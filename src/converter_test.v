module main

fn test_bool_conversion() {
	assert to_bool('') == false
	assert to_bool('0') == false
	assert to_bool(0) == false
	assert to_bool(0.0) == false
	assert to_bool(false) == false

	assert to_bool('1') == true
	assert to_bool('0.0') == true
	assert to_bool('0.7') == true
	assert to_bool('-0.7') == true
	assert to_bool(1) == true
	assert to_bool(22) == true
	assert to_bool(-5) == true
	assert to_bool(true) == true
	assert to_bool('hello') == true
	assert to_bool('none') == true
	assert to_bool('false') == true
}

fn test_int_conversion() {
	assert to_int('') == 0
	assert to_int('blue') == 0
	assert to_int(0) == 0
	assert to_int(true) == 1

	assert to_int(false) == 0
	assert to_int('1') == 1
	assert to_int('22') == 22
	assert to_int('15.5') == 15
}

fn test_float_conversion() {
	assert to_float('') == 0.0
	assert to_float('blue') == 0.0
	assert to_float(0) == 0.0
	assert to_float(true) == 1.0

	assert to_float(false) == 0.0
	assert to_float('1') == 1.0
	assert to_float('22') == 22.0
	assert to_float('15.5') == 15.5
}

fn test_string_conversion() {
	assert to_str(true) == '1'
	assert to_str(false) == '0'
	assert to_str(1) == '1'
	assert to_str(-55) == '-55'
	assert to_str(0) == '0'
	assert to_str(22) == '22'
}
