entity booth_multiplier_testbench is
end entity;


architecture booth_multiplier_testbench_arch of booth_multiplier_testbench is

component booth_multiplier IS 
    GENERIC(k : POSITIVE := 31); --input number word length less one 
    PORT(multiplicand, multiplier : IN BIT_VECTOR(k DOWNTO 0); 
       clock : IN BIT; product : INOUT BIT_VECTOR((2*k + 1) DOWNTO 0)); 
END component; 


--signals here

signal multiplicand_tb : bit_vector(31 downto 0);
signal multiplier_tb : bit_vector(31 downto 0);
signal product_tb : bit_vector((2*31+1) downto 0);
signal clk_tb : bit;
signal clk_tb_delayed : bit;

begin
	
	
	
DUT : booth_multiplier
generic map(k => 31)
port map(
multiplicand => multiplicand_tb,
multiplier => multiplier_tb,
product => product_tb,
clock => clk_tb_delayed
);



STIM : process is 

begin
	
	multiplicand_tb <= x"10000000";
	multiplier_tb <= x"10000001";

	
--	multiplicand_tb <= x"00000001";
--	multiplier_tb <= x"00000001";

	--multiplicand_tb <= x"0000A50D";
--	multiplier_tb <= x"6197ead4";
wait;
end process;










DRIVE_CLOCK:process
begin 
	wait for 50 ns;
	clk_tb <= not clk_tb;
	clk_tb_delayed <= not clk_tb_delayed after 1 ns;
end process;




	
	
end booth_multiplier_testbench_arch;
