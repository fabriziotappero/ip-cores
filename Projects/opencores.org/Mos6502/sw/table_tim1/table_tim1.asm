
	
       cpu 6502
           output HEX


        * = $c000  ; assemble at $ff00
               code


.str_1          ASC    "Mem  " ;
                DB   $00		;	


	* = $c010  ; assemble at $ff10

.top       db $0a,$0d ;
	   ASC    "MIK";
	
	
        * = $c0fa  ; vectors

          dw $0000	       
          dw $0000	       
          dw $0000	       

 code
    





