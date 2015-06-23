AltOR32 SPR Registers
=====================

### SPR_REG_VR

##### Description
Version register.

##### Encoding
`SPR_ADDR = 0x0000`

### SPR_REG_SR

##### Description
Status register (SR)

##### Encoding
`SPR_ADDR = 0x0011`

### SPR_REG_EPC

##### Description
Saved (prior to exception) PC register (EPC).

##### Encoding
`SPR_ADDR = 0x0020`

### SPR_REG_ESR

##### Description
Saved (prior to exception) status (SR) register (ESR).

##### Encoding
`SPR_ADDR = 0x0040`

### SR - Status Register

| Bit    | Description                    |  
| ------ | -------------------------------|  
| 2      | Interrupt enable.              |
| 9      | Flag status.                   |
| 10     | Carry out status.              |
| 17     | Instruction cache flush.       |
| 18     | Data cache flush.              |
