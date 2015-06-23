library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;
use work.all;

library std;
use std.textio.all;

entity tb is
	generic (
		INFILE:		string := "sim/vectors.txt";
		OUTFILE: 	string := "sim/results.txt"
	);
end entity tb;

architecture post_syn of tb is

	constant clock_period:time:=9 ns;
	constant input_hold:time:=20 ps;

	file vectorfile	: text open read_mode is INFILE;
	file resfile	: text open write_mode is OUTFILE;


	signal clk	: std_ulogic:='0';
	signal res	: std_ulogic:='0';
	signal ARG	: unsigned(31 downto 0) := (others=>'0');
	signal Z	: unsigned(31 downto 0);

	component square_root is
		generic(
			WIDTH	: positive := 32
		);
		port(
			clk	: in std_logic;
			res	: in std_logic;
			ARG	: in unsigned (WIDTH-1 downto 0); -- must be between 0.5 and 1
			Z	: out unsigned (WIDTH-1 downto 0)
		);
	end component;

begin
	-- clock
	clk<= not clk after clock_period/2;

	-- reset
	reset_proc: process is begin
		res <= '0';
		wait for 10 * clock_period;
		res <= '1' after input_hold;
		wait;
	end process reset_proc;


	-- DUT component instantiation (post synthesis)
	dut: square_root
		generic map(
			WIDTH=>32
		)
		port map(
			clk=>clk,
			res=>res,
			ARG=>ARG,
			Z=>Z
		);

	-- stimuli generation
	stimuli: process
		variable debugline	: line;
		variable vectorline	: line;
		variable vectorvalid	: boolean;
		variable ARG_read	: bit_vector(31 downto 0);
		variable space		: character;
	begin
		ARG <= (others => '0');

		--after reset phase
		wait until res = '1';
		report "Reset deasserted" severity note;

		--wait other 10 clock cycles (just to be sure)
		for i in 0 to 10 loop
			wait until clk = '1';
		end loop;

		--cycle through vector file
		while not endfile (vectorfile) loop

			readline(vectorfile, vectorline);

			read(vectorline, ARG_read, good => vectorvalid);
			--debug: copy to stdout
			--write(debugline, a_read);
			--writeline(output, debugline);

			--skip if comment
			next when not vectorvalid;

			-- put inputs after a delay to avoid hold violations on input FFs
			wait until clk = '1';
			ARG <= unsigned(to_stdlogicvector(ARG_read)) after input_hold;

		end loop;

		--let last clock cycle terminate
		wait until clk = '1';

		--let other 5 clock cycles terminate (to write last output file lines)
		for i in 0 to 5 loop
			wait until clk = '1';
		end loop;

		--force simulation termination
		assert false report "Simulation completed (not a real failure)" severity failure;

		--never reached
		wait;

	end process stimuli;

	-- output evaluation
	eval: process

		variable outline	: line;
		variable Z_res		: bit_vector(31 downto 0);
		variable space		: character := ' ';

	begin

		--wait until reset deasserted
		wait until res = '1';

		--wait other 15 clock cycles (10 before input starts plus pipeline length)
		for i in 0 to 15 loop
			wait until clk = '1';
		end loop;

		while true loop

			-- clock cycle
			wait until clk = '1';

			Z_res := to_bitvector(std_logic_vector(Z));

			-- write log to output file
			write(outline, Z_res);
			writeline(resfile, outline);

		end loop;

	end process eval;

end architecture post_syn;
