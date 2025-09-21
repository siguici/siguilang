module main

pub const empty_node = Node(EmptyNode(0))

pub type Node = Script | EmptyNode
pub type EmptyNode = u8
pub type Stmt = PrintStmt | IfStmt | Expr
pub type Expr = AssignExpr | BinaryExpr | UnaryExpr | LiteralExpr | ScanExpr

pub struct Script {
	stmts []Stmt
}

pub struct PrintStmt {
	expr Expr
}

pub struct IfStmt {
	cond  Expr
	left  Script
	right &Script = unsafe { nil }
}

pub struct ScanExpr {
	prompt Expr
}

pub struct AssignExpr {
	left  Expr
	right Expr
}

pub struct BinaryExpr {
	left  Expr
	right Expr
	op    string
}

pub struct UnaryExpr {
	expr Expr
	op   string
}

pub struct LiteralExpr {
	name  string
	value string
}
