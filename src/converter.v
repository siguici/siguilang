module main

fn to_int(v Value) int {
	return match v {
		string {
			v.int()
		}
		int {
			v
		}
		f64 {
			int(v)
		}
		bool {
			return if v {
				1
			} else {
				0
			}
		}
	}
}

fn to_float(v Value) f64 {
	return match v {
		string {
			v.f64()
		}
		int {
			f64(v)
		}
		f64 {
			v
		}
		bool {
			return if v {
				1.0
			} else {
				0.0
			}
		}
	}
}

fn to_str(v Value) string {
	return match v {
		string {
			v
		}
		f64, int, bool {
			v.str()
		}
	}
}

@[inline]
fn to_bool(v Value) bool {
	return match v {
		string {
			v != '0' && v.len > 0
		}
		int {
			v != 0
		}
		f64 {
			v != 0.0
		}
		bool {
			v
		}
	}
}
