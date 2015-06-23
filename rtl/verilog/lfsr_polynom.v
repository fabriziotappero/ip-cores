`switch (LFSR_LENGTH)
`case 2
 `let LFSR_FB="qi[`LFSR_LENGTH]^qi[1]"
 `let LFSR_FB_REW="qi[1]^qi[2]"
`breaksw
`case 3
 `let LFSR_FB="qi[`LFSR_LENGTH]^qi[2]"
 `let LFSR_FB_REW="qi[1]^qi[3]"
`breaksw
`case 4
 `let LFSR_FB="qi[`LFSR_LENGTH]^qi[3]"
 `let LFSR_FB_REW="qi[1]^qi[4]"
`breaksw
`case 5
 `let LFSR_FB="qi[`LFSR_LENGTH]^qi[3]"
 `let LFSR_FB_REW="qi[1]^qi[4]"
`breaksw
`case 6
 `let LFSR_FB="qi[`LFSR_LENGTH]^qi[5]"
 `let LFSR_FB_REW="qi[1]^qi[6]"
`breaksw
`case 7
 `let LFSR_FB="qi[`LFSR_LENGTH]^qi[6]"
 `let LFSR_FB_REW="qi[1]^qi[7]"
`breaksw
`case 8
 `let LFSR_FB="qi[`LFSR_LENGTH]^qi[6]^qi[5]^qi[4]"
 `let LFSR_FB_REW="qi[1]^qi[7]^qi[6]^qi[5]"
`breaksw
`case 9
 `let LFSR_FB="qi[`LFSR_LENGTH]^qi[5]"
 `let LFSR_FB_REW="qi[1]^qi[6]"
`breaksw
`case 10
 `let LFSR_FB="qi[`LFSR_LENGTH]^qi[7]"
 `let LFSR_FB_REW="qi[1]^qi[8]"
`breaksw
`case 11
 `let LFSR_FB="qi[`LFSR_LENGTH]^qi[9]"
 `let LFSR_FB_REW="qi[1]^qi[10]"
`breaksw
`case 12
 `let LFSR_FB="qi[`LFSR_LENGTH]^qi[6]^qi[4]^qi[1]"
 `let LFSR_FB_REW="qi[1]^qi[7]^qi[5]^qi[2]"
`breaksw
`case 13
 `let LFSR_FB="qi[`LFSR_LENGTH]^qi[4]^qi[3]^qi[1]"
 `let LFSR_FB_REW="qi[1]^qi[5]^qi[4]^qi[2]"
`breaksw
`case 14
 `let LFSR_FB="qi[`LFSR_LENGTH]^qi[5]^qi[3]^qi[1]"
 `let LFSR_FB_REW="qi[1]^qi[6]^qi[4]^qi[2]"
`breaksw
`case 15
 `let LFSR_FB="qi[`LFSR_LENGTH]^qi[14]"
 `let LFSR_FB_REW="qi[1]^qi[15]"
`breaksw
`case 16
 `let LFSR_FB="qi[`LFSR_LENGTH]^qi[15]^qi[13]^qi[4]"
 `let LFSR_FB_REW="qi[1]^qi[16]^qi[14]^qi[5]"
`breaksw
`case 17
 `let LFSR_FB="qi[`LFSR_LENGTH]^qi[14]"
 `let LFSR_FB_REW="qi[1]^qi[15]"
`breaksw
`case 18
 `let LFSR_FB="qi[`LFSR_LENGTH]^qi[11]"
 `let LFSR_FB_REW="qi[1]^qi[12]"
`breaksw
`case 19
 `let LFSR_FB="qi[`LFSR_LENGTH]^qi[6]^qi[2]^qi[1]"
 `let LFSR_FB_REW="qi[1]^qi[7]^qi[3]^qi[2]"
`breaksw
`case 20
 `let LFSR_FB="qi[`LFSR_LENGTH]^qi[17]"
 `let LFSR_FB_REW="qi[1]^qi[18]"
`breaksw
`case 21
 `let LFSR_FB="qi[`LFSR_LENGTH]^qi[19]"
 `let LFSR_FB_REW="qi[1]^qi[20]"
`breaksw
`case 22
 `let LFSR_FB="qi[`LFSR_LENGTH]^qi[21]"
 `let LFSR_FB_REW="qi[1]^qi[22]"
`breaksw
`case 23
 `let LFSR_FB="qi[`LFSR_LENGTH]^qi[18]"
 `let LFSR_FB_REW="qi[1]^qi[19]"
`breaksw
`case 24
 `let LFSR_FB="qi[`LFSR_LENGTH]^qi[23]^qi[22]^qi[17]"
 `let LFSR_FB_REW="qi[1]^qi[24]^qi[23]^qi[18]"
`breaksw
`case 25
 `let LFSR_FB="qi[`LFSR_LENGTH]^qi[22]"
 `let LFSR_FB_REW="qi[1]^qi[23]"
`breaksw
`case 26
 `let LFSR_FB="qi[`LFSR_LENGTH]^qi[6]^qi[2]^qi[1]"
 `let LFSR_FB_REW="qi[1]^qi[7]^qi[3]^qi[2]"
`breaksw
`case 27
 `let LFSR_FB="qi[`LFSR_LENGTH]^qi[5]^qi[2]^qi[1]"
 `let LFSR_FB_REW="qi[1]^qi[6]^qi[3]^qi[2]"
`breaksw
`case 28
 `let LFSR_FB="qi[`LFSR_LENGTH]^qi[25]"
 `let LFSR_FB_REW="qi[1]^qi[26]"
`breaksw
`case 29
 `let LFSR_FB="qi[`LFSR_LENGTH]^qi[27]"
 `let LFSR_FB_REW="qi[1]^qi[28]"
`breaksw
`case 30
 `let LFSR_FB="qi[`LFSR_LENGTH]^qi[6]^qi[4]^qi[1]"
 `let LFSR_FB_REW="qi[1]^qi[7]^qi[5]^qi[2]"
`breaksw
`case 31
 `let LFSR_FB="qi[`LFSR_LENGTH]^qi[28]"
 `let LFSR_FB_REW="qi[1]^qi[29]"
`breaksw
`case 32
 `let LFSR_FB="qi[`LFSR_LENGTH]^qi[22]^qi[2]^qi[1]"
 `let LFSR_FB_REW="qi[1]^qi[23]^qi[3]^qi[2]"
`breaksw	      
`endswitch
