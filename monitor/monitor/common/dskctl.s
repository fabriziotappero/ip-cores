;
; dskctl.s -- disk made available by disk controller
;

;***************************************************************

	.set	dskbase,0xF0400000	; disk base address
	.set	dskctrl,0		; control register
	.set	dskcnt,4		; count register
	.set	dsksct,8		; sector register
	.set	dskcap,12		; capacity register
	.set	dskbuf,0x00080000	; disk buffer

	.set	ctrlstrt,0x01		; start bit
	.set	ctrlien,0x02		; interrupt enable bit
	.set	ctrlwrt,0x04		; write bit
	.set	ctrlerr,0x08		; error bit
	.set	ctrldone,0x10		; done bit
	.set	ctrlrdy,0x20		; ready bit

	.set	sctsize,512		; sector size in bytes

	.set	retries,1000000		; retries to get disk ready

	.export	dskinitctl		; initialize disk
	.export	dskcapctl		; determine disk capacity
	.export	dskioctl		; do disk I/O

;***************************************************************

	.code
	.align	4

dskinitctl:
	jr	$31

dskcapctl:
	add	$8,$0,retries		; set retry count
	add	$9,$0,dskbase
dskcap1:
	ldw	$10,$9,dskctrl
	and	$10,$10,ctrlrdy		; ready?
	bne	$10,$0,dskcapok		; yes - jump
	sub	$8,$8,1
	bne	$8,$0,dskcap1		; try again
	add	$2,$0,0			; no disk found
	j	dskcapx
dskcapok:
	ldw	$2,$9,dskcap		; get disk capacity
dskcapx:
	jr	$31

dskioctl:
	sub	$29,$29,24
	stw	$31,$29,20
	stw	$16,$29,16
	stw	$17,$29,12
	stw	$18,$29,8
	stw	$19,$29,4
	stw	$20,$29,0
	add	$16,$4,$0		; command
	add	$17,$5,$0		; sector number
	add	$18,$6,0xC0000000	; memory address, virtualized
	add	$19,$7,$0		; number of sectors

	add	$8,$0,'r'
	beq	$16,$8,dskrd
	add	$8,$0,'w'
	beq	$16,$8,dskwr
	add	$2,$0,0xFF		; illegal command
	j	dskx

dskrd:
	add	$2,$0,$0		; return ok
	beq	$19,$0,dskx		; if no (more) sectors
	add	$8,$0,dskbase
	add	$9,$0,1
	stw	$9,$8,dskcnt		; number of sectors
	stw	$17,$8,dsksct		; sector number on disk
	add	$9,$0,ctrlstrt
	stw	$9,$8,dskctrl		; start command
dskrd1:
	ldw	$2,$8,dskctrl
	and	$9,$2,ctrldone		; done?
	beq	$9,$0,dskrd1		; no - wait
	and	$9,$2,ctrlerr		; error?
	bne	$9,$0,dskx		; yes - leave
	add	$8,$0,dskbase + dskbuf	; transfer data
	add	$9,$0,sctsize
dskrd2:
	ldw	$10,$8,0		; from disk buffer
	stw	$10,$18,0		; to memory
	add	$8,$8,4
	add	$18,$18,4
	sub	$9,$9,4
	bne	$9,$0,dskrd2
	add	$17,$17,1		; increment sector number
	sub	$19,$19,1		; decrement number of sectors
	j	dskrd			; next sector

dskwr:
	add	$2,$0,$0		; return ok
	beq	$19,$0,dskx		; if no (more) sectors
	add	$8,$0,dskbase + dskbuf	; transfer data
	add	$9,$0,sctsize
dskwr1:
	ldw	$10,$18,0		; from memory
	stw	$10,$8,0		; to disk buffer
	add	$18,$18,4
	add	$8,$8,4
	sub	$9,$9,4
	bne	$9,$0,dskwr1
	add	$8,$0,dskbase
	add	$9,$0,1
	stw	$9,$8,dskcnt		; number of sectors
	stw	$17,$8,dsksct		; sector number on disk
	add	$9,$0,ctrlwrt | ctrlstrt
	stw	$9,$8,dskctrl		; start command
dskwr2:
	ldw	$2,$8,dskctrl
	and	$9,$2,ctrldone		; done?
	beq	$9,$0,dskwr2		; no - wait
	and	$9,$2,ctrlerr		; error?
	bne	$9,$0,dskx		; yes - leave
	add	$17,$17,1		; increment sector number
	sub	$19,$19,1		; decrement number of sectors
	j	dskwr			; next sector

dskx:
	ldw	$20,$29,0
	ldw	$19,$29,4
	ldw	$18,$29,8
	ldw	$17,$29,12
	ldw	$16,$29,16
	ldw	$31,$29,20
	add	$29,$29,24
	jr	$31
