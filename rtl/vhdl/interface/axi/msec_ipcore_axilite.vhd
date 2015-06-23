----------------------------------------------------------------------  
----  msec_ipcore_axilite                                         ---- 
----                                                              ---- 
----  This file is part of the                                    ----
----    Modular Simultaneous Exponentiation Core project          ---- 
----    http://www.opencores.org/cores/mod_sim_exp/               ---- 
----                                                              ---- 
----  Description                                                 ---- 
----    AXI-Lite bus interface for the mod_sim_exp_core. Has a    ----
----    fixed address decoder, address offsets are:               ----
----                                                              ----
----      M       : 0xXXXX0000                                    ----
----      OP0     : 0xXXXX1000                                    ----
----      OP1     : 0xXXXX2000                                    ----
----      OP2     : 0xXXXX3000                                    ----
----      OP3     : 0xXXXX4000                                    ----
----      FIFO    : 0xXXXX5000                                    ----
----      Control : 0xXXXX6000                                    ----
----                                                              ----
----    only the XXXX part of the address can be chosen freely    ----
----                                                              ----
----  Dependencies:                                               ----
----    - mod_sim_exp_core                                        ----
----                                                              ----
----  Authors:                                                    ----
----      - Geoffrey Ottoy, DraMCo research group                 ----
----      - Jonas De Craene, JonasDC@opencores.org                ---- 
----                                                              ---- 
---------------------------------------------------------------------- 
----                                                              ---- 
---- Copyright (C) 2011 DraMCo research group and OPENCORES.ORG   ---- 
----                                                              ---- 
---- This source file may be used and distributed without         ---- 
---- restriction provided that this copyright statement is not    ---- 
---- removed from the file and that any derivative work contains  ---- 
---- the original copyright notice and the associated disclaimer. ---- 
----                                                              ---- 
---- This source file is free software; you can redistribute it   ---- 
---- and/or modify it under the terms of the GNU Lesser General   ---- 
---- Public License as published by the Free Software Foundation; ---- 
---- either version 2.1 of the License, or (at your option) any   ---- 
---- later version.                                               ---- 
----                                                              ---- 
---- This source is distributed in the hope that it will be       ---- 
---- useful, but WITHOUT ANY WARRANTY; without even the implied   ---- 
---- warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      ---- 
---- PURPOSE.  See the GNU Lesser General Public License for more ---- 
---- details.                                                     ---- 
----                                                              ---- 
---- You should have received a copy of the GNU Lesser General    ---- 
---- Public License along with this source; if not, download it   ---- 
---- from http://www.opencores.org/lgpl.shtml                     ---- 
----                                                              ---- 
----------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library mod_sim_exp;
use mod_sim_exp.mod_sim_exp_pkg;

------------------------------------------------------------------------------
-- Entity section
------------------------------------------------------------------------------
-- Definition of Generics:
--   C_S_AXI_DATA_WIDTH           -- AXI4LITE slave: Data width
--   C_S_AXI_ADDR_WIDTH           -- AXI4LITE slave: Address Width
--   C_BASEADDR                   -- AXI4LITE slave: base address
--   C_HIGHADDR                   -- AXI4LITE slave: high address
--
-- Definition of Ports:
--   S_AXI_ACLK                   -- AXI4LITE slave: Clock 
--   S_AXI_ARESETN                -- AXI4LITE slave: Reset
--   S_AXI_AWADDR                 -- AXI4LITE slave: Write address
--   S_AXI_AWVALID                -- AXI4LITE slave: Write address valid
--   S_AXI_WDATA                  -- AXI4LITE slave: Write data
--   S_AXI_WSTRB                  -- AXI4LITE slave: Write strobe
--   S_AXI_WVALID                 -- AXI4LITE slave: Write data valid
--   S_AXI_BREADY                 -- AXI4LITE slave: Response ready
--   S_AXI_ARADDR                 -- AXI4LITE slave: Read address
--   S_AXI_ARVALID                -- AXI4LITE slave: Read address valid
--   S_AXI_RREADY                 -- AXI4LITE slave: Read data ready
--   S_AXI_ARREADY                -- AXI4LITE slave: read addres ready
--   S_AXI_RDATA                  -- AXI4LITE slave: Read data
--   S_AXI_RRESP                  -- AXI4LITE slave: Read data response
--   S_AXI_RVALID                 -- AXI4LITE slave: Read data valid
--   S_AXI_WREADY                 -- AXI4LITE slave: Write data ready
--   S_AXI_BRESP                  -- AXI4LITE slave: Response
--   S_AXI_BVALID                 -- AXI4LITE slave: Resonse valid
--   S_AXI_AWREADY                -- AXI4LITE slave: Wrte address ready
------------------------------------------------------------------------------

entity msec_ipcore_axilite is
  generic(
    -- Multiplier parameters
    C_NR_BITS_TOTAL   : integer := 1536;
    C_NR_STAGES_TOTAL : integer := 96;
    C_NR_STAGES_LOW   : integer := 32;
    C_SPLIT_PIPELINE  : boolean := true;
    C_FIFO_AW         : integer := 7;
    C_MEM_STYLE       : string  := "asym"; -- xil_prim, generic, asym are valid options
    C_FPGA_MAN        : string  := "xilinx";    -- xilinx, altera are valid options
    -- Bus protocol parameters
    C_S_AXI_DATA_WIDTH             : integer              := 32;
    C_S_AXI_ADDR_WIDTH             : integer              := 32;
    C_BASEADDR                     : std_logic_vector     := X"FFFFFFFF";
    C_HIGHADDR                     : std_logic_vector     := X"00000000"
  );
  port(
    --USER ports
    core_clk                      : in std_logic;
    calc_time                     : out std_logic;
    IntrEvent                     : out std_logic;
    -------------------------
    -- AXI4lite interface
    -------------------------
    --- Global signals
    S_AXI_ACLK                     : in  std_logic;
    S_AXI_ARESETN                  : in  std_logic;
    --- Write address channel
    S_AXI_AWADDR                   : in  std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
    S_AXI_AWVALID                  : in  std_logic;
    S_AXI_AWREADY                  : out std_logic;
    --- Write data channel
    S_AXI_WDATA                    : in  std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
    S_AXI_WVALID                   : in  std_logic;
    S_AXI_WREADY                   : out std_logic;
    S_AXI_WSTRB                    : in  std_logic_vector((C_S_AXI_DATA_WIDTH/8)-1 downto 0);
    --- Write response channel
    S_AXI_BVALID                   : out std_logic;
    S_AXI_BREADY                   : in  std_logic;
    S_AXI_BRESP                    : out std_logic_vector(1 downto 0);
    --- Read address channel
    S_AXI_ARADDR                   : in  std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
    S_AXI_ARVALID                  : in  std_logic;
    S_AXI_ARREADY                  : out std_logic; 
    --- Read data channel
    S_AXI_RDATA                    : out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
    S_AXI_RVALID                   : out std_logic;
    S_AXI_RREADY                   : in  std_logic;
    S_AXI_RRESP                    : out std_logic_vector(1 downto 0)
  );

  attribute MAX_FANOUT : string;
  attribute SIGIS      : string;
  attribute MAX_FANOUT of S_AXI_ACLK    : signal is "10000";
  attribute MAX_FANOUT of S_AXI_ARESETN : signal is "10000";
  attribute SIGIS of S_AXI_ACLK         : signal is "Clk";
  attribute SIGIS of S_AXI_ARESETN      : signal is "Rst";
end entity msec_ipcore_axilite;

------------------------------------------------------------------------------
-- Architecture section
------------------------------------------------------------------------------

architecture IMP of msec_ipcore_axilite is
  type axi_states is (addr_wait, read_state, write_state, response_state);
  signal state : axi_states;
  
  signal address : std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
  signal reset : std_logic;
  
  signal S_AXI_BVALID_i : std_logic;
  
  -- selection signals
  signal cs_array           : std_logic_vector(6 downto 0);
  signal slv_reg_selected : std_logic;
  signal op_mem_selected    : std_logic;
  signal op_sel             : std_logic_vector(1 downto 0);
  signal MNO_sel            : std_logic;

  -- slave register signals
  signal slv_reg : std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
  signal slv_reg_write_enable : std_logic;
  signal load_flags : std_logic;
  
  -- core interface signeals
  signal write_enable : std_logic;
  signal core_write_enable : std_logic;
  signal core_fifo_push : std_logic;
  signal core_data_out : std_logic_vector(31 downto 0);
  signal core_rw_address : std_logic_vector(8 downto 0);
  
  ------------------------------------------------------------------
  -- Signals for multiplier core interrupt
  ------------------------------------------------------------------
  signal core_interrupt                 : std_logic;
  signal core_fifo_full                 : std_logic;
  signal core_fifo_nopush               : std_logic;
  signal core_ready                     : std_logic;
  signal core_mem_collision             : std_logic;

  ------------------------------------------------------------------
  -- Signals for multiplier core control
  ------------------------------------------------------------------
  signal core_start                     : std_logic;
  signal core_start_bit                 : std_logic;
  signal core_start_bit_d               : std_logic;
  signal core_exp_m                     : std_logic;
  signal core_p_sel                     : std_logic_vector(1 downto 0);
  signal core_dest_op_single            : std_logic_vector(1 downto 0);
  signal core_x_sel_single              : std_logic_vector(1 downto 0);
  signal core_y_sel_single              : std_logic_vector(1 downto 0);
  signal core_flags                     : std_logic_vector(15 downto 0);
  signal core_modulus_sel               : std_logic;
  
begin
  -- unused signals
  S_AXI_BRESP <= "00";
  S_AXI_RRESP <= "00";
  
  -- axi-lite slave state machine
  axi_slave_states : process (S_AXI_ACLK)
  begin
    if rising_edge(S_AXI_ACLK) then
      if S_AXI_ARESETN='0' then -- slave reset state
        S_AXI_RVALID <= '0';
        S_AXI_BVALID_i <= '0';
        S_AXI_ARREADY <= '0';
        S_AXI_WREADY <= '0';
        S_AXI_AWREADY <= '0';
        state <= addr_wait;
        address <= (others=>'0');
        write_enable <= '0';
      else
        case state is
          when addr_wait => 
          -- wait for a read or write address and latch it in
            if S_AXI_ARVALID = '1' then -- read
              state <= read_state;
              address <= S_AXI_ARADDR;
              S_AXI_ARREADY <= '1';
            elsif (S_AXI_AWVALID = '1' and S_AXI_WVALID = '1') then -- write
              state <= write_state;
              address <= S_AXI_AWADDR;
            else
              state <= addr_wait;
            end if;
            
          when read_state =>
          -- place correct data on bus and generate valid pulse
            S_AXI_ARREADY <= '0';
            S_AXI_RVALID <= '1';
            state <= response_state;
            
          when write_state =>
          -- generate a write pulse
            S_AXI_AWREADY <= '1';
            write_enable <= '1';
            S_AXI_WREADY <= '1';
            state <= response_state;
            
          when response_state =>
            write_enable <= '0';
            S_AXI_AWREADY <= '0';
            S_AXI_WREADY <= '0';
            S_AXI_BVALID_i <= '1';
          -- wait for response from master
            if (S_AXI_RREADY = '1') or (S_AXI_BVALID_i = '1' and S_AXI_BREADY = '1') then
              S_AXI_RVALID <= '0';
              S_AXI_BVALID_i <= '0';
              state <= addr_wait;
            else
              state <= response_state;
            end if;
            
        end case;
      end if;
    end if;
  end process;
  S_AXI_BVALID <= S_AXI_BVALID_i;  

  -- place correct data on the read bus
  S_AXI_RDATA <=  slv_reg when (slv_reg_selected='1') else
                  core_data_out;
  
  -- SLAVE REG MAPPING
  -- core control signals
  core_p_sel <= slv_reg(31 downto 30);
  core_dest_op_single <= slv_reg(29 downto 28);
  core_x_sel_single <= slv_reg(27 downto 26);
  core_y_sel_single <= slv_reg(25 downto 24);
  core_start_bit <= slv_reg(23);
  core_exp_m <= slv_reg(22);
  core_modulus_sel <= slv_reg(21);
  reset <= (not S_AXI_ARESETN) or slv_reg(20);
  
  -- implement slave register
  SLAVE_REG_WRITE_PROC : process( S_AXI_ACLK ) is
  begin
    if rising_edge(S_AXI_ACLK) then
      if reset = '1' then
        slv_reg <= (others => '0');
      elsif load_flags = '1' then
        slv_reg <= slv_reg(31 downto 16) & core_flags;
      else
        if (slv_reg_write_enable='1') then
          slv_reg <= S_AXI_WDATA(31 downto 0);
        end if;
      end if;
    end if;
  end process SLAVE_REG_WRITE_PROC;
  
  -- create start pulse of 1 clk wide
  START_PULSE : process(S_AXI_ACLK)
  begin
    if rising_edge(S_AXI_ACLK) then
      core_start_bit_d <= core_start_bit;
    end if;
  end process;
  core_start <= core_start_bit and not core_start_bit_d;
  
  -- interrupt and flags
  core_interrupt <= core_ready or core_mem_collision or core_fifo_full or core_fifo_nopush;
  
  FLAGS_CNTRL_PROC : process(S_AXI_ACLK, reset) is
  begin
    if reset = '1' then
      core_flags <= (others => '0');
      load_flags <= '0';
    elsif rising_edge(S_AXI_ACLK) then
      if core_start = '1' then  -- flags get resetted when core starts new operation
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
      load_flags <= core_interrupt;
    end if;
  end process FLAGS_CNTRL_PROC;
  
  IntrEvent <= core_flags(15) or core_flags(14) or core_flags(13) or core_flags(12);
  
  -- adress decoder
  with address(14 downto 12) select
    cs_array <= "0000001" when "000", -- M
                "0000010" when "001", -- OP0
                "0000100" when "010", -- OP1
                "0001000" when "011", -- OP2
                "0010000" when "100", -- OP3
                "0100000" when "101", -- FIFO
                "1000000" when "110", -- user reg space
                "0000000" when others;
  
  slv_reg_selected <= cs_array(6);
  slv_reg_write_enable <= write_enable and slv_reg_selected;
  
  -- high if memory space is selected
  op_mem_selected <= cs_array(0) or cs_array(1) or cs_array(2) or cs_array(3) or cs_array(4);
  
  -- operand memory singals
  MNO_sel <= cs_array(0);
  
  with cs_array(4 downto 1) select
    op_sel <=   "00" when "0001",
                "01" when "0010",
                "10" when "0100",
                "11" when "1000",
                "00" when others;
  
  core_rw_address <= MNO_sel & op_sel & address(7 downto 2);
  
  core_write_enable <= write_enable and op_mem_selected;
  
  
  -- FIFO signals
  core_fifo_push <= write_enable and cs_array(5);
  
  ------------------------------------------
  -- Exponentiation core instance
  ------------------------------------------
  msec: entity mod_sim_exp.mod_sim_exp_core
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
    bus_clk   => S_AXI_ACLK,
    core_clk  => core_clk,
    reset     => reset,
      -- operand memory interface (plb shared memory)
    write_enable => core_write_enable,
    data_in      => S_AXI_WDATA(31 downto 0),
    rw_address   => core_rw_address,
    data_out     => core_data_out,
    collision    => core_mem_collision,
      -- op_sel fifo interface
    fifo_din    => S_AXI_WDATA(31 downto 0),
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
  
end IMP;