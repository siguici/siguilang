module main

import cli
import term
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
		]
		execute:     fn (cmd cli.Command) ! {
			if code := cmd.flags.get_string('eval') {
				if code != '' {
					ske.run_code(code: code)
					return
				}
			}

			if cmd.flags.get_bool('repl') or { false } && ske.run_repl() {
				return
			}

			if cmd.args.len > 0 {
				for file_path in cmd.args {
					if os.exists(file_path) {
						ske.run_file(file_path)
					} else {
						eprintln(term.red('File ${file_path} not found'))
					}
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
