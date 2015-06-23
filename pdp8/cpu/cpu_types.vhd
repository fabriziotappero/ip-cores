-------------------------------------------------------------------
--!
--! PDP-8 Processor
--!
--! \brief
--!      CPU Type Definitions
--!
--! \details
--!      
--!
--! \file
--!      cpu_types.vhd
--!
--! \author
--!      Rob Doyle - doyle (at) cox (dot) net
--!
--------------------------------------------------------------------
--
--  Copyright (C) 2009, 2011, 2012 Rob Doyle
--
-- This source file may be used and distributed without
-- restriction provided that this copyright statement is not
-- removed from the file and that any derivative work contains
-- the original copyright notice and the associated disclaimer.
--
-- This source file is free software; you can redistribute it
-- and/or modify it under the terms of the GNU Lesser General
-- Public License as published by the Free Software Foundation;
-- version 2.1 of the License.
--
-- This source is distributed in the hope that it will be
-- useful, but WITHOUT ANY WARRANTY; without even the implied
-- warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
-- PURPOSE. See the GNU Lesser General Public License for more
-- details.
--
-- You should have received a copy of the GNU Lesser General
-- Public License along with this source; if not, download it
-- from http://www.gnu.org/licenses/lgpl.txt
--
--------------------------------------------------------------------
--
-- Comments are formatted for doxygen
--

library ieee;                                                   --! IEEE Library
use ieee.std_logic_1164.all;                                    --! IEEE 1164
use ieee.numeric_std.all;                                       --! IEEE Numeric Standard

--
--! CPU Type Definition Package
--

package cpu_types is

    --!
    --! Type definitions common to everything.
    --!

    subtype  addr_t      is std_logic_vector( 0 to 11);         --! MA[0:11]
    subtype  xaddr_t     is std_logic_vector( 0 to 14);         --! EMA[0:2] & MA[0:11]
    subtype  data_t      is std_logic_vector( 0 to 11);         --! XD[0:11]
    subtype  ldata_t     is std_logic_vector( 0 to 12);         --! Data with Link bit
    subtype  field_t     is std_logic_vector( 0 to  2);         --! Address Field
    subtype  sf_t        is std_logic_vector( 0 to  6);         --! Save Field Type
    subtype  page_t      is std_logic_vector( 0 to  4);         --! Address Page
    subtype  word_t      is std_logic_vector( 0 to  6);         --! Address Word
    subtype  sc_t        is std_logic_vector( 0 to  4);         --! SC Reg Type
    subtype  swDATA_t    is data_t;                             --! Switch Data type
    subtype  eaeir_t     is std_logic_vector( 0 to  3);         --! EAE IR
    subtype  eae_t       is std_logic_vector( 0 to 24);         --! EAE Register
    subtype  devNUM_t    is std_logic_vector( 0 to  5);         --! IOT Device Number
    subtype  devOP_t     is std_logic_vector( 0 to  2);         --! IOT OP Code
   
    --!
    --! OPCODES
    --!

    subtype  opcode_t   is std_logic_vector(0 to  2);
    constant opAND      : opcode_t := "000";                    --! AND Opcode
    constant opTAD      : opcode_t := "001";                    --! TAD Opcode
    constant opISZ      : opcode_t := "010";                    --! ISZ Opcode
    constant opDCA      : opcode_t := "011";                    --! DCA Opcode
    constant opJMS      : opcode_t := "100";                    --! JMS Opcode
    constant opJMP      : opcode_t := "101";                    --! JMP Opcode
    constant opIOT      : opcode_t := "110";                    --! IOT Opcode
    constant opOPR      : opcode_t := "111";                    --! OPR Opcode

    --!
    --! MRI Addressing Modes
    --!

    subtype  amode_t    is std_logic_vector(0 to  1);
    constant amDZ       : amode_t := "00";                      --! Direct, Zero Page
    constant amDC       : amode_t := "01";                      --! Direct, Current Page
    constant amIZ       : amode_t := "10";                      --! Indirect, Zero Page
    constant amIC       : amode_t := "11";                      --! Indirect, Currnt Page

    --!
    --! EAE Opcodes
    --!

    constant opEAENOP   : EAEIR_t := "0000";                    --! EAE NOP Opcode
    constant opEAEACS   : EAEIR_t := "0001";                    --! EAE ACS Opcode
    constant opEAEMUY   : EAEIR_t := "0010";                    --! EAE MUY Opcode
    constant opEAEDVI   : EAEIR_t := "0011";                    --! EAE DVI Opcode
    constant opEAENMI   : EAEIR_t := "0100";                    --! EAE NMI Opcode
    constant opEAESHL   : EAEIR_t := "0101";                    --! EAE SHL Opcode
    constant opEAEASR   : EAEIR_t := "0110";                    --! EAE ASR Opcode
    constant opEAELSR   : EAEIR_t := "0111";                    --! EAE LSR Opcode
    constant opEAESCA   : EAEIR_t := "1000";                    --! EAE SCA Opcode
    constant opEAEDAD   : EAEIR_t := "1001";                    --! EAE DAD Opcode
    constant opEAEDST   : EAEIR_t := "1010";                    --! EAE DST Opcode
    constant opEAEDPSZ  : EAEIR_t := "1100";                    --! EAE DPSZ Opcode
    constant opEAEDPIC  : EAEIR_t := "1101";                    --! EAE DPIC Opcode
    constant opEAEDCM   : EAEIR_t := "1110";                    --! EAE DCM Opcode
    constant opEAESAM   : EAEIR_t := "1111";                    --! EAE SAM Opcode
    
    --!
    --! CPU Configuration
    --!

    subtype  swCPU_t    is std_logic_vector(0 to 3);
    constant swPDP8     : swCPU_t := "0000";                    --! Straight Eight
    constant swPDP8S    : swCPU_t := "0001";                    --! PDP-8/S
    constant swPDP8I    : swCPU_t := "0010";                    --! PDP-8/I
    constant swPDP8L    : swCPU_t := "0011";                    --! PDP-8/L
    constant swPDP8E    : swCPU_t := "0100";                    --! PDP-8/E/F/M
    constant swPDP8F    : swCPU_t := "0100";                    --! PDP-8/E/F/M
    constant swPDP8M    : swCPU_t := "0100";                    --! PDP-8/E/F/M
    constant swPDP8A    : swCPU_t := "0101";                    --! PDP-8/A
    constant swHD6100   : swCPU_t := "0110";                    --! HD6100
    constant swHD6120   : swCPU_t := "0111";                    --! HD6120
    
    --!
    --! Device Control (c0, c1) Pins
    --!  C1 high causes read after write
    --!  C0 high causes AC to be cleared
    --!

    subtype  devc_t     is std_logic_vector(0 to 1);
    constant devWR      : devc_t := "00";                       --! Device WR
    constant devRD      : devc_t := "01";                       --! Device Read with OR
    constant devWRCLR   : devc_t := "10";                       --! Device Write with clear
    constant devRDCLR   : devc_t := "11";                       --! Device Read with clear

    --!
    --! Bus Operation
    --!
    
    type busOP_t is (
        busopNOP,                                               --! IDLE/NOP
        busopRESET,                                             --! Reset
        busopIOCLR,                                             --! IOCLR
        busopFETCHaddr,                                         --! Instruction Fetch Addr
        busopFETCHdata,                                         --! Instruction Fetch Data
        busopWRIB,                                              --! Write with XMA     = IB
        busopRDIBaddr,                                          --! Read addr with XMA = IB
        busopRDIBdata,                                          --! Read data with XMA = IB
        busopWRIF,                                              --! Write with XMA     = IF
        busopRDIFaddr,                                          --! Read addr with XMA = IF
        busopRDIFdata,                                          --! Read data with XMA = IF
        busopWRDF,                                              --! Write with XMA     = DF
        busopRDDFaddr,                                          --! Read addr with XMA = DF
        busopRDDFdata,                                          --! Read data with XMA = DF
        busopWRZF,                                              --! Write with XMA     = 0
        busopRDZFaddr,                                          --! Read addr with XMA = 0
        busopRDZFdata,                                          --! Read data with XMA = 0
        busopWRIOT,                                             --! IOT Write
        busopRDIOT                                              --! IOT Read
    );
    
    --!
    --! Options Configuration
    --!
    
    type swOPT_t is record
        KE8             : std_logic;                            --! KE8 - Extended Arithmetic Element Provided
        KM8E            : std_logic;                            --! KM8E - Extended Memory Provided
        TSD             : std_logic;                            --! Time Share Disable
        SP0             : std_logic;                            --! Spare 0
        SP1             : std_logic;                            --! Spare 1
        SP2             : std_logic;                            --! Spare 2
        SP3             : std_logic;                            --! Spare 3
        STARTUP         : std_logic;                            --! Boot to Panel Mode (HD6120)
    end record;                 

    --!
    --! Registers
    --!

    type regs_t is record
        PC              : data_t;                               --! PC Register
        AC              : data_t;                               --! AC Register
        IR              : data_t;                               --! IR Register
        MA              : data_t;                               --! MA Register
        MD              : data_t;                               --! MD Register
        MQ              : data_t;                               --! MQ Register
        ST              : data_t;                               --! ST Register
        SC              : data_t;                               --! SC Register
        XMA             : field_t;                              --! XMA Register
    end record;   

    --!
    --! Bus Signals
    --!

    type bus_t is record
        addr            : addr_t;                               --! Address Bus Output
        eaddr           : field_t;                              --! Extended Address
        data            : data_t;                               --! Data Bus Output
        ioclr           : std_logic;                            --! IO Clear
        dataf           : std_logic;                            --! Data Field
        ifetch          : std_logic;                            --! Instruction Fetch
        memsel          : std_logic;                            --! Asserted during memory operations
        rd              : std_logic;                            --! Read
        wr              : std_logic;                            --! Write
        lxpar           : std_logic;                            --! Load Panel Address Register
        lxmar           : std_logic;                            --! Load Memory Address Register
        lxdar           : std_logic;                            --! Load Device Address Register
        dmagnt          : std_logic;                            --! DMA Grant
        intgnt          : std_logic;                            --! INT Grant
    end record;
    
    --!
    --! CPU Output Bus
    --!
    
    type cpu_t is record
        regs            : regs_t;                               --! Registers
        buss            : bus_t;                                --! Bus Signals
        run             : std_logic;                            --! Run
    end record;   

    --!
    --! Device DMA Output(s)
    --!

    type dma_t is record
        req             : std_logic;                            --! DMA Request
        rd              : std_logic;                            --! DMA Read
        wr              : std_logic;                            --! DMA Write
        memsel          : std_logic;                            --! DMA Memsel
        lxmar           : std_logic;                            --! DMA LXMAR
        lxpar           : std_logic;                            --! DMA LXPAR
        addr            : addr_t;                               --! DMA Address
        eaddr           : field_t;                              --! Extended Address
    end record;

    constant nullDMA    : dma_t := ('0', '0', '0', '0', '0', '0',
                                    (others => '0'), (others => '0'));
    
    --!
    --! Device Output Bus
    --!
    
    type dev_t is record
        ack             : std_logic;                            --! Bus Ack
        data            : data_t;                               --! Data Out
        devc            : devc_t;                               --! Device Control
        skip            : std_logic;                            --! Skip
        cpreq           : std_logic;                            --! Control Panel Request
        intr            : std_logic;                            --! Interrupt Request
        dma             : dma_t;                                --! DMA
    end record;
    
    constant nullDEV    : dev_t := ('0', (others => '0'), devWR, '0', '0', '0', nullDMA);

    --!
    --! Control Switches
    --!
    
    type swCNTL_t is record
        boot            : std_logic;                            --! Boot Switch
        lock            : std_logic;                            --! Panel Lock Switch
        loadADDR        : std_logic;                            --! Load Address Switch
        loadEXTD        : std_logic;                            --! Load Extended Address Switch
        clear           : std_logic;                            --! Clear Switch
        cont            : std_logic;                            --! Continue Switch
        exam            : std_logic;                            --! Examine Switch
        halt            : std_logic;                            --! Halt Switch
        step            : std_logic;                            --! Single Step Switch
        dep             : std_logic;                            --! Deposit Switch
    end record;

    --!
    --! System stuff
    --!
    
    type sys_t is record
        clk             : std_logic;                            --! Clock
        rst             : std_logic;                            --! Async: Reset
    end record;        
    
    --!
    --! AC Operations
    --!
    
    type acOP_t is (
        acopNOP,                        --! LAC <- LAC
        acopIAC,                        --! IAC
        acopBSW,                        --! BSW
        acopRAL,                        --! RAL
        acopRTL,                        --! RTL
        acopR3L,                        --! R3L (HD6120 only)
        acopRAR,                        --! RAR
        acopRTR,                        --! RTR
        acopSHL0,                       --! LAC <- (LAC << 1) & '0'
        acopSHL1,                       --! LAC <- (LAC << 1) & '1'
        acopLSR,                        --! LAC <- '0' & (LAC >> 1)
        acopASR,                        --! LAC <-  L  & (LAC >> 1)
        acopUNDEF1,                     --! RAL RAR
        acopUNDEF2,                     --! RTL RTR
        acopPC,                         --! PC
        acopCML,                        --!  0   0   0  CML
        acopCMA,                        --!  0   0  CMA  0
        acopCMACML,                     --!  0   0  CMA CML
        acopCLL,                        --!  0  CLL  0   0
        acopCLLCML,                     --!  0  CLL  0  CML
        acopCLLCMA,                     --!  0  CLL CMA  0
        acopCLLCMACML,                  --!  0  CLL CMA CML
        acopCLA,                        --! CLA  0   0   0
        acopCLACML,                     --! CLA  0   0  CML    
        acopCLACMA,                     --! CLA  0  CMA  0
        acopCLACMACML,                  --! CLA  0  CMA CML
        acopCLACLL,                     --! CLA CLL  0   0
        acopCLACLLCML,                  --! CLA CLL  0  CML
        acopCLACLLCMA,                  --! CLA CLL CMA  0
        acopCLACLLCMACML,               --! CLA CLL CMA CML
        acopRDF0,                       --! RDF0 (HD6120)
        acopRIF0,                       --! RIF0 (HD6120)
        acopRIB0,                       --! RIB0 (HD6120)
        acopRDF1,                       --! RDF1 (PDP8)
        acopRIF1,                       --! RIF1 (PDP8)
        acopRIB1,                       --! RIB1 (PDP8)
        acopPRS,                        --!
        acopGTF1,                       --! HD6120 GTF
        acopGTF2,                       --! PDP8 GTF
        acopGCF,                        --!
        acopEAELAC,                     --! LAC <- EAE(0 to 12)
        acopEAEZAC,                     --! LAC <- '0' & EAE(1 to 12)
        acopSUBMD,                      --! LAC <- LAC - MD
        acopADDMD,                      --! LAC <- LAC + MD
        acopADDMDP1,                    --! LAC <- LAC + MD + 1
        acopANDMD,                      --! LAC <- L & (AC and MD)
        acopORMD,                       --! LAC <- L & (AC or MD)
        acopMQSUB,                      --! LAC <- MQ - AC
        acopMQ,                         --! LAC <- L & MQ
        acopZMQ,                        --! LAC <- '0' & MQ
        acopMQP1,                       --! LAC <- MQ + 1
        acopNEGMQ,                      --! LAC <- -MQ
        acopNOTMQ,                      --! LAC <- not(MQ)
        acopORMQ,                       --! LAC <- L & (AC or MQ)
        acopSCA,                        --! LAC <- L & (AC or SC)
        acopSP1,                        --! LAC <- '0' & SP1
        acopSP2,                        --! LAC <- '0' & SP2
        acopLAS,                        --! LAC <- L & SR
        acopOSR                         --! LAC <- L & (AC or SR)
    );

    --!
    --! BTSTRP Operation
    --!
    
    type btstrpOP_t is (
        btstrpopNOP,                    --! BTSTRP <- BTSTRP
        btstrpopCLR,                    --! BTSTRP <- '0'
        btstrpopSET                     --! BTSTRP <- '1'
    );

    --!
    --! CTRLFF Operation
    --!
    
    type ctrlffOP_t is (
        ctrlffopNOP,                    --! CTRLFF <- CTRLFF
        ctrlffopCLR,                    --! CTRLFF <- '0'
        ctrlffopSET                     --! CTRLFF <- '1'
    );

    --!
    --! Data Field Operation
    --!
    
    type dfOP_t is (
        dfopNOP,                        --! DF <- DF
        dfopCLR,                        --! DF <- "000"
        dfopAC9to11,                    --! DF <- AC(9 to 11)
        dfopIR6to8,                     --! DF <- IR(6 to  8)
        dfopSF4to6,                     --! DF <- SF(4 to  6)
        dfopSR9to11                     --! DF <- SR(9 to 11)
    );

    --!
    --! EAE Mode
    --!

    type eaeOP_t is (
        eaeopNOP,                       --! EAE <- EAE
        eaeopMUY                        --! EAE <- (MQ * MD) + AC;
      --eaeopASRMD,                     --! EAE ASR MD
      --eaeopLSRMD,                     --! EAE LSR MD
      --eaeopSHLMD                      --! EAE SHL MD
    );
    
    --!
    --! EAE Mode operation
    --!
    
    type emodeOP_t is (
        emodeopNOP,                     --! eaeModeA <- eaeModeA
        emodeopCLR,                     --! eaeModeA <- '0'
        emodeopSET                      --! eaeModeA <- '1'
    );
    
    --!
    --! Force Zero Operation
    --!
    
    type fzOP_t is (
        fzopNOP,                        --! FZ <- FZ
        fzopCLR,                        --! FZ <- '0'
        fzopSET                         --! FZ <- '1'
    );

    --!
    --! Greater Than Flag Operation
    --!
    
    type gtfOP_t is (
        gtfopNOP,                       --! GT <- GT
        gtfopCLR,                       --! GT <- '0'
        gtfopSET,                       --! GT <- '1'
        gtfopAC1                        --! GT <- AC(1)
    );

    --!
    --! Halt Trap Operation
    --!
    
    type hlttrpOP_t is (
        hlttrpopNOP,                    --! HLTTRP <- HLTTRP
        hlttrpopCLR,                    --! HLTTRP <- '0'
        hlttrpopSET                     --! HLTTRP <- '1'
    );

    --!
    --! Interrupt Enable Delay Operation
    --!
    
    type idOP_t is (
        idopNOP,                        --! ID <- II
        idopCLR,                        --! ID <- '0'
        idopSET                         --! ID <- '1'
    );
    
    --!
    --! Interrupt Enable Operation
    --!
    
    type ieOP_t is (
        ieopNOP,                        --! IE <- IE
        ieopCLR,                        --! IE <- '0'
        ieopSET                         --! IE <- '1'
    );

    --!
    --! Interrupt Inhibit Operation
    --!
    
    type iiOP_t is (
        iiopNOP,                        --! II <- II
        iiopCLR,                        --! II <- '0'
        iiopSET                         --! II <- '1'
    );

    --!
    --! IB Operation
    --!
    
    type ibOP_t is (
        ibopNOP,                        --! IB <- INB
        ibopCLR,                        --! IB <- "000"
        ibopAC6to8,                     --! IB <- AC(6 to 8)
        ibopIR6to8,                     --! IB <- IR(6 to 8)
        ibopSF1to3                      --! IB <- SF(1 to 3)
    );

    --!
    --! IF Operation
    --!
    
    type ifOP_t is (
        ifopNOP,                        --! IF <- IF
        ifopCLR,                        --! IF <- "000"
        ifopIB,                         --! IF <- IB
        ifopSR6to8                      --! IF <- SR(6 to 8)
    );

    --!
    --! Instruction Register Operation
    --!
    
    type irOP_t is (
        iropNOP,                        --! IR <- IR
        iropMD                          --! IR <- MD (Fetch)
    );

    --!
    --! Memory Address operations
    --!
    
    type maOP_t is (
        maopNOP,                        --! MA <- MA
        maop0000,                       --! MA <- o"0000"
        maopINC,                        --! MA <- MA + 1
        maopZP,                         --! MA <- zeroPage & IR(5 to 11)
        maopCP,                         --! MA <- currPage & IR(5 to 11)
        maopIR,                         --! MA <- IR
        maopPC,                         --! MA <- PC
        maopPCP1,                       --! MA <- PC + 1
        maopMB,                         --! MA <- MB
        maopMD,                         --! MA <- MD
        maopMDP1,                       --! MA <- MD + 1
        maopSP1,                        --! MA <- SP1
        maopSP1P1,                      --! MA <- SP1 + 1
        maopSP2,                        --! MA <- SP2
        maopSP2P1,                      --! MA <- SP2 + 1
        maopSR                          --! MA <- SR
    );

    --!
    --! Memory Buffer operation
    --!
    
    type mbOP_t is (
        mbopNOP,                        --! MB <- MB
        mbopAC,                         --! MB <- AC
        mbopMA,                         --! MB <- MA
        mbopMD,                         --! MB <- MD
        mbopMQ,                         --! MB <- MQ
        mbopMDP1,                       --! MB <- MD + 1
        mbopPC,                         --! MB <- PC
        mbopPCP1,                       --! MB <- PC + 1
        mbopSR                          --! MB <- SR
    );

    --!
    --! Multiplier/Quotient Operations
    --!
    
    type mqOP_t is (
        mqopNOP,                        --! MQ <- MQ
        mqopCLR,                        --! MQ <- "0000"
        mqopSET,                        --! MQ <- "7777"
        mqopSHL0,                       --! MQ <- (MQ << 1) + 0
        mqopSHL1,                       --! MQ <- (MQ << 1) + 1
        mqopAC,                         --! MQ <- AC
        mqopMD,                         --! MQ <- MD
        mqopADDMD,                      --! MQ <- MQ + MD
        mqopACP1,                       --! MQ <- AC + 1
        mqopNEGAC,                      --! MQ <- -AC
        mqopEAE,                        --! MQ <- low(EAE)
        mqopSHR0,                       --! MQ <- '0' & MQ(0 to 10)
        mqopSHR1                        --! MQ <- '1' & MQ(0 to 10)
    );

    --!
    --! MQA Operations
    --!

    type mqaOP_t is (
        mqaopNOP,                       --! MQA <- MQA
        mqaopCLR,                       --! MQA <- "0000"
        mqaopMQ,                        --! MQA <- MQ
        mqaopSHL                        --! MQA <- (MQA << 1)
    );
    
    --!
    --! Program Counter Operations
    --!

    type pcOP_t is (
        pcopNOP,                        --! PC <- PC
        pcop0000,                       --! PC <- "0000"
        pcop0001,                       --! PC <- "0001"
        pcop7777,                       --! PC <- "7777"
        pcopINC,                        --! PC <- PC + 1
        pcopMA,                         --! PC <- MA
        pcopMAP1,                       --! PC <- MA + 1
        pcopMB,                         --! PC <- MB
        pcopMBP1,                       --! PC <- MB + 1
        pcopMD,                         --! PC <- MD
        pcopMDP1,                       --! PC <- MD + 1
        pcopSR,                         --! PC <- SR
        pcopZP,                         --! PC <- "00000"     & IR(5 to 11)
        pcopCP,                         --! PC <- MA(0 to 4)  & IR(5 to 11) 
        pcopZPP1,                       --! PC <- ("00000"    & IR(5 to 11)) + "1"
        pcopCPP1                        --! PC <- (MA(0 to 4) & IR(5 to 11)) + "1"
    );

    --!
    --! Panel Data Flag Operation
    --!
    
    type pdfOP_t is (
        pdfopNOP,                       --! PDF <- PDF
        pdfopCLR,                       --! PDF <- '0'
        pdfopSET                        --! PDF <- '1'
    );

    --!
    --! Panel Execute Operation
    --!
    
    type pexOP_t is (
        pexopNOP,                       --! PEXFF <- PEXFF
        pexopCLR,                       --! PEXFF <- '0'
        pexopSET                        --! PEXFF <- '1'
    );

    --!
    --! Panel Trap Operation
    --!
    
    type pnltrpOP_t is (
        pnltrpopNOP,                    --! PNLTRP <- PNLTRP
        pnltrpopCLR,                    --! PNLTRP <- '0'
        pnltrpopSET                     --! PNLTRP <- '1'
    );
    
    --!
    --! Power-up Trap Operation
    --!
    
    type pwrtrpOP_t is ( 
        pwrtrpopNOP,                    --! PWRTRP <- PWRTRP
        pwrtrpopCLR,                    --! PWRTRP <- '0'
        pwrtrpopSET                     --! PWRTRP <- '1'
    );

    --!
    --! Shift Count Operation
    --!

    type scOP_t is (
        scopNOP,                        --! SC <- SP
        scopCLR,                        --! SC <- "00000"
        scopSET,                        --! SC <- "11111"
        scop12,                         --! SC <- "01100"
        scopAC7to11,                    --! SC <- AC(7 to 11)
        scopMD7to11,                    --! SC <- MD(7 to 11)
        scopNOTMD7to11,                 --! SC <- not(MD(7 to 11))
        scopINC,                        --! SC <- SC + 1
        scopDEC,                        --! SC <- SC - 1
        scopMDP1                        --! SC <- MD(7 to 11) + 1
    );    
    
    --!
    --! Stack Pointer Operation
    --!
    
    type spOP_t is (
        spopNOP,                        --! SP <- SP
        spopCLR,                        --! SP <- o"0000"
        spopAC,                         --! SP <- AC
        spopINC,                        --! SP <- SP + 1
        spopDEC                         --! SP <- SP - 1
    );

    --!
    --! User Buffer Operations
    --!

    type ubOP_t is (
        ubopNOP,
        ubopCLR,
        ubopSET,
        ubopAC5,                        --! UB <- AC(5)
        ubopSF                          --! UB <- SF
    );

    --!
    --! User Flag Operations
    --!

    type ufOP_t is (
        ufopNOP,                        --! UF <- UF
        ufopCLR,                        --! UF <- '0'
        ufopSET,                        --! UF <- '1'
        ufopUB                          --! UF <- UB
    );

    --!
    --! Save Flags Operations
    --!

    type sfOP_t is (
        sfopNOP,                        --! SF <- SF
        sfopUBIBDF                      --! SF <- UB & IB & DF
    );

    --!
    --! Switch Register Operations
    --!
    
    type srOP_t is (
        sropNOP,                        --! SR <- SR
        sropAC                          --! SR <- AC
    );
    
    --!
    --! User Mode Trap Operation
    --!

    type usrtrpOP_t is (
        usrtrpopNOP,                    --! USRTRP <- USRTRP
        usrtrpopCLR,                    --! USRTRP <- '0'
        usrtrpopSET                     --! USRTRP <- '1'
    );
    
    --!
    --! Extended Memory Address Operations
    --!

    type xmaOP_t is (
        xmaopNOP,                       --! XMA <- XMA
        xmaopCLR,                       --! XMA <- "000"
        xmaopDF,                        --! XMA <- DF
        xmaopIF,                        --! XMA <- IF/INF
        xmaopIB                         --! XMA <- IB
    );
    
end cpu_types;
