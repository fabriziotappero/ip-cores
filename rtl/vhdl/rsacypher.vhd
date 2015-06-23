library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

--  Uncomment the following lines to use the declarations that are
--  provided for instantiating Xilinx primitive components.
--library UNISIM;
--use UNISIM.VComponents.all;
																	
entity RSACypher is
	Generic (KEYSIZE: integer := 1024);
    Port (indata: in std_logic_vector(KEYSIZE-1 downto 0);
	 		 inExp: in std_logic_vector(KEYSIZE-1 downto 0);
	 		 inMod: in std_logic_vector(KEYSIZE-1 downto 0);
	 		 cypher: out std_logic_vector(KEYSIZE-1 downto 0);
			 clk: in std_logic;
			 ds: in std_logic;
			 reset: in std_logic;
			 ready: out std_logic
			 );
end RSACypher;

architecture Behavioral of RSACypher is
attribute keep: string;

component modmult32 is
	Generic (MPWID: integer);
    Port ( mpand : in std_logic_vector(MPWID-1 downto 0);
           mplier : in std_logic_vector(MPWID-1 downto 0);
           modulus : in std_logic_vector(MPWID-1 downto 0);
           product : out std_logic_vector(MPWID-1 downto 0);
           clk : in std_logic;
           ds : in std_logic;
			  reset : in std_logic;
			  ready: out std_logic);
end component;

--signal message: std_logic_vector(KEYSIZE-1 downto 0);
--signal exponent: std_logic_vector(KEYSIZE-1 downto 0);
signal modreg: std_logic_vector(KEYSIZE-1 downto 0);
signal root: std_logic_vector(KEYSIZE-1 downto 0);
signal square: std_logic_vector(KEYSIZE-1 downto 0);
signal sqrin: std_logic_vector(KEYSIZE-1 downto 0);
signal tempin: std_logic_vector(KEYSIZE-1 downto 0);
signal tempout: std_logic_vector(KEYSIZE-1 downto 0);
--signal cypher: std_logic_vector(KEYSIZE-1 downto 0);
signal count: std_logic_vector(KEYSIZE-1 downto 0);

signal multrdy, sqrrdy, bothrdy: std_logic;
signal multgo, sqrgo: std_logic;
--signal multds, sqrds: std_logic;
signal done: std_logic;

attribute keep of multrdy: signal is "true";
attribute keep of sqrrdy: signal is "true";
attribute keep of bothrdy: signal is "true";
attribute keep of multgo: signal is "true";
attribute keep of sqrgo: signal is "true";


begin

	ready <= done;
	bothrdy <= multrdy and sqrrdy;

	modmult: modmult32
	Generic Map(MPWID => KEYSIZE)
	Port Map(mpand => tempin,
				mplier => sqrin,
				modulus => modreg,
				product => tempout,
				clk => clk,
				ds => multgo,
				reset => reset,
				ready => multrdy);

	modsqr: modmult32
	Generic Map(MPWID => KEYSIZE)
	Port Map(mpand => root,
				mplier => root,
				modulus => modreg,
				product => square,
				clk => clk,
				ds => multgo,
				reset => reset,
				ready =>sqrrdy);

	mngcount: process (clk, reset, done, ds, count, bothrdy) is
	begin
	-- handles DONE and COUNT signals
		
		if reset = '1' then
			count <= (others => '0');
			done <= '1';
		elsif rising_edge(clk) then
			if done = '1' then
				if ds = '1' then
-- first time through
					count <= '0' & inExp(KEYSIZE-1 downto 1);
					done <= '0';
				end if;
-- after first time
			elsif count = 0 then
				if bothrdy = '1' and multgo = '0' then
					cypher <= tempout;		-- set output value
--				if ds = '0' then
					done <= '1';
				end if;
--			elsif sqrrdy = '1' and multrdy = '1' then
			elsif bothrdy = '1' then
				if multgo = '0' then
					count <= '0' & count(KEYSIZE-1 downto 1);
				end if;
			end if;
		end if;

	end process mngcount;


	setupsqr: process (clk, reset, done, ds) is
	begin
		
		if reset = '1' then
			root <= (others => '0');
			modreg <= (others => '0');
		elsif rising_edge(clk) then
			if done = '1' then
				if ds = '1' then
---- first time through
					modreg <= inMod;
					root <= indata;
				end if;
---- after first time
			else
				root <= square;
			end if;
		end if;

	end process setupsqr;

	setupmult: process (clk, reset, done, ds) is
	begin
		
		if reset = '1' then
			tempin <= (others => '0');
			sqrin <= (others => '0');
			modreg <= (others => '0');
		elsif rising_edge(clk) then
			if done = '1' then
				if ds = '1' then
-- first time through
					if inExp(0) = '1' then
						tempin <= indata;
					else
						tempin(KEYSIZE-1 downto 1) <= (others => '0');
						tempin(0) <= '1';
					end if;
					modreg <= inMod;
					sqrin(KEYSIZE-1 downto 1) <= (others => '0');
					sqrin(0) <= '1';
				end if;
-- after first time
			else
				tempin <= tempout;
				if count(0) = '1' then
					sqrin <= square;
				else
					sqrin(KEYSIZE-1 downto 1) <= (others => '0');
					sqrin(0) <= '1';
				end if;
			end if;
		end if;

	end process setupmult;

	crypto: process (clk, reset, done, ds, count, bothrdy) is
	begin
		
		if reset = '1' then
			multgo <= '0';
--			sqrgo <= '0';
		elsif rising_edge(clk) then
			if done = '1' then
				if ds = '1' then
-- first time through
					multgo <= '1';
--					sqrgo <= '1';
				end if;
-- after first time
			elsif count /= 0 then
				if bothrdy = '1' then
					multgo <= '1';
--					sqrgo <= '1';
				end if;
--			else
			end if;
				if multgo = '1' then
					multgo <= '0';
				end if;
--				if sqrgo = '1' then
--					sqrgo <= '0';
--				end if;
--			end if;
		end if;

	end process crypto;

end Behavioral;
