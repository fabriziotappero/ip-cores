##################################################################
# TITLE: Boot Up Code
# AUTHOR: Steve Rhoads (rhoadss@yahoo.com)
# DATE CREATED: 1/12/02
# FILENAME: boot.asm
# PROJECT: Plasma CPU core
# COPYRIGHT: Software placed into the public domain by the author.
#    Software 'as is' without warranty.  Author liable for nothing.
# DESCRIPTION:
#    Initializes the stack pointer and jumps to main2().
##################################################################
	.text
	.align	2
	.globl	entry
	.ent	entry
entry:
   .set noreorder

   #These eight instructions must be the first instructions.
   #convert.exe will correctly initialize $gp
   lui   $gp,0
   ori   $gp,$gp,0
   #convert.exe will set $4=.sbss_start $5=.bss_end
   lui   $4,0
   ori   $4,$4,0
   lui   $5,0
   ori   $5,$5,0
   lui   $sp,0
   ori   $sp,$sp,0xfff0     #initialize stack pointer
$BSS_CLEAR:
   sw    $0,0($4)
   slt   $3,$4,$5
   bnez  $3,$BSS_CLEAR
   addiu $4,$4,4

   jal   main2
   nop
$L1:
   j $L1

   #address 0x3c
interrupt_service_routine:
   #registers $26 and $27 are reserved for the OS
   ori $26,$0,0xffff
   ori $27,$0,46
   sb $27,0($26)           #echo out '.'
   
   #normally clear the interrupt source here

   #return and re-enable interrupts
   ori $26,$0,0x1
   mfc0 $27,$14      #C0_EPC=14
   jr $27
   mtc0 $26,$12      #STATUS=1; enable interrupts
   .set reorder
	.end	entry


###################################################
   .globl isr_enable
   .ent isr_enable
isr_enable:
   .set noreorder
   jr $31
   mtc0  $4,$12            #STATUS=1; enable interrupts
   .set reorder
   .end isr_enable


###################################################
	.globl	putchar
	.ent	putchar
putchar:
   .set noreorder
   li $5,0xffff

   #Uncomment to make each character on a seperate line
   #The VHDL simulator buffers the lines
#   sb $4,0($5)
#   ori $4,$0,'\n'

   jr $31
   sb $4,0($5)
   .set reorder
   .end putchar


###################################################
	.globl	puts
	.ent	puts
puts:
   .set noreorder
   ori $5,$0,0xffff
PUTS1:
   lb $6,0($4)
   beqz $6,PUTS2
   addiu $4,$4,1
   b PUTS1
   sb $6,0($5)
PUTS2:
   jr $31
   ori $2,$0,0
   .set reorder
   .end puts


