-------------------------------------------------------------------------------
-- Title      : mux
-- Project    : 
-------------------------------------------------------------------------------
-- File       : mux.vhd
-- Author     : 
-- Company    : 
-- Created    : 2003-11-28
-- Last update: 2003-12-05
-- Platform   : 
-------------------------------------------------------------------------------
-- Description: Multiplixador de 2-1
-------------------------------------------------------------------------------
-- Copyright (c) 2003 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2003-11-28  1.0      tmsiqueira      Created
-------------------------------------------------------------------------------

  library ieee;
  use ieee.std_logic_1164.all;

  entity mux is
    
    generic (
      width : natural);

    port (
      inRa : in  std_logic_vector(WIDTH-1 downto 0);
      inIa : in  std_logic_vector(WIDTH-1 downto 0);
      inRb : in  std_logic_vector(WIDTH-1 downto 0);
      inIb : in  std_logic_vector(WIDTH-1 downto 0);
      outR : out std_logic_vector(WIDTH-1 downto 0);
      outI : out std_logic_vector(WIDTH-1 downto 0);
		clk  : in  std_logic;
      sel  : in  std_logic);

  end mux;

  architecture mux of mux is

  begin  -- mux

--    outR <= inRa when (sel='0') else (others => 'Z');
--		outR <= inRb when (sel='1') else (others => 'Z');
--    outI <= inIa when (sel='0') else (others => 'Z');
--		outI <= inIb when (sel='1') else (others => 'Z');

--	 with sel select
--      outR <= inRa when '0',
--              inRb when others;
  
--	 with sel select
--      outI <= inIa when '0',
--              inIb when others;

   process (clk)
	begin
	   if clk'event and clk='1' then
		   case sel is
			   when '0' => 
				   outR <= inRa;
					outI <= inIa;
				when '1' =>
				   outR <= inRb;
					outI <= inIb;
				when others =>
				   null;
			end case;
		end if;
	end process;
    
  end mux;
