module main

import term
import v.vmod
import readline

fn quit_repl(msg string) {
	println('\n${msg}\nGoodbye 👋')
	exit(0)
}

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
	lines := [
		term.bold(term.hex(color, ' ┌────────────────────────────────────────────┐')),
		term.hex(color, ' │') +
			term.hex(accent, '     Welcome to the ${term.bg_hex(accent, term.white(' Sigui'))}') +
			term.bg_white(term.hex(accent, 'Lang ')) + term.hex(accent, ' REPL 🐉') +
			term.hex(color, '     │'),
		term.hex(color, ' │                                            │'),
		term.hex(color, ' │ The Sigui Programming Language (SiguiLang) │'),
		term.hex(color, ' │ A modern, high-performance scripting lang  │'),
		term.hex(color, ' │ with PHP-inspired syntax & TS-like typing. │'),
		term.hex(color, ' │                                            │'),
		term.hex(color, ' │ No tags, no semicolons—just code naturally.│'),
		term.hex(color, ' │                                            │'),
		term.hex(color, ' │') +
			term.hex(accent, '   ${manifest.name} v${manifest.version} — experimental build.') +
			term.hex(color, '   │'),
		term.hex(color, ' └────────────────────────────────────────────┘'),
		'',
		'Type ${q} or ${exit_i} or press ${ctrl_c} to quit.',
	]

	println(center_block_lines(lines))
	mut code := ''
	mut rl := readline.Readline{}
	for {
		mut line := rl.read_line('❯ ') or {
			quit_repl('Program interrupted.')
			break
		}

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

		quit_repl('Exiting REPL...')
		break
	}
	return ran
}
