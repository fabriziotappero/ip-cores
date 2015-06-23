         .set    noreorder
         .globl  strcmp
	.align	5
 strcmp:
         lbu     $8,0($4)
 3:
         lbu     $9,0($5)
         beq     $8,$0,1f
         lbu     $10,1($4)
         lbu     $11,1($5)
         bne     $8,$9,1f
         addi    $4,$4,2
         beq     $10,$0,2f
         addi    $5,$5,2
         beq     $10,$11,3b
         lbu     $8,0($4)
 2:
         j       $31
         subu    $2,$10,$11
 1:
         j       $31
        subu    $2,$8,$9
