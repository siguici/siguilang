module main

pub const empty_node = Node(EmptyNode(0))

pub type Node = Decl | Stmt | Block | EmptyNode
pub type EmptyNode = u8
pub type Decl = TypeDecl | VarDecl | ConstDecl | EnumDecl | FuncDecl | StructDecl
pub type Stmt = PrintStmt | IfStmt | Expr
pub type Expr = AssignExpr | BinaryExpr | UnaryExpr | LiteralExpr | ScanExpr

pub struct Program {
mut:
	nodes []Node
}

pub struct Block {
mut:
	stmts []Stmt
}

pub struct TypeDecl {
}

pub struct VarDecl {
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
	expr Expr
}

pub struct IfStmt {
	cond  Expr
	left  Block
	right &Block = unsafe { nil }
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
