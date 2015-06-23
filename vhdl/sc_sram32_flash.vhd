--
--	sc_sram32_flash.vhd
--
--	SimpCon compliant external memory interface
--	for 32-bit SRAM (e.g. Cyclone board)
--
--	Connection between mem_sc and the external memory bus
--
--	memory mapping
--	
--		0x000000-x7ffff	external SRAM (w mirror)	max. 512 kW (4*4 MBit)
--		0x080000-xfffff	external Flash (w mirror)	max. 512 kB (4 MBit)
--		0x100000-xfffff	external NAND flash
--
--	RAM: 32 bit word
--	ROM: 8 bit word (for flash programming)
--
--	todo:
--		
--
--	2005-11-22	first version
--	2005-12-02	added flash interface
--

Library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

use work.jop_types.all;
use work.sc_pack.all;

entity sc_mem_if is
generic (ram_ws : integer; rom_ws : integer);

port (

	clk, reset	: in std_logic;

--
--	SimpCon memory interface
--
	sc_mem_out		: in sc_mem_out_type;
	sc_mem_in		: out sc_in_type;

-- memory interface

	ram_addr	: out std_logic_vector(17 downto 0);
	ram_dout	: out std_logic_vector(31 downto 0);
	ram_din		: in std_logic_vector(31 downto 0);
	ram_dout_en	: out std_logic;
	ram_ncs		: out std_logic;
	ram_noe		: out std_logic;
	ram_nwe		: out std_logic;

--
--	config/program flash and big nand flash interface
--
	fl_a	: out std_logic_vector(18 downto 0);
	fl_d	: inout std_logic_vector(7 downto 0);
	fl_ncs	: out std_logic;
	fl_ncsb	: out std_logic;
	fl_noe	: out std_logic;
	fl_nwe	: out std_logic;
	fl_rdy	: in std_logic

);
end sc_mem_if;

architecture rtl of sc_mem_if is

--
--	signals for mem interface
--
	type state_type		is (
							idl, rd1, rd2, wr1,
							fl_rd1, fl_rd2, fl_wr1, fl_wr2
						);
	signal state 		: state_type;
	signal next_state	: state_type;

	signal nwr_int		: std_logic;
	signal wait_state	: unsigned(3 downto 0);
	signal cnt			: unsigned(1 downto 0);

	signal dout_ena		: std_logic;
	signal ram_data		: std_logic_vector(31 downto 0);
	signal ram_data_ena	: std_logic;

	signal flash_dout	: std_logic_vector(7 downto 0);
	signal fl_dout_ena	: std_logic;
	signal flash_data	: std_logic_vector(7 downto 0);
	signal flash_data_ena	: std_logic;
	signal nand_rdy		: std_logic;

	signal trans_ram	: std_logic;
	signal trans_flash	: std_logic;
	-- selection for read mux
	signal ram_access	: std_logic;
	-- selection for Flash/NAND ncs
	signal sel_flash	: std_logic;

begin

	assert MEM_ADDR_SIZE>=21 report "Too less address bits";
	ram_dout_en <= dout_ena;

	sc_mem_in.rdy_cnt <= cnt;

--
--	decode ram/flash
--	The signals are only valid for the first cycle
--
process(sc_mem_out.address(20 downto 19))
begin

	trans_ram <= '0';
	trans_flash <= '0';

	case sc_mem_out.address(20 downto 19) is
		when "00" =>
			trans_ram <= '1';
		when "01" =>
			trans_flash <= '1';
		when others =>
			null;
	end case;

end process;

--
--	Register memory address, write data and read data
--
process(clk, reset)
begin
	if reset='1' then

		ram_addr <= (others => '0');
		ram_dout <= (others => '0');
		ram_data <= (others => '0');
		flash_dout <= (others => '0');
		fl_a <= (others => '0');
		sel_flash <= '1';			-- AMD default
		ram_access <= '1';			-- RAM default

	elsif rising_edge(clk) then

		if sc_mem_out.rd='1' or sc_mem_out.wr='1' then
			if trans_ram='1' then
				ram_access <= '1';
				ram_addr <= sc_mem_out.address(17 downto 0);
			else
				ram_access <= '0';
				fl_a <= sc_mem_out.address(18 downto 0);
				-- select flash type
				-- and keep it selected
				if trans_flash='1' then
					sel_flash <= '1';
				else
					sel_flash <= '0';
				end if;
			end if;
		end if;
		if sc_mem_out.wr='1' then
			if trans_ram='1' then
				ram_dout <= sc_mem_out.wr_data;
			else
				flash_dout <= sc_mem_out.wr_data(7 downto 0);
			end if;
		end if;
		if ram_data_ena='1' then
			ram_data <= ram_din;
		end if;
		if flash_data_ena='1' then
			-- signal NAND rdy only for NAND access
			nand_rdy <= fl_rdy and not sel_flash;
			flash_data <= fl_d;
		end if;

	end if;
end process;

--
--	MUX registered RAM and Flash data
--
process(ram_access, ram_data, flash_data, nand_rdy)

begin
	if (ram_access='1') then
		sc_mem_in.rd_data <= ram_data;
	else
		sc_mem_in.rd_data <= std_logic_vector(to_unsigned(0, 32-9)) & nand_rdy & flash_data;
	end if;
end process;

--
--	'delay' nwe 1/2 cycle -> change on falling edge
--
process(clk, reset)

begin
	if (reset='1') then
		ram_nwe <= '1';
	elsif falling_edge(clk) then
		ram_nwe <= nwr_int;
	end if;

end process;


--
--	next state logic
--
process(state, sc_mem_out, trans_ram, wait_state)

begin

	next_state <= state;

	case state is

		when idl =>
			if sc_mem_out.rd='1' then
				if trans_ram='1' then
					if ram_ws=0 then
						-- then we omit state rd1!
						next_state <= rd2;
					else
						next_state <= rd1;
					end if;
				else
					next_state <= fl_rd1;
				end if;
			elsif sc_mem_out.wr='1' then
				if trans_ram='1' then
					next_state <= wr1;
				else
					next_state <= fl_wr1;
				end if;
			end if;

		-- the WS state
		when rd1 =>
			if wait_state=2 then
				next_state <= rd2;
			end if;

		-- last read state
		when rd2 =>
			next_state <= idl;
			-- This should do to give us a pipeline
			-- level of 2 for read
			-- we don't care about a flash trans.
			-- in the pipeline!
			if sc_mem_out.rd='1' then
				if ram_ws=0 then
					-- then we omit state rd1!
					next_state <= rd2;
				else
					next_state <= rd1;
				end if;
			elsif sc_mem_out.wr='1' then
				next_state <= wr1;
			end if;
			
		-- the WS state
		when wr1 =>
-- TODO: check what happens on ram_ws=0
-- TODO: do we need a write pipelining?
--	not at the moment, but parhaps later when
--	we write the stack content to main memory
			if wait_state=1 then
				next_state <= idl;
			end if;

		when fl_rd1 =>
			if wait_state=2 then
				next_state <= fl_rd2;
			end if;

		when fl_rd2 =>
			next_state <= idl;
			-- we do no pipelining with the Flashs

		when fl_wr1 =>
			if wait_state=2 then
				next_state <= fl_wr2;
			end if;

		when fl_wr2 =>
			next_state <= idl;

	end case;
				
end process;

--
--	state machine register
--	output register (RAM, Flash control lines)
--
process(clk, reset)

begin
	if (reset='1') then
		state <= idl;
		dout_ena <= '0';
		ram_ncs <= '1';
		ram_noe <= '1';
		ram_data_ena <= '0';

		fl_noe <= '1';
		fl_nwe <= '1';
		flash_data_ena <= '0';
		fl_dout_ena <= '0';

	elsif rising_edge(clk) then

		state <= next_state;
		dout_ena <= '0';
		ram_ncs <= '1';
		ram_noe <= '1';
		ram_data_ena <= '0';

		fl_noe <= '1';
		fl_nwe <= '1';
		flash_data_ena <= '0';
		fl_dout_ena <= '0';

		case next_state is

			when idl =>

			-- the wait state
			when rd1 =>
				ram_ncs <= '0';
				ram_noe <= '0';

			-- last read state
			when rd2 =>
				ram_ncs <= '0';
				ram_noe <= '0';
				ram_data_ena <= '1';
				
				
			-- the WS state
			when wr1 =>
				ram_ncs <= '0';
				dout_ena <= '1';

			when fl_rd1 =>
				fl_noe <= '0';

			when fl_rd2 =>
				fl_noe <= '0';
				flash_data_ena <= '1';

			when fl_wr1 =>
				fl_nwe <= '0';
				fl_dout_ena <= '1';

			when fl_wr2 =>
				fl_dout_ena <= '1';

		end case;
					
	end if;
end process;

--
--	nwr combinatorial processing
--	for the negativ edge
--
process(next_state, state)
begin

	nwr_int <= '1';
	if next_state=wr1 then
		nwr_int <= '0';
	end if;

end process;

--
-- wait_state processing
-- cs delay, dout enable
--
process(clk, reset)
begin
	if (reset='1') then
		wait_state <= (others => '1');
		cnt <= "00";
	elsif rising_edge(clk) then

		wait_state <= wait_state-1;

		cnt <= "11";
		if next_state=idl then
			cnt <= "00";
		-- if wait_state<4 then
		elsif wait_state(3 downto 2)="00" then
			cnt <= wait_state(1 downto 0)-1;
		end if;

		if sc_mem_out.rd='1' or sc_mem_out.wr='1' then
			if trans_ram='1' then
				wait_state <= to_unsigned(ram_ws+1, 4);
				if ram_ws<3 then
					cnt <= to_unsigned(ram_ws+1, 2);
				else
					cnt <= "11";
				end if;
			else
				wait_state <= to_unsigned(rom_ws+1, 4);
				cnt <= "11";
			end if;
		end if;

	end if;
end process;

--
--	Flash signals
--

--
--	leave last ncs. Only toggle between two flashs.
--
	fl_ncs <= not sel_flash;	-- Flash ncs
	fl_ncsb <= sel_flash;		-- NAND ncs

--
--	tristate output
--
process(fl_dout_ena, flash_dout)

begin
	if (fl_dout_ena='1') then
		fl_d <= flash_dout(7 downto 0);
	else
		fl_d <= (others => 'Z');
	end if;
end process;

end rtl;
