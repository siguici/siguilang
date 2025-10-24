module eval

import math
import os
import ske.ast
import ske.core { Span, runtime_error }

fn (mut this Eval) eval_expr(e ast.Expr) !Value {
	return match e {
		ast.AssignExpr {
			this.eval_assign(e)
		}
		ast.BinaryExpr {
			v := this.eval_binary(e)!
			return match v {
				int, string {
					v
				}
			}
		}
		ast.UnaryExpr {
			this.eval_unary(e)
		}
		ast.LiteralExpr {
			this.eval_literal(e)!
		}
		ast.ScanExpr {
			this.eval_scan(e)!
		}
	}
}

fn (mut this Eval) eval_cond(c ast.Expr) !bool {
	return this.eval_expr(c)!.to_bool()
}

fn (mut this Eval) eval_assign(a ast.AssignExpr) !Value {
	var_value := this.eval_expr(a.right)!
	var_name := this.eval_name(a.left) or {
		return runtime_error('Cannot assign ${var_value}: ${err}', span: a.left.span)
	}

	this.set_var(var_name, var_value, a.left.span)!

	return var_value
}

fn (mut this Eval) eval_binary(b ast.BinaryExpr) !BinaryValue {
	return if b.op == ',' {
		this.eval_concat(b.left, b.right)!
	} else {
		this.eval_calcul(b.op, b.left, b.right, b.left.span)!
	}
}

fn (mut this Eval) eval_concat(l ast.Expr, r ast.Expr) !string {
	lv := this.eval_expr(l)!.to_str()
	rv := this.eval_expr(r)!.to_str()

	return lv + rv
}

fn (mut this Eval) eval_calcul(op string, l ast.Expr, r ast.Expr, span Span) !int {
	lv := this.eval_expr(l)!.to_int()
	rv := this.eval_expr(r)!.to_int()

	return this.eval_op(op, lv, rv, span)
}

fn (this Eval) eval_op(o string, l int, r int, span Span) !int {
	return match o {
		'+' {
			l + r
		}
		'-' {
			l - r
		}
		'*' {
			l * r
		}
		'/' {
			l / r
		}
		'%' {
			l % r
		}
		'^' {
			l ^ r
		}
		'**' {
			math.pow(l, r)
		}
		else {
			runtime_error('Unknown operator ${o}', span: span)
		}
	}
}

fn (mut this Eval) eval_unary(u ast.UnaryExpr) !Value {
	r := this.eval_expr(u.expr)!
	o := u.op

	if o in ['+', '-', '!'] {
		return match o {
			'+' {
				r.to_int()
			}
			'-' {
				-r.to_int()
			}
			'!' {
				match r {
					true {
						false
					}
					false {
						true
					}
					else {
						runtime_error('`!` is only allowed on boolean value', span: u.expr.span)
					}
				}
			}
			else {
				runtime_error('Unknown operator ${o}', span: u.expr.span)
			}
		}
	} else {
		return r
	}
}

fn (this Eval) eval_literal(l ast.LiteralExpr) !Value {
	n := l.name
	v := l.value

	return match n {
		'bool' {
			if v == 'true' {
				true
			} else if v == 'false' {
				false
			} else {
				return runtime_error('Unknown boolean value ${v}', span: l.span)
			}
		}
		'number' {
			if v.contains('.') {
				v.f64()
			} else {
				v.int()
			}
		}
		'name' {
			this.get_var(v, l.span)!
		}
		'string' {
			v
		}
		'backticks' {
			os.execute_or_exit(v).output
		}
		else {
			runtime_error('Unknown literal ${n}', span: l.span)
		}
	}
}

fn (mut this Eval) eval_name(e ast.Expr) !string {
	return if e is ast.LiteralExpr && e.name == 'name' {
		e.value
	} else {
		runtime_error('Cannot use ${this.eval_expr(e)!} as name', span: e.span)
	}
}

fn (mut this Eval) eval_type(e ast.Expr) !Type {
	if e is ast.LiteralExpr && e.name == 'name' {
		return Type.from(e.value)
	} else {
		return runtime_error('Cannot use ${this.eval_expr(e)!} as type', span: e.span)
	}
}

fn (this Eval) eval_empty(node ast.EmptyNode) {
	// TODO
}
