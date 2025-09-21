module main

import term
import v.vmod
import readline

pub fn run_repl() bool {
	mut ran := false
	term.erase_clear()
	term.set_cursor_position(x: 0, y: 0)
	term.set_tab_title('SiguiLang')
	term.set_terminal_title('SiguiLang')
	println(term.bold(term.hex(color, center_block(logo))))
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
	print(term.hex(accent, '   ${manifest.name} v${manifest.version}') + ' — experimental build.')
	println(term.hex(color, '   │'))
	println(term.hex(color, '└────────────────────────────────────────────┘'))
	println('')
	println('Type ${q} or ${exit_i} or press ${ctrl_c} to quit.')
	mut code := ''
	mut rl := readline.Readline{}
	for {
		if mut line := rl.read_line('❯ ') {
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
	return ran
}
