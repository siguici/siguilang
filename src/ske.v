module main

import cli
import os
import v.vmod
import ske

const manifest = vmod.decode(@VMOD_FILE) or { panic(err) }

struct Program {
	cli.Command
}

pub fn Program.new() &Program {
	return &Program{cli.Command{
		name:        manifest.name
		version:     manifest.version
		description: manifest.description
		usage:       '[file | -e code]'
		flags:       [
			cli.Flag{
				flag:        .string
				name:        'eval'
				abbrev:      'e'
				description: 'Evaluate and run inline code.'
			},
			cli.Flag{
				flag:        .bool
				name:        'repl'
				abbrev:      'r'
				description: 'Start an interactive REPL session.'
			},
			cli.Flag{
				flag:        .bool
				name:        'conc'
				abbrev:      'c'
				description: 'Run multiple files concurrently.'
			},
		]
		execute:     fn (cmd cli.Command) ! {
			if code := cmd.flags.get_string('eval') {
				if code != '' {
					ske.run_code(code, path: os.getwd())
					return
				}
			}

			if cmd.flags.get_bool('repl') or { false } && ske.run_repl() {
				return
			}

			if cmd.args.len > 0 {
				if cmd.flags.get_bool('conc') or { false } {
					ske.run_many_concurrently(os.args)
				} else {
					ske.run_many(os.args)
				}
				return
			}

			if !ske.run_repl() {
				h := cmd.help_message()
				println(h)
				exit(0)
			}
		}
	}}
}

pub fn (mut p Program) run() {
	p.setup()
	p.parse(os.args)
}

pub fn main() {
	mut p := Program.new()
	p.run()
}
