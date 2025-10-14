module ske

pub fn parse(tokens []Token) Program {
	mut p := new_parser(tokens)
	return p.parse()
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

pub fn (mut this Parser) parse() Program {
	mut nodes := []Node{}
	for !this.is_eof() {
		nodes << this.parse_block([TokenType.eof]) or { panic(err) }
		this.next()
	}
	return Program{nodes}
}

pub fn (mut this Parser) parse_block(delimiters []TokenType) !&Block {
	mut s := []Stmt{}
	for (this.remaining() > 0 && !this.current().in(delimiters)) {
		s << this.parse_stmt()!
	}
	if !(delimiters.len == 1 && TokenType.eof in delimiters) {
		this.eat_any_or_fail(delimiters, '${tokens_to_str(delimiters)} expected at the end of block')!
	}
	return &Block{s}
}

pub fn (mut this Parser) parse_stmt() !Stmt {
	return if this.eat(.print) {
		PrintStmt{this.parse_expr()!}
	} else if this.eat(.if) {
		c := this.parse_expr()!
		this.eat_or_fail(.lcbr, '{ expected after if condition')!
		b := this.parse_block([TokenType.rcbr, TokenType.else])!
		return if this.eat(.else) {
			this.current()
			this.eat_or_fail(.lcbr, '{ expected after esle')!
			IfStmt{c, b, this.parse_block([TokenType.rcbr])!}
		} else {
			IfStmt{c, b, unsafe { nil }}
		}
	} else {
		Stmt(this.parse_expr()!)
	}
}

pub fn (mut this Parser) parse_expr() !Expr {
	return this.parse_assign_expr()!
}

pub fn (mut this Parser) parse_assign_expr() !Expr {
	mut l := this.parse_scan_expr()!

	for this.eat(.assign) {
		l = AssignExpr{l, this.parse_scan_expr()!}
	}

	return l
}

pub fn (mut this Parser) parse_scan_expr() !Expr {
	if this.eat(.scan) {
		return ScanExpr{this.parse_concat_expr()!}
	}

	return this.parse_concat_expr()!
}

pub fn (mut this Parser) parse_concat_expr() !Expr {
	mut l := this.parse_term_expr()!

	for this.eat(.comma) {
		v := this.peek_back().val
		l = BinaryExpr{l, this.parse_term_expr()!, v}
	}

	return l
}

pub fn (mut this Parser) parse_term_expr() !Expr {
	mut l := this.parse_factor_expr()!

	for this.eat_any([.plus, .minus]) {
		v := this.peek_back().val
		l = BinaryExpr{l, this.parse_factor_expr()!, v}
	}

	return l
}

pub fn (mut this Parser) parse_factor_expr() !Expr {
	mut l := this.parse_power_expr()!

	for this.eat_any([.mul, .div, .mod]) {
		v := this.peek_back().val
		l = BinaryExpr{l, this.parse_power_expr()!, v}
	}

	return l
}

pub fn (mut this Parser) parse_power_expr() !Expr {
	mut r := this.parse_unary_expr()!

	for this.eat(.power) {
		v := this.peek_back().val
		r = BinaryExpr{this.parse_unary_expr()!, r, v}
	}

	return r
}

pub fn (mut this Parser) parse_unary_expr() !Expr {
	if this.eat_any([.plus, .minus, .not]) {
		v := this.peek_back().val
		return UnaryExpr{this.parse_literal_expr()!, v}
	}

	return this.parse_literal_expr()!
}

pub fn (mut this Parser) parse_literal_expr() !Expr {
	t := this.next()

	if t.in([.number, .name, .string, .char, .backticks]) {
		return LiteralExpr{t.name(), t.val}
	}

	if t.is(.lpar) {
		mut expr := this.parse_expr()!
		nt := this.current()
		if !nt.is(.rpar) {
			f := if nt.pos.file.len > 0 {
				' in ${nt.pos.file}'
			} else {
				''
			}

			return error(') expected${f} on line ${nt.pos.line} at column ${nt.pos.column} but ${nt.val} provided')
		}

		this.next()

		return expr
	}

	f := if t.pos.file.len > 0 {
		' in ${t.pos.file}'
	} else {
		''
	}

	return error('Unexpected token ${t.val}${f} on line ${t.pos.line} at column ${t.pos.column}')
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

pub fn (mut this Parser) eat_or_fail(type TokenType, message string) !bool {
	if this.eat(type) {
		return true
	}
	return error(message)
}

pub fn (mut this Parser) eat_any_or_fail(types []TokenType, message string) !bool {
	if this.eat_any(types) {
		return true
	}
	return error(message)
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
	return Token.eof()
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
	return Token.eof()
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
	return Token.eof()
}

@[direct_array_access; inline]
pub fn (mut this Parser) current() Token {
	if this.offset <= this.limit {
		return this.tokens[this.offset]
	}
	return Token.eof()
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
