------------------------------------------------
--! @file func.vhd
--! @brief Functions for calculating x**-1, x**0.5, 2x**0.5 
--! @author Juli&aacute;n Andr&eacute;s Guar&iacute;n Reyes
--------------------------------------------------


-- RAYTRAC
-- Author Julian Andres Guarin
-- func.vhd
-- This file is part of raytrac.
-- 
--     raytrac is free software: you can redistribute it and/or modify
--     it under the terms of the GNU General Public License as published by
--     the Free Software Foundation, either version 3 of the License, or
--     (at your option) any later version.
-- 
--     raytrac is distributed in the hope that it will be useful,
--     but WITHOUT ANY WARRANTY; without even the implied warranty of
--     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--     GNU General Public License for more details.
-- 
--     You should have received a copy of the GNU General Public License
--     along with raytrac.  If not, see <http://www.gnu.org/licenses/>



library ieee;
use ieee.std_logic_1164.all;


library altera_mf;
use altera_mf.all;

entity func is 
	generic (
		
		memoryfilepath : string :="X:/Tesis/Workspace/hw/rt_lib/arith/src/trunk/sqrtdiv/memsqrt.mif";
		awidth : integer := 9;
		qwidth : integer := 18
	
	);
	port (
		ad0,ad1 : in std_logic_vector (awidth-1 downto 0) := (others => '0');
		clk 	: in std_logic;
		q0,q1	: out std_logic_vector(qwidth-1 downto 0)
	);
end func;

architecture func_arch of func is 
	
	COMPONENT altsyncram
	GENERIC (
		address_reg_b		: STRING;
		clock_enable_input_a		: STRING;
		clock_enable_input_b		: STRING;
		clock_enable_output_a		: STRING;
		clock_enable_output_b		: STRING;
		indata_reg_b		: STRING;
		init_file		: STRING;
		intended_device_family		: STRING;
		lpm_type		: STRING;
		numwords_a		: NATURAL;
		numwords_b		: NATURAL;
		operation_mode		: STRING;
		outdata_aclr_a		: STRING;
		outdata_aclr_b		: STRING;
		outdata_reg_a		: STRING;
		outdata_reg_b		: STRING;
		power_up_uninitialized		: STRING;
		ram_block_type		: STRING;
		widthad_a		: NATURAL;
		widthad_b		: NATURAL;
		width_a		: NATURAL;
		width_b		: NATURAL;
		width_byteena_a		: NATURAL;
		width_byteena_b		: NATURAL;
		wrcontrol_wraddress_reg_b		: STRING
	);
	PORT (
			clock0	: IN STD_LOGIC ;
			wren_a	: IN STD_LOGIC ;
			address_b	: IN STD_LOGIC_VECTOR (8 DOWNTO 0);
			data_b	: IN STD_LOGIC_VECTOR (17 DOWNTO 0);
			q_a	: OUT STD_LOGIC_VECTOR (17 DOWNTO 0);
			wren_b	: IN STD_LOGIC ;
			address_a	: IN STD_LOGIC_VECTOR (8 DOWNTO 0);
			data_a	: IN STD_LOGIC_VECTOR (17 DOWNTO 0);
			q_b	: OUT STD_LOGIC_VECTOR (17 DOWNTO 0)
	);
	END COMPONENT;

begin

	altsyncram_component : altsyncram
	generic map (
		address_reg_b => "CLOCK0",
		clock_enable_input_a => "BYPASS",
		clock_enable_input_b => "BYPASS",
		clock_enable_output_a => "BYPASS",
		clock_enable_output_b => "BYPASS",
		indata_reg_b => "CLOCK0",
		--init_file => "X:/Tesis/Workspace/hw/rt_lib/arith/src/trunk/sqrtdiv/memsqrt.mif",
		init_file => memoryfilepath,
		intended_device_family => "Cyclone III",
		lpm_type => "altsyncram",
		numwords_a => 512,
		numwords_b => 512,
		operation_mode => "BIDIR_DUAL_PORT",
		outdata_aclr_a => "NONE",
		outdata_aclr_b => "NONE",
		outdata_reg_a => "UNREGISTERED",
		outdata_reg_b => "UNREGISTERED",
		power_up_uninitialized => "FALSE",
		ram_block_type => "M9K",
		widthad_a => 9,
		widthad_b => 9,
		width_a => 18,
		width_b => 18,
		width_byteena_a => 1,
		width_byteena_b => 1,
		wrcontrol_wraddress_reg_b => "CLOCK0"
	)
	port map (
		clock0 => clk,
		wren_a => '0',
		address_b => ad1,
		data_b => (others=>'0'),
		wren_b => '0',
		address_a => ad0,
		data_a => (others=>'0'),
		q_b => q1,
		q_a => q0
	);
		


end func_arch;




