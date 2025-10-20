module ske

import ske.core { Position, parser_error }
import ske.ast { ArrayDecl, AssignExpr, BinaryExpr, Block, Decl, Expr, ForStmt, IfStmt, ListDecl, LiteralExpr, Node, PrintStmt, ScanExpr, Stmt, UnaryExpr, VarDecl }

pub fn parse(tokens []Token) ![]Node {
	mut p := new_parser(tokens)
	return p.parse()!
}

pub struct Parser {
	tokens []Token
	limit  int
mut:
	offset int
}

pub fn Parser.new(tokens []Token) Parser {
	return Parser{tokens, tokens.len, 0}
}

pub fn new_parser(tokens []Token) Parser {
	return Parser.new(tokens)
}

pub fn (mut this Parser) parse() ![]Node {
	mut nodes := []Node{}
	for !this.is_eof() {
		nodes << this.parse_block([TokenType.eof])!
		this.next()
	}
	return nodes
}

pub fn (mut this Parser) parse_block(delimiters []TokenType) !&Block {
	mut s := []Stmt{}
	for (this.remaining() > 0 && !this.current().in(delimiters)) {
		this.eat_any([.semicolon, .nl])
		s << this.parse_stmt()!
		if !this.eat_any([.semicolon, .nl]) && !this.is_eof() {
			return parser_error('; or \\n expected at the end of statement', this.current().pos)
		}
	}
	if !(delimiters.len == 1 && TokenType.eof in delimiters) {
		this.eat_any_or_fail(delimiters, '${tokens_to_str(delimiters)} expected at the end of block')!
	}
	return &Block{s, this.position()}
}

pub fn (mut this Parser) parse_stmt() !Stmt {
	return if this.eat(.print) {
		PrintStmt{this.parse_expr()!, this.position()}
	} else if this.eat(.for) {
		c := this.parse_expr()!
		this.eat_or_fail(.lcbr, '{ expected after for condition')!
		b := this.parse_block([TokenType.rcbr, TokenType.else])!
		return if this.eat(.else) {
			this.current()
			this.eat_or_fail(.lcbr, '{ expected after esle')!
			ForStmt{c, b, this.parse_block([TokenType.rcbr])!, this.position()}
		} else {
			ForStmt{c, b, unsafe { nil }, this.position()}
		}
	} else if this.eat(.if) {
		c := this.parse_expr()!
		this.eat_or_fail(.lcbr, '{ expected after if condition')!
		b := this.parse_block([TokenType.rcbr, TokenType.else])!
		return if this.eat(.else) {
			this.current()
			this.eat_or_fail(.lcbr, '{ expected after esle')!
			IfStmt{c, b, this.parse_block([TokenType.rcbr])!, this.position()}
		} else {
			IfStmt{c, b, unsafe { nil }, this.position()}
		}
	} else if this.current().in([.name, .lpar, .lsbr, .lcbr]) {
		this.parse_decl()!
	} else {
		Stmt(this.parse_expr()!)
	}
}

pub fn (mut this Parser) parse_decl() !Stmt {
	return if this.current().is(.name) && this.peek().is(.name) {
		Decl(this.parse_var_decl()!)
	} else if this.current().is(.lpar) && this.peek().is(.rpar) && this.peek_n(2).is(.name)
		&& this.peek_n(3).is(.name) {
		Decl(this.parse_list_decl()!)
	} else if this.current().is(.lsbr) && this.peek().is(.name) && this.peek_n(2).is(.rsbr)
		&& this.peek_n(3).is(.name) && this.peek_n(4).is(.name) {
		Decl(this.parse_array_decl()!)
	} else {
		this.parse_expr()!
	}
}

pub fn (mut this Parser) parse_var_decl() !VarDecl {
	var_type := this.current().val
	this.advance()
	return VarDecl{var_type, this.parse_expr()!, this.position()}
}

pub fn (mut this Parser) parse_list_decl() !ListDecl {
	this.eat_or_fail(.lpar, '( expected in list declaration')!
	this.eat_or_fail(.rpar, ') expected after ( in list declaration')!
	item_type := this.current().val
	this.advance()
	return ListDecl{item_type, this.parse_expr()!, this.position()}
}

pub fn (mut this Parser) parse_array_decl() !ArrayDecl {
	this.eat_or_fail(.lsbr, '[ expected in array declaration')!
	key_type := this.current().val
	this.advance()
	this.eat_or_fail(.rsbr, '] expected after key type in array declaration')!
	value_type := this.current().val
	this.advance()
	return ArrayDecl{key_type, value_type, this.parse_expr()!, this.position()}
}

pub fn (mut this Parser) parse_expr() !Expr {
	this.eat(.nl)
	return this.parse_assign_expr()!
}

pub fn (mut this Parser) parse_assign_expr() !Expr {
	mut l := this.parse_scan_expr()!

	for this.eat(.assign) {
		l = AssignExpr{l, this.parse_scan_expr()!, this.position()}
	}

	return l
}

pub fn (mut this Parser) parse_scan_expr() !Expr {
	if this.eat(.scan) {
		return ScanExpr{this.parse_concat_expr()!, this.position()}
	}

	return this.parse_concat_expr()!
}

pub fn (mut this Parser) parse_concat_expr() !Expr {
	mut l := this.parse_term_expr()!

	for this.eat(.comma) {
		v := this.peek_back().val
		l = BinaryExpr{l, this.parse_term_expr()!, v, this.position()}
	}

	return l
}

pub fn (mut this Parser) parse_term_expr() !Expr {
	mut l := this.parse_factor_expr()!

	for this.eat_any([.plus, .minus]) {
		v := this.peek_back().val
		l = BinaryExpr{l, this.parse_factor_expr()!, v, this.position()}
	}

	return l
}

pub fn (mut this Parser) parse_factor_expr() !Expr {
	mut l := this.parse_power_expr()!

	for this.eat_any([.mul, .div, .mod]) {
		v := this.peek_back().val
		l = BinaryExpr{l, this.parse_power_expr()!, v, this.position()}
	}

	return l
}

pub fn (mut this Parser) parse_power_expr() !Expr {
	mut r := this.parse_unary_expr()!

	for this.eat(.power) {
		v := this.peek_back().val
		r = BinaryExpr{this.parse_unary_expr()!, r, v, this.position()}
	}

	return r
}

pub fn (mut this Parser) parse_unary_expr() !Expr {
	if this.eat_any([.plus, .minus, .not]) {
		v := this.peek_back().val
		return UnaryExpr{this.parse_literal_expr()!, v, this.position()}
	}

	return this.parse_literal_expr()!
}

pub fn (mut this Parser) parse_literal_expr() !Expr {
	mut t := this.next()

	if t.in([.name, .bool, .number, .string, .backticks]) {
		return LiteralExpr{t.name(), t.val, this.position()}
	}

	if t.is(.lpar) {
		mut expr := this.parse_expr()!
		nt := this.current()
		if !nt.is(.rpar) {
			return parser_error(') expected but ${nt.val} provided', t.pos)
		}

		this.next()

		return expr
	}

	return parser_error('Unexpected token ${t.val}', t.pos)
}

pub fn (this Parser) position() Position {
	return this.current().pos
}

pub fn (mut this Parser) eat(type TokenType) bool {
	if this.current().is(type) {
		this.advance()
		return true
	}
	return false
}

pub fn (mut this Parser) eat_any(types []TokenType) bool {
	if this.current().in(types) {
		this.advance()
		return true
	}
	return false
}

pub fn (mut this Parser) eat_or_fail(type TokenType, msg string) !bool {
	if this.eat(type) {
		return true
	}
	return parser_error(msg, this.current().pos)
}

pub fn (mut this Parser) eat_any_or_fail(types []TokenType, msg string) !bool {
	if this.eat_any(types) {
		return true
	}
	return parser_error(msg, this.current().pos)
}

pub fn (this &Parser) is_eof() bool {
	return this.peek().is(.eof)
}

@[inline]
pub fn (this &Parser) remaining() int {
	return this.limit - this.offset
}

@[direct_array_access; inline]
pub fn (mut this Parser) next() Token {
	o := this.offset++
	if o < this.limit {
		return this.tokens[o]
	}
	return Token.eof(this.current().pos)
}

@[inline]
pub fn (mut this Parser) skip() {
	if this.offset < this.limit {
		this.offset++
	}
}

@[inline]
pub fn (mut this Parser) skip_n(n int) {
	this.offset += n
	if this.offset > this.limit {
		this.offset = this.limit
	}
}

@[direct_array_access; inline]
pub fn (this &Parser) peek() Token {
	return this.peek_n(1)
}

@[direct_array_access; inline]
pub fn (this &Parser) peek_n(n int) Token {
	o := this.offset + n
	if o < this.limit {
		return this.tokens[o]
	}
	return Token.eof(this.current().pos)
}

@[inline]
pub fn (mut this Parser) advance() {
	if this.offset < this.limit {
		this.offset++
	}
}

pub fn (mut this Parser) advance_n(n int) {
	this.offset += n
	if this.offset > this.limit {
		this.offset = this.limit
	}
}

@[inline]
pub fn (mut this Parser) back() {
	if this.offset > 0 {
		this.offset--
	}
}

pub fn (mut this Parser) back_n(n int) {
	this.offset -= n
	if this.offset < 0 {
		this.offset = 0
	}
}

@[direct_array_access; inline]
pub fn (this &Parser) peek_back() Token {
	return this.peek_back_n(1)
}

@[direct_array_access; inline]
pub fn (this &Parser) peek_back_n(n int) Token {
	if this.offset >= n {
		return this.tokens[this.offset - n]
	}
	return Token.eof(this.current().pos)
}

@[direct_array_access; inline]
pub fn (this Parser) current() Token {
	if this.offset <= this.limit {
		return this.tokens[this.offset]
	}
	mut pos := this.peek_back().pos
	return Token.eof(pos.next_column())
}

pub fn (mut this Parser) reset() {
	this.offset = 0
}

pub fn (mut this Parser) goto_eof() {
	this.offset = this.limit
}

@[unsafe]
pub fn (mut this Parser) free() {
	unsafe {
		this.tokens.free()
	}
}
