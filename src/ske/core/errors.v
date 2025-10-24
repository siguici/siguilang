module core

@[params]
pub struct ErrorOptions {
pub:
	pos  Position
	span Span
}

struct SkeError {
	Error
	type string @[required]
	msg  string
	span Span
	pos  Position
}

fn ske_error(type string, msg string, opts ErrorOptions) SkeError {
	return SkeError{
		type: type
		msg:  msg
		pos:  opts.pos
		span: opts.span
	}
}

pub fn scanner_error(msg string, pos Position) SkeError {
	return ske_error('scanner', msg, pos: pos)
}

pub fn parser_error(msg string, span Span) SkeError {
	return ske_error('parser', msg, span: span)
}

pub fn runtime_error(msg string, opts ErrorOptions) SkeError {
	return ske_error('runtime', msg, opts)
}

pub fn (e SkeError) msg() string {
	mut msg := 'Ske ${e.type} error: ${e.msg}'
	mut span := e.span

	if span.is_empty() {
		mut p := e.pos
		if e.pos.file.len > 0 {
			msg += ' in ${e.pos.file}'
		}
		msg += ' on line ${p.line}:${p.column}'
	} else {
		mut start := span.start
		mut end := span.end
		if start.file.len > 0 {
			msg += ' in ${start.file}'
		}
		if end.is_empty() {
			msg += ' on line ${start.line}:${start.column}'
		} else {
			if end.line < start.line || (end.line == start.line && end.column < start.column) {
				start, end = end, start
			}
			msg += ' from line ${start.line}:${start.column} to ${end.line}:${end.column}'
		}
	}

	return msg
}
