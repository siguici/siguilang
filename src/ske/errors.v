module ske

struct SkeError {
	Error
	type string
	msg  string
	pos  Position
}

fn ske_error(type string, msg string, pos Position) SkeError {
	return SkeError{
		type: type
		msg:  msg
		pos:  pos
	}
}

pub fn scanner_error(msg string, pos Position) SkeError {
	return ske_error('scanner', msg, pos)
}

pub fn parser_error(msg string, pos Position) SkeError {
	return ske_error('parser', msg, pos)
}

pub fn runtime_error(msg string, pos Position) SkeError {
	return ske_error('runtime', msg, pos)
}

pub fn (e SkeError) msg() string {
	mut msg := e.msg
	if e.pos.file.len > 0 {
		msg += ' in ${e.pos.file}'
	}
	msg += ' on line ${e.pos.line} at column ${e.pos.column}'

	return 'Ske ${e.type} error: ${msg}'
}
