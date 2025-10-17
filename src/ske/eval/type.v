module eval

pub type Type = BuiltinType | NamedType | UnionType | IntersectionType

pub enum BuiltinType {
	bool
	int
	float
	string
}

pub struct NamedType {
	name     string
	nullable bool
}

struct GroupedType {
mut:
	types    []Type
	nullable bool
}

pub struct UnionType {
	GroupedType
}

pub struct IntersectionType {
	GroupedType
}
