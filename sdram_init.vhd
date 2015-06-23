----------------------------------------------------------------------------------
-- Company: OPL Aerospatiale AG
-- Engineer: Owen Lynn <lynn0p@hotmail.com>
-- 
-- Create Date:    17:29:55 08/29/2009 
-- Design Name: 
-- Module Name:    sdram_init - impl 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: This is the FSM that gets the DDR SDRAM chip past init. Otherwise
--  the main FSM would grow pretty unwieldy and unstable.
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

entity sdram_init is
	port(
		clk_000 : in std_logic;
		reset   : in std_logic;
		
		clke  : out std_logic;
		cmd   : out std_logic_vector(2 downto 0);
		bank  : out std_logic_vector(1 downto 0);
		addr  : out std_logic_vector(12 downto 0);
		done  : out std_logic
	);
end sdram_init;

architecture impl of sdram_init is
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

	constant CMD_NOP        : std_logic_vector(2 downto 0)  := "111";
	constant CMD_PRECHARGE  : std_logic_vector(2 downto 0)  := "010";
	constant CMD_AUTO_REFR  : std_logic_vector(2 downto 0)  := "100";
	constant CMD_LOAD_MR    : std_logic_vector(2 downto 0)  := "000";
		
	constant CLKS_200US         : integer := 30000; -- well, it's supposed to be 20000, but i'm fudging

	type INIT_STATES is ( STATE_START, STATE_WAIT200US, STATE_CLKE, STATE_PRECHARGE_ALL0, STATE_WAIT_PRECHARGE_ALL0, STATE_LOAD_MRE,
	                      STATE_WAIT_MRE, STATE_LOAD_MRN, STATE_WAIT_MRN, STATE_PRECHARGE_ALL1, STATE_WAIT_PRECHARGE_ALL1, STATE_AUTO_REFRESH0,
								 STATE_WAIT_AR_CTR0, STATE_WAIT_AUTO_REFRESH0, STATE_AUTO_REFRESH1, STATE_WAIT_AR_CTR1, STATE_WAIT_AUTO_REFRESH1,
								 STATE_WAIT_200_CLOCKS, STATE_DONE );
	
	signal init_state : INIT_STATES;

	signal wait200us_rst : std_logic;
	signal wait200us_done : std_logic;
	
	signal wait_ar_rst : std_logic;
	signal wait_ar_done : std_logic;
	
	signal wait_200clks_rst : std_logic;
	signal wait_200clks_done : std_logic;

	signal a058 : std_logic;
	signal a10 : std_logic;
	signal bk0 : std_logic;

begin

	WAIT200US_CTR: wait_counter
	generic map(
		BITS => 16,
		CLKS => CLKS_200US
	)
	port map(
		clk => clk_000,
		rst => wait200us_rst,
		done => wait200us_done
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
	
	WAIT_200CLKS_CTR: wait_counter
	generic map(
		BITS => 8,
		CLKS => 200
	)
	port map(
		clk => clk_000,
		rst => wait_200clks_rst,
		done => wait_200clks_done
	);
	
	-- really optimized output of FSM
	addr(12) <= '0';
	addr(11) <= '0';
	addr(10) <= a10;
	addr(9)  <= '0';
	addr(8)  <= a058;
	addr(7)  <= '0';
	addr(6)  <= '0';
	addr(5)  <= a058;
	addr(4)  <= '0';
	addr(3)  <= '0';
	addr(2)  <= '0';
	addr(1)  <= '0';
	addr(0)  <= a058;
	bank(1) <= '0';
	bank(0) <= bk0;

	process (clk_000, reset)
	begin
		if (reset = '1') then
			init_state <= STATE_START;
			wait200us_rst <= '1';
			wait_ar_rst <= '1';
			wait_200clks_rst <= '1';
			clke <= '0';
			cmd <= CMD_NOP;
			bk0 <= '0';
			a10 <= '0'; a058 <= '0';
			done <= '0';
		elsif (rising_edge(clk_000)) then
			case init_state is
				when STATE_START =>
					cmd <= CMD_NOP;
					bk0 <= '0';
					a10 <= '0'; a058 <= '0';
					init_state <= STATE_WAIT200US;
					
				when STATE_WAIT200US =>
					wait200us_rst <= '0';
					cmd <= CMD_NOP;
					bk0 <= '0';
					a10 <= '0'; a058 <= '0';
					if( wait200us_done = '1' ) then
						init_state <= STATE_CLKE;
					else 
						init_state <= init_state;
					end if;
					
				when STATE_CLKE =>
					clke <= '1';
					cmd <= CMD_NOP;
					bk0 <= '0';
					a10 <= '1'; a058 <= '0'; -- timing kludge
					init_state <= STATE_PRECHARGE_ALL0;
					
				when STATE_PRECHARGE_ALL0 =>
					cmd <= CMD_PRECHARGE;
					bk0 <= '0';
					a10 <= '1'; a058 <= '0';
					init_state <= STATE_WAIT_PRECHARGE_ALL0;
					
				when STATE_WAIT_PRECHARGE_ALL0 =>
					cmd <= CMD_NOP;
					bk0 <= '0';
					a10 <= '0'; a058 <= '0';
					init_state <= STATE_LOAD_MRE;
					
				when STATE_LOAD_MRE =>
					cmd <= CMD_LOAD_MR;
					bk0 <= '1';
					a10 <= '0'; a058 <= '0';
					init_state <= STATE_WAIT_MRE;
					
				when STATE_WAIT_MRE =>
					cmd <= CMD_NOP;
					bk0 <= '0';
					a10 <= '0'; a058 <= '1'; -- timing kludge
					init_state <= STATE_LOAD_MRN;
					
				when STATE_LOAD_MRN =>
					cmd <= CMD_LOAD_MR;
					bk0 <= '0';
					a10 <= '0'; a058 <= '1';
					init_state <= STATE_WAIT_MRN;
					
				when STATE_WAIT_MRN =>
					cmd <= CMD_NOP;
					bk0 <= '0';
					a10 <= '0'; a058 <= '1'; -- timing kludge
					init_state <= STATE_PRECHARGE_ALL1;
					
				when STATE_PRECHARGE_ALL1 =>
					cmd <= CMD_PRECHARGE;
					bk0 <= '0';
					a10 <= '1'; a058 <= '0';
					init_state <= STATE_WAIT_PRECHARGE_ALL1;

				when STATE_WAIT_PRECHARGE_ALL1 =>
					cmd <= CMD_NOP;
					bk0 <= '0';
					a10 <= '0'; a058 <= '0';
					init_state <= STATE_AUTO_REFRESH0;

				when STATE_AUTO_REFRESH0 =>
					wait_ar_rst <= '1';
					cmd <= CMD_AUTO_REFR;
					bk0 <= '0';
					a10 <= '0'; a058 <= '0';
					init_state <= STATE_WAIT_AR_CTR0;
					
				when STATE_WAIT_AR_CTR0 =>
					wait_ar_rst <= '0';
					cmd <= CMD_NOP;
					bk0 <= '0';
					a10 <= '0'; a058 <= '0';
					init_state <= STATE_WAIT_AUTO_REFRESH0;
					
				when STATE_WAIT_AUTO_REFRESH0 =>
					cmd <= CMD_NOP;
					bk0 <= '0';
					a10 <= '0'; a058 <= '0';
					if (wait_ar_done = '1') then
						init_state <= STATE_AUTO_REFRESH1;
					else 
						init_state <= init_state;
					end if;
					
				when STATE_AUTO_REFRESH1 =>
					wait_ar_rst <= '1';
					cmd <= CMD_AUTO_REFR;
					bk0 <= '0';
					a10 <= '0'; a058 <= '0';
					init_state <= STATE_WAIT_AR_CTR1;
					
				when STATE_WAIT_AR_CTR1 =>
					wait_ar_rst <= '0';
					cmd <= CMD_NOP;
					bk0 <= '0';
					a10 <= '0'; a058 <= '0';
					init_state <= STATE_WAIT_AUTO_REFRESH1;
					
				when STATE_WAIT_AUTO_REFRESH1 =>
					wait_200clks_rst <= '1';
					cmd <= CMD_NOP;
					bk0 <= '0';
					a10 <= '0'; a058 <= '0';
					if (wait_ar_done = '1') then
						init_state <= STATE_WAIT_200_CLOCKS;
					else 
						init_state <= init_state;
					end if;
					
				when STATE_WAIT_200_CLOCKS =>
					wait_200clks_rst <= '0';
					cmd <= CMD_NOP;
					bk0 <= '0';
					a10 <= '0'; a058 <= '0';
					if (wait_200clks_done = '1') then
						init_state <= STATE_DONE;
					else 
						init_state <= init_state;
					end if;
					
				 when STATE_DONE =>
					done <= '1';
					cmd <= CMD_NOP;
					bk0 <= '0';
					a10 <= '0'; a058 <= '0';
					
				when others =>
					cmd <= CMD_NOP;
					bk0 <= '0';
					a10 <= '0'; a058 <= '0';					
			end case;
		end if;
	end process;
end impl;

