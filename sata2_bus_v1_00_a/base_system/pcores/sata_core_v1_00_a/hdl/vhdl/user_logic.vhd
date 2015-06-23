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
-- Version:           1.00.a
-- Description:       User logic.
-- Date:              Fri Jun 17 14:13:01 2011 (by Create and Import Peripheral Wizard)
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
--   C_SLV_DWIDTH                 -- Slave interface data bus width
--   C_NUM_REG                    -- Number of software accessible registers
--
-- Definition of Ports:
--   Bus2IP_Clk                   -- Bus to IP clock
--   Bus2IP_Reset                 -- Bus to IP reset
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
    --USER generics added here
    CHIPSCOPE                      : boolean := false;
    DATA_WIDTH                     : natural := 32;
    -- ADD USER GENERICS ABOVE THIS LINE ---------------

    -- DO NOT EDIT BELOW THIS LINE ---------------------
    -- Bus protocol parameters, do not add to or delete
    C_SLV_DWIDTH                   : integer := 32;
    C_NUM_REG                      : integer := 8
    -- DO NOT EDIT ABOVE THIS LINE ---------------------
  );
  port
  (
    -- ADD USER PORTS BELOW THIS LINE ------------------
    user_logic_ila_control     : in std_logic_vector (35 downto 0);
    cmd_layer_ila_control      : in std_logic_vector (35 downto 0);
    sata_rx_frame_ila_control  : in std_logic_vector (35 downto 0);
    sata_tx_frame_ila_control  : in std_logic_vector (35 downto 0);
    sata_phy_ila_control       : in std_logic_vector (35 downto 0);
    oob_control_ila_control    : in std_logic_vector (35 downto 0);
    scrambler_ila_control      : in std_logic_vector (35 downto 0);
    descrambler_ila_control    : in std_logic_vector (35 downto 0);
    -----------------------------------------------------
    --TILE0_REFCLK_PAD_P_IN : in std_logic;     -- MGTCLKA,  clocks GTP_X0Y0-2 
    --TILE0_REFCLK_PAD_N_IN : in std_logic;     -- MGTCLKA 
    TXP0_OUT              : out std_logic;
    TXN0_OUT              : out std_logic;
    RXP0_IN               : in std_logic;
    RXN0_IN               : in std_logic;		
    TILE0_PLLLKDET_OUT_N  : out std_logic;
    DCMLOCKED_OUT         : out std_logic;
    LINKUP_led            : out std_logic;
    GEN2_led              : out std_logic;
    RESET                 : in std_logic; 
    --GTX_RESET_IN          : in std_logic; 
    --new_cmd_in            : in std_logic; 
    CLKIN_150             : in std_logic;
    SATA_CORE_DOUT        : out std_logic_vector(0 to 31);
    SATA_CORE_DOUT_WE     : out std_logic; 
    SATA_CORE_CLK_OUT     : out std_logic; 
    SATA_CORE_DIN         : in std_logic_vector(0 to 31);
    SATA_CORE_DIN_WE      : in std_logic; 
    SATA_CORE_FULL        : out std_logic; 
    NPI_CORE_REQ_TYPE     : out std_logic_vector (0 to 1);
    NPI_CORE_NEW_CMD      : out std_logic;  
    NPI_CORE_NUM_RD_BYTES : out std_logic_vector (0 to 31);  
    NPI_CORE_NUM_WR_BYTES : out std_logic_vector (0 to 31); 
    NPI_CORE_INIT_WR_ADDR : out std_logic_vector (0 to 31);  
    NPI_CORE_INIT_RD_ADDR : out std_logic_vector (0 to 31);  
    NPI_CORE_READY_FOR_CMD: in std_logic; 

    --USER ports added here
    -- ADD USER PORTS ABOVE THIS LINE ------------------

    -- DO NOT EDIT BELOW THIS LINE ---------------------
    -- Bus protocol ports, do not add to or delete
    Bus2IP_Clk                     : in  std_logic;
    Bus2IP_Reset                   : in  std_logic;
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

  ------------------------------------------
  -- Signals for user logic slave model s/w accessible register example
  ------------------------------------------
  signal ctrl_reg                       : std_logic_vector(0 to C_SLV_DWIDTH-1);
  signal cmd_reg                        : std_logic_vector(0 to C_SLV_DWIDTH-1);
  signal status_reg                     : std_logic_vector(0 to C_SLV_DWIDTH-1);
  signal sector_addr_reg                : std_logic_vector(0 to C_SLV_DWIDTH-1);
  signal sector_count_reg               : std_logic_vector(0 to C_SLV_DWIDTH-1);
  signal sector_timer_reg               : std_logic_vector(0 to C_SLV_DWIDTH-1);
  signal npi_rd_addr_reg                : std_logic_vector(0 to C_SLV_DWIDTH-1);
  signal npi_wr_addr_reg                : std_logic_vector(0 to C_SLV_DWIDTH-1);
  signal slv_reg_write_sel              : std_logic_vector(0 to 7);
  signal slv_reg_read_sel               : std_logic_vector(0 to 7);
  signal slv_ip2bus_data                : std_logic_vector(0 to C_SLV_DWIDTH-1);
  signal slv_read_ack                   : std_logic;
  signal slv_write_ack                  : std_logic;
  
  constant SECTOR_NDWORDS               : integer := 128;  -- 128 DWORDS / 512 Byte Sector    
  constant READ_DMA_CMD                 : std_logic_vector(1 downto 0) := "01";
  constant WRITE_DMA_CMD                : std_logic_vector(1 downto 0) := "10";
  constant NPI_READ_REQ     : std_logic_vector(1 downto 0) := "01";
  constant NPI_WRITE_REQ     : std_logic_vector(1 downto 0) := "10";
  constant BYTES_PER_SECTOR : integer := 512;      

  signal sw_reset                       : std_logic;
  signal sata_phy_clk                   : std_logic;
  signal GTXRESET                       : std_logic;		
  signal LINKUP_led_i                   : std_logic; 

  signal new_cmd_in                     : std_logic;
  signal new_cmd                        : std_logic;
  signal cmd_started                    : std_logic;
  signal cmd_type                       : std_logic_vector(1 downto 0); 
  signal ready_for_cmd                  : std_logic;
  signal sata_dout                      : std_logic_vector(31 downto 0); 
  signal sata_dout_re                   : std_logic; 
  signal sector_count_int               : integer; 
  signal sector_count                   : std_logic_vector(31 downto 0); 
  signal sector_addr                    : std_logic_vector(31 downto 0); 
  signal read_fifo_empty                : std_logic;
  signal sata_core_full_i               : std_logic;
  signal sata_user_data_clk_in_i        : std_logic;

  -- NPI 
  signal  npi_ready_for_cmd      : std_logic;     
  signal  npi_new_cmd            : std_logic;     
  signal  npi_req_type           : std_logic_vector(1 downto 0); 
  signal  npi_num_rd_bytes       : std_logic_vector(31 downto 0);  
  signal  npi_init_rd_addr       : std_logic_vector(31 downto 0); 
  signal  npi_num_wr_bytes       : std_logic_vector(31 downto 0);  
  signal  npi_init_wr_addr       : std_logic_vector(31 downto 0);
  signal  npi_new_cmd_next       : std_logic;     
  signal  npi_req_type_next      : std_logic_vector(1 downto 0); 
  signal  npi_num_rd_bytes_next  : std_logic_vector(31 downto 0);  
  signal  npi_init_rd_addr_next  : std_logic_vector(31 downto 0); 
  signal  npi_num_wr_bytes_next  : std_logic_vector(31 downto 0);  
  signal  npi_init_wr_addr_next  : std_logic_vector(31 downto 0);

 -----------------------------------------------------------------------------
  -- TestBench FSM Declaration (curr and next states)
 -----------------------------------------------------------------------------
  type TEST_FSM_TYPE is (wait_for_cmd, wait_for_ready_low, wait_for_ack,
                         dead 
                         );
  signal test_fsm_curr, test_fsm_next : TEST_FSM_TYPE := wait_for_cmd; 
  signal test_fsm_value               : std_logic_vector (0 to 3);

  -- USER FIFO DECLARATION
  component user_fifo
	port (
	wr_clk: IN std_logic;
	rd_clk: IN std_logic;
	rst: IN std_logic;
	din: IN std_logic_VECTOR(31 downto 0);
	wr_en: IN std_logic;
	rd_en: IN std_logic;
	dout: OUT std_logic_VECTOR(31 downto 0);
	full: OUT std_logic;
	prog_full: OUT std_logic;
	empty: OUT std_logic);
  end component;

  component user_logic_ila
    port (
      control : in std_logic_vector(35 downto 0);
      clk     : in std_logic;
      trig0   : in std_logic_vector(3  downto 0);
      trig1   : in std_logic_vector(31 downto 0);
      trig2   : in std_logic_vector(31 downto 0);
      trig3   : in std_logic_vector(31 downto 0);
      trig4   : in std_logic_vector(31 downto 0);
      trig5   : in std_logic_vector(7 downto 0)
   );
  end component;



begin

  --USER logic implementation added here

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
  slv_reg_write_sel <= Bus2IP_WrCE(0 to 7);
  slv_reg_read_sel  <= Bus2IP_RdCE(0 to 7);
  slv_write_ack     <= Bus2IP_WrCE(0) or Bus2IP_WrCE(1) or Bus2IP_WrCE(2) or Bus2IP_WrCE(3) or Bus2IP_WrCE(4) or Bus2IP_WrCE(5)  or Bus2IP_WrCE(6) or Bus2IP_WrCE(7);
  slv_read_ack      <= Bus2IP_RdCE(0) or Bus2IP_RdCE(1) or Bus2IP_RdCE(2) or Bus2IP_RdCE(3) or Bus2IP_RdCE(4) or Bus2IP_RdCE(5)  or Bus2IP_RdCE(6) or Bus2IP_RdCE(7);

  -- implement slave model software accessible register(s)
  SLAVE_REG_WRITE_PROC : process( Bus2IP_Clk ) is
  begin
    if Bus2IP_Clk'event and Bus2IP_Clk = '1' then
      if Bus2IP_Reset = '1' then
        ctrl_reg <= (others => '0');
        cmd_reg <= (others => '0');
        sector_addr_reg  <= (others => '0');
        sector_count_reg <= (others => '0');
        npi_rd_addr_reg  <= (others => '0');
        npi_wr_addr_reg  <= (others => '0');
      else
        case slv_reg_write_sel is
          when "10000000" =>
            for byte_index in 0 to (C_SLV_DWIDTH/8)-1 loop
              if ( Bus2IP_BE(byte_index) = '1' ) then
                ctrl_reg(byte_index*8 to byte_index*8+7) <= Bus2IP_Data(byte_index*8 to byte_index*8+7);
              end if;
            end loop;
          when "01000000" =>
            for byte_index in 0 to (C_SLV_DWIDTH/8)-1 loop
              if ( Bus2IP_BE(byte_index) = '1' ) then
                cmd_reg(byte_index*8 to byte_index*8+7) <= Bus2IP_Data(byte_index*8 to byte_index*8+7);
              end if;
            end loop;
         when "00010000" =>
            for byte_index in 0 to (C_SLV_DWIDTH/8)-1 loop
              if ( Bus2IP_BE(byte_index) = '1' ) then
                sector_addr_reg(byte_index*8 to byte_index*8+7) <= Bus2IP_Data(byte_index*8 to byte_index*8+7);
              end if;
            end loop;
          when "00001000" =>
            for byte_index in 0 to (C_SLV_DWIDTH/8)-1 loop
              if ( Bus2IP_BE(byte_index) = '1' ) then
                sector_count_reg(byte_index*8 to byte_index*8+7) <= Bus2IP_Data(byte_index*8 to byte_index*8+7);
              end if;
            end loop;
          when "00000010" =>
            for byte_index in 0 to (C_SLV_DWIDTH/8)-1 loop
              if ( Bus2IP_BE(byte_index) = '1' ) then
                npi_rd_addr_reg(byte_index*8 to byte_index*8+7) <= Bus2IP_Data(byte_index*8 to byte_index*8+7);
              end if;
            end loop;
          when "00000001" =>
            for byte_index in 0 to (C_SLV_DWIDTH/8)-1 loop
              if ( Bus2IP_BE(byte_index) = '1' ) then
                npi_wr_addr_reg(byte_index*8 to byte_index*8+7) <= Bus2IP_Data(byte_index*8 to byte_index*8+7);
              end if;
            end loop;
          when others => null;
        end case;
      end if;
    end if;
  end process SLAVE_REG_WRITE_PROC;

  -- implement slave model software accessible register(s) read mux
  SLAVE_REG_READ_PROC : process(slv_reg_read_sel, ctrl_reg, cmd_reg, status_reg, sector_addr_reg, 
                                 sector_count_reg, sector_timer_reg, npi_rd_addr_reg, npi_wr_addr_reg) is
  begin

    case slv_reg_read_sel is
      when "10000000" => slv_ip2bus_data <= ctrl_reg;
      when "01000000" => slv_ip2bus_data <= cmd_reg;
      when "00100000" => slv_ip2bus_data <= status_reg;
      when "00010000" => slv_ip2bus_data <= sector_addr_reg;
      when "00001000" => slv_ip2bus_data <= sector_count_reg;
      when "00000100" => slv_ip2bus_data <= sector_timer_reg;
      when "00000010" => slv_ip2bus_data <= npi_rd_addr_reg;
      when "00000001" => slv_ip2bus_data <= npi_wr_addr_reg;
      when others => slv_ip2bus_data <= (others => '0');
    end case;

  end process SLAVE_REG_READ_PROC;



  ------------------------------------------
  -- Example code to drive IP to Bus signals
  ------------------------------------------
  IP2Bus_Data  <= slv_ip2bus_data when slv_read_ack = '1' else
                  (others => '0');

  IP2Bus_WrAck <= slv_write_ack;
  IP2Bus_RdAck <= slv_read_ack;
  IP2Bus_Error <= '0';

  -------------------------------------------
  -- SATA --
  -------------------------------------------
  sw_reset      <=  ctrl_reg(31); -- Software Reset
  -- Testbench Signals
  new_cmd_in    <=  ctrl_reg(30);
  cmd_type      <=  cmd_reg(30 to 31);
  sector_addr   <=  sector_addr_reg;
  sector_count_int  <=  conv_integer(sector_count_reg);
  sector_count  <=  sector_count_reg;
  status_reg(31) <= ready_for_cmd; 
  status_reg(30) <= LINKUP_led_i; 
  status_reg(29) <= npi_ready_for_cmd; 
  sata_dout_re  <=  '1' when (read_fifo_empty = '0') else '0'; 

  -- De-Assert new_cmd after 1 clk cycle
  REG_PROC: process (sata_phy_clk)
  begin
    if ((sata_phy_clk'event) and (sata_phy_clk = '1')) then
      if (GTXRESET = '1') then
         new_cmd      <= '0';
         cmd_started  <= '0';
      elsif(new_cmd_in = '0') then
         cmd_started  <= '0';
      elsif (new_cmd_in = '1' and cmd_started = '0') then
         new_cmd      <= '1';
         cmd_started  <= '1';
      elsif (cmd_started = '1') then
         new_cmd      <= '0';
      end if;
    end if; 
  end process REG_PROC;
 
 -----------------------------------------------------------------------------
  -- PROCESS: TEST_FSM_VALUE_PROC
  -- PURPOSE: ChipScope State Indicator Signal
  -----------------------------------------------------------------------------
  TEST_FSM_VALUE_PROC : process (test_fsm_curr) is
  begin
    case (test_fsm_curr) is
      when wait_for_cmd       => test_fsm_value <= x"0";
      when wait_for_ready_low => test_fsm_value <= x"1";
      when wait_for_ack       => test_fsm_value <= x"2";
      when dead               => test_fsm_value <= x"3";
      when others             => test_fsm_value <= x"4";
    end case;
  end process TEST_FSM_VALUE_PROC;

  -----------------------------------------------------------------------------
  -- PROCESS: TEST_FSM_STATE_PROC
  -- PURPOSE: Registering Signals and Next State
  -----------------------------------------------------------------------------
  TEST_FSM_STATE_PROC: process (sata_phy_clk)
  begin
    if ((sata_phy_clk'event) and (sata_phy_clk = '1')) then
      if (GTXRESET = '1') then
        --Initializing internal signals
       npi_new_cmd            <= '0';     
       npi_req_type           <= (others => '0'); 
       npi_num_rd_bytes       <= (others => '0');  
       npi_init_rd_addr       <= (others => '0'); 
       npi_num_wr_bytes       <= (others => '0');  
       npi_init_wr_addr       <= (others => '0');
       npi_ready_for_cmd      <= '0'; 
       test_fsm_curr          <= wait_for_cmd;
      else
        -- Register all Current Signals to their _next Signals
        npi_new_cmd            <= npi_new_cmd_next;     
        npi_req_type           <= npi_req_type_next; 
        npi_num_rd_bytes       <= npi_num_rd_bytes_next;  
        npi_init_rd_addr       <= npi_init_rd_addr_next; 
        npi_num_wr_bytes       <= npi_num_wr_bytes_next;  
        npi_init_wr_addr       <= npi_init_wr_addr_next;
        npi_ready_for_cmd      <= NPI_CORE_READY_FOR_CMD; 
        test_fsm_curr          <= test_fsm_next;
      end if;
    end if;
  end process TEST_FSM_STATE_PROC;

   -----------------------------------------------------------------------------
  -- PROCESS: TEST_FSM_LOGIC_PROC 
  -- PURPOSE: Registering Signals and Next State
  -----------------------------------------------------------------------------
  TEST_FSM_LOGIC_PROC : process (test_fsm_curr, new_cmd 
                                   ) is
  begin
    -- Register _next to current signals
    test_fsm_next          <= test_fsm_curr;
    npi_new_cmd_next       <= npi_new_cmd;     
    npi_req_type_next      <= npi_req_type; 
    npi_num_rd_bytes_next  <= npi_num_rd_bytes;  
    npi_init_rd_addr_next  <= npi_init_rd_addr; 
    npi_num_wr_bytes_next  <= npi_num_wr_bytes;  
    npi_init_wr_addr_next  <= npi_init_wr_addr;

    ---------------------------------------------------------------------------
    -- Finite State Machine
    ---------------------------------------------------------------------------
    case (test_fsm_curr) is

     -- x0
     when wait_for_cmd =>   
         if (new_cmd = '1') then
            test_fsm_next  <= wait_for_ready_low;
         end if;

     -- x1
     when wait_for_ready_low => 
         if (ready_for_cmd = '0') then
           if (cmd_type = WRITE_DMA_CMD) then
              npi_req_type_next <= NPI_READ_REQ;
              npi_num_rd_bytes_next  <= conv_std_logic_vector((sector_count_int * BYTES_PER_SECTOR), 32);  
              npi_init_rd_addr_next  <= npi_rd_addr_reg; 
           else
              npi_req_type_next <= NPI_WRITE_REQ; 
              npi_num_wr_bytes_next  <= conv_std_logic_vector((sector_count_int * BYTES_PER_SECTOR), 32);  
              npi_init_wr_addr_next  <= npi_wr_addr_reg;
           end if;
           if (npi_ready_for_cmd = '1') then
              npi_new_cmd_next <= '1';     
           end if;
           test_fsm_next  <= wait_for_ack;
         end if;

     -- x2
     when wait_for_ack => 
         if (ready_for_cmd = '1') then
            npi_new_cmd_next <= '0';         
            test_fsm_next  <= wait_for_cmd;
         end if;
 
     -- x3
     when dead =>   
         test_fsm_next  <= dead;

     -- x4
     when others =>   
         test_fsm_next  <= dead;

   end case;
 end process TEST_FSM_LOGIC_PROC;

 NPI_CORE_REQ_TYPE     <= npi_req_type;
 NPI_CORE_NEW_CMD      <= npi_new_cmd;  
 NPI_CORE_NUM_RD_BYTES <= npi_num_rd_bytes;  
 NPI_CORE_NUM_WR_BYTES <= npi_num_wr_bytes; 
 NPI_CORE_INIT_WR_ADDR <= npi_init_wr_addr;  
 NPI_CORE_INIT_RD_ADDR <= npi_init_rd_addr;  

  -------------------------------------------
  -- Sata Command Layer Module Instance
  ------------------------------------------
  -- Output to NPI 
  SATA_CORE_DOUT     <= sata_dout;
  SATA_CORE_DOUT_WE  <= sata_dout_re; 
  SATA_CORE_CLK_OUT  <= sata_phy_clk; 
  SATA_CORE_FULL     <= sata_core_full_i; 
  -- Output to NPI
  
  ------------------------------------------
  -- Sata Link Layer Module Instance
  ------------------------------------------
  --GTXRESET   <=   GTX_RESET_IN or RESET;
  GTXRESET          <=   sw_reset or RESET;
  LINKUP_led        <=   LINKUP_led_i;

  SATA_CORE_TOP_i: entity work.sata_core_top 
  generic map (
    CHIPSCOPE           => CHIPSCOPE, 
    DATA_WIDTH          => DATA_WIDTH          
       )
  port map(
   -- Clock and Reset Signals
    CLKIN_150            => CLKIN_150 , --GTX Ref Clk 
    reset                => GTXRESET,
    -- ChipScope ILA / Trigger Signals
    cmd_layer_ila_control      => cmd_layer_ila_control,
    sata_rx_frame_ila_control  => sata_rx_frame_ila_control  ,
    sata_tx_frame_ila_control  => sata_tx_frame_ila_control  ,
    oob_control_ila_control    => oob_control_ila_control,
    sata_phy_ila_control       => sata_phy_ila_control,
    scrambler_ila_control      => scrambler_ila_control,
    descrambler_ila_control    => descrambler_ila_control,
    ---------------------------------------
    -- SATA Interface -----
      -- Command, Control and Status --
    ready_for_cmd        => ready_for_cmd, 
    new_cmd              => new_cmd,
    cmd_type	         => cmd_type,
    sector_count         => sector_count,
    sector_addr          => sector_addr,
      -- Data and User Clock --
    sata_din             =>  SATA_CORE_DIN, 
    sata_din_we          =>  SATA_CORE_DIN_WE,
    sata_core_full       =>  sata_core_full_i,
    sata_dout            =>  sata_dout,
    sata_dout_re         =>  sata_dout_re,
    sata_core_empty      =>  read_fifo_empty,
    SATA_USER_DATA_CLK_IN  => sata_user_data_clk_in_i,
    SATA_USER_DATA_CLK_OUT => sata_phy_clk,

    -- Timer --
    sata_timer            => sector_timer_reg,
    -- Sata Phy Signals
    --REFCLK_PAD_P_IN       => TILE0_REFCLK_PAD_P_IN,     
    --REFCLK_PAD_N_IN       => TILE0_REFCLK_PAD_N_IN,  
    TXP0_OUT              => TXP0_OUT,
    TXN0_OUT              => TXN0_OUT,
    RXP0_IN               => RXP0_IN,
    RXN0_IN               => RXN0_IN,		
    PLLLKDET_OUT_N        => TILE0_PLLLKDET_OUT_N,     
    DCMLOCKED_OUT         => DCMLOCKED_OUT,
    LINKUP                => LINKUP_led_i
);


  USER_LOGIC_ILA_i : user_logic_ila
    port map (
      control  => user_logic_ila_control,
      clk      => sata_phy_clk,
      trig0    => test_fsm_value,
      trig1    => SATA_CORE_DIN,
      trig2    => (others => '0'),
      trig3    => (others => '0'),
      trig4    => (others => '0'),
      trig5(0) => new_cmd,
      trig5(1) => SATA_CORE_DIN_WE,
      trig5(2) => sata_core_full_i,
      trig5(3) => ready_for_cmd,
      trig5(4) => new_cmd,
      trig5(5) => npi_ready_for_cmd, 
      trig5(6) => npi_new_cmd,
      trig5(7) => sata_dout_re 
     ); 

end IMP;
