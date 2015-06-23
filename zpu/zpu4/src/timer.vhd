library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
 
entity timer is
  port(
       clk              : in std_logic;
		 areset				: in std_logic;
		 we					: in std_logic;
		 din					: in std_logic_vector(7 downto 0);
		 adr					: in std_logic_vector(2 downto 0);
		 dout					: out std_logic_vector(7 downto 0));
end timer;
   
   
architecture behave of timer is

signal	sample	: std_logic;
signal	reset		: std_logic;


signal	cnt		: unsigned(63 downto 0);
signal	cnt_smp	: std_logic_vector(63 downto 0);

begin

	reset <= '1' when (we = '1' and din(0) = '1') else '0';
	sample <= '1' when (we = '1' and din(1) = '1') else '0';

	process(clk, areset)	-- Carry generation
	begin
		if areset = '1' then
			cnt <= (others => '0');
			cnt_smp <= (others => '0');
		elsif (clk'event and clk = '1') then
			cnt <= cnt + 1;
			if sample = '1' then
--				report "sampling" severity failure;
				cnt_smp <= std_logic_vector(cnt);
			end if;
		end if;
	end process;
	
	
	process(cnt_smp, adr)
	begin
		case adr is
			when "000"	=> dout <= cnt_smp(7 downto 0);
			when "001"	=> dout <= cnt_smp(15 downto 8);
			when "010"	=> dout <= cnt_smp(23 downto 16);
			when "011"	=> dout <= cnt_smp(31 downto 24);
			when "100"	=> dout <= cnt_smp(39 downto 32);
			when "101"	=> dout <= cnt_smp(47 downto 40);
			when "110"	=> dout <= cnt_smp(55 downto 48);
			when others	=> dout <= cnt_smp(63 downto 56);
		end case;
	end process;
	

end behave;
 
