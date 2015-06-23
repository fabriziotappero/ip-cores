-------------------------------------------------------------------------------
-- Title      : ParToI2s
-- Project    : 
-------------------------------------------------------------------------------
-- File       : ParToI2s.vhd
-- Author     : Voggeneder Andreas, Truhlar Günther
-- Company    : 
-- Created    : 2002-11-20
-- Last update: 2006-02-01
-- Platform   : 
-- Standard   : VHDL'87
-------------------------------------------------------------------------------
-- Description: realizes the connection from the DSP to the I2s-interface
-------------------------------------------------------------------------------
-- Copyright (c) 2002 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2002-11-20  1.0      hse00044        Created
-------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
--use IEEE.std_logic_arith.all;
--use work.DffGlobal.all;


entity ParToI2s is
  generic (
    SampleSize_g : natural := 16);
  port (
    Clk_i           : in  std_ulogic;
    Reset_i         : in  std_ulogic;
    SampleLeft_i    : in  std_ulogic_vector(SampleSize_g - 1 downto 0);
    SampleRight_i   : in  std_ulogic_vector(SampleSize_g - 1 downto 0);
    StrobeLeft_i    : in  std_ulogic;
    StrobeRight_i   : in  std_ulogic;
    SampleAck_o     : out std_ulogic;
    WaitForSample_o : out std_ulogic;
    SClk_i          : in  std_ulogic;
    LRClk_i         : in  std_ulogic;
    SdnyData_o      : out std_ulogic);
end ParToI2s;

architecture rtl of ParToI2s is

  constant activated_cn   : std_ulogic := '0';
  constant inactivated_cn : std_ulogic := '1';
  constant activated_c   : std_ulogic := '1';
  constant inactivated_c : std_ulogic := '0';
  constant ResetActive_c : std_ulogic := '0';

  type   state_t is (IDLE, WAITSAMPLE, WAITLRCLK0, TRANSMITLEFT, WAITLRCLK1, TRANSMITRIGHT);
  signal state, nextstate           : state_t;
  signal sReg                       : std_ulogic_vector(SampleSize_g-1 downto 0);
  signal Cnt                        : std_ulogic_vector(4 downto 0);
  signal LeftSampleReg              : std_ulogic_vector(SampleSize_g - 1 downto 0);
  signal RightSampleReg, tempReg    : std_ulogic_vector(SampleSize_g - 1 downto 0);
  signal LRClkOld                   : std_ulogic;
  signal SClkOld                    : std_ulogic;
  signal Finished, loaded           : std_ulogic;
  signal LSampleValid, RSampleValid : std_ulogic;
  
  
begin  -- rtl

--  Finished <= '1' when Cnt = "11111" else '0';
    Finished <= '1' when Cnt = std_ulogic_vector(to_unsigned(SampleSize_g,Cnt'high+1)) else '0';

  -- purpose: Sequential state of the statemachine
  seq : process (Clk_i, Reset_i)
  begin  -- process seq
    if Reset_i = ResetActive_c then
      state <= IDLE;
    elsif Clk_i'event and Clk_i = '1' then
      state <= nextstate;
    end if;
  end process seq;


  Comb : process (state, LSampleValid, RSampleValid, LRClk_i, LRClkOld, Finished, SClkOld, SClk_i)
  begin  -- process Comb
    nextstate   <= state;
    SampleAck_o <= '0';
    WaitForSample_o <= '0';
    case state is
      when IDLE       => nextstate   <= WAITSAMPLE;
      when WAITSAMPLE => WaitForSample_o <= '1';
                         if (LSampleValid and RSampleValid) = '1' then
                           nextstate   <= WAITLRCLK0;
                         end if;
      when WAITLRCLK0 => if ((LRClk_i xor LRClkOld) and LRClkOld) = '1' then
                           nextstate <= TRANSMITLEFT;
                           SampleAck_o <= '1';
                         end if;
      when TRANSMITLEFT => if Finished = '1' and ((SClkOld xor SClk_i) and SCLKOld)='1' then
                             nextstate <= WAITLRCLK1;
                           end if;
      when WAITLRCLK1 => if ((LRClk_i xor LRClkOld) and LRClk_i) = '1' then
                           nextstate <= TRANSMITRIGHT;
                         end if;
      when TRANSMITRIGHT => if Finished = '1' and ((SClkOld xor SClk_i) and SCLKOld)='1' then
                              nextstate <= WAITSAMPLE;
                            end if;
      when others => null;
    end case;
  end process Comb;

  shiftreg : process (Clk_i, Reset_i)
  begin  -- process shiftreg
    if Reset_i = ResetActive_c then
      SdnyData_o     <= '0';
      sReg           <= (others => '0');
      Cnt            <= (others => '0');
      LRClkOld       <= '0';
      LeftSampleReg  <= (others => '0');
      RightSampleReg <= (others => '0');
      tempReg        <= (others => '0');
      LSampleValid   <= '0';
      RSampleValid   <= '0';
      loaded         <= '0';
      SClkOld        <= '0';
    elsif Clk_i'event and Clk_i = '1' then
      LRClkOld     <= LRClk_i;
      SClkOld      <= SClk_i;
      if StrobeLeft_i = '1' then
        LeftSampleReg <= SampleLeft_i;
        LSampleValid  <= '1';
--        sReg(SampleSize_g - 1 downto 0) <= SampleLeft_i;
      end if;
      if StrobeRight_i = '1' then
        RightSampleReg <= SampleRight_i;
        RSampleValid   <= '1';
      end if;

      case state is
        when WAITSAMPLE =>
          loaded <= '0';
          
        when WAITLRCLK0 =>
          -- ensure the regs are only loaded once
          SdnyData_o <= '0';
          if loaded = '0' then
            loaded  <= '1';
            sReg    <= LeftSampleReg;
            LSampleValid  <= '0';
            RSampleValid  <= '0';
            tempReg <= RightSampleReg;
            Cnt     <= (others => '0');
            
--             Cnt <=std_ulogic_vector(to_unsigned(1,Cnt'high+1));
--             SdnyData_o <= LeftSampleReg(SampleSize_g-1);
--             sReg       <= LeftSampleReg(SampleSize_g-2 downto 0)&"0";
          end if;
        when TRANSMITLEFT | TRANSMITRIGHT =>
          if Finished = '0' and ((SClk_i xor SClkOld) and SClkOld) = '1' then
            SdnyData_o <= sReg(SampleSize_g-1);
            sReg       <= sReg(SampleSize_g-2 downto 0)&"0";
            Cnt        <= std_ulogic_vector(unsigned(Cnt) + 1);
          end if;

        when WAITLRCLK1 =>
          SdnyData_o <= '0';  
          sReg <= tempReg;
          Cnt  <= (others => '0');

--           Cnt <=std_ulogic_vector(to_unsigned(1,Cnt'high+1));
--           SdnyData_o <= tempReg(SampleSize_g-1);
--           sReg       <= tempReg(SampleSize_g-2 downto 0)&"0";
        when others => null;
      end case;

    end if;
  end process shiftreg;


end rtl;


