module main

import cli
import os
import ske

struct Program {
	cli.Command
}

pub fn Program.new() &Program {
	return &Program{
		Command: cli.Command{
			name:        'ske'
			description: 'Run a script or a code'
			usage:       '[file_or_code]'
			execute:     fn (cmd cli.Command) ! {
				args := cmd.args
				if args.len < 1 {
					if !ske.run_repl() {
						h := cmd.help_message()
						println(h)
						exit(0)
					}
				}

				for arg in cmd.args {
					ske.run(arg)
				}
			}
		}
	}
}

pub fn (mut p Program) run() {
	p.setup()
	p.parse(os.args)
}

pub fn main() {
	mut p := Program.new()
	p.run()
}
