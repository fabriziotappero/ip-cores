-- This file is part of ARM4U CPU
-- 
-- This is a creation of the Laboratory of Processor Architecture
-- of Ecole Polytechnique Fédérale de Lausanne ( http://lap.epfl.ch )
--
-- cache.vhd  --  A cache with an Avalon master interface. Only for instruction and direct-mapped for now.
--
-- Written By -  Jonathan Masur and Xavier Jimenez (2013)
--
-- This program is free software; you can redistribute it and/or modify it
-- under the terms of the GNU General Public License as published by the
-- Free Software Foundation; either version 2, or (at your option) any
-- later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- In other words, you are welcome to use, share and improve this program.
-- You are forbidden to forbid anyone else to use, share and improve
-- what you give them.   Help stamp out software-hoarding!

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.all;

library altera_mf;
use altera_mf.all;

library work;
use work.utils.all;

entity cache is
	generic(
		INSTR_BADDR_BITWDTH : natural := 32;  -- input coe_cpu_address width in bits
		BLOCK_BITWIDTH      : natural := 5;   -- byte address range of a block (hence C_BLOCK_SIZE = 2**BLOCK_BITWIDTH)
		CACHE_SIZE          : natural := 4096 -- cache size in bytes, must be a factor of C_BLOCK_SIZE * CACHE_WAYS
 	);
 	port(
		-- Globals
		clk   : in std_logic;
		reset : in std_logic;

		-- CPU conduit extern
		coe_cpu_enabled   : in std_logic; -- fetches a new instruction. If deactivated, the last read is kept on the output.
		coe_cpu_flush     : in std_logic := '0'; -- flushes the cache line addressed by "coe_cpu_address" and cancels any pending read
		coe_cpu_address   : in  std_logic_vector(INSTR_BADDR_BITWDTH-1 downto 0); -- byte address
		coe_cpu_readdata  : out std_logic_vector(31 downto 0);
		coe_cpu_miss      : out std_logic;
		
		--Avalon Master Interface
		avm_waitrequest   : in  std_logic;
		avm_readdatavalid : in  std_logic;
		avm_readdata      : in  std_logic_vector(31 downto 0);
		avm_read          : out std_logic;
		avm_burstcount    : out std_logic_vector(BLOCK_BITWIDTH-2 downto 0);
		avm_address       : out std_logic_vector(31 downto 0)
	  );
end cache;

architecture synth of cache is
constant C_BLOCK_SIZE     : natural := 2**BLOCK_BITWIDTH;
constant C_SET_COUNT      : natural := CACHE_SIZE / C_BLOCK_SIZE;
constant C_INDEX_BITWIDTH : natural := log2(C_SET_COUNT);
constant C_TAG_BITWIDTH   : natural := INSTR_BADDR_BITWDTH - BLOCK_BITWIDTH - C_INDEX_BITWIDTH;
constant C_DATA_WADDR_BITWIDTH : natural := log2(CACHE_SIZE)-2; -- addressable words in the data sram

-- registerd coe_cpu_address (without the 2 lsb)
signal r_address : std_logic_vector(INSTR_BADDR_BITWDTH-3 downto 0);
signal r_read    : std_logic;
-- register flush command
signal r_flush : std_logic;
-- the current offset in a burst
signal r_burstoffset : std_logic_vector(log2(C_BLOCK_SIZE)-3 downto 0);
-- the tag and valid bit
signal s_vtag_in    : std_logic_vector(C_TAG_BITWIDTH DOWNTO 0);
signal s_vtag_out   : std_logic_vector(C_TAG_BITWIDTH DOWNTO 0);
-- signals to the tag and data srams
signal s_data_wren : std_logic;
signal s_data_rdaddr : std_logic_vector(C_DATA_WADDR_BITWIDTH-1 downto 0);
signal s_data_wraddr : std_logic_vector(C_DATA_WADDR_BITWIDTH-1 downto 0);
signal s_tag_wren  : std_logic;
signal s_tag_rdaddr  : std_logic_vector(C_INDEX_BITWIDTH-1 downto 0);
signal s_tag_wraddr  : std_logic_vector(C_INDEX_BITWIDTH-1 downto 0);
signal s_addr_stall : std_logic;
signal s_miss      : std_logic;

type state_type is (S_READY, S_WAIT, S_READ, S_DELAY);
signal state, nextstate : state_type;

-- SRAM component declaration
component altsyncram
generic (
	address_reg_b		: STRING;
	clock_enable_input_a		: STRING;
	clock_enable_input_b		: STRING;
	clock_enable_output_a		: STRING;
	clock_enable_output_b		: STRING;
	intended_device_family		: STRING;
	lpm_type		: STRING;
	numwords_a		: NATURAL;
	numwords_b		: NATURAL;
	operation_mode		: STRING;
	outdata_aclr_b		: STRING;
	outdata_reg_b		: STRING;
	power_up_uninitialized		: STRING;
	read_during_write_mode_mixed_ports		: STRING;
	widthad_a		: NATURAL;
	widthad_b		: NATURAL;
	width_a		: NATURAL;
	width_b		: NATURAL;
	width_byteena_a		: NATURAL
);
port (
	addressstall_b : IN STD_LOGIC ;
	wren_a  : IN STD_LOGIC ;
	clock0  : IN STD_LOGIC ;
	clock1  : IN STD_LOGIC ;
	address_a : IN STD_LOGIC_VECTOR (widthad_a-1 DOWNTO 0);
	address_b : IN STD_LOGIC_VECTOR (widthad_b-1 DOWNTO 0);
	q_b       : OUT STD_LOGIC_VECTOR (width_b-1 DOWNTO 0);
	data_a    : IN STD_LOGIC_VECTOR (width_a-1 downto 0)
);
end component;

begin
coe_cpu_miss <= s_miss;
-- we do not have a coe_cpu_miss when flushing, or when the tag matches a valid entry
s_miss <= '0' when r_read='0' or (coe_cpu_flush or r_flush)='1' or s_vtag_in=s_vtag_out else '1'; -- TODO: to be modified for multiple ways

-- the burstcount is fixed
avm_burstcount <= std_logic_vector(to_unsigned(C_BLOCK_SIZE/4, avm_burstcount'length));
avm_address <= (31 downto INSTR_BADDR_BITWDTH =>'0') & r_address(INSTR_BADDR_BITWDTH-3 downto BLOCK_BITWIDTH-2) & (BLOCK_BITWIDTH-1 downto 0 => '0');

-- signals to the data and tag srams
s_addr_stall  <= s_miss or not coe_cpu_enabled;
s_data_rdaddr <= coe_cpu_address(C_DATA_WADDR_BITWIDTH+1 downto 2);
s_data_wraddr <= r_address(C_DATA_WADDR_BITWIDTH-1 downto BLOCK_BITWIDTH-2) & r_burstoffset;
s_tag_rdaddr  <= coe_cpu_address(C_DATA_WADDR_BITWIDTH+1 downto BLOCK_BITWIDTH);
s_tag_wraddr  <= r_address(C_DATA_WADDR_BITWIDTH-1 downto BLOCK_BITWIDTH-2);
-- s_tag_wren and s_vtag_in
process(r_address, r_flush, r_burstoffset, avm_readdatavalid)
begin
	s_tag_wren <= '0';
	s_vtag_in  <= r_address(INSTR_BADDR_BITWDTH-3 downto INSTR_BADDR_BITWDTH-C_TAG_BITWIDTH-2) & '1';
	if (r_flush = '1') then
		s_tag_wren <= '1';
		s_vtag_in  <= (others => '0');
	elsif (r_burstoffset = (r_burstoffset'range => '1') and avm_readdatavalid='1') then
		s_tag_wren <= '1';
	end if;
end process;

process(reset, clk)
begin
	if (reset = '1') then
		r_burstoffset <= (others => '0');
		state <= S_READY;
		r_flush <= '0';
		r_read <= '0';
	elsif (rising_edge(clk)) then
		r_read <= coe_cpu_enabled or s_miss; -- in case of miss we fix r_read to 1.
		case state is
			when S_READY =>
				r_flush <= coe_cpu_flush;
				if (s_miss = '1') then
					if (avm_waitrequest = '1') then
						state <= S_WAIT;
					else
						state <= S_READ;
					end if;
				else
					-- in case of a coe_cpu_miss the coe_cpu_address is unchanged
					if (coe_cpu_enabled = '1' or coe_cpu_flush='1') then
						r_address <= coe_cpu_address(INSTR_BADDR_BITWDTH-1 downto 2);
					end if;
				end if;
				r_burstoffset <= (others => '0');
			
			when S_WAIT =>
				if (avm_waitrequest = '0') then
					state <= S_READ;
				end if;
				
			when S_READ =>
				if (r_burstoffset = (r_burstoffset'range => '1') and avm_readdatavalid='1') then
					state <= S_DELAY;
				end if;
				
			when S_DELAY =>
				state <= S_READY;
				
		end case;
			
		-- update r_burst_offset
		if (avm_readdatavalid='1') then
			r_burstoffset <= r_burstoffset + 1;
		end if;
	end if;
end process;

process(state, s_miss)
begin
	case state is
		when S_READY =>
			avm_read <= s_miss;
		when S_WAIT =>
			avm_read <= '1';
		when others =>
			avm_read <= '0';
	end case;
end process;


-- Data SRAM
g_data_sram : altsyncram
	GENERIC MAP (
		address_reg_b => "CLOCK1",
		clock_enable_input_a => "BYPASS",
		clock_enable_input_b => "BYPASS",
		clock_enable_output_a => "BYPASS",
		clock_enable_output_b => "BYPASS",
		intended_device_family => "Cyclone IV E",
		lpm_type => "altsyncram",
		numwords_a => CACHE_SIZE/4,
		numwords_b => CACHE_SIZE/4,
		operation_mode => "DUAL_PORT",
		outdata_aclr_b => "NONE",
		outdata_reg_b => "UNREGISTERED",
		power_up_uninitialized => "FALSE",
		read_during_write_mode_mixed_ports => "DONT_CARE",
		widthad_a => C_DATA_WADDR_BITWIDTH,
		widthad_b => C_DATA_WADDR_BITWIDTH,
		width_a => 32,
		width_b => 32,
		width_byteena_a => 1
	)
	PORT MAP (
		addressstall_b => s_addr_stall,
		wren_a => avm_readdatavalid,
		clock0 => clk,
		clock1 => clk,
		address_a => s_data_wraddr,
		address_b => s_data_rdaddr,
		data_a => avm_readdata,
		q_b => coe_cpu_readdata
	);
	
	
g_tag_sram : altsyncram
	GENERIC MAP (
		address_reg_b => "CLOCK1",
		clock_enable_input_a => "BYPASS",
		clock_enable_input_b => "BYPASS",
		clock_enable_output_a => "BYPASS",
		clock_enable_output_b => "BYPASS",
		intended_device_family => "Cyclone IV E",
		lpm_type => "altsyncram",
		numwords_a => C_SET_COUNT,
		numwords_b => C_SET_COUNT,
		operation_mode => "DUAL_PORT",
		outdata_aclr_b => "NONE",
		outdata_reg_b => "UNREGISTERED",
		power_up_uninitialized => "FALSE",
		read_during_write_mode_mixed_ports => "DONT_CARE",
		widthad_a => C_INDEX_BITWIDTH,
		widthad_b => C_INDEX_BITWIDTH,
		width_a => C_TAG_BITWIDTH+1,
		width_b => C_TAG_BITWIDTH+1,
		width_byteena_a => 1
	)
	PORT MAP (
		addressstall_b => s_addr_stall,
		wren_a => s_tag_wren,
		clock0 => clk,
		clock1 => clk,
		address_a => s_tag_wraddr,
		address_b => s_tag_rdaddr,
		data_a => s_vtag_in,
		q_b => s_vtag_out
	);

end synth;
