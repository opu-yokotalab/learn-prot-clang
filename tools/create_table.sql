create table compile_error (
error_flag	boolean,
compile_count	integer,
line	integer,
function_name	text,
source_name	text,
error_description	text,
sourcr_rev	text,
time	timestamp without time zone,
compile_pkey	serial not null	primary key
);

create table debug_error (
error_flag	boolean,
debug_count	integer,
line	integer,
function_name	text,
memory_address	text,
signal_name	text,
source_name	text,
evaluate_result	boolean,
source_rev	text,
run_rev	text,
trace_rev	text,
time	timestamp without time zone,
run_pkey	serial not null primary key
);
