------------------------------------------------------------------------------
--
-- ***************************************************************************
-- ** Copyright (c) 1995-2008 Xilinx, Inc.  All rights reserved.            **
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
-- Version:           1.10.a
-- Description:       User logic.
------------------------------------------------------------------------------

-- DO NOT EDIT BELOW THIS LINE --------------------
library ieee;
use     ieee.std_logic_1164.all;
use     ieee.std_logic_arith.all;
use     ieee.std_logic_unsigned.all;

library proc_common_v2_00_a;
use     proc_common_v2_00_a.proc_common_pkg.all;


------------------------------------------------------------------------------
-- Entity section
------------------------------------------------------------------------------

entity user_logic is
  generic
  (
    -- ADD USER GENERICS BELOW THIS LINE ---------------
    C_WB_DBUS_SIZE                 : integer              := 32;
    C_WB_ACCESS_TIMEOUT            : integer              := 16;
    C_WB_RETRY_TIMEOUT             : integer              := 256;
    C_WB_ACCESS_RETRIES            : integer              := 4;
    -- ADD USER GENERICS ABOVE THIS LINE ---------------

    -- DO NOT EDIT BELOW THIS LINE ---------------------
    -- Bus protocol parameters, do not add to or delete
    C_SLV_AWIDTH                   : integer              := 32;
    C_SLV_DWIDTH                   : integer              := 32;
    C_NUM_MEM                      : integer              := 1
    -- DO NOT EDIT ABOVE THIS LINE ---------------------
  );
  port
  (
    -- ADD USER PORTS BELOW THIS LINE ------------------
    WB_CLK_O                       : out std_logic;
    WB_RST_O                       : out std_logic;
    WB_ADR_O                       : out std_logic_vector(0 to 31);
    WB_DAT_O                       : out std_logic_vector(0 to C_WB_DBUS_SIZE-1);
    WB_SEL_O                       : out std_logic_vector(0 to (C_WB_DBUS_SIZE/8)-1);
    WB_CYC_O                       : out std_logic;
    WB_STB_O                       : out std_logic;
    WB_WE_O                        : out std_logic;
    WB_DAT_I                       : in  std_logic_vector(0 to C_WB_DBUS_SIZE-1);
    WB_ACK_I                       : in  std_logic;
    WB_ERR_I                       : in  std_logic;
    WB_RTY_I                       : in  std_logic;
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

  -- State Machine Declarations
  type state_type is (ST_IDLE, ST_ACCESS, ST_RETRY_STROBE, ST_RETRY, ST_ERROR, ST_DONE);
  signal curr_st        : state_type;
  signal next_st        : state_type;
  -- Bus Ack Decode
  signal wb_rdack       : std_logic;
  signal wb_wrack       : std_logic;
  -- Timer used to track bus error condition and retry timouts.
  signal timer_en       : std_logic;
  signal timer_cnt      : std_logic_vector(0 to 7);
  -- Counter used to track number of retry attempts
  signal retry_iter     : std_logic_vector(0 to 1);
  signal retry_iter_rst : std_logic;
  signal retry_iter_en  : std_logic;
  -- Status Signals
  signal retry_expire   : std_logic;  -- Maximum Retries exceeded
  signal access_to      : std_logic;  -- Bus Error Detected
  signal retry_to       : std_logic;  -- Retry cycle completed

begin

  --
  -- We are not buffering these signals to the WB Bus.
  -- Nor are we running the clock at a slower rate than the PLB Bus.
  WB_CLK_O  <= Bus2IP_Clk;
  WB_RST_O  <= Bus2IP_Reset;

  -- These can probably be treated as multi-cycle paths
  -- Possibly will add in a Pipeline stage (user selectable?)
  WB_ADR_O  <= Bus2IP_Addr;
  WB_DAT_O  <= Bus2IP_Data;
  WB_SEL_O  <= Bus2IP_BE;
  WB_WE_O   <= not Bus2IP_RNW;

  --
  -- Number of retry attempts
  --
  process(Bus2IP_Clk) begin
  	if (rising_edge(Bus2IP_Clk)) then
  		if (retry_iter_rst = '1') then
  			retry_iter <= (others=>'0');
  		elsif (retry_iter_en = '1') then
  			retry_iter <= retry_iter + 1;
  		end if;

  		retry_expire <= '0';
  		if (retry_iter = conv_std_logic_vector(C_WB_ACCESS_RETRIES-1,2)) then
  			retry_expire <= '1';
  		end if;
  	end if;
  end process;

  --
  -- Retry Wait Counter
  --
  process(Bus2IP_Clk) begin
  	if (rising_edge(Bus2IP_Clk)) then
  		if (timer_en = '0') then
  			timer_cnt <= (others => '0');
  		else
  			timer_cnt <= timer_cnt + 1;
  		end if;

  		retry_to <= '0';
  		if (timer_cnt = conv_std_logic_vector(C_WB_RETRY_TIMEOUT-1, 8)) then
  			retry_to <= '1';
  		end if;

  		if (timer_cnt = conv_std_logic_vector(C_WB_ACCESS_TIMEOUT-1, 8)) then
  			access_to <= '1';
  		end if;

  	end if;
  end process;

  --
  --
  -- WB Bridge State Machine (Next State Logic)
  --
  --

  IP2Bus_RdAck <= wb_rdack;
  IP2Bus_WrAck <= wb_wrack;

  process(curr_st, Bus2IP_CS ,WB_RTY_I ,WB_ACK_I, retry_to, access_to) begin

  	next_st <= curr_st;
  	timer_en <= '0';
  	retry_iter_rst <= '0';
  	retry_iter_en <= '0';
 		WB_STB_O <= '0';
 		WB_CYC_O <= '0';
 		wb_rdack <= '0';
 		wb_wrack <= '0';
 		IP2Bus_Error <= '0';

  	case (curr_st) is


  		when ST_IDLE =>
  			retry_iter_rst <= '1';
  			if (Bus2IP_CS(0) = '1') then
  				next_st <= ST_ACCESS;
  			end if;

  		-- Access State
  		-- Completes when we receive either a RETRY, ACK or we timeout of the transaction.
  		-- Transaction timeout is setup by the user.
  		when ST_ACCESS =>
  			WB_STB_O <= '1';
  			WB_CYC_O <= '1';
  			timer_en <= '1';
        if (WB_RTY_I = '1') then
        	next_st <= ST_RETRY_STROBE;
        elsif (WB_ACK_I = '1') then
        	next_st <= ST_DONE;
        elsif (access_to = '1') then
        	next_st <= ST_ERROR;
        end if;

  	  -- Retry Strobe
  	  -- Simply used to reset timer and increment our retries.
  	  -- We will also check to see if we have reached out limit of retries.
  	  when ST_RETRY_STROBE =>
  	  	retry_iter_en <= '1';
  	  	if (retry_expire = '1') then
  	  		next_st <= ST_ERROR;
  	  	else
  	  	  next_st <= ST_RETRY;
  	  	end if;

  	  -- Retry
  	  -- Sit here and wait until we issues a WB Retry
  	  when ST_RETRY =>
  	  	timer_en <= '1';
  	    if (retry_to = '1') then
  	    	next_st <= ST_ACCESS;
  	    end if;

      -- Error
      -- Issue PLB Error
      when ST_ERROR =>
      	IP2Bus_Error <= '1';
      	wb_wrack <= not Bus2IP_RNW;
      	wb_rdack <= Bus2IP_RNW;
    		next_st <= ST_IDLE;

  	  when ST_DONE =>
  	  	wb_rdack <= Bus2IP_RNW;
  	  	wb_wrack <= not Bus2IP_RNW;
  	  	next_st <= ST_IDLE;


  	end case;

  end process;

  --
  --
  -- WB Bridge State Machine (Current State Logic)
  --
  --
  process(Bus2IP_Clk) begin
  	if (rising_edge(Bus2IP_Clk)) then
  		if (Bus2IP_Reset = '1') then
  			curr_st <= ST_IDLE;
  		else
  			curr_st <= next_st;
  		end if;
  	end if;
  end process;

  ------------------------------------------
  -- Example code to drive IP to Bus signals
  ------------------------------------------
  IP2Bus_Data  <= WB_DAT_I when wb_rdack = '1' else
                  (others => '0');

end IMP;
