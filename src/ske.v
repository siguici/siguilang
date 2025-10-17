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
		commands:    [
			cli.Command{
				name:        'release'
				description: 'Re-build Ske'
				usage:       'ske release'
				execute:     fn (cmd cli.Command) ! {
					args := cmd.args
					if args.len >= 1 {
						eprintln('❌ Unknown command : ${args[0]}')
						exit(1)
					}
					ske.do_release()
				}
			},
			cli.Command{
				name:        'up'
				description: 'Upgrade the Ske CLI'
				usage:       'ske up [-version]'
				flags:       [
					cli.Flag{
						flag:        .string
						name:        'version'
						abbrev:      'v'
						description: 'The version to upgrade to'
					},
				]
				execute:     fn (cmd cli.Command) ! {
					args := cmd.args
					if args.len >= 1 {
						eprintln('❌ Unknown command : ${args[0]}')
						exit(1)
					}
					if version := cmd.flags.get_string('version') {
						if version != '' {
							ske.self_upgrade_to(version)
							return
						}
					}
					ske.self_upgrade()
				}
			},
		]
		execute:     fn (cmd cli.Command) ! {
			if code := cmd.flags.get_string('eval') {
				if code != '' {
					ske.run_code(code, file: os.args[0], dir: os.getwd()) or { panic(err) }
					return
				}
			}

			if cmd.flags.get_bool('repl') or { false } && ske.run_repl() {
				return
			}

			if cmd.args.len > 0 {
				if cmd.flags.get_bool('conc') or { false } {
					ske.run_many_concurrently(cmd.args, dir: os.getwd()) or { panic(err) }
				} else {
					ske.run_many(cmd.args, dir: os.getwd()) or { panic(err) }
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
