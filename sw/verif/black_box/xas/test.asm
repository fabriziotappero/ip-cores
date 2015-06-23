	;; *******************************************************************
	;; $Id: test.asm 179 2009-04-01 19:48:38Z arniml $
	;;
	;; Checks the XAS instruction.
	;;

	;; the cpu type is defined on asl's command line

	org	0x00
	clra

	;; *******************************************************************
	;; Test counter functionality
	;;
	lei	0x5
	;; enable counter
	clra
	camq

	;; clear SKL
	xas
	nop			; spend some time to let effect of SKL
	nop			; falling edge pass by
	nop			;

	;; -------------------------------------------------------------------
	;; step 1
	;; decrement counter from 1 to 0
	;; test SO by controlling SI via SO
	;; 
	;; load 0x1 to counter
	clra
	aisc	0x1
	xas
	;; decrement via SO
	lei	0xd
	nop			; ensure minimum '1' duration
	lei	0x5
	nop			;
	nop			; ensure minimum '0' duration
	nop			;
	xas
	;; check for 0x0
	xad	3, 15
	clra
	x	0
	xad	3, 15
	ske
	jmp	fail

	;; -------------------------------------------------------------------
	;; step 2
	;; decrement counter from 0 to 0xf
	;; test SKL by controlling SI via SK
	;;
	;; set SKL to '1'
	sc			; SKL = '1'
	xas
	;; load 0x0 to counter, decrement via SK
	clra
	rc
	xas
	nop			;
	nop			; ensure minimum '0' duration
	nop			;
	xas
	;; check for 0xf
	xad	3, 15
	clra
	aisc	0xf
	x	0
	xad	3, 15
	ske
	jmp	fail


	;; -------------------------------------------------------------------
	;; step 3
	;; check minimum high time on SI
	;;
	;; load 0x0 to counter
	clra
	xas
	;; clock on SI
	lei	0xd
	lei	0x5		; high time too short
	nop			;
	nop			; ensure minimum '0' duration
	nop			;
	xas
	;; check for 0x0
	xad	3, 15
	clra
	x	0
	xad	3, 15
	ske
	jmp	fail

	;; -------------------------------------------------------------------
	;; step 4
	;; check minimum low time on SI
	;;
	;; load 0x0 to counter
	clra
	xas
	;; clock on SI
	lei	0xd
	nop			; ensure minimum '1' duration
	lei	0x5
	lei	0xd		; low time too short
	xas
	;; check for 0x0
	xad	3, 15
	clra
	x	0
	xad	3, 15
	ske
	jmp	fail


	;; *******************************************************************
	;; Test shift register functionality
	;;
	lei	0xc		; SO = SIO output
	;; enable shift register
	aisc	0x1
	camq

	;; shift out 0x5
	aisc	0x4
	sc
	xas
	;;
	nop			;
	nop			; shift for four clocks on SK
	rc			;
	xas			; stop SK
	;; check for 0x2
	xad	3, 15
	clra
	aisc	0x2
	x	0
	xad	3, 15
	ske
	jmp	fail

	;; shift out 0x0
	clra
	sc
	xas
	;;
	nop			;
	nop			; shift for four clocks on SK
	rc			;
	xas			; stop SK
	;; check for 0x8
	xad	3, 15
	clra
	aisc	0x8
	x	0
	xad	3, 15
	ske
	jmp	fail

	;; now disable SO and check that only '0' is shifted in
	lei	0x4		; SO = '0'
	;; shift out 0xf
	clra
	aisc	0xf
	sc
	xas
	;;
	nop			;
	nop			; shift for four clocks on SK
	rc			;
	xas			; stop SK
	;; check for 0x0
	xad	3, 15
	clra
	x	0
	xad	3, 15
	ske
	jmp	fail

	;; enable SO
	lei	0xc
	;; shift out 0x1 to force SI to '1' via SO
	clra
	aisc	0x1
	sc
	xas
	;;
	nop			;
	nop			; shift for four clocks on SK
	rc			;
	xas			; stop SK
	;; shift out 0x0 with disabled SK
	clra
	xas
	;;
	nop			;
	nop			; shift for four clocks on SK
	nop			;
	xas
	;; check for 0xf
	xad	3, 15
	clra
	aisc	0xf
	x	0
	xad	3, 15
	ske
	jmp	fail

	jmp	pass

	org	0x100
	include	"pass_fail.asm"
