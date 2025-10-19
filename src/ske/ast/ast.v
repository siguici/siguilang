module ast

import ske.core { Position }

pub const empty_node = Node(EmptyNode(0))

pub type Node = Stmt | Block | EmptyNode
pub type EmptyNode = u8
pub type Stmt = Decl | PrintStmt | IfStmt | ForStmt | Expr
pub type Decl = TypeDecl | VarDecl | ConstDecl | EnumDecl | FuncDecl | StructDecl
pub type Expr = AssignExpr | BinaryExpr | UnaryExpr | LiteralExpr | ScanExpr

pub struct Block {
pub:
	stmts []Stmt
	pos   Position
}

pub struct TypeDecl {
	pos Position
}

pub struct VarDecl {
pub:
	type string
	expr Expr
	pos  Position
}

pub struct ConstDecl {
	pos Position
}

pub struct EnumDecl {
	pos Position
}

pub struct FuncDecl {
	pos Position
}

pub struct StructDecl {
	pos Position
}

pub struct PrintStmt {
pub:
	expr Expr
	pos  Position
}

pub struct IfStmt {
pub:
	cond  Expr
	left  Block
	right &Block = unsafe { nil }
	pos   Position
}

pub struct ForStmt {
pub:
	cond  Expr
	left  Block
	right &Block = unsafe { nil }
	pos   Position
}

pub struct ScanExpr {
pub:
	prompt Expr
	pos    Position
}

pub struct AssignExpr {
pub:
	left  Expr
	right Expr
	pos   Position
}

pub struct BinaryExpr {
pub:
	left  Expr
	right Expr
	op    string
	pos   Position
}

pub struct UnaryExpr {
pub:
	expr Expr
	op   string
	pos  Position
}

pub struct LiteralExpr {
pub:
	name  string
	value string
	pos   Position
}
