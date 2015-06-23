------------------------------------------------------------------
--!
--! PDP-8 Processor
--!
--! \brief
--!      CPU Arithmetic Logic Unit (ALU) Register
--!
--! \details
--!      The ALU 'owns' the Link Register (L) and Accumulator
--!      Register (AC).  This device performs every operation
--!      that manipules either the Link Register or Accumulator.
--!
--!      This code operates on the Link Register and Accumulator
--!      as if it were a single 13-bit wide register.  The Link
--!      Register is LAC(0) while the Accumlator is LAC(1 to 12).
--!
--! \todo
--!      Although the CPU is knitted together with a 'rats nest'
--!      of interconnections, this file is 'rattier' than most.
--!      It could stand a good cleanup.   Any cleanup should also
--!      address EAE and how that fits with the ALU.
--!
--! \file
--!      alu.vhd
--!
--! \author
--!      Rob Doyle - doyle (at) cox (dot) net
--!
--------------------------------------------------------------------
--
--  Copyright (C) 2009, 2010, 2011, 2012 Rob Doyle
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

library ieee;                                   --! IEEE Library
use ieee.std_logic_1164.all;                    --! IEEE 1164
use ieee.numeric_std.all;                       --! IEEE Numeric Standard
use work.cpu_types.all;                         --! Types

--
--! CPU Arithmetic Logic Unit (ALU) Register Entity
--

entity eALU is port (
    sys    : in  sys_t;                         --! Clock/Reset
    acOP   : in  acOP_t;                        --! AC Operation
    BTSTRP : in  std_logic;                     --! Bootstrap Flag
    GTF    : in  std_logic;                     --! Greater Than Flag
    HLTTRP : in  std_logic;                     --! Hlttrp Flag
    IE     : in  std_logic;                     --! Interrupt Enable Flip-Flop
    IRQ    : in  std_logic;                     --! Interrupt Request flag
    PNLTRP : in  std_logic;                     --! Panel Trap Flag
    PWRTRP : in  std_logic;                     --! Power-on Trap Flag
    DF     : in  field_t;                       --! DF Input
    EAE    : in  eae_t;                         --! EAE Input
    INF    : in  field_t;                       --! INF Input
    IR     : in  data_t;                        --! IR Input
    MA     : in  addr_t;                        --! MA Input
    MD     : in  data_t;                        --! MB Input
    MQ     : in  data_t;                        --! MQ Input
    PC     : in  addr_t;                        --! PC Input
    SC     : in  sc_t;                          --! SC Input
    SF     : in  sf_t;                          --! SF Input
    SP1    : in  addr_t;                        --! SP1 Input
    SP2    : in  addr_t;                        --! SP2 Input
    SR     : in  data_t;                        --! SR Input
    UF     : in  std_logic;                     --! UF Input
    LAC    : out ldata_t                        --! ALU Output
);
end eALU;

--
--! CPU Arithmetic Logic Unit (ALU) Register RTL
--

architecture rtl of eALU is

    signal   lacREG         : ldata_t;          --! Link and Accumulator Register
    signal   lacMUX         : ldata_t;          --! Link and Accumulator Multiplexer
    
    --!
    --! ALU Operations
    --!
       
    signal   opIAC          : ldata_t;          --! Increment accumulator
    signal   opBSW          : ldata_t;          --! Byte swap
    signal   opRAL          : ldata_t;          --! 
    signal   opRTL          : ldata_t;          --! 
    signal   opR3L          : ldata_t;          --! 
    signal   opRAR          : ldata_t;          --! 
    signal   opRTR          : ldata_t;          --! 
    signal   opSHL0         : ldata_t;          --! 
    signal   opSHL1         : ldata_t;          --! 
    signal   opLSR          : ldata_t;          --! 
    signal   opASR          : ldata_t;          --!
    signal   opUNDEF1       : ldata_t;          --! Undefined Operation #1
    signal   opUNDEF2       : ldata_t;          --! Undefined Operation #2
    signal   opPC           : ldata_t;          --! Undefined Operation #1,2
    signal   opCML          : ldata_t;          --! 
    signal   opCMA          : ldata_t;          --! 
    signal   opCMACML       : ldata_t;          --! 
    signal   opCLL          : ldata_t;          --! 
    signal   opCLLCML       : ldata_t;          --! 
    signal   opCLLCMA       : ldata_t;          --! 
    signal   opCLLCMACML    : ldata_t;          --! 
    signal   opCLA          : ldata_t;          --! 
    signal   opCLACML       : ldata_t;          --! 
    signal   opCLACMA       : ldata_t;          --! 
    signal   opCLACMACML    : ldata_t;          --! 
    signal   opCLACLL       : ldata_t;          --! 
    signal   opCLACLLCML    : ldata_t;          --! 
    signal   opCLACLLCMA    : ldata_t;          --! 
    signal   opCLACLLCMACML : ldata_t;          --! 

    --!
    --! KM8E
    --!

    signal   opRDF0         : ldata_t;          --! RDF0 (HD6120)
    signal   opRIF0         : ldata_t;          --! RIF0 (HD6120)
    signal   opRIB0         : ldata_t;          --! RIB0 (HD6120)
    signal   opRDF1         : ldata_t;          --! RDF1 (PDP8)
    signal   opRIF1         : ldata_t;          --! RIF1 (PDP8)
    signal   opRIB1         : ldata_t;          --! RIB1 (PDP8)

    --!
    --! EAE
    --!

    signal   opEAELAC       : ldata_t;          --! LAC <- EAE(0 to 12)
    signal   opEAEZAC       : ldata_t;          --! LAC <- '0' & EAE(1 to 12)
      
    --!
    --! Flags
    --!

    signal   opPRS          : ldata_t;          --!
    signal   opGTF1         : ldata_t;          --!
    signal   opGTF2         : ldata_t;          --!
    signal   opGCF          : ldata_t;          --!
    
    --!
    --! MD operations
    --!

    signal   opSUBMD        : ldata_t;          --! LAC <- LAC - MD
    signal   opADDMD        : ldata_t;          --! LAC <- LAC + MD
    signal   opADDMDP1      : ldata_t;          --! LAC <- LAC + MD + 1
    signal   opANDMD        : ldata_t;          --! LAC <- L & (AC and MD)
    signal   opORMD         : ldata_t;          --! LAC <- L & (AC or  MD)
    
    --!
    --! MQ Operations
    --!

    signal   opMQSUB        : ldata_t;          --! LAC <- MQ - AC
    signal   opMQ           : ldata_t;          --! LAC <- L & MQ
    signal   opZMQ          : ldata_t;          --! LAC <- '0' & MQ
    signal   opMQP1         : ldata_t;          --! LAC <-  MQ + 1
    signal   opNEGMQ        : ldata_t;          --! LAC <- -MQ
    signal   opNOTMQ        : ldata_t;          --! LAC <- not(MQ)
    signal   opORMQ         : ldata_t;          --! LAC <- L & (AC or MQ)

    --!
    --! SC Operations
    --!
    
    signal   opSCA          : ldata_t;          --! LAC <- L & (AC or  SC)

    --!
    --! SP Operations
    --!

    signal   opSP1          : ldata_t;          --! LAC <- '0' & SP1
    signal   opSP2          : ldata_t;          --! LAC <- '0' & SP2
   
    --!
    --! SR Operations
    --!

    signal   opOSR          : ldata_t;          --! LAC <- L & (AC or SR)
    signal   opLAS          : ldata_t;          --! LAC <- L & SR

begin

    -- group1 sequence 4 operations
    opIAC           <= std_logic_vector(unsigned(lacREG) + "1");
    opBSW           <= lacREG(0) & lacREG(7 to 12) & lacREG(1 to 6);
    -- rotate lefts
    opRAL           <= lacREG( 1 to 12) & lacREG(0);
    opRTL           <= lacREG( 2 to 12) & lacREG(0 to 1);
    opR3L           <= lacREG( 3 to 12) & lacREG(0 to 2);
    -- rotate rights
    opRAR           <= lacREG(12)       & lacREG(0 to 11);
    opRTR           <= lacREG(11 to 12) & lacREG(0 to 10);
    -- shift lefts
    opSHL0          <= lacREG( 1 to 12) & '0';
    opSHL1          <= lacREG( 1 to 12) & '1';
    -- shift rights
    opLSR           <= '0' & lacREG(0 to 11);
    opASR           <= lacREG(1) & lacREG(1) & lacREG(1 to 11);
    -- undefs
    opUNDEF1        <= lacREG(0) & (lacREG(1 to 12) and IR);
    opUNDEF2        <= lacREG(0) & MA(0 to 4) & IR(5 to 11);
    opPC            <= lacREG(0) & PC;
    -- group 1 operations
    opCML           <= not(lacREG(0)) &     lacREG(1 to 12);
    opCMA           <=     lacREG(0)  & not(lacREG(1 to 12));
    opCMACML        <= not(lacREG(0)) & not(lacREG(1 to 12));
    opCLL           <= '0'            &     lacREG(1 to 12);
    opCLLCML        <= '1'            &     lacREG(1 to 12);
    opCLLCMA        <= '0'            & not(lacREG(1 to 12));
    opCLLCMACML     <= '1'            & not(lacREG(1 to 12));
    opCLA           <=     lacREG(0)  & o"0000";
    opCLACML        <= not(lacREG(0)) & o"0000";
    opCLACMA        <=     lacREG(0)  & o"7777";
    opCLACMACML     <= not(lacREG(0)) & o"7777";
    opCLACLL        <= '0'            & o"0000";
    opCLACLLCML     <= '1'            & o"0000";
    opCLACLLCMA     <= '0'            & o"7777";
    opCLACLLCMACML  <= '1'            & o"7777";
    -- KM8E ops
    opRDF0          <= lacREG(0 to  6) & DF  & lacREG(10 to 12);
    opRIF0          <= lacREG(0 to  6) & INF & lacREG(10 to 12);
    opRIB0          <= lacREG(0 to  5) & SF;
    opRDF1          <= lacREG(0 to 12) or ("0000000" & DF  & "000");
    opRIF1          <= lacREG(0 to 12) or ("0000000" & INF & "000");
    opRIB1          <= lacREG(0 to 12) or ("000000"  & SF);
    -- Flags
    opPRS           <= lacREG(0) & BTSTRP    & PNLTRP & IRQ & PWRTRP & HLTTRP & '0'   & "000"      & "000";
    opGTF1          <= lacREG(0) & lacREG(0) & GTF    & IRQ & PWRTRP & '1'    & '0'   & SF(1 to 3) & SF(4 to 6);
    opGTF2          <= lacREG(0) & lacREG(0) & GTF    & IRQ &  '0'   & IE     & SF(0) & SF(1 to 3) & SF(4 to 6);
    opGCF           <= lacREG(0) & lacREG(0) & GTF    & IRQ & PWRTRP & IE     & '0'   & INF        & DF;
    -- EAE
    opEAELAC        <= EAE(0 to 12);
    opEAEZAC        <= '0' & EAE(1 to 12);
    -- MD
    opADDMD         <= std_logic_vector(unsigned(lacREG(0 to 12)) + unsigned('0' & MD));
    opADDMDP1       <= std_logic_vector(unsigned(lacREG(0 to 12)) + unsigned('0' & MD) + "1");
    opSUBMD         <= std_logic_vector(unsigned(lacREG(0 to 12)) - unsigned('0' & MD));
    opANDMD         <= lacREG(0) & (lacREG(1 to 12) and MD);
    opORMD          <= lacREG(0) & (lacREG(1 to 12) or  MD);
    -- MQ
    opMQSUB         <= std_logic_vector(unsigned('0' & MQ) + unsigned('0' & not(lacREG(1 to 12))) + "1");
    opMQ            <= lacREG(0) & MQ;
    opZMQ           <= '0' & MQ;
    opMQP1          <= std_logic_vector(unsigned('0' & MQ) + "1");
    opNEGMQ         <= std_logic_vector(unsigned('0' & not(MQ)) + "1");
    opNOTMQ         <= '0' & not(MQ);
    opORMQ          <= lacREG(0) & (lacREG(1 to 12) or MQ);
    -- SC
    opSCA           <= lacREG(0 to 7) & (lacREG(8 to 12) or SC);
    -- SP
    opSP1           <= lacREG(0) & SP1;
    opSP2           <= lacREG(0) & SP2;
    -- SR
    opLAS           <= lacREG(0) & SR;
    opOSR           <= lacREG(0) & (lacREG(1 to 12) or SR);

    --
    -- Adder input #2 mux.
    --

    with acOP select
        lacMUX <= lacREG          when acopNOP,         -- LAC <- LAC
                  opIAC           when acopIAC,         -- LAC <- LAC + 1
                  opBSW           when acopBSW,         -- LAC <- L & AC(6:12) & AC(0:5);
                  opRAL           when acopRAL,         -- LAC <- AC(0:11) & L
                  opRTL           when acopRTL,         -- LAC <- AC(1:11) & L & AC(0)
                  opR3L           when acopR3L,         -- LAC <- AC(2:11) & L & AC(0:1)
                  opRAR           when acopRAR,         -- LAC <- AC(11) & L & & AC(0:10);
                  opRTR           when acopRTR,         -- LAC <- AC(10:11) & L & & AC(0:9);
                  opSHL0          when acopSHL0,        -- LAC <- (LAC << 1) & '0'
                  opSHL1          when acopSHL1,        -- LAC <- (LAC << 1) & '1'
                  opLSR           when acopLSR,         -- LAC <- '0' & (LAC >> 1)
                  opASR           when acopASR,         -- LAC <-  L  & (LAC >> 1)
                  opUNDEF1        when acopUNDEF1,      -- LAC <-  L  & (AC and IR);
                  opUNDEF2        when acopUNDEF2,      -- LAC <-  L  & MA(0:4) & IR(5:11)
                  opPC            when acopPC,          -- LAC <- PC
                  opCML           when acopCML,         -- LAC <-  0   0   0  CML
                  opCMA           when acopCMA,         -- LAC <-  0   0  CMA  0
                  opCMACML        when acopCMACML,      -- LAC <-  0   0  CMA CML
                  opCLL           when acopCLL,         -- LAC <-  0  CLL  0   0
                  opCLLCML        when acopCLLCML,      -- LAC <-  0  CLL  0  CML
                  opCLLCMA        when acopCLLCMA,      -- LAC <-  0  CLL CMA  0
                  opCLLCMACML     when acopCLLCMACML,   -- LAC <-  0  CLL CMA CML
                  opCLA           when acopCLA,         -- LAC <- CLA  0   0   0
                  opCLACML        when acopCLACML,      -- LAC <- CLA  0   0  CML 
                  opCLACMA        when acopCLACMA,      -- LAC <- CLA  0  CMA  0
                  opCLACMACML     when acopCLACMACML,   -- LAC <- CLA  0  CMA CML
                  opCLACLL        when acopCLACLL,      -- LAC <- CLA CLL  0   0
                  opCLACLLCML     when acopCLACLLCML,   -- LAC <- CLA CLL  0  CML
                  opCLACLLCMA     when acopCLACLLCMA,   -- LAC <- CLA CLL CMA  0
                  opCLACLLCMACML  when acopCLACLLCMACML,-- LAC <- CLA CLL CMA CML
                  opRDF0          when acopRDF0,        -- LAC <- LAC(0 to  6) & DF  & LAC(10 to 12)
                  opRIF0          when acopRIF0,        -- LAC <- LAC(0 to  6) & INF & LAC(10 to 12);
                  opRIB0          when acopRIB0,        -- LAC <- LAC(0 to  5) & SF
                  opRDF1          when acopRDF1,        -- LAC <- LAC(0 to 12) or ("0000000" & DF  & "000");
                  opRIF1          when acopRIF1,        -- LAC <- LAC(0 to 12) or ("0000000" & INF & "000")
                  opRIB1          when acopRIB1,        -- LAC <- LAC(0 to 12) or ("000000"  & SF);
                  opPRS           when acopPRS,         -- LAC <- LAC(0) & BTSTRP    & PNLTRP & IRQ & PWRTRP & HLTTRP & '0'   & "000"      & "000";
                  opGTF1          when acopGTF1,        -- HD6120 GTF
                  opGTF2          when acopGTF2,        -- PDP8 GTF
                  opGCF           when acopGCF,         -- LAC <- LAC(0) & LAC(0) & GTF    & IRQ & PWRTRP & IE     & '0'   & INF        & DF;
                  opEAELAC        when acopEAELAC,      -- LAC <- EAE(0 to 12)
                  opEAEZAC        when acopEAEZAC,      -- LAC <- '0' & EAE(1 to 12);
                  opSUBMD         when acopSUBMD,       -- LAC <- LAC - MD <- LAC + NOT(MD) + 1
                  opADDMD         when acopADDMD,       -- LAC <- LAC + MD
                  opADDMDP1       when acopADDMDP1,     -- LAC <- LAC + MD + 1
                  opANDMD         when acopANDMD,       -- LAC <- L & (AC and MD)
                  opORMD          when acopORMD,        -- LAC <- L & (AC or MD)
                  opMQSUB         when acopMQSUB,       -- LAC <- MQ - AC <- MQ + NOT(AC) + 1
                  opMQ            when acopMQ,          -- LAC <- L & MQ
                  opZMQ           when acopZMQ,         -- LAC <- 0 & MQ
                  opMQP1          when acopMQP1,        -- LAC <- MQ + 1
                  opNEGMQ         when acopNEGMQ,       -- LAC <- -MQ <- NOT(MQ) + 1
                  opNOTMQ         when acopNOTMQ,       -- LAC <- NOT(MQ)
                  opORMQ          when acopORMQ,        -- LAC <- L & (AC or MQ)
                  opSCA           when acopSCA,         -- LAC <- LAC(0 to 7) & (LAC(8 to 12) or SC)
                  opSP1           when acopSP1,         -- LAC <- LAC(0) & SP1
                  opSP2           when acopSP2,         -- LAC <- LAC(0) & SP2
                  opLAS           when acopLAS,         -- LAC <- SR
                  opOSR           when acopOSR,         -- LAC <- LAC(0) & (LAC(1 to 12) or SR)
                  (others => '0') when others;          -- 

    --
    --! ALU Register
    --
    
    REG_ALU : process(sys)
    begin
        if sys.rst = '1' then
            lacREG <= (others => '0');
        elsif rising_edge(sys.clk) then
            lacREG <= lacMUX;
        end if;
    end process REG_ALU;

    LAC <= lacREG;
    
end rtl;
