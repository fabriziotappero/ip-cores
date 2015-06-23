	;; *******************************************************************
	;; $Id: pass_fail.asm 179 2009-04-01 19:48:38Z arniml $
	;;
	;; Provides pass/fail signalling via port L.
	;;
	;; Result value is expected in accumuator.
	;;
	;; Signalling on L:
	;;   0x0R
	;;   0xaR
	;;   0x5R
	;;     0x0R  -> pass
	;;     0xfR  -> fail
	;;

	;; catch spurious code execution
	jmp	fail

pass:
	lei	0x4
	;; save result to M
	x	0x0
	;; output 0x0R to Q
	clra
	camq
	;; output 0xaR to Q
	aisc	0xa
	camq
	;; output 0x5R to Q
	clra
	aisc	0x5
	camq
	;; output 0x0R to Q
	clra
	camq
	jp	.

fail:
	lei	0x4
	;; save result to M
	x	0x0
	;; output 0x0R to Q
	clra
	camq
	;; output 0xaR to Q
	aisc	0xa
	camq
	;; output 0x5R to Q
	clra
	aisc	0x5
	camq
	;; output 0xfR to Q
	clra
	aisc	0xf
	camq
	jp	.
