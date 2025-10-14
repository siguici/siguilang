module main

import os

pub fn run(code string) {
	mut path := code
	if !os.exists(path) && !path.ends_with('.ske') {
		path += '.ske'
	}

	if os.is_file(path) {
		run_file(path)
	} else {
		run_code(code: code)
	}
}

pub fn run_file(file string) {
	code := os.read_file(file) or { panic(err) }
	run_code(code: code, file: file)
}

pub fn run_code(opts LexOptions) {
	mut t := parse(lex(opts))
	interpret(mut t)
}
