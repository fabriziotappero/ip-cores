
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;


entity tb_grain128 is
generic (
	DEBUG : boolean := false;
	FAST : boolean := false
);
end entity;


architecture test of tb_grain128 is

-- some testvectors:
constant GRAIN_KEY1 : unsigned(127 downto 0) := (others => '0');
constant GRAIN_IV1  : unsigned( 95 downto 0) := (others => '0');
constant GRAIN_KS1  : unsigned(127 downto 0) := x"0fd9deefeb6fad437bf43fce35849cfe";

constant GRAIN_KEY2 : unsigned(127 downto 0) := x"0123456789abcdef123456789abcdef0";
constant GRAIN_IV2  : unsigned( 95 downto 0) := x"0123456789abcdef12345678";
constant GRAIN_KS2  : unsigned(127 downto 0) := x"db032aff3788498b57cb894fffb6bb96";


-- DUT signal
signal clk, clken, areset : std_logic;
signal key_in, iv_in : std_logic;
signal key : unsigned(127 downto 0);
signal iv : unsigned(95 downto 0);
signal init, keystream, keystream_valid : std_logic;

-- monitor the output:
signal key_memory : unsigned(127 downto 0);
signal key_count : integer;

begin
	
	
	-- the one and only, the DUT
	DUT: entity work.grain128
	generic map ( 
		DEBUG => DEBUG,
		FAST  => FAST
	)
	port map (
		CLK_I    => clk,
		CLKEN_I  => clken,
		ARESET_I => areset,
	
		KEY_I  => key_in,
		IV_I   => iv_in,
		INIT_I => init,
		
		KEYSTREAM_O => keystream,
		KEYSTREAM_VALID_O => keystream_valid
	);
	
	-- clock generator:
	clkgen_proc: process
	begin
		clk <= '0'; wait for 10 ns;
		clk <= '1'; wait for 10 ns;
	end process;
	
	-- dummy clock enable: every fourth cycle
	clken_proc: process
	begin
		clken <= '0';
		wait until rising_edge(clk);
		wait until rising_edge(clk);
		wait until rising_edge(clk);
		
		clken <= '1';		
		wait until rising_edge(clk);	
	end process;
		
	
	-- output monitor:
	mon_proc: process(clk, areset)
	begin
		if areset = '1' then
			key_memory <= (others => 'X');
			key_count <= 0;
		elsif rising_edge(clk) then
			if clken = '1' then
				if keystream_valid = '1' then
					key_count <= key_count + 1;					
					key_memory <= key_memory(key_memory'high-1 downto 0) & keystream;
				else				
					key_memory <= (others => 'X');
					key_count <= 0;
				end if;
				
			end if;
		end if;
	end process;
	
	
	
	
	-- this process will do all the testing
	tester_proc: process
	
		-- reset everything
		procedure do_reset is
		begin	  
			key_in <= 'X';
			iv_in <= 'X';
			init <= '0';
			
			areset <= '1';
			wait for 100 ns;
			
			areset <= '0';			
		end procedure;
		
		
		-- initialize grain with key and IV
		procedure do_init is
		begin
			wait until rising_edge(clk) and clken = '1';
			init <= '1';
			
			wait until rising_edge(clk) and clken = '1';
			init <= '0';
			
			for i in key'range loop
				key_in <= key(key'high);
				iv_in  <= iv(iv'high);
				key <= key rol 1;
				iv  <= iv rol 1;			
				wait until rising_edge(clk) and clken = '1';				
			end loop;		
		end procedure;			
		
	begin
	
		-- 1. start with a reset:
		do_reset;
		
		-- 2. inject key and IV
		key <= GRAIN_KEY1;
		iv  <= GRAIN_IV1;
		do_init;
		
		
		-- 3. verify output:
		wait on clk until key_count = 128;
		assert key_memory = GRAIN_KS1
			report "incorrect output with IV = 0 and KEY = 0"
			severity failure;
			
			
			
		-- 4. try the other testvector
		-- do_reset;
		key <= GRAIN_KEY2;
		iv  <= GRAIN_IV2;
		do_init;
		
		wait on clk until key_count = 128;
		assert 
			key_memory = GRAIN_KS2
			report "incorrect output with IV = 0123.. and KEY = 0123.."
			severity failure;


		
		-- done:
		report "ALL DONE" severity failure;
		wait;
	end process;
	


end test;

-- asim tb_grain128 ; wave /DUT/* ; run 100 us
