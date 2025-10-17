module ske

import ske.ast
import ske.eval

pub fn interpret(mut program ast.Program) ! {
	mut e := eval.new_eval()
	e.eval(program)!
}
