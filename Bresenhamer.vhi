
-- VHDL Instantiation Created from source file Bresenhamer.vhd -- 09:50:52 05/14/2011
--
-- Notes: 
-- 1) This instantiation template has been automatically generated using types
-- std_logic and std_logic_vector for the ports of the instantiated module
-- 2) To use this template to instantiate this entity, cut-and-paste and then edit

	COMPONENT Bresenhamer
	PORT(
		X1 : IN std_logic_vector(9 downto 0);
		Y1 : IN std_logic_vector(8 downto 0);
		X2 : IN std_logic_vector(9 downto 0);
		Y2 : IN std_logic_vector(8 downto 0);
		Clk : IN std_logic;
		StartDraw : IN std_logic;          
		WriteEnable : OUT std_logic;
		X : OUT std_logic_vector(9 downto 0);
		Y : OUT std_logic_vector(8 downto 0);
		SS : OUT std_logic_vector(3 downto 0)
		);
	END COMPONENT;

	Inst_Bresenhamer: Bresenhamer PORT MAP(
		WriteEnable => ,
		X => ,
		Y => ,
		X1 => ,
		Y1 => ,
		X2 => ,
		Y2 => ,
		SS => ,
		Clk => ,
		StartDraw => 
	);


