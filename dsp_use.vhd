-- High load test project.
-- Alexey Fedorov, 2014
-- email: FPGA@nerudo.com
--
-- It implements 7 multipliers

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity dsp_use is
	generic (
		DATA_WIDTH  : positive := 16
		);
	port
	(
		clk	: in  std_logic;
		datain: in std_logic_vector(DATA_WIDTH-1 downto 0);
		dataout: out std_logic_vector(DATA_WIDTH-1 downto 0)
	);
end dsp_use;

architecture rtl of dsp_use is
type TShReg is array (0 to 7) of signed(DATA_WIDTH-1 downto 0);
signal ShReg_1, ShReg_1r, ShReg_2, ShReg_2r, ShReg_2rr, ShReg_3, ShReg_3r, ShReg_3rr, ShReg_4 : TShReg := (others => (others => '0'));
begin

process(clk)
variable product : signed(2*DATA_WIDTH-1 downto 0); 
begin
	if rising_edge(clk) then
		ShReg_1(0) <= signed(datain);
		ShReg_1(1 to 7) <= ShReg_1(0 to 6);

		ShReg_1r  <= ShReg_1;
		
		for i in 0 to 3 loop
			product := ShReg_1r(2*i) * ShReg_1r(2*i+1);
			ShReg_2(i) <= product(DATA_WIDTH-1 downto 0);
		end loop;
		
		ShReg_2r  <= ShReg_2;
		ShReg_2rr <= ShReg_2r;
		
		for i in 0 to 1 loop
			product := ShReg_2rr(2*i) * ShReg_2rr(2*i+1);
			ShReg_3(i) <= product(DATA_WIDTH-1 downto 0);
		end loop;
		
		ShReg_3r <= ShReg_3;
		ShReg_3rr <= ShReg_3r;

		product := ShReg_3rr(0) * ShReg_3rr(1);
		ShReg_4(0) <= product(DATA_WIDTH-1 downto 0);
		
		dataout <= std_logic_vector(ShReg_4(0));
	end if;

end process;

end rtl;