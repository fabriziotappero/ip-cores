--
--  Wishbone bus toolkit.
--
--  (c) Copyright Andras Tantos <andras_tantos@yahoo.com> 2001/03/31
--  This code is distributed under the terms and conditions of the GNU General Public Lince.
--
--
-- ELEMENTS:
--   wb_async_slave: Wishbone bus to async (SRAM-like) bus slave bridge.

-------------------------------------------------------------------------------
--
--  wb_async_slave
--
-------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

library wb_tk;
use wb_tk.technology.all;

entity wb_async_slave is
	generic (
		width: positive := 16;
		addr_width: positive := 20
	);
	port (
		clk_i: in std_logic;
		rst_i: in std_logic := '0';
		
		-- interface for wait-state generator state-machine
		wait_state: in std_logic_vector (3 downto 0);

		-- interface to wishbone master device
		adr_i: in std_logic_vector (addr_width-1 downto 0);
		sel_i: in std_logic_vector ((addr_width/8)-1 downto 0);
		dat_i: in std_logic_vector (width-1 downto 0);
		dat_o: out std_logic_vector (width-1 downto 0);
		dat_oi: in std_logic_vector (width-1 downto 0) := (others => '-');
		we_i: in std_logic;
		stb_i: in std_logic;
		ack_o: out std_logic := '0';
		ack_oi: in std_logic := '-';
	
		-- interface to async slave
		a_data: inout std_logic_vector (width-1 downto 0) := (others => 'Z');
		a_addr: out std_logic_vector (addr_width-1 downto 0) := (others => 'U');
		a_rdn: out std_logic := '1';
		a_wrn: out std_logic := '1';
		a_cen: out std_logic := '1';
		-- byte-enable signals
		a_byen: out std_logic_vector ((width/8)-1 downto 0)
	);
end wb_async_slave;

architecture wb_async_slave of wb_async_slave is
	-- multiplexed access signals to memory
	signal i_ack: std_logic;
	signal sm_ack: std_logic;

	type states is (sm_idle, sm_wait, sm_deact);
	signal state: states;
	signal cnt: std_logic_vector(3 downto 0);
begin
	ack_o <= (stb_i and i_ack) or (not stb_i and ack_oi);
	dat_o_gen: for i in dat_o'RANGE generate
	    dat_o(i) <= (stb_i and a_data(i)) or (not stb_i and dat_oi(i));
	end generate;
	
	-- For 0WS operation i_ack is an async signal otherwise it's a sync one.
	i_ack_gen: process is
	begin
		wait on sm_ack, stb_i, wait_state, state;
		if (wait_state = "0000") then
			case (state) is
				when sm_deact => i_ack <= '0';
				when others => i_ack <= stb_i;
			end case;
		else
			i_ack <= sm_ack;
		end if;
	end process;
	
	-- SRAM signal-handler process
	sram_signals: process is
	begin
		wait on state,we_i,a_data,adr_i,rst_i, stb_i, sel_i, dat_i;
		if (rst_i = '1') then
			a_wrn <= '1';
			a_rdn <= '1';
			a_cen <= '1';
			a_addr <= (others => '-');
			a_data <= (others => 'Z');
    		a_byen <= (others => '1');
		else
			case (state) is
				when sm_deact =>
					a_wrn <= '1';
					a_rdn <= '1';
					a_cen <= '1';
					a_addr <= (others => '-');
					a_data <= (others => 'Z');
            		a_byen <= (others => '1');
				when others =>
					a_addr <= adr_i;
					a_rdn <= not (not we_i and stb_i);
					a_wrn <= not (we_i and stb_i);
					a_cen <= not stb_i;
            		a_byen <= not sel_i;
					if (we_i = '1') then 
						a_data <= dat_i; 
					else
						a_data <= (others => 'Z');
					end if;
			end case;
		end if;
	end process;

	-- Aysnc access state-machine.
	async_sm: process is
--		variable cnt: std_logic_vector(3 downto 0) := "0000";
--		variable state: states := init;
	begin
		wait until clk_i'EVENT and clk_i = '1';
		if (rst_i = '1') then
			state <= sm_idle;
			cnt <= ((0) => '1', others => '0');
			sm_ack <= '0';
		else
			case (state) is
				when sm_idle =>
					-- Check if anyone needs access to the memory.
					-- it's rdy signal will already be pulled low, so we only have to start the access
					if (stb_i = '1') then
						case wait_state is
							when "0000" =>
								sm_ack <= '1';
								state <= sm_deact;
							when "0001" =>
								sm_ack <= '1';
								cnt <= "0001";
								state <= sm_wait;
							when others =>
								sm_ack <= '0';
								cnt <= "0001";
								state <= sm_wait;
						end case;
					end if;
				when sm_wait =>
					if (cnt = wait_state) then
						-- wait cycle completed.
						state <= sm_deact;
						sm_ack <= '0';
						cnt <= "0000";
					else
						if (add_one(cnt) = wait_state) then
							sm_ack <= '1';
						else
							sm_ack <= '0';
						end if;
						cnt <= add_one(cnt);
					end if;
				when sm_deact =>
					if (stb_i = '1') then
						case wait_state is
							when "0000" =>
								cnt <= "0000";
								sm_ack <= '0';
								state <= sm_wait;
							when others =>
								sm_ack <= '0';
								cnt <= "0000";
								state <= sm_wait;
						end case;
					else
						sm_ack <= '0';
						state <= sm_idle;
					end if;
			end case;
		end if;
	end process;
end wb_async_slave;

