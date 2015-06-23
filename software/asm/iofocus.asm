comment ~
;------------------------------------------------------------------------------
; Get a bit from the I/O focus table.
;------------------------------------------------------------------------------
GetIOFocusBit:
	phx
	phy
	tax
	and		r1,r1,#$1F		; get bit index into word
	lsr		r2,r2,#5		; get word index into table
	ldy		IOFocusTbl,x
	lsr		r3,r3,r1		; extract bit
	and		r1,r3,#1
	ply
	plx
	rts
~
;------------------------------------------------------------------------------
; ForceIOFocus
;
; Force the IO focus to a specific job.
;------------------------------------------------------------------------------
;
public ForceIOFocus:
	pha
	phx
	phy
	spl		iof_sema + 1
	ldy		IOFocusNdx
	cmp		r1,r3
	beq		fif1
	tax
	jsr		CopyScreenToVirtualScreen
	lda		JCB_pVirtVid,y
	sta		JCB_pVidMem,y
	lda		JCB_pVirtVidAttr,y
	sta		JCB_pVidMemAttr,y
	stx		IOFocusNdx
	lda		#TEXTSCR
	sta		JCB_pVidMem,x
	add		#$10000
	sta		JCB_pVidMemAttr,x
	jsr		CopyVirtualScreenToScreen
fif1:
	stz		iof_sema + 1
	ply
	plx
	pla
	rts
	
;------------------------------------------------------------------------------
; SwitchIOFocus
;
; Switches the IO focus to the next task requesting the I/O focus. This
; routine may be called when a task releases the I/O focus as well as when
; the user presses ALT-TAB on the keyboard.
; On Entry: the io focus semaphore is set already.
;------------------------------------------------------------------------------
;
public SwitchIOFocus:
	pha
	phx
	phy

	; First check if it's even possible to switch the focus to another
	; task. The I/O focus list could be empty or there may be only a
	; single task in the list. In either case it's not possible to
	; switch.
	ldy		IOFocusNdx		; Get the job at the head of the list.
	beq		siof3			; Is the list empty ?
	ldx		JCB_iof_next,y	; Get the next job on the list.
	beq		siof3			; Nothing to switch to
	
	; Copy the current task's screen to it's virtual screen buffer.
	jsr		CopyScreenToVirtualScreen
	lda		JCB_pVirtVid,y
	sta		JCB_pVidMem,y
	lda		JCB_pVirtVidAttr,y
	sta		JCB_pVidMemAttr,y

	stx		IOFocusNdx		; Make task the new head of list.
	lda		#TEXTSCR
	sta		JCB_pVidMem,x
	add		#$10000
	sta		JCB_pVidMemAttr,x

	; Copy the virtual screen of the task recieving the I/O focus to the
	; text screen.
	jsr		CopyVirtualScreenToScreen
siof3:
	ply
	plx
	pla
	rts

;------------------------------------------------------------------------------
; The I/O focus list is an array indicating which jobs are requesting the
; I/O focus. The I/O focus is user controlled by pressing ALT-TAB on the
; keyboard.
;------------------------------------------------------------------------------
message "RequestIOFocus"
public RequestIOFocus:
	pha
	phx
	phy
	push	r4
	DisTmrKbd
	ldx		RunningTCB	
	ldx		TCB_hJCB,x
	cpx		#NR_JCB
	bhs		riof1
	txa
	bmt		IOFocusTbl		; is the job already in the IO focus list ?
	bne		riof1
	mul		r4,r2,#JCB_Size
	add		r4,r4,#JCBs
	lda		IOFocusNdx		; Is the focus list empty ?
	beq		riof2
	ldy		JCB_iof_prev,r1
	beq		riof4
	st		r4,JCB_iof_prev,r1
	sta		JCB_iof_next,r4
	sty		JCB_iof_prev,r4
	st		r4,JCB_iof_next,y
riof3:
	txa
	bms		IOFocusTbl
riof1:
	EnTmrKbd
	pop		r4
	ply
	plx
	pla
	rts

	; Here, the IO focus list was empty. So expand it.
	; Make sure pointers are NULL
riof2:
	st		r4,IOFocusNdx
	stz		JCB_iof_next,r4
	stz		JCB_iof_prev,r4
	bra		riof3

	; Here there was only a single entry in the list.
	; Setup pointers appropriately.
riof4:
	sta		JCB_iof_next,r4
	sta		JCB_iof_prev,r4
	st		r4,JCB_iof_next,r1
	st		r4,JCB_iof_prev,r1
	bra		riof3

;------------------------------------------------------------------------------
; Releasing the I/O focus causes the focus to switch if the running job
; had the I/O focus.
; ForceReleaseIOFocus forces the release of the IO focus for a job
; different than the one currently running.
;------------------------------------------------------------------------------
;
message "ForceReleaseIOFocus"
public ForceReleaseIOFocus:
	pha
	phx
	phy
	push	r4
	tax
	DisTmrKbd
	jmp		rliof4
message "ReleaseIOFocus"	
public ReleaseIOFocus:
	pha
	phx
	phy
	push	r4
	DisTmrKbd
	ldx		RunningTCB	
	ldx		TCB_hJCB,x
rliof4:
	cpx		#NR_JCB
	bhs		rliof3
;	phx	
	ldy		#1
	txa
	bmt		IOFocusTbl
	beq		rliof3
	bmc		IOFocusTbl
;	plx
	mul		r4,r2,#JCB_Size
	add		r4,r4,#JCBs
	cmp		r4,IOFocusNdx	; Does the running job have the I/O focus ?
	bne		rliof1
	jsr		SwitchIOFocus	; If so, then switch the focus.
rliof1:
	lda		JCB_iof_next,r4	; get next and previous fields.
	beq		rliof5			; Is list emptying ?
	ldy		JCB_iof_prev,r4
	sta		JCB_iof_next,y	; prev->next = current->next
	sty		JCB_iof_prev,r1	; next->prev = current->prev
	bra		rliof2
rliof5:
	stz		IOFocusNdx		; emptied.
rliof2:
	stz		JCB_iof_next,r4	; Update the next and prev fields to indicate
	stz		JCB_iof_prev,r4	; the job is no longer on the list.
rliof3:
	EnTmrKbd
	pop		r4
	ply
	plx
	pla
	rts

