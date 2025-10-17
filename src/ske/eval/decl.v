module eval

import ske.ast

fn (mut this Eval) decl(d ast.Decl) ! {
	match d {
		ast.VarDecl {
			this.decl_var(d.type, d.expr)!
		}
		else {
			error('Not implemented')
		}
	}
}

fn (mut this Eval) decl_var(type string, expr ast.Expr) ! {
	match expr {
		ast.AssignExpr {
			value := this.eval_expr(expr.right)!
			name := this.eval_name(expr.left)!
			this.init_var(type, name, value)!
		}
		ast.LiteralExpr {
			name := if expr.name == 'name' {
				expr.value
			} else {
				error('Cannot declare a variable with ${expr.name}')
				''
			}
			this.init_var(type, name, Nil{})!
		}
		else {
			error('Cannot declare variable of type ${type} with expression ${expr}')
		}
	}
}
