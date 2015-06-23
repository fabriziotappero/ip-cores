                              1 ;--------------------------------------------------------
                              2 ; File Created by SDCC : free open source ANSI-C Compiler
                              3 ; Version 2.8.0 #5117 (May 15 2008) (UNIX)
                              4 ; This file was generated Wed Apr  2 23:08:29 2014
                              5 ;--------------------------------------------------------
                              6 	.module default_tmp
                              7 	.optsdcc -mmcs51 --model-small
                              8 	
                              9 ;--------------------------------------------------------
                             10 ; Public variables in this module
                             11 ;--------------------------------------------------------
                             12 	.globl _sendStringDescriptor_PARM_3
                             13 	.globl _sendStringDescriptor_PARM_2
                             14 	.globl _spi_write_PARM_2
                             15 	.globl _flash_read_PARM_2
                             16 	.globl _mac_eeprom_init_hexdigits_1_1
                             17 	.globl _EmptyStringDescriptor
                             18 	.globl _FullSpeedConfigDescriptor_PadByte
                             19 	.globl _FullSpeedConfigDescriptor
                             20 	.globl _HighSpeedConfigDescriptor_PadByte
                             21 	.globl _HighSpeedConfigDescriptor
                             22 	.globl _DeviceQualifierDescriptor
                             23 	.globl _DeviceDescriptor
                             24 	.globl _configurationString
                             25 	.globl _productString
                             26 	.globl _manufacturerString
                             27 	.globl _fpga_flash_boot_id
                             28 	.globl _main
                             29 	.globl _init_USB
                             30 	.globl _mac_eeprom_init
                             31 	.globl _EP8_ISR
                             32 	.globl _EP6_ISR
                             33 	.globl _EP4_ISR
                             34 	.globl _EP2_ISR
                             35 	.globl _EP1OUT_ISR
                             36 	.globl _EP1IN_ISR
                             37 	.globl _EP0ACK_ISR
                             38 	.globl _HSGRANT_ISR
                             39 	.globl _URES_ISR
                             40 	.globl _SUSP_ISR
                             41 	.globl _SUTOK_ISR
                             42 	.globl _SOF_ISR
                             43 	.globl _abscode_identity
                             44 	.globl _fpga_configure_from_flash_init
                             45 	.globl _fpga_first_free_sector
                             46 	.globl _fpga_configure_from_flash
                             47 	.globl _fpga_send_ep0
                             48 	.globl _spi_send_ep0
                             49 	.globl _spi_read_ep0
                             50 	.globl _flash_init
                             51 	.globl _flash_write_next
                             52 	.globl _flash_write_finish
                             53 	.globl _flash_write_finish_sector
                             54 	.globl _flash_write_init
                             55 	.globl _flash_write
                             56 	.globl _flash_write_byte
                             57 	.globl _spi_pp
                             58 	.globl _flash_read_finish
                             59 	.globl _flash_read_next
                             60 	.globl _flash_read_init
                             61 	.globl _spi_wait
                             62 	.globl _spi_deselect
                             63 	.globl _spi_select
                             64 	.globl _spi_write
                             65 	.globl _spi_write_byte
                             66 	.globl _flash_read
                             67 	.globl _flash_read_byte
                             68 	.globl _spi_clocks
                             69 	.globl _mac_eeprom_read_ep0
                             70 	.globl _mac_eeprom_write
                             71 	.globl _mac_eeprom_read
                             72 	.globl _eeprom_write_ep0
                             73 	.globl _eeprom_read_ep0
                             74 	.globl _eeprom_write
                             75 	.globl _eeprom_read
                             76 	.globl _eeprom_select
                             77 	.globl _i2c_waitStop
                             78 	.globl _i2c_waitStart
                             79 	.globl _i2c_waitRead
                             80 	.globl _i2c_waitWrite
                             81 	.globl _MEM_COPY1_int
                             82 	.globl _uwait
                             83 	.globl _wait
                             84 	.globl _abscode_intvec
                             85 	.globl _EIPX6
                             86 	.globl _EIPX5
                             87 	.globl _EIPX4
                             88 	.globl _PI2C
                             89 	.globl _PUSB
                             90 	.globl _BREG7
                             91 	.globl _BREG6
                             92 	.globl _BREG5
                             93 	.globl _BREG4
                             94 	.globl _BREG3
                             95 	.globl _BREG2
                             96 	.globl _BREG1
                             97 	.globl _BREG0
                             98 	.globl _EIEX6
                             99 	.globl _EIEX5
                            100 	.globl _EIEX4
                            101 	.globl _EI2C
                            102 	.globl _EUSB
                            103 	.globl _ACC7
                            104 	.globl _ACC6
                            105 	.globl _ACC5
                            106 	.globl _ACC4
                            107 	.globl _ACC3
                            108 	.globl _ACC2
                            109 	.globl _ACC1
                            110 	.globl _ACC0
                            111 	.globl _SMOD1
                            112 	.globl _ERESI
                            113 	.globl _RESI
                            114 	.globl _INT6
                            115 	.globl _CY
                            116 	.globl _AC
                            117 	.globl _F0
                            118 	.globl _RS1
                            119 	.globl _RS0
                            120 	.globl _OV
                            121 	.globl _F1
                            122 	.globl _PF
                            123 	.globl _TF2
                            124 	.globl _EXF2
                            125 	.globl _RCLK
                            126 	.globl _TCLK
                            127 	.globl _EXEN2
                            128 	.globl _TR2
                            129 	.globl _CT2
                            130 	.globl _CPRL2
                            131 	.globl _SM0_1
                            132 	.globl _SM1_1
                            133 	.globl _SM2_1
                            134 	.globl _REN_1
                            135 	.globl _TB8_1
                            136 	.globl _RB8_1
                            137 	.globl _TI_1
                            138 	.globl _RI_1
                            139 	.globl _PS1
                            140 	.globl _PT2
                            141 	.globl _PS0
                            142 	.globl _PT1
                            143 	.globl _PX1
                            144 	.globl _PT0
                            145 	.globl _PX0
                            146 	.globl _IOD7
                            147 	.globl _IOD6
                            148 	.globl _IOD5
                            149 	.globl _IOD4
                            150 	.globl _IOD3
                            151 	.globl _IOD2
                            152 	.globl _IOD1
                            153 	.globl _IOD0
                            154 	.globl _EA
                            155 	.globl _ES1
                            156 	.globl _ET2
                            157 	.globl _ES0
                            158 	.globl _ET1
                            159 	.globl _EX1
                            160 	.globl _ET0
                            161 	.globl _EX0
                            162 	.globl _IOC7
                            163 	.globl _IOC6
                            164 	.globl _IOC5
                            165 	.globl _IOC4
                            166 	.globl _IOC3
                            167 	.globl _IOC2
                            168 	.globl _IOC1
                            169 	.globl _IOC0
                            170 	.globl _SM0_0
                            171 	.globl _SM1_0
                            172 	.globl _SM2_0
                            173 	.globl _REN_0
                            174 	.globl _TB8_0
                            175 	.globl _RB8_0
                            176 	.globl _TI_0
                            177 	.globl _RI_0
                            178 	.globl _IOB7
                            179 	.globl _IOB6
                            180 	.globl _IOB5
                            181 	.globl _IOB4
                            182 	.globl _IOB3
                            183 	.globl _IOB2
                            184 	.globl _IOB1
                            185 	.globl _IOB0
                            186 	.globl _TF1
                            187 	.globl _TR1
                            188 	.globl _TF0
                            189 	.globl _TR0
                            190 	.globl _IE1
                            191 	.globl _IT1
                            192 	.globl _IE0
                            193 	.globl _IT0
                            194 	.globl _IOA7
                            195 	.globl _IOA6
                            196 	.globl _IOA5
                            197 	.globl _IOA4
                            198 	.globl _IOA3
                            199 	.globl _IOA2
                            200 	.globl _IOA1
                            201 	.globl _IOA0
                            202 	.globl _EIP
                            203 	.globl _BREG
                            204 	.globl _EIE
                            205 	.globl _ACC
                            206 	.globl _EICON
                            207 	.globl _PSW
                            208 	.globl _TH2
                            209 	.globl _TL2
                            210 	.globl _RCAP2H
                            211 	.globl _RCAP2L
                            212 	.globl _T2CON
                            213 	.globl _SBUF1
                            214 	.globl _SCON1
                            215 	.globl _GPIFSGLDATLNOX
                            216 	.globl _GPIFSGLDATLX
                            217 	.globl _GPIFSGLDATH
                            218 	.globl _GPIFTRIG
                            219 	.globl _EP01STAT
                            220 	.globl _IP
                            221 	.globl _OEE
                            222 	.globl _OED
                            223 	.globl _OEC
                            224 	.globl _OEB
                            225 	.globl _OEA
                            226 	.globl _IOE
                            227 	.globl _IOD
                            228 	.globl _AUTOPTRSETUP
                            229 	.globl _EP68FIFOFLGS
                            230 	.globl _EP24FIFOFLGS
                            231 	.globl _EP2468STAT
                            232 	.globl _IE
                            233 	.globl _INT4CLR
                            234 	.globl _INT2CLR
                            235 	.globl _IOC
                            236 	.globl _AUTOPTRL2
                            237 	.globl _AUTOPTRH2
                            238 	.globl _AUTOPTRL1
                            239 	.globl _AUTOPTRH1
                            240 	.globl _SBUF0
                            241 	.globl _SCON0
                            242 	.globl __XPAGE
                            243 	.globl _MPAGE
                            244 	.globl _EXIF
                            245 	.globl _IOB
                            246 	.globl _CKCON
                            247 	.globl _TH1
                            248 	.globl _TH0
                            249 	.globl _TL1
                            250 	.globl _TL0
                            251 	.globl _TMOD
                            252 	.globl _TCON
                            253 	.globl _PCON
                            254 	.globl _DPS
                            255 	.globl _DPH1
                            256 	.globl _DPL1
                            257 	.globl _DPH0
                            258 	.globl _DPL0
                            259 	.globl _SP
                            260 	.globl _IOA
                            261 	.globl _ISOFRAME_COUNTER
                            262 	.globl _ep0_vendor_cmd_setup
                            263 	.globl _ep0_prev_setup_request
                            264 	.globl _ep0_payload_transfer
                            265 	.globl _ep0_payload_remaining
                            266 	.globl _SN_STRING
                            267 	.globl _MODULE_RESERVED
                            268 	.globl _INTERFACE_CAPABILITIES
                            269 	.globl _INTERFACE_VERSION
                            270 	.globl _FW_VERSION
                            271 	.globl _PRODUCT_ID
                            272 	.globl _ZTEXID
                            273 	.globl _ZTEX_DESCRIPTOR_VERSION
                            274 	.globl _ZTEX_DESCRIPTOR
                            275 	.globl _OOEA
                            276 	.globl _fpga_conf_initialized
                            277 	.globl _fpga_flash_result
                            278 	.globl _fpga_init_b
                            279 	.globl _fpga_bytes
                            280 	.globl _fpga_checksum
                            281 	.globl _ep0_write_mode
                            282 	.globl _ep0_read_mode
                            283 	.globl _spi_write_sector
                            284 	.globl _spi_need_pp
                            285 	.globl _spi_write_addr_lo
                            286 	.globl _spi_write_addr_hi
                            287 	.globl _spi_buffer
                            288 	.globl _spi_last_cmd
                            289 	.globl _spi_erase_cmd
                            290 	.globl _spi_memtype
                            291 	.globl _spi_device
                            292 	.globl _spi_vendor
                            293 	.globl _flash_ec
                            294 	.globl _flash_sectors
                            295 	.globl _flash_sector_size
                            296 	.globl _flash_enabled
                            297 	.globl _config_data_valid
                            298 	.globl _mac_eeprom_addr
                            299 	.globl _eeprom_write_checksum
                            300 	.globl _eeprom_write_bytes
                            301 	.globl _eeprom_addr
                            302 	.globl _INTVEC_GPIFWF
                            303 	.globl _INTVEC_GPIFDONE
                            304 	.globl _INTVEC_EP8FF
                            305 	.globl _INTVEC_EP6FF
                            306 	.globl _INTVEC_EP2FF
                            307 	.globl _INTVEC_EP8EF
                            308 	.globl _INTVEC_EP6EF
                            309 	.globl _INTVEC_EP4EF
                            310 	.globl _INTVEC_EP2EF
                            311 	.globl _INTVEC_EP8PF
                            312 	.globl _INTVEC_EP6PF
                            313 	.globl _INTVEC_EP4PF
                            314 	.globl _INTVEC_EP2PF
                            315 	.globl _INTVEC_EP8ISOERR
                            316 	.globl _INTVEC_EP6ISOERR
                            317 	.globl _INTVEC_EP4ISOERR
                            318 	.globl _INTVEC_EP2ISOERR
                            319 	.globl _INTVEC_ERRLIMIT
                            320 	.globl _INTVEC_EP8PING
                            321 	.globl _INTVEC_EP6PING
                            322 	.globl _INTVEC_EP4PING
                            323 	.globl _INTVEC_EP2PING
                            324 	.globl _INTVEC_EP1PING
                            325 	.globl _INTVEC_EP0PING
                            326 	.globl _INTVEC_IBN
                            327 	.globl _INTVEC_EP8
                            328 	.globl _INTVEC_EP6
                            329 	.globl _INTVEC_EP4
                            330 	.globl _INTVEC_EP2
                            331 	.globl _INTVEC_EP1OUT
                            332 	.globl _INTVEC_EP1IN
                            333 	.globl _INTVEC_EP0OUT
                            334 	.globl _INTVEC_EP0IN
                            335 	.globl _INTVEC_EP0ACK
                            336 	.globl _INTVEC_HISPEED
                            337 	.globl _INTVEC_USBRESET
                            338 	.globl _INTVEC_SUSPEND
                            339 	.globl _INTVEC_SUTOK
                            340 	.globl _INTVEC_SOF
                            341 	.globl _INTVEC_SUDAV
                            342 	.globl _INT12VEC_IE6
                            343 	.globl _INT11VEC_IE5
                            344 	.globl _INT10VEC_GPIF
                            345 	.globl _INT9VEC_I2C
                            346 	.globl _INT8VEC_USB
                            347 	.globl _INT7VEC_USART1
                            348 	.globl _INT6VEC_RESUME
                            349 	.globl _INT5VEC_T2
                            350 	.globl _INT4VEC_USART0
                            351 	.globl _INT3VEC_T1
                            352 	.globl _INT2VEC_IE1
                            353 	.globl _INT1VEC_T0
                            354 	.globl _INT0VEC_IE0
                            355 	.globl _EP8FIFOBUF
                            356 	.globl _EP6FIFOBUF
                            357 	.globl _EP4FIFOBUF
                            358 	.globl _EP2FIFOBUF
                            359 	.globl _EP1INBUF
                            360 	.globl _EP1OUTBUF
                            361 	.globl _EP0BUF
                            362 	.globl _GPIFABORT
                            363 	.globl _GPIFREADYSTAT
                            364 	.globl _GPIFREADYCFG
                            365 	.globl _XGPIFSGLDATLNOX
                            366 	.globl _XGPIFSGLDATLX
                            367 	.globl _XGPIFSGLDATH
                            368 	.globl _EP8GPIFTRIG
                            369 	.globl _EP8GPIFPFSTOP
                            370 	.globl _EP8GPIFFLGSEL
                            371 	.globl _EP6GPIFTRIG
                            372 	.globl _EP6GPIFPFSTOP
                            373 	.globl _EP6GPIFFLGSEL
                            374 	.globl _EP4GPIFTRIG
                            375 	.globl _EP4GPIFPFSTOP
                            376 	.globl _EP4GPIFFLGSEL
                            377 	.globl _EP2GPIFTRIG
                            378 	.globl _EP2GPIFPFSTOP
                            379 	.globl _EP2GPIFFLGSEL
                            380 	.globl _GPIFTCB0
                            381 	.globl _GPIFTCB1
                            382 	.globl _GPIFTCB2
                            383 	.globl _GPIFTCB3
                            384 	.globl _FLOWSTBHPERIOD
                            385 	.globl _FLOWSTBEDGE
                            386 	.globl _FLOWSTB
                            387 	.globl _FLOWHOLDOFF
                            388 	.globl _FLOWEQ1CTL
                            389 	.globl _FLOWEQ0CTL
                            390 	.globl _FLOWLOGIC
                            391 	.globl _FLOWSTATE
                            392 	.globl _GPIFADRL
                            393 	.globl _GPIFADRH
                            394 	.globl _GPIFCTLCFG
                            395 	.globl _GPIFIDLECTL
                            396 	.globl _GPIFIDLECS
                            397 	.globl _GPIFWFSELECT
                            398 	.globl _wLengthH
                            399 	.globl _wLengthL
                            400 	.globl _wIndexH
                            401 	.globl _wIndexL
                            402 	.globl _wValueH
                            403 	.globl _wValueL
                            404 	.globl _bRequest
                            405 	.globl _bmRequestType
                            406 	.globl _SETUPDAT
                            407 	.globl _SUDPTRCTL
                            408 	.globl _SUDPTRL
                            409 	.globl _SUDPTRH
                            410 	.globl _EP8FIFOBCL
                            411 	.globl _EP8FIFOBCH
                            412 	.globl _EP6FIFOBCL
                            413 	.globl _EP6FIFOBCH
                            414 	.globl _EP4FIFOBCL
                            415 	.globl _EP4FIFOBCH
                            416 	.globl _EP2FIFOBCL
                            417 	.globl _EP2FIFOBCH
                            418 	.globl _EP8FIFOFLGS
                            419 	.globl _EP6FIFOFLGS
                            420 	.globl _EP4FIFOFLGS
                            421 	.globl _EP2FIFOFLGS
                            422 	.globl _EP8CS
                            423 	.globl _EP6CS
                            424 	.globl _EP4CS
                            425 	.globl _EP2CS
                            426 	.globl _EPXCS
                            427 	.globl _EP1INCS
                            428 	.globl _EP1OUTCS
                            429 	.globl _EP0CS
                            430 	.globl _EP8BCL
                            431 	.globl _EP8BCH
                            432 	.globl _EP6BCL
                            433 	.globl _EP6BCH
                            434 	.globl _EP4BCL
                            435 	.globl _EP4BCH
                            436 	.globl _EP2BCL
                            437 	.globl _EP2BCH
                            438 	.globl _EP1INBC
                            439 	.globl _EP1OUTBC
                            440 	.globl _EP0BCL
                            441 	.globl _EP0BCH
                            442 	.globl _FNADDR
                            443 	.globl _MICROFRAME
                            444 	.globl _USBFRAMEL
                            445 	.globl _USBFRAMEH
                            446 	.globl _TOGCTL
                            447 	.globl _WAKEUPCS
                            448 	.globl _SUSPEND
                            449 	.globl _USBCS
                            450 	.globl _UDMACRCQUALIFIER
                            451 	.globl _UDMACRCL
                            452 	.globl _UDMACRCH
                            453 	.globl _EXTAUTODAT2
                            454 	.globl _XAUTODAT2
                            455 	.globl _EXTAUTODAT1
                            456 	.globl _XAUTODAT1
                            457 	.globl _I2CTL
                            458 	.globl _I2DAT
                            459 	.globl _I2CS
                            460 	.globl _PORTECFG
                            461 	.globl _PORTCCFG
                            462 	.globl _PORTACFG
                            463 	.globl _INTSETUP
                            464 	.globl _INT4IVEC
                            465 	.globl _INT2IVEC
                            466 	.globl _CLRERRCNT
                            467 	.globl _ERRCNTLIM
                            468 	.globl _USBERRIRQ
                            469 	.globl _USBERRIE
                            470 	.globl _GPIFIRQ
                            471 	.globl _GPIFIE
                            472 	.globl _EPIRQ
                            473 	.globl _EPIE
                            474 	.globl _USBIRQ
                            475 	.globl _USBIE
                            476 	.globl _NAKIRQ
                            477 	.globl _NAKIE
                            478 	.globl _IBNIRQ
                            479 	.globl _IBNIE
                            480 	.globl _EP8FIFOIRQ
                            481 	.globl _EP8FIFOIE
                            482 	.globl _EP6FIFOIRQ
                            483 	.globl _EP6FIFOIE
                            484 	.globl _EP4FIFOIRQ
                            485 	.globl _EP4FIFOIE
                            486 	.globl _EP2FIFOIRQ
                            487 	.globl _EP2FIFOIE
                            488 	.globl _OUTPKTEND
                            489 	.globl _INPKTEND
                            490 	.globl _EP8ISOINPKTS
                            491 	.globl _EP6ISOINPKTS
                            492 	.globl _EP4ISOINPKTS
                            493 	.globl _EP2ISOINPKTS
                            494 	.globl _EP8FIFOPFL
                            495 	.globl _EP8FIFOPFH
                            496 	.globl _EP6FIFOPFL
                            497 	.globl _EP6FIFOPFH
                            498 	.globl _EP4FIFOPFL
                            499 	.globl _EP4FIFOPFH
                            500 	.globl _EP2FIFOPFL
                            501 	.globl _EP2FIFOPFH
                            502 	.globl _ECC2B2
                            503 	.globl _ECC2B1
                            504 	.globl _ECC2B0
                            505 	.globl _ECC1B2
                            506 	.globl _ECC1B1
                            507 	.globl _ECC1B0
                            508 	.globl _ECCRESET
                            509 	.globl _ECCCFG
                            510 	.globl _EP8AUTOINLENL
                            511 	.globl _EP8AUTOINLENH
                            512 	.globl _EP6AUTOINLENL
                            513 	.globl _EP6AUTOINLENH
                            514 	.globl _EP4AUTOINLENL
                            515 	.globl _EP4AUTOINLENH
                            516 	.globl _EP2AUTOINLENL
                            517 	.globl _EP2AUTOINLENH
                            518 	.globl _EP8FIFOCFG
                            519 	.globl _EP6FIFOCFG
                            520 	.globl _EP4FIFOCFG
                            521 	.globl _EP2FIFOCFG
                            522 	.globl _EP8CFG
                            523 	.globl _EP6CFG
                            524 	.globl _EP4CFG
                            525 	.globl _EP2CFG
                            526 	.globl _EP1INCFG
                            527 	.globl _EP1OUTCFG
                            528 	.globl _GPIFHOLDAMOUNT
                            529 	.globl _REVCTL
                            530 	.globl _REVID
                            531 	.globl _FIFOPINPOLAR
                            532 	.globl _UART230
                            533 	.globl _BPADDRL
                            534 	.globl _BPADDRH
                            535 	.globl _BREAKPT
                            536 	.globl _FIFORESET
                            537 	.globl _PINFLAGSCD
                            538 	.globl _PINFLAGSAB
                            539 	.globl _IFCONFIG
                            540 	.globl _CPUCS
                            541 	.globl _GPCR2
                            542 	.globl _GPIF_WAVE3_DATA
                            543 	.globl _GPIF_WAVE2_DATA
                            544 	.globl _GPIF_WAVE1_DATA
                            545 	.globl _GPIF_WAVE0_DATA
                            546 	.globl _GPIF_WAVE_DATA
                            547 	.globl _flash_write_PARM_2
                            548 	.globl _mac_eeprom_write_PARM_3
                            549 	.globl _mac_eeprom_write_PARM_2
                            550 	.globl _mac_eeprom_read_PARM_3
                            551 	.globl _mac_eeprom_read_PARM_2
                            552 	.globl _eeprom_write_PARM_3
                            553 	.globl _eeprom_write_PARM_2
                            554 	.globl _eeprom_read_PARM_3
                            555 	.globl _eeprom_read_PARM_2
                            556 	.globl _eeprom_select_PARM_3
                            557 	.globl _eeprom_select_PARM_2
                            558 ;--------------------------------------------------------
                            559 ; special function registers
                            560 ;--------------------------------------------------------
                            561 	.area RSEG    (DATA)
                    0080    562 _IOA	=	0x0080
                    0081    563 _SP	=	0x0081
                    0082    564 _DPL0	=	0x0082
                    0083    565 _DPH0	=	0x0083
                    0084    566 _DPL1	=	0x0084
                    0085    567 _DPH1	=	0x0085
                    0086    568 _DPS	=	0x0086
                    0087    569 _PCON	=	0x0087
                    0088    570 _TCON	=	0x0088
                    0089    571 _TMOD	=	0x0089
                    008A    572 _TL0	=	0x008a
                    008B    573 _TL1	=	0x008b
                    008C    574 _TH0	=	0x008c
                    008D    575 _TH1	=	0x008d
                    008E    576 _CKCON	=	0x008e
                    0090    577 _IOB	=	0x0090
                    0091    578 _EXIF	=	0x0091
                    0092    579 _MPAGE	=	0x0092
                    0092    580 __XPAGE	=	0x0092
                    0098    581 _SCON0	=	0x0098
                    0099    582 _SBUF0	=	0x0099
                    009A    583 _AUTOPTRH1	=	0x009a
                    009B    584 _AUTOPTRL1	=	0x009b
                    009D    585 _AUTOPTRH2	=	0x009d
                    009E    586 _AUTOPTRL2	=	0x009e
                    00A0    587 _IOC	=	0x00a0
                    00A1    588 _INT2CLR	=	0x00a1
                    00A2    589 _INT4CLR	=	0x00a2
                    00A8    590 _IE	=	0x00a8
                    00AA    591 _EP2468STAT	=	0x00aa
                    00AB    592 _EP24FIFOFLGS	=	0x00ab
                    00AC    593 _EP68FIFOFLGS	=	0x00ac
                    00AF    594 _AUTOPTRSETUP	=	0x00af
                    00B0    595 _IOD	=	0x00b0
                    00B1    596 _IOE	=	0x00b1
                    00B2    597 _OEA	=	0x00b2
                    00B3    598 _OEB	=	0x00b3
                    00B4    599 _OEC	=	0x00b4
                    00B5    600 _OED	=	0x00b5
                    00B6    601 _OEE	=	0x00b6
                    00B8    602 _IP	=	0x00b8
                    00BA    603 _EP01STAT	=	0x00ba
                    00BB    604 _GPIFTRIG	=	0x00bb
                    00BD    605 _GPIFSGLDATH	=	0x00bd
                    00BE    606 _GPIFSGLDATLX	=	0x00be
                    00BF    607 _GPIFSGLDATLNOX	=	0x00bf
                    00C0    608 _SCON1	=	0x00c0
                    00C1    609 _SBUF1	=	0x00c1
                    00C8    610 _T2CON	=	0x00c8
                    00CA    611 _RCAP2L	=	0x00ca
                    00CB    612 _RCAP2H	=	0x00cb
                    00CC    613 _TL2	=	0x00cc
                    00CD    614 _TH2	=	0x00cd
                    00D0    615 _PSW	=	0x00d0
                    00D8    616 _EICON	=	0x00d8
                    00E0    617 _ACC	=	0x00e0
                    00E8    618 _EIE	=	0x00e8
                    00F0    619 _BREG	=	0x00f0
                    00F8    620 _EIP	=	0x00f8
                            621 ;--------------------------------------------------------
                            622 ; special function bits
                            623 ;--------------------------------------------------------
                            624 	.area RSEG    (DATA)
                    0080    625 _IOA0	=	0x0080
                    0081    626 _IOA1	=	0x0081
                    0082    627 _IOA2	=	0x0082
                    0083    628 _IOA3	=	0x0083
                    0084    629 _IOA4	=	0x0084
                    0085    630 _IOA5	=	0x0085
                    0086    631 _IOA6	=	0x0086
                    0087    632 _IOA7	=	0x0087
                    0088    633 _IT0	=	0x0088
                    0089    634 _IE0	=	0x0089
                    008A    635 _IT1	=	0x008a
                    008B    636 _IE1	=	0x008b
                    008C    637 _TR0	=	0x008c
                    008D    638 _TF0	=	0x008d
                    008E    639 _TR1	=	0x008e
                    008F    640 _TF1	=	0x008f
                    0090    641 _IOB0	=	0x0090
                    0091    642 _IOB1	=	0x0091
                    0092    643 _IOB2	=	0x0092
                    0093    644 _IOB3	=	0x0093
                    0094    645 _IOB4	=	0x0094
                    0095    646 _IOB5	=	0x0095
                    0096    647 _IOB6	=	0x0096
                    0097    648 _IOB7	=	0x0097
                    0098    649 _RI_0	=	0x0098
                    0099    650 _TI_0	=	0x0099
                    009A    651 _RB8_0	=	0x009a
                    009B    652 _TB8_0	=	0x009b
                    009C    653 _REN_0	=	0x009c
                    009D    654 _SM2_0	=	0x009d
                    009E    655 _SM1_0	=	0x009e
                    009F    656 _SM0_0	=	0x009f
                    00A0    657 _IOC0	=	0x00a0
                    00A1    658 _IOC1	=	0x00a1
                    00A2    659 _IOC2	=	0x00a2
                    00A3    660 _IOC3	=	0x00a3
                    00A4    661 _IOC4	=	0x00a4
                    00A5    662 _IOC5	=	0x00a5
                    00A6    663 _IOC6	=	0x00a6
                    00A7    664 _IOC7	=	0x00a7
                    00A8    665 _EX0	=	0x00a8
                    00A9    666 _ET0	=	0x00a9
                    00AA    667 _EX1	=	0x00aa
                    00AB    668 _ET1	=	0x00ab
                    00AC    669 _ES0	=	0x00ac
                    00AD    670 _ET2	=	0x00ad
                    00AE    671 _ES1	=	0x00ae
                    00AF    672 _EA	=	0x00af
                    00B0    673 _IOD0	=	0x00b0
                    00B1    674 _IOD1	=	0x00b1
                    00B2    675 _IOD2	=	0x00b2
                    00B3    676 _IOD3	=	0x00b3
                    00B4    677 _IOD4	=	0x00b4
                    00B5    678 _IOD5	=	0x00b5
                    00B6    679 _IOD6	=	0x00b6
                    00B7    680 _IOD7	=	0x00b7
                    00B8    681 _PX0	=	0x00b8
                    00B9    682 _PT0	=	0x00b9
                    00BA    683 _PX1	=	0x00ba
                    00BB    684 _PT1	=	0x00bb
                    00BC    685 _PS0	=	0x00bc
                    00BD    686 _PT2	=	0x00bd
                    00BE    687 _PS1	=	0x00be
                    00C0    688 _RI_1	=	0x00c0
                    00C1    689 _TI_1	=	0x00c1
                    00C2    690 _RB8_1	=	0x00c2
                    00C3    691 _TB8_1	=	0x00c3
                    00C4    692 _REN_1	=	0x00c4
                    00C5    693 _SM2_1	=	0x00c5
                    00C6    694 _SM1_1	=	0x00c6
                    00C7    695 _SM0_1	=	0x00c7
                    00C8    696 _CPRL2	=	0x00c8
                    00C9    697 _CT2	=	0x00c9
                    00CA    698 _TR2	=	0x00ca
                    00CB    699 _EXEN2	=	0x00cb
                    00CC    700 _TCLK	=	0x00cc
                    00CD    701 _RCLK	=	0x00cd
                    00CE    702 _EXF2	=	0x00ce
                    00CF    703 _TF2	=	0x00cf
                    00D0    704 _PF	=	0x00d0
                    00D1    705 _F1	=	0x00d1
                    00D2    706 _OV	=	0x00d2
                    00D3    707 _RS0	=	0x00d3
                    00D4    708 _RS1	=	0x00d4
                    00D5    709 _F0	=	0x00d5
                    00D6    710 _AC	=	0x00d6
                    00D7    711 _CY	=	0x00d7
                    00DB    712 _INT6	=	0x00db
                    00DC    713 _RESI	=	0x00dc
                    00DD    714 _ERESI	=	0x00dd
                    00DF    715 _SMOD1	=	0x00df
                    00E0    716 _ACC0	=	0x00e0
                    00E1    717 _ACC1	=	0x00e1
                    00E2    718 _ACC2	=	0x00e2
                    00E3    719 _ACC3	=	0x00e3
                    00E4    720 _ACC4	=	0x00e4
                    00E5    721 _ACC5	=	0x00e5
                    00E6    722 _ACC6	=	0x00e6
                    00E7    723 _ACC7	=	0x00e7
                    00E8    724 _EUSB	=	0x00e8
                    00E9    725 _EI2C	=	0x00e9
                    00EA    726 _EIEX4	=	0x00ea
                    00EB    727 _EIEX5	=	0x00eb
                    00EC    728 _EIEX6	=	0x00ec
                    00F0    729 _BREG0	=	0x00f0
                    00F1    730 _BREG1	=	0x00f1
                    00F2    731 _BREG2	=	0x00f2
                    00F3    732 _BREG3	=	0x00f3
                    00F4    733 _BREG4	=	0x00f4
                    00F5    734 _BREG5	=	0x00f5
                    00F6    735 _BREG6	=	0x00f6
                    00F7    736 _BREG7	=	0x00f7
                    00F8    737 _PUSB	=	0x00f8
                    00F9    738 _PI2C	=	0x00f9
                    00FA    739 _EIPX4	=	0x00fa
                    00FB    740 _EIPX5	=	0x00fb
                    00FC    741 _EIPX6	=	0x00fc
                            742 ;--------------------------------------------------------
                            743 ; overlayable register banks
                            744 ;--------------------------------------------------------
                            745 	.area REG_BANK_0	(REL,OVR,DATA)
   0000                     746 	.ds 8
                            747 ;--------------------------------------------------------
                            748 ; overlayable bit register bank
                            749 ;--------------------------------------------------------
                            750 	.area BIT_BANK	(REL,OVR,DATA)
   0020                     751 bits:
   0020                     752 	.ds 1
                    8000    753 	b0 = bits[0]
                    8100    754 	b1 = bits[1]
                    8200    755 	b2 = bits[2]
                    8300    756 	b3 = bits[3]
                    8400    757 	b4 = bits[4]
                    8500    758 	b5 = bits[5]
                    8600    759 	b6 = bits[6]
                    8700    760 	b7 = bits[7]
                            761 ;--------------------------------------------------------
                            762 ; internal ram data
                            763 ;--------------------------------------------------------
                            764 	.area DSEG    (DATA)
   0008                     765 _eeprom_select_PARM_2:
   0008                     766 	.ds 1
   0009                     767 _eeprom_select_PARM_3:
   0009                     768 	.ds 1
   000A                     769 _eeprom_read_PARM_2:
   000A                     770 	.ds 2
   000C                     771 _eeprom_read_PARM_3:
   000C                     772 	.ds 1
   000D                     773 _eeprom_write_PARM_2:
   000D                     774 	.ds 2
   000F                     775 _eeprom_write_PARM_3:
   000F                     776 	.ds 1
   0010                     777 _mac_eeprom_read_PARM_2:
   0010                     778 	.ds 1
   0011                     779 _mac_eeprom_read_PARM_3:
   0011                     780 	.ds 1
   0012                     781 _mac_eeprom_write_PARM_2:
   0012                     782 	.ds 1
   0013                     783 _mac_eeprom_write_PARM_3:
   0013                     784 	.ds 1
   0014                     785 _flash_write_PARM_2:
   0014                     786 	.ds 1
   0015                     787 _fpga_send_ep0_oOEC_1_1:
   0015                     788 	.ds 1
                            789 ;--------------------------------------------------------
                            790 ; overlayable items in internal ram 
                            791 ;--------------------------------------------------------
                            792 	.area	OSEG    (OVR,DATA)
                            793 	.area	OSEG    (OVR,DATA)
                            794 	.area	OSEG    (OVR,DATA)
                            795 	.area	OSEG    (OVR,DATA)
                            796 	.area	OSEG    (OVR,DATA)
                            797 	.area	OSEG    (OVR,DATA)
                            798 	.area	OSEG    (OVR,DATA)
                            799 	.area	OSEG    (OVR,DATA)
   0016                     800 _flash_read_PARM_2::
   0016                     801 	.ds 1
                            802 	.area	OSEG    (OVR,DATA)
                            803 	.area	OSEG    (OVR,DATA)
   0016                     804 _spi_write_PARM_2::
   0016                     805 	.ds 1
                            806 	.area	OSEG    (OVR,DATA)
   0016                     807 _sendStringDescriptor_PARM_2::
   0016                     808 	.ds 1
   0017                     809 _sendStringDescriptor_PARM_3::
   0017                     810 	.ds 1
                            811 ;--------------------------------------------------------
                            812 ; Stack segment in internal ram 
                            813 ;--------------------------------------------------------
                            814 	.area	SSEG	(DATA)
   0021                     815 __start__stack:
   0021                     816 	.ds	1
                            817 
                            818 ;--------------------------------------------------------
                            819 ; indirectly addressable internal ram data
                            820 ;--------------------------------------------------------
                            821 	.area ISEG    (DATA)
                            822 ;--------------------------------------------------------
                            823 ; absolute internal ram data
                            824 ;--------------------------------------------------------
                            825 	.area IABS    (ABS,DATA)
                            826 	.area IABS    (ABS,DATA)
                            827 ;--------------------------------------------------------
                            828 ; bit data
                            829 ;--------------------------------------------------------
                            830 	.area BSEG    (BIT)
                            831 ;--------------------------------------------------------
                            832 ; paged external ram data
                            833 ;--------------------------------------------------------
                            834 	.area PSEG    (PAG,XDATA)
                            835 ;--------------------------------------------------------
                            836 ; external ram data
                            837 ;--------------------------------------------------------
                            838 	.area XSEG    (XDATA)
                    E400    839 _GPIF_WAVE_DATA	=	0xe400
                    E400    840 _GPIF_WAVE0_DATA	=	0xe400
                    E420    841 _GPIF_WAVE1_DATA	=	0xe420
                    E440    842 _GPIF_WAVE2_DATA	=	0xe440
                    E460    843 _GPIF_WAVE3_DATA	=	0xe460
                    E50D    844 _GPCR2	=	0xe50d
                    E600    845 _CPUCS	=	0xe600
                    E601    846 _IFCONFIG	=	0xe601
                    E602    847 _PINFLAGSAB	=	0xe602
                    E603    848 _PINFLAGSCD	=	0xe603
                    E604    849 _FIFORESET	=	0xe604
                    E605    850 _BREAKPT	=	0xe605
                    E606    851 _BPADDRH	=	0xe606
                    E607    852 _BPADDRL	=	0xe607
                    E608    853 _UART230	=	0xe608
                    E609    854 _FIFOPINPOLAR	=	0xe609
                    E60A    855 _REVID	=	0xe60a
                    E60B    856 _REVCTL	=	0xe60b
                    E60C    857 _GPIFHOLDAMOUNT	=	0xe60c
                    E610    858 _EP1OUTCFG	=	0xe610
                    E611    859 _EP1INCFG	=	0xe611
                    E612    860 _EP2CFG	=	0xe612
                    E613    861 _EP4CFG	=	0xe613
                    E614    862 _EP6CFG	=	0xe614
                    E615    863 _EP8CFG	=	0xe615
                    E618    864 _EP2FIFOCFG	=	0xe618
                    E619    865 _EP4FIFOCFG	=	0xe619
                    E61A    866 _EP6FIFOCFG	=	0xe61a
                    E61B    867 _EP8FIFOCFG	=	0xe61b
                    E620    868 _EP2AUTOINLENH	=	0xe620
                    E621    869 _EP2AUTOINLENL	=	0xe621
                    E622    870 _EP4AUTOINLENH	=	0xe622
                    E623    871 _EP4AUTOINLENL	=	0xe623
                    E624    872 _EP6AUTOINLENH	=	0xe624
                    E625    873 _EP6AUTOINLENL	=	0xe625
                    E626    874 _EP8AUTOINLENH	=	0xe626
                    E627    875 _EP8AUTOINLENL	=	0xe627
                    E628    876 _ECCCFG	=	0xe628
                    E629    877 _ECCRESET	=	0xe629
                    E62A    878 _ECC1B0	=	0xe62a
                    E62B    879 _ECC1B1	=	0xe62b
                    E62C    880 _ECC1B2	=	0xe62c
                    E62D    881 _ECC2B0	=	0xe62d
                    E62E    882 _ECC2B1	=	0xe62e
                    E62F    883 _ECC2B2	=	0xe62f
                    E630    884 _EP2FIFOPFH	=	0xe630
                    E631    885 _EP2FIFOPFL	=	0xe631
                    E632    886 _EP4FIFOPFH	=	0xe632
                    E633    887 _EP4FIFOPFL	=	0xe633
                    E634    888 _EP6FIFOPFH	=	0xe634
                    E635    889 _EP6FIFOPFL	=	0xe635
                    E636    890 _EP8FIFOPFH	=	0xe636
                    E637    891 _EP8FIFOPFL	=	0xe637
                    E640    892 _EP2ISOINPKTS	=	0xe640
                    E641    893 _EP4ISOINPKTS	=	0xe641
                    E642    894 _EP6ISOINPKTS	=	0xe642
                    E643    895 _EP8ISOINPKTS	=	0xe643
                    E648    896 _INPKTEND	=	0xe648
                    E649    897 _OUTPKTEND	=	0xe649
                    E650    898 _EP2FIFOIE	=	0xe650
                    E651    899 _EP2FIFOIRQ	=	0xe651
                    E652    900 _EP4FIFOIE	=	0xe652
                    E653    901 _EP4FIFOIRQ	=	0xe653
                    E654    902 _EP6FIFOIE	=	0xe654
                    E655    903 _EP6FIFOIRQ	=	0xe655
                    E656    904 _EP8FIFOIE	=	0xe656
                    E657    905 _EP8FIFOIRQ	=	0xe657
                    E658    906 _IBNIE	=	0xe658
                    E659    907 _IBNIRQ	=	0xe659
                    E65A    908 _NAKIE	=	0xe65a
                    E65B    909 _NAKIRQ	=	0xe65b
                    E65C    910 _USBIE	=	0xe65c
                    E65D    911 _USBIRQ	=	0xe65d
                    E65E    912 _EPIE	=	0xe65e
                    E65F    913 _EPIRQ	=	0xe65f
                    E660    914 _GPIFIE	=	0xe660
                    E661    915 _GPIFIRQ	=	0xe661
                    E662    916 _USBERRIE	=	0xe662
                    E663    917 _USBERRIRQ	=	0xe663
                    E664    918 _ERRCNTLIM	=	0xe664
                    E665    919 _CLRERRCNT	=	0xe665
                    E666    920 _INT2IVEC	=	0xe666
                    E667    921 _INT4IVEC	=	0xe667
                    E668    922 _INTSETUP	=	0xe668
                    E670    923 _PORTACFG	=	0xe670
                    E671    924 _PORTCCFG	=	0xe671
                    E672    925 _PORTECFG	=	0xe672
                    E678    926 _I2CS	=	0xe678
                    E679    927 _I2DAT	=	0xe679
                    E67A    928 _I2CTL	=	0xe67a
                    E67B    929 _XAUTODAT1	=	0xe67b
                    E67B    930 _EXTAUTODAT1	=	0xe67b
                    E67C    931 _XAUTODAT2	=	0xe67c
                    E67C    932 _EXTAUTODAT2	=	0xe67c
                    E67D    933 _UDMACRCH	=	0xe67d
                    E67E    934 _UDMACRCL	=	0xe67e
                    E67F    935 _UDMACRCQUALIFIER	=	0xe67f
                    E680    936 _USBCS	=	0xe680
                    E681    937 _SUSPEND	=	0xe681
                    E682    938 _WAKEUPCS	=	0xe682
                    E683    939 _TOGCTL	=	0xe683
                    E684    940 _USBFRAMEH	=	0xe684
                    E685    941 _USBFRAMEL	=	0xe685
                    E686    942 _MICROFRAME	=	0xe686
                    E687    943 _FNADDR	=	0xe687
                    E68A    944 _EP0BCH	=	0xe68a
                    E68B    945 _EP0BCL	=	0xe68b
                    E68D    946 _EP1OUTBC	=	0xe68d
                    E68F    947 _EP1INBC	=	0xe68f
                    E690    948 _EP2BCH	=	0xe690
                    E691    949 _EP2BCL	=	0xe691
                    E694    950 _EP4BCH	=	0xe694
                    E695    951 _EP4BCL	=	0xe695
                    E698    952 _EP6BCH	=	0xe698
                    E699    953 _EP6BCL	=	0xe699
                    E69C    954 _EP8BCH	=	0xe69c
                    E69D    955 _EP8BCL	=	0xe69d
                    E6A0    956 _EP0CS	=	0xe6a0
                    E6A1    957 _EP1OUTCS	=	0xe6a1
                    E6A2    958 _EP1INCS	=	0xe6a2
                    E6A3    959 _EPXCS	=	0xe6a3
                    E6A3    960 _EP2CS	=	0xe6a3
                    E6A4    961 _EP4CS	=	0xe6a4
                    E6A5    962 _EP6CS	=	0xe6a5
                    E6A6    963 _EP8CS	=	0xe6a6
                    E6A7    964 _EP2FIFOFLGS	=	0xe6a7
                    E6A8    965 _EP4FIFOFLGS	=	0xe6a8
                    E6A9    966 _EP6FIFOFLGS	=	0xe6a9
                    E6AA    967 _EP8FIFOFLGS	=	0xe6aa
                    E6AB    968 _EP2FIFOBCH	=	0xe6ab
                    E6AC    969 _EP2FIFOBCL	=	0xe6ac
                    E6AD    970 _EP4FIFOBCH	=	0xe6ad
                    E6AE    971 _EP4FIFOBCL	=	0xe6ae
                    E6AF    972 _EP6FIFOBCH	=	0xe6af
                    E6B0    973 _EP6FIFOBCL	=	0xe6b0
                    E6B1    974 _EP8FIFOBCH	=	0xe6b1
                    E6B2    975 _EP8FIFOBCL	=	0xe6b2
                    E6B3    976 _SUDPTRH	=	0xe6b3
                    E6B4    977 _SUDPTRL	=	0xe6b4
                    E6B5    978 _SUDPTRCTL	=	0xe6b5
                    E6B8    979 _SETUPDAT	=	0xe6b8
                    E6B8    980 _bmRequestType	=	0xe6b8
                    E6B9    981 _bRequest	=	0xe6b9
                    E6BA    982 _wValueL	=	0xe6ba
                    E6BB    983 _wValueH	=	0xe6bb
                    E6BC    984 _wIndexL	=	0xe6bc
                    E6BD    985 _wIndexH	=	0xe6bd
                    E6BE    986 _wLengthL	=	0xe6be
                    E6BF    987 _wLengthH	=	0xe6bf
                    E6C0    988 _GPIFWFSELECT	=	0xe6c0
                    E6C1    989 _GPIFIDLECS	=	0xe6c1
                    E6C2    990 _GPIFIDLECTL	=	0xe6c2
                    E6C3    991 _GPIFCTLCFG	=	0xe6c3
                    E6C4    992 _GPIFADRH	=	0xe6c4
                    E6C5    993 _GPIFADRL	=	0xe6c5
                    E6C6    994 _FLOWSTATE	=	0xe6c6
                    E6C7    995 _FLOWLOGIC	=	0xe6c7
                    E6C8    996 _FLOWEQ0CTL	=	0xe6c8
                    E6C9    997 _FLOWEQ1CTL	=	0xe6c9
                    E6CA    998 _FLOWHOLDOFF	=	0xe6ca
                    E6CB    999 _FLOWSTB	=	0xe6cb
                    E6CC   1000 _FLOWSTBEDGE	=	0xe6cc
                    E6CD   1001 _FLOWSTBHPERIOD	=	0xe6cd
                    E6CE   1002 _GPIFTCB3	=	0xe6ce
                    E6CF   1003 _GPIFTCB2	=	0xe6cf
                    E6D0   1004 _GPIFTCB1	=	0xe6d0
                    E6D1   1005 _GPIFTCB0	=	0xe6d1
                    E6D2   1006 _EP2GPIFFLGSEL	=	0xe6d2
                    E6D3   1007 _EP2GPIFPFSTOP	=	0xe6d3
                    E6D4   1008 _EP2GPIFTRIG	=	0xe6d4
                    E6DA   1009 _EP4GPIFFLGSEL	=	0xe6da
                    E6DB   1010 _EP4GPIFPFSTOP	=	0xe6db
                    E6DC   1011 _EP4GPIFTRIG	=	0xe6dc
                    E6E2   1012 _EP6GPIFFLGSEL	=	0xe6e2
                    E6E3   1013 _EP6GPIFPFSTOP	=	0xe6e3
                    E6E4   1014 _EP6GPIFTRIG	=	0xe6e4
                    E6EA   1015 _EP8GPIFFLGSEL	=	0xe6ea
                    E6EB   1016 _EP8GPIFPFSTOP	=	0xe6eb
                    E6EC   1017 _EP8GPIFTRIG	=	0xe6ec
                    E6F0   1018 _XGPIFSGLDATH	=	0xe6f0
                    E6F1   1019 _XGPIFSGLDATLX	=	0xe6f1
                    E6F2   1020 _XGPIFSGLDATLNOX	=	0xe6f2
                    E6F3   1021 _GPIFREADYCFG	=	0xe6f3
                    E6F4   1022 _GPIFREADYSTAT	=	0xe6f4
                    E6F5   1023 _GPIFABORT	=	0xe6f5
                    E740   1024 _EP0BUF	=	0xe740
                    E780   1025 _EP1OUTBUF	=	0xe780
                    E7C0   1026 _EP1INBUF	=	0xe7c0
                    F000   1027 _EP2FIFOBUF	=	0xf000
                    F400   1028 _EP4FIFOBUF	=	0xf400
                    F800   1029 _EP6FIFOBUF	=	0xf800
                    FC00   1030 _EP8FIFOBUF	=	0xfc00
                    0003   1031 _INT0VEC_IE0	=	0x0003
                    000B   1032 _INT1VEC_T0	=	0x000b
                    0013   1033 _INT2VEC_IE1	=	0x0013
                    001B   1034 _INT3VEC_T1	=	0x001b
                    0023   1035 _INT4VEC_USART0	=	0x0023
                    002B   1036 _INT5VEC_T2	=	0x002b
                    0033   1037 _INT6VEC_RESUME	=	0x0033
                    003B   1038 _INT7VEC_USART1	=	0x003b
                    0043   1039 _INT8VEC_USB	=	0x0043
                    004B   1040 _INT9VEC_I2C	=	0x004b
                    0053   1041 _INT10VEC_GPIF	=	0x0053
                    005B   1042 _INT11VEC_IE5	=	0x005b
                    0063   1043 _INT12VEC_IE6	=	0x0063
                    0100   1044 _INTVEC_SUDAV	=	0x0100
                    0104   1045 _INTVEC_SOF	=	0x0104
                    0108   1046 _INTVEC_SUTOK	=	0x0108
                    010C   1047 _INTVEC_SUSPEND	=	0x010c
                    0110   1048 _INTVEC_USBRESET	=	0x0110
                    0114   1049 _INTVEC_HISPEED	=	0x0114
                    0118   1050 _INTVEC_EP0ACK	=	0x0118
                    0120   1051 _INTVEC_EP0IN	=	0x0120
                    0124   1052 _INTVEC_EP0OUT	=	0x0124
                    0128   1053 _INTVEC_EP1IN	=	0x0128
                    012C   1054 _INTVEC_EP1OUT	=	0x012c
                    0130   1055 _INTVEC_EP2	=	0x0130
                    0134   1056 _INTVEC_EP4	=	0x0134
                    0138   1057 _INTVEC_EP6	=	0x0138
                    013C   1058 _INTVEC_EP8	=	0x013c
                    0140   1059 _INTVEC_IBN	=	0x0140
                    0148   1060 _INTVEC_EP0PING	=	0x0148
                    014C   1061 _INTVEC_EP1PING	=	0x014c
                    0150   1062 _INTVEC_EP2PING	=	0x0150
                    0154   1063 _INTVEC_EP4PING	=	0x0154
                    0158   1064 _INTVEC_EP6PING	=	0x0158
                    015C   1065 _INTVEC_EP8PING	=	0x015c
                    0160   1066 _INTVEC_ERRLIMIT	=	0x0160
                    0170   1067 _INTVEC_EP2ISOERR	=	0x0170
                    0174   1068 _INTVEC_EP4ISOERR	=	0x0174
                    0178   1069 _INTVEC_EP6ISOERR	=	0x0178
                    017C   1070 _INTVEC_EP8ISOERR	=	0x017c
                    0180   1071 _INTVEC_EP2PF	=	0x0180
                    0184   1072 _INTVEC_EP4PF	=	0x0184
                    0188   1073 _INTVEC_EP6PF	=	0x0188
                    018C   1074 _INTVEC_EP8PF	=	0x018c
                    0190   1075 _INTVEC_EP2EF	=	0x0190
                    0194   1076 _INTVEC_EP4EF	=	0x0194
                    0198   1077 _INTVEC_EP6EF	=	0x0198
                    019C   1078 _INTVEC_EP8EF	=	0x019c
                    01A0   1079 _INTVEC_EP2FF	=	0x01a0
                    01A8   1080 _INTVEC_EP6FF	=	0x01a8
                    01AC   1081 _INTVEC_EP8FF	=	0x01ac
                    01B0   1082 _INTVEC_GPIFDONE	=	0x01b0
                    01B4   1083 _INTVEC_GPIFWF	=	0x01b4
   3A00                    1084 _eeprom_addr::
   3A00                    1085 	.ds 2
   3A02                    1086 _eeprom_write_bytes::
   3A02                    1087 	.ds 2
   3A04                    1088 _eeprom_write_checksum::
   3A04                    1089 	.ds 1
   3A05                    1090 _mac_eeprom_addr::
   3A05                    1091 	.ds 1
   3A06                    1092 _config_data_valid::
   3A06                    1093 	.ds 1
   3A07                    1094 _flash_enabled::
   3A07                    1095 	.ds 1
   3A08                    1096 _flash_sector_size::
   3A08                    1097 	.ds 2
   3A0A                    1098 _flash_sectors::
   3A0A                    1099 	.ds 4
   3A0E                    1100 _flash_ec::
   3A0E                    1101 	.ds 1
   3A0F                    1102 _spi_vendor::
   3A0F                    1103 	.ds 1
   3A10                    1104 _spi_device::
   3A10                    1105 	.ds 1
   3A11                    1106 _spi_memtype::
   3A11                    1107 	.ds 1
   3A12                    1108 _spi_erase_cmd::
   3A12                    1109 	.ds 1
   3A13                    1110 _spi_last_cmd::
   3A13                    1111 	.ds 1
   3A14                    1112 _spi_buffer::
   3A14                    1113 	.ds 4
   3A18                    1114 _spi_write_addr_hi::
   3A18                    1115 	.ds 2
   3A1A                    1116 _spi_write_addr_lo::
   3A1A                    1117 	.ds 1
   3A1B                    1118 _spi_need_pp::
   3A1B                    1119 	.ds 1
   3A1C                    1120 _spi_write_sector::
   3A1C                    1121 	.ds 2
   3A1E                    1122 _ep0_read_mode::
   3A1E                    1123 	.ds 1
   3A1F                    1124 _ep0_write_mode::
   3A1F                    1125 	.ds 1
   3A20                    1126 _fpga_checksum::
   3A20                    1127 	.ds 1
   3A21                    1128 _fpga_bytes::
   3A21                    1129 	.ds 4
   3A25                    1130 _fpga_init_b::
   3A25                    1131 	.ds 1
   3A26                    1132 _fpga_flash_result::
   3A26                    1133 	.ds 1
   3A27                    1134 _fpga_conf_initialized::
   3A27                    1135 	.ds 1
   3A28                    1136 _OOEA::
   3A28                    1137 	.ds 1
   3A29                    1138 _fpga_first_free_sector_buf_1_1:
   3A29                    1139 	.ds 4
   3A2D                    1140 _fpga_configure_from_flash_init_buf_1_1:
   3A2D                    1141 	.ds 4
                    006C   1142 _ZTEX_DESCRIPTOR	=	0x006c
                    006D   1143 _ZTEX_DESCRIPTOR_VERSION	=	0x006d
                    006E   1144 _ZTEXID	=	0x006e
                    0072   1145 _PRODUCT_ID	=	0x0072
                    0076   1146 _FW_VERSION	=	0x0076
                    0077   1147 _INTERFACE_VERSION	=	0x0077
                    0078   1148 _INTERFACE_CAPABILITIES	=	0x0078
                    007E   1149 _MODULE_RESERVED	=	0x007e
                    008A   1150 _SN_STRING	=	0x008a
   3A31                    1151 _mac_eeprom_init_buf_1_1:
   3A31                    1152 	.ds 5
                           1153 ;--------------------------------------------------------
                           1154 ; absolute external ram data
                           1155 ;--------------------------------------------------------
                           1156 	.area XABS    (ABS,XDATA)
                           1157 ;--------------------------------------------------------
                           1158 ; external initialized ram data
                           1159 ;--------------------------------------------------------
                           1160 	.area XISEG   (XDATA)
   3A36                    1161 _ep0_payload_remaining::
   3A36                    1162 	.ds 2
   3A38                    1163 _ep0_payload_transfer::
   3A38                    1164 	.ds 1
   3A39                    1165 _ep0_prev_setup_request::
   3A39                    1166 	.ds 1
   3A3A                    1167 _ep0_vendor_cmd_setup::
   3A3A                    1168 	.ds 1
   3A3B                    1169 _ISOFRAME_COUNTER::
   3A3B                    1170 	.ds 8
                           1171 	.area HOME    (CODE)
                           1172 	.area GSINIT0 (CODE)
                           1173 	.area GSINIT1 (CODE)
                           1174 	.area GSINIT2 (CODE)
                           1175 	.area GSINIT3 (CODE)
                           1176 	.area GSINIT4 (CODE)
                           1177 	.area GSINIT5 (CODE)
                           1178 	.area GSINIT  (CODE)
                           1179 	.area GSFINAL (CODE)
                           1180 	.area CSEG    (CODE)
                           1181 ;--------------------------------------------------------
                           1182 ; interrupt vector 
                           1183 ;--------------------------------------------------------
                           1184 	.area HOME    (CODE)
   0200                    1185 __interrupt_vect:
   0200 02 02 08           1186 	ljmp	__sdcc_gsinit_startup
                           1187 ;--------------------------------------------------------
                           1188 ; global & static initialisations
                           1189 ;--------------------------------------------------------
                           1190 	.area HOME    (CODE)
                           1191 	.area GSINIT  (CODE)
                           1192 	.area GSFINAL (CODE)
                           1193 	.area GSINIT  (CODE)
                           1194 	.globl __sdcc_gsinit_startup
                           1195 	.globl __sdcc_program_startup
                           1196 	.globl __start__stack
                           1197 	.globl __mcs51_genXINIT
                           1198 	.globl __mcs51_genXRAMCLEAR
                           1199 	.globl __mcs51_genRAMCLEAR
                           1200 	.area GSFINAL (CODE)
   0261 02 02 03           1201 	ljmp	__sdcc_program_startup
                           1202 ;--------------------------------------------------------
                           1203 ; Home
                           1204 ;--------------------------------------------------------
                           1205 	.area HOME    (CODE)
                           1206 	.area HOME    (CODE)
   0203                    1207 __sdcc_program_startup:
   0203 12 1E 39           1208 	lcall	_main
                           1209 ;	return from main will lock up
   0206 80 FE              1210 	sjmp .
                           1211 ;--------------------------------------------------------
                           1212 ; code
                           1213 ;--------------------------------------------------------
                           1214 	.area CSEG    (CODE)
                           1215 ;------------------------------------------------------------
                           1216 ;Allocation info for local variables in function 'abscode_intvec'
                           1217 ;------------------------------------------------------------
                           1218 ;------------------------------------------------------------
                           1219 ;	../../include/ezintavecs.h:92: void abscode_intvec()// _naked
                           1220 ;	-----------------------------------------
                           1221 ;	 function abscode_intvec
                           1222 ;	-----------------------------------------
   0264                    1223 _abscode_intvec:
                    0002   1224 	ar2 = 0x02
                    0003   1225 	ar3 = 0x03
                    0004   1226 	ar4 = 0x04
                    0005   1227 	ar5 = 0x05
                    0006   1228 	ar6 = 0x06
                    0007   1229 	ar7 = 0x07
                    0000   1230 	ar0 = 0x00
                    0001   1231 	ar1 = 0x01
                           1232 ;	../../include/ezintavecs.h:317: ERROR: no line number 317 in file ../../include/ezintavecs.h
                           1233 	
                           1234 	    .area ABSCODE (ABS,CODE)
   0000                    1235 	    .org 0x0000
   0000                    1236 	ENTRY:
   0000 02 02 00           1237 	 ljmp #0x0200
                           1238 ;	# 94 "../../include/ezintavecs.h"
   0003                    1239 	    .org 0x0003
                           1240 ;	# 34 "../../include/ezintavecs.h"
   0003 32                 1241 	 reti
                           1242 ;	# 94 "../../include/ezintavecs.h"
   000B                    1243 	    .org 0x000b
                           1244 ;	# 35 "../../include/ezintavecs.h"
   000B 32                 1245 	 reti
                           1246 ;	# 94 "../../include/ezintavecs.h"
   0013                    1247 	    .org 0x0013
                           1248 ;	# 36 "../../include/ezintavecs.h"
   0013 32                 1249 	 reti
                           1250 ;	# 94 "../../include/ezintavecs.h"
   001B                    1251 	    .org 0x001b
                           1252 ;	# 37 "../../include/ezintavecs.h"
   001B 32                 1253 	 reti
                           1254 ;	# 94 "../../include/ezintavecs.h"
   0023                    1255 	    .org 0x0023
                           1256 ;	# 38 "../../include/ezintavecs.h"
   0023 32                 1257 	 reti
                           1258 ;	# 94 "../../include/ezintavecs.h"
   002B                    1259 	    .org 0x002b
                           1260 ;	# 39 "../../include/ezintavecs.h"
   002B 32                 1261 	 reti
                           1262 ;	# 94 "../../include/ezintavecs.h"
   0033                    1263 	    .org 0x0033
                           1264 ;	# 40 "../../include/ezintavecs.h"
   0033 32                 1265 	 reti
                           1266 ;	# 94 "../../include/ezintavecs.h"
   003B                    1267 	    .org 0x003b
                           1268 ;	# 41 "../../include/ezintavecs.h"
   003B 32                 1269 	 reti
                           1270 ;	# 94 "../../include/ezintavecs.h"
   0043                    1271 	    .org 0x0043
                           1272 ;	# 42 "../../include/ezintavecs.h"
   0043 32                 1273 	 reti
                           1274 ;	# 94 "../../include/ezintavecs.h"
   004B                    1275 	    .org 0x004b
                           1276 ;	# 43 "../../include/ezintavecs.h"
   004B 32                 1277 	 reti
                           1278 ;	# 94 "../../include/ezintavecs.h"
   0053                    1279 	    .org 0x0053
                           1280 ;	# 44 "../../include/ezintavecs.h"
   0053 32                 1281 	 reti
                           1282 ;	# 94 "../../include/ezintavecs.h"
   005B                    1283 	    .org 0x005b
                           1284 ;	# 45 "../../include/ezintavecs.h"
   005B 32                 1285 	 reti
                           1286 ;	# 94 "../../include/ezintavecs.h"
   0063                    1287 	    .org 0x0063
                           1288 ;	# 46 "../../include/ezintavecs.h"
   0063 32                 1289 	 reti
                           1290 ;	# 94 "../../include/ezintavecs.h"
   0100                    1291 	    .org 0x0100
                           1292 ;	# 47 "../../include/ezintavecs.h"
   0100 32                 1293 	 reti
                           1294 ;	# 94 "../../include/ezintavecs.h"
   0104                    1295 	    .org 0x0104
                           1296 ;	# 48 "../../include/ezintavecs.h"
   0104 32                 1297 	 reti
                           1298 ;	# 94 "../../include/ezintavecs.h"
   0108                    1299 	    .org 0x0108
                           1300 ;	# 49 "../../include/ezintavecs.h"
   0108 32                 1301 	 reti
                           1302 ;	# 94 "../../include/ezintavecs.h"
   010C                    1303 	    .org 0x010C
                           1304 ;	# 50 "../../include/ezintavecs.h"
   010C 32                 1305 	 reti
                           1306 ;	# 94 "../../include/ezintavecs.h"
   0110                    1307 	    .org 0x0110
                           1308 ;	# 51 "../../include/ezintavecs.h"
   0110 32                 1309 	 reti
                           1310 ;	# 94 "../../include/ezintavecs.h"
   0114                    1311 	    .org 0x0114
                           1312 ;	# 52 "../../include/ezintavecs.h"
   0114 32                 1313 	 reti
                           1314 ;	# 94 "../../include/ezintavecs.h"
   0118                    1315 	    .org 0x0118
                           1316 ;	# 53 "../../include/ezintavecs.h"
   0118 32                 1317 	 reti
                           1318 ;	# 94 "../../include/ezintavecs.h"
   0120                    1319 	    .org 0x0120
                           1320 ;	# 54 "../../include/ezintavecs.h"
   0120 32                 1321 	 reti
                           1322 ;	# 94 "../../include/ezintavecs.h"
   0124                    1323 	    .org 0x0124
                           1324 ;	# 55 "../../include/ezintavecs.h"
   0124 32                 1325 	 reti
                           1326 ;	# 94 "../../include/ezintavecs.h"
   0128                    1327 	    .org 0x0128
                           1328 ;	# 56 "../../include/ezintavecs.h"
   0128 32                 1329 	 reti
                           1330 ;	# 94 "../../include/ezintavecs.h"
   012C                    1331 	    .org 0x012C
                           1332 ;	# 57 "../../include/ezintavecs.h"
   012C 32                 1333 	 reti
                           1334 ;	# 94 "../../include/ezintavecs.h"
   0130                    1335 	    .org 0x0130
                           1336 ;	# 58 "../../include/ezintavecs.h"
   0130 32                 1337 	 reti
                           1338 ;	# 94 "../../include/ezintavecs.h"
   0134                    1339 	    .org 0x0134
                           1340 ;	# 59 "../../include/ezintavecs.h"
   0134 32                 1341 	 reti
                           1342 ;	# 94 "../../include/ezintavecs.h"
   0138                    1343 	    .org 0x0138
                           1344 ;	# 60 "../../include/ezintavecs.h"
   0138 32                 1345 	 reti
                           1346 ;	# 94 "../../include/ezintavecs.h"
   013C                    1347 	    .org 0x013C
                           1348 ;	# 61 "../../include/ezintavecs.h"
   013C 32                 1349 	 reti
                           1350 ;	# 94 "../../include/ezintavecs.h"
   0140                    1351 	    .org 0x0140
                           1352 ;	# 62 "../../include/ezintavecs.h"
   0140 32                 1353 	 reti
                           1354 ;	# 94 "../../include/ezintavecs.h"
   0148                    1355 	    .org 0x0148
                           1356 ;	# 63 "../../include/ezintavecs.h"
   0148 32                 1357 	 reti
                           1358 ;	# 94 "../../include/ezintavecs.h"
   014C                    1359 	    .org 0x014C
                           1360 ;	# 64 "../../include/ezintavecs.h"
   014C 32                 1361 	 reti
                           1362 ;	# 94 "../../include/ezintavecs.h"
   0150                    1363 	    .org 0x0150
                           1364 ;	# 65 "../../include/ezintavecs.h"
   0150 32                 1365 	 reti
                           1366 ;	# 94 "../../include/ezintavecs.h"
   0154                    1367 	    .org 0x0154
                           1368 ;	# 66 "../../include/ezintavecs.h"
   0154 32                 1369 	 reti
                           1370 ;	# 94 "../../include/ezintavecs.h"
   0158                    1371 	    .org 0x0158
                           1372 ;	# 67 "../../include/ezintavecs.h"
   0158 32                 1373 	 reti
                           1374 ;	# 94 "../../include/ezintavecs.h"
   015C                    1375 	    .org 0x015C
                           1376 ;	# 68 "../../include/ezintavecs.h"
   015C 32                 1377 	 reti
                           1378 ;	# 94 "../../include/ezintavecs.h"
   0160                    1379 	    .org 0x0160
                           1380 ;	# 69 "../../include/ezintavecs.h"
   0160 32                 1381 	 reti
                           1382 ;	# 94 "../../include/ezintavecs.h"
   0170                    1383 	    .org 0x0170
                           1384 ;	# 70 "../../include/ezintavecs.h"
   0170 32                 1385 	 reti
                           1386 ;	# 94 "../../include/ezintavecs.h"
   0174                    1387 	    .org 0x0174
                           1388 ;	# 71 "../../include/ezintavecs.h"
   0174 32                 1389 	 reti
                           1390 ;	# 94 "../../include/ezintavecs.h"
   0178                    1391 	    .org 0x0178
                           1392 ;	# 72 "../../include/ezintavecs.h"
   0178 32                 1393 	 reti
                           1394 ;	# 94 "../../include/ezintavecs.h"
   017C                    1395 	    .org 0x017C
                           1396 ;	# 73 "../../include/ezintavecs.h"
   017C 32                 1397 	 reti
                           1398 ;	# 94 "../../include/ezintavecs.h"
   0180                    1399 	    .org 0x0180
                           1400 ;	# 74 "../../include/ezintavecs.h"
   0180 32                 1401 	 reti
                           1402 ;	# 94 "../../include/ezintavecs.h"
   0184                    1403 	    .org 0x0184
                           1404 ;	# 75 "../../include/ezintavecs.h"
   0184 32                 1405 	 reti
                           1406 ;	# 94 "../../include/ezintavecs.h"
   0188                    1407 	    .org 0x0188
                           1408 ;	# 76 "../../include/ezintavecs.h"
   0188 32                 1409 	 reti
                           1410 ;	# 94 "../../include/ezintavecs.h"
   018C                    1411 	    .org 0x018C
                           1412 ;	# 77 "../../include/ezintavecs.h"
   018C 32                 1413 	 reti
                           1414 ;	# 94 "../../include/ezintavecs.h"
   0190                    1415 	    .org 0x0190
                           1416 ;	# 78 "../../include/ezintavecs.h"
   0190 32                 1417 	 reti
                           1418 ;	# 94 "../../include/ezintavecs.h"
   0194                    1419 	    .org 0x0194
                           1420 ;	# 79 "../../include/ezintavecs.h"
   0194 32                 1421 	 reti
                           1422 ;	# 94 "../../include/ezintavecs.h"
   0198                    1423 	    .org 0x0198
                           1424 ;	# 80 "../../include/ezintavecs.h"
   0198 32                 1425 	 reti
                           1426 ;	# 94 "../../include/ezintavecs.h"
   019C                    1427 	    .org 0x019C
                           1428 ;	# 81 "../../include/ezintavecs.h"
   019C 32                 1429 	 reti
                           1430 ;	# 94 "../../include/ezintavecs.h"
   01A0                    1431 	    .org 0x01A0
                           1432 ;	# 82 "../../include/ezintavecs.h"
   01A0 32                 1433 	 reti
                           1434 ;	# 94 "../../include/ezintavecs.h"
   01A8                    1435 	    .org 0x01A8
                           1436 ;	# 83 "../../include/ezintavecs.h"
   01A8 32                 1437 	 reti
                           1438 ;	# 94 "../../include/ezintavecs.h"
   01AC                    1439 	    .org 0x01AC
                           1440 ;	# 84 "../../include/ezintavecs.h"
   01AC 32                 1441 	 reti
                           1442 ;	# 94 "../../include/ezintavecs.h"
   01B0                    1443 	    .org 0x01B0
                           1444 ;	# 85 "../../include/ezintavecs.h"
   01B0 32                 1445 	 reti
                           1446 ;	# 94 "../../include/ezintavecs.h"
   01B4                    1447 	    .org 0x01B4
                           1448 ;	# 101 "../../include/ezintavecs.h"
   01B4 32                 1449 	 reti
   01B8                    1450 	    .org 0x01b8
   01B8                    1451 	INTVEC_DUMMY:
   01B8 32                 1452 	        reti
                           1453 	    .area CSEG (CODE)
                           1454 	    
   0264 22                 1455 	ret
                           1456 ;------------------------------------------------------------
                           1457 ;Allocation info for local variables in function 'wait'
                           1458 ;------------------------------------------------------------
                           1459 ;ms                        Allocated to registers r2 r3 
                           1460 ;i                         Allocated to registers r6 r7 
                           1461 ;j                         Allocated to registers r4 r5 
                           1462 ;------------------------------------------------------------
                           1463 ;	../../include/ztex-utils.h:78: void wait(WORD short ms) {	  // wait in ms 
                           1464 ;	-----------------------------------------
                           1465 ;	 function wait
                           1466 ;	-----------------------------------------
   0265                    1467 _wait:
   0265 AA 82              1468 	mov	r2,dpl
   0267 AB 83              1469 	mov	r3,dph
                           1470 ;	../../include/ztex-utils.h:80: for (j=0; j<ms; j++) 
   0269 7C 00              1471 	mov	r4,#0x00
   026B 7D 00              1472 	mov	r5,#0x00
   026D                    1473 00104$:
   026D C3                 1474 	clr	c
   026E EC                 1475 	mov	a,r4
   026F 9A                 1476 	subb	a,r2
   0270 ED                 1477 	mov	a,r5
   0271 9B                 1478 	subb	a,r3
   0272 50 14              1479 	jnc	00108$
                           1480 ;	../../include/ztex-utils.h:81: for (i=0; i<1200; i++);
   0274 7E B0              1481 	mov	r6,#0xB0
   0276 7F 04              1482 	mov	r7,#0x04
   0278                    1483 00103$:
   0278 1E                 1484 	dec	r6
   0279 BE FF 01           1485 	cjne	r6,#0xff,00117$
   027C 1F                 1486 	dec	r7
   027D                    1487 00117$:
   027D EE                 1488 	mov	a,r6
   027E 4F                 1489 	orl	a,r7
   027F 70 F7              1490 	jnz	00103$
                           1491 ;	../../include/ztex-utils.h:80: for (j=0; j<ms; j++) 
   0281 0C                 1492 	inc	r4
   0282 BC 00 E8           1493 	cjne	r4,#0x00,00104$
   0285 0D                 1494 	inc	r5
   0286 80 E5              1495 	sjmp	00104$
   0288                    1496 00108$:
   0288 22                 1497 	ret
                           1498 ;------------------------------------------------------------
                           1499 ;Allocation info for local variables in function 'uwait'
                           1500 ;------------------------------------------------------------
                           1501 ;us                        Allocated to registers r2 r3 
                           1502 ;i                         Allocated to registers r6 r7 
                           1503 ;j                         Allocated to registers r4 r5 
                           1504 ;------------------------------------------------------------
                           1505 ;	../../include/ztex-utils.h:88: void uwait(WORD short us) {	  // wait in 10µs steps
                           1506 ;	-----------------------------------------
                           1507 ;	 function uwait
                           1508 ;	-----------------------------------------
   0289                    1509 _uwait:
   0289 AA 82              1510 	mov	r2,dpl
   028B AB 83              1511 	mov	r3,dph
                           1512 ;	../../include/ztex-utils.h:90: for (j=0; j<us; j++) 
   028D 7C 00              1513 	mov	r4,#0x00
   028F 7D 00              1514 	mov	r5,#0x00
   0291                    1515 00104$:
   0291 C3                 1516 	clr	c
   0292 EC                 1517 	mov	a,r4
   0293 9A                 1518 	subb	a,r2
   0294 ED                 1519 	mov	a,r5
   0295 9B                 1520 	subb	a,r3
   0296 50 14              1521 	jnc	00108$
                           1522 ;	../../include/ztex-utils.h:91: for (i=0; i<10; i++);
   0298 7E 0A              1523 	mov	r6,#0x0A
   029A 7F 00              1524 	mov	r7,#0x00
   029C                    1525 00103$:
   029C 1E                 1526 	dec	r6
   029D BE FF 01           1527 	cjne	r6,#0xff,00117$
   02A0 1F                 1528 	dec	r7
   02A1                    1529 00117$:
   02A1 EE                 1530 	mov	a,r6
   02A2 4F                 1531 	orl	a,r7
   02A3 70 F7              1532 	jnz	00103$
                           1533 ;	../../include/ztex-utils.h:90: for (j=0; j<us; j++) 
   02A5 0C                 1534 	inc	r4
   02A6 BC 00 E8           1535 	cjne	r4,#0x00,00104$
   02A9 0D                 1536 	inc	r5
   02AA 80 E5              1537 	sjmp	00104$
   02AC                    1538 00108$:
   02AC 22                 1539 	ret
                           1540 ;------------------------------------------------------------
                           1541 ;Allocation info for local variables in function 'MEM_COPY1_int'
                           1542 ;------------------------------------------------------------
                           1543 ;------------------------------------------------------------
                           1544 ;	../../include/ztex-utils.h:99: void MEM_COPY1_int() // __naked 
                           1545 ;	-----------------------------------------
                           1546 ;	 function MEM_COPY1_int
                           1547 ;	-----------------------------------------
   02AD                    1548 _MEM_COPY1_int:
                           1549 ;	../../include/ztex-utils.h:110: __endasm;
                           1550 	
   02AD                    1551 	020001$:
   02AD 75 AF 07           1552 	     mov _AUTOPTRSETUP,#0x07
   02B0 90 E6 7B           1553 	     mov dptr,#_XAUTODAT1
   02B3 E0                 1554 	     movx a,@dptr
   02B4 90 E6 7C           1555 	     mov dptr,#_XAUTODAT2
   02B7 F0                 1556 	     movx @dptr,a
   02B8 DA F3              1557 	     djnz r2, 020001$
   02BA 22                 1558 	     ret
                           1559 	 
   02BB 22                 1560 	ret
                           1561 ;------------------------------------------------------------
                           1562 ;Allocation info for local variables in function 'i2c_waitWrite'
                           1563 ;------------------------------------------------------------
                           1564 ;i2csbuf                   Allocated to registers r2 
                           1565 ;toc                       Allocated to registers r2 
                           1566 ;------------------------------------------------------------
                           1567 ;	../../include/ztex-eeprom.h:41: BYTE i2c_waitWrite()
                           1568 ;	-----------------------------------------
                           1569 ;	 function i2c_waitWrite
                           1570 ;	-----------------------------------------
   02BC                    1571 _i2c_waitWrite:
                           1572 ;	../../include/ztex-eeprom.h:44: for ( toc=0; toc<255 && !(I2CS & bmBIT0); toc++ );
   02BC 7A 00              1573 	mov	r2,#0x00
   02BE                    1574 00105$:
   02BE BA FF 00           1575 	cjne	r2,#0xFF,00116$
   02C1                    1576 00116$:
   02C1 50 0B              1577 	jnc	00108$
   02C3 90 E6 78           1578 	mov	dptr,#_I2CS
   02C6 E0                 1579 	movx	a,@dptr
   02C7 FB                 1580 	mov	r3,a
   02C8 20 E0 03           1581 	jb	acc.0,00108$
   02CB 0A                 1582 	inc	r2
   02CC 80 F0              1583 	sjmp	00105$
   02CE                    1584 00108$:
                           1585 ;	../../include/ztex-eeprom.h:45: i2csbuf = I2CS;
   02CE 90 E6 78           1586 	mov	dptr,#_I2CS
   02D1 E0                 1587 	movx	a,@dptr
                           1588 ;	../../include/ztex-eeprom.h:46: if ( (i2csbuf & bmBIT2) || (!(i2csbuf & bmBIT1)) ) {
   02D2 FA                 1589 	mov	r2,a
   02D3 20 E2 04           1590 	jb	acc.2,00101$
   02D6 EA                 1591 	mov	a,r2
   02D7 20 E1 0B           1592 	jb	acc.1,00102$
   02DA                    1593 00101$:
                           1594 ;	../../include/ztex-eeprom.h:47: I2CS |= bmBIT6;
   02DA 90 E6 78           1595 	mov	dptr,#_I2CS
   02DD E0                 1596 	movx	a,@dptr
   02DE 44 40              1597 	orl	a,#0x40
   02E0 F0                 1598 	movx	@dptr,a
                           1599 ;	../../include/ztex-eeprom.h:48: return 1;
   02E1 75 82 01           1600 	mov	dpl,#0x01
                           1601 ;	../../include/ztex-eeprom.h:50: return 0;
   02E4 22                 1602 	ret
   02E5                    1603 00102$:
   02E5 75 82 00           1604 	mov	dpl,#0x00
   02E8 22                 1605 	ret
                           1606 ;------------------------------------------------------------
                           1607 ;Allocation info for local variables in function 'i2c_waitRead'
                           1608 ;------------------------------------------------------------
                           1609 ;i2csbuf                   Allocated to registers r2 
                           1610 ;toc                       Allocated to registers r2 
                           1611 ;------------------------------------------------------------
                           1612 ;	../../include/ztex-eeprom.h:57: BYTE i2c_waitRead(void)
                           1613 ;	-----------------------------------------
                           1614 ;	 function i2c_waitRead
                           1615 ;	-----------------------------------------
   02E9                    1616 _i2c_waitRead:
                           1617 ;	../../include/ztex-eeprom.h:60: for ( toc=0; toc<255 && !(I2CS & bmBIT0); toc++ );
   02E9 7A 00              1618 	mov	r2,#0x00
   02EB                    1619 00104$:
   02EB BA FF 00           1620 	cjne	r2,#0xFF,00115$
   02EE                    1621 00115$:
   02EE 50 0B              1622 	jnc	00107$
   02F0 90 E6 78           1623 	mov	dptr,#_I2CS
   02F3 E0                 1624 	movx	a,@dptr
   02F4 FB                 1625 	mov	r3,a
   02F5 20 E0 03           1626 	jb	acc.0,00107$
   02F8 0A                 1627 	inc	r2
   02F9 80 F0              1628 	sjmp	00104$
   02FB                    1629 00107$:
                           1630 ;	../../include/ztex-eeprom.h:61: i2csbuf = I2CS;
   02FB 90 E6 78           1631 	mov	dptr,#_I2CS
   02FE E0                 1632 	movx	a,@dptr
                           1633 ;	../../include/ztex-eeprom.h:62: if (i2csbuf & bmBIT2) {
   02FF FA                 1634 	mov	r2,a
   0300 30 E2 0B           1635 	jnb	acc.2,00102$
                           1636 ;	../../include/ztex-eeprom.h:63: I2CS |= bmBIT6;
   0303 90 E6 78           1637 	mov	dptr,#_I2CS
   0306 E0                 1638 	movx	a,@dptr
   0307 44 40              1639 	orl	a,#0x40
   0309 F0                 1640 	movx	@dptr,a
                           1641 ;	../../include/ztex-eeprom.h:64: return 1;
   030A 75 82 01           1642 	mov	dpl,#0x01
                           1643 ;	../../include/ztex-eeprom.h:66: return 0;
   030D 22                 1644 	ret
   030E                    1645 00102$:
   030E 75 82 00           1646 	mov	dpl,#0x00
   0311 22                 1647 	ret
                           1648 ;------------------------------------------------------------
                           1649 ;Allocation info for local variables in function 'i2c_waitStart'
                           1650 ;------------------------------------------------------------
                           1651 ;toc                       Allocated to registers r2 
                           1652 ;------------------------------------------------------------
                           1653 ;	../../include/ztex-eeprom.h:73: BYTE i2c_waitStart()
                           1654 ;	-----------------------------------------
                           1655 ;	 function i2c_waitStart
                           1656 ;	-----------------------------------------
   0312                    1657 _i2c_waitStart:
                           1658 ;	../../include/ztex-eeprom.h:76: for ( toc=0; toc<255; toc++ ) {
   0312 7A 00              1659 	mov	r2,#0x00
   0314                    1660 00103$:
   0314 BA FF 00           1661 	cjne	r2,#0xFF,00112$
   0317                    1662 00112$:
   0317 50 0F              1663 	jnc	00106$
                           1664 ;	../../include/ztex-eeprom.h:77: if ( ! (I2CS & bmBIT2) )
   0319 90 E6 78           1665 	mov	dptr,#_I2CS
   031C E0                 1666 	movx	a,@dptr
   031D FB                 1667 	mov	r3,a
   031E 20 E2 04           1668 	jb	acc.2,00105$
                           1669 ;	../../include/ztex-eeprom.h:78: return 0;
   0321 75 82 00           1670 	mov	dpl,#0x00
   0324 22                 1671 	ret
   0325                    1672 00105$:
                           1673 ;	../../include/ztex-eeprom.h:76: for ( toc=0; toc<255; toc++ ) {
   0325 0A                 1674 	inc	r2
   0326 80 EC              1675 	sjmp	00103$
   0328                    1676 00106$:
                           1677 ;	../../include/ztex-eeprom.h:80: return 1;
   0328 75 82 01           1678 	mov	dpl,#0x01
   032B 22                 1679 	ret
                           1680 ;------------------------------------------------------------
                           1681 ;Allocation info for local variables in function 'i2c_waitStop'
                           1682 ;------------------------------------------------------------
                           1683 ;toc                       Allocated to registers r2 
                           1684 ;------------------------------------------------------------
                           1685 ;	../../include/ztex-eeprom.h:87: BYTE i2c_waitStop()
                           1686 ;	-----------------------------------------
                           1687 ;	 function i2c_waitStop
                           1688 ;	-----------------------------------------
   032C                    1689 _i2c_waitStop:
                           1690 ;	../../include/ztex-eeprom.h:90: for ( toc=0; toc<255; toc++ ) {
   032C 7A 00              1691 	mov	r2,#0x00
   032E                    1692 00103$:
   032E BA FF 00           1693 	cjne	r2,#0xFF,00112$
   0331                    1694 00112$:
   0331 50 0F              1695 	jnc	00106$
                           1696 ;	../../include/ztex-eeprom.h:91: if ( ! (I2CS & bmBIT6) )
   0333 90 E6 78           1697 	mov	dptr,#_I2CS
   0336 E0                 1698 	movx	a,@dptr
   0337 FB                 1699 	mov	r3,a
   0338 20 E6 04           1700 	jb	acc.6,00105$
                           1701 ;	../../include/ztex-eeprom.h:92: return 0;
   033B 75 82 00           1702 	mov	dpl,#0x00
   033E 22                 1703 	ret
   033F                    1704 00105$:
                           1705 ;	../../include/ztex-eeprom.h:90: for ( toc=0; toc<255; toc++ ) {
   033F 0A                 1706 	inc	r2
   0340 80 EC              1707 	sjmp	00103$
   0342                    1708 00106$:
                           1709 ;	../../include/ztex-eeprom.h:94: return 1;
   0342 75 82 01           1710 	mov	dpl,#0x01
   0345 22                 1711 	ret
                           1712 ;------------------------------------------------------------
                           1713 ;Allocation info for local variables in function 'eeprom_select'
                           1714 ;------------------------------------------------------------
                           1715 ;to                        Allocated with name '_eeprom_select_PARM_2'
                           1716 ;stop                      Allocated with name '_eeprom_select_PARM_3'
                           1717 ;addr                      Allocated to registers r2 
                           1718 ;toc                       Allocated to registers 
                           1719 ;------------------------------------------------------------
                           1720 ;	../../include/ztex-eeprom.h:103: BYTE eeprom_select (BYTE addr, BYTE to, BYTE stop ) {
                           1721 ;	-----------------------------------------
                           1722 ;	 function eeprom_select
                           1723 ;	-----------------------------------------
   0346                    1724 _eeprom_select:
   0346 AA 82              1725 	mov	r2,dpl
                           1726 ;	../../include/ztex-eeprom.h:105: eeprom_select_start:
   0348 C3                 1727 	clr	c
   0349 E4                 1728 	clr	a
   034A 95 08              1729 	subb	a,_eeprom_select_PARM_2
   034C E4                 1730 	clr	a
   034D 33                 1731 	rlc	a
   034E FB                 1732 	mov	r3,a
   034F                    1733 00101$:
                           1734 ;	../../include/ztex-eeprom.h:106: I2CS |= bmBIT7;		// start bit
   034F 90 E6 78           1735 	mov	dptr,#_I2CS
   0352 E0                 1736 	movx	a,@dptr
   0353 44 80              1737 	orl	a,#0x80
   0355 F0                 1738 	movx	@dptr,a
                           1739 ;	../../include/ztex-eeprom.h:107: i2c_waitStart();
   0356 C0 02              1740 	push	ar2
   0358 C0 03              1741 	push	ar3
   035A 12 03 12           1742 	lcall	_i2c_waitStart
   035D D0 03              1743 	pop	ar3
   035F D0 02              1744 	pop	ar2
                           1745 ;	../../include/ztex-eeprom.h:108: I2DAT = addr;		// select device for writing
   0361 90 E6 79           1746 	mov	dptr,#_I2DAT
   0364 EA                 1747 	mov	a,r2
   0365 F0                 1748 	movx	@dptr,a
                           1749 ;	../../include/ztex-eeprom.h:109: if ( ! i2c_waitWrite() ) {
   0366 C0 02              1750 	push	ar2
   0368 C0 03              1751 	push	ar3
   036A 12 02 BC           1752 	lcall	_i2c_waitWrite
   036D E5 82              1753 	mov	a,dpl
   036F D0 03              1754 	pop	ar3
   0371 D0 02              1755 	pop	ar2
   0373 70 12              1756 	jnz	00107$
                           1757 ;	../../include/ztex-eeprom.h:110: if ( stop ) {
   0375 E5 09              1758 	mov	a,_eeprom_select_PARM_3
   0377 60 0A              1759 	jz	00103$
                           1760 ;	../../include/ztex-eeprom.h:111: I2CS |= bmBIT6;
   0379 90 E6 78           1761 	mov	dptr,#_I2CS
   037C E0                 1762 	movx	a,@dptr
   037D 44 40              1763 	orl	a,#0x40
   037F F0                 1764 	movx	@dptr,a
                           1765 ;	../../include/ztex-eeprom.h:112: i2c_waitStop();
   0380 12 03 2C           1766 	lcall	_i2c_waitStop
   0383                    1767 00103$:
                           1768 ;	../../include/ztex-eeprom.h:114: return 0;
   0383 75 82 00           1769 	mov	dpl,#0x00
   0386 22                 1770 	ret
   0387                    1771 00107$:
                           1772 ;	../../include/ztex-eeprom.h:116: else if (toc<to) {
   0387 EB                 1773 	mov	a,r3
   0388 60 10              1774 	jz	00108$
                           1775 ;	../../include/ztex-eeprom.h:117: uwait(10);
   038A 90 00 0A           1776 	mov	dptr,#0x000A
   038D C0 02              1777 	push	ar2
   038F C0 03              1778 	push	ar3
   0391 12 02 89           1779 	lcall	_uwait
   0394 D0 03              1780 	pop	ar3
   0396 D0 02              1781 	pop	ar2
                           1782 ;	../../include/ztex-eeprom.h:118: goto eeprom_select_start;
   0398 80 B5              1783 	sjmp	00101$
   039A                    1784 00108$:
                           1785 ;	../../include/ztex-eeprom.h:120: if ( stop ) {
   039A E5 09              1786 	mov	a,_eeprom_select_PARM_3
   039C 60 08              1787 	jz	00110$
                           1788 ;	../../include/ztex-eeprom.h:121: I2CS |= bmBIT6;
   039E 90 E6 78           1789 	mov	dptr,#_I2CS
   03A1 E0                 1790 	movx	a,@dptr
   03A2 FA                 1791 	mov	r2,a
   03A3 44 40              1792 	orl	a,#0x40
   03A5 F0                 1793 	movx	@dptr,a
   03A6                    1794 00110$:
                           1795 ;	../../include/ztex-eeprom.h:123: return 1;
   03A6 75 82 01           1796 	mov	dpl,#0x01
   03A9 22                 1797 	ret
                           1798 ;------------------------------------------------------------
                           1799 ;Allocation info for local variables in function 'eeprom_read'
                           1800 ;------------------------------------------------------------
                           1801 ;addr                      Allocated with name '_eeprom_read_PARM_2'
                           1802 ;length                    Allocated with name '_eeprom_read_PARM_3'
                           1803 ;buf                       Allocated to registers r2 r3 
                           1804 ;bytes                     Allocated to registers r4 
                           1805 ;i                         Allocated to registers 
                           1806 ;------------------------------------------------------------
                           1807 ;	../../include/ztex-eeprom.h:131: BYTE eeprom_read ( __xdata BYTE *buf, WORD addr, BYTE length ) { 
                           1808 ;	-----------------------------------------
                           1809 ;	 function eeprom_read
                           1810 ;	-----------------------------------------
   03AA                    1811 _eeprom_read:
   03AA AA 82              1812 	mov	r2,dpl
   03AC AB 83              1813 	mov	r3,dph
                           1814 ;	../../include/ztex-eeprom.h:132: BYTE bytes = 0,i;
   03AE 7C 00              1815 	mov	r4,#0x00
                           1816 ;	../../include/ztex-eeprom.h:134: if ( length == 0 ) 
   03B0 E5 0C              1817 	mov	a,_eeprom_read_PARM_3
                           1818 ;	../../include/ztex-eeprom.h:135: return 0;
   03B2 70 03              1819 	jnz	00102$
   03B4 F5 82              1820 	mov	dpl,a
   03B6 22                 1821 	ret
   03B7                    1822 00102$:
                           1823 ;	../../include/ztex-eeprom.h:137: if ( eeprom_select(EEPROM_ADDR, 100,0) ) 
   03B7 75 08 64           1824 	mov	_eeprom_select_PARM_2,#0x64
   03BA 75 09 00           1825 	mov	_eeprom_select_PARM_3,#0x00
   03BD 75 82 A2           1826 	mov	dpl,#0xA2
   03C0 C0 02              1827 	push	ar2
   03C2 C0 03              1828 	push	ar3
   03C4 C0 04              1829 	push	ar4
   03C6 12 03 46           1830 	lcall	_eeprom_select
   03C9 E5 82              1831 	mov	a,dpl
   03CB D0 04              1832 	pop	ar4
   03CD D0 03              1833 	pop	ar3
   03CF D0 02              1834 	pop	ar2
   03D1 60 03              1835 	jz	00134$
   03D3 02 04 B0           1836 	ljmp	00117$
   03D6                    1837 00134$:
                           1838 ;	../../include/ztex-eeprom.h:140: I2DAT = HI(addr);		// write address
   03D6 90 E6 79           1839 	mov	dptr,#_I2DAT
   03D9 E5 0B              1840 	mov	a,(_eeprom_read_PARM_2 + 1)
   03DB F0                 1841 	movx	@dptr,a
                           1842 ;	../../include/ztex-eeprom.h:141: if ( i2c_waitWrite() ) goto eeprom_read_end;
   03DC C0 02              1843 	push	ar2
   03DE C0 03              1844 	push	ar3
   03E0 C0 04              1845 	push	ar4
   03E2 12 02 BC           1846 	lcall	_i2c_waitWrite
   03E5 E5 82              1847 	mov	a,dpl
   03E7 D0 04              1848 	pop	ar4
   03E9 D0 03              1849 	pop	ar3
   03EB D0 02              1850 	pop	ar2
   03ED 60 03              1851 	jz	00135$
   03EF 02 04 B0           1852 	ljmp	00117$
   03F2                    1853 00135$:
                           1854 ;	../../include/ztex-eeprom.h:142: I2DAT = LO(addr);		// write address
   03F2 90 E6 79           1855 	mov	dptr,#_I2DAT
   03F5 E5 0A              1856 	mov	a,_eeprom_read_PARM_2
   03F7 F0                 1857 	movx	@dptr,a
                           1858 ;	../../include/ztex-eeprom.h:143: if ( i2c_waitWrite() ) goto eeprom_read_end;
   03F8 C0 02              1859 	push	ar2
   03FA C0 03              1860 	push	ar3
   03FC C0 04              1861 	push	ar4
   03FE 12 02 BC           1862 	lcall	_i2c_waitWrite
   0401 E5 82              1863 	mov	a,dpl
   0403 D0 04              1864 	pop	ar4
   0405 D0 03              1865 	pop	ar3
   0407 D0 02              1866 	pop	ar2
   0409 60 03              1867 	jz	00136$
   040B 02 04 B0           1868 	ljmp	00117$
   040E                    1869 00136$:
                           1870 ;	../../include/ztex-eeprom.h:144: I2CS |= bmBIT6;
   040E 90 E6 78           1871 	mov	dptr,#_I2CS
   0411 E0                 1872 	movx	a,@dptr
   0412 44 40              1873 	orl	a,#0x40
   0414 F0                 1874 	movx	@dptr,a
                           1875 ;	../../include/ztex-eeprom.h:145: i2c_waitStop();
   0415 C0 02              1876 	push	ar2
   0417 C0 03              1877 	push	ar3
   0419 C0 04              1878 	push	ar4
   041B 12 03 2C           1879 	lcall	_i2c_waitStop
                           1880 ;	../../include/ztex-eeprom.h:147: I2CS |= bmBIT7;		// start bit
   041E 90 E6 78           1881 	mov	dptr,#_I2CS
   0421 E0                 1882 	movx	a,@dptr
   0422 44 80              1883 	orl	a,#0x80
   0424 F0                 1884 	movx	@dptr,a
                           1885 ;	../../include/ztex-eeprom.h:148: i2c_waitStart();
   0425 12 03 12           1886 	lcall	_i2c_waitStart
                           1887 ;	../../include/ztex-eeprom.h:149: I2DAT = EEPROM_ADDR | 1;	// select device for reading
   0428 90 E6 79           1888 	mov	dptr,#_I2DAT
   042B 74 A3              1889 	mov	a,#0xA3
   042D F0                 1890 	movx	@dptr,a
                           1891 ;	../../include/ztex-eeprom.h:150: if ( i2c_waitWrite() ) goto eeprom_read_end;
   042E 12 02 BC           1892 	lcall	_i2c_waitWrite
   0431 E5 82              1893 	mov	a,dpl
   0433 D0 04              1894 	pop	ar4
   0435 D0 03              1895 	pop	ar3
   0437 D0 02              1896 	pop	ar2
   0439 70 75              1897 	jnz	00117$
                           1898 ;	../../include/ztex-eeprom.h:152: *buf = I2DAT;		// dummy read
   043B 90 E6 79           1899 	mov	dptr,#_I2DAT
   043E E0                 1900 	movx	a,@dptr
   043F 8A 82              1901 	mov	dpl,r2
   0441 8B 83              1902 	mov	dph,r3
   0443 F0                 1903 	movx	@dptr,a
                           1904 ;	../../include/ztex-eeprom.h:153: if ( i2c_waitRead()) goto eeprom_read_end; 
   0444 C0 02              1905 	push	ar2
   0446 C0 03              1906 	push	ar3
   0448 C0 04              1907 	push	ar4
   044A 12 02 E9           1908 	lcall	_i2c_waitRead
   044D E5 82              1909 	mov	a,dpl
   044F D0 04              1910 	pop	ar4
   0451 D0 03              1911 	pop	ar3
   0453 D0 02              1912 	pop	ar2
   0455 70 59              1913 	jnz	00117$
   0457 FD                 1914 	mov	r5,a
   0458                    1915 00118$:
                           1916 ;	../../include/ztex-eeprom.h:154: for (; bytes<length; bytes++ ) {
   0458 C3                 1917 	clr	c
   0459 ED                 1918 	mov	a,r5
   045A 95 0C              1919 	subb	a,_eeprom_read_PARM_3
   045C 50 2A              1920 	jnc	00121$
                           1921 ;	../../include/ztex-eeprom.h:155: *buf = I2DAT;		// read data
   045E 90 E6 79           1922 	mov	dptr,#_I2DAT
   0461 E0                 1923 	movx	a,@dptr
   0462 8A 82              1924 	mov	dpl,r2
   0464 8B 83              1925 	mov	dph,r3
   0466 F0                 1926 	movx	@dptr,a
   0467 A3                 1927 	inc	dptr
   0468 AA 82              1928 	mov	r2,dpl
   046A AB 83              1929 	mov	r3,dph
                           1930 ;	../../include/ztex-eeprom.h:156: buf++;
                           1931 ;	../../include/ztex-eeprom.h:157: if ( i2c_waitRead()) goto eeprom_read_end; 
   046C C0 02              1932 	push	ar2
   046E C0 03              1933 	push	ar3
   0470 C0 04              1934 	push	ar4
   0472 C0 05              1935 	push	ar5
   0474 12 02 E9           1936 	lcall	_i2c_waitRead
   0477 E5 82              1937 	mov	a,dpl
   0479 D0 05              1938 	pop	ar5
   047B D0 04              1939 	pop	ar4
   047D D0 03              1940 	pop	ar3
   047F D0 02              1941 	pop	ar2
   0481 70 2D              1942 	jnz	00117$
                           1943 ;	../../include/ztex-eeprom.h:154: for (; bytes<length; bytes++ ) {
   0483 0D                 1944 	inc	r5
   0484 8D 04              1945 	mov	ar4,r5
   0486 80 D0              1946 	sjmp	00118$
   0488                    1947 00121$:
                           1948 ;	../../include/ztex-eeprom.h:160: I2CS |= bmBIT5;		// no ACK
   0488 90 E6 78           1949 	mov	dptr,#_I2CS
   048B E0                 1950 	movx	a,@dptr
   048C 44 20              1951 	orl	a,#0x20
   048E F0                 1952 	movx	@dptr,a
                           1953 ;	../../include/ztex-eeprom.h:161: i = I2DAT;			// dummy read
   048F 90 E6 79           1954 	mov	dptr,#_I2DAT
   0492 E0                 1955 	movx	a,@dptr
                           1956 ;	../../include/ztex-eeprom.h:162: if ( i2c_waitRead()) goto eeprom_read_end; 
   0493 C0 04              1957 	push	ar4
   0495 12 02 E9           1958 	lcall	_i2c_waitRead
   0498 E5 82              1959 	mov	a,dpl
   049A D0 04              1960 	pop	ar4
   049C 70 12              1961 	jnz	00117$
                           1962 ;	../../include/ztex-eeprom.h:164: I2CS |= bmBIT6;		// stop bit
   049E 90 E6 78           1963 	mov	dptr,#_I2CS
   04A1 E0                 1964 	movx	a,@dptr
   04A2 44 40              1965 	orl	a,#0x40
   04A4 F0                 1966 	movx	@dptr,a
                           1967 ;	../../include/ztex-eeprom.h:165: i = I2DAT;			// dummy read
   04A5 90 E6 79           1968 	mov	dptr,#_I2DAT
   04A8 E0                 1969 	movx	a,@dptr
                           1970 ;	../../include/ztex-eeprom.h:166: i2c_waitStop();
   04A9 C0 04              1971 	push	ar4
   04AB 12 03 2C           1972 	lcall	_i2c_waitStop
   04AE D0 04              1973 	pop	ar4
                           1974 ;	../../include/ztex-eeprom.h:168: eeprom_read_end:
   04B0                    1975 00117$:
                           1976 ;	../../include/ztex-eeprom.h:169: return bytes;
   04B0 8C 82              1977 	mov	dpl,r4
   04B2 22                 1978 	ret
                           1979 ;------------------------------------------------------------
                           1980 ;Allocation info for local variables in function 'eeprom_write'
                           1981 ;------------------------------------------------------------
                           1982 ;addr                      Allocated with name '_eeprom_write_PARM_2'
                           1983 ;length                    Allocated with name '_eeprom_write_PARM_3'
                           1984 ;buf                       Allocated to registers r2 r3 
                           1985 ;bytes                     Allocated to registers r4 
                           1986 ;------------------------------------------------------------
                           1987 ;	../../include/ztex-eeprom.h:178: BYTE eeprom_write ( __xdata BYTE *buf, WORD addr, BYTE length ) {
                           1988 ;	-----------------------------------------
                           1989 ;	 function eeprom_write
                           1990 ;	-----------------------------------------
   04B3                    1991 _eeprom_write:
   04B3 AA 82              1992 	mov	r2,dpl
   04B5 AB 83              1993 	mov	r3,dph
                           1994 ;	../../include/ztex-eeprom.h:179: BYTE bytes = 0;
   04B7 7C 00              1995 	mov	r4,#0x00
                           1996 ;	../../include/ztex-eeprom.h:181: if ( length == 0 ) 
   04B9 E5 0F              1997 	mov	a,_eeprom_write_PARM_3
                           1998 ;	../../include/ztex-eeprom.h:182: return 0;
   04BB 70 03              1999 	jnz	00102$
   04BD F5 82              2000 	mov	dpl,a
   04BF 22                 2001 	ret
   04C0                    2002 00102$:
                           2003 ;	../../include/ztex-eeprom.h:184: if ( eeprom_select(EEPROM_ADDR, 100,0) ) 
   04C0 75 08 64           2004 	mov	_eeprom_select_PARM_2,#0x64
   04C3 75 09 00           2005 	mov	_eeprom_select_PARM_3,#0x00
   04C6 75 82 A2           2006 	mov	dpl,#0xA2
   04C9 C0 02              2007 	push	ar2
   04CB C0 03              2008 	push	ar3
   04CD C0 04              2009 	push	ar4
   04CF 12 03 46           2010 	lcall	_eeprom_select
   04D2 E5 82              2011 	mov	a,dpl
   04D4 D0 04              2012 	pop	ar4
   04D6 D0 03              2013 	pop	ar3
   04D8 D0 02              2014 	pop	ar2
   04DA 60 03              2015 	jz	00125$
   04DC 02 05 70           2016 	ljmp	00111$
   04DF                    2017 00125$:
                           2018 ;	../../include/ztex-eeprom.h:187: I2DAT = HI(addr);          	// write address
   04DF 90 E6 79           2019 	mov	dptr,#_I2DAT
   04E2 E5 0E              2020 	mov	a,(_eeprom_write_PARM_2 + 1)
   04E4 F0                 2021 	movx	@dptr,a
                           2022 ;	../../include/ztex-eeprom.h:188: if ( i2c_waitWrite() ) goto eeprom_write_end;
   04E5 C0 02              2023 	push	ar2
   04E7 C0 03              2024 	push	ar3
   04E9 C0 04              2025 	push	ar4
   04EB 12 02 BC           2026 	lcall	_i2c_waitWrite
   04EE E5 82              2027 	mov	a,dpl
   04F0 D0 04              2028 	pop	ar4
   04F2 D0 03              2029 	pop	ar3
   04F4 D0 02              2030 	pop	ar2
   04F6 60 03              2031 	jz	00126$
   04F8 02 05 70           2032 	ljmp	00111$
   04FB                    2033 00126$:
                           2034 ;	../../include/ztex-eeprom.h:189: I2DAT = LO(addr);          	// write address
   04FB 90 E6 79           2035 	mov	dptr,#_I2DAT
   04FE E5 0D              2036 	mov	a,_eeprom_write_PARM_2
   0500 F0                 2037 	movx	@dptr,a
                           2038 ;	../../include/ztex-eeprom.h:190: if ( i2c_waitWrite() ) goto eeprom_write_end;
   0501 C0 02              2039 	push	ar2
   0503 C0 03              2040 	push	ar3
   0505 C0 04              2041 	push	ar4
   0507 12 02 BC           2042 	lcall	_i2c_waitWrite
   050A E5 82              2043 	mov	a,dpl
   050C D0 04              2044 	pop	ar4
   050E D0 03              2045 	pop	ar3
   0510 D0 02              2046 	pop	ar2
   0512 70 5C              2047 	jnz	00111$
   0514 FD                 2048 	mov	r5,a
   0515                    2049 00112$:
                           2050 ;	../../include/ztex-eeprom.h:192: for (; bytes<length; bytes++ ) {
   0515 C3                 2051 	clr	c
   0516 ED                 2052 	mov	a,r5
   0517 95 0F              2053 	subb	a,_eeprom_write_PARM_3
   0519 50 47              2054 	jnc	00115$
                           2055 ;	../../include/ztex-eeprom.h:193: I2DAT = *buf;         	// write data 
   051B 8A 82              2056 	mov	dpl,r2
   051D 8B 83              2057 	mov	dph,r3
   051F E0                 2058 	movx	a,@dptr
   0520 FE                 2059 	mov	r6,a
   0521 A3                 2060 	inc	dptr
   0522 AA 82              2061 	mov	r2,dpl
   0524 AB 83              2062 	mov	r3,dph
   0526 90 E6 79           2063 	mov	dptr,#_I2DAT
   0529 EE                 2064 	mov	a,r6
   052A F0                 2065 	movx	@dptr,a
                           2066 ;	../../include/ztex-eeprom.h:194: eeprom_write_checksum += *buf;
   052B 90 3A 04           2067 	mov	dptr,#_eeprom_write_checksum
   052E E0                 2068 	movx	a,@dptr
   052F FF                 2069 	mov	r7,a
   0530 EE                 2070 	mov	a,r6
   0531 2F                 2071 	add	a,r7
   0532 F0                 2072 	movx	@dptr,a
                           2073 ;	../../include/ztex-eeprom.h:195: buf++;
                           2074 ;	../../include/ztex-eeprom.h:196: eeprom_write_bytes+=1;
   0533 90 3A 02           2075 	mov	dptr,#_eeprom_write_bytes
   0536 E0                 2076 	movx	a,@dptr
   0537 FE                 2077 	mov	r6,a
   0538 A3                 2078 	inc	dptr
   0539 E0                 2079 	movx	a,@dptr
   053A FF                 2080 	mov	r7,a
   053B 90 3A 02           2081 	mov	dptr,#_eeprom_write_bytes
   053E 74 01              2082 	mov	a,#0x01
   0540 2E                 2083 	add	a,r6
   0541 F0                 2084 	movx	@dptr,a
   0542 E4                 2085 	clr	a
   0543 3F                 2086 	addc	a,r7
   0544 A3                 2087 	inc	dptr
   0545 F0                 2088 	movx	@dptr,a
                           2089 ;	../../include/ztex-eeprom.h:197: if ( i2c_waitWrite() ) goto eeprom_write_end;
   0546 C0 02              2090 	push	ar2
   0548 C0 03              2091 	push	ar3
   054A C0 04              2092 	push	ar4
   054C C0 05              2093 	push	ar5
   054E 12 02 BC           2094 	lcall	_i2c_waitWrite
   0551 E5 82              2095 	mov	a,dpl
   0553 D0 05              2096 	pop	ar5
   0555 D0 04              2097 	pop	ar4
   0557 D0 03              2098 	pop	ar3
   0559 D0 02              2099 	pop	ar2
   055B 70 13              2100 	jnz	00111$
                           2101 ;	../../include/ztex-eeprom.h:192: for (; bytes<length; bytes++ ) {
   055D 0D                 2102 	inc	r5
   055E 8D 04              2103 	mov	ar4,r5
   0560 80 B3              2104 	sjmp	00112$
   0562                    2105 00115$:
                           2106 ;	../../include/ztex-eeprom.h:199: I2CS |= bmBIT6;		// stop bit
   0562 90 E6 78           2107 	mov	dptr,#_I2CS
   0565 E0                 2108 	movx	a,@dptr
   0566 44 40              2109 	orl	a,#0x40
   0568 F0                 2110 	movx	@dptr,a
                           2111 ;	../../include/ztex-eeprom.h:200: i2c_waitStop();
   0569 C0 04              2112 	push	ar4
   056B 12 03 2C           2113 	lcall	_i2c_waitStop
   056E D0 04              2114 	pop	ar4
                           2115 ;	../../include/ztex-eeprom.h:202: eeprom_write_end:
   0570                    2116 00111$:
                           2117 ;	../../include/ztex-eeprom.h:203: return bytes;
   0570 8C 82              2118 	mov	dpl,r4
   0572 22                 2119 	ret
                           2120 ;------------------------------------------------------------
                           2121 ;Allocation info for local variables in function 'eeprom_read_ep0'
                           2122 ;------------------------------------------------------------
                           2123 ;i                         Allocated to registers r3 
                           2124 ;b                         Allocated to registers r2 
                           2125 ;------------------------------------------------------------
                           2126 ;	../../include/ztex-eeprom.h:209: BYTE eeprom_read_ep0 () { 
                           2127 ;	-----------------------------------------
                           2128 ;	 function eeprom_read_ep0
                           2129 ;	-----------------------------------------
   0573                    2130 _eeprom_read_ep0:
                           2131 ;	../../include/ztex-eeprom.h:211: b = ep0_payload_transfer;
   0573 90 3A 38           2132 	mov	dptr,#_ep0_payload_transfer
   0576 E0                 2133 	movx	a,@dptr
   0577 FA                 2134 	mov	r2,a
                           2135 ;	../../include/ztex-eeprom.h:212: i = eeprom_read(EP0BUF, eeprom_addr, b);
   0578 90 3A 00           2136 	mov	dptr,#_eeprom_addr
   057B E0                 2137 	movx	a,@dptr
   057C F5 0A              2138 	mov	_eeprom_read_PARM_2,a
   057E A3                 2139 	inc	dptr
   057F E0                 2140 	movx	a,@dptr
   0580 F5 0B              2141 	mov	(_eeprom_read_PARM_2 + 1),a
   0582 8A 0C              2142 	mov	_eeprom_read_PARM_3,r2
   0584 90 E7 40           2143 	mov	dptr,#_EP0BUF
   0587 C0 02              2144 	push	ar2
   0589 12 03 AA           2145 	lcall	_eeprom_read
   058C AB 82              2146 	mov	r3,dpl
   058E D0 02              2147 	pop	ar2
                           2148 ;	../../include/ztex-eeprom.h:213: eeprom_addr += b;
   0590 7C 00              2149 	mov	r4,#0x00
   0592 90 3A 00           2150 	mov	dptr,#_eeprom_addr
   0595 E0                 2151 	movx	a,@dptr
   0596 FD                 2152 	mov	r5,a
   0597 A3                 2153 	inc	dptr
   0598 E0                 2154 	movx	a,@dptr
   0599 FE                 2155 	mov	r6,a
   059A 90 3A 00           2156 	mov	dptr,#_eeprom_addr
   059D EA                 2157 	mov	a,r2
   059E 2D                 2158 	add	a,r5
   059F F0                 2159 	movx	@dptr,a
   05A0 EC                 2160 	mov	a,r4
   05A1 3E                 2161 	addc	a,r6
   05A2 A3                 2162 	inc	dptr
   05A3 F0                 2163 	movx	@dptr,a
                           2164 ;	../../include/ztex-eeprom.h:214: return i;
   05A4 8B 82              2165 	mov	dpl,r3
   05A6 22                 2166 	ret
                           2167 ;------------------------------------------------------------
                           2168 ;Allocation info for local variables in function 'eeprom_write_ep0'
                           2169 ;------------------------------------------------------------
                           2170 ;length                    Allocated to registers r2 
                           2171 ;------------------------------------------------------------
                           2172 ;	../../include/ztex-eeprom.h:230: void eeprom_write_ep0 ( BYTE length ) { 	
                           2173 ;	-----------------------------------------
                           2174 ;	 function eeprom_write_ep0
                           2175 ;	-----------------------------------------
   05A7                    2176 _eeprom_write_ep0:
   05A7 AA 82              2177 	mov	r2,dpl
                           2178 ;	../../include/ztex-eeprom.h:231: eeprom_write(EP0BUF, eeprom_addr, length);
   05A9 90 3A 00           2179 	mov	dptr,#_eeprom_addr
   05AC E0                 2180 	movx	a,@dptr
   05AD F5 0D              2181 	mov	_eeprom_write_PARM_2,a
   05AF A3                 2182 	inc	dptr
   05B0 E0                 2183 	movx	a,@dptr
   05B1 F5 0E              2184 	mov	(_eeprom_write_PARM_2 + 1),a
   05B3 8A 0F              2185 	mov	_eeprom_write_PARM_3,r2
   05B5 90 E7 40           2186 	mov	dptr,#_EP0BUF
   05B8 C0 02              2187 	push	ar2
   05BA 12 04 B3           2188 	lcall	_eeprom_write
   05BD D0 02              2189 	pop	ar2
                           2190 ;	../../include/ztex-eeprom.h:232: eeprom_addr += length;
   05BF 7B 00              2191 	mov	r3,#0x00
   05C1 90 3A 00           2192 	mov	dptr,#_eeprom_addr
   05C4 E0                 2193 	movx	a,@dptr
   05C5 FC                 2194 	mov	r4,a
   05C6 A3                 2195 	inc	dptr
   05C7 E0                 2196 	movx	a,@dptr
   05C8 FD                 2197 	mov	r5,a
   05C9 90 3A 00           2198 	mov	dptr,#_eeprom_addr
   05CC EA                 2199 	mov	a,r2
   05CD 2C                 2200 	add	a,r4
   05CE F0                 2201 	movx	@dptr,a
   05CF EB                 2202 	mov	a,r3
   05D0 3D                 2203 	addc	a,r5
   05D1 A3                 2204 	inc	dptr
   05D2 F0                 2205 	movx	@dptr,a
   05D3 22                 2206 	ret
                           2207 ;------------------------------------------------------------
                           2208 ;Allocation info for local variables in function 'mac_eeprom_read'
                           2209 ;------------------------------------------------------------
                           2210 ;addr                      Allocated with name '_mac_eeprom_read_PARM_2'
                           2211 ;length                    Allocated with name '_mac_eeprom_read_PARM_3'
                           2212 ;buf                       Allocated to registers r2 r3 
                           2213 ;bytes                     Allocated to registers r4 
                           2214 ;i                         Allocated to registers 
                           2215 ;------------------------------------------------------------
                           2216 ;	../../include/ztex-eeprom.h:272: BYTE mac_eeprom_read ( __xdata BYTE *buf, BYTE addr, BYTE length ) { 
                           2217 ;	-----------------------------------------
                           2218 ;	 function mac_eeprom_read
                           2219 ;	-----------------------------------------
   05D4                    2220 _mac_eeprom_read:
   05D4 AA 82              2221 	mov	r2,dpl
   05D6 AB 83              2222 	mov	r3,dph
                           2223 ;	../../include/ztex-eeprom.h:273: BYTE bytes = 0,i;
   05D8 7C 00              2224 	mov	r4,#0x00
                           2225 ;	../../include/ztex-eeprom.h:275: if ( length == 0 ) 
   05DA E5 11              2226 	mov	a,_mac_eeprom_read_PARM_3
                           2227 ;	../../include/ztex-eeprom.h:276: return 0;
   05DC 70 03              2228 	jnz	00102$
   05DE F5 82              2229 	mov	dpl,a
   05E0 22                 2230 	ret
   05E1                    2231 00102$:
                           2232 ;	../../include/ztex-eeprom.h:278: if ( eeprom_select(EEPROM_MAC_ADDR, 100,0) ) 
   05E1 75 08 64           2233 	mov	_eeprom_select_PARM_2,#0x64
   05E4 75 09 00           2234 	mov	_eeprom_select_PARM_3,#0x00
   05E7 75 82 A6           2235 	mov	dpl,#0xA6
   05EA C0 02              2236 	push	ar2
   05EC C0 03              2237 	push	ar3
   05EE C0 04              2238 	push	ar4
   05F0 12 03 46           2239 	lcall	_eeprom_select
   05F3 E5 82              2240 	mov	a,dpl
   05F5 D0 04              2241 	pop	ar4
   05F7 D0 03              2242 	pop	ar3
   05F9 D0 02              2243 	pop	ar2
   05FB 60 03              2244 	jz	00131$
   05FD 02 06 BE           2245 	ljmp	00115$
   0600                    2246 00131$:
                           2247 ;	../../include/ztex-eeprom.h:281: I2DAT = addr;		// write address
   0600 90 E6 79           2248 	mov	dptr,#_I2DAT
   0603 E5 10              2249 	mov	a,_mac_eeprom_read_PARM_2
   0605 F0                 2250 	movx	@dptr,a
                           2251 ;	../../include/ztex-eeprom.h:282: if ( i2c_waitWrite() ) goto mac_eeprom_read_end;
   0606 C0 02              2252 	push	ar2
   0608 C0 03              2253 	push	ar3
   060A C0 04              2254 	push	ar4
   060C 12 02 BC           2255 	lcall	_i2c_waitWrite
   060F E5 82              2256 	mov	a,dpl
   0611 D0 04              2257 	pop	ar4
   0613 D0 03              2258 	pop	ar3
   0615 D0 02              2259 	pop	ar2
   0617 60 03              2260 	jz	00132$
   0619 02 06 BE           2261 	ljmp	00115$
   061C                    2262 00132$:
                           2263 ;	../../include/ztex-eeprom.h:283: I2CS |= bmBIT6;
   061C 90 E6 78           2264 	mov	dptr,#_I2CS
   061F E0                 2265 	movx	a,@dptr
   0620 44 40              2266 	orl	a,#0x40
   0622 F0                 2267 	movx	@dptr,a
                           2268 ;	../../include/ztex-eeprom.h:284: i2c_waitStop();
   0623 C0 02              2269 	push	ar2
   0625 C0 03              2270 	push	ar3
   0627 C0 04              2271 	push	ar4
   0629 12 03 2C           2272 	lcall	_i2c_waitStop
                           2273 ;	../../include/ztex-eeprom.h:286: I2CS |= bmBIT7;		// start bit
   062C 90 E6 78           2274 	mov	dptr,#_I2CS
   062F E0                 2275 	movx	a,@dptr
   0630 44 80              2276 	orl	a,#0x80
   0632 F0                 2277 	movx	@dptr,a
                           2278 ;	../../include/ztex-eeprom.h:287: i2c_waitStart();
   0633 12 03 12           2279 	lcall	_i2c_waitStart
                           2280 ;	../../include/ztex-eeprom.h:288: I2DAT = EEPROM_MAC_ADDR | 1;  // select device for reading
   0636 90 E6 79           2281 	mov	dptr,#_I2DAT
   0639 74 A7              2282 	mov	a,#0xA7
   063B F0                 2283 	movx	@dptr,a
                           2284 ;	../../include/ztex-eeprom.h:289: if ( i2c_waitWrite() ) goto mac_eeprom_read_end;
   063C 12 02 BC           2285 	lcall	_i2c_waitWrite
   063F E5 82              2286 	mov	a,dpl
   0641 D0 04              2287 	pop	ar4
   0643 D0 03              2288 	pop	ar3
   0645 D0 02              2289 	pop	ar2
   0647 70 75              2290 	jnz	00115$
                           2291 ;	../../include/ztex-eeprom.h:291: *buf = I2DAT;		// dummy read
   0649 90 E6 79           2292 	mov	dptr,#_I2DAT
   064C E0                 2293 	movx	a,@dptr
   064D 8A 82              2294 	mov	dpl,r2
   064F 8B 83              2295 	mov	dph,r3
   0651 F0                 2296 	movx	@dptr,a
                           2297 ;	../../include/ztex-eeprom.h:292: if ( i2c_waitRead()) goto mac_eeprom_read_end; 
   0652 C0 02              2298 	push	ar2
   0654 C0 03              2299 	push	ar3
   0656 C0 04              2300 	push	ar4
   0658 12 02 E9           2301 	lcall	_i2c_waitRead
   065B E5 82              2302 	mov	a,dpl
   065D D0 04              2303 	pop	ar4
   065F D0 03              2304 	pop	ar3
   0661 D0 02              2305 	pop	ar2
   0663 70 59              2306 	jnz	00115$
   0665 FD                 2307 	mov	r5,a
   0666                    2308 00116$:
                           2309 ;	../../include/ztex-eeprom.h:293: for (; bytes<length; bytes++ ) {
   0666 C3                 2310 	clr	c
   0667 ED                 2311 	mov	a,r5
   0668 95 11              2312 	subb	a,_mac_eeprom_read_PARM_3
   066A 50 2A              2313 	jnc	00119$
                           2314 ;	../../include/ztex-eeprom.h:294: *buf = I2DAT;		// read data
   066C 90 E6 79           2315 	mov	dptr,#_I2DAT
   066F E0                 2316 	movx	a,@dptr
   0670 8A 82              2317 	mov	dpl,r2
   0672 8B 83              2318 	mov	dph,r3
   0674 F0                 2319 	movx	@dptr,a
   0675 A3                 2320 	inc	dptr
   0676 AA 82              2321 	mov	r2,dpl
   0678 AB 83              2322 	mov	r3,dph
                           2323 ;	../../include/ztex-eeprom.h:295: buf++;
                           2324 ;	../../include/ztex-eeprom.h:296: if ( i2c_waitRead()) goto mac_eeprom_read_end; 
   067A C0 02              2325 	push	ar2
   067C C0 03              2326 	push	ar3
   067E C0 04              2327 	push	ar4
   0680 C0 05              2328 	push	ar5
   0682 12 02 E9           2329 	lcall	_i2c_waitRead
   0685 E5 82              2330 	mov	a,dpl
   0687 D0 05              2331 	pop	ar5
   0689 D0 04              2332 	pop	ar4
   068B D0 03              2333 	pop	ar3
   068D D0 02              2334 	pop	ar2
   068F 70 2D              2335 	jnz	00115$
                           2336 ;	../../include/ztex-eeprom.h:293: for (; bytes<length; bytes++ ) {
   0691 0D                 2337 	inc	r5
   0692 8D 04              2338 	mov	ar4,r5
   0694 80 D0              2339 	sjmp	00116$
   0696                    2340 00119$:
                           2341 ;	../../include/ztex-eeprom.h:299: I2CS |= bmBIT5;		// no ACK
   0696 90 E6 78           2342 	mov	dptr,#_I2CS
   0699 E0                 2343 	movx	a,@dptr
   069A 44 20              2344 	orl	a,#0x20
   069C F0                 2345 	movx	@dptr,a
                           2346 ;	../../include/ztex-eeprom.h:300: i = I2DAT;			// dummy read
   069D 90 E6 79           2347 	mov	dptr,#_I2DAT
   06A0 E0                 2348 	movx	a,@dptr
                           2349 ;	../../include/ztex-eeprom.h:301: if ( i2c_waitRead()) goto mac_eeprom_read_end; 
   06A1 C0 04              2350 	push	ar4
   06A3 12 02 E9           2351 	lcall	_i2c_waitRead
   06A6 E5 82              2352 	mov	a,dpl
   06A8 D0 04              2353 	pop	ar4
   06AA 70 12              2354 	jnz	00115$
                           2355 ;	../../include/ztex-eeprom.h:303: I2CS |= bmBIT6;		// stop bit
   06AC 90 E6 78           2356 	mov	dptr,#_I2CS
   06AF E0                 2357 	movx	a,@dptr
   06B0 44 40              2358 	orl	a,#0x40
   06B2 F0                 2359 	movx	@dptr,a
                           2360 ;	../../include/ztex-eeprom.h:304: i = I2DAT;			// dummy read
   06B3 90 E6 79           2361 	mov	dptr,#_I2DAT
   06B6 E0                 2362 	movx	a,@dptr
                           2363 ;	../../include/ztex-eeprom.h:305: i2c_waitStop();
   06B7 C0 04              2364 	push	ar4
   06B9 12 03 2C           2365 	lcall	_i2c_waitStop
   06BC D0 04              2366 	pop	ar4
                           2367 ;	../../include/ztex-eeprom.h:307: mac_eeprom_read_end:
   06BE                    2368 00115$:
                           2369 ;	../../include/ztex-eeprom.h:308: return bytes;
   06BE 8C 82              2370 	mov	dpl,r4
   06C0 22                 2371 	ret
                           2372 ;------------------------------------------------------------
                           2373 ;Allocation info for local variables in function 'mac_eeprom_write'
                           2374 ;------------------------------------------------------------
                           2375 ;addr                      Allocated with name '_mac_eeprom_write_PARM_2'
                           2376 ;length                    Allocated with name '_mac_eeprom_write_PARM_3'
                           2377 ;buf                       Allocated to registers r2 r3 
                           2378 ;bytes                     Allocated to registers r4 
                           2379 ;------------------------------------------------------------
                           2380 ;	../../include/ztex-eeprom.h:317: BYTE mac_eeprom_write ( __xdata BYTE *buf, BYTE addr, BYTE length ) {
                           2381 ;	-----------------------------------------
                           2382 ;	 function mac_eeprom_write
                           2383 ;	-----------------------------------------
   06C1                    2384 _mac_eeprom_write:
   06C1 AA 82              2385 	mov	r2,dpl
   06C3 AB 83              2386 	mov	r3,dph
                           2387 ;	../../include/ztex-eeprom.h:318: BYTE bytes = 0;
   06C5 7C 00              2388 	mov	r4,#0x00
                           2389 ;	../../include/ztex-eeprom.h:320: if ( length == 0 ) 
   06C7 E5 13              2390 	mov	a,_mac_eeprom_write_PARM_3
                           2391 ;	../../include/ztex-eeprom.h:321: return 0;
   06C9 70 03              2392 	jnz	00102$
   06CB F5 82              2393 	mov	dpl,a
   06CD 22                 2394 	ret
   06CE                    2395 00102$:
                           2396 ;	../../include/ztex-eeprom.h:323: if ( eeprom_select(EEPROM_MAC_ADDR, 100,0) ) 
   06CE 75 08 64           2397 	mov	_eeprom_select_PARM_2,#0x64
   06D1 75 09 00           2398 	mov	_eeprom_select_PARM_3,#0x00
   06D4 75 82 A6           2399 	mov	dpl,#0xA6
   06D7 C0 02              2400 	push	ar2
   06D9 C0 03              2401 	push	ar3
   06DB C0 04              2402 	push	ar4
   06DD 12 03 46           2403 	lcall	_eeprom_select
   06E0 E5 82              2404 	mov	a,dpl
   06E2 D0 04              2405 	pop	ar4
   06E4 D0 03              2406 	pop	ar3
   06E6 D0 02              2407 	pop	ar2
   06E8 60 03              2408 	jz	00132$
   06EA 02 07 B0           2409 	ljmp	00119$
   06ED                    2410 00132$:
                           2411 ;	../../include/ztex-eeprom.h:326: I2DAT = addr;          	// write address
   06ED 90 E6 79           2412 	mov	dptr,#_I2DAT
   06F0 E5 12              2413 	mov	a,_mac_eeprom_write_PARM_2
   06F2 F0                 2414 	movx	@dptr,a
                           2415 ;	../../include/ztex-eeprom.h:327: if ( i2c_waitWrite() ) goto mac_eeprom_write_end;
   06F3 C0 02              2416 	push	ar2
   06F5 C0 03              2417 	push	ar3
   06F7 C0 04              2418 	push	ar4
   06F9 12 02 BC           2419 	lcall	_i2c_waitWrite
   06FC E5 82              2420 	mov	a,dpl
   06FE D0 04              2421 	pop	ar4
   0700 D0 03              2422 	pop	ar3
   0702 D0 02              2423 	pop	ar2
   0704 60 03              2424 	jz	00133$
   0706 02 07 B0           2425 	ljmp	00119$
   0709                    2426 00133$:
                           2427 ;	../../include/ztex-eeprom.h:329: while ( bytes<length ) {
   0709 AD 12              2428 	mov	r5,_mac_eeprom_write_PARM_2
   070B 7E 00              2429 	mov	r6,#0x00
   070D                    2430 00116$:
   070D C3                 2431 	clr	c
   070E EE                 2432 	mov	a,r6
   070F 95 13              2433 	subb	a,_mac_eeprom_write_PARM_3
   0711 40 03              2434 	jc	00134$
   0713 02 07 A2           2435 	ljmp	00118$
   0716                    2436 00134$:
                           2437 ;	../../include/ztex-eeprom.h:330: I2DAT = *buf;         	// write data 
   0716 8A 82              2438 	mov	dpl,r2
   0718 8B 83              2439 	mov	dph,r3
   071A E0                 2440 	movx	a,@dptr
   071B FF                 2441 	mov	r7,a
   071C A3                 2442 	inc	dptr
   071D AA 82              2443 	mov	r2,dpl
   071F AB 83              2444 	mov	r3,dph
   0721 90 E6 79           2445 	mov	dptr,#_I2DAT
   0724 EF                 2446 	mov	a,r7
   0725 F0                 2447 	movx	@dptr,a
                           2448 ;	../../include/ztex-eeprom.h:331: buf++;
                           2449 ;	../../include/ztex-eeprom.h:332: if ( i2c_waitWrite() ) goto mac_eeprom_write_end;
   0726 C0 02              2450 	push	ar2
   0728 C0 03              2451 	push	ar3
   072A C0 04              2452 	push	ar4
   072C C0 05              2453 	push	ar5
   072E C0 06              2454 	push	ar6
   0730 12 02 BC           2455 	lcall	_i2c_waitWrite
   0733 E5 82              2456 	mov	a,dpl
   0735 D0 06              2457 	pop	ar6
   0737 D0 05              2458 	pop	ar5
   0739 D0 04              2459 	pop	ar4
   073B D0 03              2460 	pop	ar3
   073D D0 02              2461 	pop	ar2
   073F 70 6F              2462 	jnz	00119$
                           2463 ;	../../include/ztex-eeprom.h:334: addr++;
   0741 0D                 2464 	inc	r5
   0742 8D 12              2465 	mov	_mac_eeprom_write_PARM_2,r5
                           2466 ;	../../include/ztex-eeprom.h:335: bytes++;
   0744 0E                 2467 	inc	r6
   0745 8E 04              2468 	mov	ar4,r6
                           2469 ;	../../include/ztex-eeprom.h:336: if ( ( (addr & 8) == 0 ) && ( bytes<length ) ) {
   0747 ED                 2470 	mov	a,r5
   0748 20 E3 C2           2471 	jb	acc.3,00116$
   074B C3                 2472 	clr	c
   074C EE                 2473 	mov	a,r6
   074D 95 13              2474 	subb	a,_mac_eeprom_write_PARM_3
   074F 50 BC              2475 	jnc	00116$
                           2476 ;	../../include/ztex-eeprom.h:337: I2CS |= bmBIT6;		// stop bit
   0751 90 E6 78           2477 	mov	dptr,#_I2CS
   0754 E0                 2478 	movx	a,@dptr
   0755 44 40              2479 	orl	a,#0x40
   0757 F0                 2480 	movx	@dptr,a
                           2481 ;	../../include/ztex-eeprom.h:338: i2c_waitStop();
   0758 C0 02              2482 	push	ar2
   075A C0 03              2483 	push	ar3
   075C C0 04              2484 	push	ar4
   075E C0 05              2485 	push	ar5
   0760 C0 06              2486 	push	ar6
   0762 12 03 2C           2487 	lcall	_i2c_waitStop
                           2488 ;	../../include/ztex-eeprom.h:340: if ( eeprom_select(EEPROM_MAC_ADDR, 100,0) ) 
   0765 75 08 64           2489 	mov	_eeprom_select_PARM_2,#0x64
   0768 75 09 00           2490 	mov	_eeprom_select_PARM_3,#0x00
   076B 75 82 A6           2491 	mov	dpl,#0xA6
   076E 12 03 46           2492 	lcall	_eeprom_select
   0771 E5 82              2493 	mov	a,dpl
   0773 D0 06              2494 	pop	ar6
   0775 D0 05              2495 	pop	ar5
   0777 D0 04              2496 	pop	ar4
   0779 D0 03              2497 	pop	ar3
   077B D0 02              2498 	pop	ar2
   077D 70 31              2499 	jnz	00119$
                           2500 ;	../../include/ztex-eeprom.h:343: I2DAT = addr;          	// write address
   077F 90 E6 79           2501 	mov	dptr,#_I2DAT
   0782 ED                 2502 	mov	a,r5
   0783 F0                 2503 	movx	@dptr,a
                           2504 ;	../../include/ztex-eeprom.h:344: if ( i2c_waitWrite() ) goto mac_eeprom_write_end;
   0784 C0 02              2505 	push	ar2
   0786 C0 03              2506 	push	ar3
   0788 C0 04              2507 	push	ar4
   078A C0 05              2508 	push	ar5
   078C C0 06              2509 	push	ar6
   078E 12 02 BC           2510 	lcall	_i2c_waitWrite
   0791 E5 82              2511 	mov	a,dpl
   0793 D0 06              2512 	pop	ar6
   0795 D0 05              2513 	pop	ar5
   0797 D0 04              2514 	pop	ar4
   0799 D0 03              2515 	pop	ar3
   079B D0 02              2516 	pop	ar2
   079D 70 11              2517 	jnz	00119$
   079F 02 07 0D           2518 	ljmp	00116$
   07A2                    2519 00118$:
                           2520 ;	../../include/ztex-eeprom.h:347: I2CS |= bmBIT6;		// stop bit
   07A2 90 E6 78           2521 	mov	dptr,#_I2CS
   07A5 E0                 2522 	movx	a,@dptr
   07A6 44 40              2523 	orl	a,#0x40
   07A8 F0                 2524 	movx	@dptr,a
                           2525 ;	../../include/ztex-eeprom.h:348: i2c_waitStop();
   07A9 C0 04              2526 	push	ar4
   07AB 12 03 2C           2527 	lcall	_i2c_waitStop
   07AE D0 04              2528 	pop	ar4
                           2529 ;	../../include/ztex-eeprom.h:350: mac_eeprom_write_end:
   07B0                    2530 00119$:
                           2531 ;	../../include/ztex-eeprom.h:351: mac_eeprom_addr = addr;
   07B0 90 3A 05           2532 	mov	dptr,#_mac_eeprom_addr
   07B3 E5 12              2533 	mov	a,_mac_eeprom_write_PARM_2
   07B5 F0                 2534 	movx	@dptr,a
                           2535 ;	../../include/ztex-eeprom.h:352: return bytes;
   07B6 8C 82              2536 	mov	dpl,r4
   07B8 22                 2537 	ret
                           2538 ;------------------------------------------------------------
                           2539 ;Allocation info for local variables in function 'mac_eeprom_read_ep0'
                           2540 ;------------------------------------------------------------
                           2541 ;i                         Allocated to registers r3 
                           2542 ;b                         Allocated to registers r2 
                           2543 ;------------------------------------------------------------
                           2544 ;	../../include/ztex-eeprom.h:358: BYTE mac_eeprom_read_ep0 () { 
                           2545 ;	-----------------------------------------
                           2546 ;	 function mac_eeprom_read_ep0
                           2547 ;	-----------------------------------------
   07B9                    2548 _mac_eeprom_read_ep0:
                           2549 ;	../../include/ztex-eeprom.h:360: b = ep0_payload_transfer;
   07B9 90 3A 38           2550 	mov	dptr,#_ep0_payload_transfer
   07BC E0                 2551 	movx	a,@dptr
   07BD FA                 2552 	mov	r2,a
                           2553 ;	../../include/ztex-eeprom.h:361: i = mac_eeprom_read(EP0BUF, mac_eeprom_addr, b);
   07BE 90 3A 05           2554 	mov	dptr,#_mac_eeprom_addr
   07C1 E0                 2555 	movx	a,@dptr
   07C2 F5 10              2556 	mov	_mac_eeprom_read_PARM_2,a
   07C4 8A 11              2557 	mov	_mac_eeprom_read_PARM_3,r2
   07C6 90 E7 40           2558 	mov	dptr,#_EP0BUF
   07C9 C0 02              2559 	push	ar2
   07CB 12 05 D4           2560 	lcall	_mac_eeprom_read
   07CE AB 82              2561 	mov	r3,dpl
   07D0 D0 02              2562 	pop	ar2
                           2563 ;	../../include/ztex-eeprom.h:362: mac_eeprom_addr += b;
   07D2 90 3A 05           2564 	mov	dptr,#_mac_eeprom_addr
   07D5 E0                 2565 	movx	a,@dptr
   07D6 FC                 2566 	mov	r4,a
   07D7 EA                 2567 	mov	a,r2
   07D8 2C                 2568 	add	a,r4
   07D9 F0                 2569 	movx	@dptr,a
                           2570 ;	../../include/ztex-eeprom.h:363: return i;
   07DA 8B 82              2571 	mov	dpl,r3
   07DC 22                 2572 	ret
                           2573 ;------------------------------------------------------------
                           2574 ;Allocation info for local variables in function 'spi_clocks'
                           2575 ;------------------------------------------------------------
                           2576 ;c                         Allocated to registers 
                           2577 ;------------------------------------------------------------
                           2578 ;	../../include/ztex-flash2.h:98: void spi_clocks (BYTE c) {
                           2579 ;	-----------------------------------------
                           2580 ;	 function spi_clocks
                           2581 ;	-----------------------------------------
   07DD                    2582 _spi_clocks:
                           2583 ;	../../include/ztex-flash2.h:110: }
                           2584 	
   07DD AA 82              2585 	 mov r2,dpl
   07DF                    2586 	010014$:
   07DF D2 80              2587 	        setb _IOA0
   07E1 00                 2588 	        nop
   07E2 00                 2589 	        nop
   07E3 00                 2590 	        nop
   07E4 C2 80              2591 	        clr _IOA0
   07E6 DA F7              2592 	 djnz r2,010014$
                           2593 ;	# 109 "../../include/ztex-flash2.h"
   07E8 22                 2594 	ret
                           2595 ;------------------------------------------------------------
                           2596 ;Allocation info for local variables in function 'flash_read_byte'
                           2597 ;------------------------------------------------------------
                           2598 ;------------------------------------------------------------
                           2599 ;	../../include/ztex-flash2.h:118: __asm  
                           2600 ;	-----------------------------------------
                           2601 ;	 function flash_read_byte
                           2602 ;	-----------------------------------------
   07E9                    2603 _flash_read_byte:
                           2604 ;	../../include/ztex-flash2.h:169: void flash_read(__xdata BYTE *buf, BYTE len) {
                           2605 	
                           2606 	
   07E9 A2 A0              2607 	 mov c,_IOC0
                           2608 ;	# 121 "../../include/ztex-flash2.h"
   07EB D2 80              2609 	        setb _IOA0
   07ED 33                 2610 	        rlc a
   07EE C2 80              2611 	        clr _IOA0
                           2612 	
   07F0 A2 A0              2613 	        mov c,_IOC0
                           2614 ;	# 126 "../../include/ztex-flash2.h"
   07F2 D2 80              2615 	        setb _IOA0
   07F4 33                 2616 	        rlc a
   07F5 C2 80              2617 	        clr _IOA0
                           2618 	
   07F7 A2 A0              2619 	        mov c,_IOC0
                           2620 ;	# 131 "../../include/ztex-flash2.h"
   07F9 D2 80              2621 	        setb _IOA0
   07FB 33                 2622 	        rlc a
   07FC C2 80              2623 	        clr _IOA0
                           2624 	
   07FE A2 A0              2625 	        mov c,_IOC0
                           2626 ;	# 136 "../../include/ztex-flash2.h"
   0800 D2 80              2627 	        setb _IOA0
   0802 33                 2628 	        rlc a
   0803 C2 80              2629 	        clr _IOA0
                           2630 	
   0805 A2 A0              2631 	        mov c,_IOC0
                           2632 ;	# 141 "../../include/ztex-flash2.h"
   0807 D2 80              2633 	        setb _IOA0
   0809 33                 2634 	        rlc a
   080A C2 80              2635 	        clr _IOA0
                           2636 	
   080C A2 A0              2637 	        mov c,_IOC0
                           2638 ;	# 146 "../../include/ztex-flash2.h"
   080E D2 80              2639 	        setb _IOA0
   0810 33                 2640 	        rlc a
   0811 C2 80              2641 	        clr _IOA0
                           2642 	
   0813 A2 A0              2643 	        mov c,_IOC0
                           2644 ;	# 151 "../../include/ztex-flash2.h"
   0815 D2 80              2645 	        setb _IOA0
   0817 33                 2646 	        rlc a
   0818 C2 80              2647 	        clr _IOA0
                           2648 	
   081A A2 A0              2649 	        mov c,_IOC0
                           2650 ;	# 156 "../../include/ztex-flash2.h"
   081C D2 80              2651 	        setb _IOA0
   081E 33                 2652 	        rlc a
   081F C2 80              2653 	        clr _IOA0
   0821 F5 82              2654 	        mov dpl,a
   0823 22                 2655 	        ret
                           2656 ;	../../include/ztex-flash2.h:170: *buf;					// this avoids stupid warnings
   0824 75 82 00           2657 	mov	dpl,#0x00
   0827 22                 2658 	ret
                           2659 ;------------------------------------------------------------
                           2660 ;Allocation info for local variables in function 'flash_read'
                           2661 ;------------------------------------------------------------
                           2662 ;len                       Allocated with name '_flash_read_PARM_2'
                           2663 ;buf                       Allocated to registers 
                           2664 ;------------------------------------------------------------
                           2665 ;	../../include/ztex-flash2.h:169: void flash_read(__xdata BYTE *buf, BYTE len) {
                           2666 ;	-----------------------------------------
                           2667 ;	 function flash_read
                           2668 ;	-----------------------------------------
   0828                    2669 _flash_read:
                           2670 ;	../../include/ztex-flash2.h:228: __asm
                           2671 	
                           2672 ;	# 173 "../../include/ztex-flash2.h"
   0828 AA 16              2673 	 mov r2,_flash_read_PARM_2
   082A                    2674 	010012$:
                           2675 	
   082A A2 A0              2676 	 mov c,_IOC0
                           2677 ;	# 177 "../../include/ztex-flash2.h"
   082C D2 80              2678 	        setb _IOA0
   082E 33                 2679 	        rlc a
   082F C2 80              2680 	        clr _IOA0
                           2681 	
   0831 A2 A0              2682 	        mov c,_IOC0
                           2683 ;	# 182 "../../include/ztex-flash2.h"
   0833 D2 80              2684 	        setb _IOA0
   0835 33                 2685 	        rlc a
   0836 C2 80              2686 	        clr _IOA0
                           2687 	
   0838 A2 A0              2688 	        mov c,_IOC0
                           2689 ;	# 187 "../../include/ztex-flash2.h"
   083A D2 80              2690 	        setb _IOA0
   083C 33                 2691 	        rlc a
   083D C2 80              2692 	        clr _IOA0
                           2693 	
   083F A2 A0              2694 	        mov c,_IOC0
                           2695 ;	# 192 "../../include/ztex-flash2.h"
   0841 D2 80              2696 	        setb _IOA0
   0843 33                 2697 	        rlc a
   0844 C2 80              2698 	        clr _IOA0
                           2699 	
   0846 A2 A0              2700 	        mov c,_IOC0
                           2701 ;	# 197 "../../include/ztex-flash2.h"
   0848 D2 80              2702 	        setb _IOA0
   084A 33                 2703 	        rlc a
   084B C2 80              2704 	        clr _IOA0
                           2705 	
   084D A2 A0              2706 	        mov c,_IOC0
                           2707 ;	# 202 "../../include/ztex-flash2.h"
   084F D2 80              2708 	        setb _IOA0
   0851 33                 2709 	        rlc a
   0852 C2 80              2710 	        clr _IOA0
                           2711 	
   0854 A2 A0              2712 	        mov c,_IOC0
                           2713 ;	# 207 "../../include/ztex-flash2.h"
   0856 D2 80              2714 	        setb _IOA0
   0858 33                 2715 	        rlc a
   0859 C2 80              2716 	        clr _IOA0
                           2717 	
   085B A2 A0              2718 	        mov c,_IOC0
                           2719 ;	# 212 "../../include/ztex-flash2.h"
   085D D2 80              2720 	        setb _IOA0
   085F 33                 2721 	        rlc a
   0860 C2 80              2722 	        clr _IOA0
                           2723 	
   0862 F0                 2724 	 movx @dptr,a
   0863 A3                 2725 	 inc dptr
   0864 DA C4              2726 	 djnz r2,010012$
   0866 22                 2727 	ret
                           2728 ;------------------------------------------------------------
                           2729 ;Allocation info for local variables in function 'spi_write_byte'
                           2730 ;------------------------------------------------------------
                           2731 ;b                         Allocated to registers 
                           2732 ;------------------------------------------------------------
                           2733 ;	../../include/ztex-flash2.h:235: rlc	a		// 6
                           2734 ;	-----------------------------------------
                           2735 ;	 function spi_write_byte
                           2736 ;	-----------------------------------------
   0867                    2737 _spi_write_byte:
                           2738 ;	../../include/ztex-flash2.h:280: *buf;					// this avoids stupid warnings
                           2739 	
                           2740 ;	# 230 "../../include/ztex-flash2.h"
   0867 E5 82              2741 	 mov a,dpl
   0869 33                 2742 	 rlc a
                           2743 ;	# 232 "../../include/ztex-flash2.h"
                           2744 	
   086A 92 81              2745 	 mov _IOA1,c
   086C D2 80              2746 	        setb _IOA0
   086E 33                 2747 	 rlc a
                           2748 ;	# 236 "../../include/ztex-flash2.h"
   086F C2 80              2749 	        clr _IOA0
                           2750 	
   0871 92 81              2751 	 mov _IOA1,c
   0873 D2 80              2752 	        setb _IOA0
   0875 33                 2753 	 rlc a
                           2754 ;	# 241 "../../include/ztex-flash2.h"
   0876 C2 80              2755 	        clr _IOA0
                           2756 	
   0878 92 81              2757 	 mov _IOA1,c
   087A D2 80              2758 	        setb _IOA0
   087C 33                 2759 	 rlc a
                           2760 ;	# 246 "../../include/ztex-flash2.h"
   087D C2 80              2761 	        clr _IOA0
                           2762 	
   087F 92 81              2763 	 mov _IOA1,c
   0881 D2 80              2764 	        setb _IOA0
   0883 33                 2765 	 rlc a
                           2766 ;	# 251 "../../include/ztex-flash2.h"
   0884 C2 80              2767 	        clr _IOA0
                           2768 	
   0886 92 81              2769 	 mov _IOA1,c
   0888 D2 80              2770 	        setb _IOA0
   088A 33                 2771 	 rlc a
                           2772 ;	# 256 "../../include/ztex-flash2.h"
   088B C2 80              2773 	        clr _IOA0
                           2774 	
   088D 92 81              2775 	 mov _IOA1,c
   088F D2 80              2776 	        setb _IOA0
   0891 33                 2777 	 rlc a
                           2778 ;	# 261 "../../include/ztex-flash2.h"
   0892 C2 80              2779 	        clr _IOA0
                           2780 	
   0894 92 81              2781 	 mov _IOA1,c
   0896 D2 80              2782 	        setb _IOA0
   0898 33                 2783 	 rlc a
                           2784 ;	# 266 "../../include/ztex-flash2.h"
   0899 C2 80              2785 	        clr _IOA0
                           2786 	
   089B 92 81              2787 	 mov _IOA1,c
   089D D2 80              2788 	        setb _IOA0
   089F 00                 2789 	 nop
   08A0 C2 80              2790 	        clr _IOA0
   08A2 22                 2791 	ret
                           2792 ;------------------------------------------------------------
                           2793 ;Allocation info for local variables in function 'spi_write'
                           2794 ;------------------------------------------------------------
                           2795 ;len                       Allocated with name '_spi_write_PARM_2'
                           2796 ;buf                       Allocated to registers 
                           2797 ;------------------------------------------------------------
                           2798 ;	../../include/ztex-flash2.h:279: void spi_write(__xdata BYTE *buf, BYTE len) {
                           2799 ;	-----------------------------------------
                           2800 ;	 function spi_write
                           2801 ;	-----------------------------------------
   08A3                    2802 _spi_write:
                           2803 ;	../../include/ztex-flash2.h:339: void spi_select() {
                           2804 	
                           2805 ;	# 283 "../../include/ztex-flash2.h"
   08A3 AA 16              2806 	 mov r2,_flash_read_PARM_2
   08A5                    2807 	010013$:
                           2808 ;	# 286 "../../include/ztex-flash2.h"
   08A5 E0                 2809 	 movx a,@dptr
   08A6 33                 2810 	 rlc a
                           2811 ;	# 288 "../../include/ztex-flash2.h"
                           2812 	
   08A7 92 81              2813 	 mov _IOA1,c
   08A9 D2 80              2814 	        setb _IOA0
   08AB 33                 2815 	 rlc a
                           2816 ;	# 292 "../../include/ztex-flash2.h"
   08AC C2 80              2817 	        clr _IOA0
                           2818 	
   08AE 92 81              2819 	 mov _IOA1,c
   08B0 D2 80              2820 	        setb _IOA0
   08B2 33                 2821 	 rlc a
                           2822 ;	# 297 "../../include/ztex-flash2.h"
   08B3 C2 80              2823 	        clr _IOA0
                           2824 	
   08B5 92 81              2825 	 mov _IOA1,c
   08B7 D2 80              2826 	        setb _IOA0
   08B9 33                 2827 	 rlc a
                           2828 ;	# 302 "../../include/ztex-flash2.h"
   08BA C2 80              2829 	        clr _IOA0
                           2830 	
   08BC 92 81              2831 	 mov _IOA1,c
   08BE D2 80              2832 	        setb _IOA0
   08C0 33                 2833 	 rlc a
                           2834 ;	# 307 "../../include/ztex-flash2.h"
   08C1 C2 80              2835 	        clr _IOA0
                           2836 	
   08C3 92 81              2837 	 mov _IOA1,c
   08C5 D2 80              2838 	        setb _IOA0
   08C7 33                 2839 	 rlc a
                           2840 ;	# 312 "../../include/ztex-flash2.h"
   08C8 C2 80              2841 	        clr _IOA0
                           2842 	
   08CA 92 81              2843 	 mov _IOA1,c
   08CC D2 80              2844 	        setb _IOA0
   08CE 33                 2845 	 rlc a
                           2846 ;	# 317 "../../include/ztex-flash2.h"
   08CF C2 80              2847 	        clr _IOA0
                           2848 	
   08D1 92 81              2849 	 mov _IOA1,c
   08D3 D2 80              2850 	        setb _IOA0
   08D5 33                 2851 	 rlc a
                           2852 ;	# 322 "../../include/ztex-flash2.h"
   08D6 C2 80              2853 	        clr _IOA0
                           2854 	
   08D8 92 81              2855 	 mov _IOA1,c
   08DA D2 80              2856 	        setb _IOA0
   08DC A3                 2857 	 inc dptr
   08DD C2 80              2858 	        clr _IOA0
                           2859 	
   08DF DA C4              2860 	 djnz r2,010013$
   08E1 22                 2861 	ret
                           2862 ;------------------------------------------------------------
                           2863 ;Allocation info for local variables in function 'spi_select'
                           2864 ;------------------------------------------------------------
                           2865 ;------------------------------------------------------------
                           2866 ;	../../include/ztex-flash2.h:348: // de-select the flash (CS)
                           2867 ;	-----------------------------------------
                           2868 ;	 function spi_select
                           2869 ;	-----------------------------------------
   08E2                    2870 _spi_select:
                           2871 ;	../../include/ztex-flash2.h:349: void spi_deselect() {
   08E2 D2 83              2872 	setb	_IOA3
                           2873 ;	../../include/ztex-flash2.h:350: SPI_CS = 1;					// CS = 1;
   08E4 75 82 08           2874 	mov	dpl,#0x08
   08E7 12 07 DD           2875 	lcall	_spi_clocks
                           2876 ;	../../include/ztex-flash2.h:342: SPI_CS = 0;
   08EA C2 83              2877 	clr	_IOA3
   08EC 22                 2878 	ret
                           2879 ;------------------------------------------------------------
                           2880 ;Allocation info for local variables in function 'spi_deselect'
                           2881 ;------------------------------------------------------------
                           2882 ;------------------------------------------------------------
                           2883 ;	../../include/ztex-flash2.h:349: void spi_deselect() {
                           2884 ;	-----------------------------------------
                           2885 ;	 function spi_deselect
                           2886 ;	-----------------------------------------
   08ED                    2887 _spi_deselect:
                           2888 ;	../../include/ztex-flash2.h:350: SPI_CS = 1;					// CS = 1;
   08ED D2 83              2889 	setb	_IOA3
                           2890 ;	../../include/ztex-flash2.h:351: spi_clocks(8);				// 8 dummy clocks to finish a previous command
   08EF 75 82 08           2891 	mov	dpl,#0x08
   08F2 02 07 DD           2892 	ljmp	_spi_clocks
                           2893 ;------------------------------------------------------------
                           2894 ;Allocation info for local variables in function 'spi_wait'
                           2895 ;------------------------------------------------------------
                           2896 ;i                         Allocated to registers r2 r3 
                           2897 ;------------------------------------------------------------
                           2898 ;	../../include/ztex-flash2.h:371: BYTE spi_wait() {
                           2899 ;	-----------------------------------------
                           2900 ;	 function spi_wait
                           2901 ;	-----------------------------------------
   08F5                    2902 _spi_wait:
                           2903 ;	../../include/ztex-flash2.h:359: spi_last_cmd = $0;
   08F5 90 3A 13           2904 	mov	dptr,#_spi_last_cmd
   08F8 74 05              2905 	mov	a,#0x05
   08FA F0                 2906 	movx	@dptr,a
                           2907 ;	../../include/ztex-flash2.h:360: spi_select();				// select
   08FB 12 08 E2           2908 	lcall	_spi_select
                           2909 ;	../../include/ztex-flash2.h:361: spi_write_byte($0);				// CMD 90h
   08FE 75 82 05           2910 	mov	dpl,#0x05
   0901 12 08 67           2911 	lcall	_spi_write_byte
                           2912 ;	../../include/ztex-flash2.h:375: for (i=0; (flash_read_byte() & bmBIT0) && i<65535; i++ ) { 
   0904 7A 00              2913 	mov	r2,#0x00
   0906 7B 00              2914 	mov	r3,#0x00
   0908                    2915 00102$:
   0908 C0 02              2916 	push	ar2
   090A C0 03              2917 	push	ar3
   090C 12 07 E9           2918 	lcall	_flash_read_byte
   090F E5 82              2919 	mov	a,dpl
   0911 D0 03              2920 	pop	ar3
   0913 D0 02              2921 	pop	ar2
   0915 30 E0 2E           2922 	jnb	acc.0,00105$
   0918 8A 04              2923 	mov	ar4,r2
   091A 8B 05              2924 	mov	ar5,r3
   091C 7E 00              2925 	mov	r6,#0x00
   091E 7F 00              2926 	mov	r7,#0x00
   0920 C3                 2927 	clr	c
   0921 EC                 2928 	mov	a,r4
   0922 94 FF              2929 	subb	a,#0xFF
   0924 ED                 2930 	mov	a,r5
   0925 94 FF              2931 	subb	a,#0xFF
   0927 EE                 2932 	mov	a,r6
   0928 94 00              2933 	subb	a,#0x00
   092A EF                 2934 	mov	a,r7
   092B 64 80              2935 	xrl	a,#0x80
   092D 94 80              2936 	subb	a,#0x80
   092F 50 15              2937 	jnc	00105$
                           2938 ;	../../include/ztex-flash2.h:376: spi_clocks(0);				// 256 dummy clocks
   0931 75 82 00           2939 	mov	dpl,#0x00
   0934 C0 02              2940 	push	ar2
   0936 C0 03              2941 	push	ar3
   0938 12 07 DD           2942 	lcall	_spi_clocks
   093B D0 03              2943 	pop	ar3
   093D D0 02              2944 	pop	ar2
                           2945 ;	../../include/ztex-flash2.h:375: for (i=0; (flash_read_byte() & bmBIT0) && i<65535; i++ ) { 
   093F 0A                 2946 	inc	r2
   0940 BA 00 C5           2947 	cjne	r2,#0x00,00102$
   0943 0B                 2948 	inc	r3
   0944 80 C2              2949 	sjmp	00102$
   0946                    2950 00105$:
                           2951 ;	../../include/ztex-flash2.h:379: flash_ec = flash_read_byte() & bmBIT0 ? FLASH_EC_TIMEOUT : 0;
   0946 12 07 E9           2952 	lcall	_flash_read_byte
   0949 E5 82              2953 	mov	a,dpl
   094B 30 E0 04           2954 	jnb	acc.0,00108$
   094E 7A 02              2955 	mov	r2,#0x02
   0950 80 02              2956 	sjmp	00109$
   0952                    2957 00108$:
   0952 7A 00              2958 	mov	r2,#0x00
   0954                    2959 00109$:
   0954 90 3A 0E           2960 	mov	dptr,#_flash_ec
   0957 EA                 2961 	mov	a,r2
   0958 F0                 2962 	movx	@dptr,a
                           2963 ;	../../include/ztex-flash2.h:380: spi_deselect();
   0959 12 08 ED           2964 	lcall	_spi_deselect
                           2965 ;	../../include/ztex-flash2.h:381: return flash_ec;
   095C 90 3A 0E           2966 	mov	dptr,#_flash_ec
   095F E0                 2967 	movx	a,@dptr
   0960 F5 82              2968 	mov	dpl,a
   0962 22                 2969 	ret
                           2970 ;------------------------------------------------------------
                           2971 ;Allocation info for local variables in function 'flash_read_init'
                           2972 ;------------------------------------------------------------
                           2973 ;s                         Allocated to registers r2 r3 
                           2974 ;------------------------------------------------------------
                           2975 ;	../../include/ztex-flash2.h:391: BYTE flash_read_init(WORD s) {
                           2976 ;	-----------------------------------------
                           2977 ;	 function flash_read_init
                           2978 ;	-----------------------------------------
   0963                    2979 _flash_read_init:
   0963 AA 82              2980 	mov	r2,dpl
   0965 AB 83              2981 	mov	r3,dph
                           2982 ;	../../include/ztex-flash2.h:396: OESPI_OPORT &= ~bmBITSPI_BIT_DO;
   0967 20 83 0A           2983 	jb	_IOA3,00102$
                           2984 ;	../../include/ztex-flash2.h:393: flash_ec = FLASH_EC_PENDING;
   096A 90 3A 0E           2985 	mov	dptr,#_flash_ec
   096D 74 04              2986 	mov	a,#0x04
   096F F0                 2987 	movx	@dptr,a
                           2988 ;	../../include/ztex-flash2.h:394: return FLASH_EC_PENDING;		// we interrupted a pending Flash operation
   0970 75 82 04           2989 	mov	dpl,#0x04
   0973 22                 2990 	ret
   0974                    2991 00102$:
                           2992 ;	../../include/ztex-flash2.h:396: OESPI_OPORT &= ~bmBITSPI_BIT_DO;
   0974 53 B4 FE           2993 	anl	_OEC,#0xFE
                           2994 ;	../../include/ztex-flash2.h:397: OESPI_PORT |= bmBITSPI_BIT_CS | bmBITSPI_BIT_DI | bmBITSPI_BIT_CLK;
   0977 43 B2 0B           2995 	orl	_OEA,#0x0B
                           2996 ;	../../include/ztex-flash2.h:398: if ( spi_wait() ) {
   097A C0 02              2997 	push	ar2
   097C C0 03              2998 	push	ar3
   097E 12 08 F5           2999 	lcall	_spi_wait
   0981 E5 82              3000 	mov	a,dpl
   0983 D0 03              3001 	pop	ar3
   0985 D0 02              3002 	pop	ar2
   0987 60 07              3003 	jz	00104$
                           3004 ;	../../include/ztex-flash2.h:399: return flash_ec;
   0989 90 3A 0E           3005 	mov	dptr,#_flash_ec
   098C E0                 3006 	movx	a,@dptr
   098D F5 82              3007 	mov	dpl,a
   098F 22                 3008 	ret
   0990                    3009 00104$:
                           3010 ;	../../include/ztex-flash2.h:402: s = s << ((BYTE)flash_sector_size - 8);     
   0990 90 3A 08           3011 	mov	dptr,#_flash_sector_size
   0993 E0                 3012 	movx	a,@dptr
   0994 FC                 3013 	mov	r4,a
   0995 A3                 3014 	inc	dptr
   0996 E0                 3015 	movx	a,@dptr
   0997 7D 00              3016 	mov	r5,#0x00
   0999 EC                 3017 	mov	a,r4
   099A 24 F8              3018 	add	a,#0xf8
   099C FC                 3019 	mov	r4,a
   099D ED                 3020 	mov	a,r5
   099E 34 FF              3021 	addc	a,#0xff
   09A0 FD                 3022 	mov	r5,a
   09A1 8C F0              3023 	mov	b,r4
   09A3 05 F0              3024 	inc	b
   09A5 80 06              3025 	sjmp	00112$
   09A7                    3026 00111$:
   09A7 EA                 3027 	mov	a,r2
   09A8 2A                 3028 	add	a,r2
   09A9 FA                 3029 	mov	r2,a
   09AA EB                 3030 	mov	a,r3
   09AB 33                 3031 	rlc	a
   09AC FB                 3032 	mov	r3,a
   09AD                    3033 00112$:
   09AD D5 F0 F7           3034 	djnz	b,00111$
                           3035 ;	../../include/ztex-flash2.h:359: spi_last_cmd = $0;
   09B0 90 3A 13           3036 	mov	dptr,#_spi_last_cmd
   09B3 74 0B              3037 	mov	a,#0x0B
   09B5 F0                 3038 	movx	@dptr,a
                           3039 ;	../../include/ztex-flash2.h:360: spi_select();				// select
   09B6 C0 02              3040 	push	ar2
   09B8 C0 03              3041 	push	ar3
   09BA 12 08 E2           3042 	lcall	_spi_select
                           3043 ;	../../include/ztex-flash2.h:361: spi_write_byte($0);				// CMD 90h
   09BD 75 82 0B           3044 	mov	dpl,#0x0B
   09C0 12 08 67           3045 	lcall	_spi_write_byte
   09C3 D0 03              3046 	pop	ar3
                           3047 ;	../../include/ztex-flash2.h:363: 
   09C5 8B 82              3048 	mov	dpl,r3
   09C7 C0 03              3049 	push	ar3
   09C9 12 08 67           3050 	lcall	_spi_write_byte
   09CC D0 03              3051 	pop	ar3
   09CE D0 02              3052 	pop	ar2
                           3053 ;	../../include/ztex-flash2.h:405: spi_write_byte(s & 255);
   09D0 8A 82              3054 	mov	dpl,r2
   09D2 12 08 67           3055 	lcall	_spi_write_byte
                           3056 ;	../../include/ztex-flash2.h:406: spi_write_byte(0);
   09D5 75 82 00           3057 	mov	dpl,#0x00
   09D8 12 08 67           3058 	lcall	_spi_write_byte
                           3059 ;	../../include/ztex-flash2.h:407: spi_clocks(8);				// 8 dummy clocks
   09DB 75 82 08           3060 	mov	dpl,#0x08
   09DE 12 07 DD           3061 	lcall	_spi_clocks
                           3062 ;	../../include/ztex-flash2.h:408: return 0;
   09E1 75 82 00           3063 	mov	dpl,#0x00
   09E4 22                 3064 	ret
                           3065 ;------------------------------------------------------------
                           3066 ;Allocation info for local variables in function 'flash_read_next'
                           3067 ;------------------------------------------------------------
                           3068 ;------------------------------------------------------------
                           3069 ;	../../include/ztex-flash2.h:417: BYTE flash_read_next() {
                           3070 ;	-----------------------------------------
                           3071 ;	 function flash_read_next
                           3072 ;	-----------------------------------------
   09E5                    3073 _flash_read_next:
                           3074 ;	../../include/ztex-flash2.h:418: return 0;
   09E5 75 82 00           3075 	mov	dpl,#0x00
   09E8 22                 3076 	ret
                           3077 ;------------------------------------------------------------
                           3078 ;Allocation info for local variables in function 'flash_read_finish'
                           3079 ;------------------------------------------------------------
                           3080 ;n                         Allocated to registers 
                           3081 ;------------------------------------------------------------
                           3082 ;	../../include/ztex-flash2.h:428: void flash_read_finish(WORD n) {
                           3083 ;	-----------------------------------------
                           3084 ;	 function flash_read_finish
                           3085 ;	-----------------------------------------
   09E9                    3086 _flash_read_finish:
                           3087 ;	../../include/ztex-flash2.h:430: spi_deselect();
   09E9 02 08 ED           3088 	ljmp	_spi_deselect
                           3089 ;------------------------------------------------------------
                           3090 ;Allocation info for local variables in function 'spi_pp'
                           3091 ;------------------------------------------------------------
                           3092 ;------------------------------------------------------------
                           3093 ;	../../include/ztex-flash2.h:437: BYTE spi_pp () {	
                           3094 ;	-----------------------------------------
                           3095 ;	 function spi_pp
                           3096 ;	-----------------------------------------
   09EC                    3097 _spi_pp:
                           3098 ;	../../include/ztex-flash2.h:438: spi_deselect();				// finish previous write cmd
   09EC 12 08 ED           3099 	lcall	_spi_deselect
                           3100 ;	../../include/ztex-flash2.h:440: spi_need_pp = 0;
   09EF 90 3A 1B           3101 	mov	dptr,#_spi_need_pp
   09F2 E4                 3102 	clr	a
   09F3 F0                 3103 	movx	@dptr,a
                           3104 ;	../../include/ztex-flash2.h:442: if ( spi_wait() ) {
   09F4 12 08 F5           3105 	lcall	_spi_wait
   09F7 E5 82              3106 	mov	a,dpl
   09F9 60 07              3107 	jz	00102$
                           3108 ;	../../include/ztex-flash2.h:443: return flash_ec;
   09FB 90 3A 0E           3109 	mov	dptr,#_flash_ec
   09FE E0                 3110 	movx	a,@dptr
   09FF F5 82              3111 	mov	dpl,a
   0A01 22                 3112 	ret
   0A02                    3113 00102$:
                           3114 ;	../../include/ztex-flash2.h:359: spi_last_cmd = $0;
   0A02 90 3A 13           3115 	mov	dptr,#_spi_last_cmd
   0A05 74 06              3116 	mov	a,#0x06
   0A07 F0                 3117 	movx	@dptr,a
                           3118 ;	../../include/ztex-flash2.h:360: spi_select();				// select
   0A08 12 08 E2           3119 	lcall	_spi_select
                           3120 ;	../../include/ztex-flash2.h:361: spi_write_byte($0);				// CMD 90h
   0A0B 75 82 06           3121 	mov	dpl,#0x06
   0A0E 12 08 67           3122 	lcall	_spi_write_byte
                           3123 ;	../../include/ztex-flash2.h:446: spi_deselect();
   0A11 12 08 ED           3124 	lcall	_spi_deselect
                           3125 ;	../../include/ztex-flash2.h:359: spi_last_cmd = $0;
   0A14 90 3A 13           3126 	mov	dptr,#_spi_last_cmd
   0A17 74 02              3127 	mov	a,#0x02
   0A19 F0                 3128 	movx	@dptr,a
                           3129 ;	../../include/ztex-flash2.h:360: spi_select();				// select
   0A1A 12 08 E2           3130 	lcall	_spi_select
                           3131 ;	../../include/ztex-flash2.h:361: spi_write_byte($0);				// CMD 90h
   0A1D 75 82 02           3132 	mov	dpl,#0x02
   0A20 12 08 67           3133 	lcall	_spi_write_byte
                           3134 ;	../../include/ztex-flash2.h:363: 
   0A23 90 3A 18           3135 	mov	dptr,#_spi_write_addr_hi
   0A26 E0                 3136 	movx	a,@dptr
   0A27 A3                 3137 	inc	dptr
   0A28 E0                 3138 	movx	a,@dptr
   0A29 F5 82              3139 	mov	dpl,a
   0A2B 12 08 67           3140 	lcall	_spi_write_byte
                           3141 ;	../../include/ztex-flash2.h:450: spi_write_byte(spi_write_addr_hi & 255);
   0A2E 90 3A 18           3142 	mov	dptr,#_spi_write_addr_hi
   0A31 E0                 3143 	movx	a,@dptr
   0A32 FA                 3144 	mov	r2,a
   0A33 A3                 3145 	inc	dptr
   0A34 E0                 3146 	movx	a,@dptr
   0A35 8A 82              3147 	mov	dpl,r2
   0A37 12 08 67           3148 	lcall	_spi_write_byte
                           3149 ;	../../include/ztex-flash2.h:451: spi_write_byte(0);
   0A3A 75 82 00           3150 	mov	dpl,#0x00
   0A3D 12 08 67           3151 	lcall	_spi_write_byte
                           3152 ;	../../include/ztex-flash2.h:452: return 0;
   0A40 75 82 00           3153 	mov	dpl,#0x00
   0A43 22                 3154 	ret
                           3155 ;------------------------------------------------------------
                           3156 ;Allocation info for local variables in function 'flash_write_byte'
                           3157 ;------------------------------------------------------------
                           3158 ;b                         Allocated to registers r2 
                           3159 ;------------------------------------------------------------
                           3160 ;	../../include/ztex-flash2.h:459: BYTE flash_write_byte (BYTE b) {
                           3161 ;	-----------------------------------------
                           3162 ;	 function flash_write_byte
                           3163 ;	-----------------------------------------
   0A44                    3164 _flash_write_byte:
   0A44 AA 82              3165 	mov	r2,dpl
                           3166 ;	../../include/ztex-flash2.h:460: if ( spi_need_pp && spi_pp() ) return flash_ec;
   0A46 90 3A 1B           3167 	mov	dptr,#_spi_need_pp
   0A49 E0                 3168 	movx	a,@dptr
   0A4A FB                 3169 	mov	r3,a
   0A4B 60 12              3170 	jz	00102$
   0A4D C0 02              3171 	push	ar2
   0A4F 12 09 EC           3172 	lcall	_spi_pp
   0A52 E5 82              3173 	mov	a,dpl
   0A54 D0 02              3174 	pop	ar2
   0A56 60 07              3175 	jz	00102$
   0A58 90 3A 0E           3176 	mov	dptr,#_flash_ec
   0A5B E0                 3177 	movx	a,@dptr
   0A5C F5 82              3178 	mov	dpl,a
   0A5E 22                 3179 	ret
   0A5F                    3180 00102$:
                           3181 ;	../../include/ztex-flash2.h:461: spi_write_byte(b);
   0A5F 8A 82              3182 	mov	dpl,r2
   0A61 12 08 67           3183 	lcall	_spi_write_byte
                           3184 ;	../../include/ztex-flash2.h:462: spi_write_addr_lo++;
   0A64 90 3A 1A           3185 	mov	dptr,#_spi_write_addr_lo
   0A67 E0                 3186 	movx	a,@dptr
   0A68 90 3A 1A           3187 	mov	dptr,#_spi_write_addr_lo
   0A6B 04                 3188 	inc	a
   0A6C F0                 3189 	movx	@dptr,a
                           3190 ;	../../include/ztex-flash2.h:463: if ( spi_write_addr_lo == 0 ) {
   0A6D 90 3A 1A           3191 	mov	dptr,#_spi_write_addr_lo
   0A70 E0                 3192 	movx	a,@dptr
   0A71 FA                 3193 	mov	r2,a
   0A72 70 1C              3194 	jnz	00105$
                           3195 ;	../../include/ztex-flash2.h:464: spi_write_addr_hi++;
   0A74 90 3A 18           3196 	mov	dptr,#_spi_write_addr_hi
   0A77 E0                 3197 	movx	a,@dptr
   0A78 FA                 3198 	mov	r2,a
   0A79 A3                 3199 	inc	dptr
   0A7A E0                 3200 	movx	a,@dptr
   0A7B FB                 3201 	mov	r3,a
   0A7C 90 3A 18           3202 	mov	dptr,#_spi_write_addr_hi
   0A7F 74 01              3203 	mov	a,#0x01
   0A81 2A                 3204 	add	a,r2
   0A82 F0                 3205 	movx	@dptr,a
   0A83 E4                 3206 	clr	a
   0A84 3B                 3207 	addc	a,r3
   0A85 A3                 3208 	inc	dptr
   0A86 F0                 3209 	movx	@dptr,a
                           3210 ;	../../include/ztex-flash2.h:465: spi_deselect();				// finish write cmd
   0A87 12 08 ED           3211 	lcall	_spi_deselect
                           3212 ;	../../include/ztex-flash2.h:466: spi_need_pp = 1;
   0A8A 90 3A 1B           3213 	mov	dptr,#_spi_need_pp
   0A8D 74 01              3214 	mov	a,#0x01
   0A8F F0                 3215 	movx	@dptr,a
   0A90                    3216 00105$:
                           3217 ;	../../include/ztex-flash2.h:468: return 0;
   0A90 75 82 00           3218 	mov	dpl,#0x00
   0A93 22                 3219 	ret
                           3220 ;------------------------------------------------------------
                           3221 ;Allocation info for local variables in function 'flash_write'
                           3222 ;------------------------------------------------------------
                           3223 ;len                       Allocated with name '_flash_write_PARM_2'
                           3224 ;buf                       Allocated to registers r2 r3 
                           3225 ;b                         Allocated to registers r4 
                           3226 ;------------------------------------------------------------
                           3227 ;	../../include/ztex-flash2.h:476: BYTE flash_write(__xdata BYTE *buf, BYTE len) {
                           3228 ;	-----------------------------------------
                           3229 ;	 function flash_write
                           3230 ;	-----------------------------------------
   0A94                    3231 _flash_write:
   0A94 AA 82              3232 	mov	r2,dpl
   0A96 AB 83              3233 	mov	r3,dph
                           3234 ;	../../include/ztex-flash2.h:478: if ( spi_need_pp && spi_pp() ) return flash_ec;
   0A98 90 3A 1B           3235 	mov	dptr,#_spi_need_pp
   0A9B E0                 3236 	movx	a,@dptr
   0A9C FC                 3237 	mov	r4,a
   0A9D 60 16              3238 	jz	00102$
   0A9F C0 02              3239 	push	ar2
   0AA1 C0 03              3240 	push	ar3
   0AA3 12 09 EC           3241 	lcall	_spi_pp
   0AA6 E5 82              3242 	mov	a,dpl
   0AA8 D0 03              3243 	pop	ar3
   0AAA D0 02              3244 	pop	ar2
   0AAC 60 07              3245 	jz	00102$
   0AAE 90 3A 0E           3246 	mov	dptr,#_flash_ec
   0AB1 E0                 3247 	movx	a,@dptr
   0AB2 F5 82              3248 	mov	dpl,a
   0AB4 22                 3249 	ret
   0AB5                    3250 00102$:
                           3251 ;	../../include/ztex-flash2.h:480: if ( spi_write_addr_lo == 0 ) {
   0AB5 90 3A 1A           3252 	mov	dptr,#_spi_write_addr_lo
   0AB8 E0                 3253 	movx	a,@dptr
   0AB9 FC                 3254 	mov	r4,a
   0ABA 70 0C              3255 	jnz	00110$
                           3256 ;	../../include/ztex-flash2.h:481: spi_write(buf,len);
   0ABC 85 14 16           3257 	mov	_spi_write_PARM_2,_flash_write_PARM_2
   0ABF 8A 82              3258 	mov	dpl,r2
   0AC1 8B 83              3259 	mov	dph,r3
   0AC3 12 08 A3           3260 	lcall	_spi_write
   0AC6 80 67              3261 	sjmp	00111$
   0AC8                    3262 00110$:
                           3263 ;	../../include/ztex-flash2.h:484: b = (~spi_write_addr_lo) + 1;
   0AC8 EC                 3264 	mov	a,r4
   0AC9 F4                 3265 	cpl	a
   0ACA FC                 3266 	mov	r4,a
   0ACB 0C                 3267 	inc	r4
                           3268 ;	../../include/ztex-flash2.h:485: if ( len==0 || len>b ) {
   0ACC E5 14              3269 	mov	a,_flash_write_PARM_2
   0ACE 60 06              3270 	jz	00106$
   0AD0 C3                 3271 	clr	c
   0AD1 EC                 3272 	mov	a,r4
   0AD2 95 14              3273 	subb	a,_flash_write_PARM_2
   0AD4 50 4F              3274 	jnc	00107$
   0AD6                    3275 00106$:
                           3276 ;	../../include/ztex-flash2.h:486: spi_write(buf,b);
   0AD6 8C 16              3277 	mov	_spi_write_PARM_2,r4
   0AD8 8A 82              3278 	mov	dpl,r2
   0ADA 8B 83              3279 	mov	dph,r3
   0ADC C0 02              3280 	push	ar2
   0ADE C0 03              3281 	push	ar3
   0AE0 C0 04              3282 	push	ar4
   0AE2 12 08 A3           3283 	lcall	_spi_write
   0AE5 D0 04              3284 	pop	ar4
   0AE7 D0 03              3285 	pop	ar3
   0AE9 D0 02              3286 	pop	ar2
                           3287 ;	../../include/ztex-flash2.h:487: len-=b;
   0AEB E5 14              3288 	mov	a,_flash_write_PARM_2
   0AED C3                 3289 	clr	c
   0AEE 9C                 3290 	subb	a,r4
   0AEF F5 14              3291 	mov	_flash_write_PARM_2,a
                           3292 ;	../../include/ztex-flash2.h:488: spi_write_addr_hi++;
   0AF1 90 3A 18           3293 	mov	dptr,#_spi_write_addr_hi
   0AF4 E0                 3294 	movx	a,@dptr
   0AF5 FD                 3295 	mov	r5,a
   0AF6 A3                 3296 	inc	dptr
   0AF7 E0                 3297 	movx	a,@dptr
   0AF8 FE                 3298 	mov	r6,a
   0AF9 90 3A 18           3299 	mov	dptr,#_spi_write_addr_hi
   0AFC 74 01              3300 	mov	a,#0x01
   0AFE 2D                 3301 	add	a,r5
   0AFF F0                 3302 	movx	@dptr,a
   0B00 E4                 3303 	clr	a
   0B01 3E                 3304 	addc	a,r6
   0B02 A3                 3305 	inc	dptr
   0B03 F0                 3306 	movx	@dptr,a
                           3307 ;	../../include/ztex-flash2.h:489: spi_write_addr_lo=0;
   0B04 90 3A 1A           3308 	mov	dptr,#_spi_write_addr_lo
   0B07 E4                 3309 	clr	a
   0B08 F0                 3310 	movx	@dptr,a
                           3311 ;	../../include/ztex-flash2.h:490: buf+=b;
   0B09 EC                 3312 	mov	a,r4
   0B0A 2A                 3313 	add	a,r2
   0B0B FA                 3314 	mov	r2,a
   0B0C E4                 3315 	clr	a
   0B0D 3B                 3316 	addc	a,r3
   0B0E FB                 3317 	mov	r3,a
                           3318 ;	../../include/ztex-flash2.h:491: if ( spi_pp() ) return flash_ec;
   0B0F C0 02              3319 	push	ar2
   0B11 C0 03              3320 	push	ar3
   0B13 12 09 EC           3321 	lcall	_spi_pp
   0B16 E5 82              3322 	mov	a,dpl
   0B18 D0 03              3323 	pop	ar3
   0B1A D0 02              3324 	pop	ar2
   0B1C 60 07              3325 	jz	00107$
   0B1E 90 3A 0E           3326 	mov	dptr,#_flash_ec
   0B21 E0                 3327 	movx	a,@dptr
   0B22 F5 82              3328 	mov	dpl,a
   0B24 22                 3329 	ret
   0B25                    3330 00107$:
                           3331 ;	../../include/ztex-flash2.h:493: spi_write(buf,len);
   0B25 85 14 16           3332 	mov	_spi_write_PARM_2,_flash_write_PARM_2
   0B28 8A 82              3333 	mov	dpl,r2
   0B2A 8B 83              3334 	mov	dph,r3
   0B2C 12 08 A3           3335 	lcall	_spi_write
   0B2F                    3336 00111$:
                           3337 ;	../../include/ztex-flash2.h:496: spi_write_addr_lo+=len;
   0B2F 90 3A 1A           3338 	mov	dptr,#_spi_write_addr_lo
   0B32 E0                 3339 	movx	a,@dptr
   0B33 FA                 3340 	mov	r2,a
   0B34 E5 14              3341 	mov	a,_flash_write_PARM_2
   0B36 2A                 3342 	add	a,r2
   0B37 F0                 3343 	movx	@dptr,a
                           3344 ;	../../include/ztex-flash2.h:498: if ( spi_write_addr_lo == 0 ) {
   0B38 90 3A 1A           3345 	mov	dptr,#_spi_write_addr_lo
   0B3B E0                 3346 	movx	a,@dptr
   0B3C FA                 3347 	mov	r2,a
   0B3D 70 1C              3348 	jnz	00113$
                           3349 ;	../../include/ztex-flash2.h:499: spi_write_addr_hi++;
   0B3F 90 3A 18           3350 	mov	dptr,#_spi_write_addr_hi
   0B42 E0                 3351 	movx	a,@dptr
   0B43 FA                 3352 	mov	r2,a
   0B44 A3                 3353 	inc	dptr
   0B45 E0                 3354 	movx	a,@dptr
   0B46 FB                 3355 	mov	r3,a
   0B47 90 3A 18           3356 	mov	dptr,#_spi_write_addr_hi
   0B4A 74 01              3357 	mov	a,#0x01
   0B4C 2A                 3358 	add	a,r2
   0B4D F0                 3359 	movx	@dptr,a
   0B4E E4                 3360 	clr	a
   0B4F 3B                 3361 	addc	a,r3
   0B50 A3                 3362 	inc	dptr
   0B51 F0                 3363 	movx	@dptr,a
                           3364 ;	../../include/ztex-flash2.h:500: spi_deselect();				// finish write cmd
   0B52 12 08 ED           3365 	lcall	_spi_deselect
                           3366 ;	../../include/ztex-flash2.h:501: spi_need_pp = 1;
   0B55 90 3A 1B           3367 	mov	dptr,#_spi_need_pp
   0B58 74 01              3368 	mov	a,#0x01
   0B5A F0                 3369 	movx	@dptr,a
   0B5B                    3370 00113$:
                           3371 ;	../../include/ztex-flash2.h:504: return 0;
   0B5B 75 82 00           3372 	mov	dpl,#0x00
   0B5E 22                 3373 	ret
                           3374 ;------------------------------------------------------------
                           3375 ;Allocation info for local variables in function 'flash_write_init'
                           3376 ;------------------------------------------------------------
                           3377 ;s                         Allocated to registers r2 r3 
                           3378 ;------------------------------------------------------------
                           3379 ;	../../include/ztex-flash2.h:516: BYTE flash_write_init(WORD s) {
                           3380 ;	-----------------------------------------
                           3381 ;	 function flash_write_init
                           3382 ;	-----------------------------------------
   0B5F                    3383 _flash_write_init:
   0B5F AA 82              3384 	mov	r2,dpl
   0B61 AB 83              3385 	mov	r3,dph
                           3386 ;	../../include/ztex-flash2.h:517: if ( !SPI_CS ) {
   0B63 20 83 0A           3387 	jb	_IOA3,00102$
                           3388 ;	../../include/ztex-flash2.h:518: flash_ec = FLASH_EC_PENDING;
   0B66 90 3A 0E           3389 	mov	dptr,#_flash_ec
   0B69 74 04              3390 	mov	a,#0x04
   0B6B F0                 3391 	movx	@dptr,a
                           3392 ;	../../include/ztex-flash2.h:519: return FLASH_EC_PENDING;		// we interrupted a pending Flash operation
   0B6C 75 82 04           3393 	mov	dpl,#0x04
   0B6F 22                 3394 	ret
   0B70                    3395 00102$:
                           3396 ;	../../include/ztex-flash2.h:521: OESPI_OPORT &= ~bmBITSPI_BIT_DO;
   0B70 53 B4 FE           3397 	anl	_OEC,#0xFE
                           3398 ;	../../include/ztex-flash2.h:522: OESPI_PORT |= bmBITSPI_BIT_CS | bmBITSPI_BIT_DI | bmBITSPI_BIT_CLK;
   0B73 43 B2 0B           3399 	orl	_OEA,#0x0B
                           3400 ;	../../include/ztex-flash2.h:523: if ( spi_wait() ) {
   0B76 C0 02              3401 	push	ar2
   0B78 C0 03              3402 	push	ar3
   0B7A 12 08 F5           3403 	lcall	_spi_wait
   0B7D E5 82              3404 	mov	a,dpl
   0B7F D0 03              3405 	pop	ar3
   0B81 D0 02              3406 	pop	ar2
   0B83 60 07              3407 	jz	00104$
                           3408 ;	../../include/ztex-flash2.h:524: return flash_ec;
   0B85 90 3A 0E           3409 	mov	dptr,#_flash_ec
   0B88 E0                 3410 	movx	a,@dptr
   0B89 F5 82              3411 	mov	dpl,a
   0B8B 22                 3412 	ret
   0B8C                    3413 00104$:
                           3414 ;	../../include/ztex-flash2.h:526: spi_write_sector = s;
   0B8C 90 3A 1C           3415 	mov	dptr,#_spi_write_sector
   0B8F EA                 3416 	mov	a,r2
   0B90 F0                 3417 	movx	@dptr,a
   0B91 A3                 3418 	inc	dptr
   0B92 EB                 3419 	mov	a,r3
   0B93 F0                 3420 	movx	@dptr,a
                           3421 ;	../../include/ztex-flash2.h:527: s = s << ((BYTE)flash_sector_size - 8);     
   0B94 90 3A 08           3422 	mov	dptr,#_flash_sector_size
   0B97 E0                 3423 	movx	a,@dptr
   0B98 FC                 3424 	mov	r4,a
   0B99 A3                 3425 	inc	dptr
   0B9A E0                 3426 	movx	a,@dptr
   0B9B 7D 00              3427 	mov	r5,#0x00
   0B9D EC                 3428 	mov	a,r4
   0B9E 24 F8              3429 	add	a,#0xf8
   0BA0 FC                 3430 	mov	r4,a
   0BA1 ED                 3431 	mov	a,r5
   0BA2 34 FF              3432 	addc	a,#0xff
   0BA4 FD                 3433 	mov	r5,a
   0BA5 8C F0              3434 	mov	b,r4
   0BA7 05 F0              3435 	inc	b
   0BA9 80 06              3436 	sjmp	00112$
   0BAB                    3437 00111$:
   0BAB EA                 3438 	mov	a,r2
   0BAC 2A                 3439 	add	a,r2
   0BAD FA                 3440 	mov	r2,a
   0BAE EB                 3441 	mov	a,r3
   0BAF 33                 3442 	rlc	a
   0BB0 FB                 3443 	mov	r3,a
   0BB1                    3444 00112$:
   0BB1 D5 F0 F7           3445 	djnz	b,00111$
                           3446 ;	../../include/ztex-flash2.h:528: spi_write_addr_hi = s;
   0BB4 90 3A 18           3447 	mov	dptr,#_spi_write_addr_hi
   0BB7 EA                 3448 	mov	a,r2
   0BB8 F0                 3449 	movx	@dptr,a
   0BB9 A3                 3450 	inc	dptr
   0BBA EB                 3451 	mov	a,r3
   0BBB F0                 3452 	movx	@dptr,a
                           3453 ;	../../include/ztex-flash2.h:529: spi_write_addr_lo = 0;
   0BBC 90 3A 1A           3454 	mov	dptr,#_spi_write_addr_lo
   0BBF E4                 3455 	clr	a
   0BC0 F0                 3456 	movx	@dptr,a
                           3457 ;	../../include/ztex-flash2.h:359: spi_last_cmd = $0;
   0BC1 90 3A 13           3458 	mov	dptr,#_spi_last_cmd
   0BC4 74 06              3459 	mov	a,#0x06
   0BC6 F0                 3460 	movx	@dptr,a
                           3461 ;	../../include/ztex-flash2.h:360: spi_select();				// select
   0BC7 C0 02              3462 	push	ar2
   0BC9 C0 03              3463 	push	ar3
   0BCB 12 08 E2           3464 	lcall	_spi_select
                           3465 ;	../../include/ztex-flash2.h:361: spi_write_byte($0);				// CMD 90h
   0BCE 75 82 06           3466 	mov	dpl,#0x06
   0BD1 12 08 67           3467 	lcall	_spi_write_byte
                           3468 ;	../../include/ztex-flash2.h:532: spi_deselect();
   0BD4 12 08 ED           3469 	lcall	_spi_deselect
                           3470 ;	../../include/ztex-flash2.h:359: spi_last_cmd = $0;
   0BD7 90 3A 12           3471 	mov	dptr,#_spi_erase_cmd
   0BDA E0                 3472 	movx	a,@dptr
   0BDB 90 3A 13           3473 	mov	dptr,#_spi_last_cmd
   0BDE F0                 3474 	movx	@dptr,a
                           3475 ;	../../include/ztex-flash2.h:360: spi_select();				// select
   0BDF 12 08 E2           3476 	lcall	_spi_select
                           3477 ;	../../include/ztex-flash2.h:361: spi_write_byte($0);				// CMD 90h
   0BE2 90 3A 12           3478 	mov	dptr,#_spi_erase_cmd
   0BE5 E0                 3479 	movx	a,@dptr
   0BE6 F5 82              3480 	mov	dpl,a
   0BE8 12 08 67           3481 	lcall	_spi_write_byte
   0BEB D0 03              3482 	pop	ar3
                           3483 ;	../../include/ztex-flash2.h:363: 
   0BED 8B 82              3484 	mov	dpl,r3
   0BEF C0 03              3485 	push	ar3
   0BF1 12 08 67           3486 	lcall	_spi_write_byte
   0BF4 D0 03              3487 	pop	ar3
   0BF6 D0 02              3488 	pop	ar2
                           3489 ;	../../include/ztex-flash2.h:536: spi_write_byte(s & 255);
   0BF8 8A 82              3490 	mov	dpl,r2
   0BFA 12 08 67           3491 	lcall	_spi_write_byte
                           3492 ;	../../include/ztex-flash2.h:537: spi_write_byte(0);
   0BFD 75 82 00           3493 	mov	dpl,#0x00
   0C00 12 08 67           3494 	lcall	_spi_write_byte
                           3495 ;	../../include/ztex-flash2.h:538: spi_deselect();
   0C03 12 08 ED           3496 	lcall	_spi_deselect
                           3497 ;	../../include/ztex-flash2.h:540: spi_need_pp = 1;
   0C06 90 3A 1B           3498 	mov	dptr,#_spi_need_pp
   0C09 74 01              3499 	mov	a,#0x01
   0C0B F0                 3500 	movx	@dptr,a
                           3501 ;	../../include/ztex-flash2.h:541: return 0;
   0C0C 75 82 00           3502 	mov	dpl,#0x00
   0C0F 22                 3503 	ret
                           3504 ;------------------------------------------------------------
                           3505 ;Allocation info for local variables in function 'flash_write_finish_sector'
                           3506 ;------------------------------------------------------------
                           3507 ;n                         Allocated to registers 
                           3508 ;------------------------------------------------------------
                           3509 ;	../../include/ztex-flash2.h:551: BYTE flash_write_finish_sector (WORD n) {
                           3510 ;	-----------------------------------------
                           3511 ;	 function flash_write_finish_sector
                           3512 ;	-----------------------------------------
   0C10                    3513 _flash_write_finish_sector:
                           3514 ;	../../include/ztex-flash2.h:553: spi_deselect();
   0C10 12 08 ED           3515 	lcall	_spi_deselect
                           3516 ;	../../include/ztex-flash2.h:554: return 0;
   0C13 75 82 00           3517 	mov	dpl,#0x00
   0C16 22                 3518 	ret
                           3519 ;------------------------------------------------------------
                           3520 ;Allocation info for local variables in function 'flash_write_finish'
                           3521 ;------------------------------------------------------------
                           3522 ;------------------------------------------------------------
                           3523 ;	../../include/ztex-flash2.h:564: void flash_write_finish () {
                           3524 ;	-----------------------------------------
                           3525 ;	 function flash_write_finish
                           3526 ;	-----------------------------------------
   0C17                    3527 _flash_write_finish:
                           3528 ;	../../include/ztex-flash2.h:565: spi_deselect();
   0C17 02 08 ED           3529 	ljmp	_spi_deselect
                           3530 ;------------------------------------------------------------
                           3531 ;Allocation info for local variables in function 'flash_write_next'
                           3532 ;------------------------------------------------------------
                           3533 ;------------------------------------------------------------
                           3534 ;	../../include/ztex-flash2.h:575: BYTE flash_write_next () {
                           3535 ;	-----------------------------------------
                           3536 ;	 function flash_write_next
                           3537 ;	-----------------------------------------
   0C1A                    3538 _flash_write_next:
                           3539 ;	../../include/ztex-flash2.h:576: spi_deselect();
   0C1A 12 08 ED           3540 	lcall	_spi_deselect
                           3541 ;	../../include/ztex-flash2.h:577: return flash_write_init(spi_write_sector+1);
   0C1D 90 3A 1C           3542 	mov	dptr,#_spi_write_sector
   0C20 E0                 3543 	movx	a,@dptr
   0C21 FA                 3544 	mov	r2,a
   0C22 A3                 3545 	inc	dptr
   0C23 E0                 3546 	movx	a,@dptr
   0C24 FB                 3547 	mov	r3,a
   0C25 8A 82              3548 	mov	dpl,r2
   0C27 8B 83              3549 	mov	dph,r3
   0C29 A3                 3550 	inc	dptr
   0C2A 02 0B 5F           3551 	ljmp	_flash_write_init
                           3552 ;------------------------------------------------------------
                           3553 ;Allocation info for local variables in function 'flash_init'
                           3554 ;------------------------------------------------------------
                           3555 ;i                         Allocated to registers r2 
                           3556 ;------------------------------------------------------------
                           3557 ;	../../include/ztex-flash2.h:585: void flash_init() {
                           3558 ;	-----------------------------------------
                           3559 ;	 function flash_init
                           3560 ;	-----------------------------------------
   0C2D                    3561 _flash_init:
                           3562 ;	../../include/ztex-flash2.h:588: PORTCCFG = 0;
   0C2D 90 E6 71           3563 	mov	dptr,#_PORTCCFG
   0C30 E4                 3564 	clr	a
   0C31 F0                 3565 	movx	@dptr,a
                           3566 ;	../../include/ztex-flash2.h:590: flash_enabled = 1;
   0C32 90 3A 07           3567 	mov	dptr,#_flash_enabled
   0C35 74 01              3568 	mov	a,#0x01
   0C37 F0                 3569 	movx	@dptr,a
                           3570 ;	../../include/ztex-flash2.h:591: flash_ec = 0;
   0C38 90 3A 0E           3571 	mov	dptr,#_flash_ec
   0C3B E4                 3572 	clr	a
   0C3C F0                 3573 	movx	@dptr,a
                           3574 ;	../../include/ztex-flash2.h:592: flash_sector_size = 0x8010;  // 64 KByte
   0C3D 90 3A 08           3575 	mov	dptr,#_flash_sector_size
   0C40 74 10              3576 	mov	a,#0x10
   0C42 F0                 3577 	movx	@dptr,a
   0C43 A3                 3578 	inc	dptr
   0C44 74 80              3579 	mov	a,#0x80
   0C46 F0                 3580 	movx	@dptr,a
                           3581 ;	../../include/ztex-flash2.h:593: spi_erase_cmd = 0xd8;
   0C47 90 3A 12           3582 	mov	dptr,#_spi_erase_cmd
   0C4A 74 D8              3583 	mov	a,#0xD8
   0C4C F0                 3584 	movx	@dptr,a
                           3585 ;	../../include/ztex-flash2.h:595: OESPI_OPORT &= ~bmBITSPI_BIT_DO;
   0C4D 53 B4 FE           3586 	anl	_OEC,#0xFE
                           3587 ;	../../include/ztex-flash2.h:596: OESPI_PORT |= bmBITSPI_BIT_CS | bmBITSPI_BIT_DI | bmBITSPI_BIT_CLK;
   0C50 43 B2 0B           3588 	orl	_OEA,#0x0B
                           3589 ;	../../include/ztex-flash2.h:597: SPI_CS = 1;
   0C53 D2 83              3590 	setb	_IOA3
                           3591 ;	../../include/ztex-flash2.h:598: spi_clocks(0);				// 256 clocks
   0C55 75 82 00           3592 	mov	dpl,#0x00
   0C58 12 07 DD           3593 	lcall	_spi_clocks
                           3594 ;	../../include/ztex-flash2.h:359: spi_last_cmd = $0;
   0C5B 90 3A 13           3595 	mov	dptr,#_spi_last_cmd
   0C5E 74 90              3596 	mov	a,#0x90
   0C60 F0                 3597 	movx	@dptr,a
                           3598 ;	../../include/ztex-flash2.h:360: spi_select();				// select
   0C61 12 08 E2           3599 	lcall	_spi_select
                           3600 ;	../../include/ztex-flash2.h:361: spi_write_byte($0);				// CMD 90h
   0C64 75 82 90           3601 	mov	dpl,#0x90
   0C67 12 08 67           3602 	lcall	_spi_write_byte
                           3603 ;	../../include/ztex-flash2.h:363: 
   0C6A 75 82 18           3604 	mov	dpl,#0x18
   0C6D 12 07 DD           3605 	lcall	_spi_clocks
                           3606 ;	../../include/ztex-flash2.h:602: spi_device = flash_read_byte();			
   0C70 12 07 E9           3607 	lcall	_flash_read_byte
   0C73 E5 82              3608 	mov	a,dpl
   0C75 90 3A 10           3609 	mov	dptr,#_spi_device
   0C78 F0                 3610 	movx	@dptr,a
                           3611 ;	../../include/ztex-flash2.h:603: spi_deselect();				// deselect
   0C79 12 08 ED           3612 	lcall	_spi_deselect
                           3613 ;	../../include/ztex-flash2.h:359: spi_last_cmd = $0;
   0C7C 90 3A 13           3614 	mov	dptr,#_spi_last_cmd
   0C7F 74 9F              3615 	mov	a,#0x9F
   0C81 F0                 3616 	movx	@dptr,a
                           3617 ;	../../include/ztex-flash2.h:360: spi_select();				// select
   0C82 12 08 E2           3618 	lcall	_spi_select
                           3619 ;	../../include/ztex-flash2.h:361: spi_write_byte($0);				// CMD 90h
   0C85 75 82 9F           3620 	mov	dpl,#0x9F
   0C88 12 08 67           3621 	lcall	_spi_write_byte
                           3622 ;	../../include/ztex-flash2.h:363: 
   0C8B 75 16 03           3623 	mov	_flash_read_PARM_2,#0x03
   0C8E 90 3A 14           3624 	mov	dptr,#_spi_buffer
   0C91 12 08 28           3625 	lcall	_flash_read
                           3626 ;	../../include/ztex-flash2.h:364: /* *********************************************************************
   0C94 12 08 ED           3627 	lcall	_spi_deselect
                           3628 ;	../../include/ztex-flash2.h:608: if ( spi_buffer[2]<16 || spi_buffer[2]>24 ) {
   0C97 90 3A 16           3629 	mov	dptr,#(_spi_buffer + 0x0002)
   0C9A E0                 3630 	movx	a,@dptr
   0C9B FA                 3631 	mov	r2,a
   0C9C BA 10 00           3632 	cjne	r2,#0x10,00109$
   0C9F                    3633 00109$:
   0C9F 40 3D              3634 	jc	00104$
   0CA1 EA                 3635 	mov	a,r2
   0CA2 24 E7              3636 	add	a,#0xff - 0x18
   0CA4 40 38              3637 	jc	00104$
                           3638 ;	../../include/ztex-flash2.h:611: spi_vendor = spi_buffer[0];
   0CA6 90 3A 14           3639 	mov	dptr,#_spi_buffer
   0CA9 E0                 3640 	movx	a,@dptr
   0CAA 90 3A 0F           3641 	mov	dptr,#_spi_vendor
   0CAD F0                 3642 	movx	@dptr,a
                           3643 ;	../../include/ztex-flash2.h:612: spi_memtype = spi_buffer[1];
   0CAE 90 3A 15           3644 	mov	dptr,#(_spi_buffer + 0x0001)
   0CB1 E0                 3645 	movx	a,@dptr
   0CB2 90 3A 11           3646 	mov	dptr,#_spi_memtype
   0CB5 F0                 3647 	movx	@dptr,a
                           3648 ;	../../include/ztex-flash2.h:628: i=spi_buffer[2]-16;
   0CB6 EA                 3649 	mov	a,r2
   0CB7 24 F0              3650 	add	a,#0xf0
   0CB9 FA                 3651 	mov	r2,a
                           3652 ;	../../include/ztex-flash2.h:630: flash_sectors = 1 << i;
   0CBA 8A F0              3653 	mov	b,r2
   0CBC 05 F0              3654 	inc	b
   0CBE 7A 01              3655 	mov	r2,#0x01
   0CC0 7B 00              3656 	mov	r3,#0x00
   0CC2 80 06              3657 	sjmp	00113$
   0CC4                    3658 00112$:
   0CC4 EA                 3659 	mov	a,r2
   0CC5 2A                 3660 	add	a,r2
   0CC6 FA                 3661 	mov	r2,a
   0CC7 EB                 3662 	mov	a,r3
   0CC8 33                 3663 	rlc	a
   0CC9 FB                 3664 	mov	r3,a
   0CCA                    3665 00113$:
   0CCA D5 F0 F7           3666 	djnz	b,00112$
   0CCD 90 3A 0A           3667 	mov	dptr,#_flash_sectors
   0CD0 EA                 3668 	mov	a,r2
   0CD1 F0                 3669 	movx	@dptr,a
   0CD2 A3                 3670 	inc	dptr
   0CD3 EB                 3671 	mov	a,r3
   0CD4 F0                 3672 	movx	@dptr,a
   0CD5 EB                 3673 	mov	a,r3
   0CD6 33                 3674 	rlc	a
   0CD7 95 E0              3675 	subb	a,acc
   0CD9 A3                 3676 	inc	dptr
   0CDA F0                 3677 	movx	@dptr,a
   0CDB A3                 3678 	inc	dptr
   0CDC F0                 3679 	movx	@dptr,a
                           3680 ;	../../include/ztex-flash2.h:632: return;
                           3681 ;	../../include/ztex-flash2.h:634: disable:
   0CDD 22                 3682 	ret
   0CDE                    3683 00104$:
                           3684 ;	../../include/ztex-flash2.h:635: flash_enabled = 0;
   0CDE 90 3A 07           3685 	mov	dptr,#_flash_enabled
   0CE1 E4                 3686 	clr	a
   0CE2 F0                 3687 	movx	@dptr,a
                           3688 ;	../../include/ztex-flash2.h:636: flash_ec = FLASH_EC_NOTSUPPORTED;
   0CE3 90 3A 0E           3689 	mov	dptr,#_flash_ec
   0CE6 74 07              3690 	mov	a,#0x07
   0CE8 F0                 3691 	movx	@dptr,a
                           3692 ;	../../include/ztex-flash2.h:637: OESPI_PORT &= ~( bmBITSPI_BIT_CS | bmBITSPI_BIT_DI | bmBITSPI_BIT_CLK );
   0CE9 53 B2 F4           3693 	anl	_OEA,#0xF4
   0CEC 22                 3694 	ret
                           3695 ;------------------------------------------------------------
                           3696 ;Allocation info for local variables in function 'spi_read_ep0'
                           3697 ;------------------------------------------------------------
                           3698 ;------------------------------------------------------------
                           3699 ;	../../include/ztex-flash2.h:663: void spi_read_ep0 () { 
                           3700 ;	-----------------------------------------
                           3701 ;	 function spi_read_ep0
                           3702 ;	-----------------------------------------
   0CED                    3703 _spi_read_ep0:
                           3704 ;	../../include/ztex-flash2.h:664: flash_read(EP0BUF, ep0_payload_transfer);
   0CED 90 3A 38           3705 	mov	dptr,#_ep0_payload_transfer
   0CF0 E0                 3706 	movx	a,@dptr
   0CF1 F5 16              3707 	mov	_flash_read_PARM_2,a
   0CF3 90 E7 40           3708 	mov	dptr,#_EP0BUF
   0CF6 12 08 28           3709 	lcall	_flash_read
                           3710 ;	../../include/ztex-flash2.h:665: if ( ep0_read_mode==2 && ep0_payload_remaining==0 ) {
   0CF9 90 3A 1E           3711 	mov	dptr,#_ep0_read_mode
   0CFC E0                 3712 	movx	a,@dptr
   0CFD FA                 3713 	mov	r2,a
   0CFE BA 02 0E           3714 	cjne	r2,#0x02,00104$
   0D01 90 3A 36           3715 	mov	dptr,#_ep0_payload_remaining
   0D04 E0                 3716 	movx	a,@dptr
   0D05 FA                 3717 	mov	r2,a
   0D06 A3                 3718 	inc	dptr
   0D07 E0                 3719 	movx	a,@dptr
   0D08 FB                 3720 	mov	r3,a
   0D09 4A                 3721 	orl	a,r2
   0D0A 70 03              3722 	jnz	00104$
                           3723 ;	../../include/ztex-flash2.h:666: spi_deselect();
   0D0C 02 08 ED           3724 	ljmp	_spi_deselect
   0D0F                    3725 00104$:
   0D0F 22                 3726 	ret
                           3727 ;------------------------------------------------------------
                           3728 ;Allocation info for local variables in function 'spi_send_ep0'
                           3729 ;------------------------------------------------------------
                           3730 ;------------------------------------------------------------
                           3731 ;	../../include/ztex-flash2.h:690: void spi_send_ep0 () { 
                           3732 ;	-----------------------------------------
                           3733 ;	 function spi_send_ep0
                           3734 ;	-----------------------------------------
   0D10                    3735 _spi_send_ep0:
                           3736 ;	../../include/ztex-flash2.h:691: flash_write(EP0BUF, ep0_payload_transfer);
   0D10 90 3A 38           3737 	mov	dptr,#_ep0_payload_transfer
   0D13 E0                 3738 	movx	a,@dptr
   0D14 F5 14              3739 	mov	_flash_write_PARM_2,a
   0D16 90 E7 40           3740 	mov	dptr,#_EP0BUF
   0D19 12 0A 94           3741 	lcall	_flash_write
                           3742 ;	../../include/ztex-flash2.h:692: if ( ep0_write_mode==2 && ep0_payload_remaining==0 ) {
   0D1C 90 3A 1F           3743 	mov	dptr,#_ep0_write_mode
   0D1F E0                 3744 	movx	a,@dptr
   0D20 FA                 3745 	mov	r2,a
   0D21 BA 02 0E           3746 	cjne	r2,#0x02,00104$
   0D24 90 3A 36           3747 	mov	dptr,#_ep0_payload_remaining
   0D27 E0                 3748 	movx	a,@dptr
   0D28 FA                 3749 	mov	r2,a
   0D29 A3                 3750 	inc	dptr
   0D2A E0                 3751 	movx	a,@dptr
   0D2B FB                 3752 	mov	r3,a
   0D2C 4A                 3753 	orl	a,r2
   0D2D 70 03              3754 	jnz	00104$
                           3755 ;	../../include/ztex-flash2.h:693: spi_deselect();
   0D2F 02 08 ED           3756 	ljmp	_spi_deselect
   0D32                    3757 00104$:
   0D32 22                 3758 	ret
                           3759 ;------------------------------------------------------------
                           3760 ;Allocation info for local variables in function 'reset_fpga'
                           3761 ;------------------------------------------------------------
                           3762 ;------------------------------------------------------------
                           3763 ;	../../include/ztex-fpga7.h:39: static void reset_fpga () {
                           3764 ;	-----------------------------------------
                           3765 ;	 function reset_fpga
                           3766 ;	-----------------------------------------
   0D33                    3767 _reset_fpga:
                           3768 ;	../../include/ztex-fpga7.h:40: OEE = (OEE & ~bmBIT6) | bmBIT7;
   0D33 AA B6              3769 	mov	r2,_OEE
   0D35 74 BF              3770 	mov	a,#0xBF
   0D37 5A                 3771 	anl	a,r2
   0D38 F5 F0              3772 	mov	b,a
   0D3A 74 80              3773 	mov	a,#0x80
   0D3C 45 F0              3774 	orl	a,b
   0D3E F5 B6              3775 	mov	_OEE,a
                           3776 ;	../../include/ztex-fpga7.h:41: IOE = IOE & ~bmBIT7;
   0D40 53 B1 7F           3777 	anl	_IOE,#0x7F
                           3778 ;	../../include/ztex-fpga7.h:42: wait(1);
   0D43 90 00 01           3779 	mov	dptr,#0x0001
   0D46 12 02 65           3780 	lcall	_wait
                           3781 ;	../../include/ztex-fpga7.h:43: IOE = IOE | bmBIT7;
   0D49 43 B1 80           3782 	orl	_IOE,#0x80
                           3783 ;	../../include/ztex-fpga7.h:44: fpga_conf_initialized = 0;
   0D4C 90 3A 27           3784 	mov	dptr,#_fpga_conf_initialized
   0D4F E4                 3785 	clr	a
   0D50 F0                 3786 	movx	@dptr,a
   0D51 22                 3787 	ret
                           3788 ;------------------------------------------------------------
                           3789 ;Allocation info for local variables in function 'init_fpga'
                           3790 ;------------------------------------------------------------
                           3791 ;------------------------------------------------------------
                           3792 ;	../../include/ztex-fpga7.h:50: static void init_fpga () {
                           3793 ;	-----------------------------------------
                           3794 ;	 function init_fpga
                           3795 ;	-----------------------------------------
   0D52                    3796 _init_fpga:
                           3797 ;	../../include/ztex-fpga7.h:51: IOE = IOE | bmBIT7;
   0D52 43 B1 80           3798 	orl	_IOE,#0x80
                           3799 ;	../../include/ztex-fpga7.h:52: OEE = (OEE & ~bmBIT6) | bmBIT7;
   0D55 AA B6              3800 	mov	r2,_OEE
   0D57 74 BF              3801 	mov	a,#0xBF
   0D59 5A                 3802 	anl	a,r2
   0D5A F5 F0              3803 	mov	b,a
   0D5C 74 80              3804 	mov	a,#0x80
   0D5E 45 F0              3805 	orl	a,b
   0D60 F5 B6              3806 	mov	_OEE,a
                           3807 ;	../../include/ztex-fpga7.h:53: if ( ! (IOE & bmBIT6) ) {
   0D62 E5 B1              3808 	mov	a,_IOE
   0D64 20 E6 24           3809 	jb	acc.6,00102$
                           3810 ;	../../include/ztex-fpga7.h:55: IOE = IOE & ~bmBIT7;			// PROG_B = 0
   0D67 53 B1 7F           3811 	anl	_IOE,#0x7F
                           3812 ;	../../include/ztex-fpga7.h:56: OEA = (OEA & bmBIT2 ) | bmBIT4 | bmBIT5 | bmBIT6;
   0D6A 74 04              3813 	mov	a,#0x04
   0D6C 55 B2              3814 	anl	a,_OEA
   0D6E F5 F0              3815 	mov	b,a
   0D70 74 70              3816 	mov	a,#0x70
   0D72 45 F0              3817 	orl	a,b
   0D74 F5 B2              3818 	mov	_OEA,a
                           3819 ;	../../include/ztex-fpga7.h:57: IOA = (IOA & bmBIT2 ) | bmBIT5;
   0D76 74 04              3820 	mov	a,#0x04
   0D78 55 80              3821 	anl	a,_IOA
   0D7A F5 F0              3822 	mov	b,a
   0D7C 74 20              3823 	mov	a,#0x20
   0D7E 45 F0              3824 	orl	a,b
   0D80 F5 80              3825 	mov	_IOA,a
                           3826 ;	../../include/ztex-fpga7.h:58: wait(1);
   0D82 90 00 01           3827 	mov	dptr,#0x0001
   0D85 12 02 65           3828 	lcall	_wait
                           3829 ;	../../include/ztex-fpga7.h:59: IOE = IOE | bmBIT7;			// PROG_B = 1
   0D88 43 B1 80           3830 	orl	_IOE,#0x80
   0D8B                    3831 00102$:
                           3832 ;	../../include/ztex-fpga7.h:62: fpga_conf_initialized = 0;
   0D8B 90 3A 27           3833 	mov	dptr,#_fpga_conf_initialized
   0D8E E4                 3834 	clr	a
   0D8F F0                 3835 	movx	@dptr,a
   0D90 22                 3836 	ret
                           3837 ;------------------------------------------------------------
                           3838 ;Allocation info for local variables in function 'init_fpga_configuration'
                           3839 ;------------------------------------------------------------
                           3840 ;k                         Allocated to registers r2 r3 
                           3841 ;------------------------------------------------------------
                           3842 ;	../../include/ztex-fpga7.h:68: static void init_fpga_configuration () {
                           3843 ;	-----------------------------------------
                           3844 ;	 function init_fpga_configuration
                           3845 ;	-----------------------------------------
   0D91                    3846 _init_fpga_configuration:
                           3847 ;	../../include/ztex-fpga7.h:75: IFCONFIG = bmBIT7;
   0D91 90 E6 01           3848 	mov	dptr,#_IFCONFIG
   0D94 74 80              3849 	mov	a,#0x80
   0D96 F0                 3850 	movx	@dptr,a
                           3851 ;	../../include/ezregs.h:46: __endasm;
                           3852 	
   0D97 00                 3853 	 nop
   0D98 00                 3854 	 nop
   0D99 00                 3855 	 nop
   0D9A 00                 3856 	 nop
                           3857 	    
                           3858 ;	../../include/ztex-fpga7.h:77: PORTACFG = 0;
   0D9B 90 E6 70           3859 	mov	dptr,#_PORTACFG
                           3860 ;	../../include/ztex-fpga7.h:78: PORTCCFG = 0;
   0D9E E4                 3861 	clr	a
   0D9F F0                 3862 	movx	@dptr,a
   0DA0 90 E6 71           3863 	mov	dptr,#_PORTCCFG
   0DA3 F0                 3864 	movx	@dptr,a
                           3865 ;	../../include/ztex-fpga7.h:80: OOEA = OEA;
   0DA4 90 3A 28           3866 	mov	dptr,#_OOEA
   0DA7 E5 B2              3867 	mov	a,_OEA
   0DA9 F0                 3868 	movx	@dptr,a
                           3869 ;	../../include/ztex-fpga7.h:81: fpga_conf_initialized = 123;
   0DAA 90 3A 27           3870 	mov	dptr,#_fpga_conf_initialized
   0DAD 74 7B              3871 	mov	a,#0x7B
   0DAF F0                 3872 	movx	@dptr,a
                           3873 ;	../../include/ztex-fpga7.h:83: OEA &= bmBIT2;			// only unsed PA bit
   0DB0 53 B2 04           3874 	anl	_OEA,#0x04
                           3875 ;	../../include/ztex-fpga7.h:85: OEE = (OEE & ~bmBIT6) | bmBIT7;
   0DB3 AA B6              3876 	mov	r2,_OEE
   0DB5 74 BF              3877 	mov	a,#0xBF
   0DB7 5A                 3878 	anl	a,r2
   0DB8 F5 F0              3879 	mov	b,a
   0DBA 74 80              3880 	mov	a,#0x80
   0DBC 45 F0              3881 	orl	a,b
   0DBE F5 B6              3882 	mov	_OEE,a
                           3883 ;	../../include/ztex-fpga7.h:86: IOE = IOE & ~bmBIT7;		// PROG_B = 0
   0DC0 53 B1 7F           3884 	anl	_IOE,#0x7F
                           3885 ;	../../include/ztex-fpga7.h:89: OEA |= bmBIT1 | bmBIT4 | bmBIT5 | bmBIT6;
   0DC3 43 B2 72           3886 	orl	_OEA,#0x72
                           3887 ;	../../include/ztex-fpga7.h:90: IOA = ( IOA & bmBIT2 ) | bmBIT1 | bmBIT5;
   0DC6 74 04              3888 	mov	a,#0x04
   0DC8 55 80              3889 	anl	a,_IOA
   0DCA F5 F0              3890 	mov	b,a
   0DCC 74 22              3891 	mov	a,#0x22
   0DCE 45 F0              3892 	orl	a,b
   0DD0 F5 80              3893 	mov	_IOA,a
                           3894 ;	../../include/ztex-fpga7.h:91: wait(5);
   0DD2 90 00 05           3895 	mov	dptr,#0x0005
   0DD5 12 02 65           3896 	lcall	_wait
                           3897 ;	../../include/ztex-fpga7.h:93: IOE = IOE | bmBIT7;			// PROG_B = 1
   0DD8 43 B1 80           3898 	orl	_IOE,#0x80
                           3899 ;	../../include/ztex-fpga7.h:94: IOA1 = 0;  	  			// CS = 0
   0DDB C2 81              3900 	clr	_IOA1
                           3901 ;	../../include/ztex-fpga7.h:97: while (!IOA7 && k<65535)
   0DDD 7A 00              3902 	mov	r2,#0x00
   0DDF 7B 00              3903 	mov	r3,#0x00
   0DE1                    3904 00102$:
   0DE1 20 87 20           3905 	jb	_IOA7,00104$
   0DE4 8A 04              3906 	mov	ar4,r2
   0DE6 8B 05              3907 	mov	ar5,r3
   0DE8 7E 00              3908 	mov	r6,#0x00
   0DEA 7F 00              3909 	mov	r7,#0x00
   0DEC C3                 3910 	clr	c
   0DED EC                 3911 	mov	a,r4
   0DEE 94 FF              3912 	subb	a,#0xFF
   0DF0 ED                 3913 	mov	a,r5
   0DF1 94 FF              3914 	subb	a,#0xFF
   0DF3 EE                 3915 	mov	a,r6
   0DF4 94 00              3916 	subb	a,#0x00
   0DF6 EF                 3917 	mov	a,r7
   0DF7 64 80              3918 	xrl	a,#0x80
   0DF9 94 80              3919 	subb	a,#0x80
   0DFB 50 07              3920 	jnc	00104$
                           3921 ;	../../include/ztex-fpga7.h:98: k++;
   0DFD 0A                 3922 	inc	r2
   0DFE BA 00 E0           3923 	cjne	r2,#0x00,00102$
   0E01 0B                 3924 	inc	r3
   0E02 80 DD              3925 	sjmp	00102$
   0E04                    3926 00104$:
                           3927 ;	../../include/ztex-fpga7.h:101: OEA |= bmBIT0;			// ready for configuration
   0E04 43 B2 01           3928 	orl	_OEA,#0x01
                           3929 ;	../../include/ztex-fpga7.h:103: fpga_init_b = IOA7 ? 200 : 100;
   0E07 30 87 04           3930 	jnb	_IOA7,00107$
   0E0A 7A C8              3931 	mov	r2,#0xC8
   0E0C 80 02              3932 	sjmp	00108$
   0E0E                    3933 00107$:
   0E0E 7A 64              3934 	mov	r2,#0x64
   0E10                    3935 00108$:
   0E10 90 3A 25           3936 	mov	dptr,#_fpga_init_b
   0E13 EA                 3937 	mov	a,r2
   0E14 F0                 3938 	movx	@dptr,a
                           3939 ;	../../include/ztex-fpga7.h:104: fpga_bytes = 0;
   0E15 90 3A 21           3940 	mov	dptr,#_fpga_bytes
   0E18 E4                 3941 	clr	a
   0E19 F0                 3942 	movx	@dptr,a
   0E1A A3                 3943 	inc	dptr
   0E1B F0                 3944 	movx	@dptr,a
   0E1C A3                 3945 	inc	dptr
   0E1D F0                 3946 	movx	@dptr,a
   0E1E A3                 3947 	inc	dptr
   0E1F F0                 3948 	movx	@dptr,a
                           3949 ;	../../include/ztex-fpga7.h:105: fpga_checksum = 0;
   0E20 90 3A 20           3950 	mov	dptr,#_fpga_checksum
   0E23 E4                 3951 	clr	a
   0E24 F0                 3952 	movx	@dptr,a
   0E25 22                 3953 	ret
                           3954 ;------------------------------------------------------------
                           3955 ;Allocation info for local variables in function 'post_fpga_config'
                           3956 ;------------------------------------------------------------
                           3957 ;------------------------------------------------------------
                           3958 ;	../../include/ztex-fpga7.h:111: static void post_fpga_config () {
                           3959 ;	-----------------------------------------
                           3960 ;	 function post_fpga_config
                           3961 ;	-----------------------------------------
   0E26                    3962 _post_fpga_config:
                           3963 ;	../../include/ztex-fpga7.h:113: }
   0E26 22                 3964 	ret
                           3965 ;------------------------------------------------------------
                           3966 ;Allocation info for local variables in function 'finish_fpga_configuration'
                           3967 ;------------------------------------------------------------
                           3968 ;w                         Allocated to registers r2 
                           3969 ;------------------------------------------------------------
                           3970 ;	../../include/ztex-fpga7.h:118: static void finish_fpga_configuration () {
                           3971 ;	-----------------------------------------
                           3972 ;	 function finish_fpga_configuration
                           3973 ;	-----------------------------------------
   0E27                    3974 _finish_fpga_configuration:
                           3975 ;	../../include/ztex-fpga7.h:120: fpga_init_b += IOA7 ? 22 : 11;
   0E27 30 87 04           3976 	jnb	_IOA7,00109$
   0E2A 7A 16              3977 	mov	r2,#0x16
   0E2C 80 02              3978 	sjmp	00110$
   0E2E                    3979 00109$:
   0E2E 7A 0B              3980 	mov	r2,#0x0B
   0E30                    3981 00110$:
   0E30 90 3A 25           3982 	mov	dptr,#_fpga_init_b
   0E33 E0                 3983 	movx	a,@dptr
   0E34 FB                 3984 	mov	r3,a
   0E35 EA                 3985 	mov	a,r2
   0E36 2B                 3986 	add	a,r3
   0E37 F0                 3987 	movx	@dptr,a
                           3988 ;	../../include/ztex-fpga7.h:122: for ( w=0; w<64; w++ ) {
   0E38 7A 00              3989 	mov	r2,#0x00
   0E3A                    3990 00103$:
   0E3A BA 40 00           3991 	cjne	r2,#0x40,00117$
   0E3D                    3992 00117$:
   0E3D 50 07              3993 	jnc	00106$
                           3994 ;	../../include/ztex-fpga7.h:123: IOA0 = 1; IOA0 = 0; 
   0E3F D2 80              3995 	setb	_IOA0
   0E41 C2 80              3996 	clr	_IOA0
                           3997 ;	../../include/ztex-fpga7.h:122: for ( w=0; w<64; w++ ) {
   0E43 0A                 3998 	inc	r2
   0E44 80 F4              3999 	sjmp	00103$
   0E46                    4000 00106$:
                           4001 ;	../../include/ztex-fpga7.h:125: IOA1 = 1;
   0E46 D2 81              4002 	setb	_IOA1
                           4003 ;	../../include/ztex-fpga7.h:126: IOA0 = 1; IOA0 = 0;
   0E48 D2 80              4004 	setb	_IOA0
   0E4A C2 80              4005 	clr	_IOA0
                           4006 ;	../../include/ztex-fpga7.h:127: IOA0 = 1; IOA0 = 0;
   0E4C D2 80              4007 	setb	_IOA0
   0E4E C2 80              4008 	clr	_IOA0
                           4009 ;	../../include/ztex-fpga7.h:128: IOA0 = 1; IOA0 = 0;
   0E50 D2 80              4010 	setb	_IOA0
   0E52 C2 80              4011 	clr	_IOA0
                           4012 ;	../../include/ztex-fpga7.h:129: IOA0 = 1; IOA0 = 0;
   0E54 D2 80              4013 	setb	_IOA0
   0E56 C2 80              4014 	clr	_IOA0
                           4015 ;	../../include/ztex-fpga7.h:131: OEA = OOEA;
   0E58 90 3A 28           4016 	mov	dptr,#_OOEA
   0E5B E0                 4017 	movx	a,@dptr
   0E5C F5 B2              4018 	mov	_OEA,a
                           4019 ;	../../include/ztex-fpga7.h:132: if ( IOE & bmBIT6 )  {
   0E5E E5 B1              4020 	mov	a,_IOE
   0E60 30 E6 03           4021 	jnb	acc.6,00107$
                           4022 ;	../../include/ztex-fpga7.h:133: post_fpga_config();
   0E63 02 0E 26           4023 	ljmp	_post_fpga_config
   0E66                    4024 00107$:
   0E66 22                 4025 	ret
                           4026 ;------------------------------------------------------------
                           4027 ;Allocation info for local variables in function 'fpga_send_ep0'
                           4028 ;------------------------------------------------------------
                           4029 ;oOEC                      Allocated with name '_fpga_send_ep0_oOEC_1_1'
                           4030 ;------------------------------------------------------------
                           4031 ;	../../include/ztex-fpga7.h:169: void fpga_send_ep0() {
                           4032 ;	-----------------------------------------
                           4033 ;	 function fpga_send_ep0
                           4034 ;	-----------------------------------------
   0E67                    4035 _fpga_send_ep0:
                           4036 ;	../../include/ztex-fpga7.h:171: oOEC = OEC;
   0E67 85 B4 15           4037 	mov	_fpga_send_ep0_oOEC_1_1,_OEC
                           4038 ;	../../include/ztex-fpga7.h:172: OEC = 255;
   0E6A 75 B4 FF           4039 	mov	_OEC,#0xFF
                           4040 ;	../../include/ztex-fpga7.h:173: fpga_bytes += ep0_payload_transfer;
   0E6D 90 3A 38           4041 	mov	dptr,#_ep0_payload_transfer
   0E70 E0                 4042 	movx	a,@dptr
   0E71 FB                 4043 	mov	r3,a
   0E72 90 3A 21           4044 	mov	dptr,#_fpga_bytes
   0E75 E0                 4045 	movx	a,@dptr
   0E76 FC                 4046 	mov	r4,a
   0E77 A3                 4047 	inc	dptr
   0E78 E0                 4048 	movx	a,@dptr
   0E79 FD                 4049 	mov	r5,a
   0E7A A3                 4050 	inc	dptr
   0E7B E0                 4051 	movx	a,@dptr
   0E7C FE                 4052 	mov	r6,a
   0E7D A3                 4053 	inc	dptr
   0E7E E0                 4054 	movx	a,@dptr
   0E7F FF                 4055 	mov	r7,a
   0E80 78 00              4056 	mov	r0,#0x00
   0E82 79 00              4057 	mov	r1,#0x00
   0E84 7A 00              4058 	mov	r2,#0x00
   0E86 90 3A 21           4059 	mov	dptr,#_fpga_bytes
   0E89 EB                 4060 	mov	a,r3
   0E8A 2C                 4061 	add	a,r4
   0E8B F0                 4062 	movx	@dptr,a
   0E8C E8                 4063 	mov	a,r0
   0E8D 3D                 4064 	addc	a,r5
   0E8E A3                 4065 	inc	dptr
   0E8F F0                 4066 	movx	@dptr,a
   0E90 E9                 4067 	mov	a,r1
   0E91 3E                 4068 	addc	a,r6
   0E92 A3                 4069 	inc	dptr
   0E93 F0                 4070 	movx	@dptr,a
   0E94 EA                 4071 	mov	a,r2
   0E95 3F                 4072 	addc	a,r7
   0E96 A3                 4073 	inc	dptr
   0E97 F0                 4074 	movx	@dptr,a
                           4075 ;	../../include/ztex-fpga7.h:201: OEC = oOEC;
                           4076 	
   0E98 90 E6 8B           4077 	 mov dptr,#_EP0BCL
   0E9B E0                 4078 	 movx a,@dptr
   0E9C 60 22              4079 	 jz 010000$
   0E9E FA                 4080 	   mov r2,a
   0E9F 75 9B 40           4081 	 mov _AUTOPTRL1,#(_EP0BUF)
   0EA2 75 9A E7           4082 	 mov _AUTOPTRH1,#(_EP0BUF >> 8)
   0EA5 75 AF 07           4083 	 mov _AUTOPTRSETUP,#0x07
   0EA8 90 3A 20           4084 	 mov dptr,#_fpga_checksum
   0EAB E0                 4085 	 movx a,@dptr
   0EAC F9                 4086 	 mov r1,a
   0EAD 90 E6 7B           4087 	 mov dptr,#_XAUTODAT1
   0EB0                    4088 	010001$:
   0EB0 E0                 4089 	 movx a,@dptr
   0EB1 F5 A0              4090 	 mov _IOC,a
   0EB3 D2 80              4091 	 setb _IOA0
   0EB5 29                 4092 	 add a,r1
   0EB6 F9                 4093 	 mov r1,a
   0EB7 C2 80              4094 	 clr _IOA0
   0EB9 DA F5              4095 	 djnz r2, 010001$
                           4096 ;	# 194 "../../include/ztex-fpga7.h"
                           4097 	
   0EBB 90 3A 20           4098 	 mov dptr,#_fpga_checksum
   0EBE E9                 4099 	 mov a,r1
   0EBF F0                 4100 	 movx @dptr,a
                           4101 	
   0EC0                    4102 	010000$:
                           4103 	     
                           4104 ;	../../include/ztex-fpga7.h:202: if ( EP0BCL<64 ) {
   0EC0 85 15 B4           4105 	mov	_OEC,_fpga_send_ep0_oOEC_1_1
                           4106 ;	../../include/ztex-fpga7.h:203: finish_fpga_configuration();
   0EC3 90 E6 8B           4107 	mov	dptr,#_EP0BCL
   0EC6 E0                 4108 	movx	a,@dptr
   0EC7 FA                 4109 	mov	r2,a
   0EC8 BA 40 00           4110 	cjne	r2,#0x40,00106$
   0ECB                    4111 00106$:
   0ECB 50 03              4112 	jnc	00103$
                           4113 ;	../../include/ztex-fpga7.h:204: } 
   0ECD 02 0E 27           4114 	ljmp	_finish_fpga_configuration
   0ED0                    4115 00103$:
   0ED0 22                 4116 	ret
                           4117 ;------------------------------------------------------------
                           4118 ;Allocation info for local variables in function 'fpga_configure_from_flash'
                           4119 ;------------------------------------------------------------
                           4120 ;force                     Allocated to registers r2 
                           4121 ;i                         Allocated to registers r2 r3 
                           4122 ;------------------------------------------------------------
                           4123 ;	../../include/ztex-fpga7.h:227: BYTE fpga_configure_from_flash( BYTE force ) {
                           4124 ;	-----------------------------------------
                           4125 ;	 function fpga_configure_from_flash
                           4126 ;	-----------------------------------------
   0ED1                    4127 _fpga_configure_from_flash:
                           4128 ;	../../include/ztex-fpga7.h:231: if ( ( force == 0 ) && ( IOE & bmBIT6 ) ) {
   0ED1 E5 82              4129 	mov	a,dpl
   0ED3 FA                 4130 	mov	r2,a
   0ED4 70 0F              4131 	jnz	00102$
   0ED6 E5 B1              4132 	mov	a,_IOE
   0ED8 30 E6 0A           4133 	jnb	acc.6,00102$
                           4134 ;	../../include/ztex-fpga7.h:232: fpga_flash_result = 1;
   0EDB 90 3A 26           4135 	mov	dptr,#_fpga_flash_result
   0EDE 74 01              4136 	mov	a,#0x01
   0EE0 F0                 4137 	movx	@dptr,a
                           4138 ;	../../include/ztex-fpga7.h:233: return 1;
   0EE1 75 82 01           4139 	mov	dpl,#0x01
   0EE4 22                 4140 	ret
   0EE5                    4141 00102$:
                           4142 ;	../../include/ztex-fpga7.h:236: fpga_flash_result = 0;
   0EE5 90 3A 26           4143 	mov	dptr,#_fpga_flash_result
   0EE8 E4                 4144 	clr	a
   0EE9 F0                 4145 	movx	@dptr,a
                           4146 ;	../../include/ztex-fpga7.h:238: IFCONFIG = bmBIT7;
   0EEA 90 E6 01           4147 	mov	dptr,#_IFCONFIG
   0EED 74 80              4148 	mov	a,#0x80
   0EEF F0                 4149 	movx	@dptr,a
                           4150 ;	../../include/ezregs.h:46: __endasm;
                           4151 	
   0EF0 00                 4152 	 nop
   0EF1 00                 4153 	 nop
   0EF2 00                 4154 	 nop
   0EF3 00                 4155 	 nop
                           4156 	    
                           4157 ;	../../include/ztex-fpga7.h:240: PORTACFG = 0;
   0EF4 90 E6 70           4158 	mov	dptr,#_PORTACFG
                           4159 ;	../../include/ztex-fpga7.h:241: PORTCCFG = 0;
   0EF7 E4                 4160 	clr	a
   0EF8 F0                 4161 	movx	@dptr,a
   0EF9 90 E6 71           4162 	mov	dptr,#_PORTCCFG
   0EFC F0                 4163 	movx	@dptr,a
                           4164 ;	../../include/ztex-fpga7.h:244: OEA &= bmBIT2;			// only unsed PA bit
   0EFD 53 B2 04           4165 	anl	_OEA,#0x04
                           4166 ;	../../include/ztex-fpga7.h:247: OEC &= ~bmBIT0;
   0F00 53 B4 FE           4167 	anl	_OEC,#0xFE
                           4168 ;	../../include/ztex-fpga7.h:249: OEE = (OEE & ~bmBIT6) | bmBIT7;
   0F03 AA B6              4169 	mov	r2,_OEE
   0F05 74 BF              4170 	mov	a,#0xBF
   0F07 5A                 4171 	anl	a,r2
   0F08 F5 F0              4172 	mov	b,a
   0F0A 74 80              4173 	mov	a,#0x80
   0F0C 45 F0              4174 	orl	a,b
   0F0E F5 B6              4175 	mov	_OEE,a
                           4176 ;	../../include/ztex-fpga7.h:250: IOE = IOE & ~bmBIT7;		// PROG_B = 0
   0F10 53 B1 7F           4177 	anl	_IOE,#0x7F
                           4178 ;	../../include/ztex-fpga7.h:253: OEA |= bmBIT4 | bmBIT5;
   0F13 43 B2 30           4179 	orl	_OEA,#0x30
                           4180 ;	../../include/ztex-fpga7.h:254: IOA = ( IOA & bmBIT2 ) | bmBIT4;
   0F16 74 04              4181 	mov	a,#0x04
   0F18 55 80              4182 	anl	a,_IOA
   0F1A F5 F0              4183 	mov	b,a
   0F1C 74 10              4184 	mov	a,#0x10
   0F1E 45 F0              4185 	orl	a,b
   0F20 F5 80              4186 	mov	_IOA,a
                           4187 ;	../../include/ztex-fpga7.h:255: wait(1);
   0F22 90 00 01           4188 	mov	dptr,#0x0001
   0F25 12 02 65           4189 	lcall	_wait
                           4190 ;	../../include/ztex-fpga7.h:257: IOE = IOE | bmBIT7;			// PROG_B = 1
   0F28 43 B1 80           4191 	orl	_IOE,#0x80
                           4192 ;	../../include/ztex-fpga7.h:260: wait(20);
   0F2B 90 00 14           4193 	mov	dptr,#0x0014
   0F2E 12 02 65           4194 	lcall	_wait
                           4195 ;	../../include/ztex-fpga7.h:261: for (i=0; IOA7 && (!IOA1) && i<4000; i++ ) { 
   0F31 7A 00              4196 	mov	r2,#0x00
   0F33 7B 00              4197 	mov	r3,#0x00
   0F35                    4198 00109$:
   0F35 30 87 21           4199 	jnb	_IOA7,00112$
   0F38 20 81 1E           4200 	jb	_IOA1,00112$
   0F3B C3                 4201 	clr	c
   0F3C EA                 4202 	mov	a,r2
   0F3D 94 A0              4203 	subb	a,#0xA0
   0F3F EB                 4204 	mov	a,r3
   0F40 94 0F              4205 	subb	a,#0x0F
   0F42 50 15              4206 	jnc	00112$
                           4207 ;	../../include/ztex-fpga7.h:262: wait(1);
   0F44 90 00 01           4208 	mov	dptr,#0x0001
   0F47 C0 02              4209 	push	ar2
   0F49 C0 03              4210 	push	ar3
   0F4B 12 02 65           4211 	lcall	_wait
   0F4E D0 03              4212 	pop	ar3
   0F50 D0 02              4213 	pop	ar2
                           4214 ;	../../include/ztex-fpga7.h:261: for (i=0; IOA7 && (!IOA1) && i<4000; i++ ) { 
   0F52 0A                 4215 	inc	r2
   0F53 BA 00 DF           4216 	cjne	r2,#0x00,00109$
   0F56 0B                 4217 	inc	r3
   0F57 80 DC              4218 	sjmp	00109$
   0F59                    4219 00112$:
                           4220 ;	../../include/ztex-fpga7.h:265: wait(1);
   0F59 90 00 01           4221 	mov	dptr,#0x0001
   0F5C 12 02 65           4222 	lcall	_wait
                           4223 ;	../../include/ztex-fpga7.h:267: if ( IOE & bmBIT6 )  {
   0F5F E5 B1              4224 	mov	a,_IOE
   0F61 30 E6 05           4225 	jnb	acc.6,00105$
                           4226 ;	../../include/ztex-fpga7.h:269: post_fpga_config();
   0F64 12 0E 26           4227 	lcall	_post_fpga_config
   0F67 80 09              4228 	sjmp	00106$
   0F69                    4229 00105$:
                           4230 ;	../../include/ztex-fpga7.h:274: init_fpga();
   0F69 12 0D 52           4231 	lcall	_init_fpga
                           4232 ;	../../include/ztex-fpga7.h:275: fpga_flash_result = 4;
   0F6C 90 3A 26           4233 	mov	dptr,#_fpga_flash_result
   0F6F 74 04              4234 	mov	a,#0x04
   0F71 F0                 4235 	movx	@dptr,a
   0F72                    4236 00106$:
                           4237 ;	../../include/ztex-fpga7.h:278: return fpga_flash_result;
   0F72 90 3A 26           4238 	mov	dptr,#_fpga_flash_result
   0F75 E0                 4239 	movx	a,@dptr
   0F76 F5 82              4240 	mov	dpl,a
   0F78 22                 4241 	ret
                           4242 ;------------------------------------------------------------
                           4243 ;Allocation info for local variables in function 'fpga_first_free_sector'
                           4244 ;------------------------------------------------------------
                           4245 ;i                         Allocated to registers r2 
                           4246 ;j                         Allocated to registers r3 
                           4247 ;buf                       Allocated with name '_fpga_first_free_sector_buf_1_1'
                           4248 ;------------------------------------------------------------
                           4249 ;	../../include/ztex-fpga-flash2.h:31: WORD fpga_first_free_sector() {
                           4250 ;	-----------------------------------------
                           4251 ;	 function fpga_first_free_sector
                           4252 ;	-----------------------------------------
   0F79                    4253 _fpga_first_free_sector:
                           4254 ;	../../include/ztex-fpga-flash2.h:36: if ( config_data_valid ) {
   0F79 90 3A 06           4255 	mov	dptr,#_config_data_valid
   0F7C E0                 4256 	movx	a,@dptr
   0F7D FA                 4257 	mov	r2,a
   0F7E 60 56              4258 	jz	00104$
                           4259 ;	../../include/ztex-fpga-flash2.h:37: mac_eeprom_read ( (__xdata BYTE*) buf, 26, 4 );		// read actual and max bitstream size 
   0F80 75 10 1A           4260 	mov	_mac_eeprom_read_PARM_2,#0x1A
   0F83 75 11 04           4261 	mov	_mac_eeprom_read_PARM_3,#0x04
   0F86 90 3A 29           4262 	mov	dptr,#_fpga_first_free_sector_buf_1_1
   0F89 12 05 D4           4263 	lcall	_mac_eeprom_read
                           4264 ;	../../include/ztex-fpga-flash2.h:38: if ( buf[1] != 0 ) {
   0F8C 90 3A 2B           4265 	mov	dptr,#(_fpga_first_free_sector_buf_1_1 + 0x0002)
   0F8F E0                 4266 	movx	a,@dptr
   0F90 FA                 4267 	mov	r2,a
   0F91 A3                 4268 	inc	dptr
   0F92 E0                 4269 	movx	a,@dptr
   0F93 FB                 4270 	mov	r3,a
   0F94 4A                 4271 	orl	a,r2
   0F95 60 3F              4272 	jz	00104$
                           4273 ;	../../include/ztex-fpga-flash2.h:39: return ( ( ( buf[1] > buf[0] ? buf[1] : buf[0] ) - 1 ) >> ((flash_sector_size & 255) - 12) ) + 1;
   0F97 90 3A 29           4274 	mov	dptr,#_fpga_first_free_sector_buf_1_1
   0F9A E0                 4275 	movx	a,@dptr
   0F9B FC                 4276 	mov	r4,a
   0F9C A3                 4277 	inc	dptr
   0F9D E0                 4278 	movx	a,@dptr
   0F9E FD                 4279 	mov	r5,a
   0F9F C3                 4280 	clr	c
   0FA0 EC                 4281 	mov	a,r4
   0FA1 9A                 4282 	subb	a,r2
   0FA2 ED                 4283 	mov	a,r5
   0FA3 9B                 4284 	subb	a,r3
   0FA4 40 04              4285 	jc	00115$
   0FA6 8C 02              4286 	mov	ar2,r4
   0FA8 8D 03              4287 	mov	ar3,r5
   0FAA                    4288 00115$:
   0FAA 1A                 4289 	dec	r2
   0FAB BA FF 01           4290 	cjne	r2,#0xff,00127$
   0FAE 1B                 4291 	dec	r3
   0FAF                    4292 00127$:
   0FAF 90 3A 08           4293 	mov	dptr,#_flash_sector_size
   0FB2 E0                 4294 	movx	a,@dptr
   0FB3 FC                 4295 	mov	r4,a
   0FB4 A3                 4296 	inc	dptr
   0FB5 E0                 4297 	movx	a,@dptr
   0FB6 7D 00              4298 	mov	r5,#0x00
   0FB8 EC                 4299 	mov	a,r4
   0FB9 24 F4              4300 	add	a,#0xf4
   0FBB FC                 4301 	mov	r4,a
   0FBC ED                 4302 	mov	a,r5
   0FBD 34 FF              4303 	addc	a,#0xff
   0FBF FD                 4304 	mov	r5,a
   0FC0 8C F0              4305 	mov	b,r4
   0FC2 05 F0              4306 	inc	b
   0FC4 80 07              4307 	sjmp	00129$
   0FC6                    4308 00128$:
   0FC6 C3                 4309 	clr	c
   0FC7 EB                 4310 	mov	a,r3
   0FC8 13                 4311 	rrc	a
   0FC9 FB                 4312 	mov	r3,a
   0FCA EA                 4313 	mov	a,r2
   0FCB 13                 4314 	rrc	a
   0FCC FA                 4315 	mov	r2,a
   0FCD                    4316 00129$:
   0FCD D5 F0 F6           4317 	djnz	b,00128$
   0FD0 8A 82              4318 	mov	dpl,r2
   0FD2 8B 83              4319 	mov	dph,r3
   0FD4 A3                 4320 	inc	dptr
   0FD5 22                 4321 	ret
   0FD6                    4322 00104$:
                           4323 ;	../../include/ztex-fpga-flash2.h:42: #endif    
   0FD6 90 00 00           4324 	mov	dptr,#0x0000
   0FD9 12 09 63           4325 	lcall	_flash_read_init
                           4326 ;	../../include/ztex-fpga-flash2.h:44: for ( i=0; i<8 && flash_read_byte()==fpga_flash_boot_id[i]; i++ );
   0FDC 7A 00              4327 	mov	r2,#0x00
   0FDE                    4328 00108$:
   0FDE BA 08 00           4329 	cjne	r2,#0x08,00130$
   0FE1                    4330 00130$:
   0FE1 50 16              4331 	jnc	00111$
   0FE3 C0 02              4332 	push	ar2
   0FE5 12 07 E9           4333 	lcall	_flash_read_byte
   0FE8 AB 82              4334 	mov	r3,dpl
   0FEA D0 02              4335 	pop	ar2
   0FEC EA                 4336 	mov	a,r2
   0FED 90 1E 55           4337 	mov	dptr,#_fpga_flash_boot_id
   0FF0 93                 4338 	movc	a,@a+dptr
   0FF1 FC                 4339 	mov	r4,a
   0FF2 EB                 4340 	mov	a,r3
   0FF3 B5 04 03           4341 	cjne	a,ar4,00111$
   0FF6 0A                 4342 	inc	r2
   0FF7 80 E5              4343 	sjmp	00108$
   0FF9                    4344 00111$:
                           4345 ;	../../include/ztex-fpga-flash2.h:45: if ( i != 8 ) {
   0FF9 BA 08 02           4346 	cjne	r2,#0x08,00134$
   0FFC 80 1A              4347 	sjmp	00106$
   0FFE                    4348 00134$:
                           4349 ;	../../include/ztex-fpga-flash2.h:46: flash_read_finish(flash_sector_size - i);	// dummy-read the rest of the sector + finish read opration
   0FFE 7B 00              4350 	mov	r3,#0x00
   1000 90 3A 08           4351 	mov	dptr,#_flash_sector_size
   1003 E0                 4352 	movx	a,@dptr
   1004 FC                 4353 	mov	r4,a
   1005 A3                 4354 	inc	dptr
   1006 E0                 4355 	movx	a,@dptr
   1007 FD                 4356 	mov	r5,a
   1008 EC                 4357 	mov	a,r4
   1009 C3                 4358 	clr	c
   100A 9A                 4359 	subb	a,r2
   100B F5 82              4360 	mov	dpl,a
   100D ED                 4361 	mov	a,r5
   100E 9B                 4362 	subb	a,r3
   100F F5 83              4363 	mov	dph,a
   1011 12 09 E9           4364 	lcall	_flash_read_finish
                           4365 ;	../../include/ztex-fpga-flash2.h:47: return 0;
   1014 90 00 00           4366 	mov	dptr,#0x0000
   1017 22                 4367 	ret
   1018                    4368 00106$:
                           4369 ;	../../include/ztex-fpga-flash2.h:49: i=flash_read_byte();
   1018 12 07 E9           4370 	lcall	_flash_read_byte
   101B AA 82              4371 	mov	r2,dpl
                           4372 ;	../../include/ztex-fpga-flash2.h:50: j=flash_read_byte();
   101D C0 02              4373 	push	ar2
   101F 12 07 E9           4374 	lcall	_flash_read_byte
   1022 AB 82              4375 	mov	r3,dpl
                           4376 ;	../../include/ztex-fpga-flash2.h:51: flash_read_finish(flash_sector_size - 10);		// dummy-read the rest of the sector + finish read opration
   1024 90 3A 08           4377 	mov	dptr,#_flash_sector_size
   1027 E0                 4378 	movx	a,@dptr
   1028 FC                 4379 	mov	r4,a
   1029 A3                 4380 	inc	dptr
   102A E0                 4381 	movx	a,@dptr
   102B FD                 4382 	mov	r5,a
   102C EC                 4383 	mov	a,r4
   102D 24 F6              4384 	add	a,#0xf6
   102F F5 82              4385 	mov	dpl,a
   1031 ED                 4386 	mov	a,r5
   1032 34 FF              4387 	addc	a,#0xff
   1034 F5 83              4388 	mov	dph,a
   1036 C0 03              4389 	push	ar3
   1038 12 09 E9           4390 	lcall	_flash_read_finish
   103B D0 03              4391 	pop	ar3
   103D D0 02              4392 	pop	ar2
                           4393 ;	../../include/ztex-fpga-flash2.h:53: return (i | (j<<8))+1;
   103F 8B 04              4394 	mov	ar4,r3
   1041 E4                 4395 	clr	a
   1042 FB                 4396 	mov	r3,a
   1043 FD                 4397 	mov	r5,a
   1044 EA                 4398 	mov	a,r2
   1045 42 03              4399 	orl	ar3,a
   1047 ED                 4400 	mov	a,r5
   1048 42 04              4401 	orl	ar4,a
   104A 8B 82              4402 	mov	dpl,r3
   104C 8C 83              4403 	mov	dph,r4
   104E A3                 4404 	inc	dptr
   104F 22                 4405 	ret
                           4406 ;------------------------------------------------------------
                           4407 ;Allocation info for local variables in function 'fpga_configure_from_flash_init'
                           4408 ;------------------------------------------------------------
                           4409 ;i                         Allocated to registers r2 
                           4410 ;buf                       Allocated with name '_fpga_configure_from_flash_init_buf_1_1'
                           4411 ;------------------------------------------------------------
                           4412 ;	../../include/ztex-fpga-flash2.h:60: BYTE fpga_configure_from_flash_init() {
                           4413 ;	-----------------------------------------
                           4414 ;	 function fpga_configure_from_flash_init
                           4415 ;	-----------------------------------------
   1050                    4416 _fpga_configure_from_flash_init:
                           4417 ;	../../include/ztex-fpga-flash2.h:66: if ( config_data_valid ) {
   1050 90 3A 06           4418 	mov	dptr,#_config_data_valid
   1053 E0                 4419 	movx	a,@dptr
   1054 FA                 4420 	mov	r2,a
   1055 60 2F              4421 	jz	00106$
                           4422 ;	../../include/ztex-fpga-flash2.h:67: mac_eeprom_read ( (__xdata BYTE*) buf, 26, 4 );		// read actual and max bitstream size 
   1057 75 10 1A           4423 	mov	_mac_eeprom_read_PARM_2,#0x1A
   105A 75 11 04           4424 	mov	_mac_eeprom_read_PARM_3,#0x04
   105D 90 3A 2D           4425 	mov	dptr,#_fpga_configure_from_flash_init_buf_1_1
   1060 12 05 D4           4426 	lcall	_mac_eeprom_read
                           4427 ;	../../include/ztex-fpga-flash2.h:68: if ( buf[1] != 0 ) {
   1063 90 3A 2F           4428 	mov	dptr,#(_fpga_configure_from_flash_init_buf_1_1 + 0x0002)
   1066 E0                 4429 	movx	a,@dptr
   1067 FA                 4430 	mov	r2,a
   1068 A3                 4431 	inc	dptr
   1069 E0                 4432 	movx	a,@dptr
   106A FB                 4433 	mov	r3,a
   106B 4A                 4434 	orl	a,r2
   106C 60 18              4435 	jz	00106$
                           4436 ;	../../include/ztex-fpga-flash2.h:69: if ( buf[0] == 0 ) {
   106E 90 3A 2D           4437 	mov	dptr,#_fpga_configure_from_flash_init_buf_1_1
   1071 E0                 4438 	movx	a,@dptr
   1072 FA                 4439 	mov	r2,a
   1073 A3                 4440 	inc	dptr
   1074 E0                 4441 	movx	a,@dptr
   1075 FB                 4442 	mov	r3,a
   1076 4A                 4443 	orl	a,r2
   1077 60 03              4444 	jz	00140$
   1079 02 11 13           4445 	ljmp	00113$
   107C                    4446 00140$:
                           4447 ;	../../include/ztex-fpga-flash2.h:70: return fpga_flash_result = 3;
   107C 90 3A 26           4448 	mov	dptr,#_fpga_flash_result
   107F 74 03              4449 	mov	a,#0x03
   1081 F0                 4450 	movx	@dptr,a
   1082 75 82 03           4451 	mov	dpl,#0x03
   1085 22                 4452 	ret
                           4453 ;	../../include/ztex-fpga-flash2.h:73: goto flash_config;
   1086                    4454 00106$:
                           4455 ;	../../include/ztex-fpga-flash2.h:80: if ( flash_read_init( 0 ) )		// prepare reading sector 0
   1086 90 00 00           4456 	mov	dptr,#0x0000
   1089 12 09 63           4457 	lcall	_flash_read_init
   108C E5 82              4458 	mov	a,dpl
   108E 60 0A              4459 	jz	00132$
                           4460 ;	../../include/ztex-fpga-flash2.h:81: return fpga_flash_result = 2;
   1090 90 3A 26           4461 	mov	dptr,#_fpga_flash_result
   1093 74 02              4462 	mov	a,#0x02
   1095 F0                 4463 	movx	@dptr,a
   1096 75 82 02           4464 	mov	dpl,#0x02
   1099 22                 4465 	ret
                           4466 ;	../../include/ztex-fpga-flash2.h:82: for ( i=0; i<8 && flash_read_byte()==fpga_flash_boot_id[i]; i++ );
   109A                    4467 00132$:
   109A 7A 00              4468 	mov	r2,#0x00
   109C                    4469 00120$:
   109C BA 08 00           4470 	cjne	r2,#0x08,00142$
   109F                    4471 00142$:
   109F 50 16              4472 	jnc	00123$
   10A1 C0 02              4473 	push	ar2
   10A3 12 07 E9           4474 	lcall	_flash_read_byte
   10A6 AB 82              4475 	mov	r3,dpl
   10A8 D0 02              4476 	pop	ar2
   10AA EA                 4477 	mov	a,r2
   10AB 90 1E 55           4478 	mov	dptr,#_fpga_flash_boot_id
   10AE 93                 4479 	movc	a,@a+dptr
   10AF FC                 4480 	mov	r4,a
   10B0 EB                 4481 	mov	a,r3
   10B1 B5 04 03           4482 	cjne	a,ar4,00123$
   10B4 0A                 4483 	inc	r2
   10B5 80 E5              4484 	sjmp	00120$
   10B7                    4485 00123$:
                           4486 ;	../../include/ztex-fpga-flash2.h:83: if ( i != 8 ) {
   10B7 BA 08 02           4487 	cjne	r2,#0x08,00146$
   10BA 80 20              4488 	sjmp	00110$
   10BC                    4489 00146$:
                           4490 ;	../../include/ztex-fpga-flash2.h:84: flash_read_finish(flash_sector_size - i);	// dummy-read the rest of the sector + finish read opration
   10BC 7B 00              4491 	mov	r3,#0x00
   10BE 90 3A 08           4492 	mov	dptr,#_flash_sector_size
   10C1 E0                 4493 	movx	a,@dptr
   10C2 FC                 4494 	mov	r4,a
   10C3 A3                 4495 	inc	dptr
   10C4 E0                 4496 	movx	a,@dptr
   10C5 FD                 4497 	mov	r5,a
   10C6 EC                 4498 	mov	a,r4
   10C7 C3                 4499 	clr	c
   10C8 9A                 4500 	subb	a,r2
   10C9 F5 82              4501 	mov	dpl,a
   10CB ED                 4502 	mov	a,r5
   10CC 9B                 4503 	subb	a,r3
   10CD F5 83              4504 	mov	dph,a
   10CF 12 09 E9           4505 	lcall	_flash_read_finish
                           4506 ;	../../include/ztex-fpga-flash2.h:85: return fpga_flash_result = 3;
   10D2 90 3A 26           4507 	mov	dptr,#_fpga_flash_result
   10D5 74 03              4508 	mov	a,#0x03
   10D7 F0                 4509 	movx	@dptr,a
   10D8 75 82 03           4510 	mov	dpl,#0x03
   10DB 22                 4511 	ret
   10DC                    4512 00110$:
                           4513 ;	../../include/ztex-fpga-flash2.h:87: i = flash_read_byte();
   10DC 12 07 E9           4514 	lcall	_flash_read_byte
   10DF AA 82              4515 	mov	r2,dpl
                           4516 ;	../../include/ztex-fpga-flash2.h:88: i |= flash_read_byte();
   10E1 C0 02              4517 	push	ar2
   10E3 12 07 E9           4518 	lcall	_flash_read_byte
   10E6 AB 82              4519 	mov	r3,dpl
   10E8 D0 02              4520 	pop	ar2
   10EA EB                 4521 	mov	a,r3
   10EB 42 02              4522 	orl	ar2,a
                           4523 ;	../../include/ztex-fpga-flash2.h:89: flash_read_finish(flash_sector_size - 10);		// dummy-read the rest of the sector + finish read opration
   10ED 90 3A 08           4524 	mov	dptr,#_flash_sector_size
   10F0 E0                 4525 	movx	a,@dptr
   10F1 FB                 4526 	mov	r3,a
   10F2 A3                 4527 	inc	dptr
   10F3 E0                 4528 	movx	a,@dptr
   10F4 FC                 4529 	mov	r4,a
   10F5 EB                 4530 	mov	a,r3
   10F6 24 F6              4531 	add	a,#0xf6
   10F8 F5 82              4532 	mov	dpl,a
   10FA EC                 4533 	mov	a,r4
   10FB 34 FF              4534 	addc	a,#0xff
   10FD F5 83              4535 	mov	dph,a
   10FF C0 02              4536 	push	ar2
   1101 12 09 E9           4537 	lcall	_flash_read_finish
   1104 D0 02              4538 	pop	ar2
                           4539 ;	../../include/ztex-fpga-flash2.h:90: if ( i==0 )
   1106 EA                 4540 	mov	a,r2
   1107 70 0A              4541 	jnz	00113$
                           4542 ;	../../include/ztex-fpga-flash2.h:91: return fpga_flash_result = 3;
   1109 90 3A 26           4543 	mov	dptr,#_fpga_flash_result
   110C 74 03              4544 	mov	a,#0x03
   110E F0                 4545 	movx	@dptr,a
   110F 75 82 03           4546 	mov	dpl,#0x03
                           4547 ;	../../include/ztex-fpga-flash2.h:93: flash_config:
   1112 22                 4548 	ret
   1113                    4549 00113$:
                           4550 ;	../../include/ztex-fpga-flash2.h:94: fpga_flash_result = fpga_configure_from_flash(0);
   1113 75 82 00           4551 	mov	dpl,#0x00
   1116 12 0E D1           4552 	lcall	_fpga_configure_from_flash
   1119 AA 82              4553 	mov	r2,dpl
   111B 90 3A 26           4554 	mov	dptr,#_fpga_flash_result
   111E EA                 4555 	mov	a,r2
   111F F0                 4556 	movx	@dptr,a
                           4557 ;	../../include/ztex-fpga-flash2.h:95: if ( fpga_flash_result == 1 ) {
   1120 BA 01 05           4558 	cjne	r2,#0x01,00117$
                           4559 ;	../../include/ztex-fpga-flash2.h:96: post_fpga_config();
   1123 12 0E 26           4560 	lcall	_post_fpga_config
   1126 80 0F              4561 	sjmp	00118$
   1128                    4562 00117$:
                           4563 ;	../../include/ztex-fpga-flash2.h:98: else if ( fpga_flash_result == 4 ) {
   1128 BA 04 0C           4564 	cjne	r2,#0x04,00118$
                           4565 ;	../../include/ztex-fpga-flash2.h:99: fpga_flash_result = fpga_configure_from_flash(0);	// up to two tries
   112B 75 82 00           4566 	mov	dpl,#0x00
   112E 12 0E D1           4567 	lcall	_fpga_configure_from_flash
   1131 E5 82              4568 	mov	a,dpl
   1133 90 3A 26           4569 	mov	dptr,#_fpga_flash_result
   1136 F0                 4570 	movx	@dptr,a
   1137                    4571 00118$:
                           4572 ;	../../include/ztex-fpga-flash2.h:101: return fpga_flash_result;
   1137 90 3A 26           4573 	mov	dptr,#_fpga_flash_result
   113A E0                 4574 	movx	a,@dptr
   113B F5 82              4575 	mov	dpl,a
   113D 22                 4576 	ret
                           4577 ;------------------------------------------------------------
                           4578 ;Allocation info for local variables in function 'abscode_identity'
                           4579 ;------------------------------------------------------------
                           4580 ;------------------------------------------------------------
                           4581 ;	../../include/ztex-descriptors.h:131: void abscode_identity()// _naked
                           4582 ;	-----------------------------------------
                           4583 ;	 function abscode_identity
                           4584 ;	-----------------------------------------
   113E                    4585 _abscode_identity:
                           4586 ;	../../include/ztex-descriptors.h:185: + 64
                           4587 	
                           4588 	    .area ABSCODE (ABS,CODE)
                           4589 	
   006C                    4590 	    .org 0x06c
   006C 28                 4591 	    .db 40
                           4592 	
   006D                    4593 	    .org _ZTEX_DESCRIPTOR_VERSION
   006D 01                 4594 	    .db 1
                           4595 	
   006E                    4596 	    .org _ZTEXID
   006E 5A 54 45 58        4597 	    .ascii "ZTEX"
                           4598 	
   0072                    4599 	    .org _PRODUCT_ID
   0072 0A                 4600 	    .db 10
   0073 13                 4601 	    .db 19
   0074 00                 4602 	    .db 0
   0075 00                 4603 	    .db 0
                           4604 	
   0076                    4605 	    .org _FW_VERSION
   0076 00                 4606 	    .db 0
                           4607 	
   0077                    4608 	    .org _INTERFACE_VERSION
   0077 01                 4609 	    .db 1
                           4610 	
   0078                    4611 	    .org _INTERFACE_CAPABILITIES
                           4612 ;	# 185 "../../include/ztex-descriptors.h"
   0078 47                 4613 	    .db 0 + 1 + 2 + 4 + 64
                           4614 ;	# 191 "../../include/ztex-descriptors.h"
   0079 00                 4615 	    .db 0
   007A 00                 4616 	    .db 0
   007B 00                 4617 	    .db 0
   007C 00                 4618 	    .db 0
   007D 00                 4619 	    .db 0
                           4620 	
   007E                    4621 	    .org _MODULE_RESERVED
   007E 00                 4622 	    .db 0
   007F 00                 4623 	    .db 0
   0080 00                 4624 	    .db 0
   0081 00                 4625 	    .db 0
   0082 00                 4626 	    .db 0
   0083 00                 4627 	    .db 0
   0084 00                 4628 	    .db 0
   0085 00                 4629 	    .db 0
   0086 00                 4630 	    .db 0
   0087 00                 4631 	    .db 0
   0088 00                 4632 	    .db 0
   0089 00                 4633 	    .db 0
                           4634 	
   008A                    4635 	    .org _SN_STRING
   008A 30 30 30 30 30 30  4636 	    .ascii "0000000000"
        30 30 30 30
                           4637 	
                           4638 	    .area CSEG (CODE)
                           4639 	    
   113E 22                 4640 	ret
                           4641 ;------------------------------------------------------------
                           4642 ;Allocation info for local variables in function 'resetToggleData'
                           4643 ;------------------------------------------------------------
                           4644 ;------------------------------------------------------------
                           4645 ;	../../include/ztex-isr.h:34: static void resetToggleData () {
                           4646 ;	-----------------------------------------
                           4647 ;	 function resetToggleData
                           4648 ;	-----------------------------------------
   113F                    4649 _resetToggleData:
                           4650 ;	../../include/ztex-isr.h:45: TOGCTL = 0;				// EP0 out
                           4651 ;	../../include/ztex-isr.h:46: TOGCTL = 0 | bmBIT5;
                           4652 ;	../../include/ztex-isr.h:47: TOGCTL = 0x10;			// EP0 in
                           4653 ;	../../include/ztex-isr.h:48: TOGCTL = 0x10 | bmBIT5;
   113F 90 E6 83           4654 	mov	dptr,#_TOGCTL
   1142 E4                 4655 	clr	a
   1143 F0                 4656 	movx	@dptr,a
   1144 74 20              4657 	mov	a,#0x20
   1146 F0                 4658 	movx	@dptr,a
   1147 74 10              4659 	mov	a,#0x10
   1149 F0                 4660 	movx	@dptr,a
   114A 74 30              4661 	mov	a,#0x30
   114C F0                 4662 	movx	@dptr,a
                           4663 ;	../../include/ztex-isr.h:49: #ifeq[EP1OUT_DIR][OUT]
                           4664 ;	../../include/ztex-isr.h:51: TOGCTL = 1 | bmBIT5;
                           4665 ;	../../include/ztex-isr.h:52: #endif    
                           4666 ;	../../include/ztex-isr.h:55: TOGCTL = 0x11 | bmBIT5;
   114D 90 E6 83           4667 	mov	dptr,#_TOGCTL
   1150 74 01              4668 	mov	a,#0x01
   1152 F0                 4669 	movx	@dptr,a
   1153 74 21              4670 	mov	a,#0x21
   1155 F0                 4671 	movx	@dptr,a
   1156 74 11              4672 	mov	a,#0x11
   1158 F0                 4673 	movx	@dptr,a
   1159 74 31              4674 	mov	a,#0x31
   115B F0                 4675 	movx	@dptr,a
   115C 22                 4676 	ret
                           4677 ;------------------------------------------------------------
                           4678 ;Allocation info for local variables in function 'sendStringDescriptor'
                           4679 ;------------------------------------------------------------
                           4680 ;hiAddr                    Allocated with name '_sendStringDescriptor_PARM_2'
                           4681 ;size                      Allocated with name '_sendStringDescriptor_PARM_3'
                           4682 ;loAddr                    Allocated to registers r2 
                           4683 ;i                         Allocated to registers r2 
                           4684 ;------------------------------------------------------------
                           4685 ;	../../include/ztex-isr.h:68: static void sendStringDescriptor (BYTE loAddr, BYTE hiAddr, BYTE size)
                           4686 ;	-----------------------------------------
                           4687 ;	 function sendStringDescriptor
                           4688 ;	-----------------------------------------
   115D                    4689 _sendStringDescriptor:
   115D AA 82              4690 	mov	r2,dpl
                           4691 ;	../../include/ztex-isr.h:71: if ( size > 31) size = 31;
   115F E5 17              4692 	mov	a,_sendStringDescriptor_PARM_3
   1161 24 E0              4693 	add	a,#0xff - 0x1F
   1163 50 03              4694 	jnc	00102$
   1165 75 17 1F           4695 	mov	_sendStringDescriptor_PARM_3,#0x1F
   1168                    4696 00102$:
                           4697 ;	../../include/ztex-isr.h:72: if (SETUPDAT[7] == 0 && SETUPDAT[6]<size ) size = SETUPDAT[6];
   1168 90 E6 BF           4698 	mov	dptr,#(_SETUPDAT + 0x0007)
   116B E0                 4699 	movx	a,@dptr
   116C 70 10              4700 	jnz	00104$
   116E 90 E6 BE           4701 	mov	dptr,#(_SETUPDAT + 0x0006)
   1171 E0                 4702 	movx	a,@dptr
   1172 FB                 4703 	mov	r3,a
   1173 C3                 4704 	clr	c
   1174 95 17              4705 	subb	a,_sendStringDescriptor_PARM_3
   1176 50 06              4706 	jnc	00104$
   1178 90 E6 BE           4707 	mov	dptr,#(_SETUPDAT + 0x0006)
   117B E0                 4708 	movx	a,@dptr
   117C F5 17              4709 	mov	_sendStringDescriptor_PARM_3,a
   117E                    4710 00104$:
                           4711 ;	../../include/ztex-isr.h:73: AUTOPTRSETUP = 7;
   117E 75 AF 07           4712 	mov	_AUTOPTRSETUP,#0x07
                           4713 ;	../../include/ztex-isr.h:74: AUTOPTRL1 = loAddr;
   1181 8A 9B              4714 	mov	_AUTOPTRL1,r2
                           4715 ;	../../include/ztex-isr.h:75: AUTOPTRH1 = hiAddr;
   1183 85 16 9A           4716 	mov	_AUTOPTRH1,_sendStringDescriptor_PARM_2
                           4717 ;	../../include/ztex-isr.h:76: AUTOPTRL2 = (BYTE)(((unsigned short)(&EP0BUF))+1);
   1186 75 9E 41           4718 	mov	_AUTOPTRL2,#0x41
                           4719 ;	../../include/ztex-isr.h:77: AUTOPTRH2 = (BYTE)((((unsigned short)(&EP0BUF))+1) >> 8);
   1189 75 9D E7           4720 	mov	_AUTOPTRH2,#0xE7
                           4721 ;	../../include/ztex-isr.h:78: XAUTODAT2 = 3;
   118C 90 E6 7C           4722 	mov	dptr,#_XAUTODAT2
   118F 74 03              4723 	mov	a,#0x03
   1191 F0                 4724 	movx	@dptr,a
                           4725 ;	../../include/ztex-isr.h:79: for (i=0; i<size; i++) {
   1192 7A 00              4726 	mov	r2,#0x00
   1194                    4727 00106$:
   1194 C3                 4728 	clr	c
   1195 EA                 4729 	mov	a,r2
   1196 95 17              4730 	subb	a,_sendStringDescriptor_PARM_3
   1198 50 11              4731 	jnc	00109$
                           4732 ;	../../include/ztex-isr.h:80: XAUTODAT2 = XAUTODAT1;
   119A 90 E6 7B           4733 	mov	dptr,#_XAUTODAT1
   119D E0                 4734 	movx	a,@dptr
   119E FB                 4735 	mov	r3,a
   119F 90 E6 7C           4736 	mov	dptr,#_XAUTODAT2
   11A2 F0                 4737 	movx	@dptr,a
                           4738 ;	../../include/ztex-isr.h:81: XAUTODAT2 = 0;
   11A3 90 E6 7C           4739 	mov	dptr,#_XAUTODAT2
   11A6 E4                 4740 	clr	a
   11A7 F0                 4741 	movx	@dptr,a
                           4742 ;	../../include/ztex-isr.h:79: for (i=0; i<size; i++) {
   11A8 0A                 4743 	inc	r2
   11A9 80 E9              4744 	sjmp	00106$
   11AB                    4745 00109$:
                           4746 ;	../../include/ztex-isr.h:83: i = (size+1) << 1;
   11AB E5 17              4747 	mov	a,_sendStringDescriptor_PARM_3
   11AD 04                 4748 	inc	a
                           4749 ;	../../include/ztex-isr.h:84: EP0BUF[0] = i;
   11AE 25 E0              4750 	add	a,acc
   11B0 FA                 4751 	mov	r2,a
   11B1 90 E7 40           4752 	mov	dptr,#_EP0BUF
   11B4 F0                 4753 	movx	@dptr,a
                           4754 ;	../../include/ztex-isr.h:85: EP0BUF[1] = 3;
   11B5 90 E7 41           4755 	mov	dptr,#(_EP0BUF + 0x0001)
   11B8 74 03              4756 	mov	a,#0x03
   11BA F0                 4757 	movx	@dptr,a
                           4758 ;	../../include/ztex-isr.h:86: EP0BCH = 0;
   11BB 90 E6 8A           4759 	mov	dptr,#_EP0BCH
   11BE E4                 4760 	clr	a
   11BF F0                 4761 	movx	@dptr,a
                           4762 ;	../../include/ztex-isr.h:87: EP0BCL = i;
   11C0 90 E6 8B           4763 	mov	dptr,#_EP0BCL
   11C3 EA                 4764 	mov	a,r2
   11C4 F0                 4765 	movx	@dptr,a
   11C5 22                 4766 	ret
                           4767 ;------------------------------------------------------------
                           4768 ;Allocation info for local variables in function 'ep0_payload_update'
                           4769 ;------------------------------------------------------------
                           4770 ;------------------------------------------------------------
                           4771 ;	../../include/ztex-isr.h:93: static void ep0_payload_update() {
                           4772 ;	-----------------------------------------
                           4773 ;	 function ep0_payload_update
                           4774 ;	-----------------------------------------
   11C6                    4775 _ep0_payload_update:
                           4776 ;	../../include/ztex-isr.h:94: ep0_payload_transfer = ( ep0_payload_remaining > 64 ) ? 64 : ep0_payload_remaining;
   11C6 90 3A 36           4777 	mov	dptr,#_ep0_payload_remaining
   11C9 E0                 4778 	movx	a,@dptr
   11CA FA                 4779 	mov	r2,a
   11CB A3                 4780 	inc	dptr
   11CC E0                 4781 	movx	a,@dptr
   11CD FB                 4782 	mov	r3,a
   11CE C3                 4783 	clr	c
   11CF 74 40              4784 	mov	a,#0x40
   11D1 9A                 4785 	subb	a,r2
   11D2 E4                 4786 	clr	a
   11D3 9B                 4787 	subb	a,r3
   11D4 50 06              4788 	jnc	00103$
   11D6 7C 40              4789 	mov	r4,#0x40
   11D8 7D 00              4790 	mov	r5,#0x00
   11DA 80 04              4791 	sjmp	00104$
   11DC                    4792 00103$:
   11DC 8A 04              4793 	mov	ar4,r2
   11DE 8B 05              4794 	mov	ar5,r3
   11E0                    4795 00104$:
   11E0 90 3A 38           4796 	mov	dptr,#_ep0_payload_transfer
   11E3 EC                 4797 	mov	a,r4
   11E4 F0                 4798 	movx	@dptr,a
                           4799 ;	../../include/ztex-isr.h:95: ep0_payload_remaining -= ep0_payload_transfer;
   11E5 7D 00              4800 	mov	r5,#0x00
   11E7 90 3A 36           4801 	mov	dptr,#_ep0_payload_remaining
   11EA EA                 4802 	mov	a,r2
   11EB C3                 4803 	clr	c
   11EC 9C                 4804 	subb	a,r4
   11ED F0                 4805 	movx	@dptr,a
   11EE EB                 4806 	mov	a,r3
   11EF 9D                 4807 	subb	a,r5
   11F0 A3                 4808 	inc	dptr
   11F1 F0                 4809 	movx	@dptr,a
   11F2 22                 4810 	ret
                           4811 ;------------------------------------------------------------
                           4812 ;Allocation info for local variables in function 'ep0_vendor_cmd_su'
                           4813 ;------------------------------------------------------------
                           4814 ;------------------------------------------------------------
                           4815 ;	../../include/ztex-isr.h:102: static void ep0_vendor_cmd_su() {
                           4816 ;	-----------------------------------------
                           4817 ;	 function ep0_vendor_cmd_su
                           4818 ;	-----------------------------------------
   11F3                    4819 _ep0_vendor_cmd_su:
                           4820 ;	../../include/ztex-isr.h:103: switch ( ep0_prev_setup_request ) {
   11F3 90 3A 39           4821 	mov	dptr,#_ep0_prev_setup_request
   11F6 E0                 4822 	movx	a,@dptr
   11F7 FA                 4823 	mov	r2,a
   11F8 BA 31 02           4824 	cjne	r2,#0x31,00123$
   11FB 80 77              4825 	sjmp	00107$
   11FD                    4826 00123$:
   11FD BA 32 02           4827 	cjne	r2,#0x32,00124$
   1200 80 75              4828 	sjmp	00108$
   1202                    4829 00124$:
   1202 BA 39 02           4830 	cjne	r2,#0x39,00125$
   1205 80 0A              4831 	sjmp	00101$
   1207                    4832 00125$:
   1207 BA 3C 02           4833 	cjne	r2,#0x3C,00126$
   120A 80 29              4834 	sjmp	00102$
   120C                    4835 00126$:
                           4836 ;	../../include/ztex-conf.h:123: case $0:			
   120C BA 42 74           4837 	cjne	r2,#0x42,00111$
   120F 80 2D              4838 	sjmp	00103$
   1211                    4839 00101$:
                           4840 ;	../../include/ztex-eeprom.h:236: eeprom_write_checksum = 0;
   1211 90 3A 04           4841 	mov	dptr,#_eeprom_write_checksum
                           4842 ;	../../include/ztex-eeprom.h:237: eeprom_write_bytes = 0;
   1214 E4                 4843 	clr	a
   1215 F0                 4844 	movx	@dptr,a
   1216 90 3A 02           4845 	mov	dptr,#_eeprom_write_bytes
   1219 F0                 4846 	movx	@dptr,a
   121A A3                 4847 	inc	dptr
   121B F0                 4848 	movx	@dptr,a
                           4849 ;	../../include/ztex-eeprom.h:238: eeprom_addr =  ( SETUPDAT[3] << 8) | SETUPDAT[2];	// Address
   121C 90 E6 BB           4850 	mov	dptr,#(_SETUPDAT + 0x0003)
   121F E0                 4851 	movx	a,@dptr
   1220 FB                 4852 	mov	r3,a
   1221 7A 00              4853 	mov	r2,#0x00
   1223 90 E6 BA           4854 	mov	dptr,#(_SETUPDAT + 0x0002)
   1226 E0                 4855 	movx	a,@dptr
   1227 FC                 4856 	mov	r4,a
   1228 7D 00              4857 	mov	r5,#0x00
   122A 90 3A 00           4858 	mov	dptr,#_eeprom_addr
   122D EC                 4859 	mov	a,r4
   122E 4A                 4860 	orl	a,r2
   122F F0                 4861 	movx	@dptr,a
   1230 ED                 4862 	mov	a,r5
   1231 4B                 4863 	orl	a,r3
   1232 A3                 4864 	inc	dptr
   1233 F0                 4865 	movx	@dptr,a
                           4866 ;	../../include/ztex-conf.h:125: break;
                           4867 ;	../../include/ztex-conf.h:123: case $0:			
   1234 22                 4868 	ret
   1235                    4869 00102$:
                           4870 ;	../../include/ztex-conf.h:125: break;
   1235 90 E6 BA           4871 	mov	dptr,#(_SETUPDAT + 0x0002)
   1238 E0                 4872 	movx	a,@dptr
   1239 90 3A 05           4873 	mov	dptr,#_mac_eeprom_addr
   123C F0                 4874 	movx	@dptr,a
                           4875 ;	../../include/ztex-conf.h:123: case $0:			
   123D 22                 4876 	ret
   123E                    4877 00103$:
                           4878 ;	../../include/ztex-flash2.h:698: ep0_write_mode = SETUPDAT[5];
   123E 90 E6 BD           4879 	mov	dptr,#(_SETUPDAT + 0x0005)
   1241 E0                 4880 	movx	a,@dptr
   1242 FA                 4881 	mov	r2,a
   1243 90 3A 1F           4882 	mov	dptr,#_ep0_write_mode
   1246 F0                 4883 	movx	@dptr,a
                           4884 ;	../../include/ztex-flash2.h:699: if ( (ep0_write_mode == 0) && flash_write_init((SETUPDAT[3] << 8) | SETUPDAT[2]) ) {
   1247 EA                 4885 	mov	a,r2
   1248 70 41              4886 	jnz	00113$
   124A 90 E6 BB           4887 	mov	dptr,#(_SETUPDAT + 0x0003)
   124D E0                 4888 	movx	a,@dptr
   124E FB                 4889 	mov	r3,a
   124F 7A 00              4890 	mov	r2,#0x00
   1251 90 E6 BA           4891 	mov	dptr,#(_SETUPDAT + 0x0002)
   1254 E0                 4892 	movx	a,@dptr
   1255 7D 00              4893 	mov	r5,#0x00
   1257 4A                 4894 	orl	a,r2
   1258 F5 82              4895 	mov	dpl,a
   125A ED                 4896 	mov	a,r5
   125B 4B                 4897 	orl	a,r3
   125C F5 83              4898 	mov	dph,a
   125E 12 0B 5F           4899 	lcall	_flash_write_init
   1261 E5 82              4900 	mov	a,dpl
   1263 60 26              4901 	jz	00113$
                           4902 ;	../../include/ztex-conf.h:137: EP0CS |= 0x01;	// set stall
   1265 90 E6 A0           4903 	mov	dptr,#_EP0CS
   1268 E0                 4904 	movx	a,@dptr
   1269 44 01              4905 	orl	a,#0x01
   126B F0                 4906 	movx	@dptr,a
                           4907 ;	../../include/ztex-conf.h:138: ep0_payload_remaining = 0;
   126C 90 3A 36           4908 	mov	dptr,#_ep0_payload_remaining
   126F E4                 4909 	clr	a
   1270 F0                 4910 	movx	@dptr,a
   1271 A3                 4911 	inc	dptr
   1272 F0                 4912 	movx	@dptr,a
                           4913 ;	../../include/ztex-conf.h:139: break;
                           4914 ;	../../include/ztex-conf.h:123: case $0:			
   1273 22                 4915 	ret
   1274                    4916 00107$:
                           4917 ;	../../include/ztex-conf.h:124: $1
                           4918 ;	../../include/ztex-conf.h:125: break;
                           4919 ;	../../include/ztex-conf.h:123: case $0:			
   1274 02 0D 33           4920 	ljmp	_reset_fpga
   1277                    4921 00108$:
                           4922 ;	../../include/ztex-fpga7.h:208: if ( fpga_conf_initialized != 123 )
   1277 90 3A 27           4923 	mov	dptr,#_fpga_conf_initialized
   127A E0                 4924 	movx	a,@dptr
   127B FA                 4925 	mov	r2,a
   127C BA 7B 01           4926 	cjne	r2,#0x7B,00130$
   127F 22                 4927 	ret
   1280                    4928 00130$:
                           4929 ;	../../include/ztex-fpga7.h:209: init_fpga_configuration();
                           4930 ;	../../include/ztex-conf.h:125: break;
                           4931 ;	../../include/ztex-isr.h:105: default:
   1280 02 0D 91           4932 	ljmp	_init_fpga_configuration
   1283                    4933 00111$:
                           4934 ;	../../include/ztex-isr.h:106: EP0CS |= 0x01;			// set stall, unknown request
   1283 90 E6 A0           4935 	mov	dptr,#_EP0CS
   1286 E0                 4936 	movx	a,@dptr
   1287 FA                 4937 	mov	r2,a
   1288 44 01              4938 	orl	a,#0x01
   128A F0                 4939 	movx	@dptr,a
                           4940 ;	../../include/ztex-isr.h:107: }
   128B                    4941 00113$:
   128B 22                 4942 	ret
                           4943 ;------------------------------------------------------------
                           4944 ;Allocation info for local variables in function 'SUDAV_ISR'
                           4945 ;------------------------------------------------------------
                           4946 ;a                         Allocated to registers r2 
                           4947 ;------------------------------------------------------------
                           4948 ;	../../include/ztex-isr.h:113: static void SUDAV_ISR () __interrupt
                           4949 ;	-----------------------------------------
                           4950 ;	 function SUDAV_ISR
                           4951 ;	-----------------------------------------
   128C                    4952 _SUDAV_ISR:
   128C C0 20              4953 	push	bits
   128E C0 E0              4954 	push	acc
   1290 C0 F0              4955 	push	b
   1292 C0 82              4956 	push	dpl
   1294 C0 83              4957 	push	dph
   1296 C0 02              4958 	push	(0+2)
   1298 C0 03              4959 	push	(0+3)
   129A C0 04              4960 	push	(0+4)
   129C C0 05              4961 	push	(0+5)
   129E C0 06              4962 	push	(0+6)
   12A0 C0 07              4963 	push	(0+7)
   12A2 C0 00              4964 	push	(0+0)
   12A4 C0 01              4965 	push	(0+1)
   12A6 C0 D0              4966 	push	psw
   12A8 75 D0 00           4967 	mov	psw,#0x00
                           4968 ;	../../include/ztex-isr.h:116: ep0_prev_setup_request = bRequest;
   12AB 90 E6 B9           4969 	mov	dptr,#_bRequest
   12AE E0                 4970 	movx	a,@dptr
   12AF FA                 4971 	mov	r2,a
   12B0 90 3A 39           4972 	mov	dptr,#_ep0_prev_setup_request
   12B3 F0                 4973 	movx	@dptr,a
                           4974 ;	../../include/ztex-isr.h:117: SUDPTRCTL = 1;
   12B4 90 E6 B5           4975 	mov	dptr,#_SUDPTRCTL
   12B7 74 01              4976 	mov	a,#0x01
   12B9 F0                 4977 	movx	@dptr,a
                           4978 ;	../../include/ztex-isr.h:120: switch ( bRequest ) {
   12BA 90 E6 B9           4979 	mov	dptr,#_bRequest
   12BD E0                 4980 	movx	a,@dptr
   12BE FA                 4981 	mov  r2,a
   12BF 24 F3              4982 	add	a,#0xff - 0x0C
   12C1 50 03              4983 	jnc	00238$
   12C3 02 16 42           4984 	ljmp	00160$
   12C6                    4985 00238$:
   12C6 EA                 4986 	mov	a,r2
   12C7 2A                 4987 	add	a,r2
   12C8 2A                 4988 	add	a,r2
   12C9 90 12 CD           4989 	mov	dptr,#00239$
   12CC 73                 4990 	jmp	@a+dptr
   12CD                    4991 00239$:
   12CD 02 12 F4           4992 	ljmp	00101$
   12D0 02 13 A8           4993 	ljmp	00112$
   12D3 02 16 42           4994 	ljmp	00160$
   12D6 02 14 25           4995 	ljmp	00122$
   12D9 02 16 42           4996 	ljmp	00160$
   12DC 02 16 42           4997 	ljmp	00160$
   12DF 02 14 BD           4998 	ljmp	00132$
   12E2 02 15 D8           4999 	ljmp	00152$
   12E5 02 15 DA           5000 	ljmp	00153$
   12E8 02 15 EB           5001 	ljmp	00154$
   12EB 02 15 F0           5002 	ljmp	00155$
   12EE 02 16 01           5003 	ljmp	00156$
   12F1 02 16 06           5004 	ljmp	00157$
                           5005 ;	../../include/ztex-isr.h:121: case 0x00:	// get status 
   12F4                    5006 00101$:
                           5007 ;	../../include/ztex-isr.h:122: switch(SETUPDAT[0]) {
   12F4 90 E6 B8           5008 	mov	dptr,#_SETUPDAT
   12F7 E0                 5009 	movx	a,@dptr
   12F8 FA                 5010 	mov	r2,a
   12F9 BA 80 02           5011 	cjne	r2,#0x80,00240$
   12FC 80 0D              5012 	sjmp	00102$
   12FE                    5013 00240$:
   12FE BA 81 02           5014 	cjne	r2,#0x81,00241$
   1301 80 1E              5015 	sjmp	00103$
   1303                    5016 00241$:
   1303 BA 82 02           5017 	cjne	r2,#0x82,00242$
   1306 80 2F              5018 	sjmp	00104$
   1308                    5019 00242$:
   1308 02 16 42           5020 	ljmp	00160$
                           5021 ;	../../include/ztex-isr.h:123: case 0x80:  		// self powered and remote 
   130B                    5022 00102$:
                           5023 ;	../../include/ztex-isr.h:124: EP0BUF[0] = 0;	// not self-powered, no remote wakeup
   130B 90 E7 40           5024 	mov	dptr,#_EP0BUF
                           5025 ;	../../include/ztex-isr.h:125: EP0BUF[1] = 0;
                           5026 ;	../../include/ztex-isr.h:126: EP0BCH = 0;
   130E E4                 5027 	clr	a
   130F F0                 5028 	movx	@dptr,a
   1310 90 E7 41           5029 	mov	dptr,#(_EP0BUF + 0x0001)
   1313 F0                 5030 	movx	@dptr,a
   1314 90 E6 8A           5031 	mov	dptr,#_EP0BCH
   1317 F0                 5032 	movx	@dptr,a
                           5033 ;	../../include/ztex-isr.h:127: EP0BCL = 2;
   1318 90 E6 8B           5034 	mov	dptr,#_EP0BCL
   131B 74 02              5035 	mov	a,#0x02
   131D F0                 5036 	movx	@dptr,a
                           5037 ;	../../include/ztex-isr.h:128: break;
   131E 02 16 42           5038 	ljmp	00160$
                           5039 ;	../../include/ztex-isr.h:129: case 0x81:		// interface (reserved)
   1321                    5040 00103$:
                           5041 ;	../../include/ztex-isr.h:130: EP0BUF[0] = 0; 	// always return zeros
   1321 90 E7 40           5042 	mov	dptr,#_EP0BUF
                           5043 ;	../../include/ztex-isr.h:131: EP0BUF[1] = 0;
                           5044 ;	../../include/ztex-isr.h:132: EP0BCH = 0;
   1324 E4                 5045 	clr	a
   1325 F0                 5046 	movx	@dptr,a
   1326 90 E7 41           5047 	mov	dptr,#(_EP0BUF + 0x0001)
   1329 F0                 5048 	movx	@dptr,a
   132A 90 E6 8A           5049 	mov	dptr,#_EP0BCH
   132D F0                 5050 	movx	@dptr,a
                           5051 ;	../../include/ztex-isr.h:133: EP0BCL = 2;
   132E 90 E6 8B           5052 	mov	dptr,#_EP0BCL
   1331 74 02              5053 	mov	a,#0x02
   1333 F0                 5054 	movx	@dptr,a
                           5055 ;	../../include/ztex-isr.h:134: break;
   1334 02 16 42           5056 	ljmp	00160$
                           5057 ;	../../include/ztex-isr.h:135: case 0x82:	
   1337                    5058 00104$:
                           5059 ;	../../include/ztex-isr.h:136: switch ( SETUPDAT[4] ) {
   1337 90 E6 BC           5060 	mov	dptr,#(_SETUPDAT + 0x0004)
   133A E0                 5061 	movx	a,@dptr
   133B FA                 5062 	mov	r2,a
   133C 60 0F              5063 	jz	00106$
   133E BA 01 02           5064 	cjne	r2,#0x01,00244$
   1341 80 19              5065 	sjmp	00107$
   1343                    5066 00244$:
   1343 BA 80 02           5067 	cjne	r2,#0x80,00245$
   1346 80 05              5068 	sjmp	00106$
   1348                    5069 00245$:
                           5070 ;	../../include/ztex-isr.h:138: case 0x80 :
   1348 BA 81 2F           5071 	cjne	r2,#0x81,00109$
   134B 80 1E              5072 	sjmp	00108$
   134D                    5073 00106$:
                           5074 ;	../../include/ztex-isr.h:139: EP0BUF[0] = EP0CS & bmBIT0;
   134D 90 E6 A0           5075 	mov	dptr,#_EP0CS
   1350 E0                 5076 	movx	a,@dptr
   1351 FA                 5077 	mov	r2,a
   1352 53 02 01           5078 	anl	ar2,#0x01
   1355 90 E7 40           5079 	mov	dptr,#_EP0BUF
   1358 EA                 5080 	mov	a,r2
   1359 F0                 5081 	movx	@dptr,a
                           5082 ;	../../include/ztex-isr.h:140: break;
                           5083 ;	../../include/ztex-isr.h:141: case 0x01 :
   135A 80 3A              5084 	sjmp	00110$
   135C                    5085 00107$:
                           5086 ;	../../include/ztex-isr.h:142: EP0BUF[0] = EP1OUTCS & bmBIT0;
   135C 90 E6 A1           5087 	mov	dptr,#_EP1OUTCS
   135F E0                 5088 	movx	a,@dptr
   1360 FA                 5089 	mov	r2,a
   1361 53 02 01           5090 	anl	ar2,#0x01
   1364 90 E7 40           5091 	mov	dptr,#_EP0BUF
   1367 EA                 5092 	mov	a,r2
   1368 F0                 5093 	movx	@dptr,a
                           5094 ;	../../include/ztex-isr.h:143: break;
                           5095 ;	../../include/ztex-isr.h:144: case 0x81 :
   1369 80 2B              5096 	sjmp	00110$
   136B                    5097 00108$:
                           5098 ;	../../include/ztex-isr.h:145: EP0BUF[0] = EP1INCS & bmBIT0;
   136B 90 E6 A2           5099 	mov	dptr,#_EP1INCS
   136E E0                 5100 	movx	a,@dptr
   136F FA                 5101 	mov	r2,a
   1370 53 02 01           5102 	anl	ar2,#0x01
   1373 90 E7 40           5103 	mov	dptr,#_EP0BUF
   1376 EA                 5104 	mov	a,r2
   1377 F0                 5105 	movx	@dptr,a
                           5106 ;	../../include/ztex-isr.h:146: break;
                           5107 ;	../../include/ztex-isr.h:147: default:
   1378 80 1C              5108 	sjmp	00110$
   137A                    5109 00109$:
                           5110 ;	../../include/ztex-isr.h:148: EP0BUF[0] = EPXCS[ ((SETUPDAT[4] >> 1)-1) & 3 ] & bmBIT0;
   137A 90 E6 BC           5111 	mov	dptr,#(_SETUPDAT + 0x0004)
   137D E0                 5112 	movx	a,@dptr
   137E C3                 5113 	clr	c
   137F 13                 5114 	rrc	a
   1380 14                 5115 	dec	a
   1381 54 03              5116 	anl	a,#0x03
   1383 24 A3              5117 	add	a,#_EPXCS
   1385 F5 82              5118 	mov	dpl,a
   1387 E4                 5119 	clr	a
   1388 34 E6              5120 	addc	a,#(_EPXCS >> 8)
   138A F5 83              5121 	mov	dph,a
   138C E0                 5122 	movx	a,@dptr
   138D FA                 5123 	mov	r2,a
   138E 53 02 01           5124 	anl	ar2,#0x01
   1391 90 E7 40           5125 	mov	dptr,#_EP0BUF
   1394 EA                 5126 	mov	a,r2
   1395 F0                 5127 	movx	@dptr,a
                           5128 ;	../../include/ztex-isr.h:150: }
   1396                    5129 00110$:
                           5130 ;	../../include/ztex-isr.h:151: EP0BUF[1] = 0;
   1396 90 E7 41           5131 	mov	dptr,#(_EP0BUF + 0x0001)
                           5132 ;	../../include/ztex-isr.h:152: EP0BCH = 0;
   1399 E4                 5133 	clr	a
   139A F0                 5134 	movx	@dptr,a
   139B 90 E6 8A           5135 	mov	dptr,#_EP0BCH
   139E F0                 5136 	movx	@dptr,a
                           5137 ;	../../include/ztex-isr.h:153: EP0BCL = 2;
   139F 90 E6 8B           5138 	mov	dptr,#_EP0BCL
   13A2 74 02              5139 	mov	a,#0x02
   13A4 F0                 5140 	movx	@dptr,a
                           5141 ;	../../include/ztex-isr.h:156: break;
   13A5 02 16 42           5142 	ljmp	00160$
                           5143 ;	../../include/ztex-isr.h:157: case 0x01:	// disable feature, e.g. remote wake, stall bit
   13A8                    5144 00112$:
                           5145 ;	../../include/ztex-isr.h:158: if ( SETUPDAT[0] == 2 && SETUPDAT[2] == 0 ) {
   13A8 90 E6 B8           5146 	mov	dptr,#_SETUPDAT
   13AB E0                 5147 	movx	a,@dptr
   13AC FA                 5148 	mov	r2,a
   13AD BA 02 02           5149 	cjne	r2,#0x02,00247$
   13B0 80 03              5150 	sjmp	00248$
   13B2                    5151 00247$:
   13B2 02 16 42           5152 	ljmp	00160$
   13B5                    5153 00248$:
   13B5 90 E6 BA           5154 	mov	dptr,#(_SETUPDAT + 0x0002)
   13B8 E0                 5155 	movx	a,@dptr
   13B9 60 03              5156 	jz	00249$
   13BB 02 16 42           5157 	ljmp	00160$
   13BE                    5158 00249$:
                           5159 ;	../../include/ztex-isr.h:159: switch ( SETUPDAT[4] ) {
   13BE 90 E6 BC           5160 	mov	dptr,#(_SETUPDAT + 0x0004)
   13C1 E0                 5161 	movx	a,@dptr
   13C2 FA                 5162 	mov	r2,a
   13C3 60 0F              5163 	jz	00114$
   13C5 BA 01 02           5164 	cjne	r2,#0x01,00251$
   13C8 80 15              5165 	sjmp	00115$
   13CA                    5166 00251$:
   13CA BA 80 02           5167 	cjne	r2,#0x80,00252$
   13CD 80 05              5168 	sjmp	00114$
   13CF                    5169 00252$:
                           5170 ;	../../include/ztex-isr.h:161: case 0x80 :
   13CF BA 81 23           5171 	cjne	r2,#0x81,00117$
   13D2 80 16              5172 	sjmp	00116$
   13D4                    5173 00114$:
                           5174 ;	../../include/ztex-isr.h:162: EP0CS &= ~bmBIT0;
   13D4 90 E6 A0           5175 	mov	dptr,#_EP0CS
   13D7 E0                 5176 	movx	a,@dptr
   13D8 FA                 5177 	mov	r2,a
   13D9 54 FE              5178 	anl	a,#0xFE
   13DB F0                 5179 	movx	@dptr,a
                           5180 ;	../../include/ztex-isr.h:163: break;
   13DC 02 16 42           5181 	ljmp	00160$
                           5182 ;	../../include/ztex-isr.h:164: case 0x01 :
   13DF                    5183 00115$:
                           5184 ;	../../include/ztex-isr.h:165: EP1OUTCS &= ~bmBIT0;
   13DF 90 E6 A1           5185 	mov	dptr,#_EP1OUTCS
   13E2 E0                 5186 	movx	a,@dptr
   13E3 FA                 5187 	mov	r2,a
   13E4 54 FE              5188 	anl	a,#0xFE
   13E6 F0                 5189 	movx	@dptr,a
                           5190 ;	../../include/ztex-isr.h:166: break;
   13E7 02 16 42           5191 	ljmp	00160$
                           5192 ;	../../include/ztex-isr.h:167: case 0x81 :
   13EA                    5193 00116$:
                           5194 ;	../../include/ztex-isr.h:168: EP1INCS &= ~bmBIT0;
   13EA 90 E6 A2           5195 	mov	dptr,#_EP1INCS
   13ED E0                 5196 	movx	a,@dptr
   13EE FA                 5197 	mov	r2,a
   13EF 54 FE              5198 	anl	a,#0xFE
   13F1 F0                 5199 	movx	@dptr,a
                           5200 ;	../../include/ztex-isr.h:169: break;
   13F2 02 16 42           5201 	ljmp	00160$
                           5202 ;	../../include/ztex-isr.h:170: default:
   13F5                    5203 00117$:
                           5204 ;	../../include/ztex-isr.h:171: EPXCS[ ((SETUPDAT[4] >> 1)-1) & 3 ] &= ~bmBIT0;
   13F5 90 E6 BC           5205 	mov	dptr,#(_SETUPDAT + 0x0004)
   13F8 E0                 5206 	movx	a,@dptr
   13F9 C3                 5207 	clr	c
   13FA 13                 5208 	rrc	a
   13FB 14                 5209 	dec	a
   13FC 54 03              5210 	anl	a,#0x03
   13FE 24 A3              5211 	add	a,#_EPXCS
   1400 FA                 5212 	mov	r2,a
   1401 E4                 5213 	clr	a
   1402 34 E6              5214 	addc	a,#(_EPXCS >> 8)
   1404 FB                 5215 	mov	r3,a
   1405 90 E6 BC           5216 	mov	dptr,#(_SETUPDAT + 0x0004)
   1408 E0                 5217 	movx	a,@dptr
   1409 C3                 5218 	clr	c
   140A 13                 5219 	rrc	a
   140B 14                 5220 	dec	a
   140C 54 03              5221 	anl	a,#0x03
   140E 24 A3              5222 	add	a,#_EPXCS
   1410 F5 82              5223 	mov	dpl,a
   1412 E4                 5224 	clr	a
   1413 34 E6              5225 	addc	a,#(_EPXCS >> 8)
   1415 F5 83              5226 	mov	dph,a
   1417 E0                 5227 	movx	a,@dptr
   1418 FC                 5228 	mov	r4,a
   1419 53 04 FE           5229 	anl	ar4,#0xFE
   141C 8A 82              5230 	mov	dpl,r2
   141E 8B 83              5231 	mov	dph,r3
   1420 EC                 5232 	mov	a,r4
   1421 F0                 5233 	movx	@dptr,a
                           5234 ;	../../include/ztex-isr.h:175: break;
   1422 02 16 42           5235 	ljmp	00160$
                           5236 ;	../../include/ztex-isr.h:176: case 0x03:      // enable feature, e.g. remote wake, test mode, stall bit
   1425                    5237 00122$:
                           5238 ;	../../include/ztex-isr.h:177: if ( SETUPDAT[0] == 2 && SETUPDAT[2] == 0 ) {
   1425 90 E6 B8           5239 	mov	dptr,#_SETUPDAT
   1428 E0                 5240 	movx	a,@dptr
   1429 FA                 5241 	mov	r2,a
   142A BA 02 02           5242 	cjne	r2,#0x02,00254$
   142D 80 03              5243 	sjmp	00255$
   142F                    5244 00254$:
   142F 02 16 42           5245 	ljmp	00160$
   1432                    5246 00255$:
   1432 90 E6 BA           5247 	mov	dptr,#(_SETUPDAT + 0x0002)
   1435 E0                 5248 	movx	a,@dptr
   1436 60 03              5249 	jz	00256$
   1438 02 16 42           5250 	ljmp	00160$
   143B                    5251 00256$:
                           5252 ;	../../include/ztex-isr.h:178: switch ( SETUPDAT[4] ) {
   143B 90 E6 BC           5253 	mov	dptr,#(_SETUPDAT + 0x0004)
   143E E0                 5254 	movx	a,@dptr
   143F FA                 5255 	mov	r2,a
   1440 60 0F              5256 	jz	00124$
   1442 BA 01 02           5257 	cjne	r2,#0x01,00258$
   1445 80 14              5258 	sjmp	00125$
   1447                    5259 00258$:
   1447 BA 80 02           5260 	cjne	r2,#0x80,00259$
   144A 80 05              5261 	sjmp	00124$
   144C                    5262 00259$:
                           5263 ;	../../include/ztex-isr.h:180: case 0x80 :
   144C BA 81 20           5264 	cjne	r2,#0x81,00127$
   144F 80 14              5265 	sjmp	00126$
   1451                    5266 00124$:
                           5267 ;	../../include/ztex-isr.h:181: EP0CS |= bmBIT0;
   1451 90 E6 A0           5268 	mov	dptr,#_EP0CS
   1454 E0                 5269 	movx	a,@dptr
   1455 FA                 5270 	mov	r2,a
   1456 44 01              5271 	orl	a,#0x01
   1458 F0                 5272 	movx	@dptr,a
                           5273 ;	../../include/ztex-isr.h:182: break;
                           5274 ;	../../include/ztex-isr.h:183: case 0x01 :
   1459 80 41              5275 	sjmp	00128$
   145B                    5276 00125$:
                           5277 ;	../../include/ztex-isr.h:184: EP1OUTCS |= bmBIT0;
   145B 90 E6 A1           5278 	mov	dptr,#_EP1OUTCS
   145E E0                 5279 	movx	a,@dptr
   145F FA                 5280 	mov	r2,a
   1460 44 01              5281 	orl	a,#0x01
   1462 F0                 5282 	movx	@dptr,a
                           5283 ;	../../include/ztex-isr.h:185: break;
                           5284 ;	../../include/ztex-isr.h:186: case 0x81 :
   1463 80 37              5285 	sjmp	00128$
   1465                    5286 00126$:
                           5287 ;	../../include/ztex-isr.h:187: EP1INCS |= bmBIT0;
   1465 90 E6 A2           5288 	mov	dptr,#_EP1INCS
   1468 E0                 5289 	movx	a,@dptr
   1469 FA                 5290 	mov	r2,a
   146A 44 01              5291 	orl	a,#0x01
   146C F0                 5292 	movx	@dptr,a
                           5293 ;	../../include/ztex-isr.h:188: break;
                           5294 ;	../../include/ztex-isr.h:189: default:
   146D 80 2D              5295 	sjmp	00128$
   146F                    5296 00127$:
                           5297 ;	../../include/ztex-isr.h:190: EPXCS[ ((SETUPDAT[4] >> 1)-1) & 3 ] |= ~bmBIT0;
   146F 90 E6 BC           5298 	mov	dptr,#(_SETUPDAT + 0x0004)
   1472 E0                 5299 	movx	a,@dptr
   1473 C3                 5300 	clr	c
   1474 13                 5301 	rrc	a
   1475 14                 5302 	dec	a
   1476 54 03              5303 	anl	a,#0x03
   1478 24 A3              5304 	add	a,#_EPXCS
   147A FA                 5305 	mov	r2,a
   147B E4                 5306 	clr	a
   147C 34 E6              5307 	addc	a,#(_EPXCS >> 8)
   147E FB                 5308 	mov	r3,a
   147F 90 E6 BC           5309 	mov	dptr,#(_SETUPDAT + 0x0004)
   1482 E0                 5310 	movx	a,@dptr
   1483 C3                 5311 	clr	c
   1484 13                 5312 	rrc	a
   1485 14                 5313 	dec	a
   1486 54 03              5314 	anl	a,#0x03
   1488 24 A3              5315 	add	a,#_EPXCS
   148A F5 82              5316 	mov	dpl,a
   148C E4                 5317 	clr	a
   148D 34 E6              5318 	addc	a,#(_EPXCS >> 8)
   148F F5 83              5319 	mov	dph,a
   1491 E0                 5320 	movx	a,@dptr
   1492 FC                 5321 	mov	r4,a
   1493 43 04 FE           5322 	orl	ar4,#0xFE
   1496 8A 82              5323 	mov	dpl,r2
   1498 8B 83              5324 	mov	dph,r3
   149A EC                 5325 	mov	a,r4
   149B F0                 5326 	movx	@dptr,a
                           5327 ;	../../include/ztex-isr.h:192: }
   149C                    5328 00128$:
                           5329 ;	../../include/ztex-isr.h:193: a = ( (SETUPDAT[4] & 0x80) >> 3 ) | (SETUPDAT[4] & 0x0f);
   149C 90 E6 BC           5330 	mov	dptr,#(_SETUPDAT + 0x0004)
   149F E0                 5331 	movx	a,@dptr
   14A0 54 80              5332 	anl	a,#0x80
   14A2 C4                 5333 	swap	a
   14A3 23                 5334 	rl	a
   14A4 54 1F              5335 	anl	a,#0x1f
   14A6 FA                 5336 	mov	r2,a
   14A7 90 E6 BC           5337 	mov	dptr,#(_SETUPDAT + 0x0004)
   14AA E0                 5338 	movx	a,@dptr
   14AB FB                 5339 	mov	r3,a
   14AC 74 0F              5340 	mov	a,#0x0F
   14AE 5B                 5341 	anl	a,r3
   14AF 42 02              5342 	orl	ar2,a
                           5343 ;	../../include/ztex-isr.h:194: TOGCTL = a;
                           5344 ;	../../include/ztex-isr.h:195: TOGCTL = a | bmBIT5;
   14B1 90 E6 83           5345 	mov	dptr,#_TOGCTL
   14B4 EA                 5346 	mov	a,r2
   14B5 F0                 5347 	movx	@dptr,a
   14B6 74 20              5348 	mov	a,#0x20
   14B8 4A                 5349 	orl	a,r2
   14B9 F0                 5350 	movx	@dptr,a
                           5351 ;	../../include/ztex-isr.h:197: break;
   14BA 02 16 42           5352 	ljmp	00160$
                           5353 ;	../../include/ztex-isr.h:198: case 0x06:			// get descriptor
   14BD                    5354 00132$:
                           5355 ;	../../include/ztex-isr.h:199: switch(SETUPDAT[3]) {
   14BD 90 E6 BB           5356 	mov	dptr,#(_SETUPDAT + 0x0003)
   14C0 E0                 5357 	movx	a,@dptr
   14C1 FA                 5358 	mov	r2,a
   14C2 BA 01 02           5359 	cjne	r2,#0x01,00261$
   14C5 80 19              5360 	sjmp	00133$
   14C7                    5361 00261$:
   14C7 BA 02 02           5362 	cjne	r2,#0x02,00262$
   14CA 80 26              5363 	sjmp	00134$
   14CC                    5364 00262$:
   14CC BA 03 02           5365 	cjne	r2,#0x03,00263$
   14CF 80 4D              5366 	sjmp	00138$
   14D1                    5367 00263$:
   14D1 BA 06 03           5368 	cjne	r2,#0x06,00264$
   14D4 02 15 91           5369 	ljmp	00145$
   14D7                    5370 00264$:
   14D7 BA 07 03           5371 	cjne	r2,#0x07,00265$
   14DA 02 15 A3           5372 	ljmp	00146$
   14DD                    5373 00265$:
   14DD 02 15 CE           5374 	ljmp	00150$
                           5375 ;	../../include/ztex-isr.h:200: case 0x01:		// device
   14E0                    5376 00133$:
                           5377 ;	../../include/ztex-isr.h:201: SUDPTRH = MSB(&DeviceDescriptor);
   14E0 7A 8A              5378 	mov	r2,#_DeviceDescriptor
   14E2 7B 1E              5379 	mov	r3,#(_DeviceDescriptor >> 8)
   14E4 90 E6 B3           5380 	mov	dptr,#_SUDPTRH
   14E7 EB                 5381 	mov	a,r3
   14E8 F0                 5382 	movx	@dptr,a
                           5383 ;	../../include/ztex-isr.h:202: SUDPTRL = LSB(&DeviceDescriptor);
   14E9 90 E6 B4           5384 	mov	dptr,#_SUDPTRL
   14EC 74 8A              5385 	mov	a,#_DeviceDescriptor
   14EE F0                 5386 	movx	@dptr,a
                           5387 ;	../../include/ztex-isr.h:203: break;
   14EF 02 16 42           5388 	ljmp	00160$
                           5389 ;	../../include/ztex-isr.h:204: case 0x02: 		// configuration
   14F2                    5390 00134$:
                           5391 ;	../../include/ztex-isr.h:205: if (USBCS & bmBIT7) {
   14F2 90 E6 80           5392 	mov	dptr,#_USBCS
   14F5 E0                 5393 	movx	a,@dptr
   14F6 FA                 5394 	mov	r2,a
   14F7 30 E7 12           5395 	jnb	acc.7,00136$
                           5396 ;	../../include/ztex-isr.h:206: SUDPTRH = MSB(&HighSpeedConfigDescriptor);
   14FA 7A A6              5397 	mov	r2,#_HighSpeedConfigDescriptor
   14FC 7B 1E              5398 	mov	r3,#(_HighSpeedConfigDescriptor >> 8)
   14FE 90 E6 B3           5399 	mov	dptr,#_SUDPTRH
   1501 EB                 5400 	mov	a,r3
   1502 F0                 5401 	movx	@dptr,a
                           5402 ;	../../include/ztex-isr.h:207: SUDPTRL = LSB(&HighSpeedConfigDescriptor);
   1503 90 E6 B4           5403 	mov	dptr,#_SUDPTRL
   1506 74 A6              5404 	mov	a,#_HighSpeedConfigDescriptor
   1508 F0                 5405 	movx	@dptr,a
   1509 02 16 42           5406 	ljmp	00160$
   150C                    5407 00136$:
                           5408 ;	../../include/ztex-isr.h:210: SUDPTRH = MSB(&FullSpeedConfigDescriptor);
   150C 7A C8              5409 	mov	r2,#_FullSpeedConfigDescriptor
   150E 7B 1E              5410 	mov	r3,#(_FullSpeedConfigDescriptor >> 8)
   1510 90 E6 B3           5411 	mov	dptr,#_SUDPTRH
   1513 EB                 5412 	mov	a,r3
   1514 F0                 5413 	movx	@dptr,a
                           5414 ;	../../include/ztex-isr.h:211: SUDPTRL = LSB(&FullSpeedConfigDescriptor);
   1515 90 E6 B4           5415 	mov	dptr,#_SUDPTRL
   1518 74 C8              5416 	mov	a,#_FullSpeedConfigDescriptor
   151A F0                 5417 	movx	@dptr,a
                           5418 ;	../../include/ztex-isr.h:213: break; 
   151B 02 16 42           5419 	ljmp	00160$
                           5420 ;	../../include/ztex-isr.h:214: case 0x03:		// strings
   151E                    5421 00138$:
                           5422 ;	../../include/ztex-isr.h:215: switch (SETUPDAT[2]) {
   151E 90 E6 BA           5423 	mov	dptr,#(_SETUPDAT + 0x0002)
   1521 E0                 5424 	movx	a,@dptr
   1522 FA                 5425 	mov	r2,a
   1523 BA 01 02           5426 	cjne	r2,#0x01,00267$
   1526 80 0F              5427 	sjmp	00139$
   1528                    5428 00267$:
   1528 BA 02 02           5429 	cjne	r2,#0x02,00268$
   152B 80 1C              5430 	sjmp	00140$
   152D                    5431 00268$:
   152D BA 03 02           5432 	cjne	r2,#0x03,00269$
   1530 80 29              5433 	sjmp	00141$
   1532                    5434 00269$:
                           5435 ;	../../include/ztex-isr.h:216: case 1:
   1532 BA 04 4A           5436 	cjne	r2,#0x04,00143$
   1535 80 36              5437 	sjmp	00142$
   1537                    5438 00139$:
                           5439 ;	../../include/ztex-isr.h:217: SEND_STRING_DESCRIPTOR(manufacturerString);
   1537 75 82 5D           5440 	mov	dpl,#_manufacturerString
   153A 7A 5D              5441 	mov	r2,#_manufacturerString
   153C 7B 1E              5442 	mov	r3,#(_manufacturerString >> 8)
   153E 8B 16              5443 	mov	_sendStringDescriptor_PARM_2,r3
   1540 75 17 05           5444 	mov	_sendStringDescriptor_PARM_3,#0x05
   1543 12 11 5D           5445 	lcall	_sendStringDescriptor
                           5446 ;	../../include/ztex-isr.h:218: break;
   1546 02 16 42           5447 	ljmp	00160$
                           5448 ;	../../include/ztex-isr.h:219: case 2:
   1549                    5449 00140$:
                           5450 ;	../../include/ztex-isr.h:220: SEND_STRING_DESCRIPTOR(productString);
   1549 75 82 62           5451 	mov	dpl,#_productString
   154C 7A 62              5452 	mov	r2,#_productString
   154E 7B 1E              5453 	mov	r3,#(_productString >> 8)
   1550 8B 16              5454 	mov	_sendStringDescriptor_PARM_2,r3
   1552 75 17 20           5455 	mov	_sendStringDescriptor_PARM_3,#0x20
   1555 12 11 5D           5456 	lcall	_sendStringDescriptor
                           5457 ;	../../include/ztex-isr.h:221: break;
   1558 02 16 42           5458 	ljmp	00160$
                           5459 ;	../../include/ztex-isr.h:222: case 3:
   155B                    5460 00141$:
                           5461 ;	../../include/ztex-isr.h:223: SEND_STRING_DESCRIPTOR(SN_STRING);
   155B 75 82 8A           5462 	mov	dpl,#_SN_STRING
   155E 7A 8A              5463 	mov	r2,#_SN_STRING
   1560 7B 00              5464 	mov	r3,#(_SN_STRING >> 8)
   1562 8B 16              5465 	mov	_sendStringDescriptor_PARM_2,r3
   1564 75 17 0A           5466 	mov	_sendStringDescriptor_PARM_3,#0x0A
   1567 12 11 5D           5467 	lcall	_sendStringDescriptor
                           5468 ;	../../include/ztex-isr.h:224: break;
   156A 02 16 42           5469 	ljmp	00160$
                           5470 ;	../../include/ztex-isr.h:225: case 4:
   156D                    5471 00142$:
                           5472 ;	../../include/ztex-isr.h:226: SEND_STRING_DESCRIPTOR(configurationString);
   156D 75 82 82           5473 	mov	dpl,#_configurationString
   1570 7A 82              5474 	mov	r2,#_configurationString
   1572 7B 1E              5475 	mov	r3,#(_configurationString >> 8)
   1574 8B 16              5476 	mov	_sendStringDescriptor_PARM_2,r3
   1576 75 17 08           5477 	mov	_sendStringDescriptor_PARM_3,#0x08
   1579 12 11 5D           5478 	lcall	_sendStringDescriptor
                           5479 ;	../../include/ztex-isr.h:227: break; 
   157C 02 16 42           5480 	ljmp	00160$
                           5481 ;	../../include/ztex-isr.h:228: default:
   157F                    5482 00143$:
                           5483 ;	../../include/ztex-isr.h:229: SUDPTRH = MSB(&EmptyStringDescriptor);
   157F 7A EA              5484 	mov	r2,#_EmptyStringDescriptor
   1581 7B 1E              5485 	mov	r3,#(_EmptyStringDescriptor >> 8)
   1583 90 E6 B3           5486 	mov	dptr,#_SUDPTRH
   1586 EB                 5487 	mov	a,r3
   1587 F0                 5488 	movx	@dptr,a
                           5489 ;	../../include/ztex-isr.h:230: SUDPTRL = LSB(&EmptyStringDescriptor);
   1588 90 E6 B4           5490 	mov	dptr,#_SUDPTRL
   158B 74 EA              5491 	mov	a,#_EmptyStringDescriptor
   158D F0                 5492 	movx	@dptr,a
                           5493 ;	../../include/ztex-isr.h:233: break;
   158E 02 16 42           5494 	ljmp	00160$
                           5495 ;	../../include/ztex-isr.h:234: case 0x06:		// device qualifier
   1591                    5496 00145$:
                           5497 ;	../../include/ztex-isr.h:235: SUDPTRH = MSB(&DeviceQualifierDescriptor);
   1591 7A 9C              5498 	mov	r2,#_DeviceQualifierDescriptor
   1593 7B 1E              5499 	mov	r3,#(_DeviceQualifierDescriptor >> 8)
   1595 90 E6 B3           5500 	mov	dptr,#_SUDPTRH
   1598 EB                 5501 	mov	a,r3
   1599 F0                 5502 	movx	@dptr,a
                           5503 ;	../../include/ztex-isr.h:236: SUDPTRL = LSB(&DeviceQualifierDescriptor);
   159A 90 E6 B4           5504 	mov	dptr,#_SUDPTRL
   159D 74 9C              5505 	mov	a,#_DeviceQualifierDescriptor
   159F F0                 5506 	movx	@dptr,a
                           5507 ;	../../include/ztex-isr.h:237: break;
   15A0 02 16 42           5508 	ljmp	00160$
                           5509 ;	../../include/ztex-isr.h:238: case 0x07: 		// other speed configuration
   15A3                    5510 00146$:
                           5511 ;	../../include/ztex-isr.h:239: if (USBCS & bmBIT7) {
   15A3 90 E6 80           5512 	mov	dptr,#_USBCS
   15A6 E0                 5513 	movx	a,@dptr
   15A7 FA                 5514 	mov	r2,a
   15A8 30 E7 12           5515 	jnb	acc.7,00148$
                           5516 ;	../../include/ztex-isr.h:240: SUDPTRH = MSB(&FullSpeedConfigDescriptor);
   15AB 7A C8              5517 	mov	r2,#_FullSpeedConfigDescriptor
   15AD 7B 1E              5518 	mov	r3,#(_FullSpeedConfigDescriptor >> 8)
   15AF 90 E6 B3           5519 	mov	dptr,#_SUDPTRH
   15B2 EB                 5520 	mov	a,r3
   15B3 F0                 5521 	movx	@dptr,a
                           5522 ;	../../include/ztex-isr.h:241: SUDPTRL = LSB(&FullSpeedConfigDescriptor);
   15B4 90 E6 B4           5523 	mov	dptr,#_SUDPTRL
   15B7 74 C8              5524 	mov	a,#_FullSpeedConfigDescriptor
   15B9 F0                 5525 	movx	@dptr,a
   15BA 02 16 42           5526 	ljmp	00160$
   15BD                    5527 00148$:
                           5528 ;	../../include/ztex-isr.h:244: SUDPTRH = MSB(&HighSpeedConfigDescriptor);
   15BD 7A A6              5529 	mov	r2,#_HighSpeedConfigDescriptor
   15BF 7B 1E              5530 	mov	r3,#(_HighSpeedConfigDescriptor >> 8)
   15C1 90 E6 B3           5531 	mov	dptr,#_SUDPTRH
   15C4 EB                 5532 	mov	a,r3
   15C5 F0                 5533 	movx	@dptr,a
                           5534 ;	../../include/ztex-isr.h:245: SUDPTRL = LSB(&HighSpeedConfigDescriptor);
   15C6 90 E6 B4           5535 	mov	dptr,#_SUDPTRL
   15C9 74 A6              5536 	mov	a,#_HighSpeedConfigDescriptor
   15CB F0                 5537 	movx	@dptr,a
                           5538 ;	../../include/ztex-isr.h:247: break; 
                           5539 ;	../../include/ztex-isr.h:248: default:
   15CC 80 74              5540 	sjmp	00160$
   15CE                    5541 00150$:
                           5542 ;	../../include/ztex-isr.h:249: EP0CS |= 0x01;	// set stall, unknown descriptor
   15CE 90 E6 A0           5543 	mov	dptr,#_EP0CS
   15D1 E0                 5544 	movx	a,@dptr
   15D2 FA                 5545 	mov	r2,a
   15D3 44 01              5546 	orl	a,#0x01
   15D5 F0                 5547 	movx	@dptr,a
                           5548 ;	../../include/ztex-isr.h:251: break;
                           5549 ;	../../include/ztex-isr.h:252: case 0x07:			// set descriptor
   15D6 80 6A              5550 	sjmp	00160$
   15D8                    5551 00152$:
                           5552 ;	../../include/ztex-isr.h:253: break;			
                           5553 ;	../../include/ztex-isr.h:254: case 0x08:			// get configuration
   15D8 80 68              5554 	sjmp	00160$
   15DA                    5555 00153$:
                           5556 ;	../../include/ztex-isr.h:255: EP0BUF[0] = 0;		// only one configuration
   15DA 90 E7 40           5557 	mov	dptr,#_EP0BUF
                           5558 ;	../../include/ztex-isr.h:256: EP0BCH = 0;
   15DD E4                 5559 	clr	a
   15DE F0                 5560 	movx	@dptr,a
   15DF 90 E6 8A           5561 	mov	dptr,#_EP0BCH
   15E2 F0                 5562 	movx	@dptr,a
                           5563 ;	../../include/ztex-isr.h:257: EP0BCL = 1;
   15E3 90 E6 8B           5564 	mov	dptr,#_EP0BCL
   15E6 74 01              5565 	mov	a,#0x01
   15E8 F0                 5566 	movx	@dptr,a
                           5567 ;	../../include/ztex-isr.h:258: break;
                           5568 ;	../../include/ztex-isr.h:259: case 0x09:			// set configuration
   15E9 80 57              5569 	sjmp	00160$
   15EB                    5570 00154$:
                           5571 ;	../../include/ztex-isr.h:260: resetToggleData();
   15EB 12 11 3F           5572 	lcall	_resetToggleData
                           5573 ;	../../include/ztex-isr.h:261: break;			// do nothing since we have only one configuration
                           5574 ;	../../include/ztex-isr.h:262: case 0x0a:			// get alternate setting for an interface
   15EE 80 52              5575 	sjmp	00160$
   15F0                    5576 00155$:
                           5577 ;	../../include/ztex-isr.h:263: EP0BUF[0] = 0;		// only one alternate setting
   15F0 90 E7 40           5578 	mov	dptr,#_EP0BUF
                           5579 ;	../../include/ztex-isr.h:264: EP0BCH = 0;
   15F3 E4                 5580 	clr	a
   15F4 F0                 5581 	movx	@dptr,a
   15F5 90 E6 8A           5582 	mov	dptr,#_EP0BCH
   15F8 F0                 5583 	movx	@dptr,a
                           5584 ;	../../include/ztex-isr.h:265: EP0BCL = 1;
   15F9 90 E6 8B           5585 	mov	dptr,#_EP0BCL
   15FC 74 01              5586 	mov	a,#0x01
   15FE F0                 5587 	movx	@dptr,a
                           5588 ;	../../include/ztex-isr.h:266: break;
                           5589 ;	../../include/ztex-isr.h:267: case 0x0b:			// set alternate setting for an interface
   15FF 80 41              5590 	sjmp	00160$
   1601                    5591 00156$:
                           5592 ;	../../include/ztex-isr.h:268: resetToggleData();
   1601 12 11 3F           5593 	lcall	_resetToggleData
                           5594 ;	../../include/ztex-isr.h:269: break;			// do nothing since we have only on alternate setting
                           5595 ;	../../include/ztex-isr.h:270: case 0x0c:			// sync frame
   1604 80 3C              5596 	sjmp	00160$
   1606                    5597 00157$:
                           5598 ;	../../include/ztex-isr.h:271: if ( SETUPDAT[0] == 0x82 ) {
   1606 90 E6 B8           5599 	mov	dptr,#_SETUPDAT
   1609 E0                 5600 	movx	a,@dptr
   160A FA                 5601 	mov	r2,a
   160B BA 82 34           5602 	cjne	r2,#0x82,00160$
                           5603 ;	../../include/ztex-isr.h:272: ISOFRAME_COUNTER[ ((SETUPDAT[4] >> 1)-1) & 3 ] = 0;
   160E 90 E6 BC           5604 	mov	dptr,#(_SETUPDAT + 0x0004)
   1611 E0                 5605 	movx	a,@dptr
   1612 C3                 5606 	clr	c
   1613 13                 5607 	rrc	a
   1614 14                 5608 	dec	a
   1615 54 03              5609 	anl	a,#0x03
   1617 25 E0              5610 	add	a,acc
   1619 24 3B              5611 	add	a,#_ISOFRAME_COUNTER
   161B F5 82              5612 	mov	dpl,a
   161D E4                 5613 	clr	a
   161E 34 3A              5614 	addc	a,#(_ISOFRAME_COUNTER >> 8)
   1620 F5 83              5615 	mov	dph,a
   1622 E4                 5616 	clr	a
   1623 F0                 5617 	movx	@dptr,a
   1624 A3                 5618 	inc	dptr
   1625 F0                 5619 	movx	@dptr,a
                           5620 ;	../../include/ztex-isr.h:273: EP0BUF[0] = USBFRAMEL;	// use current frame as sync frame, i hope that works
   1626 90 E6 85           5621 	mov	dptr,#_USBFRAMEL
   1629 E0                 5622 	movx	a,@dptr
   162A 90 E7 40           5623 	mov	dptr,#_EP0BUF
   162D F0                 5624 	movx	@dptr,a
                           5625 ;	../../include/ztex-isr.h:274: EP0BUF[1] = USBFRAMEH;	
   162E 90 E6 84           5626 	mov	dptr,#_USBFRAMEH
   1631 E0                 5627 	movx	a,@dptr
   1632 FA                 5628 	mov	r2,a
   1633 90 E7 41           5629 	mov	dptr,#(_EP0BUF + 0x0001)
   1636 F0                 5630 	movx	@dptr,a
                           5631 ;	../../include/ztex-isr.h:275: EP0BCH = 0;
   1637 90 E6 8A           5632 	mov	dptr,#_EP0BCH
   163A E4                 5633 	clr	a
   163B F0                 5634 	movx	@dptr,a
                           5635 ;	../../include/ztex-isr.h:276: EP0BCL = 2;
   163C 90 E6 8B           5636 	mov	dptr,#_EP0BCL
   163F 74 02              5637 	mov	a,#0x02
   1641 F0                 5638 	movx	@dptr,a
                           5639 ;	../../include/ztex-isr.h:280: }
   1642                    5640 00160$:
                           5641 ;	../../include/ztex-isr.h:283: switch ( bmRequestType ) {
   1642 90 E6 B8           5642 	mov	dptr,#_bmRequestType
   1645 E0                 5643 	movx	a,@dptr
   1646 FA                 5644 	mov	r2,a
   1647 BA 40 03           5645 	cjne	r2,#0x40,00274$
   164A 02 18 6D           5646 	ljmp	00182$
   164D                    5647 00274$:
   164D BA C0 02           5648 	cjne	r2,#0xC0,00275$
   1650 80 03              5649 	sjmp	00276$
   1652                    5650 00275$:
   1652 02 18 97           5651 	ljmp	00186$
   1655                    5652 00276$:
                           5653 ;	../../include/ztex-isr.h:285: ep0_payload_remaining = (SETUPDAT[7] << 8) | SETUPDAT[6];
   1655 90 E6 BF           5654 	mov	dptr,#(_SETUPDAT + 0x0007)
   1658 E0                 5655 	movx	a,@dptr
   1659 FB                 5656 	mov	r3,a
   165A 7A 00              5657 	mov	r2,#0x00
   165C 90 E6 BE           5658 	mov	dptr,#(_SETUPDAT + 0x0006)
   165F E0                 5659 	movx	a,@dptr
   1660 FC                 5660 	mov	r4,a
   1661 7D 00              5661 	mov	r5,#0x00
   1663 90 3A 36           5662 	mov	dptr,#_ep0_payload_remaining
   1666 EC                 5663 	mov	a,r4
   1667 4A                 5664 	orl	a,r2
   1668 F0                 5665 	movx	@dptr,a
   1669 ED                 5666 	mov	a,r5
   166A 4B                 5667 	orl	a,r3
   166B A3                 5668 	inc	dptr
   166C F0                 5669 	movx	@dptr,a
                           5670 ;	../../include/ztex-isr.h:286: ep0_payload_update();
   166D 12 11 C6           5671 	lcall	_ep0_payload_update
                           5672 ;	../../include/ztex-isr.h:288: switch ( bRequest ) {
   1670 90 E6 B9           5673 	mov	dptr,#_bRequest
   1673 E0                 5674 	movx	a,@dptr
   1674 FA                 5675 	mov	r2,a
   1675 BA 22 02           5676 	cjne	r2,#0x22,00277$
   1678 80 31              5677 	sjmp	00162$
   167A                    5678 00277$:
   167A BA 30 03           5679 	cjne	r2,#0x30,00278$
   167D 02 18 13           5680 	ljmp	00176$
   1680                    5681 00278$:
   1680 BA 38 02           5682 	cjne	r2,#0x38,00279$
   1683 80 43              5683 	sjmp	00163$
   1685                    5684 00279$:
   1685 BA 3A 02           5685 	cjne	r2,#0x3A,00280$
   1688 80 67              5686 	sjmp	00164$
   168A                    5687 00280$:
   168A BA 3B 03           5688 	cjne	r2,#0x3B,00281$
   168D 02 17 30           5689 	ljmp	00165$
   1690                    5690 00281$:
   1690 BA 3D 03           5691 	cjne	r2,#0x3D,00282$
   1693 02 17 49           5692 	ljmp	00166$
   1696                    5693 00282$:
   1696 BA 40 03           5694 	cjne	r2,#0x40,00283$
   1699 02 17 6A           5695 	ljmp	00167$
   169C                    5696 00283$:
   169C BA 41 03           5697 	cjne	r2,#0x41,00284$
   169F 02 17 A0           5698 	ljmp	00171$
   16A2                    5699 00284$:
   16A2 BA 43 03           5700 	cjne	r2,#0x43,00285$
   16A5 02 17 ED           5701 	ljmp	00175$
   16A8                    5702 00285$:
   16A8 02 18 63           5703 	ljmp	00180$
                           5704 ;	../../include/ztex-isr.h:289: case 0x22: 				// get ZTEX descriptor
   16AB                    5705 00162$:
                           5706 ;	../../include/ztex-isr.h:290: SUDPTRCTL = 0;
   16AB 90 E6 B5           5707 	mov	dptr,#_SUDPTRCTL
                           5708 ;	../../include/ztex-isr.h:291: EP0BCH = 0;
   16AE E4                 5709 	clr	a
   16AF F0                 5710 	movx	@dptr,a
   16B0 90 E6 8A           5711 	mov	dptr,#_EP0BCH
   16B3 F0                 5712 	movx	@dptr,a
                           5713 ;	../../include/ztex-isr.h:292: EP0BCL = ZTEX_DESCRIPTOR_LEN;
   16B4 90 E6 8B           5714 	mov	dptr,#_EP0BCL
   16B7 74 28              5715 	mov	a,#0x28
   16B9 F0                 5716 	movx	@dptr,a
                           5717 ;	../../include/ztex-isr.h:293: SUDPTRH = MSB(ZTEX_DESCRIPTOR_OFFS);
   16BA 90 E6 B3           5718 	mov	dptr,#_SUDPTRH
   16BD E4                 5719 	clr	a
   16BE F0                 5720 	movx	@dptr,a
                           5721 ;	../../include/ztex-isr.h:294: SUDPTRL = LSB(ZTEX_DESCRIPTOR_OFFS); 
   16BF 90 E6 B4           5722 	mov	dptr,#_SUDPTRL
   16C2 74 6C              5723 	mov	a,#0x6C
   16C4 F0                 5724 	movx	@dptr,a
                           5725 ;	../../include/ztex-isr.h:295: break;
   16C5 02 18 97           5726 	ljmp	00186$
                           5727 ;	../../include/ztex-conf.h:100: case $0:
   16C8                    5728 00163$:
                           5729 ;	../../include/ztex-conf.h:102: break;
   16C8 90 E6 BB           5730 	mov	dptr,#(_SETUPDAT + 0x0003)
   16CB E0                 5731 	movx	a,@dptr
   16CC FB                 5732 	mov	r3,a
   16CD 7A 00              5733 	mov	r2,#0x00
   16CF 90 E6 BA           5734 	mov	dptr,#(_SETUPDAT + 0x0002)
   16D2 E0                 5735 	movx	a,@dptr
   16D3 FC                 5736 	mov	r4,a
   16D4 7D 00              5737 	mov	r5,#0x00
   16D6 90 3A 00           5738 	mov	dptr,#_eeprom_addr
   16D9 EC                 5739 	mov	a,r4
   16DA 4A                 5740 	orl	a,r2
   16DB F0                 5741 	movx	@dptr,a
   16DC ED                 5742 	mov	a,r5
   16DD 4B                 5743 	orl	a,r3
   16DE A3                 5744 	inc	dptr
   16DF F0                 5745 	movx	@dptr,a
                           5746 ;	../../include/ztex-eeprom.h:219: EP0BCH = 0;
   16E0 90 E6 8A           5747 	mov	dptr,#_EP0BCH
   16E3 E4                 5748 	clr	a
   16E4 F0                 5749 	movx	@dptr,a
                           5750 ;	../../include/ztex-eeprom.h:220: EP0BCL = eeprom_read_ep0(); 
   16E5 12 05 73           5751 	lcall	_eeprom_read_ep0
   16E8 E5 82              5752 	mov	a,dpl
   16EA 90 E6 8B           5753 	mov	dptr,#_EP0BCL
   16ED F0                 5754 	movx	@dptr,a
                           5755 ;	../../include/ztex-conf.h:102: break;
   16EE 02 18 97           5756 	ljmp	00186$
                           5757 ;	../../include/ztex-conf.h:100: case $0:
   16F1                    5758 00164$:
                           5759 ;	../../include/ztex-eeprom.h:247: EP0BUF[0] = LSB(eeprom_write_bytes);
   16F1 90 3A 02           5760 	mov	dptr,#_eeprom_write_bytes
   16F4 E0                 5761 	movx	a,@dptr
   16F5 FA                 5762 	mov	r2,a
   16F6 A3                 5763 	inc	dptr
   16F7 E0                 5764 	movx	a,@dptr
   16F8 FB                 5765 	mov	r3,a
   16F9 8A 04              5766 	mov	ar4,r2
   16FB 90 E7 40           5767 	mov	dptr,#_EP0BUF
   16FE EC                 5768 	mov	a,r4
   16FF F0                 5769 	movx	@dptr,a
                           5770 ;	../../include/ztex-eeprom.h:248: EP0BUF[1] = MSB(eeprom_write_bytes);
   1700 8B 02              5771 	mov	ar2,r3
   1702 90 E7 41           5772 	mov	dptr,#(_EP0BUF + 0x0001)
   1705 EA                 5773 	mov	a,r2
   1706 F0                 5774 	movx	@dptr,a
                           5775 ;	../../include/ztex-eeprom.h:249: EP0BUF[2] = eeprom_write_checksum;
   1707 90 3A 04           5776 	mov	dptr,#_eeprom_write_checksum
   170A E0                 5777 	movx	a,@dptr
   170B 90 E7 42           5778 	mov	dptr,#(_EP0BUF + 0x0002)
   170E F0                 5779 	movx	@dptr,a
                           5780 ;	../../include/ztex-eeprom.h:250: EP0BUF[3] = eeprom_select(EEPROM_ADDR,0,1);		// 1 means busy or error
   170F 75 08 00           5781 	mov	_eeprom_select_PARM_2,#0x00
   1712 75 09 01           5782 	mov	_eeprom_select_PARM_3,#0x01
   1715 75 82 A2           5783 	mov	dpl,#0xA2
   1718 12 03 46           5784 	lcall	_eeprom_select
   171B AA 82              5785 	mov	r2,dpl
   171D 90 E7 43           5786 	mov	dptr,#(_EP0BUF + 0x0003)
   1720 EA                 5787 	mov	a,r2
   1721 F0                 5788 	movx	@dptr,a
                           5789 ;	../../include/ztex-eeprom.h:251: EP0BCH = 0;
   1722 90 E6 8A           5790 	mov	dptr,#_EP0BCH
   1725 E4                 5791 	clr	a
   1726 F0                 5792 	movx	@dptr,a
                           5793 ;	../../include/ztex-eeprom.h:252: EP0BCL = 4;
   1727 90 E6 8B           5794 	mov	dptr,#_EP0BCL
   172A 74 04              5795 	mov	a,#0x04
   172C F0                 5796 	movx	@dptr,a
                           5797 ;	../../include/ztex-conf.h:102: break;
   172D 02 18 97           5798 	ljmp	00186$
                           5799 ;	../../include/ztex-conf.h:100: case $0:
   1730                    5800 00165$:
                           5801 ;	../../include/ztex-conf.h:102: break;
   1730 90 E6 BA           5802 	mov	dptr,#(_SETUPDAT + 0x0002)
   1733 E0                 5803 	movx	a,@dptr
   1734 90 3A 05           5804 	mov	dptr,#_mac_eeprom_addr
   1737 F0                 5805 	movx	@dptr,a
                           5806 ;	../../include/ztex-eeprom.h:368: EP0BCH = 0;
   1738 90 E6 8A           5807 	mov	dptr,#_EP0BCH
   173B E4                 5808 	clr	a
   173C F0                 5809 	movx	@dptr,a
                           5810 ;	../../include/ztex-eeprom.h:369: EP0BCL = mac_eeprom_read_ep0(); 
   173D 12 07 B9           5811 	lcall	_mac_eeprom_read_ep0
   1740 E5 82              5812 	mov	a,dpl
   1742 90 E6 8B           5813 	mov	dptr,#_EP0BCL
   1745 F0                 5814 	movx	@dptr,a
                           5815 ;	../../include/ztex-conf.h:102: break;
   1746 02 18 97           5816 	ljmp	00186$
                           5817 ;	../../include/ztex-conf.h:100: case $0:
   1749                    5818 00166$:
                           5819 ;	../../include/ztex-conf.h:102: break;
   1749 75 08 00           5820 	mov	_eeprom_select_PARM_2,#0x00
   174C 75 09 01           5821 	mov	_eeprom_select_PARM_3,#0x01
   174F 75 82 A6           5822 	mov	dpl,#0xA6
   1752 12 03 46           5823 	lcall	_eeprom_select
   1755 AA 82              5824 	mov	r2,dpl
   1757 90 E7 40           5825 	mov	dptr,#_EP0BUF
   175A EA                 5826 	mov	a,r2
   175B F0                 5827 	movx	@dptr,a
                           5828 ;	../../include/ztex-eeprom.h:390: EP0BCH = 0;
   175C 90 E6 8A           5829 	mov	dptr,#_EP0BCH
   175F E4                 5830 	clr	a
   1760 F0                 5831 	movx	@dptr,a
                           5832 ;	../../include/ztex-eeprom.h:391: EP0BCL = 1;
   1761 90 E6 8B           5833 	mov	dptr,#_EP0BCL
   1764 74 01              5834 	mov	a,#0x01
   1766 F0                 5835 	movx	@dptr,a
                           5836 ;	../../include/ztex-conf.h:102: break;
   1767 02 18 97           5837 	ljmp	00186$
                           5838 ;	../../include/ztex-conf.h:100: case $0:
   176A                    5839 00167$:
                           5840 ;	../../include/ztex-flash2.h:646: if ( flash_ec == 0 && SPI_CS == 0 ) {
   176A 90 3A 0E           5841 	mov	dptr,#_flash_ec
   176D E0                 5842 	movx	a,@dptr
   176E FA                 5843 	mov	r2,a
   176F 70 09              5844 	jnz	00169$
   1771 20 83 06           5845 	jb	_IOA3,00169$
                           5846 ;	../../include/ztex-flash2.h:647: flash_ec = FLASH_EC_PENDING;
   1774 90 3A 0E           5847 	mov	dptr,#_flash_ec
   1777 74 04              5848 	mov	a,#0x04
   1779 F0                 5849 	movx	@dptr,a
   177A                    5850 00169$:
                           5851 ;	../../include/ztex-utils.h:121: AUTOPTRL1=LO(&($0));
   177A 75 9B 07           5852 	mov	_AUTOPTRL1,#_flash_enabled
                           5853 ;	../../include/ztex-utils.h:122: AUTOPTRH1=HI(&($0));
   177D 7A 07              5854 	mov	r2,#_flash_enabled
   177F 7B 3A              5855 	mov	r3,#(_flash_enabled >> 8)
   1781 8B 9A              5856 	mov	_AUTOPTRH1,r3
                           5857 ;	../../include/ztex-utils.h:123: AUTOPTRL2=LO(&($1));
   1783 75 9E 40           5858 	mov	_AUTOPTRL2,#0x40
                           5859 ;	../../include/ztex-utils.h:124: AUTOPTRH2=HI(&($1));
   1786 75 9D E7           5860 	mov	_AUTOPTRH2,#0xE7
                           5861 ;	../../include/ztex-utils.h:130: __endasm; 
                           5862 	
   1789 C0 02              5863 	  push ar2
   178B 7A 08              5864 	    mov r2,#(8);
   178D 12 02 AD           5865 	  lcall _MEM_COPY1_int
   1790 D0 02              5866 	  pop ar2
                           5867 	        
                           5868 ;	../../include/ztex-flash2.h:650: EP0BCH = 0;
   1792 90 E6 8A           5869 	mov	dptr,#_EP0BCH
   1795 E4                 5870 	clr	a
   1796 F0                 5871 	movx	@dptr,a
                           5872 ;	../../include/ztex-flash2.h:651: EP0BCL = 8;
   1797 90 E6 8B           5873 	mov	dptr,#_EP0BCL
   179A 74 08              5874 	mov	a,#0x08
   179C F0                 5875 	movx	@dptr,a
                           5876 ;	../../include/ztex-conf.h:102: break;
   179D 02 18 97           5877 	ljmp	00186$
                           5878 ;	../../include/ztex-conf.h:100: case $0:
   17A0                    5879 00171$:
                           5880 ;	../../include/ztex-flash2.h:671: ep0_read_mode = SETUPDAT[5];
   17A0 90 E6 BD           5881 	mov	dptr,#(_SETUPDAT + 0x0005)
   17A3 E0                 5882 	movx	a,@dptr
   17A4 FA                 5883 	mov	r2,a
   17A5 90 3A 1E           5884 	mov	dptr,#_ep0_read_mode
   17A8 F0                 5885 	movx	@dptr,a
                           5886 ;	../../include/ztex-flash2.h:672: if ( (ep0_read_mode==0) && flash_read_init((SETUPDAT[3] << 8) | SETUPDAT[2]) ) {
   17A9 EA                 5887 	mov	a,r2
   17AA 70 2D              5888 	jnz	00173$
   17AC 90 E6 BB           5889 	mov	dptr,#(_SETUPDAT + 0x0003)
   17AF E0                 5890 	movx	a,@dptr
   17B0 FB                 5891 	mov	r3,a
   17B1 7A 00              5892 	mov	r2,#0x00
   17B3 90 E6 BA           5893 	mov	dptr,#(_SETUPDAT + 0x0002)
   17B6 E0                 5894 	movx	a,@dptr
   17B7 7D 00              5895 	mov	r5,#0x00
   17B9 4A                 5896 	orl	a,r2
   17BA F5 82              5897 	mov	dpl,a
   17BC ED                 5898 	mov	a,r5
   17BD 4B                 5899 	orl	a,r3
   17BE F5 83              5900 	mov	dph,a
   17C0 12 09 63           5901 	lcall	_flash_read_init
   17C3 E5 82              5902 	mov	a,dpl
   17C5 60 12              5903 	jz	00173$
                           5904 ;	../../include/ztex-conf.h:137: EP0CS |= 0x01;	// set stall
   17C7 90 E6 A0           5905 	mov	dptr,#_EP0CS
   17CA E0                 5906 	movx	a,@dptr
   17CB FA                 5907 	mov	r2,a
   17CC 44 01              5908 	orl	a,#0x01
   17CE F0                 5909 	movx	@dptr,a
                           5910 ;	../../include/ztex-conf.h:138: ep0_payload_remaining = 0;
   17CF 90 3A 36           5911 	mov	dptr,#_ep0_payload_remaining
   17D2 E4                 5912 	clr	a
   17D3 F0                 5913 	movx	@dptr,a
   17D4 A3                 5914 	inc	dptr
   17D5 F0                 5915 	movx	@dptr,a
                           5916 ;	../../include/ztex-conf.h:139: break;
   17D6 02 18 97           5917 	ljmp	00186$
   17D9                    5918 00173$:
                           5919 ;	../../include/ztex-flash2.h:675: spi_read_ep0();  
   17D9 12 0C ED           5920 	lcall	_spi_read_ep0
                           5921 ;	../../include/ztex-flash2.h:676: EP0BCH = 0;
   17DC 90 E6 8A           5922 	mov	dptr,#_EP0BCH
   17DF E4                 5923 	clr	a
   17E0 F0                 5924 	movx	@dptr,a
                           5925 ;	../../include/ztex-flash2.h:677: EP0BCL = ep0_payload_transfer; 
   17E1 90 3A 38           5926 	mov	dptr,#_ep0_payload_transfer
   17E4 E0                 5927 	movx	a,@dptr
   17E5 FA                 5928 	mov	r2,a
   17E6 90 E6 8B           5929 	mov	dptr,#_EP0BCL
   17E9 F0                 5930 	movx	@dptr,a
                           5931 ;	../../include/ztex-conf.h:102: break;
   17EA 02 18 97           5932 	ljmp	00186$
                           5933 ;	../../include/ztex-conf.h:100: case $0:
   17ED                    5934 00175$:
                           5935 ;	../../include/ztex-utils.h:121: AUTOPTRL1=LO(&($0));
   17ED 75 9B 0E           5936 	mov	_AUTOPTRL1,#_flash_ec
                           5937 ;	../../include/ztex-utils.h:122: AUTOPTRH1=HI(&($0));
   17F0 7A 0E              5938 	mov	r2,#_flash_ec
   17F2 7B 3A              5939 	mov	r3,#(_flash_ec >> 8)
   17F4 8B 9A              5940 	mov	_AUTOPTRH1,r3
                           5941 ;	../../include/ztex-utils.h:123: AUTOPTRL2=LO(&($1));
   17F6 75 9E 40           5942 	mov	_AUTOPTRL2,#0x40
                           5943 ;	../../include/ztex-utils.h:124: AUTOPTRH2=HI(&($1));
   17F9 75 9D E7           5944 	mov	_AUTOPTRH2,#0xE7
                           5945 ;	../../include/ztex-utils.h:130: __endasm; 
                           5946 	
   17FC C0 02              5947 	  push ar2
   17FE 7A 0A              5948 	    mov r2,#(10);
   1800 12 02 AD           5949 	  lcall _MEM_COPY1_int
   1803 D0 02              5950 	  pop ar2
                           5951 	        
                           5952 ;	../../include/ztex-flash2.h:719: EP0BCH = 0;
   1805 90 E6 8A           5953 	mov	dptr,#_EP0BCH
   1808 E4                 5954 	clr	a
   1809 F0                 5955 	movx	@dptr,a
                           5956 ;	../../include/ztex-flash2.h:720: EP0BCL = 10;
   180A 90 E6 8B           5957 	mov	dptr,#_EP0BCL
   180D 74 0A              5958 	mov	a,#0x0A
   180F F0                 5959 	movx	@dptr,a
                           5960 ;	../../include/ztex-conf.h:102: break;
   1810 02 18 97           5961 	ljmp	00186$
                           5962 ;	../../include/ztex-conf.h:100: case $0:
   1813                    5963 00176$:
                           5964 ;	../../include/ztex-utils.h:121: AUTOPTRL1=LO(&($0));
   1813 75 9B 20           5965 	mov	_AUTOPTRL1,#_fpga_checksum
                           5966 ;	../../include/ztex-utils.h:122: AUTOPTRH1=HI(&($0));
   1816 7A 20              5967 	mov	r2,#_fpga_checksum
   1818 7B 3A              5968 	mov	r3,#(_fpga_checksum >> 8)
   181A 8B 9A              5969 	mov	_AUTOPTRH1,r3
                           5970 ;	../../include/ztex-utils.h:123: AUTOPTRL2=LO(&($1));
   181C 75 9E 41           5971 	mov	_AUTOPTRL2,#(_EP0BUF + 0x0001)
                           5972 ;	../../include/ztex-utils.h:124: AUTOPTRH2=HI(&($1));
   181F 7A 41              5973 	mov	r2,#(_EP0BUF + 0x0001)
   1821 7B E7              5974 	mov	r3,#((_EP0BUF + 0x0001) >> 8)
   1823 8B 9D              5975 	mov	_AUTOPTRH2,r3
                           5976 ;	../../include/ztex-utils.h:130: __endasm; 
                           5977 	
   1825 C0 02              5978 	  push ar2
   1827 7A 07              5979 	    mov r2,#(7);
   1829 12 02 AD           5980 	  lcall _MEM_COPY1_int
   182C D0 02              5981 	  pop ar2
                           5982 	        
                           5983 ;	../../include/ztex-fpga7.h:144: OEE = (OEE & ~bmBIT6) | bmBIT7;
   182E AA B6              5984 	mov	r2,_OEE
   1830 74 BF              5985 	mov	a,#0xBF
   1832 5A                 5986 	anl	a,r2
   1833 F5 F0              5987 	mov	b,a
   1835 74 80              5988 	mov	a,#0x80
   1837 45 F0              5989 	orl	a,b
   1839 F5 B6              5990 	mov	_OEE,a
                           5991 ;	../../include/ztex-fpga7.h:145: if ( IOE & bmBIT6 )  {
   183B E5 B1              5992 	mov	a,_IOE
   183D 30 E6 07           5993 	jnb	acc.6,00178$
                           5994 ;	../../include/ztex-fpga7.h:146: EP0BUF[0] = 0; 	 		// FPGA configured 
   1840 90 E7 40           5995 	mov	dptr,#_EP0BUF
   1843 E4                 5996 	clr	a
   1844 F0                 5997 	movx	@dptr,a
   1845 80 09              5998 	sjmp	00179$
   1847                    5999 00178$:
                           6000 ;	../../include/ztex-fpga7.h:149: EP0BUF[0] = 1;			// FPGA unconfigured 
   1847 90 E7 40           6001 	mov	dptr,#_EP0BUF
   184A 74 01              6002 	mov	a,#0x01
   184C F0                 6003 	movx	@dptr,a
                           6004 ;	../../include/ztex-fpga7.h:150: reset_fpga();			// prepare FPGA for configuration
   184D 12 0D 33           6005 	lcall	_reset_fpga
   1850                    6006 00179$:
                           6007 ;	../../include/ztex-fpga7.h:153: EP0BUF[8] = 1;			// bit order for bitstream in Flash memory: swapped
   1850 90 E7 48           6008 	mov	dptr,#(_EP0BUF + 0x0008)
   1853 74 01              6009 	mov	a,#0x01
   1855 F0                 6010 	movx	@dptr,a
                           6011 ;	../../include/ztex-fpga7.h:155: EP0BCH = 0;
   1856 90 E6 8A           6012 	mov	dptr,#_EP0BCH
   1859 E4                 6013 	clr	a
   185A F0                 6014 	movx	@dptr,a
                           6015 ;	../../include/ztex-fpga7.h:156: EP0BCL = 9;
   185B 90 E6 8B           6016 	mov	dptr,#_EP0BCL
   185E 74 09              6017 	mov	a,#0x09
   1860 F0                 6018 	movx	@dptr,a
                           6019 ;	../../include/ztex-conf.h:102: break;
                           6020 ;	../../include/ztex-isr.h:297: default:
   1861 80 34              6021 	sjmp	00186$
   1863                    6022 00180$:
                           6023 ;	../../include/ztex-isr.h:298: EP0CS |= 0x01;			// set stall, unknown request
   1863 90 E6 A0           6024 	mov	dptr,#_EP0CS
   1866 E0                 6025 	movx	a,@dptr
   1867 FA                 6026 	mov	r2,a
   1868 44 01              6027 	orl	a,#0x01
   186A F0                 6028 	movx	@dptr,a
                           6029 ;	../../include/ztex-isr.h:300: break;
                           6030 ;	../../include/ztex-isr.h:301: case 0x40: 					// vendor command
   186B 80 2A              6031 	sjmp	00186$
   186D                    6032 00182$:
                           6033 ;	../../include/ztex-isr.h:305: if ( SETUPDAT[7]!=0 || SETUPDAT[6]!=0 ) {
   186D 90 E6 BF           6034 	mov	dptr,#(_SETUPDAT + 0x0007)
   1870 E0                 6035 	movx	a,@dptr
   1871 70 06              6036 	jnz	00183$
   1873 90 E6 BE           6037 	mov	dptr,#(_SETUPDAT + 0x0006)
   1876 E0                 6038 	movx	a,@dptr
   1877 60 16              6039 	jz	00184$
   1879                    6040 00183$:
                           6041 ;	../../include/ztex-isr.h:306: ep0_vendor_cmd_setup = 1;
   1879 90 3A 3A           6042 	mov	dptr,#_ep0_vendor_cmd_setup
   187C 74 01              6043 	mov	a,#0x01
   187E F0                 6044 	movx	@dptr,a
                           6045 ;	../../include/ztex-isr.h:307: EP0BCL = 0;
   187F 90 E6 8B           6046 	mov	dptr,#_EP0BCL
   1882 E4                 6047 	clr	a
   1883 F0                 6048 	movx	@dptr,a
                           6049 ;	../../include/ztex-isr.h:308: EXIF &= ~bmBIT4;			// clear main USB interrupt flag
   1884 53 91 EF           6050 	anl	_EXIF,#0xEF
                           6051 ;	../../include/ztex-isr.h:309: USBIRQ = bmBIT0;			// clear SUADV IRQ
   1887 90 E6 5D           6052 	mov	dptr,#_USBIRQ
   188A 74 01              6053 	mov	a,#0x01
   188C F0                 6054 	movx	@dptr,a
                           6055 ;	../../include/ztex-isr.h:310: return;					// don't clear HSNAK bit. This is done after the command has completed
   188D 80 19              6056 	sjmp	00187$
   188F                    6057 00184$:
                           6058 ;	../../include/ztex-isr.h:312: ep0_vendor_cmd_su();			// setup sequences of vendor command with no payload ara executed immediately
   188F 12 11 F3           6059 	lcall	_ep0_vendor_cmd_su
                           6060 ;	../../include/ztex-isr.h:313: EP0BCL = 0;
   1892 90 E6 8B           6061 	mov	dptr,#_EP0BCL
   1895 E4                 6062 	clr	a
   1896 F0                 6063 	movx	@dptr,a
                           6064 ;	../../include/ztex-isr.h:315: }
   1897                    6065 00186$:
                           6066 ;	../../include/ztex-isr.h:317: EXIF &= ~bmBIT4;					// clear main USB interrupt flag
   1897 53 91 EF           6067 	anl	_EXIF,#0xEF
                           6068 ;	../../include/ztex-isr.h:318: USBIRQ = bmBIT0;					// clear SUADV IRQ
   189A 90 E6 5D           6069 	mov	dptr,#_USBIRQ
   189D 74 01              6070 	mov	a,#0x01
   189F F0                 6071 	movx	@dptr,a
                           6072 ;	../../include/ztex-isr.h:319: EP0CS |= 0x80;					// clear the HSNAK bit
   18A0 90 E6 A0           6073 	mov	dptr,#_EP0CS
   18A3 E0                 6074 	movx	a,@dptr
   18A4 FA                 6075 	mov	r2,a
   18A5 44 80              6076 	orl	a,#0x80
   18A7 F0                 6077 	movx	@dptr,a
   18A8                    6078 00187$:
   18A8 D0 D0              6079 	pop	psw
   18AA D0 01              6080 	pop	(0+1)
   18AC D0 00              6081 	pop	(0+0)
   18AE D0 07              6082 	pop	(0+7)
   18B0 D0 06              6083 	pop	(0+6)
   18B2 D0 05              6084 	pop	(0+5)
   18B4 D0 04              6085 	pop	(0+4)
   18B6 D0 03              6086 	pop	(0+3)
   18B8 D0 02              6087 	pop	(0+2)
   18BA D0 83              6088 	pop	dph
   18BC D0 82              6089 	pop	dpl
   18BE D0 F0              6090 	pop	b
   18C0 D0 E0              6091 	pop	acc
   18C2 D0 20              6092 	pop	bits
   18C4 32                 6093 	reti
                           6094 ;------------------------------------------------------------
                           6095 ;Allocation info for local variables in function 'SOF_ISR'
                           6096 ;------------------------------------------------------------
                           6097 ;------------------------------------------------------------
                           6098 ;	../../include/ztex-isr.h:325: void SOF_ISR() __interrupt
                           6099 ;	-----------------------------------------
                           6100 ;	 function SOF_ISR
                           6101 ;	-----------------------------------------
   18C5                    6102 _SOF_ISR:
   18C5 C0 E0              6103 	push	acc
   18C7 C0 82              6104 	push	dpl
   18C9 C0 83              6105 	push	dph
                           6106 ;	../../include/ztex-isr.h:327: EXIF &= ~bmBIT4;
   18CB 53 91 EF           6107 	anl	_EXIF,#0xEF
                           6108 ;	../../include/ztex-isr.h:328: USBIRQ = bmBIT1;
   18CE 90 E6 5D           6109 	mov	dptr,#_USBIRQ
   18D1 74 02              6110 	mov	a,#0x02
   18D3 F0                 6111 	movx	@dptr,a
   18D4 D0 83              6112 	pop	dph
   18D6 D0 82              6113 	pop	dpl
   18D8 D0 E0              6114 	pop	acc
   18DA 32                 6115 	reti
                           6116 ;	eliminated unneeded push/pop psw
                           6117 ;	eliminated unneeded push/pop b
                           6118 ;------------------------------------------------------------
                           6119 ;Allocation info for local variables in function 'SUTOK_ISR'
                           6120 ;------------------------------------------------------------
                           6121 ;------------------------------------------------------------
                           6122 ;	../../include/ztex-isr.h:334: void SUTOK_ISR() __interrupt 
                           6123 ;	-----------------------------------------
                           6124 ;	 function SUTOK_ISR
                           6125 ;	-----------------------------------------
   18DB                    6126 _SUTOK_ISR:
   18DB C0 E0              6127 	push	acc
   18DD C0 82              6128 	push	dpl
   18DF C0 83              6129 	push	dph
                           6130 ;	../../include/ztex-isr.h:336: EXIF &= ~bmBIT4;
   18E1 53 91 EF           6131 	anl	_EXIF,#0xEF
                           6132 ;	../../include/ztex-isr.h:337: USBIRQ = bmBIT2;
   18E4 90 E6 5D           6133 	mov	dptr,#_USBIRQ
   18E7 74 04              6134 	mov	a,#0x04
   18E9 F0                 6135 	movx	@dptr,a
   18EA D0 83              6136 	pop	dph
   18EC D0 82              6137 	pop	dpl
   18EE D0 E0              6138 	pop	acc
   18F0 32                 6139 	reti
                           6140 ;	eliminated unneeded push/pop psw
                           6141 ;	eliminated unneeded push/pop b
                           6142 ;------------------------------------------------------------
                           6143 ;Allocation info for local variables in function 'SUSP_ISR'
                           6144 ;------------------------------------------------------------
                           6145 ;------------------------------------------------------------
                           6146 ;	../../include/ztex-isr.h:343: void SUSP_ISR() __interrupt
                           6147 ;	-----------------------------------------
                           6148 ;	 function SUSP_ISR
                           6149 ;	-----------------------------------------
   18F1                    6150 _SUSP_ISR:
   18F1 C0 E0              6151 	push	acc
   18F3 C0 82              6152 	push	dpl
   18F5 C0 83              6153 	push	dph
                           6154 ;	../../include/ztex-isr.h:345: EXIF &= ~bmBIT4;
   18F7 53 91 EF           6155 	anl	_EXIF,#0xEF
                           6156 ;	../../include/ztex-isr.h:346: USBIRQ = bmBIT3;
   18FA 90 E6 5D           6157 	mov	dptr,#_USBIRQ
   18FD 74 08              6158 	mov	a,#0x08
   18FF F0                 6159 	movx	@dptr,a
   1900 D0 83              6160 	pop	dph
   1902 D0 82              6161 	pop	dpl
   1904 D0 E0              6162 	pop	acc
   1906 32                 6163 	reti
                           6164 ;	eliminated unneeded push/pop psw
                           6165 ;	eliminated unneeded push/pop b
                           6166 ;------------------------------------------------------------
                           6167 ;Allocation info for local variables in function 'URES_ISR'
                           6168 ;------------------------------------------------------------
                           6169 ;------------------------------------------------------------
                           6170 ;	../../include/ztex-isr.h:352: void URES_ISR() __interrupt
                           6171 ;	-----------------------------------------
                           6172 ;	 function URES_ISR
                           6173 ;	-----------------------------------------
   1907                    6174 _URES_ISR:
   1907 C0 E0              6175 	push	acc
   1909 C0 82              6176 	push	dpl
   190B C0 83              6177 	push	dph
                           6178 ;	../../include/ztex-isr.h:354: EXIF &= ~bmBIT4;
   190D 53 91 EF           6179 	anl	_EXIF,#0xEF
                           6180 ;	../../include/ztex-isr.h:355: USBIRQ = bmBIT4;
   1910 90 E6 5D           6181 	mov	dptr,#_USBIRQ
   1913 74 10              6182 	mov	a,#0x10
   1915 F0                 6183 	movx	@dptr,a
   1916 D0 83              6184 	pop	dph
   1918 D0 82              6185 	pop	dpl
   191A D0 E0              6186 	pop	acc
   191C 32                 6187 	reti
                           6188 ;	eliminated unneeded push/pop psw
                           6189 ;	eliminated unneeded push/pop b
                           6190 ;------------------------------------------------------------
                           6191 ;Allocation info for local variables in function 'HSGRANT_ISR'
                           6192 ;------------------------------------------------------------
                           6193 ;------------------------------------------------------------
                           6194 ;	../../include/ztex-isr.h:361: void HSGRANT_ISR() __interrupt
                           6195 ;	-----------------------------------------
                           6196 ;	 function HSGRANT_ISR
                           6197 ;	-----------------------------------------
   191D                    6198 _HSGRANT_ISR:
   191D C0 E0              6199 	push	acc
   191F C0 82              6200 	push	dpl
   1921 C0 83              6201 	push	dph
                           6202 ;	../../include/ztex-isr.h:363: EXIF &= ~bmBIT4;
   1923 53 91 EF           6203 	anl	_EXIF,#0xEF
                           6204 ;	../../include/ztex-isr.h:365: USBIRQ = bmBIT5;
   1926 90 E6 5D           6205 	mov	dptr,#_USBIRQ
   1929 74 20              6206 	mov	a,#0x20
   192B F0                 6207 	movx	@dptr,a
   192C D0 83              6208 	pop	dph
   192E D0 82              6209 	pop	dpl
   1930 D0 E0              6210 	pop	acc
   1932 32                 6211 	reti
                           6212 ;	eliminated unneeded push/pop psw
                           6213 ;	eliminated unneeded push/pop b
                           6214 ;------------------------------------------------------------
                           6215 ;Allocation info for local variables in function 'EP0ACK_ISR'
                           6216 ;------------------------------------------------------------
                           6217 ;------------------------------------------------------------
                           6218 ;	../../include/ztex-isr.h:371: void EP0ACK_ISR() __interrupt
                           6219 ;	-----------------------------------------
                           6220 ;	 function EP0ACK_ISR
                           6221 ;	-----------------------------------------
   1933                    6222 _EP0ACK_ISR:
   1933 C0 E0              6223 	push	acc
   1935 C0 82              6224 	push	dpl
   1937 C0 83              6225 	push	dph
                           6226 ;	../../include/ztex-isr.h:373: EXIF &= ~bmBIT4;	// clear USB interrupt flag
   1939 53 91 EF           6227 	anl	_EXIF,#0xEF
                           6228 ;	../../include/ztex-isr.h:374: USBIRQ = bmBIT6;	// clear EP0ACK IRQ
   193C 90 E6 5D           6229 	mov	dptr,#_USBIRQ
   193F 74 40              6230 	mov	a,#0x40
   1941 F0                 6231 	movx	@dptr,a
   1942 D0 83              6232 	pop	dph
   1944 D0 82              6233 	pop	dpl
   1946 D0 E0              6234 	pop	acc
   1948 32                 6235 	reti
                           6236 ;	eliminated unneeded push/pop psw
                           6237 ;	eliminated unneeded push/pop b
                           6238 ;------------------------------------------------------------
                           6239 ;Allocation info for local variables in function 'EP0IN_ISR'
                           6240 ;------------------------------------------------------------
                           6241 ;------------------------------------------------------------
                           6242 ;	../../include/ztex-isr.h:380: static void EP0IN_ISR () __interrupt
                           6243 ;	-----------------------------------------
                           6244 ;	 function EP0IN_ISR
                           6245 ;	-----------------------------------------
   1949                    6246 _EP0IN_ISR:
   1949 C0 20              6247 	push	bits
   194B C0 E0              6248 	push	acc
   194D C0 F0              6249 	push	b
   194F C0 82              6250 	push	dpl
   1951 C0 83              6251 	push	dph
   1953 C0 02              6252 	push	(0+2)
   1955 C0 03              6253 	push	(0+3)
   1957 C0 04              6254 	push	(0+4)
   1959 C0 05              6255 	push	(0+5)
   195B C0 06              6256 	push	(0+6)
   195D C0 07              6257 	push	(0+7)
   195F C0 00              6258 	push	(0+0)
   1961 C0 01              6259 	push	(0+1)
   1963 C0 D0              6260 	push	psw
   1965 75 D0 00           6261 	mov	psw,#0x00
                           6262 ;	../../include/ztex-isr.h:382: EUSB = 0;			// block all USB interrupts
   1968 C2 E8              6263 	clr	_EUSB
                           6264 ;	../../include/ztex-isr.h:383: ep0_payload_update();
   196A 12 11 C6           6265 	lcall	_ep0_payload_update
                           6266 ;	../../include/ztex-isr.h:384: switch ( ep0_prev_setup_request ) {
   196D 90 3A 39           6267 	mov	dptr,#_ep0_prev_setup_request
   1970 E0                 6268 	movx	a,@dptr
   1971 FA                 6269 	mov	r2,a
   1972 BA 30 03           6270 	cjne	r2,#0x30,00124$
   1975 02 19 E3           6271 	ljmp	00112$
   1978                    6272 00124$:
   1978 BA 38 02           6273 	cjne	r2,#0x38,00125$
   197B 80 1E              6274 	sjmp	00101$
   197D                    6275 00125$:
   197D BA 3A 02           6276 	cjne	r2,#0x3A,00126$
   1980 80 61              6277 	sjmp	00112$
   1982                    6278 00126$:
   1982 BA 3B 02           6279 	cjne	r2,#0x3B,00127$
   1985 80 24              6280 	sjmp	00103$
   1987                    6281 00127$:
   1987 BA 3D 02           6282 	cjne	r2,#0x3D,00128$
   198A 80 57              6283 	sjmp	00112$
   198C                    6284 00128$:
   198C BA 40 02           6285 	cjne	r2,#0x40,00129$
   198F 80 52              6286 	sjmp	00112$
   1991                    6287 00129$:
   1991 BA 41 02           6288 	cjne	r2,#0x41,00130$
   1994 80 25              6289 	sjmp	00106$
   1996                    6290 00130$:
                           6291 ;	../../include/ztex-conf.h:105: case $0:
   1996 BA 43 41           6292 	cjne	r2,#0x43,00111$
   1999 80 48              6293 	sjmp	00112$
   199B                    6294 00101$:
                           6295 ;	../../include/ztex-eeprom.h:222: EP0BCH = 0;
   199B 90 E6 8A           6296 	mov	dptr,#_EP0BCH
   199E E4                 6297 	clr	a
   199F F0                 6298 	movx	@dptr,a
                           6299 ;	../../include/ztex-eeprom.h:223: EP0BCL = eeprom_read_ep0(); 
   19A0 12 05 73           6300 	lcall	_eeprom_read_ep0
   19A3 E5 82              6301 	mov	a,dpl
   19A5 90 E6 8B           6302 	mov	dptr,#_EP0BCL
   19A8 F0                 6303 	movx	@dptr,a
                           6304 ;	../../include/ztex-conf.h:107: break;
                           6305 ;	../../include/ztex-conf.h:105: case $0:
   19A9 80 38              6306 	sjmp	00112$
   19AB                    6307 00103$:
                           6308 ;	../../include/ztex-eeprom.h:371: EP0BCH = 0;
   19AB 90 E6 8A           6309 	mov	dptr,#_EP0BCH
   19AE E4                 6310 	clr	a
   19AF F0                 6311 	movx	@dptr,a
                           6312 ;	../../include/ztex-eeprom.h:372: EP0BCL = mac_eeprom_read_ep0(); 
   19B0 12 07 B9           6313 	lcall	_mac_eeprom_read_ep0
   19B3 E5 82              6314 	mov	a,dpl
   19B5 90 E6 8B           6315 	mov	dptr,#_EP0BCL
   19B8 F0                 6316 	movx	@dptr,a
                           6317 ;	../../include/ztex-conf.h:107: break;
                           6318 ;	../../include/ztex-conf.h:105: case $0:
   19B9 80 28              6319 	sjmp	00112$
   19BB                    6320 00106$:
                           6321 ;	../../include/ztex-flash2.h:679: if ( ep0_payload_transfer != 0 ) {
   19BB 90 3A 38           6322 	mov	dptr,#_ep0_payload_transfer
   19BE E0                 6323 	movx	a,@dptr
   19BF FA                 6324 	mov	r2,a
   19C0 60 08              6325 	jz	00108$
                           6326 ;	../../include/ztex-flash2.h:680: flash_ec = 0;
   19C2 90 3A 0E           6327 	mov	dptr,#_flash_ec
   19C5 E4                 6328 	clr	a
   19C6 F0                 6329 	movx	@dptr,a
                           6330 ;	../../include/ztex-flash2.h:681: spi_read_ep0(); 
   19C7 12 0C ED           6331 	lcall	_spi_read_ep0
   19CA                    6332 00108$:
                           6333 ;	../../include/ztex-flash2.h:683: EP0BCH = 0;
   19CA 90 E6 8A           6334 	mov	dptr,#_EP0BCH
   19CD E4                 6335 	clr	a
   19CE F0                 6336 	movx	@dptr,a
                           6337 ;	../../include/ztex-flash2.h:684: EP0BCL = ep0_payload_transfer;
   19CF 90 3A 38           6338 	mov	dptr,#_ep0_payload_transfer
   19D2 E0                 6339 	movx	a,@dptr
   19D3 FA                 6340 	mov	r2,a
   19D4 90 E6 8B           6341 	mov	dptr,#_EP0BCL
   19D7 F0                 6342 	movx	@dptr,a
                           6343 ;	../../include/ztex-conf.h:107: break;
                           6344 ;	../../include/ztex-isr.h:386: default:
   19D8 80 09              6345 	sjmp	00112$
   19DA                    6346 00111$:
                           6347 ;	../../include/ztex-isr.h:387: EP0BCH = 0;
   19DA 90 E6 8A           6348 	mov	dptr,#_EP0BCH
                           6349 ;	../../include/ztex-isr.h:388: EP0BCL = 0;
   19DD E4                 6350 	clr	a
   19DE F0                 6351 	movx	@dptr,a
   19DF 90 E6 8B           6352 	mov	dptr,#_EP0BCL
   19E2 F0                 6353 	movx	@dptr,a
                           6354 ;	../../include/ztex-isr.h:389: }
   19E3                    6355 00112$:
                           6356 ;	../../include/ztex-isr.h:390: EXIF &= ~bmBIT4;		// clear USB interrupt flag
   19E3 53 91 EF           6357 	anl	_EXIF,#0xEF
                           6358 ;	../../include/ztex-isr.h:391: EPIRQ = bmBIT0;		// clear EP0IN IRQ
   19E6 90 E6 5F           6359 	mov	dptr,#_EPIRQ
   19E9 74 01              6360 	mov	a,#0x01
   19EB F0                 6361 	movx	@dptr,a
                           6362 ;	../../include/ztex-isr.h:392: EUSB = 1;
   19EC D2 E8              6363 	setb	_EUSB
   19EE D0 D0              6364 	pop	psw
   19F0 D0 01              6365 	pop	(0+1)
   19F2 D0 00              6366 	pop	(0+0)
   19F4 D0 07              6367 	pop	(0+7)
   19F6 D0 06              6368 	pop	(0+6)
   19F8 D0 05              6369 	pop	(0+5)
   19FA D0 04              6370 	pop	(0+4)
   19FC D0 03              6371 	pop	(0+3)
   19FE D0 02              6372 	pop	(0+2)
   1A00 D0 83              6373 	pop	dph
   1A02 D0 82              6374 	pop	dpl
   1A04 D0 F0              6375 	pop	b
   1A06 D0 E0              6376 	pop	acc
   1A08 D0 20              6377 	pop	bits
   1A0A 32                 6378 	reti
                           6379 ;------------------------------------------------------------
                           6380 ;Allocation info for local variables in function 'EP0OUT_ISR'
                           6381 ;------------------------------------------------------------
                           6382 ;------------------------------------------------------------
                           6383 ;	../../include/ztex-isr.h:398: static void EP0OUT_ISR () __interrupt
                           6384 ;	-----------------------------------------
                           6385 ;	 function EP0OUT_ISR
                           6386 ;	-----------------------------------------
   1A0B                    6387 _EP0OUT_ISR:
   1A0B C0 20              6388 	push	bits
   1A0D C0 E0              6389 	push	acc
   1A0F C0 F0              6390 	push	b
   1A11 C0 82              6391 	push	dpl
   1A13 C0 83              6392 	push	dph
   1A15 C0 02              6393 	push	(0+2)
   1A17 C0 03              6394 	push	(0+3)
   1A19 C0 04              6395 	push	(0+4)
   1A1B C0 05              6396 	push	(0+5)
   1A1D C0 06              6397 	push	(0+6)
   1A1F C0 07              6398 	push	(0+7)
   1A21 C0 00              6399 	push	(0+0)
   1A23 C0 01              6400 	push	(0+1)
   1A25 C0 D0              6401 	push	psw
   1A27 75 D0 00           6402 	mov	psw,#0x00
                           6403 ;	../../include/ztex-isr.h:400: EUSB = 0;			// block all USB interrupts
   1A2A C2 E8              6404 	clr	_EUSB
                           6405 ;	../../include/ztex-isr.h:401: if ( ep0_vendor_cmd_setup ) {
   1A2C 90 3A 3A           6406 	mov	dptr,#_ep0_vendor_cmd_setup
   1A2F E0                 6407 	movx	a,@dptr
   1A30 FA                 6408 	mov	r2,a
   1A31 60 20              6409 	jz	00102$
                           6410 ;	../../include/ztex-isr.h:402: ep0_vendor_cmd_setup = 0;
   1A33 90 3A 3A           6411 	mov	dptr,#_ep0_vendor_cmd_setup
   1A36 E4                 6412 	clr	a
   1A37 F0                 6413 	movx	@dptr,a
                           6414 ;	../../include/ztex-isr.h:403: ep0_payload_remaining = (SETUPDAT[7] << 8) | SETUPDAT[6];
   1A38 90 E6 BF           6415 	mov	dptr,#(_SETUPDAT + 0x0007)
   1A3B E0                 6416 	movx	a,@dptr
   1A3C FB                 6417 	mov	r3,a
   1A3D 7A 00              6418 	mov	r2,#0x00
   1A3F 90 E6 BE           6419 	mov	dptr,#(_SETUPDAT + 0x0006)
   1A42 E0                 6420 	movx	a,@dptr
   1A43 FC                 6421 	mov	r4,a
   1A44 7D 00              6422 	mov	r5,#0x00
   1A46 90 3A 36           6423 	mov	dptr,#_ep0_payload_remaining
   1A49 EC                 6424 	mov	a,r4
   1A4A 4A                 6425 	orl	a,r2
   1A4B F0                 6426 	movx	@dptr,a
   1A4C ED                 6427 	mov	a,r5
   1A4D 4B                 6428 	orl	a,r3
   1A4E A3                 6429 	inc	dptr
   1A4F F0                 6430 	movx	@dptr,a
                           6431 ;	../../include/ztex-isr.h:404: ep0_vendor_cmd_su();
   1A50 12 11 F3           6432 	lcall	_ep0_vendor_cmd_su
   1A53                    6433 00102$:
                           6434 ;	../../include/ztex-isr.h:407: ep0_payload_update();
   1A53 12 11 C6           6435 	lcall	_ep0_payload_update
                           6436 ;	../../include/ztex-isr.h:409: switch ( ep0_prev_setup_request ) {
   1A56 90 3A 39           6437 	mov	dptr,#_ep0_prev_setup_request
   1A59 E0                 6438 	movx	a,@dptr
   1A5A FA                 6439 	mov	r2,a
   1A5B BA 31 02           6440 	cjne	r2,#0x31,00127$
   1A5E 80 60              6441 	sjmp	00112$
   1A60                    6442 00127$:
   1A60 BA 32 02           6443 	cjne	r2,#0x32,00128$
   1A63 80 58              6444 	sjmp	00111$
   1A65                    6445 00128$:
   1A65 BA 39 02           6446 	cjne	r2,#0x39,00129$
   1A68 80 0A              6447 	sjmp	00103$
   1A6A                    6448 00129$:
   1A6A BA 3C 02           6449 	cjne	r2,#0x3C,00130$
   1A6D 80 10              6450 	sjmp	00104$
   1A6F                    6451 00130$:
                           6452 ;	../../include/ztex-conf.h:128: case $0:			
   1A6F BA 42 4E           6453 	cjne	r2,#0x42,00112$
   1A72 80 1F              6454 	sjmp	00105$
   1A74                    6455 00103$:
                           6456 ;	../../include/ztex-eeprom.h:240: eeprom_write_ep0(EP0BCL);
   1A74 90 E6 8B           6457 	mov	dptr,#_EP0BCL
   1A77 E0                 6458 	movx	a,@dptr
   1A78 F5 82              6459 	mov	dpl,a
   1A7A 12 05 A7           6460 	lcall	_eeprom_write_ep0
                           6461 ;	../../include/ztex-conf.h:130: break;
                           6462 ;	../../include/ztex-conf.h:128: case $0:			
   1A7D 80 41              6463 	sjmp	00112$
   1A7F                    6464 00104$:
                           6465 ;	../../include/ztex-eeprom.h:382: mac_eeprom_write(EP0BUF, mac_eeprom_addr, EP0BCL);
   1A7F 90 3A 05           6466 	mov	dptr,#_mac_eeprom_addr
   1A82 E0                 6467 	movx	a,@dptr
   1A83 F5 12              6468 	mov	_mac_eeprom_write_PARM_2,a
   1A85 90 E6 8B           6469 	mov	dptr,#_EP0BCL
   1A88 E0                 6470 	movx	a,@dptr
   1A89 F5 13              6471 	mov	_mac_eeprom_write_PARM_3,a
   1A8B 90 E7 40           6472 	mov	dptr,#_EP0BUF
   1A8E 12 06 C1           6473 	lcall	_mac_eeprom_write
                           6474 ;	../../include/ztex-conf.h:130: break;
                           6475 ;	../../include/ztex-conf.h:128: case $0:			
   1A91 80 2D              6476 	sjmp	00112$
   1A93                    6477 00105$:
                           6478 ;	../../include/ztex-flash2.h:703: if ( ep0_payload_transfer != 0 ) {
   1A93 90 3A 38           6479 	mov	dptr,#_ep0_payload_transfer
   1A96 E0                 6480 	movx	a,@dptr
   1A97 FA                 6481 	mov	r2,a
   1A98 60 26              6482 	jz	00112$
                           6483 ;	../../include/ztex-flash2.h:704: flash_ec = 0;
   1A9A 90 3A 0E           6484 	mov	dptr,#_flash_ec
   1A9D E4                 6485 	clr	a
   1A9E F0                 6486 	movx	@dptr,a
                           6487 ;	../../include/ztex-flash2.h:705: spi_send_ep0();
   1A9F 12 0D 10           6488 	lcall	_spi_send_ep0
                           6489 ;	../../include/ztex-flash2.h:706: if ( flash_ec != 0 ) {
   1AA2 90 3A 0E           6490 	mov	dptr,#_flash_ec
   1AA5 E0                 6491 	movx	a,@dptr
   1AA6 FA                 6492 	mov	r2,a
   1AA7 60 17              6493 	jz	00112$
                           6494 ;	../../include/ztex-flash2.h:707: spi_deselect();
   1AA9 12 08 ED           6495 	lcall	_spi_deselect
                           6496 ;	../../include/ztex-conf.h:137: EP0CS |= 0x01;	// set stall
   1AAC 90 E6 A0           6497 	mov	dptr,#_EP0CS
   1AAF E0                 6498 	movx	a,@dptr
   1AB0 FA                 6499 	mov	r2,a
   1AB1 44 01              6500 	orl	a,#0x01
   1AB3 F0                 6501 	movx	@dptr,a
                           6502 ;	../../include/ztex-conf.h:138: ep0_payload_remaining = 0;
   1AB4 90 3A 36           6503 	mov	dptr,#_ep0_payload_remaining
   1AB7 E4                 6504 	clr	a
   1AB8 F0                 6505 	movx	@dptr,a
   1AB9 A3                 6506 	inc	dptr
   1ABA F0                 6507 	movx	@dptr,a
                           6508 ;	../../include/ztex-conf.h:139: break;
                           6509 ;	../../include/ztex-conf.h:128: case $0:			
   1ABB 80 03              6510 	sjmp	00112$
   1ABD                    6511 00111$:
                           6512 ;	../../include/ztex-fpga7.h:211: fpga_send_ep0();
   1ABD 12 0E 67           6513 	lcall	_fpga_send_ep0
                           6514 ;	../../include/ztex-isr.h:411: } 
   1AC0                    6515 00112$:
                           6516 ;	../../include/ztex-isr.h:413: EP0BCL = 0;
   1AC0 90 E6 8B           6517 	mov	dptr,#_EP0BCL
   1AC3 E4                 6518 	clr	a
   1AC4 F0                 6519 	movx	@dptr,a
                           6520 ;	../../include/ztex-isr.h:415: EXIF &= ~bmBIT4;		// clear main USB interrupt flag
   1AC5 53 91 EF           6521 	anl	_EXIF,#0xEF
                           6522 ;	../../include/ztex-isr.h:416: EPIRQ = bmBIT1;		// clear EP0OUT IRQ
   1AC8 90 E6 5F           6523 	mov	dptr,#_EPIRQ
   1ACB 74 02              6524 	mov	a,#0x02
   1ACD F0                 6525 	movx	@dptr,a
                           6526 ;	../../include/ztex-isr.h:417: if ( ep0_payload_remaining == 0 ) {
   1ACE 90 3A 36           6527 	mov	dptr,#_ep0_payload_remaining
   1AD1 E0                 6528 	movx	a,@dptr
   1AD2 FA                 6529 	mov	r2,a
   1AD3 A3                 6530 	inc	dptr
   1AD4 E0                 6531 	movx	a,@dptr
   1AD5 FB                 6532 	mov	r3,a
   1AD6 4A                 6533 	orl	a,r2
   1AD7 70 08              6534 	jnz	00114$
                           6535 ;	../../include/ztex-isr.h:418: EP0CS |= 0x80; 		// clear the HSNAK bit
   1AD9 90 E6 A0           6536 	mov	dptr,#_EP0CS
   1ADC E0                 6537 	movx	a,@dptr
   1ADD FA                 6538 	mov	r2,a
   1ADE 44 80              6539 	orl	a,#0x80
   1AE0 F0                 6540 	movx	@dptr,a
   1AE1                    6541 00114$:
                           6542 ;	../../include/ztex-isr.h:420: EUSB = 1;
   1AE1 D2 E8              6543 	setb	_EUSB
   1AE3 D0 D0              6544 	pop	psw
   1AE5 D0 01              6545 	pop	(0+1)
   1AE7 D0 00              6546 	pop	(0+0)
   1AE9 D0 07              6547 	pop	(0+7)
   1AEB D0 06              6548 	pop	(0+6)
   1AED D0 05              6549 	pop	(0+5)
   1AEF D0 04              6550 	pop	(0+4)
   1AF1 D0 03              6551 	pop	(0+3)
   1AF3 D0 02              6552 	pop	(0+2)
   1AF5 D0 83              6553 	pop	dph
   1AF7 D0 82              6554 	pop	dpl
   1AF9 D0 F0              6555 	pop	b
   1AFB D0 E0              6556 	pop	acc
   1AFD D0 20              6557 	pop	bits
   1AFF 32                 6558 	reti
                           6559 ;------------------------------------------------------------
                           6560 ;Allocation info for local variables in function 'EP1IN_ISR'
                           6561 ;------------------------------------------------------------
                           6562 ;------------------------------------------------------------
                           6563 ;	../../include/ztex-isr.h:427: void EP1IN_ISR() __interrupt
                           6564 ;	-----------------------------------------
                           6565 ;	 function EP1IN_ISR
                           6566 ;	-----------------------------------------
   1B00                    6567 _EP1IN_ISR:
   1B00 C0 E0              6568 	push	acc
   1B02 C0 82              6569 	push	dpl
   1B04 C0 83              6570 	push	dph
                           6571 ;	../../include/ztex-isr.h:429: EXIF &= ~bmBIT4;
   1B06 53 91 EF           6572 	anl	_EXIF,#0xEF
                           6573 ;	../../include/ztex-isr.h:430: EPIRQ = bmBIT2;
   1B09 90 E6 5F           6574 	mov	dptr,#_EPIRQ
   1B0C 74 04              6575 	mov	a,#0x04
   1B0E F0                 6576 	movx	@dptr,a
   1B0F D0 83              6577 	pop	dph
   1B11 D0 82              6578 	pop	dpl
   1B13 D0 E0              6579 	pop	acc
   1B15 32                 6580 	reti
                           6581 ;	eliminated unneeded push/pop psw
                           6582 ;	eliminated unneeded push/pop b
                           6583 ;------------------------------------------------------------
                           6584 ;Allocation info for local variables in function 'EP1OUT_ISR'
                           6585 ;------------------------------------------------------------
                           6586 ;------------------------------------------------------------
                           6587 ;	../../include/ztex-isr.h:437: void EP1OUT_ISR() __interrupt
                           6588 ;	-----------------------------------------
                           6589 ;	 function EP1OUT_ISR
                           6590 ;	-----------------------------------------
   1B16                    6591 _EP1OUT_ISR:
   1B16 C0 E0              6592 	push	acc
   1B18 C0 82              6593 	push	dpl
   1B1A C0 83              6594 	push	dph
                           6595 ;	../../include/ztex-isr.h:439: EXIF &= ~bmBIT4;
   1B1C 53 91 EF           6596 	anl	_EXIF,#0xEF
                           6597 ;	../../include/ztex-isr.h:440: EPIRQ = bmBIT3;
   1B1F 90 E6 5F           6598 	mov	dptr,#_EPIRQ
   1B22 74 08              6599 	mov	a,#0x08
   1B24 F0                 6600 	movx	@dptr,a
   1B25 D0 83              6601 	pop	dph
   1B27 D0 82              6602 	pop	dpl
   1B29 D0 E0              6603 	pop	acc
   1B2B 32                 6604 	reti
                           6605 ;	eliminated unneeded push/pop psw
                           6606 ;	eliminated unneeded push/pop b
                           6607 ;------------------------------------------------------------
                           6608 ;Allocation info for local variables in function 'EP2_ISR'
                           6609 ;------------------------------------------------------------
                           6610 ;------------------------------------------------------------
                           6611 ;	../../include/ztex-isr.h:446: void EP2_ISR() __interrupt
                           6612 ;	-----------------------------------------
                           6613 ;	 function EP2_ISR
                           6614 ;	-----------------------------------------
   1B2C                    6615 _EP2_ISR:
   1B2C C0 E0              6616 	push	acc
   1B2E C0 82              6617 	push	dpl
   1B30 C0 83              6618 	push	dph
                           6619 ;	../../include/ztex-isr.h:448: EXIF &= ~bmBIT4;
   1B32 53 91 EF           6620 	anl	_EXIF,#0xEF
                           6621 ;	../../include/ztex-isr.h:449: EPIRQ = bmBIT4;
   1B35 90 E6 5F           6622 	mov	dptr,#_EPIRQ
   1B38 74 10              6623 	mov	a,#0x10
   1B3A F0                 6624 	movx	@dptr,a
   1B3B D0 83              6625 	pop	dph
   1B3D D0 82              6626 	pop	dpl
   1B3F D0 E0              6627 	pop	acc
   1B41 32                 6628 	reti
                           6629 ;	eliminated unneeded push/pop psw
                           6630 ;	eliminated unneeded push/pop b
                           6631 ;------------------------------------------------------------
                           6632 ;Allocation info for local variables in function 'EP4_ISR'
                           6633 ;------------------------------------------------------------
                           6634 ;------------------------------------------------------------
                           6635 ;	../../include/ztex-isr.h:455: void EP4_ISR() __interrupt
                           6636 ;	-----------------------------------------
                           6637 ;	 function EP4_ISR
                           6638 ;	-----------------------------------------
   1B42                    6639 _EP4_ISR:
   1B42 C0 E0              6640 	push	acc
   1B44 C0 82              6641 	push	dpl
   1B46 C0 83              6642 	push	dph
                           6643 ;	../../include/ztex-isr.h:457: EXIF &= ~bmBIT4;
   1B48 53 91 EF           6644 	anl	_EXIF,#0xEF
                           6645 ;	../../include/ztex-isr.h:458: EPIRQ = bmBIT5;
   1B4B 90 E6 5F           6646 	mov	dptr,#_EPIRQ
   1B4E 74 20              6647 	mov	a,#0x20
   1B50 F0                 6648 	movx	@dptr,a
   1B51 D0 83              6649 	pop	dph
   1B53 D0 82              6650 	pop	dpl
   1B55 D0 E0              6651 	pop	acc
   1B57 32                 6652 	reti
                           6653 ;	eliminated unneeded push/pop psw
                           6654 ;	eliminated unneeded push/pop b
                           6655 ;------------------------------------------------------------
                           6656 ;Allocation info for local variables in function 'EP6_ISR'
                           6657 ;------------------------------------------------------------
                           6658 ;------------------------------------------------------------
                           6659 ;	../../include/ztex-isr.h:464: void EP6_ISR() __interrupt
                           6660 ;	-----------------------------------------
                           6661 ;	 function EP6_ISR
                           6662 ;	-----------------------------------------
   1B58                    6663 _EP6_ISR:
   1B58 C0 E0              6664 	push	acc
   1B5A C0 82              6665 	push	dpl
   1B5C C0 83              6666 	push	dph
                           6667 ;	../../include/ztex-isr.h:466: EXIF &= ~bmBIT4;
   1B5E 53 91 EF           6668 	anl	_EXIF,#0xEF
                           6669 ;	../../include/ztex-isr.h:467: EPIRQ = bmBIT6;
   1B61 90 E6 5F           6670 	mov	dptr,#_EPIRQ
   1B64 74 40              6671 	mov	a,#0x40
   1B66 F0                 6672 	movx	@dptr,a
   1B67 D0 83              6673 	pop	dph
   1B69 D0 82              6674 	pop	dpl
   1B6B D0 E0              6675 	pop	acc
   1B6D 32                 6676 	reti
                           6677 ;	eliminated unneeded push/pop psw
                           6678 ;	eliminated unneeded push/pop b
                           6679 ;------------------------------------------------------------
                           6680 ;Allocation info for local variables in function 'EP8_ISR'
                           6681 ;------------------------------------------------------------
                           6682 ;------------------------------------------------------------
                           6683 ;	../../include/ztex-isr.h:473: void EP8_ISR() __interrupt
                           6684 ;	-----------------------------------------
                           6685 ;	 function EP8_ISR
                           6686 ;	-----------------------------------------
   1B6E                    6687 _EP8_ISR:
   1B6E C0 E0              6688 	push	acc
   1B70 C0 82              6689 	push	dpl
   1B72 C0 83              6690 	push	dph
                           6691 ;	../../include/ztex-isr.h:475: EXIF &= ~bmBIT4;
   1B74 53 91 EF           6692 	anl	_EXIF,#0xEF
                           6693 ;	../../include/ztex-isr.h:476: EPIRQ = bmBIT7;
   1B77 90 E6 5F           6694 	mov	dptr,#_EPIRQ
   1B7A 74 80              6695 	mov	a,#0x80
   1B7C F0                 6696 	movx	@dptr,a
   1B7D D0 83              6697 	pop	dph
   1B7F D0 82              6698 	pop	dpl
   1B81 D0 E0              6699 	pop	acc
   1B83 32                 6700 	reti
                           6701 ;	eliminated unneeded push/pop psw
                           6702 ;	eliminated unneeded push/pop b
                           6703 ;------------------------------------------------------------
                           6704 ;Allocation info for local variables in function 'mac_eeprom_init'
                           6705 ;------------------------------------------------------------
                           6706 ;b                         Allocated to registers r2 
                           6707 ;c                         Allocated to registers r2 
                           6708 ;d                         Allocated to registers r4 
                           6709 ;buf                       Allocated with name '_mac_eeprom_init_buf_1_1'
                           6710 ;------------------------------------------------------------
                           6711 ;	../../include/ztex.h:269: void mac_eeprom_init ( ) { 
                           6712 ;	-----------------------------------------
                           6713 ;	 function mac_eeprom_init
                           6714 ;	-----------------------------------------
   1B84                    6715 _mac_eeprom_init:
                           6716 ;	../../include/ztex.h:274: mac_eeprom_read ( buf, 0, 3 );	// read signature
   1B84 75 10 00           6717 	mov	_mac_eeprom_read_PARM_2,#0x00
   1B87 75 11 03           6718 	mov	_mac_eeprom_read_PARM_3,#0x03
   1B8A 90 3A 31           6719 	mov	dptr,#_mac_eeprom_init_buf_1_1
   1B8D 12 05 D4           6720 	lcall	_mac_eeprom_read
                           6721 ;	../../include/ztex.h:275: if ( buf[0]==67 && buf[1]==68 && buf[2]==48 ) {
   1B90 90 3A 31           6722 	mov	dptr,#_mac_eeprom_init_buf_1_1
   1B93 E0                 6723 	movx	a,@dptr
   1B94 FA                 6724 	mov	r2,a
   1B95 BA 43 24           6725 	cjne	r2,#0x43,00102$
   1B98 90 3A 32           6726 	mov	dptr,#(_mac_eeprom_init_buf_1_1 + 0x0001)
   1B9B E0                 6727 	movx	a,@dptr
   1B9C FA                 6728 	mov	r2,a
   1B9D BA 44 1C           6729 	cjne	r2,#0x44,00102$
   1BA0 90 3A 33           6730 	mov	dptr,#(_mac_eeprom_init_buf_1_1 + 0x0002)
   1BA3 E0                 6731 	movx	a,@dptr
   1BA4 FA                 6732 	mov	r2,a
   1BA5 BA 30 14           6733 	cjne	r2,#0x30,00102$
                           6734 ;	../../include/ztex.h:276: config_data_valid = 1;
   1BA8 90 3A 06           6735 	mov	dptr,#_config_data_valid
   1BAB 74 01              6736 	mov	a,#0x01
   1BAD F0                 6737 	movx	@dptr,a
                           6738 ;	../../include/ztex.h:277: mac_eeprom_read ( SN_STRING, 16, 10 );	// copy serial number
   1BAE 75 10 10           6739 	mov	_mac_eeprom_read_PARM_2,#0x10
   1BB1 75 11 0A           6740 	mov	_mac_eeprom_read_PARM_3,#0x0A
   1BB4 90 00 8A           6741 	mov	dptr,#_SN_STRING
   1BB7 12 05 D4           6742 	lcall	_mac_eeprom_read
   1BBA 80 05              6743 	sjmp	00123$
   1BBC                    6744 00102$:
                           6745 ;	../../include/ztex.h:280: config_data_valid = 0;
   1BBC 90 3A 06           6746 	mov	dptr,#_config_data_valid
   1BBF E4                 6747 	clr	a
   1BC0 F0                 6748 	movx	@dptr,a
                           6749 ;	../../include/ztex.h:283: for (b=0; b<10; b++) {	// abort if SN != "0000000000"
   1BC1                    6750 00123$:
   1BC1 7A 00              6751 	mov	r2,#0x00
   1BC3                    6752 00108$:
   1BC3 BA 0A 00           6753 	cjne	r2,#0x0A,00133$
   1BC6                    6754 00133$:
   1BC6 50 12              6755 	jnc	00111$
                           6756 ;	../../include/ztex.h:284: if ( SN_STRING[b] != 48 )
   1BC8 EA                 6757 	mov	a,r2
   1BC9 24 8A              6758 	add	a,#_SN_STRING
   1BCB F5 82              6759 	mov	dpl,a
   1BCD E4                 6760 	clr	a
   1BCE 34 00              6761 	addc	a,#(_SN_STRING >> 8)
   1BD0 F5 83              6762 	mov	dph,a
   1BD2 E0                 6763 	movx	a,@dptr
   1BD3 FB                 6764 	mov	r3,a
                           6765 ;	../../include/ztex.h:285: return;
   1BD4 BB 30 54           6766 	cjne	r3,#0x30,00116$
                           6767 ;	../../include/ztex.h:283: for (b=0; b<10; b++) {	// abort if SN != "0000000000"
   1BD7 0A                 6768 	inc	r2
   1BD8 80 E9              6769 	sjmp	00108$
   1BDA                    6770 00111$:
                           6771 ;	../../include/ztex.h:288: mac_eeprom_read ( buf, 0xfb, 5 );	// read the last 5 MAC digits
   1BDA 75 10 FB           6772 	mov	_mac_eeprom_read_PARM_2,#0xFB
   1BDD 75 11 05           6773 	mov	_mac_eeprom_read_PARM_3,#0x05
   1BE0 90 3A 31           6774 	mov	dptr,#_mac_eeprom_init_buf_1_1
   1BE3 12 05 D4           6775 	lcall	_mac_eeprom_read
                           6776 ;	../../include/ztex.h:290: c=0;
   1BE6 7A 00              6777 	mov	r2,#0x00
                           6778 ;	../../include/ztex.h:291: for (b=0; b<5; b++) {	// convert to MAC to SN string
   1BE8 7B 00              6779 	mov	r3,#0x00
   1BEA                    6780 00112$:
   1BEA BB 05 00           6781 	cjne	r3,#0x05,00136$
   1BED                    6782 00136$:
   1BED 50 3C              6783 	jnc	00116$
                           6784 ;	../../include/ztex.h:292: d = buf[b];
   1BEF EB                 6785 	mov	a,r3
   1BF0 24 31              6786 	add	a,#_mac_eeprom_init_buf_1_1
   1BF2 F5 82              6787 	mov	dpl,a
   1BF4 E4                 6788 	clr	a
   1BF5 34 3A              6789 	addc	a,#(_mac_eeprom_init_buf_1_1 >> 8)
   1BF7 F5 83              6790 	mov	dph,a
   1BF9 E0                 6791 	movx	a,@dptr
   1BFA FC                 6792 	mov	r4,a
                           6793 ;	../../include/ztex.h:293: SN_STRING[c] = hexdigits[d>>4];
   1BFB EA                 6794 	mov	a,r2
   1BFC 24 8A              6795 	add	a,#_SN_STRING
   1BFE FD                 6796 	mov	r5,a
   1BFF E4                 6797 	clr	a
   1C00 34 00              6798 	addc	a,#(_SN_STRING >> 8)
   1C02 FE                 6799 	mov	r6,a
   1C03 EC                 6800 	mov	a,r4
   1C04 C4                 6801 	swap	a
   1C05 54 0F              6802 	anl	a,#0x0f
   1C07 90 1E EE           6803 	mov	dptr,#_mac_eeprom_init_hexdigits_1_1
   1C0A 93                 6804 	movc	a,@a+dptr
   1C0B FF                 6805 	mov	r7,a
   1C0C 8D 82              6806 	mov	dpl,r5
   1C0E 8E 83              6807 	mov	dph,r6
   1C10 F0                 6808 	movx	@dptr,a
                           6809 ;	../../include/ztex.h:294: c++;
   1C11 0A                 6810 	inc	r2
                           6811 ;	../../include/ztex.h:295: SN_STRING[c] = hexdigits[d & 15];
   1C12 EA                 6812 	mov	a,r2
   1C13 24 8A              6813 	add	a,#_SN_STRING
   1C15 FD                 6814 	mov	r5,a
   1C16 E4                 6815 	clr	a
   1C17 34 00              6816 	addc	a,#(_SN_STRING >> 8)
   1C19 FE                 6817 	mov	r6,a
   1C1A 74 0F              6818 	mov	a,#0x0F
   1C1C 5C                 6819 	anl	a,r4
   1C1D 90 1E EE           6820 	mov	dptr,#_mac_eeprom_init_hexdigits_1_1
   1C20 93                 6821 	movc	a,@a+dptr
   1C21 FC                 6822 	mov	r4,a
   1C22 8D 82              6823 	mov	dpl,r5
   1C24 8E 83              6824 	mov	dph,r6
   1C26 F0                 6825 	movx	@dptr,a
                           6826 ;	../../include/ztex.h:296: c++;
   1C27 0A                 6827 	inc	r2
                           6828 ;	../../include/ztex.h:291: for (b=0; b<5; b++) {	// convert to MAC to SN string
   1C28 0B                 6829 	inc	r3
   1C29 80 BF              6830 	sjmp	00112$
   1C2B                    6831 00116$:
   1C2B 22                 6832 	ret
                           6833 ;------------------------------------------------------------
                           6834 ;Allocation info for local variables in function 'init_USB'
                           6835 ;------------------------------------------------------------
                           6836 ;------------------------------------------------------------
                           6837 ;	../../include/ztex.h:345: void init_USB ()
                           6838 ;	-----------------------------------------
                           6839 ;	 function init_USB
                           6840 ;	-----------------------------------------
   1C2C                    6841 _init_USB:
                           6842 ;	../../include/ztex.h:347: USBCS |= bmBIT3;
   1C2C 90 E6 80           6843 	mov	dptr,#_USBCS
   1C2F E0                 6844 	movx	a,@dptr
   1C30 44 08              6845 	orl	a,#0x08
   1C32 F0                 6846 	movx	@dptr,a
                           6847 ;	../../include/ztex.h:349: CPUCS = bmBIT4 | bmBIT1;
   1C33 90 E6 00           6848 	mov	dptr,#_CPUCS
   1C36 74 12              6849 	mov	a,#0x12
   1C38 F0                 6850 	movx	@dptr,a
                           6851 ;	../../include/ztex.h:350: wait(2);
   1C39 90 00 02           6852 	mov	dptr,#0x0002
   1C3C 12 02 65           6853 	lcall	_wait
                           6854 ;	../../include/ztex.h:351: CKCON &= ~7;
   1C3F 53 8E F8           6855 	anl	_CKCON,#0xF8
                           6856 ;	../../include/ztex.h:380: init_fpga();
   1C42 12 0D 52           6857 	lcall	_init_fpga
                           6858 ;	../../include/ztex-fpga-flash2.h:105: fpga_flash_result= 255;
   1C45 90 3A 26           6859 	mov	dptr,#_fpga_flash_result
   1C48 74 FF              6860 	mov	a,#0xFF
   1C4A F0                 6861 	movx	@dptr,a
                           6862 ;	../../include/ztex.h:385: EA = 0;
   1C4B C2 AF              6863 	clr	_EA
                           6864 ;	../../include/ztex.h:386: EUSB = 0;
   1C4D C2 E8              6865 	clr	_EUSB
                           6866 ;	../../include/ezintavecs.h:123: INT8VEC_USB.op=0x02;
   1C4F 90 00 43           6867 	mov	dptr,#_INT8VEC_USB
   1C52 74 02              6868 	mov	a,#0x02
   1C54 F0                 6869 	movx	@dptr,a
                           6870 ;	../../include/ezintavecs.h:124: INT8VEC_USB.addrH = 0x01;
   1C55 90 00 44           6871 	mov	dptr,#(_INT8VEC_USB + 0x0001)
   1C58 74 01              6872 	mov	a,#0x01
   1C5A F0                 6873 	movx	@dptr,a
                           6874 ;	../../include/ezintavecs.h:125: INT8VEC_USB.addrL = 0xb8;
   1C5B 90 00 45           6875 	mov	dptr,#(_INT8VEC_USB + 0x0002)
   1C5E 74 B8              6876 	mov	a,#0xB8
   1C60 F0                 6877 	movx	@dptr,a
                           6878 ;	../../include/ezintavecs.h:126: INTSETUP |= 8;
   1C61 90 E6 68           6879 	mov	dptr,#_INTSETUP
   1C64 E0                 6880 	movx	a,@dptr
   1C65 44 08              6881 	orl	a,#0x08
   1C67 F0                 6882 	movx	@dptr,a
                           6883 ;	../../include/ezintavecs.h:115: $0.op=0x02;
   1C68 90 01 00           6884 	mov	dptr,#_INTVEC_SUDAV
   1C6B 74 02              6885 	mov	a,#0x02
   1C6D F0                 6886 	movx	@dptr,a
                           6887 ;	../../include/ezintavecs.h:116: $0.addrH=((unsigned short)(&$1)) >> 8;
   1C6E 7A 8C              6888 	mov	r2,#_SUDAV_ISR
   1C70 7B 12              6889 	mov	r3,#(_SUDAV_ISR >> 8)
   1C72 8B 04              6890 	mov	ar4,r3
   1C74 90 01 01           6891 	mov	dptr,#(_INTVEC_SUDAV + 0x0001)
   1C77 EC                 6892 	mov	a,r4
   1C78 F0                 6893 	movx	@dptr,a
                           6894 ;	../../include/ezintavecs.h:117: $0.addrL=(unsigned short)(&$1);
   1C79 90 01 02           6895 	mov	dptr,#(_INTVEC_SUDAV + 0x0002)
   1C7C EA                 6896 	mov	a,r2
   1C7D F0                 6897 	movx	@dptr,a
                           6898 ;	../../include/ezintavecs.h:115: $0.op=0x02;
   1C7E 90 01 04           6899 	mov	dptr,#_INTVEC_SOF
   1C81 74 02              6900 	mov	a,#0x02
   1C83 F0                 6901 	movx	@dptr,a
                           6902 ;	../../include/ezintavecs.h:116: $0.addrH=((unsigned short)(&$1)) >> 8;
   1C84 7A C5              6903 	mov	r2,#_SOF_ISR
   1C86 7B 18              6904 	mov	r3,#(_SOF_ISR >> 8)
   1C88 8B 04              6905 	mov	ar4,r3
   1C8A 90 01 05           6906 	mov	dptr,#(_INTVEC_SOF + 0x0001)
   1C8D EC                 6907 	mov	a,r4
   1C8E F0                 6908 	movx	@dptr,a
                           6909 ;	../../include/ezintavecs.h:117: $0.addrL=(unsigned short)(&$1);
   1C8F 90 01 06           6910 	mov	dptr,#(_INTVEC_SOF + 0x0002)
   1C92 EA                 6911 	mov	a,r2
   1C93 F0                 6912 	movx	@dptr,a
                           6913 ;	../../include/ezintavecs.h:115: $0.op=0x02;
   1C94 90 01 08           6914 	mov	dptr,#_INTVEC_SUTOK
   1C97 74 02              6915 	mov	a,#0x02
   1C99 F0                 6916 	movx	@dptr,a
                           6917 ;	../../include/ezintavecs.h:116: $0.addrH=((unsigned short)(&$1)) >> 8;
   1C9A 7A DB              6918 	mov	r2,#_SUTOK_ISR
   1C9C 7B 18              6919 	mov	r3,#(_SUTOK_ISR >> 8)
   1C9E 8B 04              6920 	mov	ar4,r3
   1CA0 90 01 09           6921 	mov	dptr,#(_INTVEC_SUTOK + 0x0001)
   1CA3 EC                 6922 	mov	a,r4
   1CA4 F0                 6923 	movx	@dptr,a
                           6924 ;	../../include/ezintavecs.h:117: $0.addrL=(unsigned short)(&$1);
   1CA5 90 01 0A           6925 	mov	dptr,#(_INTVEC_SUTOK + 0x0002)
   1CA8 EA                 6926 	mov	a,r2
   1CA9 F0                 6927 	movx	@dptr,a
                           6928 ;	../../include/ezintavecs.h:115: $0.op=0x02;
   1CAA 90 01 0C           6929 	mov	dptr,#_INTVEC_SUSPEND
   1CAD 74 02              6930 	mov	a,#0x02
   1CAF F0                 6931 	movx	@dptr,a
                           6932 ;	../../include/ezintavecs.h:116: $0.addrH=((unsigned short)(&$1)) >> 8;
   1CB0 7A F1              6933 	mov	r2,#_SUSP_ISR
   1CB2 7B 18              6934 	mov	r3,#(_SUSP_ISR >> 8)
   1CB4 8B 04              6935 	mov	ar4,r3
   1CB6 90 01 0D           6936 	mov	dptr,#(_INTVEC_SUSPEND + 0x0001)
   1CB9 EC                 6937 	mov	a,r4
   1CBA F0                 6938 	movx	@dptr,a
                           6939 ;	../../include/ezintavecs.h:117: $0.addrL=(unsigned short)(&$1);
   1CBB 90 01 0E           6940 	mov	dptr,#(_INTVEC_SUSPEND + 0x0002)
   1CBE EA                 6941 	mov	a,r2
   1CBF F0                 6942 	movx	@dptr,a
                           6943 ;	../../include/ezintavecs.h:115: $0.op=0x02;
   1CC0 90 01 10           6944 	mov	dptr,#_INTVEC_USBRESET
   1CC3 74 02              6945 	mov	a,#0x02
   1CC5 F0                 6946 	movx	@dptr,a
                           6947 ;	../../include/ezintavecs.h:116: $0.addrH=((unsigned short)(&$1)) >> 8;
   1CC6 7A 07              6948 	mov	r2,#_URES_ISR
   1CC8 7B 19              6949 	mov	r3,#(_URES_ISR >> 8)
   1CCA 8B 04              6950 	mov	ar4,r3
   1CCC 90 01 11           6951 	mov	dptr,#(_INTVEC_USBRESET + 0x0001)
   1CCF EC                 6952 	mov	a,r4
   1CD0 F0                 6953 	movx	@dptr,a
                           6954 ;	../../include/ezintavecs.h:117: $0.addrL=(unsigned short)(&$1);
   1CD1 90 01 12           6955 	mov	dptr,#(_INTVEC_USBRESET + 0x0002)
   1CD4 EA                 6956 	mov	a,r2
   1CD5 F0                 6957 	movx	@dptr,a
                           6958 ;	../../include/ezintavecs.h:115: $0.op=0x02;
   1CD6 90 01 14           6959 	mov	dptr,#_INTVEC_HISPEED
   1CD9 74 02              6960 	mov	a,#0x02
   1CDB F0                 6961 	movx	@dptr,a
                           6962 ;	../../include/ezintavecs.h:116: $0.addrH=((unsigned short)(&$1)) >> 8;
   1CDC 7A 1D              6963 	mov	r2,#_HSGRANT_ISR
   1CDE 7B 19              6964 	mov	r3,#(_HSGRANT_ISR >> 8)
   1CE0 8B 04              6965 	mov	ar4,r3
   1CE2 90 01 15           6966 	mov	dptr,#(_INTVEC_HISPEED + 0x0001)
   1CE5 EC                 6967 	mov	a,r4
   1CE6 F0                 6968 	movx	@dptr,a
                           6969 ;	../../include/ezintavecs.h:117: $0.addrL=(unsigned short)(&$1);
   1CE7 90 01 16           6970 	mov	dptr,#(_INTVEC_HISPEED + 0x0002)
   1CEA EA                 6971 	mov	a,r2
   1CEB F0                 6972 	movx	@dptr,a
                           6973 ;	../../include/ezintavecs.h:115: $0.op=0x02;
   1CEC 90 01 18           6974 	mov	dptr,#_INTVEC_EP0ACK
   1CEF 74 02              6975 	mov	a,#0x02
   1CF1 F0                 6976 	movx	@dptr,a
                           6977 ;	../../include/ezintavecs.h:116: $0.addrH=((unsigned short)(&$1)) >> 8;
   1CF2 7A 33              6978 	mov	r2,#_EP0ACK_ISR
   1CF4 7B 19              6979 	mov	r3,#(_EP0ACK_ISR >> 8)
   1CF6 8B 04              6980 	mov	ar4,r3
   1CF8 90 01 19           6981 	mov	dptr,#(_INTVEC_EP0ACK + 0x0001)
   1CFB EC                 6982 	mov	a,r4
   1CFC F0                 6983 	movx	@dptr,a
                           6984 ;	../../include/ezintavecs.h:117: $0.addrL=(unsigned short)(&$1);
   1CFD 90 01 1A           6985 	mov	dptr,#(_INTVEC_EP0ACK + 0x0002)
   1D00 EA                 6986 	mov	a,r2
   1D01 F0                 6987 	movx	@dptr,a
                           6988 ;	../../include/ezintavecs.h:115: $0.op=0x02;
   1D02 90 01 20           6989 	mov	dptr,#_INTVEC_EP0IN
   1D05 74 02              6990 	mov	a,#0x02
   1D07 F0                 6991 	movx	@dptr,a
                           6992 ;	../../include/ezintavecs.h:116: $0.addrH=((unsigned short)(&$1)) >> 8;
   1D08 7A 49              6993 	mov	r2,#_EP0IN_ISR
   1D0A 7B 19              6994 	mov	r3,#(_EP0IN_ISR >> 8)
   1D0C 8B 04              6995 	mov	ar4,r3
   1D0E 90 01 21           6996 	mov	dptr,#(_INTVEC_EP0IN + 0x0001)
   1D11 EC                 6997 	mov	a,r4
   1D12 F0                 6998 	movx	@dptr,a
                           6999 ;	../../include/ezintavecs.h:117: $0.addrL=(unsigned short)(&$1);
   1D13 90 01 22           7000 	mov	dptr,#(_INTVEC_EP0IN + 0x0002)
   1D16 EA                 7001 	mov	a,r2
   1D17 F0                 7002 	movx	@dptr,a
                           7003 ;	../../include/ezintavecs.h:115: $0.op=0x02;
   1D18 90 01 24           7004 	mov	dptr,#_INTVEC_EP0OUT
   1D1B 74 02              7005 	mov	a,#0x02
   1D1D F0                 7006 	movx	@dptr,a
                           7007 ;	../../include/ezintavecs.h:116: $0.addrH=((unsigned short)(&$1)) >> 8;
   1D1E 7A 0B              7008 	mov	r2,#_EP0OUT_ISR
   1D20 7B 1A              7009 	mov	r3,#(_EP0OUT_ISR >> 8)
   1D22 8B 04              7010 	mov	ar4,r3
   1D24 90 01 25           7011 	mov	dptr,#(_INTVEC_EP0OUT + 0x0001)
   1D27 EC                 7012 	mov	a,r4
   1D28 F0                 7013 	movx	@dptr,a
                           7014 ;	../../include/ezintavecs.h:117: $0.addrL=(unsigned short)(&$1);
   1D29 90 01 26           7015 	mov	dptr,#(_INTVEC_EP0OUT + 0x0002)
   1D2C EA                 7016 	mov	a,r2
   1D2D F0                 7017 	movx	@dptr,a
                           7018 ;	../../include/ezintavecs.h:115: $0.op=0x02;
   1D2E 90 01 28           7019 	mov	dptr,#_INTVEC_EP1IN
   1D31 74 02              7020 	mov	a,#0x02
   1D33 F0                 7021 	movx	@dptr,a
                           7022 ;	../../include/ezintavecs.h:116: $0.addrH=((unsigned short)(&$1)) >> 8;
   1D34 7A 00              7023 	mov	r2,#_EP1IN_ISR
   1D36 7B 1B              7024 	mov	r3,#(_EP1IN_ISR >> 8)
   1D38 8B 04              7025 	mov	ar4,r3
   1D3A 90 01 29           7026 	mov	dptr,#(_INTVEC_EP1IN + 0x0001)
   1D3D EC                 7027 	mov	a,r4
   1D3E F0                 7028 	movx	@dptr,a
                           7029 ;	../../include/ezintavecs.h:117: $0.addrL=(unsigned short)(&$1);
   1D3F 90 01 2A           7030 	mov	dptr,#(_INTVEC_EP1IN + 0x0002)
   1D42 EA                 7031 	mov	a,r2
   1D43 F0                 7032 	movx	@dptr,a
                           7033 ;	../../include/ezintavecs.h:115: $0.op=0x02;
   1D44 90 01 2C           7034 	mov	dptr,#_INTVEC_EP1OUT
   1D47 74 02              7035 	mov	a,#0x02
   1D49 F0                 7036 	movx	@dptr,a
                           7037 ;	../../include/ezintavecs.h:116: $0.addrH=((unsigned short)(&$1)) >> 8;
   1D4A 7A 16              7038 	mov	r2,#_EP1OUT_ISR
   1D4C 7B 1B              7039 	mov	r3,#(_EP1OUT_ISR >> 8)
   1D4E 8B 04              7040 	mov	ar4,r3
   1D50 90 01 2D           7041 	mov	dptr,#(_INTVEC_EP1OUT + 0x0001)
   1D53 EC                 7042 	mov	a,r4
   1D54 F0                 7043 	movx	@dptr,a
                           7044 ;	../../include/ezintavecs.h:117: $0.addrL=(unsigned short)(&$1);
   1D55 90 01 2E           7045 	mov	dptr,#(_INTVEC_EP1OUT + 0x0002)
   1D58 EA                 7046 	mov	a,r2
   1D59 F0                 7047 	movx	@dptr,a
                           7048 ;	../../include/ezintavecs.h:115: $0.op=0x02;
   1D5A 90 01 30           7049 	mov	dptr,#_INTVEC_EP2
   1D5D 74 02              7050 	mov	a,#0x02
   1D5F F0                 7051 	movx	@dptr,a
                           7052 ;	../../include/ezintavecs.h:116: $0.addrH=((unsigned short)(&$1)) >> 8;
   1D60 7A 2C              7053 	mov	r2,#_EP2_ISR
   1D62 7B 1B              7054 	mov	r3,#(_EP2_ISR >> 8)
   1D64 8B 04              7055 	mov	ar4,r3
   1D66 90 01 31           7056 	mov	dptr,#(_INTVEC_EP2 + 0x0001)
   1D69 EC                 7057 	mov	a,r4
   1D6A F0                 7058 	movx	@dptr,a
                           7059 ;	../../include/ezintavecs.h:117: $0.addrL=(unsigned short)(&$1);
   1D6B 90 01 32           7060 	mov	dptr,#(_INTVEC_EP2 + 0x0002)
   1D6E EA                 7061 	mov	a,r2
   1D6F F0                 7062 	movx	@dptr,a
                           7063 ;	../../include/ezintavecs.h:115: $0.op=0x02;
   1D70 90 01 34           7064 	mov	dptr,#_INTVEC_EP4
   1D73 74 02              7065 	mov	a,#0x02
   1D75 F0                 7066 	movx	@dptr,a
                           7067 ;	../../include/ezintavecs.h:116: $0.addrH=((unsigned short)(&$1)) >> 8;
   1D76 7A 42              7068 	mov	r2,#_EP4_ISR
   1D78 7B 1B              7069 	mov	r3,#(_EP4_ISR >> 8)
   1D7A 8B 04              7070 	mov	ar4,r3
   1D7C 90 01 35           7071 	mov	dptr,#(_INTVEC_EP4 + 0x0001)
   1D7F EC                 7072 	mov	a,r4
   1D80 F0                 7073 	movx	@dptr,a
                           7074 ;	../../include/ezintavecs.h:117: $0.addrL=(unsigned short)(&$1);
   1D81 90 01 36           7075 	mov	dptr,#(_INTVEC_EP4 + 0x0002)
   1D84 EA                 7076 	mov	a,r2
   1D85 F0                 7077 	movx	@dptr,a
                           7078 ;	../../include/ezintavecs.h:115: $0.op=0x02;
   1D86 90 01 38           7079 	mov	dptr,#_INTVEC_EP6
   1D89 74 02              7080 	mov	a,#0x02
   1D8B F0                 7081 	movx	@dptr,a
                           7082 ;	../../include/ezintavecs.h:116: $0.addrH=((unsigned short)(&$1)) >> 8;
   1D8C 7A 58              7083 	mov	r2,#_EP6_ISR
   1D8E 7B 1B              7084 	mov	r3,#(_EP6_ISR >> 8)
   1D90 8B 04              7085 	mov	ar4,r3
   1D92 90 01 39           7086 	mov	dptr,#(_INTVEC_EP6 + 0x0001)
   1D95 EC                 7087 	mov	a,r4
   1D96 F0                 7088 	movx	@dptr,a
                           7089 ;	../../include/ezintavecs.h:117: $0.addrL=(unsigned short)(&$1);
   1D97 90 01 3A           7090 	mov	dptr,#(_INTVEC_EP6 + 0x0002)
   1D9A EA                 7091 	mov	a,r2
   1D9B F0                 7092 	movx	@dptr,a
                           7093 ;	../../include/ezintavecs.h:115: $0.op=0x02;
   1D9C 90 01 3C           7094 	mov	dptr,#_INTVEC_EP8
   1D9F 74 02              7095 	mov	a,#0x02
   1DA1 F0                 7096 	movx	@dptr,a
                           7097 ;	../../include/ezintavecs.h:116: $0.addrH=((unsigned short)(&$1)) >> 8;
   1DA2 7A 6E              7098 	mov	r2,#_EP8_ISR
   1DA4 7B 1B              7099 	mov	r3,#(_EP8_ISR >> 8)
   1DA6 8B 04              7100 	mov	ar4,r3
   1DA8 90 01 3D           7101 	mov	dptr,#(_INTVEC_EP8 + 0x0001)
   1DAB EC                 7102 	mov	a,r4
   1DAC F0                 7103 	movx	@dptr,a
                           7104 ;	../../include/ezintavecs.h:117: $0.addrL=(unsigned short)(&$1);
   1DAD 90 01 3E           7105 	mov	dptr,#(_INTVEC_EP8 + 0x0002)
   1DB0 EA                 7106 	mov	a,r2
   1DB1 F0                 7107 	movx	@dptr,a
                           7108 ;	../../include/ztex.h:407: EXIF &= ~bmBIT4;
   1DB2 53 91 EF           7109 	anl	_EXIF,#0xEF
                           7110 ;	../../include/ztex.h:408: USBIRQ = 0x7f;
   1DB5 90 E6 5D           7111 	mov	dptr,#_USBIRQ
   1DB8 74 7F              7112 	mov	a,#0x7F
   1DBA F0                 7113 	movx	@dptr,a
                           7114 ;	../../include/ztex.h:409: USBIE |= 0x7f; 
   1DBB 90 E6 5C           7115 	mov	dptr,#_USBIE
   1DBE E0                 7116 	movx	a,@dptr
   1DBF FA                 7117 	mov	r2,a
   1DC0 44 7F              7118 	orl	a,#0x7F
   1DC2 F0                 7119 	movx	@dptr,a
                           7120 ;	../../include/ztex.h:410: EPIRQ = 0xff;
   1DC3 90 E6 5F           7121 	mov	dptr,#_EPIRQ
   1DC6 74 FF              7122 	mov	a,#0xFF
   1DC8 F0                 7123 	movx	@dptr,a
                           7124 ;	../../include/ztex.h:411: EPIE = 0xff;
   1DC9 90 E6 5E           7125 	mov	dptr,#_EPIE
   1DCC 74 FF              7126 	mov	a,#0xFF
   1DCE F0                 7127 	movx	@dptr,a
                           7128 ;	../../include/ztex.h:413: EUSB = 1;
   1DCF D2 E8              7129 	setb	_EUSB
                           7130 ;	../../include/ztex.h:414: EA = 1;
   1DD1 D2 AF              7131 	setb	_EA
                           7132 ;	../../include/ztex.h:333: EP$0CFG = bmBIT7 | bmBIT5;
   1DD3 90 E6 11           7133 	mov	dptr,#_EP1INCFG
   1DD6 74 A0              7134 	mov	a,#0xA0
   1DD8 F0                 7135 	movx	@dptr,a
                           7136 ;	../../include/ezregs.h:46: __endasm;
                           7137 	
   1DD9 00                 7138 	 nop
   1DDA 00                 7139 	 nop
   1DDB 00                 7140 	 nop
   1DDC 00                 7141 	 nop
                           7142 	    
                           7143 ;	../../include/ztex.h:333: EP$0CFG = bmBIT7 | bmBIT5;
   1DDD 90 E6 10           7144 	mov	dptr,#_EP1OUTCFG
   1DE0 74 A0              7145 	mov	a,#0xA0
   1DE2 F0                 7146 	movx	@dptr,a
                           7147 ;	../../include/ezregs.h:46: __endasm;
                           7148 	
   1DE3 00                 7149 	 nop
   1DE4 00                 7150 	 nop
   1DE5 00                 7151 	 nop
   1DE6 00                 7152 	 nop
                           7153 	    
                           7154 ;	../../include/ztex.h:328: ;
   1DE7 90 E6 12           7155 	mov	dptr,#_EP2CFG
   1DEA E4                 7156 	clr	a
   1DEB F0                 7157 	movx	@dptr,a
                           7158 ;	../../include/ezregs.h:46: __endasm;
                           7159 	
   1DEC 00                 7160 	 nop
   1DED 00                 7161 	 nop
   1DEE 00                 7162 	 nop
   1DEF 00                 7163 	 nop
                           7164 	    
                           7165 ;	../../include/ztex.h:328: ;
   1DF0 90 E6 13           7166 	mov	dptr,#_EP4CFG
   1DF3 E4                 7167 	clr	a
   1DF4 F0                 7168 	movx	@dptr,a
                           7169 ;	../../include/ezregs.h:46: __endasm;
                           7170 	
   1DF5 00                 7171 	 nop
   1DF6 00                 7172 	 nop
   1DF7 00                 7173 	 nop
   1DF8 00                 7174 	 nop
                           7175 	    
                           7176 ;	../../include/ztex.h:328: ;
   1DF9 90 E6 14           7177 	mov	dptr,#_EP6CFG
   1DFC E4                 7178 	clr	a
   1DFD F0                 7179 	movx	@dptr,a
                           7180 ;	../../include/ezregs.h:46: __endasm;
                           7181 	
   1DFE 00                 7182 	 nop
   1DFF 00                 7183 	 nop
   1E00 00                 7184 	 nop
   1E01 00                 7185 	 nop
                           7186 	    
                           7187 ;	../../include/ztex.h:328: ;
   1E02 90 E6 15           7188 	mov	dptr,#_EP8CFG
   1E05 E4                 7189 	clr	a
   1E06 F0                 7190 	movx	@dptr,a
                           7191 ;	../../include/ezregs.h:46: __endasm;
                           7192 	
   1E07 00                 7193 	 nop
   1E08 00                 7194 	 nop
   1E09 00                 7195 	 nop
   1E0A 00                 7196 	 nop
                           7197 	    
                           7198 ;	../../include/ztex.h:434: flash_init();
   1E0B 12 0C 2D           7199 	lcall	_flash_init
                           7200 ;	../../include/ztex.h:435: if ( !flash_enabled ) {
   1E0E 90 3A 07           7201 	mov	dptr,#_flash_enabled
   1E11 E0                 7202 	movx	a,@dptr
   1E12 FA                 7203 	mov	r2,a
   1E13 70 09              7204 	jnz	00102$
                           7205 ;	../../include/ztex.h:436: wait(250);
   1E15 90 00 FA           7206 	mov	dptr,#0x00FA
   1E18 12 02 65           7207 	lcall	_wait
                           7208 ;	../../include/ztex.h:437: flash_init();
   1E1B 12 0C 2D           7209 	lcall	_flash_init
   1E1E                    7210 00102$:
                           7211 ;	../../include/ztex.h:447: mac_eeprom_init();
   1E1E 12 1B 84           7212 	lcall	_mac_eeprom_init
                           7213 ;	../../include/ztex.h:453: fpga_configure_from_flash_init();
   1E21 12 10 50           7214 	lcall	_fpga_configure_from_flash_init
                           7215 ;	../../include/ztex.h:456: USBCS |= bmBIT7 | bmBIT1;
   1E24 90 E6 80           7216 	mov	dptr,#_USBCS
   1E27 E0                 7217 	movx	a,@dptr
   1E28 44 82              7218 	orl	a,#0x82
   1E2A F0                 7219 	movx	@dptr,a
                           7220 ;	../../include/ztex.h:457: wait(10);
   1E2B 90 00 0A           7221 	mov	dptr,#0x000A
   1E2E 12 02 65           7222 	lcall	_wait
                           7223 ;	../../include/ztex.h:459: USBCS &= ~bmBIT3;
   1E31 90 E6 80           7224 	mov	dptr,#_USBCS
   1E34 E0                 7225 	movx	a,@dptr
   1E35 54 F7              7226 	anl	a,#0xF7
   1E37 F0                 7227 	movx	@dptr,a
   1E38 22                 7228 	ret
                           7229 ;------------------------------------------------------------
                           7230 ;Allocation info for local variables in function 'main'
                           7231 ;------------------------------------------------------------
                           7232 ;------------------------------------------------------------
                           7233 ;	default.c:35: void main(void)	
                           7234 ;	-----------------------------------------
                           7235 ;	 function main
                           7236 ;	-----------------------------------------
   1E39                    7237 _main:
                           7238 ;	default.c:37: init_USB();
   1E39 12 1C 2C           7239 	lcall	_init_USB
                           7240 ;	default.c:39: if ( config_data_valid ) {
   1E3C 90 3A 06           7241 	mov	dptr,#_config_data_valid
   1E3F E0                 7242 	movx	a,@dptr
   1E40 FA                 7243 	mov	r2,a
   1E41 60 0C              7244 	jz	00104$
                           7245 ;	default.c:40: mac_eeprom_read ( (__xdata BYTE*) (productString+20), 6, 1 );
   1E43 90 1E 76           7246 	mov	dptr,#(_productString + 0x0014)
   1E46 75 10 06           7247 	mov	_mac_eeprom_read_PARM_2,#0x06
   1E49 75 11 01           7248 	mov	_mac_eeprom_read_PARM_3,#0x01
   1E4C 12 05 D4           7249 	lcall	_mac_eeprom_read
                           7250 ;	default.c:43: while (1) {	}					//  twiddle thumbs
   1E4F                    7251 00104$:
   1E4F 80 FE              7252 	sjmp	00104$
                           7253 	.area CSEG    (CODE)
                           7254 	.area CONST   (CODE)
   1E55                    7255 _fpga_flash_boot_id:
   1E55 5A                 7256 	.db #0x5A
   1E56 54                 7257 	.db #0x54
   1E57 45                 7258 	.db #0x45
   1E58 58                 7259 	.db #0x58
   1E59 42                 7260 	.db #0x42
   1E5A 53                 7261 	.db #0x53
   1E5B 01                 7262 	.db #0x01
   1E5C 01                 7263 	.db #0x01
   1E5D                    7264 _manufacturerString:
   1E5D 5A 54 45 58        7265 	.ascii "ZTEX"
   1E61 00                 7266 	.db 0x00
   1E62                    7267 _productString:
   1E62 55 53 42 2D 46 50  7268 	.ascii "USB-FPGA Module 2.01  (default)"
        47 41 20 4D 6F 64
        75 6C 65 20 32 2E
        30 31 20 20 28 64
        65 66 61 75 6C 74
        29
   1E81 00                 7269 	.db 0x00
   1E82                    7270 _configurationString:
   1E82 64 65 66 61 75 6C  7271 	.ascii "default"
        74
   1E89 00                 7272 	.db 0x00
   1E8A                    7273 _DeviceDescriptor:
   1E8A 12                 7274 	.db #0x12
   1E8B 01                 7275 	.db #0x01
   1E8C 00                 7276 	.db #0x00
   1E8D 02                 7277 	.db #0x02
   1E8E FF                 7278 	.db #0xFF
   1E8F FF                 7279 	.db #0xFF
   1E90 FF                 7280 	.db #0xFF
   1E91 40                 7281 	.db #0x40
   1E92 1A                 7282 	.db #0x1A
   1E93 22                 7283 	.db #0x22
   1E94 00                 7284 	.db #0x00
   1E95 01                 7285 	.db #0x01
   1E96 00                 7286 	.db #0x00
   1E97 00                 7287 	.db #0x00
   1E98 01                 7288 	.db #0x01
   1E99 02                 7289 	.db #0x02
   1E9A 03                 7290 	.db #0x03
   1E9B 01                 7291 	.db #0x01
   1E9C                    7292 _DeviceQualifierDescriptor:
   1E9C 0A                 7293 	.db #0x0A
   1E9D 06                 7294 	.db #0x06
   1E9E 00                 7295 	.db #0x00
   1E9F 02                 7296 	.db #0x02
   1EA0 FF                 7297 	.db #0xFF
   1EA1 FF                 7298 	.db #0xFF
   1EA2 FF                 7299 	.db #0xFF
   1EA3 40                 7300 	.db #0x40
   1EA4 01                 7301 	.db #0x01
   1EA5 00                 7302 	.db #0x00
   1EA6                    7303 _HighSpeedConfigDescriptor:
   1EA6 09                 7304 	.db #0x09
   1EA7 02                 7305 	.db #0x02
   1EA8 20                 7306 	.db #0x20
   1EA9 00                 7307 	.db #0x00
   1EAA 01                 7308 	.db #0x01
   1EAB 01                 7309 	.db #0x01
   1EAC 04                 7310 	.db #0x04
   1EAD C0                 7311 	.db #0xC0
   1EAE 32                 7312 	.db #0x32
   1EAF 09                 7313 	.db #0x09
   1EB0 04                 7314 	.db #0x04
   1EB1 00                 7315 	.db #0x00
   1EB2 00                 7316 	.db #0x00
   1EB3 02                 7317 	.db #0x02
   1EB4 FF                 7318 	.db #0xFF
   1EB5 FF                 7319 	.db #0xFF
   1EB6 FF                 7320 	.db #0xFF
   1EB7 00                 7321 	.db #0x00
   1EB8 07                 7322 	.db #0x07
   1EB9 05                 7323 	.db #0x05
   1EBA 81                 7324 	.db #0x81
   1EBB 02                 7325 	.db #0x02
   1EBC 00                 7326 	.db #0x00
   1EBD 02                 7327 	.db #0x02
   1EBE 00                 7328 	.db #0x00
   1EBF 07                 7329 	.db #0x07
   1EC0 05                 7330 	.db #0x05
   1EC1 01                 7331 	.db #0x01
   1EC2 02                 7332 	.db #0x02
   1EC3 00                 7333 	.db #0x00
   1EC4 02                 7334 	.db #0x02
   1EC5 00                 7335 	.db #0x00
   1EC6                    7336 _HighSpeedConfigDescriptor_PadByte:
   1EC6 00                 7337 	.db #0x00
   1EC7 00                 7338 	.db 0x00
   1EC8                    7339 _FullSpeedConfigDescriptor:
   1EC8 09                 7340 	.db #0x09
   1EC9 02                 7341 	.db #0x02
   1ECA 20                 7342 	.db #0x20
   1ECB 00                 7343 	.db #0x00
   1ECC 01                 7344 	.db #0x01
   1ECD 01                 7345 	.db #0x01
   1ECE 04                 7346 	.db #0x04
   1ECF C0                 7347 	.db #0xC0
   1ED0 32                 7348 	.db #0x32
   1ED1 09                 7349 	.db #0x09
   1ED2 04                 7350 	.db #0x04
   1ED3 00                 7351 	.db #0x00
   1ED4 00                 7352 	.db #0x00
   1ED5 02                 7353 	.db #0x02
   1ED6 FF                 7354 	.db #0xFF
   1ED7 FF                 7355 	.db #0xFF
   1ED8 FF                 7356 	.db #0xFF
   1ED9 00                 7357 	.db #0x00
   1EDA 07                 7358 	.db #0x07
   1EDB 05                 7359 	.db #0x05
   1EDC 81                 7360 	.db #0x81
   1EDD 02                 7361 	.db #0x02
   1EDE 40                 7362 	.db #0x40
   1EDF 00                 7363 	.db #0x00
   1EE0 00                 7364 	.db #0x00
   1EE1 07                 7365 	.db #0x07
   1EE2 05                 7366 	.db #0x05
   1EE3 01                 7367 	.db #0x01
   1EE4 02                 7368 	.db #0x02
   1EE5 40                 7369 	.db #0x40
   1EE6 00                 7370 	.db #0x00
   1EE7 00                 7371 	.db #0x00
   1EE8                    7372 _FullSpeedConfigDescriptor_PadByte:
   1EE8 00                 7373 	.db #0x00
   1EE9 00                 7374 	.db 0x00
   1EEA                    7375 _EmptyStringDescriptor:
   1EEA 04                 7376 	.db #0x04
   1EEB 03                 7377 	.db #0x03
   1EEC 00                 7378 	.db #0x00
   1EED 00                 7379 	.db #0x00
   1EEE                    7380 _mac_eeprom_init_hexdigits_1_1:
   1EEE 30 31 32 33 34 35  7381 	.ascii "0123456789ABCDEF"
        36 37 38 39 41 42
        43 44 45 46
   1EFE 00                 7382 	.db 0x00
                           7383 	.area XINIT   (CODE)
   1EFF                    7384 __xinit__ep0_payload_remaining:
   1EFF 00 00              7385 	.byte #0x00,#0x00
   1F01                    7386 __xinit__ep0_payload_transfer:
   1F01 00                 7387 	.db #0x00
   1F02                    7388 __xinit__ep0_prev_setup_request:
   1F02 FF                 7389 	.db #0xFF
   1F03                    7390 __xinit__ep0_vendor_cmd_setup:
   1F03 00                 7391 	.db #0x00
   1F04                    7392 __xinit__ISOFRAME_COUNTER:
   1F04 00 00              7393 	.byte #0x00,#0x00
   1F06 00 00              7394 	.byte #0x00,#0x00
   1F08 00 00              7395 	.byte #0x00,#0x00
   1F0A 00 00              7396 	.byte #0x00,#0x00
                           7397 	.area CABS    (ABS,CODE)
