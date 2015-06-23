
; ============================================================================
;        __
;   \\__/ o\    (C) 2014  Robert Finch, Stratford
;    \  __ /    All rights reserved.
;     \/_//     robfinch<remove>@opencores.org
;       ||
;  
;
; This source file is free software: you can redistribute it and/or modify 
; it under the terms of the GNU Lesser General Public License as published 
; by the Free Software Foundation, either version 3 of the License, or     
; (at your option) any later version.                                      
;                                                                          
; This source file is distributed in the hope that it will be useful,      
; but WITHOUT ANY WARRANTY; without even the implied warranty of           
; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the            
; GNU General Public License for more details.                             
;                                                                          
; You should have received a copy of the GNU General Public License        
; along with this program.  If not, see <http://www.gnu.org/licenses/>.    
;                                                                          
; ============================================================================
;
;==============================================================================
; Ethernet test code
;==============================================================================
my_MAC1	EQU	0x00
my_MAC2	EQU	0xFF
my_MAC3	EQU	0xEE
my_MAC4	EQU	0xF0
my_MAC5	EQU	0xDA
my_MAC6	EQU	0x42

; r1 = PHY
; r2 = regnum
; r3 = data
;
eth_mii_write:
	pha
	phx
	push	r4
	ld		r4,#ETHMAC
	asl		r2,r2,#8
	or		r1,r1,r2
	sta		ETH_MIIADDRESS,r4
	sty		ETH_MIITX_DATA,r4
	lda		#ETH_WCTRLDATA
	sta		ETH_MIICOMMAND,r4
	stz		ETH_MIICOMMAND,r4
emiw1:
	lda		ETH_MIISTATUS,r4
	bit		#ETH_MIISTATUS_BUSY
	bne		emiw1
	pop		r4
	plx
	pla
	rts

; r1 = PHY
; r2 = reg

eth_mii_read:
	phx
	phy
	ldy		#ETHMAC
	asl		r2,r2,#8
	or		r1,r1,r2
	sta		ETH_MIIADDRESS,y	
	lda		#ETH_MIICOMMAND_RSTAT
	sta		ETH_MIICOMMAND,y
	stz		ETH_MIICOMMAND,y
emir1:
	lda		ETH_MIISTATUS,y
	bit		#ETH_MIISTATUS_BUSY
	bne		emir1	
	lda		ETH_MIIRX_DATA,y
	ply
	plx
	rts

public ethmac_setup:
	ld		r4,#ETHMAC
	lda		#ETH_MIIMODER_RST
	sta		ETH_MIIMODER,r4
	lda		ETH_MIIMODER,r4
	and		#~ETH_MIIMODER_RST
	sta		ETH_MIIMODER,r4
	lda		#$10				; /16=1.25MHz
	sta		ETH_MIIMODER,r4		; Clock divider for MII Management interface 
	lda		#ETH_MODER_RST
	sta		ETH_MODER,r4
	lda		ETH_MODER,r4
	and		#~ETH_MODER_RST
	sta		ETH_MODER,r4

	stz		ETH_MIITX_DATA,r4
	stz		ETH_MIIADDRESS,r4
	stz		ETH_MIICOMMAND,r4
	
	lda		#0xEEF0DA42
	sta		ETH_MAC_ADDR0,r4		; MAC0
	lda		#0x00FF
	sta		ETH_MAC_ADDR1,r4		; MAC1

	lda		#-1
	sta		ETH_INT_SOURCE,r4

	; Advertise support for 10/100 FD/HD
	lda		#ETH_PHY
	ldx		#ETH_MII_ADVERTISE
	jsr		eth_mii_read
	or		r3,r1,#ETH_ADVERTISE_ALL
	lda		#ETH_PHY
	ldx		#ETH_MII_ADVERTISE
	jsr		eth_mii_write

	; Do NOT advertise support for 1000BT
	lda		#ETH_PHY
	ldx		#ETH_MII_CTRL1000
	jsr		eth_mii_read
	and		r3,r1,#~(ETH_ADVERTISE_1000FULL|ETH_ADVERTISE_1000HALF)
	lda		#ETH_PHY
	ldx		#ETH_MII_CTRL1000
	jsr		eth_mii_write
 
	; Disable 1000BT
	lda		#ETH_PHY
	ldx		#ETH_MII_EXPANSION
	jsr		eth_mii_read
	and		r3,r1,#~(ETH_ESTATUS_1000_THALF|ETH_ESTATUS_1000_TFULL)
	ldx		#ETH_MII_EXPANSION
	jsr		eth_mii_write
  
	; Restart autonegotiation
	lda		#0
	ldx		#ETH_MII_BMCR
	jsr		eth_mii_read
	and		r3,r1,#~(ETH_BMCR_ANRESTART|ETH_BMCR_ANENABLE)
	lda		#7
	jsr		eth_mii_write
	
	; Enable BOTH the transmiter and receiver
	lda		#$A003
	sta		ETH_MODER,r4
	rts
  
; Initialize the ethmac controller.
; Supply a MAC address, set MD clock
;
message "eth_init"
public eth_init:
	pha
	phy
	ldy		#ETHMAC
	lda		#$A003
	sta		ETH_MODER,y
;	lda		#0x64				; 100
;	sta		ETH_MIIMODER,y
;	lda		#7					; PHY address
;	sta		ETH_MIIADDRESS,y
	lda		#0xEEF0DA42
	sta		ETH_MAC_ADDR0,y		; MAC0
	lda		#0x00FF
	sta		ETH_MAC_ADDR1,y		; MAC1
	ply
	pla
	rts

; Request a packet and display on screen
; r1 = address where to put packet
;
message "eth_request_packet"
public eth_request_packet:
	phx
	phy
	push	r4
	push	r5
	ldy		#ETHMAC
	ldx		#4					; clear rx interrupt
	stx		ETH_INT_SOURCE,y
	sta		0x181,y				; storage address
	ldx		#0xe000				; enable interrupt
	stx		0x180,y
eth1:
	nop
	ldx		ETH_INT_SOURCE,y
	bit		r2,#4				; get bit #2
	beq		eth1
	ldx		0x180,y				; get from descriptor
	lsr		r2,r2,#16
	ldy		#0
	pha
	jsr		GetScreenLocation
	add		r4,r1,3780			; second last line of screen
	pla
eth20:
	add		r5,r1,r3
	lb		r2,0,r5				; get byte
	add		r5,r4,r3
	stx		(r5)				; store to screen
	iny
	cpy		#83
	bne		eth20
	pop		r5
	pop		r4
	ply
	plx
	rts

; r1 = packet address
;
message "eth_interpret_packet"
public eth_interpret_packet:
	phx
	phy
	lb		r2,12,r1
	lb		r3,13,r1
	cpx		#8					; 0x806 ?
	bne		eth2	
	cpy		#6		
	bne		eth2
	lda		#2					; return r1 = 2 for ARP
eth5:
	ply
	plx
	rts
eth2:
	cpx		#8
	bne		eth3				; 0x800 ?
	cpy		#0
	bne		eth3
	lb		r2,23,r1
	cpx		#1
	bne		eth4
	lda		#1
	bra		eth5				; return 1 ICMP
eth4:
	cpx		#$11
	bne		eth6
	lda		#3					; return 3 for UDP
	bra		eth5
eth6:
	cpx		#6
	bne		eth7
	lda		#4					; return 4 for TCP
	bra		eth5
eth7:
eth3:
	eor		r1,r1,r1			; return zero for unknown
	ply
	plx
	rts

; r1 = address of packet to send
; r2 = packet length
;
message "eth_send_packet"
public eth_send_packet:
	phx
	phy
	push	r4
	ldy		#ETHMAC
	; wait for tx buffer to be clear
eth8:
	ld		r4,0x100,y
	bit		r4,#$8000
	bne		eth8
	ld		r4,#1			; clear tx interrupt
	st		r4,ETH_INT_SOURCE,y
	; set address
	sta		0x101,y
	; set the packet length field and enable interrupts
	asl		r2,r2,#16
	or		r2,r2,#0xF000
	stx		0x100,y
	pop		r4
	ply
	plx
	rts

; Only for IP type packets (not ARP)
; r1 = rx buffer address
; r2 = swap flag
; Returns:
; r1 = data start index
;
message "eth_build_packet"
public eth_build_packet:
	phy
	push	r4
	push	r5
	push	r6
	push	r7
	push	r8
	push	r9
	push	r10

	lb		r3,6,r1
	lb		r4,7,r1
	lb		r5,8,r1
	lb		r6,9,r1
	lb		r7,10,r1
	lb		r8,11,r1
	; write to destination header
	sb		r3,0,r1
	sb		r4,1,r1
	sb		r5,2,r1
	sb		r6,3,r1
	sb		r7,4,r1
	sb		r8,5,r1
	; write to source header
	ld		r3,#my_MAC1
	sb		r3,6,r1
	ld		r3,#my_MAC2
	sb		r3,7,r1
	ld		r3,#my_MAC3
	sb		r3,8,r1
	ld		r3,#my_MAC4
	sb		r3,9,r1
	ld		r3,#my_MAC5
	sb		r3,10,r1
	ld		r3,#my_MAC6
	sb		r3,11,r1
	cmp		r2,#1
	bne		eth16			; if (swap)
	lb		r3,26,r1
	lb		r4,27,r1
	lb		r5,28,r1
	lb		r6,29,r1
	; read destination
	lb		r7,30,r1
	lb		r8,31,r1
	lb		r9,32,r1
	lb		r10,33,r1
	; write to sender
	sb		r7,26,r1
	sb		r8,27,r1
	sb		r9,28,r1
	sb		r10,29,r1
	; write destination
	sb		r3,30,r1
	sb		r4,31,r1
	sb		r5,32,r1
	sb		r6,33,r1
eth16:
	ldy		eth_unique_id
	iny
	sty		eth_unique_id
	sb		r3,19,r1
	lsr		r3,r3,#8
	sb		r3,18,r1
	lb		r3,14,r1
	and		r3,r3,#0xF
	asl		r3,r3,#2		; *4
	add		r1,r3,#14		; return datastart in r1
	pop		r10
	pop		r9
	pop		r8
	pop		r7
	pop		r6
	pop		r5
	pop		r4
	ply
	rts

; Compute IPv4 checksum of header
; r1 = packet address
; r2 = data start
;
message "eth_checksum"
public eth_checksum:
	phy
	push	r4
	push	r5
	push	r6
	; set checksum to zero
	stz		24,r1
	stz		25,r1
	eor		r3,r3,r3		; r3 = sum = zero
	ld		r4,#14
eth15:
	ld		r5,r2
	dec		r5				; r5 = datastart - 1
	cmp		r4,r5
	bpl		eth14
	add		r6,r1,r4
	lb		r5,0,r6			; shi = [rx_addr+i]
	lb		r6,1,r6		    ; slo = [rx_addr+i+1]
	asl 	r5,r5,#8
	or		r5,r5,r6		; shilo
	add		r3,r3,r5		; sum = sum + shilo
	add		r4,r4,#2		; i = i + 2
	bra		eth15
eth14:
	ld		r5,r3			; r5 = sum
	and		r3,r3,#0xffff
	lsr		r5,r5,#16
	add		r3,r3,r5
	eor		r3,r3,#-1
	sb		r3,25,r1		; low byte
	lsr		r3,r3,#8
	sb		r3,24,r1		; high byte
	pop		r6
	pop		r5
	pop		r4
	ply
	rts

; r1 = packet address
; returns r1 = 1 if this IP
;	
message "eth_verifyIP"
public eth_verifyIP:
	phx
	phy
	push	r4
	push	r5
	lb		r2,30,r1
	lb		r3,31,r1
	lb		r4,32,r1
	lb		r5,33,r1
	; Check for general broadcast
	cmp		r2,#$FF
	bne		eth11
	cmp		r3,#$FF
	bne		eth11
	cmp		r4,#$FF
	bne		eth11
	cmp		r5,#$FF
	bne		eth11
eth12:
	lda		#1
eth13:
	pop		r5
	pop		r4
	ply
	plx
	rts
eth11:
	ld		r1,r2
	asl		r1,r1,#8
	or		r1,r1,r3
	asl		r1,r1,#8
	or		r1,r1,r4
	asl		r1,r1,#8
	or		r1,r1,r5
	cmp		#$C0A8012A		; 192.168.1.42
	beq		eth12
	eor		r1,r1,r1
	bra		eth13

msgEthTest
	db		CR,LF,"Ethernet test - press CTRL-C to exit.",CR,LF,0

message "eth_main"
public eth_main:
	jsr		RequestIOFocus
	jsr		ClearScreen
	jsr		HomeCursor
	lda		#msgEthTest
	jsr		DisplayStringB
;	jsr		eth_init
	jsr		ethmac_setup
eth_loop:
	jsr		KeybdGetChar
	cmp		#-1
	beq		eth17
	cmp		#CTRLC
	bne		eth17
	lda		#$A000					; tunr off transmit/recieve
	sta		ETH_MODER+ETHMAC
	jsr		ReleaseIOFocus
	rts
eth17
	lda		#eth_rx_buffer<<2		; memory address zero
	jsr		eth_request_packet
	jsr		eth_interpret_packet	; r1 = packet type

	cmp		#1
	bne		eth10
	ld		r2,r1					; save off r1, r2 = packet type
	lda		#eth_rx_buffer<<2		; memory address zero
	jsr		eth_verifyIP
	tay
	txa								; r1 = packet type again
	cpy		#1
	bne		eth10

	lda		#eth_rx_buffer<<2		; memory address zero
	ldx		#1
	jsr		eth_build_packet
	tay								; y = icmpstart
	lda		#eth_rx_buffer<<2		; memory address zero
	add		r4,r1,r3
	sb		r0,0,r4					; [rx_addr+icmpstart] = 0
	lb		r2,17,r1
	add		r2,r2,#14				; r2 = len
	ld		r6,r2					; r6 = len
	add		r15,r1,r3
	lb		r4,2,r15				; shi
	lb		r5,3,r15				; slo
	asl		r4,r4,#8
	or		r4,r4,r5				; sum = {shi,slo};
	eor		r4,r4,#-1				; sum = ~sum
	sub		r4,r4,#0x800			; sum = sum - 0x800
	eor		r4,r4,#-1				; sum = ~sum
	add		r15,r1,r3
	sb		r4,3,r15
	lsr		r4,r4,#8
	sb		r4,2,r15
	tyx
	jsr		eth_checksum
	lda		#eth_rx_buffer<<2		; memory address zero
	ld		r2,r6
	jsr		eth_send_packet
	jmp		eth_loop
eth10:
	; r2 = rx_addr
	cmp		#2
	bne		eth_loop		; Do we have ARP ?
;	xor		r2,r2,r2			; memory address zero
	ldx		#eth_rx_buffer<<2
	; get the opcode
	lb		r13,21,x
	cmp		r13,#1
	bne		eth_loop		; ARP request
	; get destination IP address
	lb		r9,38,x
	lb		r10,39,x
	lb		r11,40,x
	lb		r12,41,x
	; set r15 = destination IP
	ld		r15,r9
	asl		r15,r15,#8
	or		r15,r15,r10
	asl		r15,r15,#8
	or		r15,r15,r11
	asl		r15,r15,#8
	or		r15,r15,r12
	; Is it our IP ?
	cmp		r15,#$C0A8012A	; //192.168.1.42
	bne		eth_loop
	; get source IP address
	lb		r5,28,x
	lb		r6,29,x
	lb		r7,30,x
	lb		r8,31,x
	; set r14 = source IP
	ld		r14,r5
	asl		r14,r14,#8
	or		r14,r14,r6
	asl		r14,r14,#8
	or		r14,r14,r7
	asl		r14,r14,#8
	or		r14,r14,r8
	; Get the source MAC address
	push	r6
	push	r7
	push	r8
	push	r9
	push	r10
	push	r11
	lb		r6,22,x
	lb		r7,23,x
	lb		r8,24,x
	lb		r9,25,x
	lb		r10,26,x
	lb		r11,27,x
	; write to destination header
	sb		r6,0,x
	sb		r7,1,x
	sb		r8,2,x
	sb		r9,3,x
	sb		r10,4,x
	sb		r11,5,x
	; and write to ARP destination
	sb		r6,32,x
	sb		r7,33,x
	sb		r8,34,x
	sb		r9,35,x
	sb		r10,36,x
	sb		r11,37,x
	pop		r11
	pop		r10
	pop		r9
	pop		r8
	pop		r7
	pop		r6
	; write to source header
;	stbc	#0x00,6[r2]
;	stbc	#0xFF,7[r2]
;	stbc	#0xEE,8[r2]
;	stbc	#0xF0,9[r2]
;	stbc	#0xDA,10[r2]
;	stbc	#0x42,11[r2]
	sb		r0,6,x
	lda		#0xFF
	sb		r1,7,x
	lda		#0xEE
	sb		r1,8,x
	lda		#0xF0
	sb		r1,9,x
	lda		#0xDA
	sb		r1,10,x
	lda		#0x42
	sb		r1,11,x
	; write to ARP source
;	stbc	#0x00,22[r2]
;	stbc	#0xFF,23[r2]
;	stbc	#0xEE,24[r2]
;	stbc	#0xF0,25[r2]
;	stbc	#0xDA,26[r2]
;	stbc	#0x42,27[r2]
	sb		r0,22,x
	lda		#0xFF
	sb		r1,23,x
	lda		#0xEE
	sb		r1,24,x
	lda		#0xF0
	sb		r1,25,x
	lda		#0xDA
	sb		r1,26,x
	lda		#0x42
	sb		r1,27,x
	; swap sender / destination IP
	; write sender
	sb		r9,28,x
	sb		r10,29,x
	sb		r11,30,x
	sb		r12,31,x
	; write destination
	sb		r5,38,x
	sb		r6,39,x
	sb		r7,40,x
	sb		r8,41,x
	; change request to reply
;	stbc	#2,21[r2]
	lda		#2
	sb		r1,21,x
	txa						; r1 = packet address
	ldx		#0x2A			; r2 = packet length
	jsr		eth_send_packet
	jmp		eth_loop

