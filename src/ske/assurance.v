module ske

struct Assurance[T] {
	val T
}

pub fn ensure[T](val T) Assurance[T] {
	return Assurance[T]{val}
}

pub fn (this Assurance[T]) is_nil() Assurance[T] {
	if !is_nil(this.val) {
		panic('${this.val} is not nil')
	}
	return this
}

pub fn (this Assurance[T]) is_bool() Assurance[T] {
	if !is_bool(this.val) {
		panic('${this.val} is not bool')
	}
	return this
}

pub fn (this Assurance[bool]) is_true() Assurance[bool] {
	if !is_true(this.val) {
		panic('${this.val} is not true')
	}
	return this
}

pub fn (this Assurance[bool]) is_false() Assurance[bool] {
	if !is_false(this.val) {
		panic('${this.val} is not false')
	}
	return this
}
