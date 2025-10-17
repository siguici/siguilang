module ske

pub enum TokenType {
	amp        // &
	and        // &&
	and_assign // &=
	arrow      // <-
	assign     // =
	at         // @
	await
	backticks          // `ls -la`
	bit_not            // ~
	boolean_and_assign // &&=
	boolean_or_assign  // ||=
	colon              // :
	comma              // ,
	comment
	dec         // --
	decl_assign // :=
	diff        // <>
	div         // /
	div_assign  // /=
	dollar      // $
	dot         // .
	dotdot      // ..
	ellipsis    // ...
	eof
	eq                // ==
	float             // .456
	ge                // >=
	gt                // >
	hash              // #
	inc               // ++
	int               // 123
	lcbr              // {
	ldoc              // <!
	le                // <=
	left_shift        // <<
	left_shift_assign // >>=
	logical_or        // ||
	lpar              // (
	lsbr              // [
	lt                // <
	ltag              // <?
	minus             // -
	minus_assign      // -=
	mod               // %
	mod_assign        // %=
	mul               // *
	mul_assign        // *=
	name              // abc
	ne                // !=
	nl
	not                // !
	not_in             // !in
	not_is             // !is
	number             // 123.456
	or_assign          // |=
	pipe               // |
	plus               // +
	plus_assign        // +=
	power              // **
	question           // ?
	rcbr               // }
	rdoc               // !>
	right_shift        // >>
	right_shift_assign // <<=
	rpar               // )
	rsbr               // ]
	rtag               // ?>
	semicolon          // ;
	str_dollar
	string // "foo"
	unknown
	unsigned_right_shift        // >>>
	unsigned_right_shift_assign // >>>=
	whitespace
	xor        // ^
	xor_assign // ^=

	// Keywords
	as
	assert
	bool
	break
	case
	continue
	debug
	do
	dump
	else
	emit
	ensure
	exit
	extends
	false
	for
	if
	in
	is
	let
	nil
	on
	print
	private
	protected
	public
	return
	scan
	spawn
	static
	true
	type
	unset
	use

	// PHP Keywords
	class
	const
	declare
	define
	foreach
	from
	funtion
	implements
	interface
	namespace
	switch
	trait
	var
	yield
}

@[params]
pub struct TokenOptions {
	type TokenType
	pos  Position
	val  string
}

pub struct Token {
	type TokenType
	val  string
	size int
	pos  Position
}

pub fn token_to_str(type TokenType) string {
	return match type {
		.amp {
			'&'
		}
		.and {
			'&&'
		}
		.and_assign {
			'&='
		}
		.arrow {
			'<-'
		}
		.assign {
			'='
		}
		.at {
			'@'
		}
		.bit_not {
			'~'
		}
		.boolean_and_assign {
			'&&='
		}
		.boolean_or_assign {
			'||='
		}
		.colon {
			':'
		}
		.comma {
			','
		}
		.dec {
			'--'
		}
		.decl_assign {
			':='
		}
		.diff {
			'<>'
		}
		.div {
			'/'
		}
		.div_assign {
			'/='
		}
		.dollar {
			'\$'
		}
		.dot {
			'.'
		}
		.dotdot {
			'..'
		}
		.ellipsis {
			'...'
		}
		.eof {
			'EOF'
		}
		.eq {
			'=='
		}
		.ge {
			'>='
		}
		.gt {
			'>'
		}
		.hash {
			'#'
		}
		.inc {
			'++'
		}
		.ldoc {
			'<!'
		}
		.lcbr {
			'{'
		}
		.le {
			'<='
		}
		.left_shift {
			'<<'
		}
		.left_shift_assign {
			'>>='
		}
		.logical_or {
			'||'
		}
		.lpar {
			'('
		}
		.lsbr {
			'['
		}
		.lt {
			'<'
		}
		.ltag {
			'<?'
		}
		.minus {
			'-'
		}
		.minus_assign {
			'-='
		}
		.mod {
			'%'
		}
		.mod_assign {
			'%='
		}
		.mul {
			'*'
		}
		.mul_assign {
			'*='
		}
		.ne {
			'!='
		}
		.nl {
			'\n'
		}
		.not {
			'!'
		}
		.not_in {
			'!in'
		}
		.not_is {
			'!is'
		}
		.or_assign {
			'|='
		}
		.pipe {
			'|'
		}
		.plus {
			'+'
		}
		.plus_assign {
			'+='
		}
		.power {
			'**'
		}
		.question {
			'?'
		}
		.rcbr {
			'}'
		}
		.rdoc {
			'!>'
		}
		.right_shift {
			'>>'
		}
		.right_shift_assign {
			'<<='
		}
		.rpar {
			')'
		}
		.rsbr {
			']'
		}
		.rtag {
			'?>'
		}
		.semicolon {
			';'
		}
		.unsigned_right_shift {
			'>>>'
		}
		.unsigned_right_shift_assign {
			'>>>='
		}
		.xor {
			'^'
		}
		.xor_assign {
			'^='
		}
		else {
			type.str()
		}
	}
}

pub fn tokens_to_str(types []TokenType) string {
	mut s := ''
	for type in types {
		s += ' ${token_to_str(type)}'
	}
	return s.trim(' ')
}

pub fn (this Token) is(type TokenType) bool {
	return this.type == type
}

pub fn (this Token) in(types []TokenType) bool {
	for type in types {
		if this.is(type) {
			return true
		}
	}
	return false
}

pub fn (this Token) name() string {
	return token_to_str(this.type)
}

pub fn (this Token) val_is(val string) bool {
	return this.val == val || this.name() == val
}

pub fn (this Token) val_in(vals []string) bool {
	for val in vals {
		if this.val_is(val) {
			return true
		}
	}
	return false
}

pub fn Token.new(opts TokenOptions) Token {
	val := if opts.val.len > 0 {
		opts.val
	} else {
		token_to_str(opts.type)
	}
	return Token{opts.type, val, val.len, opts.pos}
}

pub fn new_token(type TokenType, val string, pos Position) Token {
	return Token.new(type: type, val: val, pos: pos)
}

pub fn new_keyword(keyword TokenType, pos Position) Token {
	return new_token(keyword, keyword.str(), pos)
}

pub fn (this Token) is_keyword() bool {
	return token_to_str(this.type) == this.val
}

pub fn Token.as(pos Position) Token {
	return new_keyword(.as, pos)
}

pub fn Token.assert(pos Position) Token {
	return new_keyword(.assert, pos)
}

pub fn Token.await(pos Position) Token {
	return new_keyword(.await, pos)
}

pub fn Token.bool(pos Position) Token {
	return new_keyword(.bool, pos)
}

pub fn Token.break(pos Position) Token {
	return new_keyword(.break, pos)
}

pub fn Token.case(pos Position) Token {
	return new_keyword(.case, pos)
}

pub fn Token.continue(pos Position) Token {
	return new_keyword(.continue, pos)
}

pub fn Token.debug(pos Position) Token {
	return new_keyword(.debug, pos)
}

pub fn Token.do(pos Position) Token {
	return new_keyword(.do, pos)
}

pub fn Token.dump(pos Position) Token {
	return new_keyword(.dump, pos)
}

pub fn Token.else(pos Position) Token {
	return new_keyword(.else, pos)
}

pub fn Token.emit(pos Position) Token {
	return new_keyword(.emit, pos)
}

pub fn Token.ensure(pos Position) Token {
	return new_keyword(.ensure, pos)
}

pub fn Token.exit(pos Position) Token {
	return new_keyword(.exit, pos)
}

pub fn Token.false(pos Position) Token {
	return new_keyword(.false, pos)
}

pub fn Token.for(pos Position) Token {
	return new_keyword(.for, pos)
}

pub fn Token.if(pos Position) Token {
	return new_keyword(.if, pos)
}

pub fn Token.in(pos Position) Token {
	return new_keyword(.in, pos)
}

pub fn Token.is(pos Position) Token {
	return new_keyword(.is, pos)
}

pub fn Token.let(pos Position) Token {
	return new_keyword(.let, pos)
}

pub fn Token.nil(pos Position) Token {
	return new_keyword(.nil, pos)
}

pub fn Token.on(pos Position) Token {
	return new_keyword(.on, pos)
}

pub fn Token.print(pos Position) Token {
	return new_keyword(.print, pos)
}

pub fn Token.public(pos Position) Token {
	return new_keyword(.public, pos)
}

pub fn Token.return(pos Position) Token {
	return new_keyword(.return, pos)
}

pub fn Token.scan(pos Position) Token {
	return new_keyword(.scan, pos)
}

pub fn Token.spawn(pos Position) Token {
	return new_keyword(.spawn, pos)
}

pub fn Token.static(pos Position) Token {
	return new_keyword(.static, pos)
}

pub fn Token.true(pos Position) Token {
	return new_keyword(.true, pos)
}

pub fn Token.type(pos Position) Token {
	return new_keyword(.type, pos)
}

pub fn Token.unset(pos Position) Token {
	return new_keyword(.unset, pos)
}

pub fn Token.use(pos Position) Token {
	return new_keyword(.use, pos)
}

pub fn Token.amp(pos Position) Token {
	return new_token(.amp, '&', pos)
}

pub fn Token.and(pos Position) Token {
	return new_token(.and, '&&', pos)
}

pub fn Token.and_assign(pos Position) Token {
	return new_token(.and_assign, '&=', pos)
}

pub fn Token.arrow(pos Position) Token {
	return new_token(.arrow, '<-', pos)
}

pub fn Token.assign(pos Position) Token {
	return new_token(.assign, '=', pos)
}

pub fn Token.at(pos Position) Token {
	return new_token(.at, '@', pos)
}

pub fn Token.backticks(val string, pos Position) Token {
	return new_token(.backticks, val, pos)
}

pub fn Token.bit_not(pos Position) Token {
	return new_token(.bit_not, '~', pos)
}

pub fn Token.boolean_and_assign(pos Position) Token {
	return new_token(.boolean_and_assign, '&&=', pos)
}

pub fn Token.boolean_or_assign(pos Position) Token {
	return new_token(.boolean_or_assign, '||=', pos)
}

pub fn Token.colon(pos Position) Token {
	return new_token(.colon, ':', pos)
}

pub fn Token.comma(pos Position) Token {
	return new_token(.comma, ',', pos)
}

pub fn Token.comment(val string, pos Position) Token {
	return new_token(.comment, val, pos)
}

pub fn Token.dec(pos Position) Token {
	return new_token(.dec, '--', pos)
}

pub fn Token.decl_assign(pos Position) Token {
	return new_token(.decl_assign, ':=', pos)
}

pub fn Token.div(pos Position) Token {
	return new_token(.div, '/', pos)
}

pub fn Token.div_assign(pos Position) Token {
	return new_token(.div_assign, '/=', pos)
}

pub fn Token.dollar(pos Position) Token {
	return new_token(.dollar, '\$', pos)
}

pub fn Token.dot(pos Position) Token {
	return new_token(.dot, '.', pos)
}

pub fn Token.dotdot(pos Position) Token {
	return new_token(.dotdot, '..', pos)
}

pub fn Token.ellipsis(pos Position) Token {
	return new_token(.ellipsis, '...', pos)
}

pub fn Token.eof() Token {
	return new_token(.eof, 'EOF', new_position())
}

pub fn Token.eq(pos Position) Token {
	return new_token(.eq, '==', pos)
}

pub fn Token.float(val string, pos Position) Token {
	return new_token(.float, val, pos)
}

pub fn Token.ge(pos Position) Token {
	return new_token(.ge, '>=', pos)
}

pub fn Token.gt(pos Position) Token {
	return new_token(.gt, '>', pos)
}

pub fn Token.hash(pos Position) Token {
	return new_token(.hash, '#', pos)
}

pub fn Token.inc(pos Position) Token {
	return new_token(.inc, '++', pos)
}

pub fn Token.int(val string, pos Position) Token {
	return new_token(.int, val, pos)
}

pub fn Token.lcbr(pos Position) Token {
	return new_token(.lcbr, '{', pos)
}

pub fn Token.le(pos Position) Token {
	return new_token(.le, '<=', pos)
}

pub fn Token.left_shift(pos Position) Token {
	return new_token(.left_shift, '<<', pos)
}

pub fn Token.left_shift_assign(pos Position) Token {
	return new_token(.left_shift_assign, '>>=', pos)
}

pub fn Token.logical_or(pos Position) Token {
	return new_token(.logical_or, '||', pos)
}

pub fn Token.lpar(pos Position) Token {
	return new_token(.lpar, '(', pos)
}

pub fn Token.lsbr(pos Position) Token {
	return new_token(.lsbr, '[', pos)
}

pub fn Token.lt(pos Position) Token {
	return new_token(.lt, '<', pos)
}

pub fn Token.ltag(pos Position) Token {
	return new_token(.ltag, '<?', pos)
}

pub fn Token.minus(pos Position) Token {
	return new_token(.minus, '-', pos)
}

pub fn Token.minus_assign(pos Position) Token {
	return new_token(.minus_assign, '-=', pos)
}

pub fn Token.mod(pos Position) Token {
	return new_token(.mod, '%', pos)
}

pub fn Token.mod_assign(pos Position) Token {
	return new_token(.mod_assign, '%=', pos)
}

pub fn Token.mul(pos Position) Token {
	return new_token(.mul, '*', pos)
}

pub fn Token.mul_assign(pos Position) Token {
	return new_token(.mul_assign, '*=', pos)
}

pub fn Token.name(val string, pos Position) Token {
	return new_token(.name, val, pos)
}

pub fn Token.ne(pos Position) Token {
	return new_token(.ne, '!=', pos)
}

pub fn Token.nl(pos Position) Token {
	return new_token(.nl, '\n', pos)
}

pub fn Token.not(pos Position) Token {
	return new_token(.not, '!', pos)
}

pub fn Token.not_in(pos Position) Token {
	return new_token(.not_in, '!in', pos)
}

pub fn Token.not_is(pos Position) Token {
	return new_token(.not_is, '!is', pos)
}

pub fn Token.number(val string, pos Position) Token {
	return new_token(.number, val, pos)
}

pub fn Token.or_assign(pos Position) Token {
	return new_token(.or_assign, '|=', pos)
}

pub fn Token.pipe(pos Position) Token {
	return new_token(.pipe, '|', pos)
}

pub fn Token.plus(pos Position) Token {
	return new_token(.plus, '+', pos)
}

pub fn Token.plus_assign(pos Position) Token {
	return new_token(.plus_assign, '+=', pos)
}

pub fn Token.question(pos Position) Token {
	return new_token(.question, '?', pos)
}

pub fn Token.rcbr(pos Position) Token {
	return new_token(.rcbr, '}', pos)
}

pub fn Token.rdoc(pos Position) Token {
	return new_token(.rdoc, '!>', pos)
}

pub fn Token.right_shift(pos Position) Token {
	return new_token(.right_shift, '>>', pos)
}

pub fn Token.right_shift_assign(pos Position) Token {
	return new_token(.right_shift_assign, '<<=', pos)
}

pub fn Token.rpar(pos Position) Token {
	return new_token(.rpar, ', pos)', pos)
}

pub fn Token.rsbr(pos Position) Token {
	return new_token(.rsbr, ']', pos)
}

pub fn Token.rtag(pos Position) Token {
	return new_token(.rtag, '?>', pos)
}

pub fn Token.semicolon(pos Position) Token {
	return new_token(.semicolon, ';', pos)
}

pub fn Token.string(val string, pos Position) Token {
	return new_token(.string, val, pos)
}

pub fn Token.unknown(val string, pos Position) Token {
	return new_token(.unknown, val, pos)
}

pub fn Token.unsigned_right_shift(pos Position) Token {
	return new_token(.unsigned_right_shift, '>>>', pos)
}

pub fn Token.unsigned_right_shift_assign(pos Position) Token {
	return new_token(.unsigned_right_shift_assign, '>>>=', pos)
}

pub fn Token.whitespace(val string, pos Position) Token {
	return new_token(.whitespace, val, pos)
}

pub fn Token.xor(pos Position) Token {
	return new_token(.xor, '^', pos)
}

pub fn Token.xor_assign(pos Position) Token {
	return new_token(.xor_assign, '^=', pos)
}
