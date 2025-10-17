module ske

pub struct Position {
	file string
mut:
	offset int
	line   int
	column int
}

@[params]
pub struct PositionOptions {
	file   string
	offset int
	line   int
	column int
}

pub fn Position.new(options PositionOptions) Position {
	return Position{options.file, options.offset, options.line, options.column}
}

pub fn new_position(options PositionOptions) Position {
	return Position.new(options)
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
