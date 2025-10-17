module eval

import math
import os
import ske.ast

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
	r := this.eval_expr(a.right)!
	v := this.eval_name(a.left) or { panic('Cannot assign ${r}: ${err}') }

	this.ctx.mem.store(v, r)

	return r
}

fn (mut this Eval) eval_binary(b ast.BinaryExpr) !BinaryValue {
	return if b.op == ',' {
		this.eval_concat(b.left, b.right)!
	} else {
		this.eval_calcul(b.op, b.left, b.right)!
	}
}

fn (mut this Eval) eval_concat(l ast.Expr, r ast.Expr) !string {
	lv := this.eval_expr(l)!.to_str()
	rv := this.eval_expr(r)!.to_str()

	return lv + rv
}

fn (mut this Eval) eval_calcul(op string, l ast.Expr, r ast.Expr) !int {
	lv := this.eval_expr(l)!.to_int()
	rv := this.eval_expr(r)!.to_int()

	return this.eval_op(op, lv, rv)
}

fn (this Eval) eval_op(o string, l int, r int) !int {
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
			error('Unknown operator ${o}')
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
						error('`!` is only allowed on boolean value')
					}
				}
			}
			else {
				error('Unknown operator ${o}')
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
		'number' {
			v.int()
		}
		'name' {
			this.ctx.mem.find(v) or { error('Undefined variable ${v}') }
		}
		'char' {
			v
		}
		'string' {
			v
		}
		'backticks' {
			os.execute_or_exit(v).output
		}
		else {
			error('Unknown literal ${n}')
		}
	}
}

fn (mut this Eval) eval_name(e ast.Expr) !string {
	return if e is ast.LiteralExpr && e.name == 'name' {
		return e.value
	} else {
		error('Cannot use ${this.eval_expr(e)!} as name')
	}
}

fn (this Eval) eval_empty(node ast.EmptyNode) {
	// TODO
}
