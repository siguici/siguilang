module eval

import os
import ske.ast

fn (mut this Eval) eval_stmt(s ast.Stmt) ! {
	match s {
		ast.PrintStmt {
			this.eval_print(s)!
		}
		ast.IfStmt {
			this.eval_if(s)!
		}
		ast.Decl {
			this.decl(s)!
		}
		ast.Expr {
			this.eval_expr(s)!
		}
	}
}

fn (mut this Eval) eval_print(p ast.PrintStmt) ! {
	r := this.eval_expr(p.expr)!
	println(r.to_str())
}

fn (mut this Eval) eval_scan(s ast.ScanExpr) !string {
	p := this.eval_expr(s.prompt)!
	return os.input(p.to_str())
}

fn (mut this Eval) eval_if(s ast.IfStmt) ! {
	c := this.eval_cond(s.cond)!

	if c {
		this.eval_block(s.left)!
	}

	if !c && s.right != unsafe { nil } {
		this.eval_block(s.right)!
	}
}

pub fn (mut this Eval) eval_block(b ast.Block) ! {
	for stmt in b.stmts {
		this.eval_stmt(stmt)!
	}
}
