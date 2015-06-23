
-- VHDL Instantiation Created from source file Pointer.vhd -- 09:51:32 05/14/2011
--
-- Notes: 
-- 1) This instantiation template has been automatically generated using types
-- std_logic and std_logic_vector for the ports of the instantiated module
-- 2) To use this template to instantiate this entity, cut-and-paste and then edit

	COMPONENT Pointer
	PORT(
		MoveUp : IN std_logic;
		MoveDown : IN std_logic;
		MoveLeft : IN std_logic;
		MoveRight : IN std_logic;
		Move : IN std_logic;
		Clk : IN std_logic;
		syncX : IN std_logic_vector(9 downto 0);
		syncY : IN std_logic_vector(8 downto 0);          
		Here : OUT std_logic
		);
	END COMPONENT;

	Inst_Pointer: Pointer PORT MAP(
		MoveUp => ,
		MoveDown => ,
		MoveLeft => ,
		MoveRight => ,
		Move => ,
		Clk => ,
		Here => ,
		syncX => ,
		syncY => 
	);


