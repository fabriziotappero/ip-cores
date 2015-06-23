.text
   .align 2
   .global entry
   .ent entry
entry:
   .set noreorder
   la    $sp, 1000
   jal   main
   nop
$L1:
   j $L1

   .end entry

   .global  fsleep
   .ent     fsleep
fsleep:
   .set noreorder
   
   mtc0 $a0, $11
   mtc0 $zero, $9
   lui  $k0, 0xffff
   ori  $k0, 0x010c
   lw   $k1, 0($k0)
   andi	$k1,$k1,0x1
   beqz	$k1,fsleep + 16
   sw   $zero, 0($k0) 
   nop
   nop
   nop
   jr 	$ra

   .set reorder
   .end fsleep
