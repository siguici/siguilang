pub struct SkeError {
	Error
	file   string
	line   string
	column int
	offset int
}

pub struct LexerError {
	SkeError
}

pub struct ParserError {
	SkeError
}

pub struct RuntimeError {
	SkeError
}
