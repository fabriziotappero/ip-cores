
	mov a, #10h	;
	mov 15h, #20h	;
	mov 25h, 15h	;
	orl 25h, #1h	;
	add a, 25h	;
	mov p0, a	;

done:
	ajmp done	;

end