Dorq
====

Simple and extendable scripting language written in PERL

WARNING
-------

A very dirty draft version it is

How to run scripts
------------------

	perl -MDorq -e 'run "hello.dorq"'

Syntax
------

### String definition

	"some string"

### Number definition

	100500

### Boolean definition

	true()
	false() # sorry for brackets

### Array definition

	array ( "element1"; 2; 3 );
	array ();

	[ ( "element1"; 2; 3 ) ]
	[]

### Hash definition

	hash ( "key" => "value"; "other_key" => 3; "third key"; 5; );
	hash ();

	{ ( "key" => "value"; "other_key" => 3; "third key"; 5; ) };
	{}

### Variable definition

	let $var;
	let $var = "string";
	let $var = $other_var;
	let $var = hash ();
	let $var = array ();
	let $var = function();
	let $var = true();
	let $var = -1;

### Function definition

	defun function
	(
		"function body";
		"this string will be returned to caller"
	);

### Lambda definition

	lambda (
		"some function body";
	);

### Function arguments

	defun function_with_args
	(
		"simply try to access an argument by name: " + $some_arg;
		"here it is concatenated with some string"
	);

	function_with_args( let $some_arg = "some string" );

### Object methods

Everything is an object and everything inherits from "object" class.

	let $bool = $object.defined();

### String methods

	let $var = "some string";

	$var.split( let $re = "\s+" );
	$var.like( let $re = "[a-z]+" );
	$var.ilike( let $re = "[a-z]+" );
	$var.length();

	"some string".split( let $re = "\s+" );

### Number methods

	let $var = 3;

	$var.times (
		let $code = lambda (
			print ( let $str = $element );
		);
	);

	3.times (
		let $code = lambda (
			print ( let $str = $element );
		);
	);

### Array methods

	let $var = array ( 1; 2; 3; );

	$var.push( let $list = array( 4; 5; 6; ) );
	$var.unshift( let $list = array( 0 ) );
	$var.size();
	let $first_el = $var.first();
	let $last_el = $var.last();
	let $second_el = $var.get( let $idx = 1 );
	let $first_el = $var.shift(); # also removes first element from array
	let $last_el = $var.pop(); # also removes last element from array
	let $second_el = $var.get( let $idx = 1 );
	let $new_value = $var.set( let $idx = 0; let $val = "some new value" );

	$var.each (
		let $code = lambda (
			print ( let $str = $element );
		);
	);

	array ( 1; 2; 3; ).each (
		let $code = lambda (
			print ( let $str = $element );
		);
	);

### Hash methods

	let $var = hash ( "key" => "value"; "other_key" => "other_value" );

	let $value = $var.get( let $key = "key" );
	let $new_value = $var.set( let $key = "key"; let $val = 100500; );
	let $array_with_keys = $var.keys();
	let $array_with_values = $var.values();
	let $bool = $var.exists( let $key = "some key" );
	let $value_for_removed_key = $val.delete( let $key = "key" );

### Lambda methods

	let $var = lambda (
		print( let $str = $in );
	);

	$var.call( let $in = "some string" );

### Context object

You have an access to $context object almost anywhere. It represents, well, current context.

#### Methods

##### exists( let $name = "..." )

Check whether a named symbol exists in current context.

##### localize()

Take all symbols from parental context and isolate current context from all parental contexts. Best used together with lambda.call() .

### Loop object

You have an access to $loop object inside of almost every loop.

#### Methods

##### next()

Skips current iteration immediately.

##### last()

Ends current loop immediately.

### Builtin functions

	print( let $str = "" );
	E( let $str = "" ); # interpolate escape sequences in string
	Dump( let $val = $some_variable ); # dump internal Dorq object

	ruleset (
		let $set = array (
			array (
				lambda (
					"boolean" == "equation";
				);

				lambda (
					print ( let $str = "action code" );
				);
			);
		);

		let $default = lambda (
			print ( let $str = "default action" );
		);
	);

