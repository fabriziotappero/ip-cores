/*
MEMORY
        {
        vectors : ORIGIN = 0x00000000, LENGTH = 0x00002000
        flash   : ORIGIN = 0x04000000, LENGTH = 0x00200000
        ram     : ORIGIN = 0x00002000, LENGTH = 0x001fe000
        icm     : ORIGIN = 0x00800000, LENGTH = 0x00004000
        }
 */
MEMORY
	{
	reset	: ORIGIN = 0x00000000, LENGTH = 0x00000200
	vectors : ORIGIN = 0x00000200, LENGTH = 0x00001000
    ram     : ORIGIN = 0x00001200, LENGTH = 0x00006E00  

	}

SECTIONS
{
	.reset :
        {
        *(.reset)
        } > reset


 
	.vectors :
        {
        _vec_start = .;
        *(.vectors)
        _vec_end = .;
        } > vectors

        .text :
        {
        *(.text)
        } > ram

      .rodata :
        {
        *(.rodata)
        *(.rodata.*)
        } > ram
 
     .icm :
        {
        _icm_start = .;
        *(.icm)
        _icm_end = .;
        } > ram

     .data :
        {
        _dst_beg = .;
        *(.data)
        _dst_end = .;
        } > ram
 
      .bss :
        {
        *(.bss)
        } > ram
 
      .stack (NOLOAD) :
        {
        *(.stack)
        _src_addr = .;
        } > ram

}
