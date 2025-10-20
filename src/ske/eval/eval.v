module eval

import ske.ast
import ske.core { Position, runtime_error }
import ske.checker { is_bool, is_float, is_int }

pub struct Var {
pub mut:
	type    Type
	value   Value
	mutable bool
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

pub fn eval(nodes []ast.Node) ! {
	mut ev := new_eval()
	ev.eval(nodes)!
}

pub fn (mut this Eval) init_var(type Type, name string, value Value, pos Position) ! {
	is_valid := if value !is Nil && type is BuiltinType {
		(type.is(.bool) && value.is_bool()) || (type.is(.int) && value.is_int())
			|| (type.is(.float) && value.is_float())
			|| (type.is(.string) && value.is_string())
	} else {
		true
	}
	if !is_valid {
		return runtime_error('Invalid type for variable ${name} (got ${value.type_name()} expected ${type.str()})',
			pos)
	} else {
		this.vars[name] = Var{
			type:    type
			value:   value
			mutable: name.starts_with('\$')
		}
	}
}

pub fn (mut this Eval) set_var(name string, value Value, pos Position) ! {
	if var_def := this.vars[name] {
		if !var_def.mutable {
			return runtime_error('Cannot set constant ${name}. Use \$${name} instead.',
				pos)
		}
		this.vars[name].value = value
	} else {
		return runtime_error('Cannot set variable ${name}. Define it before.', pos)
	}
}

pub fn (this Eval) get_var(name string, pos Position) !Value {
	if var_def := this.vars[name] {
		return var_def.value
	} else {
		kind := if name.starts_with('\$') { 'variable' } else { 'constant' }
		return runtime_error('Undefined ${kind} ${name}', pos)
	}
}

pub fn (mut this Eval) eval(nodes []ast.Node) ! {
	for node in nodes {
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
