Searching for: XX
// dec_n1
LDsB_N                  ; 06 XX
LDsC_N                  ; 0E XX
LDsD_N                  ; 16 XX
LDsE_N                  ; 1E XX
LDsH_N                  ; 26 XX
LDsL_N                  ; 2E XX
LDs6HL7_N               ; 36 XX
LDsA_N                  ; 3E XX
ADDsA_N                 ; C6 XX
ADCsA_N                 ; CE XX
OUTs6N7_A               ; D3 XX
SUBsN                   ; D6 XX
INsA_6N7                ; DB XX



//dec_n2
LDsBC_NN                ; 01 XX XX
LDsDE_NN                ; 11 XX XX
LDsHL_NN                ; 21 XX XX
LDs6NN7_HL              ; 22 XX XX
LDsHL_6NN7              ; 2A XX XX
LDsSP_NN                ; 31 XX XX
LDs6NN7_A               ; 32 XX XX
LDsA_6NN7               ; 3A XX XX
CALLsNZ_NN              ; C4 XX XX
CALLsZ_NN               ; CC XX XX
CALLsNN                 ; CD XX XX
CALLsNC_NN              ; D4 XX XX
CALLsNC_NN              ; D4 XX XX
CALLsC_NN               ; DC XX XX





LD IX,NN                ; DD 21 XX XX
LD (NN),IX              ; DD 22 XX XX
LD IX,(NN)              ; DD 2A XX XX
INC (IX+N)              ; DD 34 XX
DEC (IX+N)              ; DD 35 XX
LD (IX+N),N             ; DD 36 XX XX
LD B,(IX+N)             ; DD 46 XX
LD C,(IX+N)             ; DD 4E XX
LD D,(IX+N)             ; DD 56 XX
LD E,(IX+N)             ; DD 5E XX
LD H,(IX+N)             ; DD 66 XX
LD L,(IX+N)             ; DD 6E XX
LD (IX+N),B             ; DD 70 XX
LD (IX+N),C             ; DD 71 XX
LD (IX+N),D             ; DD 72 XX
LD (IX+N),E             ; DD 73 XX
LD (IX+N),H             ; DD 74 XX
LD (IX+N),L             ; DD 75 XX
LD (IX+N),A             ; DD 77 XX
LD A,(IX+N)             ; DD 7E XX
ADD A,(IX+N)            ; DD 86 XX
ADC A,(IX+N)            ; DD 8E XX
SUB (IX+N)              ; DD 96 XX
SBC A,(IX+N)            ; DD 9E XX
AND (IX+N)              ; DD A6 XX
XOR (IX+N)              ; DD AE XX
OR (IX+N)               ; DD B6 XX
CP (IX+N)               ; DD BE XX
RLC (IX+N)              ; DD CB XX 06
RRC (IX+N)              ; DD CB XX 0E
RL (IX+N)               ; DD CB XX 16
RR (IX+N)               ; DD CB XX 1E
SLA (IX+N)              ; DD CB XX 26
SRA (IX+N)              ; DD CB XX 2E
BIT 0,(IX+N)            ; DD CB XX 46
BIT 1,(IX+N)            ; DD CB XX 4E
BIT 2,(IX+N)            ; DD CB XX 56
BIT 3,(IX+N)            ; DD CB XX 5E
BIT 4,(IX+N)            ; DD CB XX 66
BIT 5,(IX+N)            ; DD CB XX 6E
BIT 6,(IX+N)            ; DD CB XX 76
BIT 7,(IX+N)            ; DD CB XX 7E
RES 0,(IX+N)            ; DD CB XX 86
RES 1,(IX+N)            ; DD CB XX 8E
RES 2,(IX+N)            ; DD CB XX 96
RES 3,(IX+N)            ; DD CB XX 9E
RES 4,(IX+N)            ; DD CB XX A6
RES 5,(IX+N)            ; DD CB XX AE
RES 6,(IX+N)            ; DD CB XX B6
RES 7,(IX+N)            ; DD CB XX BE
SET 0,(IX+N)            ; DD CB XX C6
SET 1,(IX+N)            ; DD CB XX CE
SET 2,(IX+N)            ; DD CB XX D6
SET 3,(IX+N)            ; DD CB XX DE
SET 4,(IX+N)            ; DD CB XX E6
SET 5,(IX+N)            ; DD CB XX EE
SET 6,(IX+N)            ; DD CB XX F6
SET 7,(IX+N)            ; DD CB XX FE
SBC A,N                 ; DE XX
CALL PO,NN              ; E4 XX XX
AND N                   ; E6 XX
CALL PE,NN              ; EC XX XX
LD (NN),BC              ; ED 43 XX XX
LD BC,(NN)              ; ED 4B XX XX
LD (NN),DE              ; ED 53 XX XX
LD DE,(NN)              ; ED 5B XX XX
LD (NN),SP              ; ED 73 XX XX
LD SP,(NN)              ; ED 7B XX XX
XOR N                   ; EE XX
CALL P,NN               ; F4 XX XX
OR N                    ; F6 XX
CALL M,NN               ; FC XX XX
LD IY,NN                ; FD 21 XX XX
LD (NN),IY              ; FD 22 XX XX
LD IY,(NN)              ; FD 2A XX XX
INC (IY+N)              ; FD 34 XX
DEC (IY+N)              ; FD 35 XX
LD (IY+N),N             ; FD 36 XX XX
LD B,(IY+N)             ; FD 46 XX
LD C,(IY+N)             ; FD 4E XX
LD D,(IY+N)             ; FD 56 XX
LD E,(IY+N)             ; FD 5E XX
LD H,(IY+N)             ; FD 66 XX
LD L,(IY+N)             ; FD 6E XX
LD (IY+N),B             ; FD 70 XX
LD (IY+N),C             ; FD 71 XX
LD (IY+N),D             ; FD 72 XX
LD (IY+N),E             ; FD 73 XX
LD (IY+N),H             ; FD 74 XX
LD (IY+N),L             ; FD 75 XX
LD (IY+N),A             ; FD 77 XX
LD A,(IY+N)             ; FD 7E XX
ADD A,(IY+N)            ; FD 86 XX
ADC A,(IY+N)            ; FD 8E XX
SUB (IY+N)              ; FD 96 XX
SBC A,(IY+N)            ; FD 9E XX
AND (IY+N)              ; FD A6 XX
XOR (IY+N)              ; FD AE XX
OR (IY+N)               ; FD B6 XX
CP (IY+N)               ; FD BE XX
RLC (IY+N)              ; FD CB XX 06
RRC (IY+N)              ; FD CB XX 0E
RL (IY+N)               ; FD CB XX 16
RR (IY+N)               ; FD CB XX 1E
SLA (IY+N)              ; FD CB XX 26
SRA (IY+N)              ; FD CB XX 2E
BIT 0,(IY+N)            ; FD CB XX 46
BIT 1,(IY+N)            ; FD CB XX 4E
BIT 2,(IY+N)            ; FD CB XX 56
BIT 3,(IY+N)            ; FD CB XX 5E
BIT 4,(IY+N)            ; FD CB XX 66
BIT 5,(IY+N)            ; FD CB XX 6E
BIT 6,(IY+N)            ; FD CB XX 76
BIT 7,(IY+N)            ; FD CB XX 7E
RES 0,(IY+N)            ; FD CB XX 86
RES 1,(IY+N)            ; FD CB XX 8E
RES 2,(IY+N)            ; FD CB XX 96
RES 3,(IY+N)            ; FD CB XX 9E
RES 4,(IY+N)            ; FD CB XX A6
RES 5,(IY+N)            ; FD CB XX AE
RES 6,(IY+N)            ; FD CB XX B6
RES 7,(IY+N)            ; FD CB XX BE
SET 0,(IY+N)            ; FD CB XX C6
SET 1,(IY+N)            ; FD CB XX CE
SET 2,(IY+N)            ; FD CB XX D6
SET 3,(IY+N)            ; FD CB XX DE
SET 4,(IY+N)            ; FD CB XX E6
SET 5,(IY+N)            ; FD CB XX EE
SET 6,(IY+N)            ; FD CB XX F6
SET 7,(IY+N)            ; FD CB XX FE
CP N                    ; FE XX
Found 159 occurrence(s) in 1 file(s)

