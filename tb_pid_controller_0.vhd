-------------------------------------------------------------------------------
-- Title      : Testbench for pid_controller
-- Project    : 
-------------------------------------------------------------------------------
-- File       : tb_pid_controller_0.vhd
-- Author     : Tomasz Turek  <tomasz.turek@gmail.com>
-- Company    : SzuWar ZOO
-- Created    : 16:43:29 21-07-2010
-- Last update: 20:54:54 04-10-2010
-- Platform   : Xilinx ISE 10.1.03
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------
-- Copyright (c) 2010 SzuWar ZOO
-------------------------------------------------------------------------------
-- Revisions  :
-- Date                  Version  Author  Description
-- 16:43:29 21-07-2010   1.0      aTomek  Created
-- 20:54:31 04-10-2010   1.1      aTomek  Created
-------------------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.all;
USE ieee.numeric_std.ALL;

entity tb_pid_controller_0 is

end entity tb_pid_controller_0;

architecture testbench of tb_pid_controller_0 is
-------------------------------------------------------------------------------
-- components --
-------------------------------------------------------------------------------
   component pid_controller is

      generic
         (
               iDataWidith    : integer range 8 to 32 := 12;
               iKP            : integer range 0 to 7  := 2;  -- 0 - /2, 1 - /4, 2 - /8, 3 - /16, 4 - /32, 5 - /64, 6 - /128, 7 - /256
               iKI            : integer range 0 to 7  := 3;  -- 0 - /2, 1 - /4, 2 - /8, 3 - /16, 4 - /32, 5 - /64, 6 - /128, 7 - /256
               iKD            : integer range 0 to 7  := 4;  -- 0 - /2, 1 - /4, 2 - /8, 3 - /16, 4 - /32, 5 - /64, 6 - /128, 7 - /256
               iKM            : integer range 0 to 7  := 0;  -- 0 - /1, 1 - /2, 2 - /4, 3 - /8 , 4 - /16, 5 - /32, 6 - /64 , 7 - /128
               iDelayD        : integer range 1 to 16 := 1;
               iWork          : integer range 0 to 1  := 1   -- 0 - ró¿nica sygna³ów steruj¹cych, 1 - b³¹d
               );

      port
         (
               CLK_I               : in  std_logic;
               RESET_I             : in  std_logic;
               ERROR_I             : in  std_logic_vector(iDataWidith - 1 downto 0);
               PATERN_I            : in  std_logic_vector(iDataWidith - 1 downto 0);
               PATERN_ESTIMATION_I : in  std_logic_vector(iDataWidith - 1 downto 0);
               CORRECT_O           : out std_logic_vector(iDataWidith - 1 downto 0)
               );
      
   end component pid_controller;
   
-------------------------------------------------------------------------------
-- constants --
-------------------------------------------------------------------------------
   constant TS : time := 5 ns;
   constant iDataWidith    : integer range 8 to 32 := 12;
   constant iKP            : integer range 0 to 7  := 2;  -- 0 - /2, 1 - /4, 2 - /8, 3 - /16, 4 - /32, 5 - /64, 6 - /128, 7 - /256
   constant iKI            : integer range 0 to 7  := 1;  -- 0 - /2, 1 - /4, 2 - /8, 3 - /16, 4 - /32, 5 - /64, 6 - /128, 7 - /256
   constant iKD            : integer range 0 to 7  := 1;  -- 0 - /2, 1 - /4, 2 - /8, 3 - /16, 4 - /32, 5 - /64, 6 - /128, 7 - /256
   constant iKM            : integer range 0 to 7  := 0;  -- 0 - /1, 1 - /2, 2 - /4, 3 - /8 , 4 - /16, 5 - /32, 6 - /64 , 7 - /128
   constant iDelayD        : integer range 1 to 16 := 16;
   constant iWork          : integer range 0 to 1  := 0;
   
-------------------------------------------------------------------------------
-- signals --
-------------------------------------------------------------------------------
   -- Inputs --
   signal CLK_I               : std_logic := '0';
   signal RESET_I             : std_logic := '0';
   signal ERROR_I             : std_logic_vector(iDataWidith - 1 downto 0) := x"00f";
   signal PATERN_I            : std_logic_vector(iDataWidith - 1 downto 0) := x"6ff";
   signal PATERN_ESTIMATION_I : std_logic_vector(iDataWidith - 1 downto 0) := x"007";
   -- Outputs --
   signal CORRECT_O           : std_logic_vector(iDataWidith - 1 downto 0);
    -- Others --
   signal v_count : std_logic_vector(15 downto 0) := x"0000";
   
begin  -- architecture testbench

   -- Unit Under Test --
   uut :
      pid_controler

         generic map
         (
               iDataWidith    => iDataWidith,
               iKP            => iKP,
               iKI            => iKI,
               iKD            => iKD,
               iKM            => iKM,
               iDelayD        => iDelayD,
               iWork          => iWork
               )

         port map
         (
               CLK_I               => CLK_I,
               RESET_I             => RESET_I,
               ERROR_I             => ERROR_I,
               PATERN_I            => PATERN_I,
               PATERN_ESTIMATION_I => PATERN_ESTIMATION_I,
               CORRECT_O           => CORRECT_O
               );

   
   -- stimulate proces --
   stim_proc: process
   begin

      for i in 0 to 1000000 loop

         CLK_I <= '0';

         wait for TS;

         CLK_I <= '1';

         wait for TS;
         
      end loop;  -- i
      
   end process;

   T0: process (CLK_I) is
   begin  -- process T0

      if rising_edge(CLK_I) then 
         
         case v_count is
            
            when x"0010" =>

               v_count <= v_count + 1;
               RESET_I <= '1';
            when x"0020" =>

               v_count <= v_count + 1;
               RESET_I <= '0';


               
            when others =>

               PATERN_ESTIMATION_I <= PATERN_I - 336 + CORRECT_O;
               v_count <= v_count + 1;
               
         end case;
         
      end if;
      
   end process T0;

end architecture testbench;
