------------------------------------------------------------------------------
-- user_logic.vhd - entity/architecture pair
------------------------------------------------------------------------------
--
-- ***************************************************************************
-- ** Copyright (c) 1995-2009 Xilinx, Inc.  All rights reserved.            **
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
-- Version:           2.00.a
-- Description:       User logic.
-- Date:              Thu May 03 09:53:36 2012 (by Create and Import Peripheral Wizard)
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
library mod_sim_exp;
use mod_sim_exp.mod_sim_exp_pkg.all;

------------------------------------------------------------------------------
-- Entity section
------------------------------------------------------------------------------
-- Definition of Generics:
--   C_SLV_AWIDTH                 -- Slave interface address bus width
--   C_SLV_DWIDTH                 -- Slave interface data bus width
--   C_NUM_REG                    -- Number of software accessible registers
--   C_NUM_MEM                    -- Number of memory spaces
--   C_NUM_INTR                   -- Number of interrupt event
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
--   IP2Bus_IntrEvent             -- IP to Bus interrupt event
------------------------------------------------------------------------------

entity user_logic is
  generic
  (
    -- ADD USER GENERICS BELOW THIS LINE ---------------
    --USER generics added here
    -- Multiplier parameters
    C_NR_BITS_TOTAL   : integer := 1536;
    C_NR_STAGES_TOTAL : integer := 96;
    C_NR_STAGES_LOW   : integer := 32;
    C_SPLIT_PIPELINE  : boolean := true;
    C_FIFO_AW         : integer := 7;
    C_MEM_STYLE       : string  := "xil_prim"; -- xil_prim, generic, asym are valid options
    C_FPGA_MAN        : string  := "xilinx";    -- xilinx, altera are valid options
    -- ADD USER GENERICS ABOVE THIS LINE ---------------

    -- DO NOT EDIT BELOW THIS LINE ---------------------
    -- Bus protocol parameters, do not add to or delete
    C_SLV_AWIDTH                   : integer              := 32;
    C_SLV_DWIDTH                   : integer              := 32;
    C_NUM_REG                      : integer              := 1;
    C_NUM_MEM                      : integer              := 6;
    C_NUM_INTR                     : integer              := 1
    -- DO NOT EDIT ABOVE THIS LINE ---------------------
  );
  port
  (
    -- ADD USER PORTS BELOW THIS LINE ------------------
    --USER ports added here
	  calc_time                      : out std_logic;
	  core_clk                       : in std_logic;
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
    IP2Bus_Error                   : out std_logic;
    IP2Bus_IntrEvent               : out std_logic_vector(0 to C_NUM_INTR-1)
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

  ------------------------------------------------------------------
  -- Signals for multiplier core slave model s/w accessible register
  ------------------------------------------------------------------
  signal slv_reg0                       : std_logic_vector(0 to C_SLV_DWIDTH-1);
  signal slv_reg_write_sel              : std_logic_vector(0 to 0);
  signal slv_reg_read_sel               : std_logic_vector(0 to 0);
  signal slv_ip2bus_data                : std_logic_vector(0 to C_SLV_DWIDTH-1);
  signal slv_read_ack                   : std_logic;
  signal slv_write_ack                  : std_logic;

  signal load_flags                     : std_logic;

  ------------------------------------------------------------------
  -- Signals for multiplier core interrupt
  ------------------------------------------------------------------
  signal core_interrupt                 : std_logic_vector(0 to 0);
  signal core_fifo_full                 : std_logic;
  signal core_fifo_nopush               : std_logic;
  signal core_ready                     : std_logic;
  signal core_mem_collision             : std_logic;

  ------------------------------------------------------------------
  -- Signals for multiplier core control
  ------------------------------------------------------------------
  signal core_start                     : std_logic;
  signal core_exp_m                     : std_logic;
  signal core_p_sel                     : std_logic_vector(1 downto 0);
  signal core_dest_op_single            : std_logic_vector(1 downto 0);
  signal core_x_sel_single              : std_logic_vector(1 downto 0);
  signal core_y_sel_single              : std_logic_vector(1 downto 0);
  signal core_flags                     : std_logic_vector(15 downto 0);
  signal core_modulus_sel               : std_logic;

  ------------------------------------------------------------------
  -- Signals for multiplier core memory space
  ------------------------------------------------------------------
  signal mem_address                    : std_logic_vector(0 to 5);
  signal mem_select                     : std_logic_vector(0 to 5);
  signal mem_read_enable                : std_logic;
  signal mem_read_enable_dly1           : std_logic;
  signal mem_read_req                   : std_logic;
  signal mem_ip2bus_data                : std_logic_vector(0 to C_SLV_DWIDTH-1);
  signal mem_read_ack_dly1              : std_logic;
  signal mem_read_ack                   : std_logic;
  signal mem_write_ack                  : std_logic;

  signal core_rw_address                : std_logic_vector (8 downto 0);
  signal core_data_in                   : std_logic_vector(31 downto 0);
  signal core_fifo_din                  : std_logic_vector(31 downto 0);
  signal sel_mno                        : std_logic;
  signal sel_op                         : std_logic_vector(1 downto 0);
  signal core_data_out                  : std_logic_vector(31 downto 0);
  signal core_write_enable              : std_logic;
  signal core_fifo_push                 : std_logic;
begin

  --USER logic implementation added here
  --ctrl_sigs <= 

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
  slv_reg_write_sel <= Bus2IP_WrCE(0 to 0);
  slv_reg_read_sel  <= Bus2IP_RdCE(0 to 0);
  slv_write_ack     <= Bus2IP_WrCE(0);
  slv_read_ack      <= Bus2IP_RdCE(0);

  -- implement slave model software accessible register(s)
  SLAVE_REG_WRITE_PROC : process( Bus2IP_Clk ) is
  begin
    if Bus2IP_Clk'event and Bus2IP_Clk = '1' then
      if Bus2IP_Reset = '1' then
        slv_reg0 <= (others => '0');
      elsif load_flags = '1' then
		  slv_reg0 <= slv_reg0(0 to 15) & core_flags;
		else
        case slv_reg_write_sel is
          when "1" =>
            for byte_index in 0 to (C_SLV_DWIDTH/8)-1 loop
              if ( Bus2IP_BE(byte_index) = '1' ) then
                slv_reg0(byte_index*8 to byte_index*8+7) <= Bus2IP_Data(byte_index*8 to byte_index*8+7);
              end if;
            end loop;
          when others => null;
        end case;
      end if;
    end if;

  end process SLAVE_REG_WRITE_PROC;

  -- implement slave model software accessible register(s) read mux
  SLAVE_REG_READ_PROC : process( slv_reg_read_sel, slv_reg0 ) is
  begin

    case slv_reg_read_sel is
      when "1" => slv_ip2bus_data <= slv_reg0;
      when others => slv_ip2bus_data <= (others => '0');
    end case;

  end process SLAVE_REG_READ_PROC;

  ------------------------------------------
  -- Multiplier core interrupts form IP core interrupt
  ------------------------------------------

  core_interrupt(0) <= core_ready or core_mem_collision or core_fifo_full or core_fifo_nopush;
  IP2Bus_IntrEvent <= core_interrupt;

  FLAGS_CNTRL_PROC: process(Bus2IP_Clk, Bus2IP_Reset) is
  begin
    if Bus2IP_Reset = '1' then
	   core_flags <= (others => '0');
		load_flags <= '0';
    elsif rising_edge(Bus2IP_Clk) then
	   if core_start = '1' then
		  core_flags <= (others => '0');
		else
		  if core_ready = '1' then
		    core_flags(15) <= '1';
		  else
		    core_flags(15) <= core_flags(15);
		  end if;
		  if core_mem_collision = '1' then
		    core_flags(14) <= '1';
		  else
		    core_flags(14) <= core_flags(14);
		  end if;
		  if core_fifo_full = '1' then
			 core_flags(13) <= '1';
		  else
		    core_flags(13) <= core_flags(13);
		  end if;
		  if core_fifo_nopush = '1' then
			 core_flags(12) <= '1';
		  else
		    core_flags(12) <= core_flags(12);
		  end if;
		end if;
		--
		load_flags <= core_interrupt(0);
	 end if;
  end process FLAGS_CNTRL_PROC;

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
  -- 6 256x32-bit (byte accessible) single-port Block RAM by XST.
  ------------------------------------------
  mem_select      <= Bus2IP_CS;
  mem_read_enable <= ( Bus2IP_CS(0) or Bus2IP_CS(1) or Bus2IP_CS(2) or Bus2IP_CS(3) or Bus2IP_CS(4) or Bus2IP_CS(5) ) and Bus2IP_RNW;
  mem_read_ack    <= mem_read_ack_dly1;
  mem_write_ack   <= ( Bus2IP_CS(0) or Bus2IP_CS(1) or Bus2IP_CS(2) or Bus2IP_CS(3) or Bus2IP_CS(4) or Bus2IP_CS(5) ) and not(Bus2IP_RNW);
  mem_address     <= Bus2IP_Addr(C_SLV_AWIDTH-8 to C_SLV_AWIDTH-3);

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

    -- address logic
  Sel_MNO <= mem_select(0);
  with mem_select(1 to 4) select
    Sel_Op <= "00" when "1000",
	           "01" when "0100",
				  "10" when "0010",
				  "11" when others;
	 
  
  core_rw_address <= Sel_MNO & Sel_Op & mem_address;
  
  -- data-in
  core_data_in <= Bus2IP_Data;
  core_fifo_din <= Bus2IP_Data;
  core_write_enable <= (Bus2IP_CS(0) or Bus2IP_CS(1) or Bus2IP_CS(2) or Bus2IP_CS(3) or Bus2IP_CS(4)) and (not Bus2IP_RNW);
  core_fifo_push <= Bus2IP_CS(5) and (not Bus2IP_RNW);
  -- no read mux required, we can only read from core_data_out
  mem_ip2bus_data <= core_data_out;

  ------------------------------------------
  -- Map slv_reg0 bits to core control signals 
  ------------------------------------------
  
  core_p_sel <= slv_reg0(0 to 1);
  core_dest_op_single <= slv_reg0(2 to 3);
  core_x_sel_single <= slv_reg0(4 to 5);
  core_y_sel_single <= slv_reg0(6 to 7);
  core_start <= slv_reg0(8);
  core_exp_m <= slv_reg0(9);
  core_modulus_sel <= slv_reg0(10);

  ------------------------------------------
  -- Multiplier core instance
  ------------------------------------------
  the_multiplier: mod_sim_exp_core
  generic map(
    C_NR_BITS_TOTAL   => C_NR_BITS_TOTAL,
    C_NR_STAGES_TOTAL => C_NR_STAGES_TOTAL,
    C_NR_STAGES_LOW   => C_NR_STAGES_LOW,
    C_SPLIT_PIPELINE  => C_SPLIT_PIPELINE,
    C_FIFO_AW         => C_FIFO_AW,
    C_MEM_STYLE       => C_MEM_STYLE,
    C_FPGA_MAN        => C_FPGA_MAN
  )
  port map(
    core_clk  => core_clk,
    bus_clk   => Bus2IP_Clk,
    reset     => Bus2IP_Reset,
      -- operand memory interface (plb shared memory)
    write_enable => core_write_enable,
    data_in      => core_data_in,
    rw_address   => core_rw_address,
    data_out     => core_data_out,
    collision    => core_mem_collision,
      -- op_sel fifo interface
    fifo_din    => core_fifo_din,
    fifo_push   => core_fifo_push,
    fifo_full   => core_fifo_full,
    fifo_nopush => core_fifo_nopush,
      -- ctrl signals
    start          => core_start,
    exp_m          => core_exp_m,
    ready          => core_ready,
    x_sel_single   => core_x_sel_single,
    y_sel_single   => core_y_sel_single,
    dest_op_single => core_dest_op_single,
    p_sel          => core_p_sel,
    calc_time      => calc_time,
    modulus_sel    => core_modulus_sel
  );


  ------------------------------------------
  -- Drive IP to Bus signals
  ------------------------------------------
  IP2Bus_Data  <= slv_ip2bus_data when slv_read_ack = '1' else
                  mem_ip2bus_data when mem_read_ack = '1' else
                  (others => '0');

  IP2Bus_WrAck <= slv_write_ack or mem_write_ack;
  IP2Bus_RdAck <= slv_read_ack or mem_read_ack;
  IP2Bus_Error <= '0';

end IMP;
