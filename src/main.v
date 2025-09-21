module main

import os
import cli
import term

pub fn main() {
	mut app := cli.Command{
		name:        'siguilang'
		description: 'Run a script or a code'
		usage:       '[file_or_code]'
		execute:     fn (cmd cli.Command) ! {
			args := cmd.args
			if args.len < 1 {
				if !run_repl() {
					h := cmd.help_message()
					println(h)
					exit(0)
				}
			}

			for arg in cmd.args {
				println(term.ok_message('Running ${arg}...'))
				run(arg)
			}
		}
	}

	app.setup()
	app.parse(os.args)
}
