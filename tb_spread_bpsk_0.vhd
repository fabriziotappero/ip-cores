-------------------------------------------------------------------------------
-- Title      : Testbench for spread_bpsk.vhd
-- Project    : 
-------------------------------------------------------------------------------
-- File       : tb_spread_bpsk_0.vhd
-- Author     : Tomasz Turek  <tomasz.turek@gmail.com>
-- Company    : SzuWar INC
-- Created    : 22:24:52 26-03-2010
-- Last update: 09:02:29 11-05-2010
-- Platform   : Xilinx ISE 10.1.03
-- Standard   : VHDL'93
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------
-- Copyright (c) 2010 SzuWar INC
-------------------------------------------------------------------------------
-- Revisions  :
-- Date                  Version  Author  Description
-- 22:24:52 26-03-2010   1.0      szuwarek  Created
-------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_arith.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

entity tb_spread_bpsk_0 is   
end entity tb_spread_bpsk_0;

architecture tb of tb_spread_bpsk_0 is

-------------------------------------------------------------------------------
-- Unit Under Test --
-------------------------------------------------------------------------------
   component spread_bpsk is

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

   end component spread_bpsk;

-------------------------------------------------------------------------------
-- consttants --
-------------------------------------------------------------------------------
   constant iDataWidith        : integer range 1 to 16 := 4;
   constant iSingleValueSpread : integer range 2 to 255 := 16;
   constant iTrigerType        : integer range 0 to 2 := 2;
   constant tTs                : time := 5 ns;

-------------------------------------------------------------------------------
-- signals --
-------------------------------------------------------------------------------
   -- In --
   signal CLK_I             : std_logic := '0';
   signal RESET_I           : std_logic := '0';
   signal DATA_VALID_I      : std_logic := '0';
   signal TRIGER_I          : std_logic := '0';
--   signal DATA_I            : std_logic_vector(iDataWidith - 1 downto 0) := (others => '0');
   signal DATA_I            : std_logic_vector(iDataWidith - 1 downto 0) := x"5";
   signal SPREAD_SEQUENCE_I : std_logic_vector(iSingleValueSpread - 1 downto 0) := (others => '0');
--   signal SPREAD_SEQUENCE_I : std_logic_vector(iSingleValueSpread - 1 downto 0) := x"a5c9";

   -- Out --
   signal DATA_VALID_O      : std_logic;
   signal READY_FOR_DATA_O  : std_logic;
   signal DATA_O            : std_logic_vector(iDataWidith - 1 downto 0);

   -- Others --
   signal v_count           : std_logic_vector(15 downto 0) := (others => '0');
   -- +1 bpsk == '1' --
   signal p_one             : std_logic_vector(iDataWidith - 1 downto 0) := (others => '1');
   -- -1 bpsk == '0' --
   signal s_one             : std_logic_vector(iDataWidith - 1 downto 0) := (others => '0');
   
begin  -- architecture tb


   UUT :
      spread_bpsk

   generic map (
      iDataWidith        => iDataWidith,
      iSingleValueSpread => iSingleValueSpread,
      iTrigerType        => iTrigerType
      )

   port map (
      CLK_I             => CLK_I,
      RESET_I           => RESET_I,
      DATA_I            => DATA_I,
      DATA_VALID_I      => DATA_VALID_I,

      TRIGER_I     => TRIGER_I,
      SPREAD_SEQUENCE_I => SPREAD_SEQUENCE_I,
      DATA_O            => DATA_O,
      DATA_VALID_O      => DATA_VALID_O,
      READY_FOR_DATA_O  => READY_FOR_DATA_O
      );

   StimulationProcess : process
      
   begin
      
      for i in 0 to 1000000 loop
         
         CLK_I <= not CLK_I;

         wait for tTs;

      end loop;

      wait;
      
   end process StimulationProcess;

   T0: process (CLK_I) is
   begin  -- process T0

      if rising_edge(CLK_I) then

         case v_count is

            when x"0002" =>

               RESET_I <= '1';

               TRIGER_I <= TRIGER_I;
               DATA_VALID_I <= DATA_VALID_I;
               DATA_I <= DATA_I;
               v_count <= v_count + 1;

            when x"0005" =>

               RESET_I <= '0';

               TRIGER_I <= TRIGER_I;
               DATA_VALID_I <= DATA_VALID_I;
               DATA_I <= DATA_I;
               v_count <= v_count + 1;

            when x"0007" =>


               RESET_I <= RESET_I;
               TRIGER_I <= TRIGER_I;
               DATA_VALID_I <= '1';
               DATA_I <= x"5";
               v_count <= v_count + 1;

            when x"0026" =>

 
               RESET_I <= RESET_I;
               TRIGER_I <= TRIGER_I;
               DATA_VALID_I <= '0';
               DATA_I <= DATA_I;
               v_count <= v_count;

            when x"0027" =>


               RESET_I <= RESET_I;
               TRIGER_I <= TRIGER_I;
               DATA_VALID_I <= '1';
               DATA_I <= x"a";
               v_count <= v_count + 1;

            when x"0040" =>


               RESET_I <= RESET_I;
               TRIGER_I <= TRIGER_I;
               DATA_VALID_I <= '0';
               DATA_I <= DATA_I;
               v_count <= v_count;
               
            when others =>


               RESET_I <= RESET_I;
               TRIGER_I <= TRIGER_I;
               DATA_VALID_I <= DATA_VALID_I;
               DATA_I <= DATA_I + 1;
--               DATA_I <= DATA_I xor p_one;
               v_count <= v_count + 1;
               
         end case;
         
      end if;
      
   end process T0;
   
end architecture tb;

