module ast

pub const empty_node = Node(EmptyNode(0))

pub type Node = Stmt | Block | EmptyNode
pub type EmptyNode = u8
pub type Stmt = Decl | PrintStmt | IfStmt | Expr
pub type Decl = TypeDecl | VarDecl | ConstDecl | EnumDecl | FuncDecl | StructDecl
pub type Expr = AssignExpr | BinaryExpr | UnaryExpr | LiteralExpr | ScanExpr

pub struct Program {
pub:
	nodes []Node
}

pub struct Block {
pub:
	stmts []Stmt
}

pub struct TypeDecl {
}

pub struct VarDecl {
pub:
	type string
	expr Expr
}

pub struct ConstDecl {
}

pub struct EnumDecl {
}

pub struct FuncDecl {
}

pub struct StructDecl {
}

pub struct PrintStmt {
pub:
	expr Expr
}

pub struct IfStmt {
pub:
	cond  Expr
	left  Block
	right &Block = unsafe { nil }
}

pub struct ScanExpr {
pub:
	prompt Expr
}

pub struct AssignExpr {
pub:
	left  Expr
	right Expr
}

pub struct BinaryExpr {
pub:
	left  Expr
	right Expr
	op    string
}

pub struct UnaryExpr {
pub:
	expr Expr
	op   string
}

pub struct LiteralExpr {
pub:
	name  string
	value string
}
