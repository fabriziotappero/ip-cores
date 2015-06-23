----------------------------------------------------------------------------------
--
--  This file is a part of Technica Corporation Wizardry Project
--
--  Copyright (C) 2004-2009, Technica Corporation  
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
----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
-- Module Name: MIG_addr_gen_0 - Structural 
-- Project Name: Wizardry
-- Target Devices: Virtex 4 ML401
-- Description: Top-level structural description for address generation.
-- Revision: 1.0
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use work.MAC_Constants.all;
use work.eRCP_Constants.ALL;
library UNISIM;
use UNISIM.vcomponents.all;

entity MIG_addr_gen is
  port (
    clk0            : in  std_logic;
    rst             : in  std_logic;
    bkend_wraddr_en : in  std_logic;
	 rx				  : in  std_logic;
	 tx				  : out  std_logic;
--	 leds : out std_logic_vector(8 downto 0);
    cntrl0_app_af_addr     : out std_logic_vector(35 downto 0);
    cntrl0_app_af_wren     : out std_logic;
	 cntrl0_app_wdf_data                  : out  std_logic_vector(63 downto 0);
	 cntrl0_app_wdf_wren                  : out std_logic;
	 cntrl0_app_mask_data                 : out  std_logic_vector(7 downto 0);
	 cntrl0_read_data_valid               : in std_logic;
	 cntrl0_read_data_fifo_out            : in  std_logic_vector(63 downto 0);
	 init_done									  : in std_logic;
	 FIFO_empty										: out std_logic;
	 read_enable									: out std_logic;
	 write_enable									: out std_logic;
	 
	 -- eRCP and EmPAC Signals to/from top level
	 phy_clock : in std_logic;
	 phy_reset : out std_logic;
	 phy_data_in : in  STD_LOGIC_VECTOR (3 downto 0);
				phy_data_valid_in : in  STD_LOGIC;
				WIZ_rx_sdata : in  STD_LOGIC;
				WIZ_tx_sdata : out  STD_LOGIC;
--				;
	--  Debug Signals to top level
--	rdcount : out std_logic_vector(11 downto 0);
--			   wrcount : out std_logic_vector(11 downto 0);
--				empac_empty_debug: out std_logic;
--				empac_full_debug : out std_logic;
				
				
	---==========================================================--
----===========Virtex-4 SRAM Port============================--
	wd : out std_logic;
	sram_clk : out std_logic;
	sram_feedback_clk : out std_logic;
	
	sram_addr : out std_logic_vector(22 downto 0);
	
	sram_we_n : out std_logic;
	sram_oe_n : out std_logic;

	sram_data : inout std_logic_vector(31 downto 0);
	
	sram_bw0: out std_logic;
	sram_bw1 : out std_logic;
	
	sram_bw2 : out std_Logic;
	sram_bw3 : out std_logic;
	
	sram_adv_ld_n : out std_logic;
	sram_mode : out std_logic;
	sram_cen : out std_logic;
	sram_cen_test : out std_logic;
	sram_zz : out std_logic			
				
    );
end MIG_addr_gen;

architecture arch of MIG_addr_gen is
  
  signal rx_s,tx_s : std_logic;  
--  signal wd : std_logic;
  
  signal adr_check : std_logic;
  
  signal addr_0_out : std_logic;
  signal leds_s : std_logic_vector(8 downto 0);
  signal leds_s2 : std_logic_vector(8 downto 0);
	
  signal wr_rd_addr          : std_logic_vector(8 downto 0);
  signal wr_rd_addr_en       : std_logic;
  signal wr_addr_count       : std_logic_vector(5 downto 0);
  signal bkend_wraddr_en_reg : std_logic;
  signal wr_rd_addr_en_reg   : std_logic;
  signal bkend_wraddr_en_3r  : std_logic;
  signal unused_data_in      : std_logic_vector(31 downto 0);
  signal unused_data_in_p    : std_logic_vector(3 downto 0);
  signal gnd                 : std_logic;
  signal addr_out            : std_logic_vector(35 downto 0);
  signal rst_r               : std_logic;
  signal Memory_Access_in : Memory_Access_Port_in;
  signal Memory_Access_out : Memory_Access_Port_out;
  signal MAC_in : Preprocessor_Interface_Port_in;
  signal	MAC_out : Preprocessor_Interface_Port_out;
  signal read_data_test_vector : std_logic_vector(7 downto 0);
 
  signal dat_i : std_logic_vector(32-1 downto 0);
  signal adr_o : std_logic_vector(virtual_address_width-1 downto 0);
  signal	cyc_o : std_logic;
	signal stb_o : std_logic;
	signal we_o : std_logic;
	signal lock_o : std_logic;
	signal dat_o : std_logic_vector(32-1 downto 0);
	signal sel_o : std_logic_Vector(3 downto 0);
	signal priority : std_logic_vector(7 downto 0);
	signal id : std_logic_vector(4 downto 0);
	signal ack_i : std_logic;
	signal acknowledge_read_data : std_logic;
	signal store_rd_data : std_logic;
	signal store_rd_data_0 : std_logic;
	signal command_s : std_logic_vector(2 downto 0);
	
	signal jop_reset_cnt : std_logic_vector(14 downto 0);
	signal jop_reset : std_logic;
	signal sync_reset_n : std_logic;
	
	type shift_reg is
		array (0 to 3) of std_logic_vector(63 downto 0); 
	signal dat_i_shift_reg : shift_reg;
	
	signal sync_reset: std_logic;
	signal device_clock_fb,device_clock_fb_0 : std_logic;
	signal leds_dummy : std_logic_vector(8 downto 0);
	
	signal eRCP_busy_s : boolean;
				signal interactive_instructions_s : instruction_interface;
	
component Top_Level_MAC is
    Port ( clock : in  STD_LOGIC;
			  device_clock : in  STD_LOGIC;
           reset : in  STD_LOGIC;
           Memory_Access_in : in  Memory_Access_Port_in;
           Memory_Access_out : out  Memory_Access_Port_out;
			  MAC_in : in Preprocessor_Interface_Port_in;
			  MAC_out : out Preprocessor_Interface_Port_out
			  );
end component;

component Uart_Interface is
port(
		clock : in std_logic;
		reset : in std_logic;
		write_enable_out	:  in   std_logic;
		read_enable_out	:  in  std_logic;
		FIFO_empty_out	:    in std_logic;
		read_data_test_vector : out std_logic_vector(7 downto 0);
		rx : in std_logic;
		tx : out std_logic;
		leds : out std_logic_vector(8 downto 0);
		dat_i : in std_logic_vector(data_width-1 downto 0);
  	   adr_o : out std_logic_vector(virtual_address_width-1 downto 0);
	   cyc_o : out std_logic;
	   stb_o : out std_logic;
	   we_o : out std_logic;
	   lock_o : out std_logic;
	   dat_o : out std_logic_vector(data_width-1 downto 0);
	   sel_o : out std_logic_Vector(3 downto 0);
	   priority : out std_logic_vector(7 downto 0);
	   id : out std_logic_vector(4 downto 0);
	   ack_i : in std_logic;
		err_i : in std_logic;
		cntrl0_APP_AF_WREN : out std_logic;
	   cntrl0_APP_WDF_WREN : out std_logic;
		mask : out std_logic_vector(7 downto 0);
		ack_access_in : out std_logic;
		command : out std_logic_vector(2 downto 0);
		acknowledge_read_data : in std_logic
		
);
end component;

component jop is

generic (
	ram_cnt		: integer := 4;		-- clock cycles for external ram
	rom_cnt		: integer := 15;	-- not used for S3K
	jpc_width	: integer := 11;	-- address bits of java bytecode pc = cache size
	block_bits	: integer := 4;		-- 2*block_bits is number of cache blocks
	spm_width	: integer := 0		-- size of scratchpad RAM (in number of address bits for 32-bit words)
);

port (
	clk		: in std_logic;
	
--
---- serial interface
--
	ser_txd			: out std_logic;
	ser_rxd			: in std_logic;
--
--
--	watchdog
--
	wd		: out std_logic;
	
--  Control Signals from JOP
--	configuration_trigger : out std_logic_vector(7 downto 0);	
	eRCP_trigger_reg : out std_logic;
	
--
---==========================================================--
----===========Virtex-4 SRAM Port============================--
	sram_clk : out std_logic;
	sram_feedback_clk : out std_logic;
	
	sram_addr : out std_logic_vector(22 downto 0);
	
	sram_we_n : out std_logic;
	sram_oe_n : out std_logic;

	sram_data : inout std_logic_vector(31 downto 0);
	
	sram_bw0: out std_logic;
	sram_bw1 : out std_logic;
	
	sram_bw2 : out std_Logic;
	sram_bw3 : out std_logic;
	
	sram_adv_ld_n : out std_logic;
	sram_mode : out std_logic;
	sram_cen : out std_logic;
	sram_cen_test : out std_logic;
	sram_zz : out std_logic;

---=========================================================---
---=========================================================---

--
--	I/O pins of board TODO: change this and io for xilinx board!
--
--	io_b	: inout std_logic_vector(10 downto 1);
--	io_l	: inout std_logic_vector(20 downto 1);
--	io_r	: inout std_logic_vector(20 downto 1);
--	io_t	: inout std_logic_vector(6 downto 1)

-- Wizardry Interface
	ack_i : in std_logic;
	err_i : in std_logic;
	dat_i : in std_logic_vector(31 downto 0);
	cyc_o : out std_logic;
	stb_o : out std_logic;
	we_o : out std_logic;
	dat_o : out std_logic_vector(31 downto 0);
	adr_o : out std_logic_Vector(21 downto 0);
	lock_o : out std_logic;
--	id_o : out std_logic_Vector(4 downto 0);
	priority_o : out std_logic_Vector(7 downto 0)
);
end component;

component Wizardry_Top is
    Port ( clock : in  STD_LOGIC;
				phy_clock : in  STD_LOGIC;
				reset : in  STD_LOGIC;
				phy_reset : out std_logic;
				phy_data_in : in  STD_LOGIC_VECTOR (3 downto 0);
				phy_data_valid_in : in  STD_LOGIC;
				rx_sdata : in  STD_LOGIC;
				tx_sdata : out  STD_LOGIC;
				leds : out  STD_LOGIC_VECTOR (8 downto 0);
				device_clock_fb : out std_logic;
				
				--  Configuration Trigger Signal
			new_configuration : in std_logic;
				
				------WB Signals
					---WB Out Signals
				adr_o	 	:     out std_logic_vector(virtual_address_width -1 downto 0);
				dat_o	 	:     out std_logic_vector(data_width -1 downto 0);
				we_o	 	:     out std_logic;
				sel_o	 	:     out std_logic_vector(data_resolution -1 downto 0);
				stb_o	 	:     out std_logic;
				cyc_o	 	:     out std_logic;
				ID_o	 	:     out std_logic_vector(ID_width -1 downto 0);
				priority_o :   out std_logic_vector(priority_width -1 downto 0);
				lock_o   :  	out std_logic;
					---WB IN Signals
				err_i	 	:     in std_logic;
				ack_i	 	:     in std_logic;
				dat_i	 	:     in std_logic_vector(data_width -1 downto 0);
				
				
				------WB Signals 2
					---WB Out Signals
				adr_o_0	 	:     out std_logic_vector(virtual_address_width -1 downto 0);
				dat_o_0	 	:     out std_logic_vector(data_width -1 downto 0);
				we_o_0	 	:     out std_logic;
				sel_o_0	 	:     out std_logic_vector(data_resolution -1 downto 0);
				stb_o_0	 	:     out std_logic;
				cyc_o_0	 	:     out std_logic;
				ID_o_0	 	:     out std_logic_vector(ID_width -1 downto 0);
				priority_o_0 :   out std_logic_vector(priority_width -1 downto 0);
				lock_o_0   :  	out std_logic;
					---WB IN Signals
				err_i_0	 	:     in std_logic;
				ack_i_0	 	:     in std_logic;
				dat_i_0	 	:     in std_logic_vector(data_width -1 downto 0);
				
					--EMPAC WB SIGNALS
				empac_ack_i : in std_logic;
				empac_dat_i : in std_logic_vector(data_width-1 downto 0);
				empac_err_i : in std_logic;
				empac_dat_o : out std_logic_Vector(data_width-1 downto 0);
				empac_adr_o : out std_logic_Vector(virtual_address_width-1 downto 0);
				empac_cyc_o : out std_logic;
				empac_stb_o : out std_logic;
				empac_we_o : out std_Logic;
				empac_lock_o : out std_logic;
				empac_priority_o : out std_logic_Vector(priority_width-1 downto 0);
				empac_id_o : out std_logic_vector(id_width-1 downto 0);
				--  Debug Signals to top level
				eRCP_busy : out boolean;
				interactive_instructions : in instruction_interface
--				;
--				rdcount : out std_logic_vector(11 downto 0);
--			   wrcount : out std_logic_vector(11 downto 0);
--				empac_empty_debug: out std_logic;
--				empac_full_debug : out std_logic
			  
			  );
end component;

component RDIC_Xilinx_bridge is
    Port ( clock : in  STD_LOGIC;
           reset : in  STD_LOGIC;
			  fifo_empty_out : in std_Logic;
			  write_enable_out : in std_logic;
			  APP_AF_WREN   : out std_logic;
				APP_WDF_WREN : out std_logic;
				ack_access_in : out std_logic;
				command : out std_logic_vector(2 downto 0);
				mask : out std_logic_vector(7 downto 0));
end component;


component wc_uart_controller is
    Port ( clock : in  STD_LOGIC;
			  device_clock : out std_Logic;
           reset : in  STD_LOGIC;
           cyc_o : out  STD_LOGIC;
           stb_o : out  STD_LOGIC;
           we_o : out  STD_LOGIC;
           adr_o : out  STD_LOGIC_VECTOR (21 downto 0);
           dat_o : out  STD_LOGIC_VECTOR (31 downto 0);
           dat_i : in  STD_LOGIC_VECTOR (31 downto 0);
           ack_i : in  STD_LOGIC;
			  err_i : in std_logic;
			  priority_o : out std_logic_vector(7 downto 0);
			  id_o : out std_logic_vector(4 downto 0);
			  lock_o : out std_logic;
			  eRCP_busy : in boolean;
			  interactive_instructions : out instruction_interface;
           rx : in  STD_LOGIC;
           tx : out  STD_LOGIC);
end component;


Signal eRCP_trigger_s : std_logic;





begin

--leds <= leds_s2(8 downto 1) & wd  ;

------------------MY Stuff------------------
--app_af_addr <= 
FIFO_empty	<= MAC_out.FIFO_empty_out;
read_enable <= MAC_out.read_enable_out;
write_enable	<= MAC_out.write_enable_out;
	
cntrl0_app_af_addr <= '0' & command_s & "000000" & MAC_out.address_out(23 downto 9) & "00" & MAC_out.address_out(8 downto 0);
cntrl0_app_wdf_data <= MAC_out.write_data_out & MAC_out.write_data_out;         														  
Mac_in.Acknowledge_read_data_in <= store_rd_data;
Mac_in.read_data_in <= dat_i;

sync_reset <= '1' when rst = '1' OR init_done= '0' else '0';
sync_reset_n <= not sync_reset;

Arbitration_Component : Top_Level_MAC
    Port Map( clock => clk0,
			  device_clock => clk0, --device_clock_fb,
           reset => sync_reset,
           Memory_Access_in => Memory_Access_in,
           Memory_Access_out => Memory_Access_out,
			  MAC_in => MAC_in,
			  MAC_out => MAC_out
			  );

--		write_data_out	 	:     std_logic_vector(data_width -1 downto 0);
--		address_out	 		:     std_logic_vector(physical_address_width -1 downto 0);
--		write_enable_out	:     std_logic;
--		read_enable_out	:     std_logic;
--		FIFO_empty_out	:     std_logic;
--

--process(clk0,rst_r,Memory_Access_in.adr_i(3))
--begin
--	if rising_Edge(clk0) then
--		if rst_r = '1' then
--			adr_check <= '0';
--		elsif (Memory_Access_in.adr_i(3)(17 downto 16) = "11") then
--			adr_check <= '1';
--		else
--			adr_check <= adr_check;
--		end if;
--	end if;
--end process;

-- Backup Version
--process(clk0,sync_reset,Memory_Access_in.adr_i(3))
--begin
--	if rising_Edge(clk0) then
--		if sync_reset = '1' then
--			adr_check <= '0';
--		elsif (Memory_Access_in.adr_i(3)(17 downto 16) = "11") then
--			adr_check <= '1';
--		else
--			adr_check <= adr_check;
--		end if;
--	end if;
--end process;
--



--UART_Component : Uart_Interface
--port map(
--		clock => clk0,
--		reset => rst_r, --sync_reset,
--		write_enable_out	=> MAC_out.write_enable_out,
--		read_enable_out	=> MAC_out.read_enable_out,
--		FIFO_empty_out	=> MAC_out.FIFO_empty_out,
--		read_data_test_vector => read_data_test_vector,
--		rx => rx_s,
--		tx => tx_s,
--		leds => leds_s,
--		dat_i => dat_i,
--  	   adr_o => Memory_Access_in.adr_i(0),
--	   cyc_o => Memory_Access_in.cyc_i(0),
--	   stb_o => Memory_Access_in.stb_i(0),
--	   we_o => Memory_Access_in.we_i(0),
--	   lock_o => Memory_Access_in.lock_i(0),
--	   dat_o => Memory_Access_in.dat_i(0),
--	   sel_o => Memory_Access_in.sel_i(0),
--	   priority => Memory_Access_in.priority_i(0),
--	   id => Memory_Access_in.id_i(0),
--	   ack_i => Memory_Access_out.ack_o(0),
--		err_i => Memory_Access_out.err_o(0),
--		cntrl0_APP_AF_WREN => cntrl0_APP_AF_WREN,
--	   cntrl0_APP_WDF_WREN => cntrl0_APP_WDF_WREN,
--		mask => cntrl0_app_mask_data,
--		ack_access_in => MAC_in.ack_access_in,
--		command => command_s,
--		acknowledge_read_data => acknowledge_read_data
--);


jop_cmp: jop
generic map(
	ram_cnt		=> 4,		-- clock cycles for external ram
	rom_cnt		=> 15,	-- not used for S3K
	jpc_width	=> 11,	-- address bits of java bytecode pc = cache size
	block_bits	=> 4,		-- 2*block_bits is number of cache blocks
	spm_width	=> 0		-- size of scratchpad RAM (in number of address bits for 32-bit words)
)

port map(
	clk		=> clk0,
	
--
---- serial interface
--
	ser_txd			=> tx,
	ser_rxd			=> rx,

--
--	watchdog
--
	wd		=> wd,
--

--  Control Signals to Wizardry
--	configuration_trigger => configuration_trigger_s,
	eRCP_trigger_reg => eRCP_trigger_s, --eRCP_trigger_reg_s,
---==========================================================--
----===========Virtex-4 SRAM Port============================--
	sram_clk => sram_clk,
	sram_feedback_clk => sram_feedback_clk,
	
	sram_addr => sram_addr,
	
	sram_we_n => sram_we_n,
	sram_oe_n => sram_oe_n,

	sram_data => sram_data,
	
	sram_bw0 => sram_bw0,
	sram_bw1 => sram_bw1,
	
	sram_bw2 => sram_bw2,
	sram_bw3 => sram_bw3,
	
	sram_adv_ld_n => sram_adv_ld_n,
	sram_mode => sram_mode,
	sram_cen => sram_cen,
	sram_cen_test => sram_cen_test,
	sram_zz => sram_zz,

---=========================================================---
---=========================================================---

--
--	I/O pins of board TODO: change this and io for xilinx board!
--
--	io_b	: inout std_logic_vector(10 downto 1);
--	io_l	: inout std_logic_vector(20 downto 1);
--	io_r	: inout std_logic_vector(20 downto 1);
--	io_t	: inout std_logic_vector(6 downto 1)

-- Wizardry Interface
	ack_i => Memory_Access_out.ack_o(8),
	err_i => Memory_Access_out.err_o(8),
	dat_i => Memory_Access_out.dat_o(8),
	cyc_o => Memory_Access_in.cyc_i(8),
	stb_o => Memory_Access_in.stb_i(8),
	we_o => Memory_Access_in.we_i(8),
	dat_o => Memory_Access_in.dat_i(8),
	adr_o => Memory_Access_in.adr_i(8),
	lock_o => Memory_Access_in.lock_i(8),
--	id_o => open, --Memory_Access_in.id_i(8),
	priority_o => Memory_Access_in.priority_i(8)
);

Wizardry_Top_Level : Wizardry_Top
    Port Map( clock => clk0,
				phy_clock => phy_clock, --clk0, --open, --phy_clock,
				reset => sync_reset,--sync_reset_n,
				phy_reset => phy_reset, --open, --phy_reset,
				phy_data_in => phy_data_in,
				phy_data_valid_in => phy_data_valid_in,
				rx_sdata => WIZ_rx_sdata,
				tx_sdata => WIZ_tx_sdata,
				leds => leds_dummy, --open,
				device_clock_fb => device_clock_fb,
				
				--  Configuration Trigger Signal
			new_configuration => eRCP_trigger_s, 
				
				------WB Signals
					---WB Out Signals
				adr_o	 	=> Memory_Access_in.adr_i(4),
				dat_o	 	=> Memory_Access_in.dat_i(4),
				we_o	 	=> Memory_Access_in.we_i(4),
				sel_o	 	=> Memory_Access_in.sel_i(4),
				stb_o	 	=> Memory_Access_in.stb_i(4),
				cyc_o	 	=> Memory_Access_in.cyc_i(4),
				ID_o	 	=> Memory_Access_in.ID_i(4),
				priority_o => Memory_Access_in.priority_i(4),
				lock_o   => Memory_Access_in.lock_i(4),
					---WB IN Signals
				err_i	 	=> Memory_Access_out.err_o(4),
				ack_i	 	=> Memory_Access_out.ack_o(4),
				dat_i	 	=> Memory_Access_out.dat_o(4),
				
				------WB Signals 2
					---WB Out Signals
				adr_o_0	 	=> Memory_Access_in.adr_i(0),
				dat_o_0	 	=> Memory_Access_in.dat_i(0),
				we_o_0	 	=> Memory_Access_in.we_i(0),
				sel_o_0	 	=> Memory_Access_in.sel_i(0),
				stb_o_0	 	=> Memory_Access_in.stb_i(0),
				cyc_o_0	 	=> Memory_Access_in.cyc_i(0),
				ID_o_0	 	=> Memory_Access_in.ID_i(0),
				priority_o_0 => Memory_Access_in.priority_i(0),
				lock_o_0   => Memory_Access_in.lock_i(0),
					---WB IN Signals
				err_i_0	 	=> Memory_Access_out.err_o(0),
				ack_i_0	 	=> Memory_Access_out.ack_o(0),
				dat_i_0	 	=> Memory_Access_out.dat_o(0),
				
					--EMPAC WB SIGNALS
				empac_ack_i => Memory_Access_out.ack_o(3),
				empac_dat_i => Memory_Access_out.dat_o(3),
				empac_err_i => Memory_Access_out.err_o(3),
				empac_dat_o => Memory_Access_in.dat_i(3),
				empac_adr_o => Memory_Access_in.adr_i(3),
				empac_cyc_o => Memory_Access_in.cyc_i(3),
				empac_stb_o => Memory_Access_in.stb_i(3),
				empac_we_o => Memory_Access_in.we_i(3),
				empac_lock_o => Memory_Access_in.lock_i(3),
				empac_priority_o => Memory_Access_in.priority_i(3),
				empac_id_o => Memory_Access_in.id_i(3),
				
				--  Debug Signals to top level
				eRCP_busy => eRCP_busy_s,
				interactive_instructions => interactive_instructions_s
--				,
--				rdcount => rdcount,
--			   wrcount => wrcount,
--				empac_empty_debug => empac_empty_debug,
--				empac_full_debug => empac_full_debug
			  
			  );

Xilinx_RDIC_Bridge : RDIC_Xilinx_bridge
    Port Map( clock => clk0,
           reset => sync_reset,
			  fifo_empty_out => MAC_out.FIFO_empty_out,
			  write_enable_out => MAC_out.write_enable_out,
			  APP_AF_WREN   => cntrl0_APP_AF_WREN,
				APP_WDF_WREN => cntrl0_APP_WDF_WREN,
				ack_access_in => MAC_in.ack_access_in,
				command => command_s,
				mask => cntrl0_app_mask_data
);

--WB_UART_Component : wc_uart_controller
--    Port Map( clock => clk0,
--			  device_clock => device_clock_fb_0,
--           reset => sync_reset,
--           cyc_o => Memory_Access_in.cyc_i(7),
--           stb_o => Memory_Access_in.stb_i(7),
--           we_o => Memory_Access_in.we_i(7),
--           adr_o => Memory_Access_in.adr_i(7),
--           dat_o => Memory_Access_in.dat_i(7),
--           dat_i => Memory_Access_out.dat_o(7),
--           ack_i => Memory_Access_out.ack_o(7),
--			  err_i => Memory_Access_out.err_o(7),
--			  priority_o => Memory_Access_in.priority_i(7),
--			  id_o => Memory_Access_in.ID_i(7),
--			  lock_o => Memory_Access_in.lock_i(7),
--			  eRCP_busy => eRCP_busy_s,
--			  interactive_instructions => interactive_instructions_s,
--           rx => rx_s, --rx,
--           tx => tx_s --tx
--);


process(cntrl0_read_data_valid,clk0,rst_r)
begin
if(clk0'event and clk0 = '1') then
      if(rst_r = '1') then
        store_rd_data <= '0';
        store_rd_data_0  <= '0';
      elsif(cntrl0_read_data_valid = '1') then
        store_rd_data <= store_rd_data_0;
        store_rd_data_0  <= '1';
		else
		  store_rd_data <= store_rd_data_0;
        store_rd_data_0  <= '0';
      end if;
    end if;
end process;


process(store_rd_data,clk0,rst_r)
begin
--if(clk0'event and clk0 = '1') then
if(rst_r = '1') then
--  dat_i_shift_reg(0) <= (others => '0');
--  dat_i_shift_reg(1) <= (others => '0');
--  dat_i_shift_reg(2) <= (others => '0');
--  dat_i_shift_reg(3) <= (others => '0');
--  dat_i <= (others => '0');
elsif(clk0'event and clk0 = '1') then
	if(cntrl0_read_data_valid = '1') then
	  dat_i_shift_reg(0) <= dat_i_shift_reg(1);
	  dat_i_shift_reg(1) <= dat_i_shift_reg(2);
	  dat_i_shift_reg(2) <= dat_i_shift_reg(3);
	  dat_i_shift_reg(3) <= cntrl0_read_data_fifo_out;
	  dat_i <= dat_i_shift_reg(2)(63 downto 32);
	else
	  dat_i_shift_reg(0) <= dat_i_shift_reg(0);
	  dat_i_shift_reg(1) <= dat_i_shift_reg(1);
	  dat_i_shift_reg(2) <= dat_i_shift_reg(2);
	  dat_i_shift_reg(3) <= dat_i_shift_reg(3);	  
	  dat_i <= dat_i_shift_reg(2)(63 downto 32);
	end if;
end if;
end process;

--process(store_rd_data,clk0,rst_r)
--begin
--if(clk0'event and clk0 = '1') then
--      if(rst_r = '1') then
--        dat_i <= X"00000000";
--		elsif(store_rd_data = '1') then
--		  dat_i <= cntrl0_read_data_fifo_out(63 downto 32);
--      else
--        dat_i <= dat_i;
--      end if;
--    end if;
--end process;
--


-----------------My stuff above-------------------

  unused_data_in   <= X"00000000";
  unused_data_in_p <= "0000";
  gnd              <= '0';
--  cntrl0_app_wdf_data <= X"00FF00FF00FF00FF";
--  cntrl0_app_mask_data <= "00000000";
--  cntrl0_app_wdf_wren <= '1';

-- ADDRESS generation for Write and Read Address FIFOs

-- RAMB16_S36 is set to 512x36 mode

-- INITP_00 (2 downto 0)
-- read -5
-- write -4
-- lmr - 0
-- pre -2
-- ref -1
-- active -3


  wr_rd_addr_lookup : RAMB16_S36
    generic map(
      INIT_00  => X"0003C154_0003C198_0003C088_0003C0EC_00023154_00023198_00023088_000230EC",
      INIT_01  => X"00023154_00023198_00023088_000230EC_0003C154_0003C198_0003C088_0003C0EC",
      INIT_02  => X"0083C154_0083C198_0083C088_0083C0EC_00823154_00823198_00823088_008230EC",
      INIT_03  => X"0083C154_0083C198_0083C088_0083C0EC_00823154_00823198_00823088_008230EC",
      INIT_04  => X"0043C154_0043C198_0043C088_0043C0EC_00423154_00423198_00423088_004230EC",
      INIT_05  => X"0043C154_0043C198_0043C088_0043C0EC_00423154_00423198_00423088_004230EC",
      INIT_06  => X"00C3C154_00C3C198_00C3C088_00C3C0EC_00C23154_00C23198_00C23088_00C230EC",
      INIT_07  => X"00C3C154_00C3C198_00C3C088_00C3C0EC_00C23154_00C23198_00C23088_00C230EC",
      INITP_00 => X"55555555_44444444_55555555_44444444_55555555_44444444_55555555_44444444")
    port map (
      DO   => addr_out(31 downto 0),
      DOP  => addr_out(35 downto 32),
      ADDR => wr_rd_addr(8 downto 0),
      clk  => clk0,
      DI   => unused_data_in(31 downto 0),
      DIP  => unused_data_in_p(3 downto 0),
      EN   => wr_rd_addr_en_reg,
      SSR  => gnd,
      WE   => gnd
      );





  wr_rd_addr_en <= bkend_wraddr_en;


  process(clk0)
  begin
    if(clk0'event and clk0 = '1') then
      rst_r <= sync_reset;
    end if;
  end process;
  
  process(clk0,rst_r)
  begin
    if(rst_r = '1') then
		jop_reset_cnt <= "000000000000000";
	 elsif(clk0'event and clk0 = '1') then
		if(jop_reset_cnt = "111111111111111") then 
			--jop_reset_cnt <= jop_reset_cnt;
			jop_reset <= '0'; 
		else
			jop_reset_cnt <= jop_reset_cnt + '1';
			jop_reset <= '1';
		end if;
    end if;
  end process;

--	jop_reset <= '0' when jop_reset_cnt = 

  process(clk0)
  begin
    if(clk0'event and clk0 = '1') then
      if(rst_r = '1') then
        wr_rd_addr_en_reg <= '0';
      else
        wr_rd_addr_en_reg <= wr_rd_addr_en;
      end if;
    end if;
  end process;

--register backend enables
  process(clk0)
  begin
    if(clk0'event and clk0 = '1') then
      if(rst_r = '1') then
        bkend_wraddr_en_reg <= '0';
        bkend_wraddr_en_3r  <= '0';
      else
        bkend_wraddr_en_reg <= bkend_wraddr_en;
        bkend_wraddr_en_3r  <= bkend_wraddr_en_reg;
      end if;
    end if;
  end process;

----FIFO enables
--  process(clk0)
--  begin
--    if(clk0'event and clk0 = '1') then
--      if(rst_r = '1') then
--        app_af_wren <= '0';
--      else
--        app_af_wren <= bkend_wraddr_en_3r;
--      end if;
--    end if;
--  end process;

----FIFO addresses
--  process(clk0)
--  begin
--    if(clk0'event and clk0 = '1') then
--      if(rst_r = '1') then
--        app_af_addr <= (others => '0');
--      elsif(bkend_wraddr_en_3r = '1') then
--        app_af_addr <= addr_out(35 downto 0);
--      else
--        app_af_addr <= (others => '0');
--      end if;
--    end if;
--  end process;

--address input
  process(clk0)
  begin
    if(clk0'event and clk0 = '1') then
      if(rst_r = '1') then
        wr_addr_count <= "111111";
      elsif(bkend_wraddr_en = '1') then
        wr_addr_count <= wr_addr_count + '1';
      else
        wr_addr_count <= wr_addr_count;
      end if;
    end if;
  end process;


  wr_rd_addr <= ("000" & wr_addr_count) when (bkend_wraddr_en_reg = '1') else
                "000000000";

--Memory_Access_in.id_i(0)	<= "11111";
--Memory_Access_in.id_i(1)	<= "11110";
--Memory_Access_in.id_i(3)	<= "11101";
--Memory_Access_in.id_i(4)	<= "11100";
--Memory_Access_in.id_i(5)	<= "11011";
--Memory_Access_in.id_i(6)	<= "11010";
--Memory_Access_in.id_i(7)	<= "11001";

process(clk0)
begin
--	if(clk0'event and clk0 = '1') then
	for i in 0 to (num_of_ports) loop
			Memory_Access_in.adr_i(i)	 <= (others => 'Z');
			Memory_Access_in.dat_i(i)	 <= (others => 'Z');
			Memory_Access_in.we_i(i)	 <= 'Z';
			Memory_Access_in.stb_i(i)	 	<= 'Z';
			Memory_Access_in.cyc_i(i)	 <= 'Z';
			Memory_Access_in.push_i(i) 	<= 'Z';
			Memory_Access_in.lock_i(i)   <= 'Z';
			Memory_Access_in.priority_i(i) <= (others => 'Z');
		end loop;
--	end if;
end process;

process(clk0)
begin
	for i in 0 to (num_of_ports -1) loop
		Memory_Access_in.id_i(i)	<= (others => 'Z');
		Memory_Access_in.sel_i(i)	 <= (others => 'Z');
	end loop;
end process;





end arch;
