module core

pub struct Position {
pub:
	file string
pub mut:
	offset int
	line   int
	column int
}

@[params]
pub struct PositionOptions {
pub:
	file   string
	offset int
	line   int
	column int
}

pub fn Position.new(options PositionOptions) Position {
	return Position{options.file, options.offset, options.line, options.column}
}

pub fn (mut p Position) next_line() Position {
	p.offset++
	p.line++
	p.column = 0
	return p
}

pub fn (mut p Position) next_column() Position {
	p.offset++
	p.column++
	return p
}
