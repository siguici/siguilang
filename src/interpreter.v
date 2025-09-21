module main

pub fn interpret(ast []Node) {
	mut e := new_eval()

	for i := 0; i < ast.len; i++ {
		mut n := ast[i]

		if check(n) {
			n = optimize(n)
		}

		e.eval(n) or { panic(err) }
	}
}
