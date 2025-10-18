module eval

fn test_bool_conversion() {
	assert Value('').to_bool() == false
	assert Value('0').to_bool() == false
	assert Value(0).to_bool() == false
	assert Value(0.0).to_bool() == false
	assert Value(false).to_bool() == false

	assert Value('1').to_bool() == true
	assert Value('0.0').to_bool() == true
	assert Value('0.7').to_bool() == true
	assert Value('-0.7').to_bool() == true
	assert Value(1).to_bool() == true
	assert Value(22).to_bool() == true
	assert Value(-5).to_bool() == true
	assert Value(true).to_bool() == true
	assert Value('hello').to_bool() == true
	assert Value('none').to_bool() == true
	assert Value('false').to_bool() == true
}

fn test_int_conversion() {
	assert Value('').to_int() == 0
	assert Value('blue').to_int() == 0
	assert Value(0).to_int() == 0
	assert Value(true).to_int() == 1

	assert Value(false).to_int() == 0
	assert Value(true).to_int() == 1
	assert Value('22').to_int() == 22
	assert Value('15.5').to_int() == 15
}

fn test_float_conversion() {
	assert Value('').to_float() == 0.0
	assert Value('blue').to_float() == 0.0
	assert Value(0).to_float() == 0.0
	assert Value(true).to_float() == 1.0

	assert Value(false).to_float() == 0.0
	assert Value('1').to_float() == 1.0
	assert Value('22').to_float() == 22.0
	assert Value('15.5').to_float() == 15.5
}

fn test_string_conversion() {
	assert Value(true).to_str() == 'true'
	assert Value(false).to_str() == 'false'
	assert Value(1).to_str() == '1'
	assert Value(-55).to_str() == '-55'
	assert Value(0).to_str() == '0'
	assert Value(22).to_str() == '22'
}
