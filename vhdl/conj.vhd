-------------------------------------------------------------------------------
-- Title      : Conj.vhd
-- Project    : 
-------------------------------------------------------------------------------
-- File       : invsignal.vhd
-- Author     : 
-- Company    : 
-- Created    : 2003-11-28
-- Last update: 2003-12-05
-- Platform   : 
-------------------------------------------------------------------------------
-- Description: Faz o conjugado do sinal de entrada
-------------------------------------------------------------------------------
-- Copyright (c) 2003 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2003-11-28  1.0      tmsiqueira      Created
-------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_SIGNED.ALL;

--  Uncomment the following lines to use the declarations that are
--  provided for instantiating Xilinx primitive components.
--library UNISIM;
--use UNISIM.VComponents.all;

entity conj is
generic (
      width : natural);

    port (
      inR : in  std_logic_vector(WIDTH-1 downto 0);
      inI : in  std_logic_vector(WIDTH-1 downto 0);
      outR : out std_logic_vector(WIDTH-1 downto 0);
      outI : out std_logic_vector(WIDTH-1 downto 0);
		clk  : in  std_logic;
      conj  : in  std_logic);

end conj;

architecture conj of conj is

begin

   process(clk)
	begin
	   if clk'event and clk='1' then
		   case conj is
			   when '0' =>
				   outR <= inR;
					outI <= inI;
				when '1' =>
				   outR <= inR;
					outI <= 0-inI;
				when others =>
				   null;
			end case;
		end if;
	end process;

end conj;