library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
	 entity VGA_Top is
    Port ( R : out  STD_LOGIC;
           G : out  STD_LOGIC;
           B : out  STD_LOGIC;
           Clk : in  STD_LOGIC;
           HS : out  STD_LOGIC;
           VS : out  STD_LOGIC;
			  button : in  STD_LOGIC;
			  reset : in  STD_LOGIC;
			  LED : out  STD_LOGIC;
			  Enables : out  STD_LOGIC_VECTOR(3 downto 0);
			  Segments : out  STD_LOGIC_VECTOR(6 downto 0);
			  inColor : in  STD_LOGIC_VECTOR (2 downto 0);
			  MoveUp : in  STD_LOGIC;
			  MoveDown : in  STD_LOGIC;
			  MoveLeft : in  STD_LOGIC;
			  MoveRight : in  STD_LOGIC;
			  MoveP1 : in  STD_LOGIC;
			  MoveP2 : in  STD_LOGIC);
end VGA_Top;
architecture Behavioral of VGA_Top is
COMPONENT Debouncer
	PORT(
		Clk : IN std_logic;
		Button : IN std_logic;          
		Dout : OUT std_logic);
END COMPONENT;
COMPONENT Bresenhamer
	PORT(
		X1 : IN std_logic_vector(9 downto 0);
		Y1 : IN std_logic_vector(8 downto 0);
		X2 : IN std_logic_vector(9 downto 0);
		Y2 : IN std_logic_vector(8 downto 0);
		Clk : IN std_logic;
		StartDraw : IN std_logic;          
		WriteEnable : OUT std_logic;
		SS : OUT STD_LOGIC_VECTOR (3 downto 0);
		X : OUT std_logic_vector(9 downto 0);
		Y : OUT std_logic_vector(8 downto 0);
		Reset : in  STD_LOGIC);
END COMPONENT;
Component Synchronizer is
    Port ( R : out  STD_LOGIC;
           G : out  STD_LOGIC;
           B : out  STD_LOGIC;
           HS : out  STD_LOGIC;
           VS : out  STD_LOGIC;
           Clk : in  STD_LOGIC;
			  dataIn : in  STD_LOGIC_VECTOR (2 downto 0);
			  AddressX : out  STD_LOGIC_VECTOR (9 downto 0);
			  AddressY : out  STD_LOGIC_VECTOR (8 downto 0));
end Component;
Component FrameBuffer is
    Port ( inX : in  STD_LOGIC_VECTOR (9 downto 0);
           inY : in  STD_LOGIC_VECTOR (8 downto 0);
           outX : in  STD_LOGIC_VECTOR (9 downto 0);
           outY : in  STD_LOGIC_VECTOR (8 downto 0);
           outColor : out  STD_LOGIC_VECTOR (2 downto 0);
           inColor : in  STD_LOGIC_VECTOR (2 downto 0);
           BufferWrite : in  STD_LOGIC;
           Clk : in  STD_LOGIC);
end Component;
COMPONENT SevenSegment
	PORT(	Clk : IN std_logic;
			data : IN std_logic_vector(15 downto 0);
			Enables : OUT std_logic_vector(3 downto 0);
			Segments : OUT std_logic_vector(6 downto 0));
END COMPONENT;
COMPONENT Pointer
	Generic (initX : STD_LOGIC_VECTOR (9 downto 0);
				initY : STD_LOGIC_VECTOR (8 downto 0));
	PORT(	MoveUp : IN std_logic;
			MoveDown : IN std_logic;
			MoveLeft : IN std_logic;
			MoveRight : IN std_logic;
			Move : IN std_logic;
			Clk : IN std_logic;
			X : OUT std_logic_vector(9 downto 0);
			Y : OUT std_logic_vector(8 downto 0);
			syncX : IN std_logic_vector(9 downto 0);
			syncY : IN std_logic_vector(8 downto 0);
			Here : OUT std_logic);
END COMPONENT;
COMPONENT FreqDiv
	PORT(	Clk : IN std_logic;          
			Clk2 : OUT std_logic);
END COMPONENT;
signal Adx,GPU_X : STD_LOGIC_VECTOR (9 downto 0);
signal Ady,GPU_Y : STD_LOGIC_VECTOR (8 downto 0);
signal data : STD_LOGIC_VECTOR (2 downto 0);
signal GIM : STD_LOGIC_VECTOR (22 downto 0);
signal GPU_COLOR_TO_BUFFER : STD_LOGIC_VECTOR (2 downto 0);
signal BufferWrite : STD_LOGIC;
signal Dout : STD_LOGIC;
signal SS : STD_LOGIC_VECTOR (3 downto 0);
signal Clk2 : STD_LOGIC;
signal P1Region,p2Region : STD_LOGIC;
signal Rt,Gt,Bt : STD_LOGIC;
signal X1,X2 : STD_LOGIC_VECTOR (9 downto 0);
signal Y1,Y2 : STD_LOGIC_VECTOR (8 downto 0);
begin
ins_FrameBuffer : FrameBuffer PORT MAP (
	inX => GPU_X,
   inY => GPU_Y,
   outX => Adx,
   outY => Ady,
   outColor => data,
   inColor => inColor,
   BufferWrite => BufferWrite,
   Clk => Clk);
ins_Synchronizer : Synchronizer PORT MAP (
	 R => Rt,
    G => Gt,
    B => Bt,
    HS => HS,
    VS => VS,
    Clk => Clk,
	 dataIn => data,
	 AddressX => Adx,
	 AddressY => Ady);
Inst_Debouncer: Debouncer PORT MAP(
	Clk => Clk,
	Button => Button,
	Dout => Dout);
Inst_Bresenhamer: Bresenhamer PORT MAP(
	WriteEnable => BufferWrite,
	X => GPU_X,
	Y => GPU_Y,
	X1 => X1,
	Y1 => Y1,
	X2 => X2,
	Y2 => Y2,
	Clk => Clk,
	SS => SS,
	Reset => reset,
	StartDraw => Dout);
	
LED <= BufferWrite;

R <= Rt when (P1Region='0' and P2Region='0') else not Rt;

G <= Gt when (P1Region='0' and P2Region='0') else not Gt;

B <= Bt when (P1Region='0' and P2Region='0') else not Bt;
	 
Inst_SevenSegment: SevenSegment PORT MAP(
	Clk => Clk,
	Enables => Enables,
	Segments => Segments,
	data(3 downto 0) => SS,
	data(15 downto 4) => "000000000000");
		
Inst_Pointer1: Pointer
	GENERIC MAP (initX => "0000000100",
					 initY => "011110000")
	PORT MAP(
	MoveUp => MoveUp,
	MoveDown => MoveDown,
	MoveLeft => MoveLeft,
	MoveRight => MoveRight,
	Move => MoveP1,
	Clk => Clk2,
	Here => P1Region,
	X => X1,
	Y => Y1,
	syncX => Adx,
	syncY => Ady);

Inst_FreqDiv: FreqDiv PORT MAP(
	Clk => Clk,
	Clk2 => Clk2);

Inst_Pointer2: Pointer
	GENERIC MAP (InitX => "1001111000",
					 InitY => "011110000")
	PORT MAP(
	MoveUp => MoveUp,
	MoveDown => MoveDown,
	MoveLeft => MoveLeft,
	MoveRight => MoveRight,
	Move => MoveP2,
	Clk => Clk2,
	Here => P2Region,
	X => X2,
	Y => Y2,
	syncX => Adx,
	syncY => Ady);

end Behavioral;