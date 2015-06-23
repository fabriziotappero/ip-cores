;**********************************************************************************
;*                                                                                *
;* alu_ops compare data                                                           *
;*                                                                                *
;**********************************************************************************
	org	01008h
	db	0ceh, 0b3h, 0cfh, 033h, 0ceh, 033h, 033h, 0cdh

	org	02008h
	db	0e1h, 078h, 0e0h, 0f8h, 0e0h, 0f8h, 078h, 0e1h

	org	02da8h
	dw	0ffffh, 0ffffh, 0ffffh, 03872h	;2da8h
	dw	00000h, 00000h, 0ffffh, 0ffffh	;2db0h

	org	03008h
	db	08bh, 0e2h, 08bh, 0e2h, 08ah, 0e2h, 062h, 0f7h, 02eh, 08bh
	
;	org	04000h
;	db	0a1h, 0b4h, 01ch, 04dh
	
;	org	04100h
;	db	0e2h, 0f8h, 023h, 085h

	org	078cbh
	db	02fh, 0bfh

	org	0bc9eh
	db	0f1h, 07fh

	org	0ca02h
	db	020h, 0ffh

	org	0fac8h
	dw	06304h, 06200h, 03872h, 00ff0h	;fac8h
	dw	03872h, 03f01h, 000ffh, 0fe01h	;fad0h
	dw	00000h, 0ff01h, 0fe01h, 00000h	;fad8h
	dw	0ff01h, 0ffffh, 00000h, 00057h	;fae0h
	dw	01303h, 08296h, 07706h, 06701h	;fae8h
	dw	08591h, 08485h, 01705h, 00111h	;faf0h
	dw	00605h, 07804h, 09094h, 09984h	;faf8h

;	org	0fb76h
;	dw	0234dh
;	dw	0f81ch, 0e2b4h, 08501h, 0a140h	;fb78h

	org	0fb90h
	dw	06030h, 0aaaah, 0dedeh, 0bcbch	;fb90h
	dw	0a382h, 0fc93h, 07a06h, 04a06h	;fb98h
	dw	0a282h, 0fc93h, 07a06h, 04a06h	;fba0h
	dw	06012h, 06097h, 06002h, 06042h	;fba8h
	dw	0ad80h, 00400h, 09a84h, 0ca84h	;fbb0h
	dw	0af84h, 0ae80h, 0ba80h, 0ea80h	;fbb8h
	dw	00101h, 00101h, 0aa00h, 0aa01h	;fbc0h
	dw	0aa00h, 0aa01h, 0aa51h, 0aa51h	;fbc8h
	dw	0aa50h, 0aa50h, 0ffffh, 0ffffh	;fbd0h
	dw	0aa92h, 0aa42h, 0aa90h, 0aa43h	;fbd8h
	dw	0aa93h, 0aa42h, 0aa92h, 0aa43h	;fbe0h
	dw	00210h, 0aa94h, 02010h, 02010h	;fbe8h
	dw	0b190h, 05815h, 0da80h, 00a01h	;fbf0h
	dw	0b290h, 05815h, 0db80h, 00a01h	;fbf8h

	org	0fc00h
	dw	03544h, 06a44h, 0d444h, 0a845h	;fc00h
	dw	05145h, 0a344h, 05145h, 0a845h	;fc08h
	dw	0d444h, 06a44h, 03544h, 06a44h	;fc10h
	dw	0d445h, 0a945h, 05344h, 0a644h	;fc18h
	dw	05345h, 0a945h, 0d444h, 06a44h	;fc20h
	dw	00004h, 00080h, 00081h, 00080h	;fc28h
	dw	00081h, 00004h, 00085h, 00005h	;fc30h
	dw	00005h, 00080h, 00005h, 00084h	;fc38h
	dw	00081h, 00080h, 00001h, 00085h	;fc40h
	dw	00081h, 00084h, 00085h, 00085h	;fc48h
	dw	00085h, 00004h, 01078h, 010f0h	;fc50h
	dw	04d65h, 04dcbh, 02c33h, 02c67h	;fc58h
	dw	00080h, 010f8h, 010f0h, 0cde5h	;fc60h
	dw	0cdcbh, 02c33h, 02c67h, 00081h	;fc68h
	dw	042e0h, 042f0h, 03496h, 034cbh	;fc70h
	dw	0b0ceh, 0b067h, 00080h, 090f8h	;fc78h
	dw	090f0h, 0cd65h, 0cdcbh, 0ac33h	;fc80h
	dw	0ac67h, 00081h, 043e0h, 043f0h	;fc88h
	dw	03497h, 034cbh, 0b0ceh, 0b067h	;fc90h
	dw	00004h, 09078h, 090f0h, 04de5h	;fc98h
	dw	04dcbh, 02cb3h, 02c67h, 00085h	;fca0h
	dw	042e1h, 042f0h, 03597h, 035cbh	;fca8h
	dw	0b0ceh, 0b067h, 00000h, 00000h	;fcb0h
	dw	00000h, 02105h, 04300h, 00605h	;fcb8h
	dw	00d00h, 01a01h, 0e185h, 0c384h	;fcc0h
	dw	00605h, 00d00h, 01a01h, 0a084h	;fcc8h
	dw	05005h, 0a881h, 0d484h, 06a04h	;fcd0h
	dw	03504h, 06a04h, 0d484h, 0a881h	;fcd8h
	dw	05101h, 0a384h, 05101h, 0a881h	;fce0h
	dw	0d484h, 06a04h, 03504h, 06a04h	;fce8h
	dw	0d485h, 0a985h, 05304h, 0a684h	;fcf0h
	dw	05305h, 0a985h, 0d484h, 06a04h	;fcf8h
	
	org	0fd24h
	dw	0bf85h, 0bf80h	;fd24h
	dw	0bf85h, 0bf85h, 043e1h, 043f0h	;fd28h
	dw	03597h, 035cbh, 0b1cfh, 0b167h	;fd30h
	dw	021f0h, 09acbh, 05867h, 0bf80h	;fd38h
	dw	05f05h, 0af85h, 0d784h, 06b00h	;fd40h

	org	0fd48h
	dw	0ffffh, 0ffffh, 00042h, 0ff93h	;fd48h
	dw	00042h, 0c181h, 0e080h, 0e084h	;fd50h
	dw	07010h, 03842h, 03810h, 00044h	;fd58h
	dw	0c083h, 00e02h, 00042h, 05e16h	;fd60h
	dw	0b483h, 05506h, 0a282h, 0fc93h	;fd68h
	dw	07a06h, 04906h, 09884h, 01110h	;fd70h
	dw	0a991h, 0f680h, 0a091h, 0ff80h	;fd78h
	dw	0b290h, 05815h, 0db80h, 00b01h	;fd80h
	dw	02083h, 00f02h, 0aa42h, 0b416h	;fd88h
	dw	0aa83h, 0aa06h, 0aa82h, 0aa93h	;fd90h
	dw	0aa06h, 0aa06h, 0c083h, 00e02h	;fd98h
	dw	00042h, 05f16h, 0b483h, 05506h	;fda0h
	dw	0a382h, 0fc93h, 07a06h, 04a06h	;fda8h
	dw	09884h, 01010h, 0a991h, 0f580h	;fdb0h
	dw	0a091h, 0ff80h, 0b190h, 05815h	;fdb8h
	dw	0da80h, 00a01h, 07804h, 08f80h	;fdc0h
	dw	0df80h, 05504h, 00044h, 0ff84h	;fdc8h
	dw	0af84h, 0ae80h, 0ba80h, 0ea80h	;fdd0h
	dw	00100h, 05d00h, 0ff84h, 0df80h	;fdd8h
	dw	02000h, 00044h, 0ad80h, 00400h	;fde0h
	dw	09a84h, 0ca84h, 08294h, 00054h	;fde8h
	dw	02814h, 00a14h, 08a90h, 00054h	;fdf0h
	dw	00210h, 00810h, 02010h, 08090h	;fdf8h

	org	0fe30h
	dw	0ffffh, 0ffffh, 01234h, 05256h	;fe30h
	dw	00093h, 00000h, 01234h, 05256h	;fe38h
	dw	00042h, 083afh, 01234h, 05256h	;fe40h
	dw	00093h, 081fah, 01234h, 05256h	;fe48h
	dw	00093h, 0804ch, 01234h, 05256h	;fe50h
	dw	00082h, 09281h, 01234h, 05256h	;fe58h
	dw	00082h, 0a4b5h, 01234h, 05256h	;fe60h
	dw	00082h, 0f70ch, 01234h, 05256h	;fe68h
	dw	00083h, 04962h, 01234h, 05256h	;fe70h
	dw	00011h, 04ae7h, 01234h, 05256h	;fe78h
	dw	00011h, 04c65h, 01234h, 05256h	;fe80h
	dw	00000h, 02632h, 01234h, 05256h	;fe88h
	dw	00005h, 09319h, 01234h, 05256h	;fe90h
	dw	00080h, 080e4h, 01234h, 05256h	;fe98h
	dw	00094h, 06eb0h, 01234h, 05256h	;fea0h
	dw	00000h, 01c59h, 01234h, 05256h	;fea8h
	dw	00001h, 0bca0h, 078bch, 0ca03h	;feb0h
	dw	01234h, 05256h, 07f16h, 07f92h	;feb8h
	dw	07f10h, 0bca0h, 078bch, 0ca02h	;fec0h
	dw	01234h, 05256h, 07f02h, 0ca05h	;fec8h
	dw	01236h, 05257h, 07f82h, 0cb05h	;fed0h
	dw	01436h, 05557h, 07f00h, 0cb04h	;fed8h
	dw	01434h, 05554h, 07f80h, 0bca0h	;fee0h
	dw	078bch, 0c804h, 01234h, 05454h	;fee8h
	dw	07f16h, 00f12h, 0fe82h, 0ff92h	;fef0h
	dw	00050h, 08094h, 01010h, 00100h	;fef8h

	org	0ff10h
	dw	0ffffh, 0ffffh, 0ffffh, 0bca0h 	;ff10h
	dw	078bch, 0c804h, 01234h, 05454h	;ff18h
	dw	00055h, 0de50h, 078bch, 0c804h	;ff20h
	dw	01234h, 05454h, 00055h, 0df22h	;ff28h
	dw	078bch, 0c804h, 01234h, 05454h	;ff30h
	dw	00044h, 0cceeh, 078bch, 0c804h	;ff38h
	dw	01234h, 05454h, 00044h, 0789ah	;ff40h
	dw	078bch, 0c804h, 01234h, 05454h	;ff48h
	dw	00055h, 0789ah, 0bc5eh, 0c804h	;ff50h
	dw	01234h, 05454h, 00055h, 0789ah	;ff58h
	dw	0bd00h, 0c804h, 01234h, 05454h	;ff60h
	dw	00044h, 0789ah, 0aacch, 0c804h	;ff68h
	dw	01234h, 05454h, 00044h, 0789ah	;ff70h
	dw	05678h, 0c804h, 01234h, 05454h	;ff78h
	dw	00055h, 0c882h, 01234h, 05454h	;ff80h
	dw	00044h, 06441h, 01234h, 05454h	;ff88h
	dw	00044h, 0520dh, 01234h, 05454h	;ff90h
	dw	00055h, 00000h, 00000h, 00001h	;ff98h
	dw	00044h                        	;ffa0h

	org	0ffc8h
	dw	0ffffh, 0ffffh, 0789ah, 05678h	;ffc8h
	dw	07899h, 05678h, 07899h, 0ffffh	;ffd0h
	dw	07899h, 05677h, 00000h, 0ffffh	;ffd8h
	dw	00000h, 0ffffh, 00001h, 00000h	;ffe0h
	dw	0ffffh, 08087h, 00213h, 0fe93h	;ffe8h
	dw	0ff93h, 00042h, 08057h, 07f57h	;fff0h
	dw	00045h, 00045h, 00054h, 00045h	;fff8h

	end
