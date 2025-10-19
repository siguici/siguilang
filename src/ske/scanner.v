module ske

import strings.textscanner
import ske.core { Position, scanner_error }

@[params]
pub struct ScannerOptions {
	file string
	dir  string
	line int = 1
	col  int = 1
}

@[noinit]
pub struct Scanner {
	textscanner.TextScanner
pub:
	file string
	dir  string
pub mut:
	line int = 1
	col  int = 1
}

pub fn Scanner.new(input string, options ScannerOptions) Scanner {
	return Scanner{
		TextScanner: textscanner.new(input)
		file:        options.file
		dir:         options.dir
		line:        options.line
		col:         options.col
	}
}

pub fn new_scanner(input string, options ScannerOptions) Scanner {
	return Scanner.new(input, options)
}

pub fn tokenize(input string, options ScannerOptions) ![]Token {
	mut sc := new_scanner(input, options)
	return sc.tokenize()!
}

pub fn (mut this Scanner) tokenize() ![]Token {
	mut t := []Token{}

	for this.next() != -1 && this.pos != this.ilen {
		c := this.scan()!
		if !c.is(.whitespace) {
			t << c
		}
	}

	if !this.current_is_space() {
		t << this.scan()!
	}

	return t
}

pub fn (mut this Scanner) scan() !Token {
	c := this.current_u8()
	match c {
		`<` {
			this.col++
			match this.peek_u8() {
				`>` {
					this.col++
					this.next()
					return this.token_ne()
				}
				`<` {
					this.col++
					this.next()
					match this.peek_u8() {
						`=` {
							this.col++
							this.next()
							return this.token_right_shift_assign()
						}
						else {
							return this.token_left_shift()
						}
					}
				}
				`-` {
					this.col++
					this.next()
					return this.token_arrow()
				}
				`?` {
					this.col++
					this.next()
					return this.token_ltag()
				}
				`!` {
					this.col++
					this.next()
					return this.token_ldoc()
				}
				`=` {
					this.col++
					this.next()
					return this.token_le()
				}
				else {
					return this.token_lt()
				}
			}
		}
		`>` {
			this.col++
			match this.peek_u8() {
				`>` {
					this.col++
					this.next()
					match this.peek_u8() {
						`>` {
							this.col++
							this.next()
							return if this.peek_u8() == `=` {
								this.col++
								this.next()
								this.token_unsigned_right_shift_assign()
							} else {
								this.token_unsigned_right_shift()
							}
						}
						`=` {
							this.col++
							this.next()
							return this.token_left_shift_assign()
						}
						else {
							return this.token_right_shift()
						}
					}
				}
				`=` {
					this.col++
					this.next()
					return this.token_ge()
				}
				else {
					return this.token_gt()
				}
			}
		}
		`|` {
			this.col++
			if this.peek_u8() == `|` {
				this.col++
				this.next()
				if this.peek_u8() == `=` {
					this.col++
					this.next()
					return if this.peek_u8() == `=` {
						this.col++
						this.next()
						this.token_boolean_or_assign()
					} else {
						this.token_or_assign()
					}
				} else {
					return this.token_logical_or()
				}
			} else {
				return this.token_pipe()
			}
		}
		`.` {
			this.col++
			if this.peek_u8() == `.` {
				this.col++
				this.next()
				return if this.peek_u8() == `.` {
					this.col++
					this.next()
					this.token_ellipsis()
				} else {
					this.token_dotdot()
				}
			} else {
				return this.token_dot()
			}
		}
		`@`, `~`, `,`, `;`, `$`, `#`, `(`, `)`, `{`, `}`, `[`, `]` {
			this.col++
			return match c {
				`@` {
					this.token_at()
				}
				`~` {
					this.token_bit_not()
				}
				`,` {
					this.token_comma()
				}
				`$` {
					mut t := this.token_dollar()
					if this.peek_is_letter() {
						id := this.scan_identifier()
						if id.len >= 1 {
							this.pos--
							t = this.token_name(id)
						}
					}
					return t
				}
				`#` {
					this.token_hash()
				}
				`(` {
					this.token_lpar()
				}
				`)` {
					this.token_rpar()
				}
				`{` {
					this.token_lcbr()
				}
				`}` {
					this.token_rcbr()
				}
				`[` {
					this.token_lsbr()
				}
				`]` {
					this.token_rsbr()
				}
				else {
					this.token_semicolon()
				}
			}
		}
		`!` {
			this.col++
			if this.peek_u8() == `i` && this.peek_n_u8(2) in [`s`, `n`] {
				this.col += 2
				this.pos += 2
				return if this.current_u8() == `s` {
					this.token_not_is()
				} else {
					this.token_not_in()
				}
			}
			match this.peek_u8() {
				`=` {
					this.col++
					this.next()
					return this.token_ne()
				}
				`>` {
					this.col++
					this.next()
					return this.token_rdoc()
				}
				else {
					return this.token_not()
				}
			}
		}
		`&` {
			this.col++
			match this.peek_u8() {
				`&` {
					this.col++
					this.next()
					if this.peek_u8() == `=` {
						this.col++
						this.next()
						return this.token_boolean_and_assign()
					}
					return this.token_and()
				}
				`=` {
					this.col++
					this.next()
					return this.token_and_assign()
				}
				else {
					return this.token_amp()
				}
			}
		}
		`?` {
			this.col++
			match this.peek_u8() {
				`>` {
					this.col++
					this.next()
					return this.token_rtag()
				}
				else {
					return this.token_question()
				}
			}
		}
		`=` {
			this.col++
			if this.peek_u8() == `=` {
				this.col++
				this.next()
				return this.token_eq()
			}
			return this.token_assign()
		}
		`:` {
			this.col++
			if this.peek_u8() == `=` {
				this.col++
				this.next()
				return this.token_decl_assign()
			}
			return this.token_colon()
		}
		`^` {
			this.col++
			if this.peek_u8() == `=` {
				this.col++
				this.next()
				return this.token_xor_assign()
			}
			return this.token_xor()
		}
		`*` {
			this.col++
			match this.peek_u8() {
				`*` {
					this.col++
					this.next()
					return this.token_power()
				}
				`=` {
					this.col++
					this.next()
					return this.token_mul_assign()
				}
				else {
					return this.token_mul()
				}
			}
		}
		`/` {
			this.col++
			if this.peek_u8() == `=` {
				this.col++
				this.next()
				return this.token_div_assign()
			}
			return this.token_div()
		}
		`%` {
			this.col++
			if this.peek_u8() == `=` {
				this.col++
				this.next()
				return this.token_mod_assign()
			}
			return this.token_mod()
		}
		`+` {
			this.col++
			match this.peek_u8() {
				`+` {
					this.col++
					this.next()
					return this.token_inc()
				}
				`=` {
					this.col++
					this.next()
					return this.token_plus_assign()
				}
				else {
					return this.token_plus()
				}
			}
		}
		`-` {
			this.col++
			match this.peek_u8() {
				`-` {
					this.col++
					this.next()
					return this.token_dec()
				}
				`=` {
					this.col++
					this.next()
					return this.token_minus_assign()
				}
				else {
					return this.token_minus()
				}
			}
		}
		`'`, `"`, `\`` {
			ss := this.scan_string(this.current())!
			if ss.len >= 1 {
				return if c == `\`` {
					this.token_backticks(ss)
				} else {
					this.token_string(ss)
				}
			}
		}
		else {
			nl := this.scan_newline()
			if nl.len >= 1 {
				this.pos--
				return this.token_nl()
			}

			sp := this.scan_whitespace()
			if sp.len >= 1 {
				this.pos--
				return this.token_whitespace(sp)
			}

			nb := this.scan_number()
			if nb.len >= 1 {
				this.pos--
				return this.token_number(nb)
			}

			id := this.scan_identifier()
			if id.len >= 1 {
				this.pos--
				return match id {
					'true', 'false' {
						this.token_bool(id)
					}
					'print' {
						this.token_print()
					}
					'scan' {
						this.token_scan()
					}
					'if' {
						this.token_if()
					}
					'else' {
						this.token_else()
					}
					else {
						this.token_name(id)
					}
				}
			}
		}
	}

	return this.token_unknown(c.ascii_str())
}

pub fn (mut this Scanner) scan_string(delimiter int) !string {
	this.col++
	this.next()
	mut v := ''
	mut end := false

	for (this.pos < this.ilen) {
		if this.current() == delimiter && this.peek_back() != `\\` {
			end = true
			break
		}
		if this.current() == `\\` {
			v += match this.peek_u8() {
				`n` {
					'\n'
				}
				`r` {
					'\r'
				}
				`t` {
					'\t'
				}
				`\\` {
					'\\'
				}
				u8(delimiter) {
					u8(delimiter).ascii_str()
				}
				else {
					return scanner_error('Cannot escape ${this.peek_u8().ascii_str()}',
						this.position())
				}
			}
			this.col += 2
			this.next()
			this.next()
			continue
		}
		if this.current_is_new_line() {
			this.line++
			this.col = 1
		} else {
			this.col++
		}
		v += this.current_str()
		this.next()
	}

	if this.peek() == -1 && this.current() == delimiter {
		end = true
		this.next()
	}

	if !end {
		return scanner_error('End of string ${u8(delimiter).ascii_str()} expected', this.position())
	}

	return v
}

pub fn (mut this Scanner) scan_newline() string {
	mut w := ''

	for (this.pos < this.ilen || this.peek() != -1) && this.current_is_new_line() {
		this.line++
		this.col = 1
		w += this.current_str()
		this.next()
	}

	return w
}

pub fn (mut this Scanner) scan_whitespace() string {
	mut w := ''

	for (this.pos < this.ilen || this.peek() != -1) && this.current_is_space()
		&& !this.current_is_new_line() {
		w += this.current_str()
		this.col++
		this.next()
	}

	return w
}

pub fn (mut this Scanner) scan_number() string {
	mut nb := ''

	if this.current_is_digit() || (this.current_is_dot() && this.peek_is_digit()) {
		nb += this.current_str()
		this.col++
		this.next()

		for (this.pos < this.ilen || this.peek() != -1) && this.current_is_digit() {
			nb += this.current_str()
			this.col++
			this.next()
		}
	}

	if !nb.contains('.') && this.current_is_dot() && this.peek_is_digit() {
		nb += this.current_str()
		this.col++
		this.next()

		for (this.pos < this.ilen || this.peek() != -1) && this.current_is_digit() {
			nb += this.current_str()
			this.col++
			this.next()
		}
	}

	return nb
}

pub fn (mut this Scanner) scan_identifier() string {
	mut id := ''

	if this.current_is_underscore() || this.current_is_letter()
		|| (this.current_is_dollar() && this.peek_is_letter()) {
		id += this.current_str()
		this.col++
		this.next()

		for (this.pos < this.ilen || this.peek() != -1)
			&& (this.current_is_digit() || this.current_is_underscore()
			|| this.current_is_letter()) {
			id += this.current_str()
			this.col++
			this.next()
		}
	}

	return id
}

pub fn (mut this Scanner) current_u8() u8 {
	return u8(this.current())
}

pub fn (mut this Scanner) current_str() string {
	return this.current_u8().ascii_str()
}

pub fn (mut this Scanner) current_is_space() bool {
	return this.current_u8().is_space()
}

pub fn (mut this Scanner) current_is_digit() bool {
	return this.current_u8().is_digit()
}

pub fn (mut this Scanner) current_is_letter() bool {
	return this.current_u8().is_letter()
}

pub fn (mut this Scanner) current_is_dollar() bool {
	return this.current_u8() == `$`
}

pub fn (mut this Scanner) current_is_new_line() bool {
	return this.current_u8() == `\n`
}

pub fn (mut this Scanner) current_is_dot() bool {
	return this.current_u8() == `.`
}

pub fn (mut this Scanner) current_is_underscore() bool {
	return this.current_u8() == `_`
}

pub fn (mut this Scanner) peek_str() string {
	return this.peek_u8().ascii_str()
}

pub fn (mut this Scanner) peek_is_space() bool {
	return this.peek_u8().is_space()
}

pub fn (mut this Scanner) peek_is_digit() bool {
	return this.peek_u8().is_digit()
}

pub fn (mut this Scanner) peek_is_letter() bool {
	return this.peek_u8().is_letter()
}

pub fn (mut this Scanner) peek_is_dollar() bool {
	return this.peek_u8() == `$`
}

pub fn (mut this Scanner) peek_is_new_line() bool {
	return this.peek_u8() == `\n`
}

pub fn (mut this Scanner) position() Position {
	return this.position_n(0)
}

pub fn (mut this Scanner) position_n(n int) Position {
	return Position.new(
		file:   this.file
		offset: this.pos
		line:   this.line
		column: this.col - n
	)
}

pub fn (mut this Scanner) token(type TokenType, value string) Token {
	return new_token(type, value, this.position_n(value.len))
}

pub fn (mut this Scanner) keyword(keyword TokenType) Token {
	return new_keyword(keyword, this.position_n(token_to_str(keyword).len))
}

pub fn (mut this Scanner) token_as() Token {
	return this.keyword(.as)
}

pub fn (mut this Scanner) token_assert() Token {
	return this.keyword(.assert)
}

pub fn (mut this Scanner) token_await() Token {
	return this.keyword(.await)
}

pub fn (mut this Scanner) token_break() Token {
	return this.keyword(.break)
}

pub fn (mut this Scanner) token_case() Token {
	return this.keyword(.case)
}

pub fn (mut this Scanner) token_continue() Token {
	return this.keyword(.continue)
}

pub fn (mut this Scanner) token_debug() Token {
	return this.keyword(.debug)
}

pub fn (mut this Scanner) token_do() Token {
	return this.keyword(.do)
}

pub fn (mut this Scanner) token_dump() Token {
	return this.keyword(.dump)
}

pub fn (mut this Scanner) token_else() Token {
	return this.keyword(.else)
}

pub fn (mut this Scanner) token_emit() Token {
	return this.keyword(.emit)
}

pub fn (mut this Scanner) token_ensure() Token {
	return this.keyword(.ensure)
}

pub fn (mut this Scanner) token_exit() Token {
	return this.keyword(.exit)
}

pub fn (mut this Scanner) token_false() Token {
	return this.keyword(.false)
}

pub fn (mut this Scanner) token_for() Token {
	return this.keyword(.for)
}

pub fn (mut this Scanner) token_if() Token {
	return this.keyword(.if)
}

pub fn (mut this Scanner) token_in() Token {
	return this.keyword(.in)
}

pub fn (mut this Scanner) token_is() Token {
	return this.keyword(.is)
}

pub fn (mut this Scanner) token_let() Token {
	return this.keyword(.let)
}

pub fn (mut this Scanner) token_nil() Token {
	return this.keyword(.nil)
}

pub fn (mut this Scanner) token_on() Token {
	return this.keyword(.on)
}

pub fn (mut this Scanner) token_print() Token {
	return this.keyword(.print)
}

pub fn (mut this Scanner) token_public() Token {
	return this.keyword(.public)
}

pub fn (mut this Scanner) token_return() Token {
	return this.keyword(.return)
}

pub fn (mut this Scanner) token_scan() Token {
	return this.keyword(.scan)
}

pub fn (mut this Scanner) token_spawn() Token {
	return this.keyword(.spawn)
}

pub fn (mut this Scanner) token_static() Token {
	return this.keyword(.static)
}

pub fn (mut this Scanner) token_true() Token {
	return this.keyword(.true)
}

pub fn (mut this Scanner) token_type() Token {
	return this.keyword(.type)
}

pub fn (mut this Scanner) token_unset() Token {
	return this.keyword(.unset)
}

pub fn (mut this Scanner) token_use() Token {
	return this.keyword(.use)
}

pub fn (mut this Scanner) token_amp() Token {
	return this.token(.amp, '&')
}

pub fn (mut this Scanner) token_and() Token {
	return this.token(.and, '&&')
}

pub fn (mut this Scanner) token_and_assign() Token {
	return this.token(.and_assign, '&=')
}

pub fn (mut this Scanner) token_arrow() Token {
	return this.token(.arrow, '<-')
}

pub fn (mut this Scanner) token_assign() Token {
	return this.token(.assign, '=')
}

pub fn (mut this Scanner) token_at() Token {
	return this.token(.at, '@')
}

pub fn (mut this Scanner) token_bit_not() Token {
	return this.token(.bit_not, '~')
}

pub fn (mut this Scanner) token_bool(val string) Token {
	return this.token(.bool, val)
}

pub fn (mut this Scanner) token_boolean_and_assign() Token {
	return this.token(.boolean_and_assign, '&&=')
}

pub fn (mut this Scanner) token_boolean_or_assign() Token {
	return this.token(.boolean_or_assign, '||=')
}

pub fn (mut this Scanner) token_colon() Token {
	return this.token(.colon, ':')
}

pub fn (mut this Scanner) token_comma() Token {
	return this.token(.comma, ',')
}

pub fn (mut this Scanner) token_comment(val string) Token {
	return this.token(.comment, val)
}

pub fn (mut this Scanner) token_dec() Token {
	return this.token(.dec, '--')
}

pub fn (mut this Scanner) token_decl_assign() Token {
	return this.token(.decl_assign, ':=')
}

pub fn (mut this Scanner) token_div() Token {
	return this.token(.div, '/')
}

pub fn (mut this Scanner) token_div_assign() Token {
	return this.token(.div_assign, '/=')
}

pub fn (mut this Scanner) token_dollar() Token {
	return this.token(.dollar, '\$')
}

pub fn (mut this Scanner) token_dot() Token {
	return this.token(.dot, '.')
}

pub fn (mut this Scanner) token_dotdot() Token {
	return this.token(.dotdot, '..')
}

pub fn (mut this Scanner) token_ellipsis() Token {
	return this.token(.ellipsis, '...')
}

pub fn (mut this Scanner) token_eof(val string) Token {
	return this.token(.eof, val)
}

pub fn (mut this Scanner) token_eq() Token {
	return this.token(.eq, '==')
}

pub fn (mut this Scanner) token_float(val string) Token {
	return this.token(.float, val)
}

pub fn (mut this Scanner) token_ge() Token {
	return this.token(.ge, '>=')
}

pub fn (mut this Scanner) token_gt() Token {
	return this.token(.gt, '>')
}

pub fn (mut this Scanner) token_hash() Token {
	return this.token(.hash, '#')
}

pub fn (mut this Scanner) token_inc() Token {
	return this.token(.inc, '++')
}

pub fn (mut this Scanner) token_int(val string) Token {
	return this.token(.int, val)
}

pub fn (mut this Scanner) token_ldoc() Token {
	return this.token(.ldoc, '<!')
}

pub fn (mut this Scanner) token_lcbr() Token {
	return this.token(.lcbr, '{')
}

pub fn (mut this Scanner) token_le() Token {
	return this.token(.le, '<=')
}

pub fn (mut this Scanner) token_left_shift() Token {
	return this.token(.left_shift, '<<')
}

pub fn (mut this Scanner) token_left_shift_assign() Token {
	return this.token(.left_shift_assign, '>>=')
}

pub fn (mut this Scanner) token_logical_or() Token {
	return this.token(.logical_or, '||')
}

pub fn (mut this Scanner) token_lpar() Token {
	return this.token(.lpar, '(')
}

pub fn (mut this Scanner) token_lsbr() Token {
	return this.token(.lsbr, '[')
}

pub fn (mut this Scanner) token_lt() Token {
	return this.token(.lt, '<')
}

pub fn (mut this Scanner) token_ltag() Token {
	return this.token(.ltag, '<?')
}

pub fn (mut this Scanner) token_minus() Token {
	return this.token(.minus, '-')
}

pub fn (mut this Scanner) token_minus_assign() Token {
	return this.token(.minus_assign, '-=')
}

pub fn (mut this Scanner) token_mod() Token {
	return this.token(.mod, '%')
}

pub fn (mut this Scanner) token_mod_assign() Token {
	return this.token(.mod_assign, '%=')
}

pub fn (mut this Scanner) token_mul() Token {
	return this.token(.mul, '*')
}

pub fn (mut this Scanner) token_mul_assign() Token {
	return this.token(.mul_assign, '*=')
}

pub fn (mut this Scanner) token_name(val string) Token {
	return this.token(.name, val)
}

pub fn (mut this Scanner) token_ne() Token {
	return this.token(.ne, '!=')
}

pub fn (mut this Scanner) token_nl() Token {
	return this.token(.nl, '\n')
}

pub fn (mut this Scanner) token_not() Token {
	return this.token(.not, '!')
}

pub fn (mut this Scanner) token_not_in() Token {
	return this.token(.not_in, '!in')
}

pub fn (mut this Scanner) token_not_is() Token {
	return this.token(.not_is, '!is')
}

pub fn (mut this Scanner) token_number(val string) Token {
	return this.token(.number, val)
}

pub fn (mut this Scanner) token_or_assign() Token {
	return this.token(.or_assign, '|=')
}

pub fn (mut this Scanner) token_pipe() Token {
	return this.token(.pipe, '|')
}

pub fn (mut this Scanner) token_plus() Token {
	return this.token(.plus, '+')
}

pub fn (mut this Scanner) token_plus_assign() Token {
	return this.token(.plus_assign, '+=')
}

pub fn (mut this Scanner) token_power() Token {
	return this.token(.power, '**')
}

pub fn (mut this Scanner) token_question() Token {
	return this.token(.question, '?')
}

pub fn (mut this Scanner) token_rcbr() Token {
	return this.token(.rcbr, '}')
}

pub fn (mut this Scanner) token_rdoc() Token {
	return this.token(.rdoc, '!>')
}

pub fn (mut this Scanner) token_right_shift() Token {
	return this.token(.right_shift, '>>')
}

pub fn (mut this Scanner) token_right_shift_assign() Token {
	return this.token(.right_shift_assign, '<<=')
}

pub fn (mut this Scanner) token_rpar() Token {
	return this.token(.rpar, ')')
}

pub fn (mut this Scanner) token_rsbr() Token {
	return this.token(.rsbr, ']')
}

pub fn (mut this Scanner) token_rtag() Token {
	return this.token(.rtag, '?>')
}

pub fn (mut this Scanner) token_semicolon() Token {
	return this.token(.semicolon, ';')
}

pub fn (mut this Scanner) token_backticks(val string) Token {
	return this.token(.backticks, val)
}

pub fn (mut this Scanner) token_string(val string) Token {
	return this.token(.string, val)
}

pub fn (mut this Scanner) token_unknown(val string) Token {
	return this.token(.unknown, val)
}

pub fn (mut this Scanner) token_unsigned_right_shift() Token {
	return this.token(.unsigned_right_shift, '>>>')
}

pub fn (mut this Scanner) token_unsigned_right_shift_assign() Token {
	return this.token(.unsigned_right_shift_assign, '>>>=')
}

pub fn (mut this Scanner) token_whitespace(val string) Token {
	return this.token(.whitespace, val)
}

pub fn (mut this Scanner) token_xor() Token {
	return this.token(.xor, '^')
}

pub fn (mut this Scanner) token_xor_assign() Token {
	return this.token(.xor_assign, '^=')
}
