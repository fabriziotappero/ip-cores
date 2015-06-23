

	.section	.vectors.hw_exception

	.global	_hw_exception_handler
	.func	_hw_exception_handler
_hw_exception_handler:	
	//rtsd	r15, 8
	rted	r17, 0
	nop

	.end

