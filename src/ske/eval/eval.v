module eval

import ske.ast

pub struct Var {
pub mut:
	type  Type
	value Value
}

pub struct Eval {
mut:
	vars map[string]Var
	ctx  Context
}

pub fn Eval.new() Eval {
	return Eval{}
}

pub fn new_eval() Eval {
	return Eval.new()
}

pub fn eval(program ast.Program) ! {
	mut ev := new_eval()
	ev.eval(program)!
}

pub fn (mut this Eval) init_var(type string, name string, value Value) {
	this.vars[name] = Var{
		type:  NamedType{
			name: type
		}
		value: value
	}
}

pub fn (mut this Eval) set_var(name string, value Value) {
	this.vars[name].value = value
}

pub fn (this Eval) get_var(name string) Value {
	return this.vars[name].value
}

pub fn (mut this Eval) eval(p ast.Program) ! {
	for node in p.nodes {
		this.eval_node(node)!
	}
}

pub fn (mut this Eval) eval_node(n ast.Node) ! {
	match n {
		ast.Block {
			this.eval_block(n)!
		}
		ast.Stmt {
			this.eval_stmt(n)!
		}
		ast.EmptyNode {
			this.eval_empty(n)
		}
	}
}
