module main

fn test_nil() {
	assert is_nil(unsafe { nil }) == true
	assert is_nil('') == false
	assert is_nil(true) == false
	assert is_nil(false) == false
	assert is_nil(0) == false
	assert is_nil(1) == false
	assert is_nil(1.0) == false
	assert is_nil(-7.5) == false
	assert is_nil('0') == false
	assert is_nil('1') == false
	assert is_nil('0.0') == false
	assert is_nil('1.0') == false
	assert is_nil('true') == false
	assert is_nil('false') == false
	assert is_nil('foo') == false
	assert is_nil('') == false
}

fn test_bool_value() {
	assert is_bool(unsafe { nil }) == false
	assert is_bool(true) == true
	assert is_bool(false) == true
	assert is_bool(0) == false
	assert is_bool(1) == false
	assert is_bool(1.0) == false
	assert is_bool(-7.5) == false
	assert is_float('0') == false
	assert is_float('1') == false
	assert is_float('0.0') == false
	assert is_float('1.0') == false
	assert is_float('true') == false
	assert is_float('false') == false
	assert is_bool('foo') == false
	assert is_bool('') == false
}

fn test_int_value() {
	assert is_int(unsafe { nil }) == false
	assert is_int(true) == false
	assert is_int(false) == false
	assert is_int(0) == true
	assert is_int(1) == true
	assert is_int(-75) == true
	assert is_int(1.0) == false
	assert is_int(-7.5) == false
	assert is_int('0') == false
	assert is_int('1') == false
	assert is_int('0.0') == false
	assert is_int('1.0') == false
	assert is_int('true') == false
	assert is_int('false') == false
	assert is_int('foo') == false
	assert is_int('') == false
}

fn test_float_value() {
	assert is_float(unsafe { nil }) == false
	assert is_float(true) == false
	assert is_float(false) == false
	assert is_float(0) == false
	assert is_float(1) == false
	assert is_float(-0.0) == true
	assert is_float(4.5) == true
	assert is_float(-75) == false
	assert is_float(1.0) == true
	assert is_float(-7.5) == true
	assert is_str('0') == true
	assert is_str('1') == true
	assert is_str('0.0') == true
	assert is_str('1.0') == true
	assert is_str('true') == true
	assert is_str('false') == true
	assert is_float('foo') == false
	assert is_float('') == false
}

fn test_num_value() {
	assert is_num(unsafe { nil }) == false
	assert is_num(true) == false
	assert is_num(false) == false
	assert is_num(0) == true
	assert is_num(-0.0) == true
	assert is_num(1) == true
	assert is_num(-75) == true
	assert is_num(1.0) == true
	assert is_num(-7.5) == true
	assert is_num(4.5) == true
	assert is_str('0') == true
	assert is_str('1') == true
	assert is_str('0.0') == true
	assert is_str('1.0') == true
	assert is_str('true') == true
	assert is_str('false') == true
	assert is_num('foo') == false
	assert is_num('') == false
}

fn test_str_value() {
	assert is_str(unsafe { nil }) == false
	assert is_str(true) == false
	assert is_str(false) == false
	assert is_str(0) == false
	assert is_str(-0.0) == false
	assert is_str(1) == false
	assert is_str(-75) == false
	assert is_str(1.0) == false
	assert is_str(-7.5) == false
	assert is_str(4.5) == false
	assert is_str('0') == true
	assert is_str('1') == true
	assert is_str('0.0') == true
	assert is_str('1.0') == true
	assert is_str('true') == true
	assert is_str('false') == true
	assert is_str('foo') == true
	assert is_str('') == true
}
