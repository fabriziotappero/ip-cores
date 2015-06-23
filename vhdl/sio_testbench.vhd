-- VHDL Test Bench for jc2_top design functional and timing simulation

LIBRARY  IEEE;
USE IEEE.std_logic_1164.all;

--use work.types.all;

ENTITY sio_testbench IS
END sio_testbench;

ARCHITECTURE sio_testbench_arch OF sio_testbench IS
	COMPONENT mysio
		Port ( gclk : in  STD_LOGIC;
           reset : in  STD_LOGIC;
			  
			  simulation : in std_logic;

           rx : in  STD_LOGIC;
           tx : out  STD_LOGIC;
			  
			  test : out std_logic_vector(7 downto 0)
			  );
	END COMPONENT;


	SIGNAL simulation : STD_LOGIC := '1';
	SIGNAL gclk : STD_LOGIC := '0';
	SIGNAL reset : STD_LOGIC := '0';
	signal rx : STD_LOGIC := '0'; 

BEGIN
	UUT : mysio
	PORT MAP (
		gclk => gclk,
		reset => reset,
		rx => rx,
		simulation => simulation
	);
	
	simulation <= '1' after 0 ns;
	reset <= '1' after 310 ns;
	gclk   <= not gclk after 10 ns;

END sio_testbench_arch;

CONFIGURATION sio_testbench_cfg OF sio_testbench IS
	FOR sio_testbench_arch
	END FOR;
END sio_testbench_cfg;
