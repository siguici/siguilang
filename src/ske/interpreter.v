module ske

pub fn interpret(mut program Program) {
	mut e := new_eval()

	for i := 0; i < program.nodes.len; i++ {
		mut node := program.nodes[i]

		if check(node) {
			node = optimize(node)
		}

		program.nodes[i] = node
	}

	e.eval(program) or { panic('Failed to interpret program: ${err.msg()}') }
}
