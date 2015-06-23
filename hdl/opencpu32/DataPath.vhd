--! @file
--! @brief DataPath http://en.wikipedia.org/wiki/Datapath

--! Use standard library and import the packages (std_logic_1164,std_logic_unsigned,std_logic_arith)
library IEEE;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

--! Use CPU Definitions package
use work.pkgOpenCPU32.all;

--! A datapath is a collection of functional units, such as arithmetic logic units or multipliers, that perform data processing operations.\n
--! Most central processing units consist of a datapath and a control unit, with a large part of the control unit dedicated to 
--! regulating the interaction between the datapath and main memory.

--! The purpose of datapaths is to provide routes for data to travel between functional units.
entity DataPath is
    generic (n : integer := nBits - 1);									--! Generic value (Used to easily change the size of the Alu on the package)
	 Port ( inputMm : in  STD_LOGIC_VECTOR (n downto 0);    			--! Input of Datapath from main memory       
			  inputImm : in  STD_LOGIC_VECTOR (n downto 0);    		--! Input of Datapath from imediate value (instructions...)
			  clk : in  STD_LOGIC;												--! Clock signal
           outEn : in  typeEnDis;											--! Enable/Disable datapath output
           aluOp : in  aluOps;												--! Alu operations
           muxSel : in  dpMuxInputs;										--! Select inputs from dataPath(Memory,Imediate,RegisterFile,Alu)
			  muxRegFile : in dpMuxAluIn;										--! Select Alu InputA (Memory,Imediate,RegFileA)
           regFileWriteAddr : in  generalRegisters;					--! General register write address
           regFileWriteEn : in  STD_LOGIC;								--! RegisterFile write enable signal
           regFileReadAddrA : in  generalRegisters;					--! General register read address (PortA)
           regFileReadAddrB : in  generalRegisters;					--! General register read address (PortB)
           regFileEnA : in  STD_LOGIC;										--! Enable RegisterFile PortA
           regFileEnB : in  STD_LOGIC;										--! Enable RegisterFile PortB
			  outputDp : out  STD_LOGIC_VECTOR (n downto 0);			--! DataPath Output
           dpFlags : out  STD_LOGIC_VECTOR (2 downto 0));			--! Alu Flags
end DataPath;

--! @brief DataPath http://en.wikipedia.org/wiki/Datapath
--! @details This description will also show how to instantiate components(Alu, RegisterFile, Multiplexer) on your design
architecture Behavioral of DataPath is

--! Component declaration to instantiate the Multiplexer circuit
COMPONENT Multiplexer4_1
	generic (n : integer := nBits - 1);					--! Generic value (Used to easily change the size of the Alu on the package)
	Port ( A   : in  STD_LOGIC_VECTOR (n downto 0);	--! First Input
		  B   : in  STD_LOGIC_VECTOR (n downto 0);	--! Second Input
		  C   : in  STD_LOGIC_VECTOR (n downto 0);	--! Third Input
		  D   : in  STD_LOGIC_VECTOR (n downto 0);	--! Forth Input
		  E   : in  STD_LOGIC_VECTOR (n downto 0);	--! Fifth Input
        sel : in  dpMuxInputs;							--! Select inputs (1, 2, 3, 4, 5)
		  S   : out  STD_LOGIC_VECTOR (n downto 0));	--! Mux Output
END COMPONENT;

--! Component declaration to instantiate the Multiplexer3_1 circuit
COMPONENT Multiplexer3_1 is
    generic (n : integer := nBits - 1);					--! Generic value (Used to easily change the size of the Alu on the package)
	 Port ( A : in  STD_LOGIC_VECTOR (n downto 0);		--! First Input
           B : in  STD_LOGIC_VECTOR (n downto 0);		--! Second Input
           C : in  STD_LOGIC_VECTOR (n downto 0);		--! Third Input
           sel : in dpMuxAluIn;								--! Select inputs (fromMemory, fromImediate, fromRegFileA)
           S : out  STD_LOGIC_VECTOR (n downto 0));	--! Mux Output
end COMPONENT;

--! Component declaration to instantiate the Alu circuit
COMPONENT Alu
	generic (n : integer := nBits - 1);						--! Generic value (Used to easily change the size of the Alu on the package)
	Port ( A : in  STD_LOGIC_VECTOR (n downto 0);		--! Alu Operand 1
		  B : in  STD_LOGIC_VECTOR (n downto 0);			--! Alu Operand 2
		  S : out  STD_LOGIC_VECTOR (n downto 0);			--! Alu Output
		  flagsOut : out STD_LOGIC_VECTOR(2 downto 0);	--! Flags from current operation
		  sel : in  aluOps);										--! Select operation
END COMPONENT;

--! Component declaration to instantiate the testRegisterFile circuit
COMPONENT RegisterFile
	generic (n : integer := nBits - 1);						--! Generic value (Used to easily change the size of the registers)
	Port ( clk : in  STD_LOGIC;								--! Clock signal
		  writeEn : in  STD_LOGIC;								--! Write enable
		  writeAddr : in  generalRegisters;					--! Write Adress
		  input : in  STD_LOGIC_VECTOR (n downto 0);		--! Input 
		  Read_A_En : in  STD_LOGIC;							--! Enable read A
		  Read_A_Addr : in  generalRegisters;				--! Read A adress
		  Read_B_En : in  STD_LOGIC;							--! Enable read A
		  Read_B_Addr : in  generalRegisters;  			--! Read B adress
		  A_Out : out  STD_LOGIC_VECTOR (n downto 0);	--! Output A
		  B_Out : out  STD_LOGIC_VECTOR (n downto 0));	--! Output B
END COMPONENT;

COMPONENT TriStateBuffer
	generic (n : integer := nBits - 1);				--! Generic value (Used to easily change the size of the Alu on the package)
	PORT(         
		A : IN  std_logic_vector(n downto 0);		--! Buffer Input
		sel : IN  typeEnDis;								--! Enable or Disable the output
		S : OUT  std_logic_vector(n downto 0)		--! Enable or Disable the output
	  );
END COMPONENT;

-- Signals that will connect the various components from the DataPath
signal regFilePortA : STD_LOGIC_VECTOR (n downto 0);
signal regFilePortB : STD_LOGIC_VECTOR (n downto 0);
signal aluOut 		  : STD_LOGIC_VECTOR (n downto 0);
signal muxOut 		  : STD_LOGIC_VECTOR (n downto 0);
signal muxOutReg	  : STD_LOGIC_VECTOR (n downto 0);
begin
	--! Instantiate Multiplexer 5:1
   uMux: Multiplexer4_1 PORT MAP (
          A => inputMm,
          B => inputImm,
			 C => regFilePortA,
			 D => regFilePortB,
			 E => aluOut,
          sel => muxSel,
          S => muxOut
        );
	
	--! Instantiate Multiplexer 5:1
   uMux2: Multiplexer3_1 PORT MAP (
          A => inputMm,
          B => inputImm,
			 C => regFilePortA,			 
          sel => muxRegFile,
          S => muxOutReg
        );
	
	--! Instantiate the Unit Under Test (Alu) (Doxygen bug if it's not commented!)
   uAlu: Alu PORT MAP (
          A => muxOutReg,
          B => regFilePortB,
          S => aluOut,
			 flagsOut => dpFlags,
          sel => aluOp
        );
	
	--! Instantiate the Unit Under Test (RegisterFile) (Doxygen bug if it's not commented!)
   uRegisterFile: RegisterFile PORT MAP (
          clk => clk,
          writeEn => regFileWriteEn,
          writeAddr => regFileWriteAddr,
          input => muxOut,
          Read_A_En => regFileEnA,
          Read_A_Addr => regFileReadAddrA,
          Read_B_En => regFileEnB,
          Read_B_Addr => regFileReadAddrB,
          A_Out => regFilePortA,
          B_Out => regFilePortB
        );
	
	--!Instantiate the Unit Under Test (Multiplexer2_1) (Doxygen bug if it's not commented!)
   uTriState: TriStateBuffer PORT MAP (
          A => muxOut,
          sel => outEn,
          S => outputDp
        );

end Behavioral;

