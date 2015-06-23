----------------------------------------------------------------------------------
-- Company: OPL Aerospatiale AG
-- Engineer: Owen Lynn <lynn0p@hotmail.com>
-- 
-- Create Date:    14:25:41 08/20/2009 
-- Design Name:    DDR SDRAM Controller
-- Module Name:    sdram_controller - impl 
-- Project Name: 
-- Target Devices: Spartan3e Starter Board
-- Tool versions:  ISE 11.2
-- Description: This is the main controller module. This is where the signals 
--  to/from the DDR SDRAM chip happen.
--  
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--  Copyright (c) 2009 Owen Lynn <lynn0p@hotmail.com>
--  Released under the GNU Lesser General Public License, Version 3
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

-- This is not meant to be a high performance controller. No fancy command
--  scheduling, does the bare minimum to work without screwing up timing.
-- Do NOT put this controller in something mission critical! This is the creation
--  of a guy in his bedroom, learning digital circuits.
-- Intended to be used exclusively with the Spartan3e Starter Board and targets
--  the mt46v32m16 chip. Dunno if it will work anywhere else.
-- Uses the ODDR2 and DCM Xilinx primitives, for other FPGAs, you'll need to
--  patch in equivalents. See sdram_support for the details.
-- I'd strongly recommend running it through a post-PAR simulation if you're
--  porting to any other FPGA, as the timings will probably change on you.
-- Consumes one DCM, needs a 100mhz clock or an external DCM to supply it.
-- Has an 8bit wide datapath, moderate changes could support 16bits, 32 bits
--  you'll have to work some. You want more than that, you'll be doing brain
--  surgery on the FSMs - good luck.

-- This design has now been tested with a t80 soft cpu, however, it hasn't been
--  exhaustively tested with the rest of the system. Glitches may still exist.
-- Did I mention that you shouldn't put this in anything mission critical? 

-- Be careful with the synthesizer settings too. Do not let the FSM extractor
--  choose something other than one-hot. Be careful with equivalent register
--  removal. I've rolled all synthesizer settings back to default and things
--  seem to be OK, but pay attention to the synthesizer reports!

-- TODO: implement reset signal
entity sdram_controller is
	port(	   -- user facing signals 
	         clk100mhz : in  std_logic;
	             reset : in  std_logic;
	                op : in  std_logic_vector(1 downto 0);        -- 00/11: NOP, 01: READ, 10: write
	              addr : in  std_logic_vector(25 downto 0);       -- address to read/write 
	            op_ack : out std_logic;                           -- op, addr and data_i should be captured when this goes high
	            busy_n : out std_logic;                           -- busy when LOW, ops will be ignored until busy goes high again
	            data_o : out std_logic_vector(7 downto 0);        -- data from read shows up here
	            data_i : in  std_logic_vector(7 downto 0);        -- data to write needs to be here
	             
	        -- SDRAM facing signals 
			  dram_clkp : out   std_logic;                         -- 0 deg phase 100mhz clock going out to SDRAM chip
			  dram_clkn : out   std_logic;                         -- 180 deg phase version of dram_clkp
	        dram_clke : out   std_logic;                         -- clock enable, owned by the init module
			    dram_cs : out   std_logic;                         -- tied low upon powerup
	         dram_cmd : out   std_logic_vector(2 downto 0);      -- this is the command vector <we_n,cas_n,ras_n>
           dram_bank : out   std_logic_vector(1 downto 0);      -- bank address
			  dram_addr : out   std_logic_vector(12 downto 0);     -- row/col/mode register
			    dram_dm : out   std_logic_vector(1 downto 0);      -- masks used for writing
			   dram_dqs : inout std_logic_vector(1 downto 0);      -- strobes used for writing
			    dram_dq : inout std_logic_vector(15 downto 0);     -- data lines

			  -- debug signals (possibly could be repurposed later for wider data)
			  debug_reg : out   std_logic_vector(7 downto 0)
				 );
end sdram_controller;

architecture impl of sdram_controller is

	-- component decls begin here
	component sdram_dcm is
		port(
			reset      : in  std_logic;
			clk100mhz  : in  std_logic;
			locked     : out std_logic;
			dram_clkp  : out std_logic;
			dram_clkn  : out std_logic;
			clk_000    : out std_logic;
			clk_090    : out std_logic;
			clk_180    : out std_logic;
			clk_270    : out std_logic
		);
	end component;
  
	component oddr2_2 is
		port( 
			Q  : out std_logic_vector(1 downto 0);
			C0 : in  std_logic;
			C1 : in  std_logic;
			CE : in  std_logic;
			D0 : in  std_logic_vector(1 downto 0);
			D1 : in  std_logic_vector(1 downto 0);
			R  : in  std_logic;
			S  : in  std_logic );
	end component;

	component oddr2_3 is
		port( 
			Q  : out std_logic_vector(2 downto 0);
			C0 : in  std_logic;
			C1 : in  std_logic;
			CE : in  std_logic;
			D0 : in  std_logic_vector(2 downto 0);
			D1 : in  std_logic_vector(2 downto 0);
			R  : in  std_logic;
			S  : in  std_logic );
	end component;

	component oddr2_13 is
		port( 
			Q  : out std_logic_vector(12 downto 0);
			C0 : in  std_logic;
			C1 : in  std_logic;
			CE : in  std_logic;
			D0 : in  std_logic_vector(12 downto 0);
			D1 : in  std_logic_vector(12 downto 0);
			R  : in  std_logic;
			S  : in  std_logic );
	end component;
  
	component inout_switch_2 is
		port (
			ioport : inout std_logic_vector(1 downto 0);
				dir : in    std_logic;
			data_i : in    std_logic_vector(1 downto 0)
		);
	end component;

	component inout_switch_16 is
		port (
			ioport : inout std_logic_vector(15 downto 0);
				dir : in    std_logic;
			data_o : out   std_logic_vector(15 downto 0);
			data_i : in    std_logic_vector(15 downto 0)
		);
	end component;
	
	component sdram_reader is
		port(
			clk270 : in  std_logic;
			rst    : in  std_logic;
			dq     : in  std_logic_vector(15 downto 0);
			data0  : out std_logic_vector(7 downto 0);
			data1  : out std_logic_vector(7 downto 0)
		);
	end component;

	component sdram_writer is
		port(
			clk    : in  std_logic;
			clk090 : in  std_logic;
			clk180 : in  std_logic;
			clk270 : in  std_logic;
			rst    : in  std_logic;
			addr   : in  std_logic;
			data_o : in  std_logic_vector(7 downto 0);
			dqs    : out std_logic_vector(1 downto 0);
			dm     : out std_logic_vector(1 downto 0);
			dq     : out std_logic_vector(15 downto 0)
		);
	end component;

	component wait_counter is
		generic(
			BITS : integer;
			CLKS : integer
		);
		port(
			 clk : in std_logic;
			 rst : in std_logic;
			done : out std_logic
		);
	end component;
	
	component sdram_init
		port(
			clk_000 : in std_logic;
			reset   : in std_logic;
			
			clke  : out std_logic;
			cmd   : out std_logic_vector(2 downto 0);
			bank  : out std_logic_vector(1 downto 0);
			addr  : out std_logic_vector(12 downto 0);
			done  : out std_logic
		);
	end component;

	component cmd_bank_addr_switch is
		port(
			sel      : in std_logic;
			cmd0_in  : in std_logic_vector(2 downto 0);
			bank0_in : in std_logic_vector(1 downto 0);
			addr0_in : in std_logic_vector(12 downto 0);
			cmd1_in  : in std_logic_vector(2 downto 0);
			bank1_in : in std_logic_vector(1 downto 0);
			addr1_in : in std_logic_vector(12 downto 0);
			cmd_out  : out std_logic_vector(2 downto 0);
			bank_out : out std_logic_vector(1 downto 0);
			addr_out : out std_logic_vector(12 downto 0)
		);
	end component;
	-- component decls end here
	
	-- DRAM commands - <we_n,cas_n,ras_n>
	constant CMD_NOP        : std_logic_vector(2 downto 0)  := "111";
	constant CMD_ACTIVE     : std_logic_vector(2 downto 0)  := "110"; -- opens a row within a bank
	constant CMD_READ       : std_logic_vector(2 downto 0)  := "101";
	constant CMD_WRITE      : std_logic_vector(2 downto 0)  := "001";
	constant CMD_BURST_TERM : std_logic_vector(2 downto 0)  := "011";
	constant CMD_PRECHARGE  : std_logic_vector(2 downto 0)  := "010"; -- closes a row within a bank
	constant CMD_AUTO_REFR  : std_logic_vector(2 downto 0)  := "100";
	constant CMD_LOAD_MR    : std_logic_vector(2 downto 0)  := "000";
	
	-- various wait counter values
	constant AUTO_REFRESH_CLKS  : integer := 700; -- spec says 7.8us, which is 780 clocks @ 100Mhz, I'm setting it to 700
	constant WRITE_RECOVER_CLKS : integer := 5;   -- these are fudged a bit, you *might* be able to shave a clock or two off
	constant READ_DONE_CLKS     : integer := 4;   --  or shave a clock or two off if your board timing is a bit wedgy

	type CMD_STATES is ( STATE_START, STATE_INIT, STATE_WAIT_INIT, STATE_IDLE, STATE_IDLE_AUTO_REFRESH, 
	                     STATE_IDLE_CHECK_OP_PENDING, STATE_IDLE_WAIT_AR_CTR, STATE_IDLE_WAIT_AUTO_REFRESH,
								STATE_WRITE_ROW_OPEN, STATE_WRITE_WAIT_ROW_OPEN, STATE_WRITE_ISSUE_CMD, STATE_WRITE_WAIT_RECOVER,
								STATE_READ_ROW_OPEN, STATE_READ_WAIT_ROW_OPEN, STATE_READ_ISSUE_CMD, STATE_READ_WAIT_CAPTURE );

	signal cmd_state : CMD_STATES := STATE_START;

	signal cmd_oddr2_rising   : std_logic_vector(2 downto 0) := CMD_NOP;
	signal bank_oddr2_rising  : std_logic_vector(1 downto 0) := "00";	
	signal addr_oddr2_rising  : std_logic_vector(12 downto 0) := "0000000000000";

	signal dqs_out : std_logic_vector(1 downto 0);
	signal dqs_dir : std_logic;

	signal dq_in : std_logic_vector(15 downto 0);
	signal dq_out : std_logic_vector(15 downto 0);
	signal dq_dir : std_logic;

	signal reader_rst : std_logic := '1';
	signal writer_rst : std_logic := '1';

	signal dcm_locked   : std_logic;
	signal clk_000      : std_logic;
	signal clk_090      : std_logic;
	signal clk_180      : std_logic;
	signal clk_270      : std_logic;
	
	-- init module stuff
	signal init_reset : std_logic;
	signal init_cmd   : std_logic_vector(2 downto 0);
	signal init_bank  : std_logic_vector(1 downto 0);
	signal init_addr  : std_logic_vector(12 downto 0);
	signal init_done  : std_logic;

	-- main module stuff
	signal main_sel  : std_logic;
	signal main_cmd  : std_logic_vector(2 downto 0);
	signal main_bank : std_logic_vector(1 downto 0);
	signal main_addr : std_logic_vector(12 downto 0);

	-- wait counter stuff
	signal need_ar_rst : std_logic;
	signal need_ar     : std_logic;
	
	signal wait_ar_rst  : std_logic;
	signal wait_ar_done : std_logic;
	
	signal write_reco_rst  : std_logic;
	signal write_reco_done : std_logic;
	
	signal read_wait_rst : std_logic;
	signal read_wait_done : std_logic;
	
	signal data0_o : std_logic_vector(7 downto 0);
	signal data1_o : std_logic_vector(7 downto 0);
	
	-- capture signals
	signal cap_en     : std_logic;
	signal op_save    : std_logic_vector(1 downto 0);
	signal addr_save  : std_logic_vector(25 downto 0);
	signal datai_save : std_logic_vector(7 downto 0);
	
begin
  
	-- component instantiations begin here
	DRAM_DCM: sdram_dcm
	port map(
		reset           => reset,
		clk100mhz       => clk100mhz,
		locked          => dcm_locked,
		dram_clkp       => dram_clkp,
		dram_clkn       => dram_clkn,
		clk_000         => clk_000,
		clk_090         => clk_090,
		clk_180         => clk_180,
		clk_270         => clk_270
	);
	
	DRAM_INIT: sdram_init
	port map(
		clk_000 => clk_000,
		reset   => init_reset,
		clke    => dram_clke,
		cmd     => init_cmd,
		bank    => init_bank,
		addr    => init_addr,
		done    => init_done
	);
	
	CMD_BANK_ADDR_SEL: cmd_bank_addr_switch
	port map(
		sel      => main_sel,
		cmd0_in  => init_cmd,
		bank0_in => init_bank,
		addr0_in => init_addr,
		cmd1_in  => main_cmd,
		bank1_in => main_bank,
		addr1_in => main_addr,
		cmd_out  => cmd_oddr2_rising,
		bank_out => bank_oddr2_rising,
		addr_out => addr_oddr2_rising
	);
	
	DRAM_BANK_ODDR2: oddr2_2
	port map(
		Q  => dram_bank,
		C0 => clk_270,
		C1 => clk_090,
		CE => '1',
		D0 => bank_oddr2_rising,
		D1 => "00",
		R  => '0',
		S  => '0' );
  
	DRAM_CMD_ODDR2: oddr2_3
	port map(
		Q  => dram_cmd,
		C0 => clk_270,
		C1 => clk_090,
		CE => '1',
		D0 => cmd_oddr2_rising,
		D1 => CMD_NOP,
		R  => '0',
		S  => '0' );
  
	DRAM_ADDR_ODDR2: oddr2_13
	port map(
		Q  => dram_addr,
		C0 => clk_270,
		C1 => clk_090,
		CE => '1',
		D0 => addr_oddr2_rising,
		D1 => "0000000000000",
		R  => '0',
		S  => '0' );
    
	DQS_SWITCH: inout_switch_2
	port map(
		ioport => dram_dqs,
		dir    => dqs_dir,
		data_i => dqs_out
	);
  
	DQ_SWITCH: inout_switch_16
	port map(
		ioport => dram_dq,
		dir    => dq_dir,
		data_o => dq_in,
		data_i => dq_out
	);

	AR_NEEDED_CTR: wait_counter
	generic map(
		BITS => 10,
		CLKS => AUTO_REFRESH_CLKS
	)
	port map (
          clk => clk_000,
          rst => need_ar_rst,
         done => need_ar
	);
	
	WAIT_AR_CTR: wait_counter
	generic map(
		BITS => 4,
		CLKS => 11
	)
	port map(
		clk => clk_000,
		rst => wait_ar_rst,
		done => wait_ar_done
	);

	WRITE_RECOVER_CTR: wait_counter
	generic map(
		BITS => 2,
		CLKS => WRITE_RECOVER_CLKS
	)
	port map(
          clk => clk_000,
          rst => write_reco_rst,
         done => write_reco_done
	);
	
	READ_DONE_CTR: wait_counter
	generic map(
		BITS => 2,
		CLKS => READ_DONE_CLKS
	)
	port map(
          clk => clk_000,
          rst => read_wait_rst,
         done => read_wait_done
	);
  
	READER: sdram_reader
	port map(
      clk270 => clk_270,
      rst    => reader_rst,
      dq     => dq_in,
		data0  => data0_o,
		data1  => data1_o
	);
  
	WRITER: sdram_writer
	port map(
		clk    => clk_000,
		clk090 => clk_090,
		clk180 => clk_180,
		clk270 => clk_270,
		rst    => writer_rst,
		addr   => addr_save(0),
		data_o => datai_save,
		dqs    => dqs_out,
		dm     => dram_dm,
		dq     => dq_out
	);
	-- end component allocs

	debug_reg <= x"00";
	dram_cs <= '0';
	data_o <= data1_o when addr_save(0) = '1' else data0_o;
	
	-- capture addr, data_i and op for the cmd fsm
	-- op needs to be captured during AR or it might get dropped
	process (clk_000,cap_en)
	begin
		if (cap_en = '1') then
			if (rising_edge(clk_000)) then
				addr_save <= addr;
				datai_save <= data_i;
				op_save <= op;
			end if;
		end if;
	end process;
	
	-- command state machine
	process (clk_000)
	begin
		if (rising_edge(clk_000)) then
			if (dcm_locked = '1') then
				case cmd_state is
					when STATE_START =>
						busy_n <= '0';
						op_ack <= '0';
						init_reset <= '1';
						cap_en <= '0';
						main_sel <= '0';
						main_cmd <= CMD_NOP;
						main_bank <= "00";
						main_addr <= "0000000000000";
						cmd_state <= STATE_INIT;
						
					when STATE_INIT =>
						init_reset <= '0';
						cmd_state <= STATE_WAIT_INIT;
					
					when STATE_WAIT_INIT =>
						need_ar_rst <= '1';
						if (init_done = '1') then
							cmd_state <= STATE_IDLE;
						else
							cmd_state <= cmd_state;
						end if;
					
					when STATE_IDLE =>
						-- this is the main hub state
						-- this is where reads and writes return to after being completed
						busy_n <= '1';
						op_ack <= '0';
						need_ar_rst <= '0';
						main_sel <= '1';
						writer_rst <= '1';
						reader_rst <= '1';
						cap_en <= '1';
						if (need_ar = '1') then
							busy_n <= '0';
							cmd_state <= STATE_IDLE_AUTO_REFRESH;
						elsif (op = "01") then
							busy_n <= '0';
							op_ack <= '1';
							cap_en <= '0';
							cmd_state <= STATE_READ_ROW_OPEN; 
						elsif (op = "10") then
							busy_n <= '0';
							op_ack <= '1';
							cap_en <= '0';
							cmd_state <= STATE_WRITE_ROW_OPEN;
						else
							cmd_state <= cmd_state;
						end if;					

					when STATE_IDLE_AUTO_REFRESH =>
						if (op = "01" or op = "10") then
							cap_en <= '0';
						end if;
						need_ar_rst <= '1';
						wait_ar_rst <= '1';
						main_cmd <= CMD_AUTO_REFR;
						main_bank <= "00";
						main_addr <= "0000000000000";
						cmd_state <= STATE_IDLE_WAIT_AR_CTR;

					when STATE_IDLE_WAIT_AR_CTR =>
						if (op = "01" or op = "10") then
							cap_en <= '0';
						end if;
						wait_ar_rst <= '0';
						main_cmd <= CMD_NOP;
						main_bank <= "00";
						main_addr <= "0000000000000";
						cmd_state <= STATE_IDLE_WAIT_AUTO_REFRESH;
						
					when STATE_IDLE_WAIT_AUTO_REFRESH =>
						if (op = "01" or op = "10") then
							cap_en <= '0';
						end if;
						main_cmd <= CMD_NOP;
						main_bank <= "00";
						main_addr <= "0000000000000";
						if (wait_ar_done = '1') then
							cmd_state <= STATE_IDLE_CHECK_OP_PENDING; 
						else
							cmd_state <= cmd_state;
						end if;
						
					when STATE_IDLE_CHECK_OP_PENDING =>
						if ( cap_en = '0') then
							if    (op_save = "01") then
								op_ack <= '1';
								cmd_state <= STATE_READ_ROW_OPEN; 
							elsif (op_save = "10") then
								op_ack <= '1';
								cmd_state <= STATE_WRITE_ROW_OPEN;
							else
								cmd_state <= STATE_IDLE;
							end if;
						else
							cmd_state <= STATE_IDLE;
						end if;
						
					when STATE_WRITE_ROW_OPEN =>
						dqs_dir <= '1';
						dq_dir <= '1';
						main_cmd <= CMD_ACTIVE;
						main_bank <= addr_save(25 downto 24);
						main_addr <= addr_save(23 downto 11);
						cmd_state <= STATE_WRITE_WAIT_ROW_OPEN;
						
					when STATE_WRITE_WAIT_ROW_OPEN =>
						main_cmd <= CMD_NOP;
						main_bank <= addr_save(25 downto 24); -- timing kludge
						main_addr <= "001" & addr_save(10 downto 1); -- last bit determines upper/lower byte in word
						cmd_state <= STATE_WRITE_ISSUE_CMD;
					
					when STATE_WRITE_ISSUE_CMD =>
						writer_rst <= '0';
						write_reco_rst <= '1';
						main_cmd <= CMD_WRITE;
						main_bank <= addr_save(25 downto 24);
						main_addr <= "001" & addr_save(10 downto 1); -- last bit determines upper/lower byte in word
						cmd_state <= STATE_WRITE_WAIT_RECOVER;
						
					when STATE_WRITE_WAIT_RECOVER =>
						write_reco_rst <= '0';
						main_cmd <= CMD_NOP;
						main_bank <= "00";
						main_addr <= "0000000000000";
						if (write_reco_done = '1') then
							cmd_state <= STATE_IDLE; 
						else
							cmd_state <= cmd_state;
						end if;
						
					when STATE_READ_ROW_OPEN =>
						dqs_dir <= '0';
						dq_dir <= '0';
						main_cmd <= CMD_ACTIVE;
						main_bank <= addr_save(25 downto 24);
						main_addr <= addr_save(23 downto 11);
						cmd_state <= STATE_READ_WAIT_ROW_OPEN;
						
					when STATE_READ_WAIT_ROW_OPEN => 
						main_cmd <= CMD_NOP;
						main_bank <= addr_save(25 downto 24); -- timing kludge
						main_addr <= "001" & addr_save(10 downto 1); -- last bit determines upper/lower byte
						cmd_state <= STATE_READ_ISSUE_CMD;
						
					when STATE_READ_ISSUE_CMD =>
						read_wait_rst <= '1';
						main_cmd <= CMD_READ;
						main_bank <= addr_save(25 downto 24);
						main_addr <= "001" & addr_save(10 downto 1); -- last bit determines upper/lower byte
						cmd_state <= STATE_READ_WAIT_CAPTURE;
						
					when STATE_READ_WAIT_CAPTURE =>
						read_wait_rst <= '0';
						reader_rst <= '0';
						main_cmd <= CMD_NOP;
						main_bank <= "00";
						main_addr <= "0000000000000";
						if (read_wait_done = '1') then
							cmd_state <= STATE_IDLE;
						else
							cmd_state <= cmd_state;
						end if;
				end case;
			end if;
		end if;
	end process;	
	
end impl;


