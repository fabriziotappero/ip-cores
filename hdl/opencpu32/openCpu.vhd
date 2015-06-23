--! @file
--! @brief Arithmetic logic unit http://en.wikipedia.org/wiki/Arithmetic_logic_unit

--! Use standard library and import the packages (std_logic_1164,std_logic_unsigned,std_logic_arith)
library IEEE;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

--! Use CPU Definitions package
use work.pkgOpenCPU32.all;

--! Cpu top level file

--! Include the Control Unit and datapath
entity openCpu is
    generic (n : integer := nBits - 1);									--! Generic value (Used to easily change the size of the Alu on the package)
	 Port ( rst : in  STD_LOGIC;												--! Reset signal
           clk : in  STD_LOGIC;												--! Clock signal
           mem_rd : out  STD_LOGIC;											--! Main memory Read enable
           mem_rd_addr : out  STD_LOGIC_VECTOR (n downto 0);		--! Main memory Read address
           mem_wr : out  STD_LOGIC;											--! Main memory Write enable
           mem_wr_addr : out  STD_LOGIC_VECTOR (n downto 0);		--! Main memory Write address
			  mem_data_in : in  STD_LOGIC_VECTOR (n downto 0);			--! Data comming from main memory
			  mem_data_out : out  STD_LOGIC_VECTOR (n downto 0)		--! Data to main memory
			  );
end openCpu;

--! @brief Cpu http://en.wikipedia.org/wiki/Central_processing_unit
--! @details This description will instantiate the components ControlUnit and DataPath
architecture Behavioral of openCpu is
COMPONENT DataPath is
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
           dpFlags : out  STD_LOGIC_VECTOR (2 downto 0));
end COMPONENT;

COMPONENT ControlUnit is
    generic (n : integer := nBits - 1);									--! Generic value (Used to easily change the size of the Alu on the package)
	 Port ( reset : in  STD_LOGIC;
           clk : in  STD_LOGIC;												--! Main system clock
           FlagsDp : in  STD_LOGIC_VECTOR (2 downto 0);				--! Flags comming from the Datapath
           DataDp : in  STD_LOGIC_VECTOR (n downto 0);				--! Data comming from the Datapath
			  outEnDp : out  typeEnDis;										--! Enable/Disable datapath output
           MuxDp : out  dpMuxInputs;										--! Select on datapath data from (Memory, Imediate, RegFileA, RegFileB, AluOut)
			  MuxRegDp : out dpMuxAluIn;										--! Select Alu InputA (Memory,Imediate,RegFileA)
           ImmDp : out  STD_LOGIC_VECTOR (n downto 0);				--! Imediate value passed to the Datapath
           DpAluOp : out  aluOps;											--! Alu operations
			  DpRegFileWriteAddr : out  generalRegisters;				--! General register address to write
           DpRegFileWriteEn : out  STD_LOGIC;							--! Enable register write
           DpRegFileReadAddrA : out  generalRegisters;				--! General register address to read
           DpRegFileReadAddrB : out  generalRegisters;				--! General register address to read
           DpRegFileReadEnA : out  STD_LOGIC;							--! Enable register read (PortA)
           DpRegFileReadEnB : out  STD_LOGIC;							--! Enable register read (PortB)
           MemoryDataReadEn : out std_logic;								--! Enable Main memory read
			  MemoryDataWriteEn: out std_logic;								--! Enable Main memory write
			  MemoryDataInput : in  STD_LOGIC_VECTOR (n downto 0);	--! Incoming data from main memory
           MemoryDataRdAddr : out  STD_LOGIC_VECTOR (n downto 0);	--! Main memory Read address
			  MemoryDataWrAddr : out  STD_LOGIC_VECTOR (n downto 0);	--! Main memory Write address
           MemoryDataOut : out  STD_LOGIC_VECTOR (n downto 0));	--! Data to write on main memory
end COMPONENT;

signal InputImediate : STD_LOGIC_VECTOR (n downto 0);
signal enableOutputDp : typeEnDis;
signal aluOperations : aluOps;
signal InputDataPathSelector : dpMuxInputs;
signal InputDataPathAluASelector : dpMuxAluIn;
signal registerFileWriteAddress : generalRegisters;
signal registerFileWriteEnable : STD_LOGIC;
signal registerFileReadAddressA : generalRegisters;
signal registerFileReadAddressB : generalRegisters;
signal registerFileReadEnableA : STD_LOGIC;
signal registerFileReadEnableB : STD_LOGIC;
signal dataPathOutput : STD_LOGIC_VECTOR (n downto 0);
signal dataPathFlags : STD_LOGIC_VECTOR (2 downto 0);
begin
	--! Instantiate the Datapath
   uDataPath: DataPath PORT MAP (
			inputMm => mem_data_in,
			inputImm => InputImediate,
			clk => clk,
			outEn => enableOutputDp,
			aluOp => aluOperations,
			muxSel => InputDataPathSelector,
			muxRegFile => InputDataPathAluASelector,
			regFileWriteAddr => registerFileWriteAddress,
			regFileWriteEn => registerFileWriteEnable,
			regFileReadAddrA => registerFileReadAddressA,
			regFileReadAddrB => registerFileReadAddressB,
			regFileEnA => registerFileReadEnableA,
			regFileEnB => registerFileReadEnableB,
			outputDp => dataPathOutput,
			dpFlags => dataPathFlags			
        );
	
	--! Instantiate the control unit
	uControlUnit: ControlUnit PORT MAP (
			reset => rst,
			clk => clk,
			FlagsDp => dataPathFlags,
			DataDp => dataPathOutput,
			outEnDp => enableOutputDp,
			MuxDp => InputDataPathSelector,
			MuxRegDp => InputDataPathAluASelector,
			ImmDp => InputImediate,
			DpAluOp => aluOperations,
			DpRegFileWriteAddr => registerFileWriteAddress,
			DpRegFileWriteEn => registerFileWriteEnable,
			DpRegFileReadAddrA => registerFileReadAddressA,
			DpRegFileReadAddrB => registerFileReadAddressB,
			DpRegFileReadEnA => registerFileReadEnableA,
			DpRegFileReadEnB => registerFileReadEnableB,
			MemoryDataReadEn => mem_rd,
			MemoryDataWriteEn => mem_wr,
			MemoryDataInput => mem_data_in,
			MemoryDataRdAddr => mem_rd_addr,
			MemoryDataWrAddr => mem_wr_addr,
			MemoryDataOut => mem_data_out
	);

end Behavioral;

