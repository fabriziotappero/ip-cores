
-- VHDL Instantiation Created from source file SevenSegment.vhd -- 20:17:11 05/13/2011
--
-- Notes: 
-- 1) This instantiation template has been automatically generated using types
-- std_logic and std_logic_vector for the ports of the instantiated module
-- 2) To use this template to instantiate this entity, cut-and-paste and then edit

	COMPONENT SevenSegment
	PORT(
		Clk : IN std_logic;
		data : IN std_logic_vector(7 downto 0);          
		Enables : OUT std_logic_vector(3 downto 0);
		Segments : OUT std_logic_vector(6 downto 0)
		);
	END COMPONENT;

	Inst_SevenSegment: SevenSegment PORT MAP(
		Clk => ,
		Enables => ,
		Segments => ,
		data => 
	);


