--
-- Counter.vhd, contains 1) run-once down-counter  2) general purpose up-down riple-carry counter
--
-- Author: Richard Herveille
-- Rev. 1.0 march 7th, 2001
-- rev. 1.1 april 17th, 2001. Changed ro_cnt nld generation
-- rev. 1.1 april 26th, 2001. Changed SYNCH_RCO (component ud_cnt) from string to bit. Fixed problems with Synplify
-- rev. 1.2 may   11th, 2001. Fixed incomplete sensitivity list warning
-- rev. 1.3 june  18th, 2001. Changed module order, they are now in compilation order.
-- rev. 1.4 june  27th, 2001. Removed 'SYNCH_RCO' parameter, simplifies conversion to verilog. 
--                            Fixed a potential bug in "ro_cnt" where 'rci' was not related to 'cnt_en'. 
--                            Changed "val" signal generation from process to "when..else.." statement
--


library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

package count is
	-- general purpose up-down counter
	component ud_cnt is
	generic(
		SIZE : natural := 8
	);
	port(
		clk : in std_logic; -- master clock
		nReset : in std_logic := '1'; -- asynchronous active low reset
		rst : in std_logic := '0'; -- synchronous active high reset

		cnt_en : in std_logic := '1'; -- count enable
		ud : in std_logic := '0'; -- up / not down
		nld : in std_logic := '1'; -- synchronous active low load
		D : in unsigned(SIZE -1 downto 0); -- load counter value
		Q : out unsigned(SIZE -1 downto 0); -- current counter value
		
		resD : in unsigned(SIZE -1 downto 0) := (others => '0'); -- initial data after reset

		rci : in std_logic := '1'; -- carry input
		rco : out std_logic -- carry output
	);
	end component ud_cnt;

	-- run-once down-counter
	component ro_cnt is
	generic(SIZE : natural := 8);
	port(
		clk : in std_logic; -- master clock
		nReset : in std_logic := '1'; -- asynchronous active low reset
		rst : in std_logic := '0'; -- synchronous active high reset

		cnt_en : in std_logic := '1'; -- count enable
		go : in std_logic; -- load counter and start sequence
		done : out std_logic; -- done counting
		D : in unsigned(SIZE -1 downto 0); -- load counter value
		Q : out unsigned(SIZE -1 downto 0); -- current counter value
		
		ID : in unsigned(SIZE -1 downto 0) := (others => '0') -- initial data after reset
	);
	end component ro_cnt;
end package count;

--
-- general purpose counter
--
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

entity ud_cnt is
	generic(
		SIZE : natural := 8
	);
	port(
		clk : in std_logic; -- master clock
		nReset : in std_logic := '1'; -- asynchronous active low reset
		rst : in std_logic := '0'; -- synchronous active high reset

		cnt_en : in std_logic := '1'; -- count enable
		ud : in std_logic := '0'; -- up / not down
		nld : in std_logic := '1'; -- synchronous active low load
		D : in unsigned(SIZE -1 downto 0); -- load counter value
		Q : out unsigned(SIZE -1 downto 0); -- current counter value
		
		resD : in unsigned(SIZE -1 downto 0) := (others => '0'); -- initial data after reset

		rci : in std_logic := '1'; -- carry input
		rco : out std_logic -- carry output
	);
end entity ud_cnt;

architecture structural of ud_cnt is
	signal Qi : unsigned(SIZE -1 downto 0);
	signal val : unsigned(SIZE downto 0);
begin
	val <= ( ('0' & Qi) + rci) when (ud = '1') else ( ('0' & Qi) - rci);

	regs: process(clk, nReset, resD)
	begin
		if (nReset = '0') then
			Qi <= resD;
		elsif (clk'event and clk = '1') then
			if (rst = '1') then
				Qi <= resD;
			else
				if (nld = '0') then
					Qi <= D;
				elsif (cnt_en = '1') then
					Qi <= val(SIZE -1 downto 0);
				end if;
			end if;
		end if;
	end process regs;

	-- assign outputs
	Q <= Qi;
	rco <= val(SIZE);
end architecture structural;


--
-- run-once down-counter, counts D+1 cycles before generating 'DONE'
--
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

entity ro_cnt is
	generic(SIZE : natural := 8);
	port(
		clk : in std_logic; -- master clock
		nReset : in std_logic := '1'; -- asynchronous active low reset
		rst : in std_logic := '0'; -- synchronous active high reset

		cnt_en : in std_logic := '1'; -- count enable
		go : in std_logic; -- load counter and start sequence
		done : out std_logic; -- done counting
		D : in unsigned(SIZE -1 downto 0); -- load counter value
		Q : out unsigned(SIZE -1 downto 0); -- current counter value
		
		ID : in unsigned(SIZE -1 downto 0) := (others => '0') -- initial data after reset
	);
end entity ro_cnt;

architecture structural of ro_cnt is
	component ud_cnt is
	generic(
		SIZE : natural := 8
	);
	port(
		clk : in std_logic; -- master clock
		nReset : in std_logic := '1'; -- asynchronous active low reset
		rst : in std_logic := '0'; -- synchronous active high reset

		cnt_en : in std_logic := '1'; -- count enable
		ud : in std_logic := '0'; -- up / not down
		nld : in std_logic := '1'; -- synchronous active low load
		D : in unsigned(SIZE -1 downto 0); -- load counter value
		Q : out unsigned(SIZE -1 downto 0); -- current counter value
		
		resD : in unsigned(SIZE -1 downto 0) := (others => '0'); -- initial data after reset

		rci : in std_logic := '1'; -- carry input
		rco : out std_logic -- carry output
	);
	end component ud_cnt;

	signal rci, rco, nld : std_logic;
begin
	gen_ctrl: process(clk, nReset)
	begin
		if (nReset = '0') then
			rci <= '0';
		elsif (clk'event and clk = '1') then
			if (rst = '1') then
				rci <= '0';
			elsif (cnt_en = '1' ) then
				rci <= (go or rci) and not rco;
			end if;
		end if;
	end process;

	nld <= not go;

	-- hookup counter
	cnt : ud_cnt 
		generic map (SIZE => SIZE)
		port map (clk => clk, nReset => nReset, rst => rst, cnt_en => cnt_en, nld => nld, D => D, Q => Q, 
			resD => ID, rci => rci, rco => rco);

	done <= rco;
end architecture structural;

