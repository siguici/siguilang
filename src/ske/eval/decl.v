module eval

import ske.ast
import ske.core { runtime_error }

fn (mut this Eval) decl(d ast.Decl) ! {
	match d {
		ast.VarDecl {
			this.decl_var(d.type, d.expr)!
		}
		ast.ListDecl {
			this.decl_list(d.item_type, d.expr)!
		}
		ast.ArrayDecl {
			this.decl_array(d.key_type, d.value_type, d.expr)!
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
			name := this.eval_name(expr.left)!
			value := this.eval_expr(expr.right)!
			this.init_var(Type.from(type), name, value, expr.pos)!
		}
		ast.LiteralExpr {
			name := if expr.name == 'name' {
				expr.value
			} else {
				return runtime_error('Cannot declare a variable with ${expr.name}', expr.pos)
			}
			this.init_var(Type.from(type), name, Nil{}, expr.pos)!
		}
		else {
			return runtime_error('Cannot declare variable of type ${type} with expression ${expr}',
				expr.pos)
		}
	}
}

fn (mut this Eval) decl_list(item_type string, expr ast.Expr) ! {
	type := ListType{
		item_type: Type.from(item_type)
	}
	match expr {
		ast.AssignExpr {
			name := this.eval_name(expr.left)!
			value := this.eval_expr(expr.right)!
			this.init_var(type, name, value, expr.pos)!
		}
		ast.LiteralExpr {
			name := if expr.name == 'name' {
				expr.value
			} else {
				return runtime_error('Cannot declare a list of type ()${item_type} with ${expr.name}',
					expr.pos)
			}
			this.init_var(type, name, Nil{}, expr.pos)!
		}
		else {
			return runtime_error('Cannot declare list of type ()${item_type} with expression ${expr}',
				expr.pos)
		}
	}
}

fn (mut this Eval) decl_array(key_type string, value_type string, expr ast.Expr) ! {
	type := ArrayType{
		key_type:   Type.from(key_type)
		value_type: Type.from(value_type)
	}
	match expr {
		ast.AssignExpr {
			name := this.eval_name(expr.left)!
			value := this.eval_expr(expr.right)!
			this.init_var(type, name, value, expr.pos)!
		}
		ast.LiteralExpr {
			name := if expr.name == 'name' {
				expr.value
			} else {
				return runtime_error('Cannot declare an array of type [${key_type}]${value_type} with ${expr.name}',
					expr.pos)
			}
			this.init_var(type, name, Nil{}, expr.pos)!
		}
		else {
			return runtime_error('Cannot declare an array of type [${key_type}]${value_type} with expression ${expr}',
				expr.pos)
		}
	}
}
