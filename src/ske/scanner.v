module ske

import strings.textscanner

@[noinit]
pub struct Scanner {
	textscanner.TextScanner
pub mut:
	file string
	line int = 1
	col  int = 1
}

@[params]
pub struct ScannerOptions {
	input string
	file  string
	line  int = 1
	col   int = 1
}

pub fn Scanner.new(o ScannerOptions) Scanner {
	return Scanner{
		TextScanner: textscanner.new(o.input)
		line:        o.line
		file:        o.file
		col:         o.col
	}
}

pub fn (mut this Scanner) scan() Token {
	c := this.current_u8()
	match c {
		`<` {
			this.col++
			match this.peek_u8() {
				`>` {
					this.col++
					this.next()
					return this.tokenize_ne()
				}
				`<` {
					this.col++
					this.next()
					match this.peek_u8() {
						`=` {
							this.col++
							this.next()
							return this.tokenize_right_shift_assign()
						}
						else {
							return this.tokenize_left_shift()
						}
					}
				}
				`-` {
					this.col++
					this.next()
					return this.tokenize_arrow()
				}
				`?` {
					this.col++
					this.next()
					return this.tokenize_ltag()
				}
				`!` {
					this.col++
					this.next()
					return this.tokenize_ldoc()
				}
				`=` {
					this.col++
					this.next()
					return this.tokenize_le()
				}
				else {
					return this.tokenize_lt()
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
								this.tokenize_unsigned_right_shift_assign()
							} else {
								this.tokenize_unsigned_right_shift()
							}
						}
						`=` {
							this.col++
							this.next()
							return this.tokenize_left_shift_assign()
						}
						else {
							return this.tokenize_right_shift()
						}
					}
				}
				`=` {
					this.col++
					this.next()
					return this.tokenize_ge()
				}
				else {
					return this.tokenize_gt()
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
						this.tokenize_boolean_or_assign()
					} else {
						this.tokenize_or_assign()
					}
				} else {
					return this.tokenize_logical_or()
				}
			} else {
				return this.tokenize_pipe()
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
					this.tokenize_ellipsis()
				} else {
					this.tokenize_dotdot()
				}
			} else {
				return this.tokenize_dot()
			}
		}
		`@`, `~`, `,`, `;`, `$`, `#`, `(`, `)`, `{`, `}`, `[`, `]` {
			this.col++
			return match c {
				`@` {
					this.tokenize_at()
				}
				`~` {
					this.tokenize_bit_not()
				}
				`,` {
					this.tokenize_comma()
				}
				`$` {
					mut t := this.tokenize_dollar()
					if this.peek_is_letter() {
						id := this.scan_identifier()
						if id.len >= 1 {
							this.pos--
							t = this.tokenize_name(id)
						}
					}
					return t
				}
				`#` {
					this.tokenize_hash()
				}
				`(` {
					this.tokenize_lpar()
				}
				`)` {
					this.tokenize_rpar()
				}
				`{` {
					this.tokenize_lcbr()
				}
				`}` {
					this.tokenize_rcbr()
				}
				`[` {
					this.tokenize_lsbr()
				}
				`]` {
					this.tokenize_rsbr()
				}
				else {
					this.tokenize_semicolon()
				}
			}
		}
		`!` {
			this.col++
			if this.peek_u8() == `i` && this.peek_n_u8(2) in [`s`, `n`] {
				this.col += 2
				this.pos += 2
				return if this.current_u8() == `s` {
					this.tokenize_not_is()
				} else {
					this.tokenize_not_in()
				}
			}
			match this.peek_u8() {
				`=` {
					this.col++
					this.next()
					return this.tokenize_ne()
				}
				`>` {
					this.col++
					this.next()
					return this.tokenize_rdoc()
				}
				else {
					return this.tokenize_not()
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
						return this.tokenize_boolean_and_assign()
					}
					return this.tokenize_and()
				}
				`=` {
					this.col++
					this.next()
					return this.tokenize_and_assign()
				}
				else {
					return this.tokenize_amp()
				}
			}
		}
		`?` {
			this.col++
			match this.peek_u8() {
				`>` {
					this.col++
					this.next()
					return this.tokenize_rtag()
				}
				else {
					return this.tokenize_question()
				}
			}
		}
		`=` {
			this.col++
			if this.peek_u8() == `=` {
				this.col++
				this.next()
				return this.tokenize_eq()
			}
			return this.tokenize_assign()
		}
		`:` {
			this.col++
			if this.peek_u8() == `=` {
				this.col++
				this.next()
				return this.tokenize_decl_assign()
			}
			return this.tokenize_colon()
		}
		`^` {
			this.col++
			if this.peek_u8() == `=` {
				this.col++
				this.next()
				return this.tokenize_xor_assign()
			}
			return this.tokenize_xor()
		}
		`*` {
			this.col++
			match this.peek_u8() {
				`*` {
					this.col++
					this.next()
					return this.tokenize_power()
				}
				`=` {
					this.col++
					this.next()
					return this.tokenize_mul_assign()
				}
				else {
					return this.tokenize_mul()
				}
			}
		}
		`/` {
			this.col++
			if this.peek_u8() == `=` {
				this.col++
				this.next()
				return this.tokenize_div_assign()
			}
			return this.tokenize_div()
		}
		`%` {
			this.col++
			if this.peek_u8() == `=` {
				this.col++
				this.next()
				return this.tokenize_mod_assign()
			}
			return this.tokenize_mod()
		}
		`+` {
			this.col++
			match this.peek_u8() {
				`+` {
					this.col++
					this.next()
					return this.tokenize_inc()
				}
				`=` {
					this.col++
					this.next()
					return this.tokenize_plus_assign()
				}
				else {
					return this.tokenize_plus()
				}
			}
		}
		`-` {
			this.col++
			match this.peek_u8() {
				`-` {
					this.col++
					this.next()
					return this.tokenize_dec()
				}
				`=` {
					this.col++
					this.next()
					return this.tokenize_minus_assign()
				}
				else {
					return this.tokenize_minus()
				}
			}
		}
		`'`, `"`, `\`` {
			ss := this.scan_string(this.current())
			if ss.len >= 1 {
				return if c == `\`` {
					this.tokenize_backticks(ss)
				} else if c == `'` {
					this.tokenize_char(ss)
				} else {
					this.tokenize_string(ss)
				}
			}
		}
		else {
			nl := this.scan_newline()
			if nl.len >= 1 {
				this.pos--
				return this.tokenize_nl()
			}

			sp := this.scan_whitespace()
			if sp.len >= 1 {
				this.pos--
				return this.tokenize_whitespace(sp)
			}

			nb := this.scan_number()
			if nb.len >= 1 {
				this.pos--
				return this.tokenize_number(nb)
			}

			id := this.scan_identifier()
			if id.len >= 1 {
				this.pos--
				return match id {
					'print' {
						this.tokenize_print()
					}
					'scan' {
						this.tokenize_scan()
					}
					'if' {
						this.tokenize_if()
					}
					'else' {
						this.tokenize_else()
					}
					else {
						this.tokenize_name(id)
					}
				}
			}
		}
	}

	return this.tokenize_unknown(c.ascii_str())
}

pub fn (mut this Scanner) scan_string(delimiter int) string {
	this.col++
	this.next()
	mut v := ''
	mut end := false

	for this.pos < this.ilen {
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
					panic('Cannot escape ${this.peek_u8().ascii_str()} in ${this.file} at ${this.line}:${this.col}')
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

	if !end && this.peek() != -1 {
		panic('End of string ${u8(delimiter).ascii_str()} expected in ${this.file} at ${this.line}:${this.col}')
	}

	return v
}

pub fn (mut this Scanner) scan_newline() string {
	mut w := ''

	for this.pos < this.ilen && this.current_is_new_line() {
		this.line++
		this.col = 1
		w += this.current_str()
		this.next()
	}

	return w
}

pub fn (mut this Scanner) scan_whitespace() string {
	mut w := ''

	for this.pos < this.ilen && this.current_is_space() && !this.current_is_new_line() {
		w += this.current_str()
		this.col++
		this.next()
	}

	return w
}

pub fn (mut this Scanner) scan_number() string {
	return this.scan_integer() + this.scan_decimal()
}

pub fn (mut this Scanner) scan_integer() string {
	mut i := ''

	for this.pos < this.ilen && this.current_is_digit() {
		i += this.current_str()
		this.col++
		this.next()
	}

	return i
}

pub fn (mut this Scanner) scan_decimal() string {
	mut d := ''

	if this.current_is_dot() && this.peek_is_digit() {
		d += this.current_str()
		this.col++
		for this.pos < this.ilen && this.peek_is_digit() {
			d += this.peek_str()
			this.col++
			this.next()
		}
	}

	return d
}

pub fn (mut this Scanner) scan_identifier() string {
	mut id := ''

	for this.pos < this.ilen && (this.current_is_underscore() || this.current_is_dollar()
		|| this.current_is_letter()) {
		id += this.current_str()
		this.col++
		this.next()
	}

	if this.current_is_digit() {
		for this.pos < this.ilen && (this.current_is_digit() || this.current_is_underscore()
			|| this.current_is_letter()) {
			this.col++
			id += this.current_str()
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
	return new_position(
		file:   this.file
		offset: this.pos
		line:   this.line
		column: this.col - n
	)
}

pub fn (mut this Scanner) tokenize(type TokenType, value string) Token {
	return new_token(type, value, this.position_n(value.len))
}

pub fn (mut this Scanner) tokenize_keyword(keyword TokenType) Token {
	return new_keyword(keyword, this.position_n(token_to_str(keyword).len))
}

pub fn (mut this Scanner) tokenize_as() Token {
	return this.tokenize_keyword(.as)
}

pub fn (mut this Scanner) tokenize_assert() Token {
	return this.tokenize_keyword(.assert)
}

pub fn (mut this Scanner) tokenize_await() Token {
	return this.tokenize_keyword(.await)
}

pub fn (mut this Scanner) tokenize_break() Token {
	return this.tokenize_keyword(.break)
}

pub fn (mut this Scanner) tokenize_case() Token {
	return this.tokenize_keyword(.case)
}

pub fn (mut this Scanner) tokenize_continue() Token {
	return this.tokenize_keyword(.continue)
}

pub fn (mut this Scanner) tokenize_debug() Token {
	return this.tokenize_keyword(.debug)
}

pub fn (mut this Scanner) tokenize_do() Token {
	return this.tokenize_keyword(.do)
}

pub fn (mut this Scanner) tokenize_dump() Token {
	return this.tokenize_keyword(.dump)
}

pub fn (mut this Scanner) tokenize_else() Token {
	return this.tokenize_keyword(.else)
}

pub fn (mut this Scanner) tokenize_emit() Token {
	return this.tokenize_keyword(.emit)
}

pub fn (mut this Scanner) tokenize_ensure() Token {
	return this.tokenize_keyword(.ensure)
}

pub fn (mut this Scanner) tokenize_exit() Token {
	return this.tokenize_keyword(.exit)
}

pub fn (mut this Scanner) tokenize_false() Token {
	return this.tokenize_keyword(.false)
}

pub fn (mut this Scanner) tokenize_for() Token {
	return this.tokenize_keyword(.for)
}

pub fn (mut this Scanner) tokenize_if() Token {
	return this.tokenize_keyword(.if)
}

pub fn (mut this Scanner) tokenize_in() Token {
	return this.tokenize_keyword(.in)
}

pub fn (mut this Scanner) tokenize_is() Token {
	return this.tokenize_keyword(.is)
}

pub fn (mut this Scanner) tokenize_let() Token {
	return this.tokenize_keyword(.let)
}

pub fn (mut this Scanner) tokenize_nil() Token {
	return this.tokenize_keyword(.nil)
}

pub fn (mut this Scanner) tokenize_on() Token {
	return this.tokenize_keyword(.on)
}

pub fn (mut this Scanner) tokenize_print() Token {
	return this.tokenize_keyword(.print)
}

pub fn (mut this Scanner) tokenize_public() Token {
	return this.tokenize_keyword(.public)
}

pub fn (mut this Scanner) tokenize_return() Token {
	return this.tokenize_keyword(.return)
}

pub fn (mut this Scanner) tokenize_scan() Token {
	return this.tokenize_keyword(.scan)
}

pub fn (mut this Scanner) tokenize_spawn() Token {
	return this.tokenize_keyword(.spawn)
}

pub fn (mut this Scanner) tokenize_static() Token {
	return this.tokenize_keyword(.static)
}

pub fn (mut this Scanner) tokenize_true() Token {
	return this.tokenize_keyword(.true)
}

pub fn (mut this Scanner) tokenize_type() Token {
	return this.tokenize_keyword(.type)
}

pub fn (mut this Scanner) tokenize_unset() Token {
	return this.tokenize_keyword(.unset)
}

pub fn (mut this Scanner) tokenize_use() Token {
	return this.tokenize_keyword(.use)
}

pub fn (mut this Scanner) tokenize_amp() Token {
	return this.tokenize(.amp, '&')
}

pub fn (mut this Scanner) tokenize_and() Token {
	return this.tokenize(.and, '&&')
}

pub fn (mut this Scanner) tokenize_and_assign() Token {
	return this.tokenize(.and_assign, '&=')
}

pub fn (mut this Scanner) tokenize_arrow() Token {
	return this.tokenize(.arrow, '<-')
}

pub fn (mut this Scanner) tokenize_assign() Token {
	return this.tokenize(.assign, '=')
}

pub fn (mut this Scanner) tokenize_at() Token {
	return this.tokenize(.at, '@')
}

pub fn (mut this Scanner) tokenize_bit_not() Token {
	return this.tokenize(.bit_not, '~')
}

pub fn (mut this Scanner) tokenize_boolean_and_assign() Token {
	return this.tokenize(.boolean_and_assign, '&&=')
}

pub fn (mut this Scanner) tokenize_boolean_or_assign() Token {
	return this.tokenize(.boolean_or_assign, '||=')
}

pub fn (mut this Scanner) tokenize_char(val string) Token {
	return this.tokenize(.char, val)
}

pub fn (mut this Scanner) tokenize_colon() Token {
	return this.tokenize(.colon, ':')
}

pub fn (mut this Scanner) tokenize_comma() Token {
	return this.tokenize(.comma, ',')
}

pub fn (mut this Scanner) tokenize_comment(val string) Token {
	return this.tokenize(.comment, val)
}

pub fn (mut this Scanner) tokenize_dec() Token {
	return this.tokenize(.dec, '--')
}

pub fn (mut this Scanner) tokenize_decl_assign() Token {
	return this.tokenize(.decl_assign, ':=')
}

pub fn (mut this Scanner) tokenize_div() Token {
	return this.tokenize(.div, '/')
}

pub fn (mut this Scanner) tokenize_div_assign() Token {
	return this.tokenize(.div_assign, '/=')
}

pub fn (mut this Scanner) tokenize_dollar() Token {
	return this.tokenize(.dollar, '\$')
}

pub fn (mut this Scanner) tokenize_dot() Token {
	return this.tokenize(.dot, '.')
}

pub fn (mut this Scanner) tokenize_dotdot() Token {
	return this.tokenize(.dotdot, '..')
}

pub fn (mut this Scanner) tokenize_ellipsis() Token {
	return this.tokenize(.ellipsis, '...')
}

pub fn (mut this Scanner) tokenize_eof(val string) Token {
	return this.tokenize(.eof, val)
}

pub fn (mut this Scanner) tokenize_eq() Token {
	return this.tokenize(.eq, '==')
}

pub fn (mut this Scanner) tokenize_float(val string) Token {
	return this.tokenize(.float, val)
}

pub fn (mut this Scanner) tokenize_ge() Token {
	return this.tokenize(.ge, '>=')
}

pub fn (mut this Scanner) tokenize_gt() Token {
	return this.tokenize(.gt, '>')
}

pub fn (mut this Scanner) tokenize_hash() Token {
	return this.tokenize(.hash, '#')
}

pub fn (mut this Scanner) tokenize_inc() Token {
	return this.tokenize(.inc, '++')
}

pub fn (mut this Scanner) tokenize_int(val string) Token {
	return this.tokenize(.int, val)
}

pub fn (mut this Scanner) tokenize_ldoc() Token {
	return this.tokenize(.ldoc, '<!')
}

pub fn (mut this Scanner) tokenize_lcbr() Token {
	return this.tokenize(.lcbr, '{')
}

pub fn (mut this Scanner) tokenize_le() Token {
	return this.tokenize(.le, '<=')
}

pub fn (mut this Scanner) tokenize_left_shift() Token {
	return this.tokenize(.left_shift, '<<')
}

pub fn (mut this Scanner) tokenize_left_shift_assign() Token {
	return this.tokenize(.left_shift_assign, '>>=')
}

pub fn (mut this Scanner) tokenize_logical_or() Token {
	return this.tokenize(.logical_or, '||')
}

pub fn (mut this Scanner) tokenize_lpar() Token {
	return this.tokenize(.lpar, '(')
}

pub fn (mut this Scanner) tokenize_lsbr() Token {
	return this.tokenize(.lsbr, '[')
}

pub fn (mut this Scanner) tokenize_lt() Token {
	return this.tokenize(.lt, '<')
}

pub fn (mut this Scanner) tokenize_ltag() Token {
	return this.tokenize(.ltag, '<?')
}

pub fn (mut this Scanner) tokenize_minus() Token {
	return this.tokenize(.minus, '-')
}

pub fn (mut this Scanner) tokenize_minus_assign() Token {
	return this.tokenize(.minus_assign, '-=')
}

pub fn (mut this Scanner) tokenize_mod() Token {
	return this.tokenize(.mod, '%')
}

pub fn (mut this Scanner) tokenize_mod_assign() Token {
	return this.tokenize(.mod_assign, '%=')
}

pub fn (mut this Scanner) tokenize_mul() Token {
	return this.tokenize(.mul, '*')
}

pub fn (mut this Scanner) tokenize_mul_assign() Token {
	return this.tokenize(.mul_assign, '*=')
}

pub fn (mut this Scanner) tokenize_name(val string) Token {
	return this.tokenize(.name, val)
}

pub fn (mut this Scanner) tokenize_ne() Token {
	return this.tokenize(.ne, '!=')
}

pub fn (mut this Scanner) tokenize_nl() Token {
	return this.tokenize(.nl, '\n')
}

pub fn (mut this Scanner) tokenize_not() Token {
	return this.tokenize(.not, '!')
}

pub fn (mut this Scanner) tokenize_not_in() Token {
	return this.tokenize(.not_in, '!in')
}

pub fn (mut this Scanner) tokenize_not_is() Token {
	return this.tokenize(.not_is, '!is')
}

pub fn (mut this Scanner) tokenize_number(val string) Token {
	return this.tokenize(.number, val)
}

pub fn (mut this Scanner) tokenize_or_assign() Token {
	return this.tokenize(.or_assign, '|=')
}

pub fn (mut this Scanner) tokenize_pipe() Token {
	return this.tokenize(.pipe, '|')
}

pub fn (mut this Scanner) tokenize_plus() Token {
	return this.tokenize(.plus, '+')
}

pub fn (mut this Scanner) tokenize_plus_assign() Token {
	return this.tokenize(.plus_assign, '+=')
}

pub fn (mut this Scanner) tokenize_power() Token {
	return this.tokenize(.power, '**')
}

pub fn (mut this Scanner) tokenize_question() Token {
	return this.tokenize(.question, '?')
}

pub fn (mut this Scanner) tokenize_rcbr() Token {
	return this.tokenize(.rcbr, '}')
}

pub fn (mut this Scanner) tokenize_rdoc() Token {
	return this.tokenize(.rdoc, '!>')
}

pub fn (mut this Scanner) tokenize_right_shift() Token {
	return this.tokenize(.right_shift, '>>')
}

pub fn (mut this Scanner) tokenize_right_shift_assign() Token {
	return this.tokenize(.right_shift_assign, '<<=')
}

pub fn (mut this Scanner) tokenize_rpar() Token {
	return this.tokenize(.rpar, ')')
}

pub fn (mut this Scanner) tokenize_rsbr() Token {
	return this.tokenize(.rsbr, ']')
}

pub fn (mut this Scanner) tokenize_rtag() Token {
	return this.tokenize(.rtag, '?>')
}

pub fn (mut this Scanner) tokenize_semicolon() Token {
	return this.tokenize(.semicolon, ';')
}

pub fn (mut this Scanner) tokenize_backticks(val string) Token {
	return this.tokenize(.backticks, val)
}

pub fn (mut this Scanner) tokenize_string(val string) Token {
	return this.tokenize(.string, val)
}

pub fn (mut this Scanner) tokenize_unknown(val string) Token {
	return this.tokenize(.unknown, val)
}

pub fn (mut this Scanner) tokenize_unsigned_right_shift() Token {
	return this.tokenize(.unsigned_right_shift, '>>>')
}

pub fn (mut this Scanner) tokenize_unsigned_right_shift_assign() Token {
	return this.tokenize(.unsigned_right_shift_assign, '>>>=')
}

pub fn (mut this Scanner) tokenize_whitespace(val string) Token {
	return this.tokenize(.whitespace, val)
}

pub fn (mut this Scanner) tokenize_xor() Token {
	return this.tokenize(.xor, '^')
}

pub fn (mut this Scanner) tokenize_xor_assign() Token {
	return this.tokenize(.xor_assign, '^=')
}
