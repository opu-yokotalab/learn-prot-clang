create table compile_error (
error_flag	boolean,
line	integer,
function_name	text,
source_name	text,
sourcr_rev	text,
time	timestamp without time zone,
compile_pkey	serial not null	primary key
);

create table run_error (
error_flag	boolean,
line	integer,
function_name	text,
memory_address	text,
signal_name	text,
source_name	text,
source_rev	text,
run_rev	text,
time	timestamp without time zone,
run_pkey	serial not null primary key
);

create table evaluate_result (

);