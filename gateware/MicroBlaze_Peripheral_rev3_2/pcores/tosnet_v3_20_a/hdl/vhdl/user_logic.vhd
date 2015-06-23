------------------------------------------------------------------------------
-- user_logic.vhd - entity/architecture pair
------------------------------------------------------------------------------
--
-- ***************************************************************************
-- ** Copyright (c) 1995-2010 Xilinx, Inc.  All rights reserved.            **
-- **                                                                       **
-- ** Xilinx, Inc.                                                          **
-- ** XILINX IS PROVIDING THIS DESIGN, CODE, OR INFORMATION "AS IS"         **
-- ** AS A COURTESY TO YOU, SOLELY FOR USE IN DEVELOPING PROGRAMS AND       **
-- ** SOLUTIONS FOR XILINX DEVICES.  BY PROVIDING THIS DESIGN, CODE,        **
-- ** OR INFORMATION AS ONE POSSIBLE IMPLEMENTATION OF THIS FEATURE,        **
-- ** APPLICATION OR STANDARD, XILINX IS MAKING NO REPRESENTATION           **
-- ** THAT THIS IMPLEMENTATION IS FREE FROM ANY CLAIMS OF INFRINGEMENT,     **
-- ** AND YOU ARE RESPONSIBLE FOR OBTAINING ANY RIGHTS YOU MAY REQUIRE      **
-- ** FOR YOUR IMPLEMENTATION.  XILINX EXPRESSLY DISCLAIMS ANY              **
-- ** WARRANTY WHATSOEVER WITH RESPECT TO THE ADEQUACY OF THE               **
-- ** IMPLEMENTATION, INCLUDING BUT NOT LIMITED TO ANY WARRANTIES OR        **
-- ** REPRESENTATIONS THAT THIS IMPLEMENTATION IS FREE FROM CLAIMS OF       **
-- ** INFRINGEMENT, IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS       **
-- ** FOR A PARTICULAR PURPOSE.                                             **
-- **                                                                       **
-- ***************************************************************************
--
------------------------------------------------------------------------------
-- Filename:          user_logic.vhd
-- Version:           3.20.a
-- Description:       User logic.
-- Date:              Tue Aug 03 15:27:10 2010 (by Create and Import Peripheral Wizard)
-- VHDL Standard:     VHDL'93
------------------------------------------------------------------------------
-- Naming Conventions:
--   active low signals:                    "*_n"
--   clock signals:                         "clk", "clk_div#", "clk_#x"
--   reset signals:                         "rst", "rst_n"
--   generics:                              "C_*"
--   user defined types:                    "*_TYPE"
--   state machine next state:              "*_ns"
--   state machine current state:           "*_cs"
--   combinatorial signals:                 "*_com"
--   pipelined or register delay signals:   "*_d#"
--   counter signals:                       "*cnt*"
--   clock enable signals:                  "*_ce"
--   internal version of output port:       "*_i"
--   device pins:                           "*_pin"
--   ports:                                 "- Names begin with Uppercase"
--   processes:                             "*_PROCESS"
--   component instantiations:              "<ENTITY_>I_<#|FUNC>"
------------------------------------------------------------------------------

-- DO NOT EDIT BELOW THIS LINE --------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library proc_common_v3_00_a;
use proc_common_v3_00_a.proc_common_pkg.all;

-- DO NOT EDIT ABOVE THIS LINE --------------------

--USER libraries added here

------------------------------------------------------------------------------
-- Entity section
------------------------------------------------------------------------------
-- Definition of Generics:
--   C_SLV_AWIDTH                 -- Slave interface address bus width
--   C_SLV_DWIDTH                 -- Slave interface data bus width
--   C_NUM_REG                    -- Number of software accessible registers
--   C_NUM_MEM                    -- Number of memory spaces
--
-- Definition of Ports:
--   Bus2IP_Clk                   -- Bus to IP clock
--   Bus2IP_Reset                 -- Bus to IP reset
--   Bus2IP_Addr                  -- Bus to IP address bus
--   Bus2IP_CS                    -- Bus to IP chip select for user logic memory selection
--   Bus2IP_RNW                   -- Bus to IP read/not write
--   Bus2IP_Data                  -- Bus to IP data bus
--   Bus2IP_BE                    -- Bus to IP byte enables
--   Bus2IP_RdCE                  -- Bus to IP read chip enable
--   Bus2IP_WrCE                  -- Bus to IP write chip enable
--   IP2Bus_Data                  -- IP to Bus data bus
--   IP2Bus_RdAck                 -- IP to Bus read transfer acknowledgement
--   IP2Bus_WrAck                 -- IP to Bus write transfer acknowledgement
--   IP2Bus_Error                 -- IP to Bus error response
------------------------------------------------------------------------------

entity user_logic is
  generic
  (
    -- ADD USER GENERICS BELOW THIS LINE ---------------
    C_REG_ENABLE                   : std_logic_vector(7 downto 0)     := X"00";
	C_NODE_ID                      : integer              := 0;
	C_MAX_SKIPPED_READS            : integer              := 0;
	C_MAX_SKIPPED_WRITES           : integer              := 0;
	C_WATCHDOG_THRESHOLD           : integer              := 16384;
	C_DISABLE_MASTER               : std_logic            := '0';
	C_DISABLE_SLAVE                : std_logic            := '0';
	C_DISABLE_ASYNC                : std_logic            := '0';
    -- ADD USER GENERICS ABOVE THIS LINE ---------------

    -- DO NOT EDIT BELOW THIS LINE ---------------------
    -- Bus protocol parameters, do not add to or delete
    C_SLV_AWIDTH                   : integer              := 32;
    C_SLV_DWIDTH                   : integer              := 32;
    C_NUM_REG                      : integer              := 5;
    C_NUM_MEM                      : integer              := 1
    -- DO NOT EDIT ABOVE THIS LINE ---------------------
  );
  port
  (
    -- ADD USER PORTS BELOW THIS LINE ------------------
    sig_in                         : in  std_logic;
	sig_out                        : out std_logic;
	clk_50M                        : in  std_logic;
	sync_strobe                    : out std_logic;
	system_halt                    : out std_logic;
    -- ADD USER PORTS ABOVE THIS LINE ------------------

    -- DO NOT EDIT BELOW THIS LINE ---------------------
    -- Bus protocol ports, do not add to or delete
    Bus2IP_Clk                     : in  std_logic;
    Bus2IP_Reset                   : in  std_logic;
    Bus2IP_Addr                    : in  std_logic_vector(0 to C_SLV_AWIDTH-1);
    Bus2IP_CS                      : in  std_logic_vector(0 to C_NUM_MEM-1);
    Bus2IP_RNW                     : in  std_logic;
    Bus2IP_Data                    : in  std_logic_vector(0 to C_SLV_DWIDTH-1);
    Bus2IP_BE                      : in  std_logic_vector(0 to C_SLV_DWIDTH/8-1);
    Bus2IP_RdCE                    : in  std_logic_vector(0 to C_NUM_REG-1);
    Bus2IP_WrCE                    : in  std_logic_vector(0 to C_NUM_REG-1);
    IP2Bus_Data                    : out std_logic_vector(0 to C_SLV_DWIDTH-1);
    IP2Bus_RdAck                   : out std_logic;
    IP2Bus_WrAck                   : out std_logic;
    IP2Bus_Error                   : out std_logic
    -- DO NOT EDIT ABOVE THIS LINE ---------------------
  );

  attribute SIGIS : string;
  attribute SIGIS of Bus2IP_Clk    : signal is "CLK";
  attribute SIGIS of Bus2IP_Reset  : signal is "RST";

end entity user_logic;

------------------------------------------------------------------------------
-- Architecture section
------------------------------------------------------------------------------

architecture IMP of user_logic is

  --USER signal declarations added here, as needed for user logic

	component tdl_top is
	Port( 	node_id					: in	STD_LOGIC_VECTOR(3 downto 0);
			reg_enable				: in	STD_LOGIC_VECTOR(7 downto 0);
			watchdog_threshold		: in	STD_LOGIC_VECTOR(17 downto 0);
			data_out_ext			: out	STD_LOGIC_VECTOR(7 downto 0);
			data_out_strobe_ext		: out	STD_LOGIC;
			data_out_enable_ext		: out	STD_LOGIC;
			data_in_ext				: in	STD_LOGIC_VECTOR(7 downto 0);
			data_in_strobe_ext		: in	STD_LOGIC;
			data_in_enable_ext		: in	STD_LOGIC;
			buffer_full				: inout	STD_LOGIC;
			packet_error			: inout	STD_LOGIC;
			force_packet_error		: inout	STD_LOGIC;
			sync_strobe				: inout	STD_LOGIC;
			online					: out	STD_LOGIC;
			network_reg_addr		: in	STD_LOGIC_VECTOR(3 downto 0);
			network_reg_data		: out	STD_LOGIC_VECTOR(31 downto 0);
			network_reg_clk			: in	STD_LOGIC;
			node_is_master			: out	STD_LOGIC;
			node_address			: out	STD_LOGIC_VECTOR(3 downto 0);
			clk_50M					: in	STD_LOGIC;
			reset					: in	STD_LOGIC;
			sig_in					: in	STD_LOGIC;
			sig_out					: inout	STD_LOGIC);
	end component;
	
	component tal_top is
	Generic(disable_slave			: STD_LOGIC := '0';
			disable_master			: STD_LOGIC := '0';
			disable_async			: STD_LOGIC := '0');
	Port(	node_id					: in 	STD_LOGIC_VECTOR(3 downto 0);
			max_skipped_writes		: in 	STD_LOGIC_VECTOR(15 downto 0);
			max_skipped_reads		: in 	STD_LOGIC_VECTOR(15 downto 0);
			data_in					: in	STD_LOGIC_VECTOR(7 downto 0);
			data_in_strobe			: in	STD_LOGIC;
			data_in_enable			: in	STD_LOGIC;
			data_out				: out	STD_LOGIC_VECTOR(7 downto 0);
			data_out_strobe			: out	STD_LOGIC;
			data_out_enable			: out	STD_LOGIC;
			buffer_full				: in	STD_LOGIC;
			packet_error			: in	STD_LOGIC;
			force_packet_error		: out	STD_LOGIC;
			sync_strobe				: in	STD_LOGIC;
			network_reg_addr		: out	STD_LOGIC_VECTOR(3 downto 0);
			network_reg_data		: in	STD_LOGIC_VECTOR(31 downto 0);
			network_reg_clk			: out	STD_LOGIC;
			data_reg_addr			: in	STD_LOGIC_VECTOR(9 downto 0);
			data_reg_data_in		: in	STD_LOGIC_VECTOR(31 downto 0);
			data_reg_data_out		: out	STD_LOGIC_VECTOR(31 downto 0);
			data_reg_clk			: in	STD_LOGIC;
			data_reg_we				: in	STD_LOGIC_VECTOR(0 downto 0);
			data_reg_commit_write 	: in	STD_LOGIC;
			data_reg_commit_read	: in	STD_LOGIC;
			skip_count_write		: out	STD_LOGIC_VECTOR(15 downto 0);
			skip_count_read			: out	STD_LOGIC_VECTOR(15 downto 0);
			current_buffer_index	: out	STD_LOGIC_VECTOR(3 downto 0);
			node_address			: in	STD_LOGIC_VECTOR(3 downto 0);
			is_master				: in	STD_LOGIC;
			clk_50M					: in	STD_LOGIC;
			pause					: in	STD_LOGIC;
			pause_ack				: out	STD_LOGIC;
			reset					: in	STD_LOGIC;
			system_halt				: out	STD_LOGIC;
			reset_counter			: out 	STD_LOGIC_VECTOR(31 downto 0);
			packet_counter			: out 	STD_LOGIC_VECTOR(31 downto 0);
			error_counter			: out 	STD_LOGIC_VECTOR(31 downto 0);
			async_in_data			: in	STD_LOGIC_VECTOR(37 downto 0);
			async_out_data			: out	STD_LOGIC_VECTOR(37 downto 0);
			async_in_clk			: in	STD_LOGIC;
			async_out_clk			: in	STD_LOGIC;
			async_in_full			: out	STD_LOGIC;
			async_out_empty			: out	STD_LOGIC;
			async_in_wr_en			: in	STD_LOGIC;
			async_out_rd_en			: in	STD_LOGIC;
			async_out_valid			: out	STD_LOGIC);
	end component;

	signal sig_out_int				: STD_LOGIC;
	signal data_up					: STD_LOGIC_VECTOR(7 downto 0);
	signal data_up_strobe			: STD_LOGIC;
	signal data_up_enable			: STD_LOGIC;
	signal data_down				: STD_LOGIC_VECTOR(7 downto 0);
	signal data_down_strobe			: STD_LOGIC;
	signal data_down_enable			: STD_LOGIC;
	signal buffer_full				: STD_LOGIC;
	signal sync_strobe_int			: STD_LOGIC;
	signal network_reg_addr			: STD_LOGIC_VECTOR(3 downto 0);
	signal network_reg_data			: STD_LOGIC_VECTOR(31 downto 0);
	signal network_reg_clk			: STD_LOGIC;
	signal node_address				: STD_LOGIC_VECTOR(3 downto 0);
	signal node_is_master			: STD_LOGIC;
	signal packet_error				: STD_LOGIC;
	signal online					: STD_LOGIC;
	signal app_reset				: STD_LOGIC;
	signal force_packet_error		: STD_LOGIC;
	signal max_skipped_writes		: STD_LOGIC_VECTOR(15 downto 0);
	signal max_skipped_reads		: STD_LOGIC_VECTOR(15 downto 0);
	signal watchdog_threshold		: STD_LOGIC_VECTOR(17 downto 0);
	signal data_reg_addr			: STD_LOGIC_VECTOR(9 downto 0);
	signal data_reg_data_in			: STD_LOGIC_VECTOR(31 downto 0);
	signal data_reg_data_out		: STD_LOGIC_VECTOR(31 downto 0);
	signal data_reg_clk				: STD_LOGIC;
	signal data_reg_we				: STD_LOGIC_VECTOR(0 downto 0);
	signal commit_write				: STD_LOGIC;
	signal commit_read				: STD_LOGIC;
	signal system_halt_int			: STD_LOGIC;
	signal packet_counter			: STD_LOGIC_VECTOR(31 downto 0);
	signal error_counter			: STD_LOGIC_VECTOR(31 downto 0);
	signal reset_counter			: STD_LOGIC_VECTOR(31 downto 0);
	
	signal async_in_data			: STD_LOGIC_VECTOR(37 downto 0);
	signal async_out_data			: STD_LOGIC_VECTOR(37 downto 0);
	signal async_rd_en				: STD_LOGIC;
	signal async_wr_en				: STD_LOGIC;
	signal async_empty				: STD_LOGIC;
	signal async_full				: STD_LOGIC;
	signal async_valid				: STD_LOGIC;
	signal async_rd_node_id			: STD_LOGIC_VECTOR(3 downto 0);
	signal async_wr_node_id			: STD_LOGIC_VECTOR(3 downto 0);
	signal async_rd_be				: STD_LOGIC_VECTOR(1 downto 0);
	signal async_wr_be				: STD_LOGIC_VECTOR(1 downto 0);

  ------------------------------------------
  -- Signals for user logic slave model s/w accessible register example
  ------------------------------------------
  signal slv_reg0                       : std_logic_vector(0 to C_SLV_DWIDTH-1);
  signal slv_reg1                       : std_logic_vector(0 to C_SLV_DWIDTH-1);
  signal slv_reg2                       : std_logic_vector(0 to C_SLV_DWIDTH-1);
  signal slv_reg3                       : std_logic_vector(0 to C_SLV_DWIDTH-1);
  signal slv_reg4                       : std_logic_vector(0 to C_SLV_DWIDTH-1);
  signal slv_reg_write_sel              : std_logic_vector(0 to 4);
  signal slv_reg_read_sel               : std_logic_vector(0 to 4);
  signal slv_ip2bus_data                : std_logic_vector(0 to C_SLV_DWIDTH-1);
  signal slv_read_ack                   : std_logic;
  signal slv_write_ack                  : std_logic;

  ------------------------------------------
  -- Signals for user logic memory space example
  ------------------------------------------
  type BYTE_RAM_TYPE is array (0 to 255) of std_logic_vector(0 to 7);
  type DO_TYPE is array (0 to C_NUM_MEM-1) of std_logic_vector(0 to C_SLV_DWIDTH-1);
  signal mem_data_out                   : DO_TYPE;
  signal mem_address                    : std_logic_vector(0 to 7);
  signal mem_select                     : std_logic_vector(0 to 0);
  signal mem_read_enable                : std_logic;
  signal mem_read_enable_dly1           : std_logic;
  signal mem_read_req                   : std_logic;
  signal mem_ip2bus_data                : std_logic_vector(0 to C_SLV_DWIDTH-1);
  signal mem_read_ack_dly1              : std_logic;
  signal mem_read_ack                   : std_logic;
  signal mem_write_ack                  : std_logic;

begin

  --USER logic implementation added here

	tdl_top_inst : tdl_top
	Port map ( 	node_id => conv_std_logic_vector(C_NODE_ID, 4),
				reg_enable => C_REG_ENABLE,
				watchdog_threshold => conv_std_logic_vector(C_WATCHDOG_THRESHOLD, 18),
				sig_in => sig_in,
				sig_out => sig_out_int,
				reset => Bus2IP_Reset,
				clk_50M => clk_50M,
				data_in_ext => data_down,
				data_in_enable_ext => data_down_enable,
				data_in_strobe_ext => data_down_strobe,
				data_out_ext => data_up,
				data_out_enable_ext => data_up_enable,
				data_out_strobe_ext => data_up_strobe,
				buffer_full => buffer_full,
				packet_error => packet_error,
				force_packet_error => force_packet_error,
				sync_strobe => sync_strobe_int,
				online => online,
				network_reg_addr => network_reg_addr,
				network_reg_data => network_reg_data,
				network_reg_clk => network_reg_clk,
				node_address => node_address,
				node_is_master => node_is_master);

	application_inst : tal_top
	Generic map(disable_master => C_DISABLE_MASTER,
				disable_slave => C_DISABLE_SLAVE,
				disable_async => C_DISABLE_ASYNC)
	Port map( 	node_id => conv_std_logic_vector(C_NODE_ID, 4),
				max_skipped_writes => conv_std_logic_vector(C_MAX_SKIPPED_WRITES, 16),
				max_skipped_reads => conv_std_logic_vector(C_MAX_SKIPPED_READS, 16),
				data_in => data_up,
				data_in_strobe => data_up_strobe,
				data_in_enable => data_up_enable,
				data_out => data_down,
				data_out_strobe => data_down_strobe,
				data_out_enable => data_down_enable,
				buffer_full => buffer_full,
				packet_error => packet_error,
				force_packet_error => force_packet_error,
				sync_strobe => sync_strobe_int,
				network_reg_addr => network_reg_addr,
				network_reg_data => network_reg_data,
				network_reg_clk => network_reg_clk,
				node_address => node_address,
				is_master => node_is_master,
				data_reg_addr => data_reg_addr,
				data_reg_data_in => data_reg_data_in,
				data_reg_data_out => data_reg_data_out,
				data_reg_clk => data_reg_clk,
				data_reg_we => data_reg_we,
				data_reg_commit_write => commit_write,
				data_reg_commit_read => commit_read,
				clk_50M => clk_50M,
				pause => '0',
				reset => app_reset,
				system_halt => system_halt_int,
				packet_counter => packet_counter,
				error_counter => error_counter,
				reset_counter => reset_counter,
				async_in_data => async_in_data,
				async_out_data => async_out_data,
				async_in_clk => Bus2IP_Clk,
				async_out_clk => Bus2IP_Clk,
				async_in_full => async_full,
				async_out_empty => async_empty,
				async_in_wr_en => async_wr_en,
				async_out_rd_en => async_rd_en,
				async_out_valid => async_valid);
			

	app_reset <= not online;
	sig_out <= sig_out_int;
	
  ------------------------------------------
  -- Example code to read/write user logic slave model s/w accessible registers
  -- 
  -- Note:
  -- The example code presented here is to show you one way of reading/writing
  -- software accessible registers implemented in the user logic slave model.
  -- Each bit of the Bus2IP_WrCE/Bus2IP_RdCE signals is configured to correspond
  -- to one software accessible register by the top level template. For example,
  -- if you have four 32 bit software accessible registers in the user logic,
  -- you are basically operating on the following memory mapped registers:
  -- 
  --    Bus2IP_WrCE/Bus2IP_RdCE   Memory Mapped Register
  --                     "1000"   C_BASEADDR + 0x0
  --                     "0100"   C_BASEADDR + 0x4
  --                     "0010"   C_BASEADDR + 0x8
  --                     "0001"   C_BASEADDR + 0xC
  -- 
  ------------------------------------------
  slv_reg_write_sel <= Bus2IP_WrCE(0 to 4);
  slv_reg_read_sel  <= Bus2IP_RdCE(0 to 4);
  slv_write_ack     <= Bus2IP_WrCE(0) or Bus2IP_WrCE(1) or Bus2IP_WrCE(2) or Bus2IP_WrCE(3) or Bus2IP_WrCE(4);
  slv_read_ack      <= Bus2IP_RdCE(0) or Bus2IP_RdCE(1) or Bus2IP_RdCE(2) or Bus2IP_RdCE(3) or Bus2IP_RdCE(4);

  slv_reg0(0 to 3) <= async_rd_node_id;
  slv_reg0(4 to 5) <= async_rd_be;
  slv_reg0(6 to 7) <= "00";
  slv_reg0(8 to 15) <= C_REG_ENABLE;
  slv_reg0(16 to 19) <= node_address;
  slv_reg0(20 to 23) <= conv_std_logic_vector(C_NODE_ID, 4);
  slv_reg0(24) <= async_valid;
  slv_reg0(25) <= async_empty;
  slv_reg0(26) <= async_full;
  slv_reg0(27) <= system_halt_int;
  slv_reg0(28) <= node_is_master;
  slv_reg0(29) <= online;
  slv_reg0(30 to 31) <= "00";
  slv_reg1 <= packet_counter;
  slv_reg2 <= error_counter;
  slv_reg3 <= reset_counter;
  slv_reg4 <= async_out_data(31 downto 0) when async_valid = '1' else (others => '0');
  
  async_in_data(37 downto 36) <= async_wr_be;
  async_in_data(35 downto 32) <= async_wr_node_id;
  
  async_rd_node_id <= async_out_data(35 downto 32) when async_valid = '1' else (others => '0');
  async_rd_be <= async_out_data(37 downto 36) when async_valid = '1' else (others => '0');
  
  async_rd_en <= '1' when slv_reg_read_sel = "00001" else '0';
  
  -- implement slave model software accessible register(s)
  SLAVE_REG_WRITE_PROC : process( Bus2IP_Clk ) is
  begin

	if Bus2IP_Clk'event and Bus2IP_Clk = '1' then
		async_wr_en <= '0';
		case slv_reg_write_sel is
			when "10000" =>
				if ( Bus2IP_BE(0) = '1' ) then
					async_wr_node_id <= Bus2IP_Data(0 to 3);
					async_wr_be <= Bus2IP_Data(4 to 5);
				end if;
				if ( Bus2IP_BE(3) = '1' ) then
					commit_write <= Bus2IP_Data(30);
					commit_read <= Bus2IP_Data(31);
				end if;
			when "00001" =>
				if ( Bus2IP_BE = "1111" ) then
					async_in_data(31 downto 0) <= Bus2IP_Data;
					async_wr_en <= '1';
				end if;
			when others => null;
		end case;
	end if;

  end process SLAVE_REG_WRITE_PROC;

  -- implement slave model software accessible register(s) read mux
  SLAVE_REG_READ_PROC : process( slv_reg_read_sel, slv_reg0, slv_reg1, slv_reg2, slv_reg3, slv_reg4) is
  begin

    case slv_reg_read_sel is
      when "10000" => slv_ip2bus_data <= slv_reg0;
      when "01000" => slv_ip2bus_data <= slv_reg1;
      when "00100" => slv_ip2bus_data <= slv_reg2;
      when "00010" => slv_ip2bus_data <= slv_reg3;
      when "00001" => slv_ip2bus_data <= slv_reg4;
      when others => slv_ip2bus_data <= (others => '0');
    end case;

  end process SLAVE_REG_READ_PROC;

  ------------------------------------------
  -- Example code to generate user logic interrupts
  -- 
  -- Note:
  -- The example code presented here is to show you one way of generating
  -- interrupts from the user logic. This code snippet infers a counter
  -- and generate the interrupts whenever the counter rollover (the counter
  -- will rollover ~21 sec @50Mhz).
  ------------------------------------------

  sync_strobe <= sync_strobe_int;
  system_halt <= system_halt_int;

  ------------------------------------------
  -- Example code to access user logic memory region
  -- 
  -- Note:
  -- The example code presented here is to show you one way of using
  -- the user logic memory space features. The Bus2IP_Addr, Bus2IP_CS,
  -- and Bus2IP_RNW IPIC signals are dedicated to these user logic
  -- memory spaces. Each user logic memory space has its own address
  -- range and is allocated one bit on the Bus2IP_CS signal to indicated
  -- selection of that memory space. Typically these user logic memory
  -- spaces are used to implement memory controller type cores, but it
  -- can also be used in cores that need to access additional address space
  -- (non C_BASEADDR based), s.t. bridges. This code snippet infers
  -- 1 256x32-bit (byte accessible) single-port Block RAM by XST.
  ------------------------------------------
  mem_select		<= Bus2IP_CS;
  mem_read_ack		<= mem_read_ack_dly1;
  mem_write_ack		<= data_reg_we(0);
  mem_read_enable	<= Bus2IP_CS(0) and Bus2IP_RNW;
  data_reg_we(0)	<= Bus2IP_CS(0) and not Bus2IP_RNW;
  data_reg_addr		<= Bus2IP_Addr(20 to 29);
  data_reg_clk		<= Bus2IP_Clk;
  data_reg_data_in	<= Bus2IP_Data;

  -- implement single clock wide read request
  mem_read_req    <= mem_read_enable and not(mem_read_enable_dly1);
  BRAM_RD_REQ_PROC : process( Bus2IP_Clk ) is
  begin

    if ( Bus2IP_Clk'event and Bus2IP_Clk = '1' ) then
      if ( Bus2IP_Reset = '1' ) then
        mem_read_enable_dly1 <= '0';
      else
        mem_read_enable_dly1 <= mem_read_enable;
      end if;
    end if;

  end process BRAM_RD_REQ_PROC;

  -- this process generates the read acknowledge 1 clock after read enable
  -- is presented to the BRAM block. The BRAM block has a 1 clock delay
  -- from read enable to data out.
  BRAM_RD_ACK_PROC : process( Bus2IP_Clk ) is
  begin

    if ( Bus2IP_Clk'event and Bus2IP_Clk = '1' ) then
      if ( Bus2IP_Reset = '1' ) then
        mem_read_ack_dly1 <= '0';
      else
        mem_read_ack_dly1 <= mem_read_req;
      end if;
    end if;

  end process BRAM_RD_ACK_PROC;


  -- implement Block RAM read mux
  MEM_IP2BUS_DATA_PROC : process( data_reg_data_out, mem_select ) is
  begin

    case mem_select is
      when "1" => mem_ip2bus_data <= data_reg_data_out;
      when others => mem_ip2bus_data <= (others => '0');
    end case;

  end process MEM_IP2BUS_DATA_PROC;

  ------------------------------------------
  -- Example code to drive IP to Bus signals
  ------------------------------------------
  IP2Bus_Data  <= slv_ip2bus_data when slv_read_ack = '1' else
                  mem_ip2bus_data when mem_read_ack = '1' else
                  (others => '0');

  IP2Bus_WrAck <= slv_write_ack or mem_write_ack;
  IP2Bus_RdAck <= slv_read_ack or mem_read_ack;
  IP2Bus_Error <= '0';

end IMP;
