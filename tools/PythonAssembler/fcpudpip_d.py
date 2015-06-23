# FCP/UDP/IP Assembly Code
from patlpp import *

# R2:R1 = Host IP Address
# R5:R4:R3 = Host MAC Address
# R6 = Request Number (incoming packets)
# R7 = Sequence Number (outgoing packets)
# R8 = Acked Number (outgoing packets)
# R9 = Current Local Port
# R10 = Inited Status
# R11 = Connection Status
# R12 = Current UDP Host Socket
# R15 = Debug Register
	
label = globals()

IP = [10, 0, 1, 42]

INITCODE()


def SRAP2R(source, dest):
	if not isinstance(source, SR):
		print "Invalid Shift Register"
		return 0
	elif not isinstance(dest, R):
		print "Invalid Register"
		return 0
	inst = Instruction("Copy and Wrap SR:" + str(source) + " to R:" + str(dest))
	inst.data_mux_s = 4
	inst.reg_addr = dest.address
	if (dest.high): inst.reg_wen += 2
	if (dest.low): inst.reg_wen += 1
	if (source.sr_num == 1): 
		inst.sr1_out_en = True
		inst.sr1_in_en = True
	else: 
		inst.sr2_out_en = True
		inst.sr2_in_en = True
	MAN(inst)

JMP( label["Main"], IF(EQU(C(1),R(10))) )
MOV( C(0), R(6) )
MOV( C(0), R(7) )
MOV( C(0), R(8) )
MOV( C(1), R(10) )
#: Main
MOV( C(0), IPR())
MOV( C(0), OPR())
IN( HBR(), UNTIL([SOF(),SRC()]) )
IN( HBR() )
IN( HBR() )
IN( HBR() )
IN( HBR() )
IN( HBR() )
IN( SR(1) )
IN( SR(1) )
IN( SR(1) )
IN( SR(1) )
IN( SR(1) )
IN( SR(1) )
IN( HBR() )
IN( R(0) )
JMP( label["IP_PACKET"], IF(EQU(C(2048), R(0))) ) # test for IP
RST( IF(NEQ(C(2054), R(0))) ) # test for ARP

# -------------------------------------------------------
# ARP Packet Handling
# -------------------------------------------------------
IN( HBR() ) # skip hardware type
IN( HBR() )
IN( HBR() ) # test protocol type
IN( R(0) )
RST( IF(NEQ(C(2048),R(0))) )
IN( HBR() ) # skip length fields
IN( HBR() )
IN( HBR() ) # test operation for request
IN( R(0) )
RST( IF(NEQ(C(1),R(0))) )
IN( SR(1) ) # read sender hardware address
IN( SR(1) )
IN( SR(1) )
IN( SR(1) )
IN( SR(1) )
IN( SR(1) )
IN( SR(1) ) # read sender protocol address
IN( SR(1) )
IN( SR(1) )
IN( SR(1) )
IN( HBR() ) # skip target hardware
IN( HBR() )
IN( HBR() )
IN( HBR() )
IN( HBR() )
IN( HBR() )
RST( IF(NEQ(P(),C(IP[0]),True)) ) # check target protocol address
IN( HBR() )
RST( IF(NEQ(P(),C(IP[1]),True)) )
IN( HBR() )
RST( IF(NEQ(P(),C(IP[2]),True)) )
IN( HBR() )
RST( IF(NEQ(P(),C(IP[3]),True)) )
IN( HBR() )
OUT( SR(1), flags=[ASOF()] ) # Ethernet
OUT( SR(1) )
OUT( SR(1) )
OUT( SR(1) )
OUT( SR(1) )
OUT( SR(1) )
OUT( C(0x01) )
OUT( C(0x23) )
OUT( C(0x45) )
OUT( C(0x67) )
OUT( C(0x89) )
OUT( C(0xab) )
OUT( C(0x08) )
OUT( C(0x06) )
OUT( C(0) ) # ARP
OUT( C(1) )
OUT( C(8) )
OUT( C(0) )
OUT( C(6) )
OUT( C(4) )
OUT( C(0) )
OUT( C(2) )
OUT( C(0x01) )
OUT( C(0x23) )
OUT( C(0x45) )
OUT( C(0x67) )
OUT( C(0x89) )
OUT( C(0xab) )
OUT( C(IP[0]) )
OUT( C(IP[1]) )
OUT( C(IP[2]) )
OUT( C(IP[3]) )
OUT(SR(1))
OUT(SR(1))
OUT(SR(1))
OUT(SR(1))
OUT(SR(1))
OUT(SR(1))
OUT(SR(1))
OUT(SR(1))
OUT(SR(1))
OUT(SR(1), flags=[AEOF()])
RST()

# -------------------------------------------------------
# IP Packet Handling
# -------------------------------------------------------
#: IP_PACKET
IN( HBR() ) # Version/HeaderLen
IN( HBR() ) # Differentiated Services
IN( HBR() ) # Total Length 
IN( HBR() ) # Total Leght (cont)
IN( HBR() ) # Id
IN( HBR() ) # Id (cont)
IN( HBR() ) # Flags
IN( HBR() ) # Offset
IN( HBR() ) # Time to live
RST( IF(NEQ(P(),C(17),True) ) )
IN( HBR() ) # Protocol
IN( HBR() ) # Header Checksum
IN( HBR() ) # Header Checksum (cont)
IN( SR(1) ) # Source[3]
IN( SR(1) ) # Source[2]
IN( SR(1) ) # Source[1]
IN( SR(1) ) # Source[0]
RST( IF(NEQ(P(),C(IP[0]),True)) ) # check target protocol address
IN( HBR() ) # Dest[3]
RST( IF(NEQ(P(),C(IP[1]),True)) )
IN( HBR() ) # Dest[2]
RST( IF(NEQ(P(),C(IP[2]),True)) )
IN( HBR() ) # Dest[1]
RST( IF(NEQ(P(),C(IP[3]),True)) )
IN( HBR() ) # Dest[0]
IN( SR(1) ) # UDP: Source Port
IN( SR(1) ) # Source Port (cont)
IN( HBR() ) # Dest Port
RST( IF(NEQ(P(),C(0x3001))) )
IN( HBR() ) # Dest Port (cont)
IN( HBR() ) # Len
IN( HBR() ) # Len
IN( HBR() ) # CS
IN( HBR() ) # CS
IN( R(0) )
JMP( label["LAB_DAT"], IF( EQU(C(0), R(0), True) ) )
JMP( label["LAB_ACK"], IF( EQU(C(1), R(0), True) ) )
JMP( label["LAB_CON"], IF( EQU(C(2), R(0), True) ) )
JMP( label["LAB_DRQ"], IF( EQU(C(4), R(0), True) ) )
RST()

#: LAB_DAT
IN( R(9) ) 
IN( HBR() )
RST( IF(NEQ(P(),R(6))) )
IN( HBR() )
IN( HBR() )
IN( R(0) )
MOV(R(9), OPR())
SUB( R(0), C(1), R(0) )
JMP( label["END_DAT"], IF(EQU(R(0), C(0))) )
#: INI_DAT
IN( SR(2))
OUT(SR(2), flags=[ASOF()])
SUB( R(0), C(1), R(0) )
JMP( label["END_DAT"], IF(EQU(R(0), C(0))) )
#: BEG_DAT
BYP( UNTIL( DEC(R(0), C(1)) ) )
#IN( SR(2))
#OUT(SR(2))
#SUB( R(0), C(1), R(0) )
#JMP( label["BEG_DAT"], IF(NEQ(R(0), C(1))) )
#: END_DAT
IN(SR(2))
OUT(SR(2), flags=[AEOF()])
MOV(C(0), OPR())
JMP(label["LAB_SENDACK"])

#: LAB_ACK
IN( HBR() )
IN( HBR() )
IN( R(8))
IN( HBR() )
IN( HBR() )
IN( HBR() )
RST()

#: LAB_CON
IN(HBR())
IN(HBR())
IN(HBR())
IN(HBR())
IN(HBR())
SRAP2R(SR(1), R(3, low=False)) # read sender hardware address
SRAP2R(SR(1), R(3, high=False))
SRAP2R(SR(1), R(4, low=False))
SRAP2R(SR(1), R(4, high=False))
SRAP2R(SR(1), R(5, low=False))
SRAP2R(SR(1), R(5, high=False))
SRAP2R(SR(1), R(1, low=False)) # read sender protocol address
SRAP2R(SR(1), R(1, high=False))
SRAP2R(SR(1), R(2, low=False))
SRAP2R(SR(1), R(2, high=False))
SRAP2R(SR(1), R(12, low=False)) # read sender UDP port
SRAP2R(SR(1), R(12, high=False))
# IN( HBR() ) # read sender hardware address
# IN( R(3) )
# IN( HBR() )
# IN( R(4) )
# IN( HBR() )
# IN( R(5) )
# IN( HBR() ) # read sender protocol address
# IN( R(1) )
# IN( HBR() )
# IN( R(2) )
MOV( C(0), R(6) )
MOV( C(0), R(7) )
MOV( C(0), R(8) )
JMP(label["LAB_SENDACK"])
RST()

# -------------------------------------------------------
# Data Request Handling
# -------------------------------------------------------

#: LAB_DRQ
IN( R(9) )
IN( HBR() )
RST( IF(NEQ(P(),R(6))) )
IN( HBR() )
IN( HBR() )
IN( R(0) )
OUT(SR(1), flags=[ASOF()])
OUT(SR(1))
OUT(SR(1))
OUT(SR(1))
OUT(SR(1))
OUT(SR(1))
OUT(C(0x01))
OUT(C(0x23))
OUT(C(0x45))
OUT(C(0x67))
OUT(C(0x89))
OUT(C(0xab))
OUT(C(0x08))
OUT(C(0x00))
CSC()
CSA(C(0x4500))
OUT(C(0x45))
OUT(C(0x00))
ADD( C(34), R(0), R(0) )
CSA(R(0))
OUT(R(0, hbs=True))
OUT(R(0))
SUB( R(0), C(34), R(0) )
OUT(C(0x0))
OUT(C(0x0))
OUT(C(0x0))
OUT(C(0x0))
CSA(C(0x2011))
OUT(C(0x20))
OUT(C(0x11))
CSA(C((IP[0] << 8) | IP[1]))
CSA(C((IP[2] << 8) | IP[3]))
CSA(R(1))
CSA(R(2))
OUT(CS(hbs=True))
OUT(CS())
OUT(C(IP[0]))
OUT(C(IP[1]))
OUT(C(IP[2]))
OUT(C(IP[3]))
OUT(SR(1))
OUT(SR(1))
OUT(SR(1))
OUT(SR(1))
CSC()
CSA(C(0x3001))
CSA(R(12))
OUT(C(0x30))
OUT(C(0x01))
OUT(SR(1))
OUT(SR(1))
ADD(C(14),R(0),R(0))
OUT(R(0, hbs=True) )
OUT(R(0))
CSA(R(0))
SUB(R(0),C(14),R(0))
#OUT(CS(hbs=True))
#OUT(CS())
OUT(C(0x00))
OUT(C(0x00))
OUT(C(0x05))
OUT(R(9))
OUT(R(6,hbs=True))
OUT(R(6))
ADD(C(1),R(6),R(6))
OUT(R(0, hbs=True) )
OUT(R(0))

MOV( R(9), IPR())
JMP( label["END_DRQ"], IF(EQU(R(0), C(1))) )
#: DRQ_LOOP
IN(SR(2))
OUT(SR(2))
SUB( R(0), C(1), R(0) )
JMP(label["DRQ_LOOP"], IF(NEQ(R(0),C(1))) )
#: END_DRQ
IN(SR(2))
OUT(SR(2), flags=[AEOF()])
RST()

# -------------------------------------------------------
# Send Ack
# -------------------------------------------------------

#: LAB_SENDACK
OUT(SR(1), flags=[ASOF()])
OUT(SR(1))
OUT(SR(1))
OUT(SR(1))
OUT(SR(1))
OUT(SR(1))
OUT(C(0x01))
OUT(C(0x23))
OUT(C(0x45))
OUT(C(0x67))
OUT(C(0x89))
OUT(C(0xab))
OUT(C(0x08))
OUT(C(0x00))
CSC()
CSA(C(0x4500))
OUT(C(0x45))
OUT(C(0x00))
CSA(C(0x0022))
OUT(C(0x0))
OUT(C(0x22))
OUT(C(0x0))
OUT(C(0x0))
OUT(C(0x0))
OUT(C(0x0))
CSA(C(0x2011))
OUT(C(0x20))
OUT(C(0x11))
CSA(C((IP[0] << 8) | IP[1]))
CSA(C((IP[2] << 8) | IP[3]))
CSA(R(1))
CSA(R(2))
OUT(CS(hbs=True))
OUT(CS())
OUT(C(IP[0]))
OUT(C(IP[1]))
OUT(C(IP[2]))
OUT(C(IP[3]))
OUT(SR(1))
OUT(SR(1))
OUT(SR(1))
OUT(SR(1))
OUT(C(0x30))
OUT(C(0x01))
CSC()
CSA(C(0x3001))
CSA(R(12))
OUT(SR(1))
OUT(SR(1))
OUT(C(0x00))
OUT(C(14))
CSA(C(0x0006))
#OUT(CS(hbs=True))
#OUT(CS())
OUT(C(0x00))
OUT(C(0x00))
OUT(C(0x01))
OUT(C(0x00))
OUT(R(6,hbs=True))
OUT(R(6))
ADD(C(1), R(6), R(6))
OUT(C(0x00))
OUT(C(0x00), flags=[AEOF()])
RST()

ENDCODE()
