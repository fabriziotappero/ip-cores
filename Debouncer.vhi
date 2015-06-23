
-- VHDL Instantiation Created from source file Debouncer.vhd -- 00:02:30 05/14/2011
--
-- Notes: 
-- 1) This instantiation template has been automatically generated using types
-- std_logic and std_logic_vector for the ports of the instantiated module
-- 2) To use this template to instantiate this entity, cut-and-paste and then edit

	COMPONENT Debouncer
	PORT(
		Clk : IN std_logic;
		Button : IN std_logic;          
		Dout : OUT std_logic
		);
	END COMPONENT;

	Inst_Debouncer: Debouncer PORT MAP(
		Clk => ,
		Button => ,
		Dout => 
	);


