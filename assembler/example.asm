		csr negro
end		jmp	end

negro	stm r0,32
		ldi r1,80    
		ldi r2,60  
		ldi r3,0   
		ldi r4,0   
nextc	cmp r4,r1
		jpz inc_fil
		stm r3,64
		stm r4,32
		adi r4,1
		jmp nextc
inc_fil	ldi r4,0
		cmp r3,r2
		jpz fneg
		adi r3,1
		jmp nextc
fneg 	ret


