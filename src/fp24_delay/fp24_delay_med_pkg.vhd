-------------------------------------------------------------------------------
--
-- Title       : fp24_delay_med_pkg
-- Design      : fp24fftk
-- Author      : Kapitanov
-- Company     :
--
-------------------------------------------------------------------------------
--
-- Description : version 1.0 
--
-- Stages: medium line (5 stages);
--
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
--		(c) Copyright 2015 													 
--		Kapitanov.                                          				 
--		All rights reserved.                                                 
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

package	fp24_delay_med_pkg is
	-- 64
	component fp24_sh24x64r
	  port (
	    d 		: in std_logic_vector(23 downto 0);
	    clk 	: in std_logic;
	    ce 		: in std_logic;
	    sclr 	: in std_logic;
	    q 		: out std_logic_vector(23 downto 0)
	  );
	end component;
	-- 128
	component fp24_sh24x128r
	  port (
	    d 		: in std_logic_vector(23 downto 0);
	    clk 	: in std_logic;
	    ce 		: in std_logic;
	    sclr 	: in std_logic;
	    q 		: out std_logic_vector(23 downto 0)
	  );
	end component;
	-- 256
	component fp24_sh24x256r
	  port (
	    d 		: in std_logic_vector(23 downto 0);
	    clk 	: in std_logic;
	    ce 		: in std_logic;
	    sclr 	: in std_logic;
	    q 		: out std_logic_vector(23 downto 0)
	  );
	end component;
		-- 512
	component fp24_sh24x512r
	  port (
	    d 		: in std_logic_vector(23 downto 0);
	    clk 	: in std_logic;
	    ce 		: in std_logic;
	    sclr 	: in std_logic;
	    q 		: out std_logic_vector(23 downto 0)
	  );
	end component;
		-- 1k
	component fp24_sh24x1kr
	  port (
	    d 		: in std_logic_vector(23 downto 0);
	    clk 	: in std_logic;
	    ce 		: in std_logic;
	    sclr 	: in std_logic;
	    q 		: out std_logic_vector(23 downto 0)
	  );
	end component;
end fp24_delay_med_pkg;