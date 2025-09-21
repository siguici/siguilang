module main

import os
import cli
import term
import v.vmod

const logo = os.read_file('logo.txt') or { '' }

const color = 59064 // #00E6B8
const accent = 16744258 // #FF8C42

pub fn main() {
	mut app := cli.Command{
		name:        'siguilang'
		description: 'Run a script or a code'
		usage:       '[file_or_code]'
		execute:     fn (cmd cli.Command) ! {
			term.set_tab_title('SiguiLang')
			term.set_terminal_title('SiguiLang')
			println(term.bold(term.hex(color, logo)))

			args := cmd.args
			if args.len < 1 {
				mut ran := false
				q := term.bg_red(term.white(term.bold(' \\q ')))
				exit_i := term.bg_red(term.white(term.bold(' exit() ')))
				ctrl_c := term.bg_red(term.white(' Ctrl+C '))
				manifest := vmod.decode(@VMOD_FILE) or { panic(err) }
				println(term.bold(term.hex(color, '┌────────────────────────────────────────────┐')))
				print(term.hex(color, '│'))
				print(term.hex(accent, '    Welcome to the ${term.bg_hex(color, term.white(' Sigui '))}'))
				print(term.bg_white(term.hex(color, ' Lang ')))
				print(term.hex(accent, ' REPL 🐉'))
				println(term.hex(color, '    │'))
				println(term.hex(color, '│                                            │'))
				println(term.hex(color, '│ The Sigui Programming Language (SiguiLang) │'))
				println(term.hex(color, '│ A modern, high-performance scripting lang  │'))
				println(term.hex(color, '│ with PHP-inspired syntax & TS-like typing. │'))
				println(term.hex(color, '│                                            │'))
				println(term.hex(color, '│ No tags, no semicolons—just code naturally.│'))
				println(term.hex(color, '│                                            │'))
				print(term.hex(color, '│'))
				print(term.hex(accent, '   ${manifest.name} v${manifest.version}') +
					' — experimental build.')
				println(term.hex(color, '   │'))
				println(term.hex(color, '└────────────────────────────────────────────┘'))
				println('')
				println('Type ${q} or ${exit_i} or press ${ctrl_c} to quit.')
				mut code := ''
				for {
					if mut line := os.input_opt('❯ ') {
						if line !in ['\\q', 'exit()'] {
							ran = true
							mut line_code := code
							code += '\n${line}'
							if !line.starts_with('print ') {
								line += 'print ${line}\n'
							}
							line_code += '\n${line}'
							run('<? ${line_code} ?>')
							continue
						}
						break
					}
				}
				if !ran {
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
