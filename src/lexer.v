@[params]
struct LexOptions {
	code string
	file string
}

pub fn lex(options LexOptions) []Token {
	mut l := new_lexer(input: options.code, file: options.file)

	return l.lex()
}

pub fn new_lexer(options LexerOptions) Lexer {
	return Lexer.new(options)
}

@[noinit]
pub struct Lexer {
	Scanner
pub:
	file string
pub mut:
	line int = 1
	col  int = 1
}

@[params]
pub struct LexerOptions {
	input string
	file  string
	line  int = 1
	col   int = 1
}

pub fn Lexer.new(o LexerOptions) Lexer {
	return Lexer{
		Scanner: Scanner.new(input: o.input, file: o.file, line: o.line, col: o.col)
	}
}

pub fn (mut this Lexer) lex() []Token {
	mut t := []Token{}

	for this.next() != -1 && this.pos != this.ilen {
		t << this.scan()
	}

	return t
}
