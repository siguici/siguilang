module eval

import ske.ast
import ske.core { runtime_error }

fn (mut this Eval) decl(d ast.Decl) ! {
	match d {
		ast.VarDecl {
			this.decl_var(d.type, d.expr)!
		}
		else {
			// TODO
			return error('${d} is not implemented')
		}
	}
}

fn (mut this Eval) decl_var(type string, expr ast.Expr) ! {
	match expr {
		ast.AssignExpr {
			value := this.eval_expr(expr.right)!
			name := this.eval_name(expr.left)!
			this.init_var(type, name, value, expr.pos)!
		}
		ast.LiteralExpr {
			name := if expr.name == 'name' {
				expr.value
			} else {
				return runtime_error('Cannot declare a variable with ${expr.name}', expr.pos)
			}
			this.init_var(type, name, Nil{}, expr.pos)!
		}
		else {
			return runtime_error('Cannot declare variable of type ${type} with expression ${expr}',
				expr.pos)
		}
	}
}
