--
-- File vtim.vhd, Video Timing Generator
-- Project: VGA
-- Author : Richard Herveille
-- rev.: 0.1 April 13th, 2001
-- rev.: 0.2 June  23nd, 2001. Removed unused "rst_strb" signal.
-- rev.: 0.3 June  29th, 2001. Changed 'gen_go' process to use clock-enable signal.
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

library count;
use count.count.all;

entity vtim is
	port(
		clk : in std_logic;                -- master clock
		ena : in std_logic;                -- count enable
		rst : in std_logic;                -- synchronous active high reset

		Tsync : in unsigned(7 downto 0);   -- sync duration
		Tgdel : in unsigned(7 downto 0);   -- gate delay
		Tgate : in unsigned(15 downto 0);  -- gate length
		Tlen  : in unsigned(15 downto 0);  -- line time / frame time

		Sync  : out std_logic;             -- synchronization pulse
		Gate  : out std_logic;             -- gate
		Done  : out std_logic              -- done with line/frame
	);
end entity vtim;

architecture structural of vtim is
	signal Dsync, Dgdel, Dgate, Dlen : std_logic;
	signal go, drst : std_logic;
begin
	-- generate go signal
	gen_go: process(clk)
	begin
		if (clk'event and clk = '1') then
			if (rst = '1') then
				go <= '0';
				drst <= '1';
			elsif (ena = '1') then
				go <= Dlen or (not rst and drst);
				drst <= rst;
			end if;
		end if;
	end process gen_go;
--	go <= Dlen or (not rst and drst); does not work => horizontal Dlen counter does not reload

	-- hookup sync counter
	sync_cnt : ro_cnt generic map (SIZE => 8)
		port map (clk => clk, rst => rst, cnt_en => ena, go => go, D => Tsync, iD => Tsync, done => Dsync);

	-- hookup gate delay counter
	gdel_cnt : ro_cnt generic map (SIZE => 8)
		port map (clk => clk, rst => rst, cnt_en => ena, go => Dsync, D => Tgdel, iD => Tgdel, done => Dgdel);

	-- hookup gate counter
	gate_cnt : ro_cnt generic map (SIZE => 16)
		port map (clk => clk, rst => rst, cnt_en => ena, go => Dgdel, D => Tgate, iD => Tgate, done => Dgate);

	-- hookup gate counter
	len_cnt : ro_cnt generic map (SIZE => 16)
		port map (clk => clk, rst => rst, cnt_en => ena, go => go, D => Tlen, iD => Tlen, done => Dlen);

	-- generate output signals
	gen_sync: block
		signal iSync : std_logic;
	begin
		process(clk)
		begin
			if (clk'event and clk = '1') then
				if (rst = '1') then
					iSync <= '0';
				else
					iSync <= (go or iSync) and not Dsync;
				end if;
			end if;
		end process;
		Sync <= iSync;
	end block gen_sync;

	gen_gate: block
		signal iGate : std_logic;
	begin
		process(clk)
		begin
			if (clk'event and clk = '1') then
				if (rst = '1') then
					iGate <= '0';
				else
					iGate <= (Dgdel or iGate) and not Dgate;
				end if;
			end if;
		end process;

		Gate <= iGate;
	end block gen_gate;

	Done <= Dlen;
end architecture structural;



