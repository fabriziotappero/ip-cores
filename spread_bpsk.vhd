-------------------------------------------------------------------------------
-- Title      : Spread using spreading sequence based on BPSK constelation.
-- Project    : 
-------------------------------------------------------------------------------
-- File       : spread_bpsk.vhd
-- Author     : Tomasz Turek  <tomasz.turek@gmail.com>
-- Company    : SzuWar INC
-- Created    : 21:37:13 20-03-2010
-- Last update: 09:03:26 11-05-2010
-- Platform   : Xilinx ISE 10.1.03
-- Standard   : VHDL'93
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------
-- Copyright (c) 2010 SzuWar INC
-------------------------------------------------------------------------------
-- Revisions  :
-- Date                  Version  Author  Description
-- 21:37:13 20-03-2010   1.0      szuwarek  Created
-------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_arith.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

Library UNISIM;
use UNISIM.vcomponents.all;

entity spread_bpsk is

   generic (
         iDataWidith        : integer range 1 to 16  := 2;
         iSingleValueSpread : integer range 2 to 255 := 17;
         iTrigerType        : integer range 0 to 2   := 2
         );

   port (
         CLK_I             : in  std_logic;
         RESET_I           : in  std_logic;
         DATA_I            : in  std_logic_vector(iDataWidith - 1 downto 0);
         DATA_VALID_I      : in  std_logic;
         TRIGER_I          : in  std_logic;
         SPREAD_SEQUENCE_I : in  std_logic_vector(iSingleValueSpread - 1 downto 0);
         DATA_O            : out std_logic_vector(iDataWidith - 1 downto 0);
         DATA_VALID_O      : out std_logic;
         READY_FOR_DATA_O  : out std_logic
         );

end entity spread_bpsk;

architecture rtl of spread_bpsk is
   
-------------------------------------------------------------------------------
-- signals --
-------------------------------------------------------------------------------
   signal fifo_ce               : std_logic;
   signal fifo_read             : std_logic;
   signal FF_fifo_read          : std_logic;
   signal fifo_empty            : std_logic;
   signal rfd                   : std_logic;
   signal data_processing       : std_logic;
   signal v_data_processing     : std_logic_vector(1 downto 0);
   signal spread_triger         : std_logic;
   signal v_fifo_data           : std_logic_vector(iDataWidith - 1 downto 0);
   signal v_data_in             : std_logic_vector(iDataWidith - 1 downto 0);
   signal v_fifo_data_spread    : std_logic_vector(iDataWidith - 1 downto 0);
   signal v_spread_count        : std_logic_vector(7 downto 0);
   signal v_delay_counter       : std_logic_vector(3 downto 0) := x"0";
   signal i_delay_counter       : integer range 0 to 16 := 0;
   
begin  -- architecture rtl

-------------------------------------------------------------------------------
-- FIFO IN --
-------------------------------------------------------------------------------

   rfd                  <= '1' when v_delay_counter < x"f" else '0';
   READY_FOR_DATA_O     <= rfd;
   fifo_empty           <= '1' when i_delay_counter = 0 else '0';
   fifo_ce              <= '1' when (DATA_VALID_I = '1') and (fifo_read = '1') else
                           DATA_VALID_I and rfd ;

   DATA_VALID_O         <= v_data_processing(0);
   v_data_in            <= DATA_I when fifo_ce = '1' else
                           (others => 'Z');
   
   G0: for i in 0 to (iDataWidith - 1) generate

      FIFO_IN :
         SRLC16E
            port map
            (
                  Q => v_fifo_data(i), -- SRL data output
                  A0 => v_delay_counter(0), -- Select[0] input
                  A1 => v_delay_counter(1), -- Select[1] input
                  A2 => v_delay_counter(2), -- Select[2] input
                  A3 => v_delay_counter(3), -- Select[3] input
                  CE => fifo_ce, -- Clock enable input
                  CLK => CLK_I, -- Clock input
                  D => v_data_in(i) -- SRL data input
                  );
      
   end generate G0;

   P0: process (CLK_I) is
   begin  -- process P0

      if rising_edge(CLK_I) then

         if RESET_I = '1' then

            i_delay_counter <= 0;
            v_delay_counter <= x"0";
            
         else
            
            if (DATA_VALID_I = '1') and (fifo_read = '0') and (rfd = '1') then

               if i_delay_counter < 1 then
                  
                  i_delay_counter <= i_delay_counter + 1;
                  v_delay_counter <= x"0";

               else

                  i_delay_counter <= i_delay_counter + 1;
                  v_delay_counter <= v_delay_counter + 1;
                  
               end if;

            elsif (DATA_VALID_I = '0') and (fifo_read = '1') and (fifo_empty = '0') then

               if ((i_delay_counter < 2) and (i_delay_counter > 0)) then
                  
                  i_delay_counter <= i_delay_counter - 1;
                  v_delay_counter <= x"0";

               else

                  i_delay_counter <= i_delay_counter - 1;
                  v_delay_counter <= v_delay_counter - 1;
                  
               end if;

            else

               i_delay_counter <= i_delay_counter;
               v_delay_counter <= v_delay_counter;
               
            end if;
            
         end if;
         
      end if;
      
   end process P0;
   
-------------------------------------------------------------------------------
-- FIFO IN --
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Triger --
-------------------------------------------------------------------------------
   P1: process (CLK_I) is
   begin  -- process P1

      if rising_edge(CLK_I) then

         if RESET_I = '1' then


         else

            if iTrigerType = 0 then     -- ce

               triger <= TRIGER_I;
               
            end if;
            
            
         end if;
         
      end if;
      
   end process P1;
   
-------------------------------------------------------------------------------
-- Triger --
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- SPREAD --
-------------------------------------------------------------------------------
   P2: process (CLK_I) is
   begin  -- process P2

      if rising_edge(CLK_I) then

         if RESET_I = '1' then

            data_processing     <= '0';
            v_data_processing   <= "00";
            fifo_read           <= '0';
            FF_fifo_read        <= '0';
            DATA_O              <= (others => '0');
            v_spread_count      <= (others => '0');
            v_fifo_data_spread  <= (others => '0');
            
         else

            v_data_processing           <= v_data_processing(0) & data_processing;
            FF_fifo_read                <= fifo_read;
            
            if ((fifo_empty = '0') and (data_processing = '0')) then

               data_processing          <= '1';
               fifo_read                <= '1';
               v_spread_count           <= (others => '0');
               v_fifo_data_spread       <= v_fifo_data;

            else

               if v_spread_count = conv_std_logic_vector(iSingleValueSpread - 1 , 8) then

                  v_spread_count        <= v_spread_count;

                  data_procesing        <= '0';
                  
               else

                  v_spread_count        <= v_spread_count + 1;
                  
               end if;

               fifo_read                <= '0';
               
               for i in 0 to iDataWidith - 1 loop
                  
                  if v_fifo_data_spread(i) = '1' then

                     DATA_O(i)          <= SPREAD_SEQUENCE_I(conv_integer(v_spread_count));
                     
                  elsif v_fifo_data_spread(i) = '0' then

                     DATA_O(i)          <= not SPREAD_SEQUENCE_I(conv_integer(v_spread_count));
                     
                  end if;

               end loop;  -- i
               
            end if;
            
         end if;
         
      end if;
      
   end process P2;
   
-------------------------------------------------------------------------------
-- SPREAD --
-------------------------------------------------------------------------------
   
end architecture rtl;
