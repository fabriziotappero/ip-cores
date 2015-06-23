-------------------------------------------------------------------------------
-- Title      : Parametrilayze based on SRL16 shift register FIFO
-- Project    : 
-------------------------------------------------------------------------------
-- File       : fifo_srl_uni.vhd
-- Author     : Tomasz Turek  <tomasz.turek@gmail.com>
-- Company    : SzuWar INC
-- Created    : 13:27:31 14-03-2010
-- Last update: 15:02:32 21-03-2010
-- Platform   : Xilinx ISE 10.1.03
-- Standard   : VHDL'93
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------
-- Copyright (c) 2010 SzuWar INC
-------------------------------------------------------------------------------
-- Revisions  :
-- Date                  Version  Author  Description
-- 13:27:31 14-03-2010   1.0      szuwarek  Created
-------------------------------------------------------------------------------
-- Version 1.1 unlimited size of Input and Output register.
-- Version 1.0

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_arith.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

Library UNISIM;
use UNISIM.vcomponents.all;

entity fifo_srl_uni is
   
   generic (
      iDataWidth        : integer range 1 to 32   := 17;
      ififoWidth        : integer range 1 to 1023 := 32;
      iInputReg         : integer range 0 to 3    := 0;
      iOutputReg        : integer range 0 to 3    := 2;
      iFullFlagOfSet    : integer range 0 to 1021 := 2;
      iEmptyFlagOfSet   : integer range 0 to 1021 := 5;
      iSizeDelayCounter : integer range 5 to 11   := 6
      );

   port (
      CLK_I          : in  std_logic;
      DATA_I         : in  std_logic_vector(iDataWidth - 1 downto 0);
      DATA_O         : out std_logic_vector(iDataWidth - 1 downto 0);
      WRITE_ENABLE_I : in  std_logic;
      READ_ENABLE_I  : in  std_logic;
      READ_VALID_O   : out std_logic;
      FIFO_COUNT_O   : out std_logic_vector(iSizeDelayCounter - 1 downto 0);
      FULL_FLAG_O    : out std_logic;
      EMPTY_FLAG_O   : out std_logic
      );

end entity fifo_srl_uni;

architecture fifo_srl_uni_rtl of fifo_srl_uni is

-------------------------------------------------------------------------------
-- functions --
-------------------------------------------------------------------------------
   function f_srl_count (constant c_fifo_size : integer) return integer is

      variable i_temp  : integer;
      variable i_count : integer;
      
   begin  -- function f_srl_count

      i_temp := c_fifo_size;
      i_count := 0;
      
      for i in 0 to 64 loop

         if i_temp < 1 then

            if i_count = 0 then

               i_count := i;

            else

               i_count := i_count;
               
            end if;
            
         else

            i_temp := i_temp - 16;
            
         end if;
         
      end loop;  -- i

      return i_count;
      
   end function f_srl_count;
   
-------------------------------------------------------------------------------
-- constants --
-------------------------------------------------------------------------------
   constant c_srl_count : integer range 0 to 64 := f_srl_count(ififoWidth);
   
-------------------------------------------------------------------------------
-- types --
-------------------------------------------------------------------------------
   type type_in_reg    is array (0 to iInputReg - 1)   of std_logic_vector(iDataWidth - 1 downto 0);
   type type_out_reg   is array (0 to iOutputReg)      of std_logic_vector(iDataWidth - 1 downto 0);
   type type_data_path is array (0 to c_srl_count - 1) of std_logic_vector(iDataWidth - 1 downto 0);
   type type_srl_path  is array (0 to c_srl_count)    of std_logic_vector(iDataWidth - 1 downto 0);
   
-------------------------------------------------------------------------------
-- signals --
-------------------------------------------------------------------------------
   signal v_delay_counter : std_logic_vector(iSizeDelayCounter - 1 downto 0) := (others => '0');
   signal v_size_counter  : std_logic_vector(iSizeDelayCounter - 1 downto 0) := (others => '0');
   signal v_zeros         : std_logic_vector(iSizeDelayCounter - 1 downto 0) := (others => '0');
   signal v_WRITE_ENABLE  : std_logic_vector(iInputReg downto 0);
   signal v_READ_ENABLE   : std_logic_vector(iOutputReg downto 0);
   signal v_valid_delay   : std_logic_vector(iOutputReg downto 0);
   signal i_size_counter  : integer range 0 to 1023 := 0;
   signal i_srl_select    : integer range 0 to 64 := 0;
   signal i_temp          : integer range 0 to 64;
   signal t_mux_in        : type_data_path;
   signal t_srl_in        : type_srl_path;
   signal t_mux_out       : type_out_reg;
   signal t_reg_in        : type_in_reg;
   signal one_delay       : std_logic := '0';
   signal ce_master       : std_logic;
   signal full_capacity   : std_logic;
   signal data_valid_off  : std_logic;

begin  -- architecture fifo_srl_uni_r

   v_zeros <= (others => '0');

   i_srl_select         <= conv_integer((v_delay_counter(iSizeDelayCounter - 1 downto 4)));
   i_size_counter       <= conv_integer(v_size_counter);

   ce_master            <= v_WRITE_ENABLE(0) and (not full_capacity);
   
   full_capacity        <= '0' when i_size_counter < ififoWidth else '1';

   t_mux_out(0)         <= t_mux_in(i_srl_select);      
   READ_VALID_O         <= v_READ_ENABLE(0) and (not v_valid_delay(0));
   FIFO_COUNT_O         <= v_size_counter;
   
-------------------------------------------------------------------------------
-- Input Register --
-------------------------------------------------------------------------------
   GR0: if iInputReg = 0 generate

      t_srl_in(0) <= DATA_I;
      v_WRITE_ENABLE(iInputReg) <= WRITE_ENABLE_I;
      
   end generate GR0;

   GR1: if iInputReg = 1 generate

      t_srl_in(0) <= t_reg_in(0);
      v_WRITE_ENABLE(iInputReg) <= WRITE_ENABLE_I;
      
      P1: process (CLK_I) is
      begin  -- process P1

         if rising_edge(CLK_I) then

            t_reg_in(0) <= DATA_I;
            v_WRITE_ENABLE(0) <= v_WRITE_ENABLE(iInputReg);
            
         end if;
         
      end process P1;
      
   end generate GR1;

   GR2: if iInputReg > 1 generate

      t_srl_in(0) <= t_reg_in(0);
      v_WRITE_ENABLE(iInputReg) <= WRITE_ENABLE_I;

      P1: process (CLK_I) is
      begin  -- process P1

         if rising_edge(CLK_I) then

            t_reg_in(iInputReg - 1) <= DATA_I;
            t_reg_in(0 to iInputReg - 2) <= t_reg_in(1 to iInputReg -1);
            v_WRITE_ENABLE(iInputReg - 1 downto 0) <= v_WRITE_ENABLE(iInputReg downto 1);
            
         end if;
         
      end process P1;
      
   end generate GR2;
-------------------------------------------------------------------------------
-- Input Register --
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- FIFO Core, SRL16E based --
-------------------------------------------------------------------------------
   G1: for i in 0 to c_srl_count - 1 generate

      G0: for j in 0 to iDataWidth - 1 generate

         SRLC16_inst : SRLC16E
            port map
            (
                  Q => t_mux_in(i)(j), -- SRL data output
                  Q15 => t_srl_in(i+1)(j), -- Carry output (connect to next SRL)
                  A0 => v_delay_counter(0), -- Select[0] input
                  A1 => v_delay_counter(1), -- Select[1] input
                  A2 => v_delay_counter(2), -- Select[2] input
                  A3 => v_delay_counter(3), -- Select[3] input
                  CE => ce_master, -- Clock enable input
                  CLK => CLK_I, -- Clock input
                  D => t_srl_in(i)(j) -- SRL data input
                  );
         
      end generate G0;
      
   end generate G1;
-------------------------------------------------------------------------------
-- FIFO Core, SRL16E based --
-------------------------------------------------------------------------------
   
   P0: process (CLK_I) is
   begin  -- process P0

      if rising_edge(CLK_I) then

         if (v_WRITE_ENABLE(0) = '1') and (READ_ENABLE_I = '0') and (i_size_counter < ififoWidth) then

            if one_delay = '1' then

               v_delay_counter <= v_delay_counter + 1;
               one_delay <= '1';

            else

               one_delay <= '1';
               v_delay_counter <= v_delay_counter;
               
            end if;

            v_size_counter <= v_size_counter + 1;

         elsif (v_WRITE_ENABLE(0) = '0') and (READ_ENABLE_I = '1') and (i_size_counter > 0) then

            if v_delay_counter = v_zeros then

               one_delay <= '0';

            else

               one_delay <= '1';
               v_delay_counter <= v_delay_counter - 1;
               
            end if;
            
            v_size_counter <= v_size_counter - 1;
            
         else

            v_delay_counter <= v_delay_counter;
            v_size_counter <= v_size_counter;
            one_delay <= one_delay;
            
         end if;
         
      end if;
      
   end process P0;

   data_valid_off <= '1' when i_size_counter = 0 else '0';
-------------------------------------------------------------------------------
-- Output Register --
-------------------------------------------------------------------------------

   -- size of output register: 0 --
   GM0: if iOutputReg = 0 generate

      DATA_O <= t_mux_out(0);
      v_READ_ENABLE(0) <= READ_ENABLE_I;
      v_valid_delay(0) <= data_valid_off;
      
   end generate GM0;

   -- size of output register: 1 --
   GM1: if iOutputReg = 1 generate

      DATA_O <= t_mux_out(1);
      v_READ_ENABLE(1) <= READ_ENABLE_I;
      
      
      P2: process (CLK_I) is
      begin  -- process P2

         if rising_edge(CLK_I) then

            v_READ_ENABLE(0) <= v_READ_ENABLE(1);
            t_mux_out(1) <= t_mux_out(0);
            v_valid_delay(0) <= data_valid_off;
            
         end if;
         
      end process P2;
      
   end generate GM1;

   -- size of output register: > 1 --
   GM2: if iOutputReg > 1 generate

      DATA_O <= t_mux_out(iOutputReg);
      v_READ_ENABLE(iOutputReg) <= READ_ENABLE_I;

      P2: process (CLK_I) is
      begin  -- process P2

         if rising_edge(CLK_I) then

            v_READ_ENABLE(iOutputReg - 1 downto 0) <= v_READ_ENABLE(iOutputReg downto 1);
            t_mux_out(1 to iOutputReg) <= t_mux_out(0 to iOutputReg - 1);
            v_valid_delay(iOutputReg - 1 downto 0) <= data_valid_off&v_valid_delay(iOutputReg - 1 downto 1);
            
         end if;
         
      end process P2;
      
   end generate GM2;
-------------------------------------------------------------------------------
-- Output Register --
-------------------------------------------------------------------------------
   
-------------------------------------------------------------------------------
-- Flag Generators --
-------------------------------------------------------------------------------
   EMPTY_FLAG_O <= '0' when (i_size_counter)> iEmptyFlagOfSet             else '1';
   FULL_FLAG_O  <= '1' when i_size_counter >= ififoWidth - iFullFlagOfSet else '0';
-------------------------------------------------------------------------------
-- Flag Generators --
-------------------------------------------------------------------------------
   
end architecture fifo_srl_uni_rtl;

