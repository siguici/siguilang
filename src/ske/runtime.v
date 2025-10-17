module ske

import os
import sync

@[params]
pub struct RunParams {
pub:
	path string
	root string
}

pub fn run(code string, params RunParams) ! {
	mut path := code
	if !os.exists(path) && !path.ends_with('.ske') {
		path += '.ske'
	}

	if os.exists(path) {
		run_path(path)!
	} else {
		run_code(code, params)!
	}
}

pub fn run_path(path string, params RunParams) ! {
	if os.is_dir(path) {
		for file in os.ls(path) or { []string{} } {
			run_path('${path}/${file}', params)!
		}
	} else {
		run_file(path, params)!
	}
}

pub fn run_file(file string, params RunParams) ! {
	code := os.read_file(file) or { panic(err) }
	run_code(code, path: file, root: params.root)!
}

pub fn run_code(code string, params RunParams) ! {
	t := tokenize(code, file: params.path, dir: params.root)
	mut p := parse(t)
	interpret(mut p)!
}

pub fn run_many(inputs []string, params RunParams) ! {
	for input in inputs {
		run(input, params)!
	}
}

pub fn run_many_concurrently(inputs []string, params RunParams) ! {
	mut wg := sync.new_waitgroup()
	wg.add(inputs.len)
	defer {
		wg.done()
	}
	for input in inputs {
		go fn (_input string, mut _wg sync.WaitGroup) ! {
			defer {
				_wg.done()
			}
			run(_input) or {
				_wg.done()
				return err
			}
		}(input, mut wg)
	}
	wg.wait()
}
