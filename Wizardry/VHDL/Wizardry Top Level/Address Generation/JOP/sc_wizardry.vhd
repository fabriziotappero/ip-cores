--
--
--  This file is a part of JOP, the Java Optimized Processor
--
--  Copyright (C) 2001-2008, Martin Schoeberl (martin@jopdesign.com)
--
--  This program is free software: you can redistribute it and/or modify
--  it under the terms of the GNU General Public License as published by
--  the Free Software Foundation, either version 3 of the License, or
--  (at your option) any later version.
--
--  This program is distributed in the hope that it will be useful,
--  but WITHOUT ANY WARRANTY; without even the implied warranty of
--  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--  GNU General Public License for more details.
--
--  You should have received a copy of the GNU General Public License
--  along with this program.  If not, see <http://www.gnu.org/licenses/>.
--


--
--	sc_uart.vhd
--
--	8-N-1 serial interface
--	
--	wr, rd should be one cycle long => trde, rdrf goes 0 one cycle later
--
--	Author: Martin Schoeberl	martin@jopdesign.com
--
--
--	resources on ACEX1K30-3
--
--		100 LCs, max 90 MHz
--
--	resetting rts with fifo_full-1 works with C program on pc
--	but not with javax.comm: sends some more bytes after deassert
--	of rts (16 byte blocks regardless of rts).
--	Try to stop with half full fifo.
--
--	todo:
--
--
--	2000-12-02	first working version
--	2002-01-06	changed tdr and rdr to fifos.
--	2002-05-15	changed clkdiv calculation
--	2002-11-01	don't wait if read fifo is full, just drop the byte
--	2002-11-03	use threshold in fifo to reset rts 
--				don't send if cts is '0'
--	2002-11-08	rx fifo to 20 characters and stop after 4
--	2003-07-05	new IO standard, change cts/rts to neg logic
--	2003-09-19	sync ncts in!
--	2004-03-23	two stop bits
--	2005-11-30	change interface to SimpCon
--	2006-08-07	rxd input register with clk to avoid Quartus tsu violation
--	2006-08-13	use 3 FFs for the rxd input at clk
--


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity sc_wizardry is

generic (addr_bits : integer := 4);
port (
	clk		: in std_logic;
	reset	: in std_logic;

-- SimpCon interface

	address		: in std_logic_vector(addr_bits-1 downto 0);
	wr_data		: in std_logic_vector(31 downto 0);
	rd, wr		: in std_logic;
	rd_data		: out std_logic_vector(31 downto 0);
	rdy_cnt		: out unsigned(1 downto 0);
	
	--  Control Signals from JOP
--	configuration_trigger : out std_logic_vector(7 downto 0);
	eRCP_trigger_reg : out std_logic;
	
	--Wizardry Interface
	ack_i : in std_logic;
	err_i : in std_logic;
	dat_i : in std_logic_Vector(31 downto 0);
	cyc_o : out std_logic;
	stb_o : out std_logic;
	we_o : out std_logic;
	dat_o : out std_logic_vector(31 downto 0);
	adr_o : out std_logic_vector(21 downto 0);
	lock_o : out std_logic;
--	id_o : out std_logic_vector(4 downto 0);
	priority_o : out std_logic_vector(7 downto 0)
);
end sc_wizardry;

architecture rtl of sc_wizardry is

--type statetype is (reset_state,wait_for_rd_wr,check_address_value,store_address_state,store_data_state,
--					    write_to_ddr,read_from_ddr,send_sc_ack,wait_for_write_ack,wait_for_read_ack,
--						 prepare_sc_data);
--signal currentstate, nextstate : statetype;
signal store_address : std_logic;
signal store_data : std_logic;
signal store_config_data : std_logic;
signal adr_o_reg : std_logic_Vector(21 downto 0);
signal dat_o_reg : std_logic_vector(31 downto 0);
--signal wr_data_reg : std_logic_vector(31 downto 0);
signal address_reg : std_logic_vector(3 downto 0);
--signal rd_data_reg : std_logic_vector(31 downto 0);
signal set_sc_data : std_logic;
--signal dat_i_reg : std_logic_vector(31 downto 0);

component sc_wizardry_fsm is
    Port ( clock : in  STD_LOGIC;
           reset : in  STD_LOGIC;
           rd : in  STD_LOGIC;
           wr : in  STD_LOGIC;
           ack_i : in  STD_LOGIC;
           err_i : in  STD_LOGIC;
           address_reg : in  STD_LOGIC_VECTOR (3 downto 0);
			  adr_o_reg : in std_logic_vector(21 downto 0);
			  dat_o_reg : in std_logic_Vector(31 downto 0);
           cyc_o : out  STD_LOGIC;
           stb_o : out  STD_LOGIC;
           we_o : out  STD_LOGIC;
           adr_o : out  STD_LOGIC_VECTOR (21 downto 0);
           dat_o : out  STD_LOGIC_VECTOR (31 downto 0);
           store_address : out  STD_LOGIC;
           store_data : out  STD_LOGIC;
			  store_config_data : out  STD_LOGIC;
           rdy_cnt : out  unsigned (1 downto 0);
           set_sc_data : out  STD_LOGIC);
end component;

component sc_wizardry_processes is
	port(  clk : in std_logic;
			 reset : in std_logic;
			 rd : in std_logic;
			 wr : in std_logic;
			 ack_i : in std_Logic;
			 dat_i : in std_logic_Vector(31 downto 0);
			 address : in std_logic_Vector(3 downto 0);
			 wr_data : in std_Logic_Vector(31 downto 0);
			 rd_data : out std_logic_Vector(31 downto 0);
			 store_address : in std_Logic;
			 store_data : in std_Logic;
			 store_config_data : in  STD_LOGIC;
			 set_sc_data : in std_Logic;
			 adr_o_reg : out std_logic_Vector(21 downto 0);
			 dat_o_reg : out std_logic_Vector(31 downto 0);
--			 config_trigger_reg : out std_logic_vector(7 downto 0);
			 eRCP_trigger_reg : out std_logic;
			 address_reg : out std_logic_vector(3 downto 0));
end component;

begin
--id_o <= "00000";
priority_o <= "00000001";
lock_o <= '0';
--	rdy_cnt <= "00";	-- no wait states
--	rd_data(31 downto 8) <= std_logic_vector(to_unsigned(0, 24));
sc_wiz_fsm: sc_wizardry_fsm
    Port map( clock => clk,
           reset => reset,
           rd => rd,
           wr => wr,
           ack_i => ack_i,
           err_i => err_i,
           address_reg => address_reg,
			  adr_o_reg => adr_o_reg,
			  dat_o_reg => dat_o_reg,
           cyc_o => cyc_o,
           stb_o => stb_o,
           we_o => we_o,
           adr_o => adr_o,
           dat_o => dat_o,
           store_address => store_address,
           store_data => store_data,
			  store_config_data => store_config_data, --eRCP_trigger_reg, --
           rdy_cnt => rdy_cnt,
           set_sc_data => set_sc_data);

sc_wiz_proc: sc_wizardry_processes
	port map( clk => clk,
			 reset => reset,
			 rd => rd,
			 wr => wr,
			 ack_i => ack_i,
			 dat_i => dat_i,
			 address => address,
			 wr_data => wr_data,
			 rd_data => rd_data,
			 store_address => store_address,
			 store_data => store_data,
			 store_config_data => store_config_data,
			 set_sc_data => set_sc_data,
			 adr_o_reg => adr_o_reg,
			 dat_o_reg => dat_o_reg,
--			 config_trigger_reg => configuration_trigger,
			 eRCP_trigger_reg => eRCP_trigger_reg,  --open, --
			 address_reg => address_reg);

--eRCP_trigger_reg <= store_config_data;

end rtl;