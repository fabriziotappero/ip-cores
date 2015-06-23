# crt.asm
#	C RunTime:
#	Used for initialization of small data 
#	anchors and stack for programs compiled using 
#	Xilinx Gnu Tools. 
#	Used for initialization of user's bss area
#	All external and static variables are initialized                 

	.globl _start

	.align 2
	.ent _start
_start:
	nop				/* to help simulation external program without block ram */
	/* todo : initialize system vectors */
					/* Set the Small Data Anchors and the Stack pointer  */
	la r13, r0, _SDA_BASE_
	la r2, r0, _SDA2_BASE_
	la r1, r0, _stack		# stack is at end of heap
		
_crtinit:				/* clear sbss */
	addi	r6,r0,__sbss_start      /* SBSS beginning	*/
	addi	r7,r0,__sbss_end	/* SBSS end		*/
	rsub	r18,r6,r7		/* Compare		*/
	blei	r18,.Lendsbss
.Lloopsbss:	
	sw	r0,r6,r0
	addi	r6,r6,4
	rsub	r18,r6,r7
	bgti	r18,.Lloopsbss
.Lendsbss:				/* clear bss */
	addi	r6,r0,__bss_start      	/* BSS beginning	*/
	addi	r7,r0,__bss_end		/* BSS end		*/
	rsub	r18,r6,r7		/* Compare		*/
	blei	r18,.Lendbss
.Lloopbss:	
	sw	r0,r6,r0
	addi	r6,r6,4
	rsub	r18,r6,r7
	bgti	r18,.Lloopbss
.Lendbss:

    	brlid	r15,main		# enter main program (ignoring parameters: r5, r6 & r7)
	nop				# fall throught to exit
        .end _start

        .globl exit                  	# exit library call 
        .ent exit        
exit:
	brai	0x0			# enter monitor again...
	.end exit        
