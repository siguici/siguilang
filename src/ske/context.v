module ske

struct Scope {
	parent &Scope = unsafe { nil }
mut:
	children []&Scope
}

@[unsafe]
pub fn (this &Scope) free() {
	if this == unsafe { nil } {
		return
	}
	unsafe {
		for child in this.children {
			child.free()
		}
		this.children.free()
	}
}

struct State {
	name string
mut:
	value Value
}

@[heap; minify]
struct Memory {
mut:
	store []&State
	scope &Scope = unsafe { nil }
}

pub fn (mut m Memory) store(name string, value Value) &Memory {
	m.store << &State{name, value}

	return m
}

@[unsafe]
pub fn (mut this Memory) free() {
	unsafe {
		for state in this.store {
			state.free()
		}
		this.store.free()
	}
}

pub fn (this Memory) find(name string) ?Value {
	for s in this.store {
		if s.name == name {
			return s.value
		}
	}

	return none
}

struct Context {
mut:
	mem Memory
}
