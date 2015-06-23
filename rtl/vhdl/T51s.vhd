--
-- 8051 compatible microcontroller core
--
-- Version : 0300
--
-- Copyright (c) 2001-2002 Daniel Wallner (jesus@opencores.org)
--           (c) 2004-2005 Andreas Voggeneder (andreas.voggeneder@fh-hagenberg.ac.at)
--
-- All rights reserved
--
-- Redistribution and use in source and synthezised forms, with or without
-- modification, are permitted provided that the following conditions are met:
--
-- Redistributions of source code must retain the above copyright notice,
-- this list of conditions and the following disclaimer.
--
-- Redistributions in synthesized form must reproduce the above copyright
-- notice, this list of conditions and the following disclaimer in the
-- documentation and/or other materials provided with the distribution.
--
-- Neither the name of the author nor the names of other contributors may
-- be used to endorse or promote products derived from this software without
-- specific prior written permission.
--
-- THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
-- AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
-- THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
-- PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE
-- LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
-- CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
-- SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
-- INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
-- CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
-- ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
-- POSSIBILITY OF SUCH DAMAGE.
--
-- Please report bugs to the author, but before you do so, please
-- make sure that this is not a derivative work and that
-- you have the latest version of this file.
--
-- The latest version of this file can be found at:
--  http://www.opencores.org/cvsweb.shtml/t51/
--
-- Limitations :
--
-- File history :
--
-- 16-Dec-05 : Bugfix for JBC Instruction
-- 21-Jan-06 : Bugfix for INC DPTR instruction for special cases
-- 19-Feb-06 : Bugfix for interrupts at stalled instructions

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.T51_Pack.all;

entity T51s is
  generic(
    DualBus         : integer := 0;     -- FALSE: single bus movx
    SecondDPTR      : integer := 0;
    tristate        : integer := 0);
  port(
    Clk          : in  std_logic;
    Rst_n        : in  std_logic;
    Ready        : in  std_logic;
    ROM_Addr     : out std_logic_vector(15 downto 0);
    ROM_Data     : in  std_logic_vector(7 downto 0);
    RAM_Addr     : out std_logic_vector(15 downto 0);
    RAM_RData    : in  std_logic_vector(7 downto 0);
    RAM_WData    : out std_logic_vector(7 downto 0);
    RAM_Cycle    : out std_logic;
    RAM_Rd       : out std_logic;
    RAM_Wr       : out std_logic;
    Int_Trig     : in  std_logic_vector(6 downto 0);
    Int_Acc      : out std_logic_vector(6 downto 0);
    SFR_Rd_RMW   : out std_logic;
    SFR_Wr       : out std_logic;
    SFR_Addr     : out std_logic_vector(6 downto 0);
    SFR_WData    : out std_logic_vector(7 downto 0);
    SFR_RData_in : in  std_logic_vector(7 downto 0);
    -- DEBUG
    opcode_o     : out std_logic_vector(7 downto 0);
    
    -- external iram (standard synchronous dual ported ram)
    -- Port A (only read)
    IRAM_AddrA : out std_logic_vector(7 downto 0);
    IRAM_DoutA : in  std_logic_vector(7 downto 0);
    -- Port B (read and write)
    IRAM_AddrB : out std_logic_vector(7 downto 0);
    IRAM_DoutB : in  std_logic_vector(7 downto 0);
    IRAM_Wr    : out std_logic;
    IRAM_WData : out std_logic_vector(7 downto 0)
    );
end T51s;

architecture rtl of T51s is
  -- speeds up instructions "mov @Ri,direct" and "mov Ri,direct" by one cycle
  -- but not fully testet. So use it with care
  constant fast_cpu_c    : integer := 0;
  -- Registers
  signal   ACC           : std_logic_vector(7 downto 0);
  signal   B             : std_logic_vector(7 downto 0);
  signal   PSW           : std_logic_vector(7 downto 1);  -- Bit 0 is parity
  signal   PSW0          : std_logic;
  signal   IP            : std_logic_vector(7 downto 0);
  signal   SP            : unsigned(7 downto 0);
  signal   DPL0          : std_logic_vector(7 downto 0);  -- DPTR 0
  signal   DPH0          : std_logic_vector(7 downto 0);  -- DPTR 0
  signal   DPL1          : std_logic_vector(7 downto 0);  -- DPTR 1
  signal   DPH1          : std_logic_vector(7 downto 0);  -- DPTR 1
  signal   DPL           : std_logic_vector(7 downto 0);  -- current DPTR
  signal   DPH           : std_logic_vector(7 downto 0);  -- current DPTR
  signal   DPS, next_DPS : std_logic;
  signal   dptr_inc      : std_logic_vector(15 downto 0);
  signal   DPS_r         : std_logic;
  signal   PC            : unsigned(15 downto 0);
  signal   P2R           : std_logic_vector(7 downto 0);

  signal PCC : std_logic_vector(15 downto 0);
  signal NPC : unsigned(15 downto 0);
  signal OPC : unsigned(15 downto 0);

  -- ALU signals
  signal Op_A      : std_logic_vector(7 downto 0);
  signal Op_B      : std_logic_vector(7 downto 0);
  signal Mem_A     : std_logic_vector(7 downto 0);
  signal Mem_B     : std_logic_vector(7 downto 0);
  signal Old_Mem_B : std_logic_vector(7 downto 0);
  signal ACC_Q     : std_logic_vector(7 downto 0);
  signal B_Q       : std_logic_vector(7 downto 0);
  signal Res_Bus   : std_logic_vector(7 downto 0);
  signal Status_D  : std_logic_vector(7 downto 5);
  signal Status_Wr : std_logic_vector(7 downto 5);

  -- Misc signals
  signal Int_AddrA   : std_logic_vector(7 downto 0);
  signal Int_AddrA_r : std_logic_vector(7 downto 0);
  signal Int_AddrB   : std_logic_vector(7 downto 0);

  signal MCode  : std_logic_vector(3 downto 0);
  signal FCycle : std_logic_vector(1 downto 0);

  signal RET_r : std_logic;
  signal RET   : std_logic;

  signal Stall_pipe  : std_logic;
  signal Ri_Stall    : std_logic;
  signal PSW_Stall   : std_logic;
  signal ACC_Stall   : std_logic;
  signal SP_Stall    : std_logic;
  signal movx_Stall  : std_logic;
  signal DPRAM_Stall : std_logic;
  signal iReady      : std_logic;

  signal Next_PSW7  : std_logic;
  signal Next_ACC_Z : std_logic;
  signal ACC_Wr     : std_logic;
  signal B_Wr       : std_logic;

  signal SFR_RData_r : std_logic_vector(7 downto 0);
  signal SFR_RData   : std_logic_vector(7 downto 0);

  signal Mem_Din : std_logic_vector(7 downto 0);

  signal Bit_Pattern : std_logic_vector(7 downto 0);

  -- Registered instruction words.
  signal Inst  : std_logic_vector(7 downto 0);
  signal Inst1 : std_logic_vector(7 downto 0);
  signal Inst2 : std_logic_vector(7 downto 0);

  -- Control signals
  signal Rst_r_n    : std_logic;
  signal Last       : std_logic;
  signal SFR_Wr_i   : std_logic;
  signal Mem_Wr     : std_logic;
  signal J_Skip     : std_logic;
  signal IPending   : std_logic;
  signal Int_Trig_r : std_logic_vector(6 downto 0);
  signal IStart     : std_logic;
  signal ICall      : std_logic;
  signal HPInt      : std_logic;
  signal LPInt      : std_logic;
  signal PCPaused   : std_logic_vector(3 downto 0);
  signal PCPause    : std_logic;
  signal Inst_Skip  : std_logic;
  signal Div_Rdy    : std_logic;
  signal RAM_Rd_i   : std_logic;
  signal RAM_Wr_i   : std_logic;
  signal INC_DPTR   : std_logic;
  signal CJNE       : std_logic;
  signal DJNZ       : std_logic;

  -- Mux control
  signal AMux_SFR   : std_logic;
  signal BMux_Inst2 : std_logic;
  signal RMux_PCL   : std_logic;
  signal RMux_PCH   : std_logic;

  signal next_Mem_Wr : std_logic;

  signal rd_flag, xxx_flag : std_logic;
  signal rd_flag_r         : std_ulogic;
  signal rd_sfr_flag       : std_logic;
  signal Do_ACC_Wr         : std_logic;

  signal ramc, ramc_r, ramrw_r : std_logic;

  -- external iram
  signal Int_AddrA_unique : std_logic_vector(7 downto 0);
  signal wren_mux_a       : std_logic;
  signal wrdata_r         : std_logic_vector(7 downto 0);
begin


  -- DEBUG
  opcode_o <= Inst;

  -----------------------------------------------------------------------------
  -- bypass logic for external iram
  -----------------------------------------------------------------------------
  Mem_A <= IRAM_DoutA when wren_mux_a = '0' else
           wrdata_r;

----  -- if a W/R instruction is executed on Port B a stall is inserted
  Mem_B <= IRAM_DoutB;


------ to avoid R/W on same address (others => '1') can not be accessed by write
------ Port B
  Int_AddrA_unique <= (others => '1') when  (Mem_Wr='1' and (Int_AddrA=Int_AddrA_r)) else
                        Int_AddrA;

  process (Rst_n, Clk)
  begin
    if Rst_n = '0' then
      wren_mux_a  <= '0';
      wrdata_r    <= (others => '0');
      Int_AddrA_r <= (others => '0');
    elsif Clk'event and Clk = '1' then
      Int_AddrA_r <= Int_AddrA;
      wrdata_r    <= Mem_Din;
      wren_mux_a  <= '0';
      if (Mem_Wr = '1' and Int_AddrA = Int_AddrA_r) then
        wren_mux_a <= '1';
      end if;
    end if;
  end process;


  IRAM_AddrB <= Int_AddrA_r when Mem_Wr = '1' else
                Int_AddrB;



  IRAM_AddrA <= Int_AddrA_unique;
--  IRAM_AddrA <= Int_AddrA;
-------------------------------------------------------------------------------
-- end bypass logic for external iram
---------------------------------------------------------------------------------

  iReady    <= Ready and not xxx_flag;
  ram_cycle <= ramc;

  Last <= '1' when ICall = '1' and FCycle = "11" else
          '0' when ICall = '1'                                 else
          '1' when MCode(1 downto 0) = FCycle and iReady = '1' else
          '0';

  --      (ROM_Data, ICall, Inst, Inst1, Inst2, Last, FCycle, PSW, Mem_B, SP, Old_Mem_B, Ready, Int_AddrA_r)
  process (FCycle, ICall, Inst, Inst1, Inst2, Int_AddrA_r, Last, Mem_B, Old_Mem_B, PSW,
           ROM_Data, Ready, SP)
  begin
    Int_AddrA   <= "--------";
--      Int_AddrB <= "--------";
    Int_AddrB   <= "000" & PSW(4 downto 3) & "00" & Inst(0);
    rd_flag     <= '0';
    rd_sfr_flag <= '0';

    if Inst(3 downto 0) = "0000" or Inst(3 downto 0) = "0010" then
      if Inst(3 downto 0) = "0000" or (Inst(3 downto 0) = "0010" and (Inst(7) = '1' or Inst(6 downto 4) = "111")) then
        if Inst1(7) = '0' then
          Int_AddrA <= "0010" & Inst1(6 downto 3);
        else
          Int_AddrA <= "1" & Inst1(6 downto 3) & "000";
        end if;
      else
        Int_AddrA <= Inst1;
      end if;
      if Inst = "00010010" or ICall = '1' then
        -- LCALL
        if FCycle = "01" then
          Int_AddrA <= std_logic_vector(SP + 1);
        else
          Int_AddrA <= std_logic_vector(SP + 2);
        end if;
      end if;
      if Inst = "11000000" then
        -- 11000000 2 PUSH  data addr       INC SP: MOV "@SP",<src>
        if FCycle = "10" then
          Int_AddrA <= std_logic_vector(SP);
        else
          Int_AddrA <= Inst1;
        end if;
      end if;
      if Inst = "11010000" then
        -- 11010000 2 POP   data addr       MOV <dest>,"@SP": DEC SP
        if FCycle = "10" then
          Int_AddrA <= Inst1;
        else
          Int_AddrA <= std_logic_vector(SP);
        end if;
      end if;
      if Inst(7 downto 5) = "001" and Inst(3 downto 0) = "0010" then
        -- RET, RETI
        Int_AddrA <= std_logic_vector(SP);
        Int_AddrB <= std_logic_vector(SP - 1);
      end if;
    elsif Inst(4 downto 0) = "10001" then
      -- ACALL
      if FCycle = "01" then
        Int_AddrA <= std_logic_vector(SP + 1);
      else
        Int_AddrA <= std_logic_vector(SP + 2);
      end if;
    elsif Inst(3 downto 0) = "0011" then
      Int_AddrA <= Inst1;                --inst1;
    elsif Inst(3 downto 0) = "0100" then
    elsif Inst(3 downto 0) = "0101" then
      if Inst(7 downto 4) = "1000" and FCycle = "11" then
        Int_AddrA <= Inst2;
      else
        Int_AddrA <= Inst1;
      end if;
    elsif Inst(3 downto 1) = "011" then  -- @Ri Adressing mode
      if FCycle(1 downto 0) = "01" then
        Int_AddrA <= Mem_B;
      else
        Int_AddrA <= Old_Mem_B;
      end if;
      if Inst(7 downto 4) = "1000" and FCycle = "10" then
        Int_AddrA <= Inst1;              -- mov direct,@Ri
      end if;
      if Inst(7 downto 4) = "1010" and FCycle = "01" then
        Int_AddrA <= ROM_Data;           -- mov @Ri,direct
        rd_flag   <= '1';
      end if;
    elsif Inst(3) = '1' then
      Int_AddrA <= "000" & PSW(4 downto 3) & Inst(2 downto 0);
      if Inst(7 downto 4) = "1000" and FCycle = "10" then
        Int_AddrA <= Inst1;
      end if;
      if Inst(7 downto 4) = "1010" and FCycle = "01" then
        Int_AddrA <= ROM_Data;           -- mov Ri,data
        rd_flag   <= '1';
      end if;
    end if;

--      if Last = '1' then
    -- Modified by AVG
    if (Inst(7 downto 5) /= "001" or Inst(3 downto 0) /= "0010") and  -- not a RET, RETI
      (ROM_Data(3 downto 1) = "011" or  -- Next or current Instruction has @Ri Addressing Mode
       Inst(3 downto 1) = "011" or
       ROM_Data(7 downto 1) = "1110001" or ROM_Data(7 downto 1)="1111001") then  -- MOVX @Ri,A ; MOVX A,@Ri
      if Last = '1' then
        Int_AddrB <= "000" & PSW(4 downto 3) & "00" & ROM_Data(0);
        -- write to psw is in progress => forward argument
        -- decreases timing !!!
--        if fast_cpu_c /= 0 and SFR_Wr_i = '1' and Int_AddrA_r = "11010000" then
--          Int_AddrB <= "000" & Res_Bus(4 downto 3) & "00" & ROM_Data(0);
--        end if;
      end if;
      rd_sfr_flag <= '1';

    end if;
--      end if;
--      if Inst(7 downto 1) = "1011011" then  -- cjne @ri,#im
--        Int_AddrB <= "000" & PSW(4 downto 3) & "00" & Inst(0);
--      end if;

    if Ready = '0' then
      Int_AddrA <= Int_AddrA_r;
    end if;
  end process;

  Op_A <= SFR_RData_r when AMux_SFR = '1' else
          Mem_A;
  
  Op_B <= Inst2 when BMux_Inst2 = '1' else
          Inst1;

  -- Store return Address to mem (Stack) when a call (or interrupt) occured
  Mem_Din <= PCC(7 downto 0) when RMux_PCL = '1' else
             PCC(15 downto 8) when RMux_PCH = '1' else
             Res_Bus;
  
  
  process (Clk)
  begin
    if Clk'event and Clk = '1' then
      AMux_SFR   <= '0';
      BMux_Inst2 <= '0';
      RMux_PCL   <= '0';
      RMux_PCH   <= '0';

      if Int_AddrA(7) = '1' then
        AMux_SFR <= '1';
      end if;
      if Inst(3 downto 1) = "011" then           -- relative addressing mode
        -- not "mov @ri,direct"
        if not (Inst(7 downto 4) = "1010") then  -- and FCycle = "10") then
          -- Indirect addressing
          AMux_SFR <= '0';
        end if;
      end if;
      if Inst = "11010000" then
        -- 11010000 2 POP   data addr       MOV <dest>,"@SP": DEC SP
--              if FCycle = "10" then
        AMux_SFR <= '0';
--              end if;
      end if;

      if Inst(3 downto 0) = "0011" or Inst(3 downto 0) = "0101" then
        BMux_Inst2 <= '1';
      end if;

      -- LCALL, ACALL, Int
      if (Inst = "00010010" or Inst(4 downto 0) = "10001" or ICall = '1') then
        if FCycle = "01" then
          RMux_PCL <= '1';
        elsif FCycle = "10" then
          RMux_PCH <= '1';
        end if;
      end if;
    end if;
  end process;

  SFR_Wr    <= SFR_Wr_i;
  SFR_Addr  <= Int_AddrA(6 downto 0);
  SFR_WData <= Res_Bus;

  SFR_Rd_RMW <= '1' when Last = '1' and MCode(3) = '1' and Int_AddrA(7) = '1' and
                (Inst(7 downto 4) = "1000" or Inst(3 downto 1) /= "011") and
                Inst /= "11000000" else  -- no push
                '0';
  
  next_Mem_Wr <= '1' when Last = '1' and MCode(3) = '1' and
                 (Int_AddrA(7) = '0' or
                  -- Instruction is no MOV and indirect addressing mode
                  (Inst(7 downto 4) /= "1000" and Inst(3 downto 1) = "011") or
                  Inst = "11000000" ) else  -- PUSH Instruction
                 '0';
  
  
  process (Clk)
  begin
    if Clk'event and Clk = '1' then
      SFR_Wr_i <= '0';
      Mem_Wr   <= '0';
      if Last = '1' and MCode(3) = '1' then
        -- MOV or no indirect addressing
        if Int_AddrA(7) = '1' and (Inst(7 downto 4) = "1000" or Inst(3 downto 1) /= "011") and
          Inst /= "11000000"  then
          -- Direct addressing
          if(Inst = "00010000") then    -- JBC, write result only back if jump is taken
            SFR_Wr_i <= J_Skip;
          else
            -- Direct addressing
            SFR_Wr_i <= '1';
          end if;
        else
          Mem_Wr <= '1';
        end if;
      end if;

      -- LCALL, ACALL, Int
      if iReady = '1' and (Inst = "00010010" or Inst(4 downto 0) = "10001" or ICall = '1') then
        if FCycle /= "11" then          -- LCALL
          Mem_Wr <= '1';
        end if;
      end if;
    end if;
  end process;

  -- Instruction register
  Inst_Skip <= RET_r or J_Skip;  -- '1' when (RET_r = '1' and unsigned(Mem_B) /= PC(15 downto 8)) else J_Skip; ????????????
--  Ri_Stall <= '1' when Inst /= "00000000" and
--              Int_AddrA = "000" & PSW(4 downto 3) & Inst(2 downto 0) and  --Write to Ri in Progress
--              ROM_Data(3 downto 1) = "011" and  --@Ri at next opcode
--              Last = '1' and MCode(3) = '1' else '0';

-- WHEN MCODE(3)==1 => Write to Memory or FSR is in Progress

  -- Modified by AVG
  Ri_Stall <= '1' when Inst /= "00000000" and 
              next_Mem_Wr = '1' and
              (Int_AddrA = "000" & PSW(4 downto 3) & "00"&ROM_Data(0) and
               (ROM_Data(3 downto 1) = "011" or      -- @Ri at next opcode 
                ROM_Data(7 downto 1) = "1110001" or  -- movx a,@ri at next opcode
                ROM_Data(7 downto 1) = "1111001"))   -- movx @ri,a at next opcod
              else '0';



-- WHEN MCODE(3)==1 => Write to Memory or FSR is in Progress            
  -- Modified by AVG
  PSW_Stall <= '1' when Int_AddrA = "11010000" and 
               next_Mem_Wr = '0' and             -- PSW Adressed and no memory write
               (ROM_Data(3 downto 1) = "011" or  -- @Ri at next opcode
                ROM_Data(3) = '1') and           -- Rx at next opcode
               Last = '1' and
               MCode(3) = '1' else
               '0';

-- WHEN MCODE(2)==1 => Write to ACC in Progress 
-- Stall Pipe when Write to ACC is in Progress and next Instruction is JMP @A+DPTR  
-- Modified by AVG
  ACC_Stall <= '1' when ROM_Data = "01110011" and
               Last = '1' and MCode(2) = '1' else
               '0';

  -- when a write to SP is in progress
  -- and next opcode is a call or interrupt
  -- -> stall pipe (nop insertion)                      
  -- Modified by AVG
  SP_Stall <= '1' when Last = '1' and MCode(3) = '1' and
              Int_AddrA = "10000001" and 
              (Inst(7 downto 4) = "1000" or    -- mov opcode
               Inst(3 downto 1) /= "011") and  -- and no indirect addressing
              Inst /= "11000000" and           -- and not PUSH
              (ROM_Data = "00010010" or 
               ROM_Data(4 downto 0) = "10001" or 
               IStart = '1') else              -- LCALL, ACALL, Int
              '0';

  -- to subsequent movx instructions
  movx_Stall <= '1' when Last = '1' and
                -- movx opcode at current instruction
                Inst(7 downto 5) = "111" and Inst(3 downto 2) = "00" and 
                Inst(1 downto 0) /= "01" and
                -- movx opcode at next instruction
                ROM_Data(7 downto 5) = "111" and ROM_Data(3 downto 2) = "00" and 
                ROM_Data(1 downto 0) /= "01" else
                '0';

  -- Modified by Markus Lang
  -- for the DPRAM a Stall is needed if a read and a write instruction should
  -- be processed at the same cycle on AddrB
  DPRAM_Stall <= '1' when Last = '1' and
                 -- Ret(i), MOV dir, @Rx
                 ((next_Mem_Wr = '1' and (ROM_Data = "00110010" or ROM_Data = "00100010" or ROM_Data(7 downto 1) = "1010011")) or
                  (Mem_Wr = '1' and
                   -- @Ri
                   (ROM_Data(3 downto 1) = "011"  or
                    -- movx a,@ri at next opcode
                    ROM_Data(7 downto 1) = "1110001" or
                    -- movx @ri,a at next opcode
                    ROM_Data(7 downto 1) = "1111001"))) else
                 '0';



  Stall_pipe <= (Ri_Stall or PSW_Stall or ACC_Stall or SP_Stall or movx_Stall or DPRAM_Stall) and not IStart;

  process (Rst_n, Clk)
    variable bitnr_v : natural range 0 to 7;
  begin
    if Rst_n = '0' then
      Rst_r_n     <= '0';
      Inst        <= (others => '0');                 -- Force NOP at reset.
      Inst1       <= (others => '0');
      Inst2       <= (others => '0');
      Bit_Pattern <= "00000000";
    elsif Clk'event and Clk = '1' then
      Rst_r_n <= '1';
      if iReady = '0' then
      elsif Rst_r_n = '0' or
        Inst_Skip = '1' or IStart = '1' or
        Stall_pipe = '1' then
--                Ri_Stall = '1' or PSW_Stall = '1' or ACC_Stall = '1' then
        -- Skip/Stall/Flush: NOP insertion
        Inst <= (others => '0');
      elsif Inst = "10000100" and PCPause = '1' then  -- DIV
      else
        if Last = '1' then
          Inst <= ROM_Data;
        end if;
        if FCycle = "01" then
          Inst1 <= ROM_Data;
        end if;
        if FCycle = "10" then
          Inst2 <= ROM_Data;
        end if;
      end if;
      if FCycle = "01" then
        Bit_Pattern          <= "00000000";
        bitnr_v              := to_integer(unsigned(ROM_Data(2 downto 0)));
        Bit_Pattern(bitnr_v) <= '1';

--              case ROM_Data(2 downto 0) is
--              when "000" =>
--                  Bit_Pattern <= "00000001";
--              when "001" =>
--                  Bit_Pattern <= "00000010";
--              when "010" =>
--                  Bit_Pattern <= "00000100";
--              when "011" =>
--                  Bit_Pattern <= "00001000";
--              when "100" =>
--                  Bit_Pattern <= "00010000";
--              when "101" =>
--                  Bit_Pattern <= "00100000";
--              when "110" =>
--                  Bit_Pattern <= "01000000";
--              when others =>
--                  Bit_Pattern <= "10000000";
--              end case;
      end if;
    end if;
  end process;

  -- Accumulator, B and status register
  tristate_mux : if tristate /= 0 generate
    SFR_RData <= PSW & PSW0           when Int_AddrA = "11010000" else "ZZZZZZZZ";
    SFR_RData <= ACC                  when Int_AddrA = "11100000" else "ZZZZZZZZ";
    SFR_RData <= B                    when Int_AddrA = "11110000" else "ZZZZZZZZ";
    -- Stack pointer
    SFR_RData <= std_logic_vector(SP) when Int_AddrA = "10000001" else "ZZZZZZZZ";

    SFR_RData <= dptr_inc(7 downto 0) when (SecondDPTR /= 0 and (INC_DPTR and next_DPS) = '1' and Int_AddrA = "10000100") or
                 ((INC_DPTR and not next_DPS) = '1' and Int_AddrA = "10000010") else "ZZZZZZZZ";
    SFR_RData <= dptr_inc(15 downto 8) when (SecondDPTR /= 0 and (INC_DPTR and next_DPS) = '1' and Int_AddrA = "10000101") or
                 ((INC_DPTR and not next_DPS) = '1' and Int_AddrA = "10000011") else "ZZZZZZZZ";
    
    SFR_RData <= DPL1          when SecondDPTR /= 0 and INC_DPTR = '0' and Int_AddrA = "10000100" else "ZZZZZZZZ";
    SFR_RData <= DPH1          when SecondDPTR /= 0 and INC_DPTR = '0' and Int_AddrA = "10000101" else "ZZZZZZZZ";
    SFR_RData <= "0000000"&DPS when SecondDPTR/=0 and Int_AddrA = "10000110"                      else "ZZZZZZZZ";

    SFR_RData <= DPL0 when INC_DPTR = '0' and Int_AddrA = "10000010" else "ZZZZZZZZ";
    SFR_RData <= DPH0 when INC_DPTR = '0' and Int_AddrA = "10000011" else "ZZZZZZZZ";
    SFR_RData <= IP   when Int_AddrA = "10111000"                    else "ZZZZZZZZ";
    SFR_RData <= SFR_RData_in;
  end generate;

  std_mux : if tristate = 0 generate
    SFR_RData <= PSW & PSW0 when Int_AddrA = "11010000" else 
                 ACC                  when Int_AddrA = "11100000" else 
                 B                    when Int_AddrA = "11110000" else 
                 std_logic_vector(SP) when Int_AddrA = "10000001" else 

                 dptr_inc(7 downto 0)  when (SecondDPTR /= 0 and (INC_DPTR and next_DPS) = '1' and Int_AddrA = "10000100") or
                 ((INC_DPTR and not next_DPS) = '1' and Int_AddrA = "10000010")                           else 
                 dptr_inc(15 downto 8) when (SecondDPTR /= 0 and (INC_DPTR and next_DPS) = '1' and Int_AddrA = "10000101") or
                 ((INC_DPTR and not next_DPS) = '1' and Int_AddrA = "10000011")                           else 
                 DPL1                  when SecondDPTR /= 0 and INC_DPTR = '0' and Int_AddrA = "10000100" else 
                 DPH1                  when SecondDPTR /= 0 and INC_DPTR = '0' and Int_AddrA = "10000101" else
                 "0000000"&DPS         when SecondDPTR/=0 and Int_AddrA = "10000110"                      else 

                 DPL0 when INC_DPTR = '0' and Int_AddrA = "10000010" else 
                 DPH0 when INC_DPTR = '0' and Int_AddrA = "10000011" else 
                 IP   when Int_AddrA = "10111000"                    else 
                 SFR_RData_in;

    --  -- is it an internal or external read                 
    --   Int_Read <= '1' when Int_AddrA = "11010000" or 
    --                       Int_AddrA = "11100000" or 
    --                       Int_AddrA = "11110000" or 
    --                       Int_AddrA = "10000001" or 
    --                       
    --                        (SecondDPTR and Int_AddrA = "10000100") or 
    --                       (SecondDPTR and Int_AddrA = "10000101") or 
    --                       (SecondDPTR and Int_AddrA = "10000110") or 
    --                       
    --                       Int_AddrA = "10000010" or 
    --                       Int_AddrA = "10000011" or 
    --                       Int_AddrA = "10111000" else 
    --              '0';
    
  end generate;

  PSW0      <= ACC(7) xor ACC(6) xor ACC(5) xor ACC(4) xor ACC(3) xor ACC(2) xor ACC(1) xor ACC(0);
  Next_PSW7 <= Res_Bus(7) when SFR_Wr_i = '1' and Int_AddrA_r = "11010000" else
               Status_D(7) when Status_Wr(7) = '1' else
               PSW(7);
  Next_ACC_Z <= '1' when ACC_Q = "00000000" and ACC_Wr = '1' else
                '1' when ACC = "00000000" else '0';
  
  process (Rst_n, Clk)
--      variable B_Wr : std_logic;
  begin
    if Rst_n = '0' then
      PSW    <= "0000000";
      ACC    <= "00000000";
      B      <= "00000000";
      ACC_Wr <= '0';
      B_Wr   <= '0';
    elsif Clk'event and Clk = '1' then
      if ACC_Wr = '1' then
        ACC <= ACC_Q;
      end if;
      if B_Wr = '1' then
        B <= B_Q;
      end if;
      if (MCode(2) and Last) = '1' or (Inst = "10000100" and PCPause = '0') then
        ACC_Wr <= '1';
      else
        ACC_Wr <= '0';
      end if;
      if ((Inst = "10000100" and PCPause = '0') or Inst = "10100100") and Last = '1' then  --  DIV, MUL
        B_Wr <= '1';
      else
        B_Wr <= '0';
      end if;

      if SFR_Wr_i = '1' and Int_AddrA_r = "11100000" then
        ACC <= Res_Bus;
      end if;

      if RAM_Rd_i = '1' then
        ACC <= RAM_RData;
      end if;

      if SFR_Wr_i = '1' and Int_AddrA_r = "11110000" then
        B <= Res_Bus;
      end if;

      if Inst(7 downto 5) = "100" and Inst(3 downto 0) = "0011" then  -- MOVC
        if FCycle = "11" then
          ACC <= ROM_Data;
        end if;
      end if;

      if SFR_Wr_i = '1' and Int_AddrA_r = "11010000" then
        PSW <= Res_Bus(7 downto 1);
      end if;
      -- CY
      if Status_Wr(7) = '1' then PSW(7) <= Status_D(7); end if;
      -- AC
      if Status_Wr(6) = '1' then PSW(6) <= Status_D(6); end if;
      -- OV
      if Status_Wr(5) = '1' then PSW(2) <= Status_D(5); end if;
    end if;
  end process;


  process (Rst_n, Clk)
  begin
    if Rst_n = '0' then
      SP <= "00000111";
    elsif Clk'event and Clk = '1' then
      if SFR_Wr_i = '1' and Int_AddrA_r = "10000001" then
        SP <= unsigned(Res_Bus);
      end if;
      if iReady = '1' then
        if Inst(7 downto 5) = "001" and Inst(3 downto 0) = "0010" then
          SP <= SP - 2;
        end if;
        if (Inst = "00010010" or Inst(4 downto 0) = "10001" or ICall = '1') and Last = '1' then
          -- LCALL, ACALL, ICall
          SP <= SP + 2;
        end if;
        if Inst = "11000000" and PCPaused(0) = '1' then
          -- 11000000 2 PUSH  data addr     INC SP: MOV "@SP",<src>
          SP <= SP + 1;
        end if;
        if Inst = "11010000" and Last = '1' then
          -- 11010000 2 POP   data addr     MOV <dest>,"@SP": DEC SP
          SP <= SP - 1;
        end if;
      end if;
    end if;
  end process;

  twoDPTR : if SecondDPTR /= 0 generate
    next_DPS <= Res_Bus(0) when SFR_Wr_i = '1' and Int_AddrA_r = "10000110" else
                DPS;
    
    DPL <= DPL0 when next_DPS = '0' else
           DPL1;
    DPH <= DPH0 when next_DPS = '0' else
           DPH1;
--      SFR_RData <= DPL1 when Int_AddrA = "10000100" else "ZZZZZZZZ";
--      SFR_RData <= DPH1 when Int_AddrA = "10000101" else "ZZZZZZZZ";
--      SFR_RData <= "0000000"&DPS when Int_AddrA = "10000110" else "ZZZZZZZZ";
  end generate;
  oneDPTR : if SecondDPTR = 0 generate
    DPL      <= DPL0;
    DPH      <= DPH0;
    next_DPS <= '0';
  end generate;

  -- DPTR/RAM_Addr
  RAM_WData <= ACC;
  --(Inst, P2R, DPH, DPL, Int_AddrA_r, SFR_Wr_i, Res_Bus, INC_DPTR, Mem_B)
  process (DPH, DPL, INC_DPTR, dptr_inc, Inst, Int_AddrA_r, Mem_B, P2R, Res_Bus, SFR_Wr_i, DPS)
  begin
    RAM_Addr <= DPH & DPL;
    if Inst(1) = '0' then
      if (SFR_Wr_i = '1' and Int_AddrA_r = "10000010" and DPS = '0') or
        (SecondDPTR /= 0 and SFR_Wr_i = '1' and Int_AddrA_r = "10000100"  and DPS = '1')
      then
        RAM_Addr(7 downto 0) <= Res_Bus;
      end if;
      if (SFR_Wr_i = '1' and Int_AddrA_r = "10000011" and DPS = '0') or
        (SecondDPTR /= 0 and SFR_Wr_i = '1' and Int_AddrA_r = "10000101" and DPS = '1')
      then
        RAM_Addr(15 downto 8) <= Res_Bus;
      end if;
      -- 10100011 1 INC   DPTR
      if INC_DPTR = '1' then
--              RAM_Addr <= std_logic_vector(unsigned(DPH) & unsigned(DPL) + 1);
        RAM_Addr <= dptr_inc;
      end if;
    else                                -- movx a,@ri or movx @ri,a
      RAM_Addr <= P2R & Mem_B;
      if SFR_Wr_i = '1' and Int_AddrA_r = "10100000" then
        RAM_Addr(15 downto 8) <= Res_Bus;
      end if;
    end if;
  end process;

  --if Inst(7 downto 2) = "111000" and Inst(1 downto 0) /= "01" then
  -- MOVX Instruction
  ramc <= '1' when Inst(7 downto 5) = "111" and Inst(3 downto 2) = "00" and 
          Inst(1 downto 0) /= "01" and 
          PCPaused(0) = '0' else
          '0';

--  RAM_Rd <= RAM_Rd_i and ramc and not ramrw_r when DualBus=0 else
--            RAM_Rd_i and ramc;
  RAM_Rd <= RAM_Rd_i and ramc;

  RAM_Wr <= RAM_Wr_i;

  Do_ACC_Wr <= '1' when (ACC_Wr or RAM_Rd_i) = '1' or
               (SFR_Wr_i = '1' and Int_AddrA_r = "11100000") else
               '0';

-- Gefählich sind:
-- mov @Ri,direct
-- mov Ri,data
-- da diese Befehle die Quelldaten einen Takt früher lesen als alle anderen Befehle
--      xxx_flag <= '1' when ((SFR_Wr_i and rd_flag)= '1' and Int_AddrA_r=Int_AddrA) or
--                            ((Do_ACC_Wr and rd_flag)='1' and Int_AddrA = "11010000") or
--                            (Status_Wr/="000" and rd_flag='1' and Int_AddrA="11010000") or
--                            (fast_cpu_c=0 and (rd_sfr_flag and SFR_Wr_i) = '1' and Int_AddrA_r = "11010000") else
--                  '0';
  fast : if fast_cpu_c /= 0 generate
    xxx_flag <= '1' when ((SFR_Wr_i and rd_flag) = '1' and Int_AddrA_r = Int_AddrA) or
                ((Do_ACC_Wr and rd_flag) = '1' and Int_AddrA = "11010000") or  -- WR to ACC in Progress and read from PSW
                ((B_Wr and rd_flag) = '1' and Int_AddrA = "11110000") or
                (Status_Wr /= "000" and rd_flag='1' and Int_AddrA="11010000") or
--                            (ramc='1' and ramc_r='0')
                (Inst(7 downto 2) = "111000" and Inst(1 downto 0) /= "01" and ramc_r='0')  --MOVX A,??
--                          (((RAM_Rd_i and ramc)='1' or RAM_Wr_i='1') and ramrw_r='0' and DualBus=0) 
                else
                '0';
  end generate;
  slow : if fast_cpu_c = 0 generate
    -- Inserts an Waitstate on every mov @Ri,direct or mov Ri,data Instruction
    xxx_flag <= '1' when (rd_flag and not rd_flag_r) = '1' or  -- mov @ri,direct or mov ri,direct
                ((rd_sfr_flag and SFR_Wr_i) = '1' and Int_AddrA_r = "11010000")  or  -- Wr to PSW and @Ri Adressing at next instruction
--                           (ramc='1' and ramc_r='0')
                (Inst(7 downto 2) = "111000" and Inst(1 downto 0) /= "01" and ramc_r='0') or  --MOVX A,??
--                         (((RAM_Rd_i and ramc)='1' or RAM_Wr_i='1') and ramrw_r='0' and DualBus=0) 
                ((RAM_Wr_i = '1') and ramrw_r = '0' and DualBus = 0)
                else
                '0';
    
    process(Rst_n, Clk)
    begin
      if Rst_n = '0' then
        rd_flag_r <= '0';
      elsif Clk'event and Clk = '1' then
        rd_flag_r <= rd_flag;
      end if;
    end process;
    
  end generate;

  process (Rst_n, Clk)
    variable tmp : unsigned(15 downto 0);
  begin
    if Rst_n = '0' then
      P2R      <= "11111111";
      DPL0     <= "00000000";
      DPH0     <= "00000000";
      INC_DPTR <= '0';
      RAM_Rd_i <= '0';
      RAM_Wr_i <= '0';
      if SecondDPTR /= 0 then
        DPL1     <= "00000000";
        DPH1     <= "00000000";
        DPS_r    <= '0';
      end if;
      ramc_r   <= '0';
      ramrw_r  <= '0';
    elsif Clk'event and Clk = '1' then
      if Ready = '1' then
        ramc_r  <= ramc;
        ramrw_r <= (RAM_Rd_i and ramc) or RAM_Wr_i;
      end if;
      if SFR_Wr_i = '1' and Int_AddrA_r = "10100000" then
        P2R <= Res_Bus;
      end if;
      if SFR_Wr_i = '1' and Int_AddrA_r = "10000010" then
        DPL0 <= Res_Bus;
      end if;
      if SFR_Wr_i = '1' and Int_AddrA_r = "10000011" then
        DPH0 <= Res_Bus;
      end if;
      if SecondDPTR /= 0 then
        if SFR_Wr_i = '1' and Int_AddrA_r = "10000100" then
          DPL1 <= Res_Bus;
        end if;
        if SFR_Wr_i = '1' and Int_AddrA_r = "10000101" then
          DPH1 <= Res_Bus;
        end if;
        if SFR_Wr_i = '1' and Int_AddrA_r = "10000110" then
          DPS_r <= Res_Bus(0);
        end if;
      end if;
      if iReady = '1' then
        if SecondDPTR = 0 or
          (SecondDPTR /= 0 and DPS = '0') then
          -- 10010000 3 MOV   DPTR,#data
          if Inst = "10010000" and FCycle = "10" then
            DPH0 <= Inst1;
          end if;
          if Inst = "10010000" and FCycle = "11" then
            DPL0 <= Inst2;
          end if;
          -- 10100011 1 INC   DPTR
          if INC_DPTR = '1' then
--                      tmp := unsigned(DPH) & unsigned(DPL) + 1;
--                      DPH0 <= std_logic_vector(tmp(15 downto 8));
--                      DPL0 <= std_logic_vector(tmp(7 downto 0));
            DPH0 <= dptr_inc(15 downto 8);
            DPL0 <= dptr_inc(7 downto 0);
          end if;
        elsif SecondDPTR /= 0 and DPS = '1' then
          -- 10010000 3 MOV   DPTR,#data
          if Inst = "10010000" and FCycle = "10" then
            DPH1 <= Inst1;
          end if;
          if Inst = "10010000" and FCycle = "11" then
            DPL1 <= Inst2;
          end if;
          -- 10100011 1 INC   DPTR
          if INC_DPTR = '1' then
--                      tmp := unsigned(DPH) & unsigned(DPL) + 1;
--                      DPH1 <= std_logic_vector(tmp(15 downto 8));
--                      DPL1 <= std_logic_vector(tmp(7 downto 0));
            DPH1 <= dptr_inc(15 downto 8);
            DPL1 <= dptr_inc(7 downto 0);
          end if;
        end if;
        INC_DPTR <= '0';
        if Inst = "10100011" then
          INC_DPTR <= '1';
        end if;
      end if;
      if Ready = '1' then
        RAM_Wr_i <= '0';
        -- movx instruction
        if (Inst(7 downto 2) = "111100" and Inst(1 downto 0) /= "01") then  -- and DualBus/=0) or
          --                (Inst(7 downto 2) = "111100" and Inst(1 downto 0) /= "01" and iReady = '0' and DualBus=0) then
          RAM_Wr_i <= '1';
        end if;
        RAM_Rd_i <= '0';
        --          if Inst(7 downto 2) = "111000" and Inst(1 downto 0) /= "01" and iReady = '1' then
        if Inst(7 downto 2) = "111000" and Inst(1 downto 0) /= "01" then
          RAM_Rd_i <= '1';
        end if;
      end if;
    end if;
  end process;

  dptr_inc <= std_logic_vector(unsigned(DPH) & unsigned(DPL) + 1);

--  process(DPS_r)
--  begin
--    if SecondDPTR /= 0 then
--      DPS <= DPS_r;
--    else
--      DPS <= '0';
--    end if;
--  end process;

  DPS <= DPS_r when SecondDPTR /= 0 else
         '0';


  -- Interrupts
  IStart <= Last and IPending and not Inst_Skip;

  process (Rst_n, Clk)
  begin
    if Rst_n = '0' then
      LPInt      <= '0';
      HPInt      <= '0';
      Int_Acc    <= (others => '0');
      Int_Trig_r <= (others => '0');
      IPending   <= '0';
      IP         <= "00000000";
      ICall      <= '0';
    elsif Clk'event and Clk = '1' then
      if SFR_Wr_i = '1' and Int_AddrA_r = "10111000" then
        IP <= Res_Bus;
      end if;
      if iReady = '1' then
        if (Int_Trig and IP(6 downto 0)) /= "0000000" and HPInt = '0' and IPending = '0' and ICall = '0' then
          Int_Trig_r <= Int_Trig and IP(6 downto 0);
          IPending   <= '1';
          HPInt      <= '1';
        elsif Int_Trig /= "0000000" and LPInt = '0' and HPInt = '0'  and IPending = '0' and ICall = '0' then
          IPending   <= '1';
          Int_Trig_r <= Int_Trig;
          LPInt      <= '1';
        end if;
        if ICall = '1' then
          IPending <= '0';
        end if;
        if IStart = '1' and SP_Stall = '0' then
          ICall <= '1';
        end if;
        if ICall = '1' and Last = '1' then
          ICall      <= '0';
          Int_Trig_r <= (others => '0');
        end if;
        Int_Acc <= (others => '0');
        if IPending = '1' and ICall = '1' then
          if Int_Trig_r(0) = '1' then Int_Acc(0)    <= '1';
          elsif Int_Trig_r(1) = '1' then Int_Acc(1) <= '1';
          elsif Int_Trig_r(2) = '1' then Int_Acc(2) <= '1';
          elsif Int_Trig_r(3) = '1' then Int_Acc(3) <= '1';
          elsif Int_Trig_r(4) = '1' then Int_Acc(4) <= '1';
          elsif Int_Trig_r(5) = '1' then Int_Acc(5) <= '1';
          elsif Int_Trig_r(6) = '1' then Int_Acc(6) <= '1';
          end if;
        end if;
        if Inst = "00110010" then       -- reti
          if HPInt = '0' then
            LPInt <= '0';
          else
            HPInt <= '0';
          end if;
        end if;
      end if;
    end if;
  end process;

  -- Program counter
  ROM_Addr <= std_logic_vector(NPC);
  process (Rst_n, Clk)
  begin
    if Rst_n = '0' then
      PC       <= (others => '0');
      OPC      <= (others => '0');
      FCycle   <= "01";
      RET_r    <= '0';
      PCPaused <= (others => '0');
    elsif Clk'event and Clk = '1' then
      if iReady = '1' then
        PC    <= NPC;
        RET_r <= RET;

        if PCPause = '1' then
          PCPaused <= std_logic_vector(unsigned(PCPaused) + 1);
        else
          PCPaused <= (others => '0');
        end if;

        if PCPause = '0' then
          FCycle <= std_logic_vector(unsigned(FCycle) + 1);
          if Last = '1' then
            FCycle <= "01";
          end if;
        end if;

        if Inst(7 downto 5) = "100" and Inst(3 downto 0) = "0011" then  -- MOVC
          if FCycle = "01" then
            OPC <= PC;
          end if;
        end if;
      end if;
    end if;
  end process;


  process (ACC, Bit_Pattern, CJNE, DJNZ, DPH, DPL, Div_Rdy, FCycle, ICall,
           Inst, Inst1, Inst2, Int_Trig_r, Mem_A, Mem_B, Next_ACC_Z, Next_PSW7, OPC,
           Op_A, PC, PCPaused, RET_r, ROM_Data, iReady, Rst_r_n, Stall_pipe)
  begin
    NPC     <= PC;
    J_Skip  <= '0';
    RET     <= '0';
    PCPause <= '0';
    -- push,pop
    if (Inst(7 downto 5) = "110" and Inst(3 downto 0) = "0000" and FCycle = "01" and PCPaused(0) = '0') or  -- PUSH, POP
      -- Single bus MOVX
      (Inst(7 downto 2) = "111000" and Inst(1 downto 0) /= "01" and DualBus=0 and PCPaused(0) = '0') or 
      (Inst = "10000100" and (PCPaused(3 downto 1) = "000" or Div_Rdy = '0')) then  -- DIV
      PCPause <= '1';
    else
--          if Ri_Stall = '0' and PSW_Stall = '0' and ACC_Stall='0' then
      if Stall_pipe = '0' then
        NPC <= PC + 1;
      end if;
    end if;
    -- Single bus MOVX
    if (Inst(7 downto 2) = "111000" and Inst(1 downto 0) /= "01"  and DualBus=0) then
      J_Skip <= '1';
    end if;
    -- Return
    if Inst(7 downto 5) = "001" and Inst(3 downto 0) = "0010" then  -- RET, RETI
      RET    <= '1';
      J_Skip <= '1';
    end if;
    -- MOVC
    if Inst(7 downto 5) = "100" and Inst(3 downto 0) = "0011" and FCycle = "11" then
      NPC    <= OPC;
      J_Skip <= '1';
    end if;
    -- 2 byte 8 bit relative jump
    if FCycle = "10" then
      if (Inst = "01000000" and Next_PSW7 = '1') or                 -- JC
                  (Inst = "01010000" and Next_PSW7 = '0') or        -- JNC
                  (Inst = "01100000" and Next_ACC_Z = '1') or       -- JZ
                  (Inst = "01110000" and Next_ACC_Z = '0') or       -- JNZ
                  (Inst(7 downto 3) = "11011" and DJNZ = '1') or    -- DJNZ
                  Inst = "10000000" then                            -- SJMP
        NPC    <= PC + unsigned(resize(signed(Inst1), 16));
        J_Skip <= '1';
      end if;
    end if;

    -- 3 byte 8 bit relative jump
    if FCycle = "11" then
      if (Inst = "00100000" or Inst = "00010000") and (Bit_Pattern and Op_A) /= "00000000" then  -- JB, JBC
        NPC    <= PC + unsigned(resize(signed(Inst2), 16));
        J_Skip <= '1';
      end if;
      if Inst = "00110000" and (Bit_Pattern and Op_A) = "00000000" then  -- JNB
        NPC    <= PC + unsigned(resize(signed(Inst2), 16));
        J_Skip <= '1';
      end if;
      if Inst(7 downto 4) = "1011" and Inst(3 downto 2) /= "00" and CJNE = '1' then  -- CJNE
        NPC    <= PC + unsigned(resize(signed(Inst2), 16));
        J_Skip <= '1';
      end if;
      if Inst = "11010101" and DJNZ = '1' then                           -- DJNZ
        NPC    <= PC + unsigned(resize(signed(Inst2), 16));
        J_Skip <= '1';
      end if;
    end if;
    -- 11 bit absolute
    if FCycle = "10" then
      if Inst(4 downto 0) = "00001" or Inst(4 downto 0) = "10001" then
        -- AJMP, ACALL
        NPC(15 downto 11) <= PC(15 downto 11);
        NPC(10 downto 8)  <= unsigned(Inst(7 downto 5));
        NPC(7 downto 0)   <= unsigned(Inst1);
        J_Skip            <= '1';
      end if;
    end if;
    -- 16 bit absolute
    if FCycle = "10" then
      if Inst = "00000010" or Inst = "00010010" then
        -- LJMP, LCALL
        NPC(15 downto 8) <= unsigned(Inst1);
        NPC(7 downto 0)  <= unsigned(ROM_Data);
      end if;
      if ICall = '1' then
        NPC                                            <= (1 => '1', 0 => '1', others => '0');
        if Int_Trig_r(1) = '1' then NPC(5 downto 3)    <= "001";
        elsif Int_Trig_r(2) = '1' then NPC(5 downto 3) <= "010";
        elsif Int_Trig_r(3) = '1' then NPC(5 downto 3) <= "011";
        elsif Int_Trig_r(4) = '1' then NPC(5 downto 3) <= "100";
        elsif Int_Trig_r(5) = '1' then NPC(5 downto 3) <= "101";
        elsif Int_Trig_r(6) = '1' then NPC(5 downto 3) <= "110";
        end if;
      end if;
    end if;
    -- A+DPTR Absolute
    if Inst = "01110011" then
      -- JMP @A+DPTR
      NPC    <= (unsigned(DPH) & unsigned(DPL)) + unsigned(resize(signed(ACC), 16));
      J_Skip <= '1';
    end if;

    if Inst(7 downto 5) = "100" and Inst(3 downto 0) = "0011" then  -- MOVC
      if FCycle = "10" then
        if Inst(4) = '0' then
          NPC <= unsigned(ACC) + OPC;
        else
          NPC <= unsigned(ACC) + (unsigned(DPH) & unsigned(DPL));
        end if;
      end if;
    end if;

    if RET_r = '1' then  -- and unsigned(Mem_A) /= PC(15 downto 8) then ???????????????????????????
      NPC <= unsigned(Mem_A) & unsigned(Mem_B);
    end if;

    if iReady = '0' then
      NPC <= PC;
    end if;
    if Rst_r_n = '0' then
      NPC <= (others => '0');
    end if;
  end process;

  -- ALU
  alu : T51_ALU
    generic map(
      tristate => tristate
      )
    port map(
      Clk         => Clk,
      Last        => Last,
      OpCode      => Inst,
      ACC         => ACC,
      B           => B,
      IA          => Op_A,
      IB          => Op_B,
      Bit_Pattern => Bit_Pattern,
      CY_In       => PSW(7),
      AC_In       => PSW(6),
      ACC_Q       => ACC_Q,
      B_Q         => B_Q,
      IDCPBL_Q    => Res_Bus,
      Div_Rdy     => Div_Rdy,
      CJNE        => CJNE,
      DJNZ        => DJNZ,
      CY_Out      => Status_D(7),
      AC_Out      => Status_D(6),
      OV_Out      => Status_D(5),
      CY_Wr       => Status_Wr(7),
      AC_Wr       => Status_Wr(6),
      OV_Wr       => Status_Wr(5));

  process (Clk)
  begin
    if Clk'event and Clk = '1' then
      Old_Mem_B <= Mem_B;
      if FCycle = "01" then
        if Inst(1) = '1' then
          PCC <= std_logic_vector(PC + 2);
        else
          PCC <= std_logic_vector(PC + 1);
        end if;
        if ICall = '1' then
          PCC <= std_logic_vector(PC - 1);
        end if;
      end if;
      SFR_RData_r <= SFR_RData;
    end if;
  end process;


--   iram : T51_RAM
--      generic map (
--        RAMAddressWidth => RAMAddressWidth)
--      port map (
--        Clk         => Clk,
--        Rst_n       => Rst_n,
--        ARE         => Ready,
--        Wr          => Mem_Wr,
--        DIn         => Mem_Din,
--        Int_AddrA   => Int_AddrA,
--        Int_AddrA_r => Int_AddrA_r,
--        Int_AddrB   => Int_AddrB,
--        Mem_A       => Mem_A,
--        Mem_B       => Mem_B);


  IRAM_Wr    <= Mem_Wr;
 -- IRAM_Addr  <= Int_AddrA_r;
  IRAM_WData <= Mem_Din;

  process (Inst)
  begin
    case Inst is
      -- 1 downto 0 instruction length
      -- 2 write ACC
      -- 3 write register file
      when "00000000" => MCode <= "0001";  -- 00000000 1 NOP
      when "00000001" => MCode <= "0010";  -- aaa00001 2 AJMP  code addr
      when "00000010" => MCode <= "0011";  -- 00000010 3 LJMP  code addr
      when "00000011" => MCode <= "0101";  -- 00000011 1 RR    A
      when "00000100" => MCode <= "0101";  -- 00000100 1 INC   A
      when "00000101" => MCode <= "1010";  -- 00000101 2 INC   data addr
      when "00000110" => MCode <= "1001";  -- 0000011i 1 INC   @Ri
      when "00000111" => MCode <= "1001";  -- 0000011i 1 INC   @Ri
      when "00001000" => MCode <= "1001";  -- 00001rrr 1 INC   Rn
      when "00001001" => MCode <= "1001";  -- 00001rrr 1 INC   Rn
      when "00001010" => MCode <= "1001";  -- 00001rrr 1 INC   Rn
      when "00001011" => MCode <= "1001";  -- 00001rrr 1 INC   Rn
      when "00001100" => MCode <= "1001";  -- 00001rrr 1 INC   Rn
      when "00001101" => MCode <= "1001";  -- 00001rrr 1 INC   Rn
      when "00001110" => MCode <= "1001";  -- 00001rrr 1 INC   Rn
      when "00001111" => MCode <= "1001";  -- 00001rrr 1 INC   Rn
      when "00010000" => MCode <= "1011";  -- 00010000 3 JBC   bit addr, code addr
      when "00010001" => MCode <= "0010";  -- aaa10001 2 ACALL code addr
      when "00010010" => MCode <= "0011";  -- 00010010 3 LCALL code addr
      when "00010011" => MCode <= "0101";  -- 00010011 1 RRC   A
      when "00010100" => MCode <= "0101";  -- 00010100 1 DEC   A
      when "00010101" => MCode <= "1010";  -- 00010101 2 DEC   data addr
      when "00010110" => MCode <= "1001";  -- 0001011i 1 DEC   @Ri
      when "00010111" => MCode <= "1001";  -- 0001011i 1 DEC   @Ri
      when "00011000" => MCode <= "1001";  -- 00011rrr 1 DEC   Rn
      when "00011001" => MCode <= "1001";  -- 00011rrr 1 DEC   Rn
      when "00011010" => MCode <= "1001";  -- 00011rrr 1 DEC   Rn
      when "00011011" => MCode <= "1001";  -- 00011rrr 1 DEC   Rn
      when "00011100" => MCode <= "1001";  -- 00011rrr 1 DEC   Rn
      when "00011101" => MCode <= "1001";  -- 00011rrr 1 DEC   Rn
      when "00011110" => MCode <= "1001";  -- 00011rrr 1 DEC   Rn
      when "00011111" => MCode <= "1001";  -- 00011rrr 1 DEC   Rn
      when "00100000" => MCode <= "0011";  -- 00100000 3 JB    bit addr, code addr
      when "00100001" => MCode <= "0010";  -- aaa00001 2 AJMP  code addr
      when "00100010" => MCode <= "0001";  -- 00100010 1 RET
      when "00100011" => MCode <= "0101";  -- 00100011 1 RL    A
      when "00100100" => MCode <= "0110";  -- 00100100 2 ADD   A,#data
      when "00100101" => MCode <= "0110";  -- 00100101 2 ADD   A,data addr
      when "00100110" => MCode <= "0101";  -- 0010011i 1 ADD   A,@Ri
      when "00100111" => MCode <= "0101";  -- 0010011i 1 ADD   A,@Ri
      when "00101000" => MCode <= "0101";  -- 00101rrr 1 ADD   A,Rn
      when "00101001" => MCode <= "0101";  -- 00101rrr 1 ADD   A,Rn
      when "00101010" => MCode <= "0101";  -- 00101rrr 1 ADD   A,Rn
      when "00101011" => MCode <= "0101";  -- 00101rrr 1 ADD   A,Rn
      when "00101100" => MCode <= "0101";  -- 00101rrr 1 ADD   A,Rn
      when "00101101" => MCode <= "0101";  -- 00101rrr 1 ADD   A,Rn
      when "00101110" => MCode <= "0101";  -- 00101rrr 1 ADD   A,Rn
      when "00101111" => MCode <= "0101";  -- 00101rrr 1 ADD   A,Rn
      when "00110000" => MCode <= "0011";  -- 00110000 3 JNB   bit addr, code addr
      when "00110001" => MCode <= "0010";  -- aaa10001 2 ACALL code addr
      when "00110010" => MCode <= "0001";  -- 00110010 1 RETI
      when "00110011" => MCode <= "0101";  -- 00110011 1 RLC   A
      when "00110100" => MCode <= "0110";  -- 00110100 2 ADDC  A,#data
      when "00110101" => MCode <= "0110";  -- 00110101 2 ADDC  A,data addr
      when "00110110" => MCode <= "0101";  -- 0011011i 1 ADDC  A,@Ri
      when "00110111" => MCode <= "0101";  -- 0011011i 1 ADDC  A,@Ri
      when "00111000" => MCode <= "0101";  -- 00111rrr 1 ADDC  A,Rn
      when "00111001" => MCode <= "0101";  -- 00111rrr 1 ADDC  A,Rn
      when "00111010" => MCode <= "0101";  -- 00111rrr 1 ADDC  A,Rn
      when "00111011" => MCode <= "0101";  -- 00111rrr 1 ADDC  A,Rn
      when "00111100" => MCode <= "0101";  -- 00111rrr 1 ADDC  A,Rn
      when "00111101" => MCode <= "0101";  -- 00111rrr 1 ADDC  A,Rn
      when "00111110" => MCode <= "0101";  -- 00111rrr 1 ADDC  A,Rn
      when "00111111" => MCode <= "0101";  -- 00111rrr 1 ADDC  A,Rn
      when "01000000" => MCode <= "0010";  -- 01000000 2 JC    code addr
      when "01000001" => MCode <= "0010";  -- aaa00001 2 AJMP  code addr
      when "01000010" => MCode <= "1010";  -- 01000010 2 ORL   data addr,A
      when "01000011" => MCode <= "1011";  -- 01000011 3 ORL   data addr,#data
      when "01000100" => MCode <= "0110";  -- 01000100 2 ORL   A,#data
      when "01000101" => MCode <= "0110";  -- 01000101 2 ORL   A,data addr
      when "01000110" => MCode <= "0101";  -- 0100011i 1 ORL   A,@Ri
      when "01000111" => MCode <= "0101";  -- 0100011i 1 ORL   A,@Ri
      when "01001000" => MCode <= "0101";  -- 01001rrr 1 ORL   A,Rn
      when "01001001" => MCode <= "0101";  -- 01001rrr 1 ORL   A,Rn
      when "01001010" => MCode <= "0101";  -- 01001rrr 1 ORL   A,Rn
      when "01001011" => MCode <= "0101";  -- 01001rrr 1 ORL   A,Rn
      when "01001100" => MCode <= "0101";  -- 01001rrr 1 ORL   A,Rn
      when "01001101" => MCode <= "0101";  -- 01001rrr 1 ORL   A,Rn
      when "01001110" => MCode <= "0101";  -- 01001rrr 1 ORL   A,Rn
      when "01001111" => MCode <= "0101";  -- 01001rrr 1 ORL   A,Rn
      when "01010000" => MCode <= "0010";  -- 01010000 2 JNC   code addr
      when "01010001" => MCode <= "0010";  -- aaa10001 2 ACALL code addr
      when "01010010" => MCode <= "1010";  -- 01010010 2 ANL   data addr,A
      when "01010011" => MCode <= "1011";  -- 01010011 3 ANL   data addr,#data
      when "01010100" => MCode <= "0110";  -- 01010100 2 ANL   A,#data
      when "01010101" => MCode <= "0110";  -- 01010101 2 ANL   A,data addr
      when "01010110" => MCode <= "0101";  -- 0101011i 1 ANL   A,@Ri
      when "01010111" => MCode <= "0101";  -- 0101011i 1 ANL   A,@Ri
      when "01011000" => MCode <= "0101";  -- 01011rrr 1 ANL   A,Rn
      when "01011001" => MCode <= "0101";  -- 01011rrr 1 ANL   A,Rn
      when "01011010" => MCode <= "0101";  -- 01011rrr 1 ANL   A,Rn
      when "01011011" => MCode <= "0101";  -- 01011rrr 1 ANL   A,Rn
      when "01011100" => MCode <= "0101";  -- 01011rrr 1 ANL   A,Rn
      when "01011101" => MCode <= "0101";  -- 01011rrr 1 ANL   A,Rn
      when "01011110" => MCode <= "0101";  -- 01011rrr 1 ANL   A,Rn
      when "01011111" => MCode <= "0101";  -- 01011rrr 1 ANL   A,Rn
      when "01100000" => MCode <= "0010";  -- 01100000 2 JZ    code addr
      when "01100001" => MCode <= "0010";  -- aaa00001 2 AJMP  code addr
      when "01100010" => MCode <= "1010";  -- 01100010 2 XRL   data addr,A
      when "01100011" => MCode <= "1011";  -- 01100011 3 XRL   data addr,#data
      when "01100100" => MCode <= "0110";  -- 01100100 2 XRL   A,#data
      when "01100101" => MCode <= "0110";  -- 01100101 2 XRL   A,data addr
      when "01100110" => MCode <= "0101";  -- 0110011i 1 XRL   A,@Ri
      when "01100111" => MCode <= "0101";  -- 0110011i 1 XRL   A,@Ri
      when "01101000" => MCode <= "0101";  -- 01101rrr 1 XRL   A,Rn
      when "01101001" => MCode <= "0101";  -- 01101rrr 1 XRL   A,Rn
      when "01101010" => MCode <= "0101";  -- 01101rrr 1 XRL   A,Rn
      when "01101011" => MCode <= "0101";  -- 01101rrr 1 XRL   A,Rn
      when "01101100" => MCode <= "0101";  -- 01101rrr 1 XRL   A,Rn
      when "01101101" => MCode <= "0101";  -- 01101rrr 1 XRL   A,Rn
      when "01101110" => MCode <= "0101";  -- 01101rrr 1 XRL   A,Rn
      when "01101111" => MCode <= "0101";  -- 01101rrr 1 XRL   A,Rn
      when "01110000" => MCode <= "0010";  -- 01110000 2 JNZ   code addr
      when "01110001" => MCode <= "0010";  -- aaa10001 2 ACALL code addr
      when "01110010" => MCode <= "0010";  -- 01110010 2 ORL   C, bit addr
      when "01110011" => MCode <= "0001";  -- 01110011 1 JMP   @A+DPTR
      when "01110100" => MCode <= "0110";  -- 01110100 2 MOV   A,#data
      when "01110101" => MCode <= "1011";  -- 01110101 3 MOV   data addr,#data
      when "01110110" => MCode <= "1010";  -- 0111011i 2 MOV   @Ri,#data
      when "01110111" => MCode <= "1010";  -- 0111011i 2 MOV   @Ri,#data
      when "01111000" => MCode <= "1010";  -- 01111rrr 2 MOV   Rn,#data
      when "01111001" => MCode <= "1010";  -- 01111rrr 2 MOV   Rn,#data
      when "01111010" => MCode <= "1010";  -- 01111rrr 2 MOV   Rn,#data
      when "01111011" => MCode <= "1010";  -- 01111rrr 2 MOV   Rn,#data
      when "01111100" => MCode <= "1010";  -- 01111rrr 2 MOV   Rn,#data
      when "01111101" => MCode <= "1010";  -- 01111rrr 2 MOV   Rn,#data
      when "01111110" => MCode <= "1010";  -- 01111rrr 2 MOV   Rn,#data
      when "01111111" => MCode <= "1010";  -- 01111rrr 2 MOV   Rn,#data
      when "10000000" => MCode <= "0010";  -- 10000000 2 SJMP  code addr
      when "10000001" => MCode <= "0010";  -- aaa00001 2 AJMP  code addr
      when "10000010" => MCode <= "0010";  -- 10000010 2 ANL   C,bit addr
      when "10000011" => MCode <= "0011";  -- 10000011 1 MOVC  A,@A+PC
      when "10000100" => MCode <= "0001";  -- 10000100 1 DIV   AB
      when "10000101" => MCode <= "1011";  -- 10000101 3 MOV   data addr,data addr
      when "10000110" => MCode <= "1010";  -- 1000011i 2 MOV   data addr,@Ri
      when "10000111" => MCode <= "1010";  -- 1000011i 2 MOV   data addr,@Ri
      when "10001000" => MCode <= "1010";  -- 10001rrr 2 MOV   data addr,Rn
      when "10001001" => MCode <= "1010";  -- 10001rrr 2 MOV   data addr,Rn
      when "10001010" => MCode <= "1010";  -- 10001rrr 2 MOV   data addr,Rn
      when "10001011" => MCode <= "1010";  -- 10001rrr 2 MOV   data addr,Rn
      when "10001100" => MCode <= "1010";  -- 10001rrr 2 MOV   data addr,Rn
      when "10001101" => MCode <= "1010";  -- 10001rrr 2 MOV   data addr,Rn
      when "10001110" => MCode <= "1010";  -- 10001rrr 2 MOV   data addr,Rn
      when "10001111" => MCode <= "1010";  -- 10001rrr 2 MOV   data addr,Rn
      when "10010000" => MCode <= "0011";  -- 10010000 3 MOV   DPTR,#data
      when "10010001" => MCode <= "0010";  -- aaa10001 2 ACALL code addr
      when "10010010" => MCode <= "1010";  -- 10010010 2 MOV   bit addr,C
      when "10010011" => MCode <= "0011";  -- 10010011 1 MOVC  A,@A+DPTR
      when "10010100" => MCode <= "0110";  -- 10010100 2 SUBB  A,#data
      when "10010101" => MCode <= "0110";  -- 10010101 2 SUBB  A,data addr
      when "10010110" => MCode <= "0101";  -- 1001011i 1 SUBB  A,@Ri
      when "10010111" => MCode <= "0101";  -- 1001011i 1 SUBB  A,@Ri
      when "10011000" => MCode <= "0101";  -- 10011rrr 1 SUBB  A,Rn
      when "10011001" => MCode <= "0101";  -- 10011rrr 1 SUBB  A,Rn
      when "10011010" => MCode <= "0101";  -- 10011rrr 1 SUBB  A,Rn
      when "10011011" => MCode <= "0101";  -- 10011rrr 1 SUBB  A,Rn
      when "10011100" => MCode <= "0101";  -- 10011rrr 1 SUBB  A,Rn
      when "10011101" => MCode <= "0101";  -- 10011rrr 1 SUBB  A,Rn
      when "10011110" => MCode <= "0101";  -- 10011rrr 1 SUBB  A,Rn
      when "10011111" => MCode <= "0101";  -- 10011rrr 1 SUBB  A,Rn
      when "10100000" => MCode <= "0010";  -- 10100000 2 ORL   C,/bit addr
      when "10100001" => MCode <= "0010";  -- aaa00001 2 AJMP  code addr
      when "10100010" => MCode <= "0010";  -- 10100010 2 MOV   C,bit addr
      when "10100011" => MCode <= "0001";  -- 10100011 1 INC   DPTR
      when "10100100" => MCode <= "0101";  -- 10100100 1 MUL   AB
      when "10100101" => MCode <= "0001";  -- 10100101   reserved
      when "10100110" => MCode <= "1010";  -- 1010011i 2 MOV   @Ri,data addr
      when "10100111" => MCode <= "1010";  -- 1010011i 2 MOV   @Ri,data addr
      when "10101000" => MCode <= "1010";  -- 10101rrr 2 MOV   Rn,data addr
      when "10101001" => MCode <= "1010";  -- 10101rrr 2 MOV   Rn,data addr
      when "10101010" => MCode <= "1010";  -- 10101rrr 2 MOV   Rn,data addr
      when "10101011" => MCode <= "1010";  -- 10101rrr 2 MOV   Rn,data addr
      when "10101100" => MCode <= "1010";  -- 10101rrr 2 MOV   Rn,data addr
      when "10101101" => MCode <= "1010";  -- 10101rrr 2 MOV   Rn,data addr
      when "10101110" => MCode <= "1010";  -- 10101rrr 2 MOV   Rn,data addr
      when "10101111" => MCode <= "1010";  -- 10101rrr 2 MOV   Rn,data addr
      when "10110000" => MCode <= "0010";  -- 10110000 2 ANL   C,/bit addr
      when "10110001" => MCode <= "0010";  -- aaa10001 2 ACALL code addr
      when "10110010" => MCode <= "1010";  -- 10110010 2 CPL   bit addr
      when "10110011" => MCode <= "0001";  -- 10110011 1 CPL   C
      when "10110100" => MCode <= "0011";  -- 10110100 3 CJNE  A,#data,code addr
      when "10110101" => MCode <= "0011";  -- 10110101 3 CJNE  A,data addr,code addr
      when "10110110" => MCode <= "0011";  -- 1011011i 3 CJNE  @Ri,#data,code addr
      when "10110111" => MCode <= "0011";  -- 1011011i 3 CJNE  @Ri,#data,code addr
      when "10111000" => MCode <= "0011";  -- 10111rrr 3 CJNE  Rn,#data,code addr
      when "10111001" => MCode <= "0011";  -- 10111rrr 3 CJNE  Rn,#data,code addr
      when "10111010" => MCode <= "0011";  -- 10111rrr 3 CJNE  Rn,#data,code addr
      when "10111011" => MCode <= "0011";  -- 10111rrr 3 CJNE  Rn,#data,code addr
      when "10111100" => MCode <= "0011";  -- 10111rrr 3 CJNE  Rn,#data,code addr
      when "10111101" => MCode <= "0011";  -- 10111rrr 3 CJNE  Rn,#data,code addr
      when "10111110" => MCode <= "0011";  -- 10111rrr 3 CJNE  Rn,#data,code addr
      when "10111111" => MCode <= "0011";  -- 10111rrr 3 CJNE  Rn,#data,code addr
      when "11000000" => MCode <= "1010";  -- 11000000 2 PUSH  data addr
      when "11000001" => MCode <= "0010";  -- aaa00001 2 AJMP  code addr
      when "11000010" => MCode <= "1010";  -- 11000010 2 CLR   bit addr
      when "11000011" => MCode <= "0001";  -- 11000011 1 CLR   C
      when "11000100" => MCode <= "0101";  -- 11000100 1 SWAP  A
      when "11000101" => MCode <= "1110";  -- 11000101 2 XCH   A,data addr
      when "11000110" => MCode <= "1101";  -- 1100011i 1 XCH   A,@Ri
      when "11000111" => MCode <= "1101";  -- 1100011i 1 XCH   A,@Ri
      when "11001000" => MCode <= "1101";  -- 11001rrr 1 XCH   A,Rn
      when "11001001" => MCode <= "1101";  -- 11001rrr 1 XCH   A,Rn
      when "11001010" => MCode <= "1101";  -- 11001rrr 1 XCH   A,Rn
      when "11001011" => MCode <= "1101";  -- 11001rrr 1 XCH   A,Rn
      when "11001100" => MCode <= "1101";  -- 11001rrr 1 XCH   A,Rn
      when "11001101" => MCode <= "1101";  -- 11001rrr 1 XCH   A,Rn
      when "11001110" => MCode <= "1101";  -- 11001rrr 1 XCH   A,Rn
      when "11001111" => MCode <= "1101";  -- 11001rrr 1 XCH   A,Rn
      when "11010000" => MCode <= "1010";  -- 11010000 2 POP   data addr
      when "11010001" => MCode <= "0010";  -- aaa10001 2 ACALL code addr
      when "11010010" => MCode <= "1010";  -- 11010010 2 SETB  bit addr
      when "11010011" => MCode <= "0001";  -- 11010011 1 SETB  C
      when "11010100" => MCode <= "0101";  -- 11010100 1 DA    A
      when "11010101" => MCode <= "1011";  -- 11010101 3 DJNZ  data addr, code addr
      when "11010110" => MCode <= "1101";  -- 1101011i 1 XCHD  A,@Ri
      when "11010111" => MCode <= "1101";  -- 1101011i 1 XCHD  A,@Ri
      when "11011000" => MCode <= "1010";  -- 11011rrr 2 DJNZ  Rn,code addr
      when "11011001" => MCode <= "1010";  -- 11011rrr 2 DJNZ  Rn,code addr
      when "11011010" => MCode <= "1010";  -- 11011rrr 2 DJNZ  Rn,code addr
      when "11011011" => MCode <= "1010";  -- 11011rrr 2 DJNZ  Rn,code addr
      when "11011100" => MCode <= "1010";  -- 11011rrr 2 DJNZ  Rn,code addr
      when "11011101" => MCode <= "1010";  -- 11011rrr 2 DJNZ  Rn,code addr
      when "11011110" => MCode <= "1010";  -- 11011rrr 2 DJNZ  Rn,code addr
      when "11011111" => MCode <= "1010";  -- 11011rrr 2 DJNZ  Rn,code addr
      when "11100000" => MCode <= "0101";  -- 11100000 1 MOVX  A,@DPTR
      when "11100001" => MCode <= "0010";  -- aaa00001 2 AJMP  code addr
      when "11100010" => MCode <= "0101";  -- 1110001i 1 MOVX  A,@Ri
      when "11100011" => MCode <= "0101";  -- 1110001i 1 MOVX  A,@Ri
      when "11100100" => MCode <= "0101";  -- 11100100 1 CLR   A
      when "11100101" => MCode <= "0110";  -- 11100101 2 MOV   A,data addr
      when "11100110" => MCode <= "0101";  -- 1110011i 1 MOV   A,@Ri
      when "11100111" => MCode <= "0101";  -- 1110011i 1 MOV   A,@Ri
      when "11101000" => MCode <= "0101";  -- 11101rrr 1 MOV   A,Rn
      when "11101001" => MCode <= "0101";  -- 11101rrr 1 MOV   A,Rn
      when "11101010" => MCode <= "0101";  -- 11101rrr 1 MOV   A,Rn
      when "11101011" => MCode <= "0101";  -- 11101rrr 1 MOV   A,Rn
      when "11101100" => MCode <= "0101";  -- 11101rrr 1 MOV   A,Rn
      when "11101101" => MCode <= "0101";  -- 11101rrr 1 MOV   A,Rn
      when "11101110" => MCode <= "0101";  -- 11101rrr 1 MOV   A,Rn
      when "11101111" => MCode <= "0101";  -- 11101rrr 1 MOV   A,Rn
      when "11110000" => MCode <= "0001";  -- 11110000 1 MOVX  @DPTR,A
      when "11110001" => MCode <= "0010";  -- aaa10001 2 ACALL code addr
      when "11110010" => MCode <= "0001";  -- 1111001i 1 MOVX  @Ri,A
      when "11110011" => MCode <= "0001";  -- 1111001i 1 MOVX  @Ri,A
      when "11110100" => MCode <= "0101";  -- 11110100 1 CPL   A
      when "11110101" => MCode <= "1010";  -- 11110101 2 MOV   data addr,A
      when "11110110" => MCode <= "1001";  -- 1111011i 1 MOV   @Ri,A
      when "11110111" => MCode <= "1001";  -- 1111011i 1 MOV   @Ri,A
      when "11111000" => MCode <= "1001";  -- 11111rrr 1 MOV   Rn,A
      when "11111001" => MCode <= "1001";  -- 11111rrr 1 MOV   Rn,A
      when "11111010" => MCode <= "1001";  -- 11111rrr 1 MOV   Rn,A
      when "11111011" => MCode <= "1001";  -- 11111rrr 1 MOV   Rn,A
      when "11111100" => MCode <= "1001";  -- 11111rrr 1 MOV   Rn,A
      when "11111101" => MCode <= "1001";  -- 11111rrr 1 MOV   Rn,A
      when "11111110" => MCode <= "1001";  -- 11111rrr 1 MOV   Rn,A
      when "11111111" => MCode <= "1001";  -- 11111rrr 1 MOV   Rn,A
      when others     => MCode <= "----";
    end case;
  end process;

end;

-----------------------------------------------------------------------------------------

