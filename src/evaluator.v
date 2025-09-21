module main

import os
import math

type Value = int | f64 | string | bool
type BinaryValue = int | string

pub struct Eval {
mut:
	ctx Context
}

pub fn Eval.new() Eval {
	return Eval{}
}

pub fn new_eval() Eval {
	return Eval.new()
}

pub fn eval(node Node) ! {
	mut ev := new_eval()
	ev.eval(node)!
}

pub fn (mut this Eval) eval(n Node) ! {
	match n {
		Script {
			this.eval_script(n)!
		}
		EmptyNode {
			this.eval_empty(n)
		}
	}
}

fn (mut this Eval) eval_script(s Script) ! {
	for stmt in s.stmts {
		this.eval_stmt(stmt)!
	}
}

fn (mut this Eval) eval_stmt(s Stmt) ! {
	match s {
		PrintStmt {
			this.eval_print(s)!
		}
		IfStmt {
			this.eval_if(s)!
		}
		Expr {
			this.eval_expr(s)!
		}
	}
}

fn (mut this Eval) eval_print(p PrintStmt) ! {
	r := this.eval_expr(p.expr)!
	println(to_str(r))
}

fn (mut this Eval) eval_scan(s ScanExpr) !string {
	p := this.eval_expr(s.prompt)!
	return os.input(to_str(p))
}

fn (mut this Eval) eval_if(s IfStmt) ! {
	c := this.eval_cond(s.cond)!

	if c {
		this.eval_script(s.left)!
	}

	if !c && s.right != unsafe { nil } {
		this.eval_script(s.right)!
	}
}

fn (mut this Eval) eval_cond(c Expr) !bool {
	return to_bool(this.eval_expr(c)!)
}

fn (mut this Eval) eval_expr(e Expr) !Value {
	return match e {
		AssignExpr {
			this.eval_assign(e)
		}
		BinaryExpr {
			v := this.eval_binary(e)!
			return match v {
				int, string {
					v
				}
			}
		}
		UnaryExpr {
			this.eval_unary(e)
		}
		LiteralExpr {
			this.eval_literal(e)!
		}
		ScanExpr {
			this.eval_scan(e)!
		}
	}
}

fn (mut this Eval) eval_assign(a AssignExpr) !Value {
	r := this.eval_expr(a.right)!
	v := this.eval_name(a.left) or { panic('Cannot assign ${r}: ${err}') }

	this.ctx.mem.store(v, r)

	return r
}

fn (mut this Eval) eval_binary(b BinaryExpr) !BinaryValue {
	return if b.op == ',' {
		this.eval_concat(b.left, b.right)!
	} else {
		this.eval_calcul(b.op, b.left, b.right)!
	}
}

fn (mut this Eval) eval_concat(l Expr, r Expr) !string {
	lv := to_str(this.eval_expr(l)!)
	rv := to_str(this.eval_expr(r)!)

	return lv + rv
}

fn (mut this Eval) eval_calcul(op string, l Expr, r Expr) !int {
	lv := to_int(this.eval_expr(l)!)
	rv := to_int(this.eval_expr(r)!)

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

fn (mut this Eval) eval_unary(u UnaryExpr) !Value {
	r := this.eval_expr(u.expr)!
	o := u.op

	if o in ['+', '-', '!'] {
		return match o {
			'+' {
				to_int(r)
			}
			'-' {
				-to_int(r)
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

fn (this Eval) eval_literal(l LiteralExpr) !Value {
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

fn (mut this Eval) eval_name(e Expr) !string {
	return if e is LiteralExpr && e.name == 'name' {
		return e.value
	} else {
		error('Cannot use ${this.eval_expr(e)!} as name')
	}
}

fn (this Eval) eval_empty(node EmptyNode) {
	// TODO
}
