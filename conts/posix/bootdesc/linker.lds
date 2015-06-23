ENTRY(_start)

SECTIONS
{
	_start = .;
	.data : { *(.data) }
	_end = .;
}
