--! @file
--! @brief Testbench for ControlUnit

--! Use standard library and import the packages (std_logic_1164,std_logic_unsigned,std_logic_arith)
library IEEE;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;
 
--! Use CPU Definitions package
use work.pkgOpenCPU32.all;

--! Adding library for File I/O 
-- More information on this site:
-- http://people.sabanciuniv.edu/erkays/el310/io_10.pdf
-- http://eesun.free.fr/DOC/vhdlref/refguide/language_overview/test_benches/reading_and_writing_files_with_text_i_o.htm
use std.textio.ALL;
use ieee.std_logic_textio.all;
 
ENTITY testControlUnit IS
generic (n : integer := nBits - 1);									--! Generic value (Used to easily change the size of the Alu on the package)
END testControlUnit;
 
--! @brief ControlUnit Testbench file
--! @details Exercise the control unit with a assembly program sample
--! for more information: http://vhdlguru.blogspot.com/2010/03/how-to-write-testbench.html
ARCHITECTURE behavior OF testControlUnit IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT ControlUnit
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
    END COMPONENT;
    

   --Inputs
   signal reset : std_logic := '0';															--! Wire to connect Test signal to component
   signal clk : std_logic := '0';															--! Wire to connect Test signal to component
   signal FlagsDp : std_logic_vector(2 downto 0) := (others => '0');				--! Wire to connect Test signal to component
   signal DataDp : std_logic_vector(n downto 0) := (others => '0');				--! Wire to connect Test signal to component
   signal MemoryDataInput : std_logic_vector(n downto 0) := (others => '0');	--! Wire to connect Test signal to component

 	--Outputs
   signal outEnDp : typeEnDis;																--! Wire to connect Test signal to component
	signal MuxDp : dpMuxInputs;																--! Wire to connect Test signal to component
	signal MuxRegDp : dpMuxAluIn;																--! Wire to connect Test signal to component
   signal ImmDp : std_logic_vector(n downto 0);											--! Wire to connect Test signal to component
	signal DpAluOp : aluOps;																	--! Wire to connect Test signal to component
   signal DpRegFileWriteAddr : generalRegisters;										--! Wire to connect Test signal to component
   signal DpRegFileWriteEn : std_logic;													--! Wire to connect Test signal to component
   signal DpRegFileReadAddrA : generalRegisters;										--! Wire to connect Test signal to component
   signal DpRegFileReadAddrB : generalRegisters;										--! Wire to connect Test signal to component
   signal DpRegFileReadEnA : std_logic;													--! Wire to connect Test signal to component
   signal DpRegFileReadEnB : std_logic;													--! Wire to connect Test signal to component
	signal MemoryDataReadEn : std_logic;													--! Wire to connect Test signal to component
	signal MemoryDataWriteEn : std_logic;													--! Wire to connect Test signal to component
	signal MemoryDataRdAddr : std_logic_vector(n downto 0);							--! Wire to connect Test signal to component
   signal MemoryDataWrAddr : std_logic_vector(n downto 0);							--! Wire to connect Test signal to component
   signal MemoryDataOut : std_logic_vector(n downto 0);								--! Wire to connect Test signal to component

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
	--! Instantiate the Unit Under Test (ControlUnit)
   uut: ControlUnit PORT MAP (          
			reset => reset,
			clk => clk,
			FlagsDp => FlagsDp,
			DataDp => DataDp,
			outEnDp => outEnDp,
			MuxDp => MuxDp,
			MuxRegDp => MuxRegDp,
			ImmDp => ImmDp,
			DpAluOp => DpAluOp,
			DpRegFileWriteAddr => DpRegFileWriteAddr,
			DpRegFileWriteEn => DpRegFileWriteEn,
			DpRegFileReadAddrA => DpRegFileReadAddrA,
			DpRegFileReadAddrB => DpRegFileReadAddrB,
			DpRegFileReadEnA => DpRegFileReadEnA,
			DpRegFileReadEnB => DpRegFileReadEnB,
			MemoryDataReadEn => MemoryDataReadEn,
			MemoryDataWriteEn => MemoryDataWriteEn,
			MemoryDataInput => MemoryDataInput,
			MemoryDataRdAddr => MemoryDataRdAddr,
			MemoryDataWrAddr => MemoryDataWrAddr,
			MemoryDataOut => MemoryDataOut
        );

   -- Clock process definitions
   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
	variable line_out: Line; -- Line that will be written to a file
	file cmdfile: TEXT;      -- Define the file 'handle'
   begin		      
		-- Reset operation
		REPORT "RESET" SEVERITY NOTE;
		-- Open source file for write...
		FILE_OPEN(cmdfile,"testCode/testCodeBin.dat",WRITE_MODE);
		reset <= '1';
      wait for 2 ns;	     
		reset <= '0';
		wait for 2 ns;	     

      -- MOV r0,10d (Compare control unit outputs with Datapath)--------------------------------------
		REPORT "MOV r0,10" SEVERITY NOTE;
		MemoryDataInput <= mov_val & conv_std_logic_vector(reg2Num(r0),4) & conv_std_logic_vector(10, 22);		
		wait for CLK_period;	-- Fetch
		wait for CLK_period;	-- Decode
		wait for CLK_period;	-- Execute
		
		-- Write the command to a file (This will be usefull for the top Testing later)
		WRITE (line_out, MemoryDataInput);
		WRITELINE (cmdfile, line_out);
		
		-- Verify if signals for the datapath are valid
		assert ImmDp = conv_std_logic_vector(10, nBits) report "Invalid value" severity FAILURE;
		assert DpRegFileWriteAddr = r0 report "Invalid value" severity FAILURE; 
      assert DpAluOp = alu_pass report "Invalid value" severity FAILURE;
		assert MuxDp = fromImediate report "Invalid value" severity FAILURE;				
		
		wait for CLK_period;	-- Executing ... 1
		
		-- State writing on the registers
		assert DpRegFileWriteEn = '1' report "Invalid value" severity FAILURE;				
		
		wait for CLK_period;	-- Executing ...2 (Releasing lines.... (Next instruction should come...)				
		
		-- Verify if all lines are unasserted
		assert DpRegFileWriteEn = '0' report "Invalid value" severity FAILURE;
		assert DpRegFileReadEnB = '0' report "Invalid value" severity FAILURE;
		assert DpRegFileReadEnA = '0' report "Invalid value" severity FAILURE;
		assert DpRegFileWriteEn = '0' report "Invalid value" severity FAILURE;
		assert outEnDp = disable report "Invalid value" severity FAILURE;								
		-------------------------------------------------------------------------------------------------
		
		-- MOV r1,20d (Compare control unit outputs with Datapath)--------------------------------------
		REPORT "MOV r1,20" SEVERITY NOTE;
		MemoryDataInput <= mov_val & conv_std_logic_vector(reg2Num(r1),4) & conv_std_logic_vector(20, 22);
		wait for CLK_period;	-- Fetch
		wait for CLK_period;	-- Decode
		wait for CLK_period;	-- Execute
		
		-- Write the command to a file (This will be usefull for the top Testing later)
		WRITE (line_out, MemoryDataInput);
		WRITELINE (cmdfile, line_out);
		
		-- Verify if signals for the datapath are valid
		assert ImmDp = conv_std_logic_vector(20, nBits) report "Invalid value" severity FAILURE;
		assert DpRegFileWriteAddr = r1 report "Invalid value" severity FAILURE; 
      assert DpAluOp = alu_pass report "Invalid value" severity FAILURE;
		assert MuxDp = fromImediate report "Invalid value" severity FAILURE;				
		
		wait for CLK_period;	-- Executing ... 1
		
		-- State writing on the registers
		assert DpRegFileWriteEn = '1' report "Invalid value" severity FAILURE;				
		
		wait for CLK_period;	-- Executing ...2 (Releasing lines.... (Next instruction should come...)				
		
		-- Verify if all lines are unasserted
		assert DpRegFileWriteEn = '0' report "Invalid value" severity FAILURE;
		assert DpRegFileReadEnB = '0' report "Invalid value" severity FAILURE;
		assert DpRegFileReadEnA = '0' report "Invalid value" severity FAILURE;
		assert DpRegFileWriteEn = '0' report "Invalid value" severity FAILURE;
		assert outEnDp = disable report "Invalid value" severity FAILURE;
		-------------------------------------------------------------------------------------------------
		
		-- MOV r2,r1 (Compare control unit outputs with Datapath)--------------------------------------
		REPORT "MOV r2,r1" SEVERITY NOTE;
		MemoryDataInput <= mov_reg & conv_std_logic_vector(reg2Num(r2),4) & conv_std_logic_vector(reg2Num(r1),4) & "000000000000000000";
		wait for CLK_period;	-- Fetch
		wait for CLK_period;	-- Decode
		wait for CLK_period;	-- Execute
		
		-- Write the command to a file (This will be usefull for the top Testing later)
		WRITE (line_out, MemoryDataInput);
		WRITELINE (cmdfile, line_out);
		
		-- Verify if signals for the datapath are valid		
		assert DpRegFileReadAddrB = r1 report "Invalid value" severity FAILURE;
		assert DpRegFileWriteAddr = r2 report "Invalid value" severity FAILURE;       
		assert MuxDp = fromRegFileB report "Invalid value" severity FAILURE;				
		assert DpRegFileReadEnB = '1' report "Invalid value" severity FAILURE;
		wait for CLK_period;	-- Executing ... 1
		
		-- State writing on the registers
		assert DpRegFileWriteEn = '1' report "Invalid value" severity FAILURE;				
		
		wait for CLK_period;	-- Executing ...2 (Releasing lines.... (Next instruction should come...)				
		
		-- Verify if all lines are unasserted
		assert DpRegFileWriteEn = '0' report "Invalid value" severity FAILURE;
		assert DpRegFileReadEnB = '0' report "Invalid value" severity FAILURE;
		assert DpRegFileReadEnA = '0' report "Invalid value" severity FAILURE;
		assert DpRegFileWriteEn = '0' report "Invalid value" severity FAILURE;
		assert outEnDp = disable report "Invalid value" severity FAILURE;
		-------------------------------------------------------------------------------------------------
		
		-- ADD r2,r0 (Compare control unit outputs with Datapath)--------------------------------------
		REPORT "ADD r2,r0" SEVERITY NOTE;
		MemoryDataInput <= add_reg & conv_std_logic_vector(reg2Num(r2),4) & conv_std_logic_vector(reg2Num(r0),4) & "000000000000000000";
		wait for CLK_period;	-- Fetch
		wait for CLK_period;	-- Decode
		wait for CLK_period;	-- Execute
		
		-- Write the command to a file (This will be usefull for the top Testing later)
		WRITE (line_out, MemoryDataInput);
		WRITELINE (cmdfile, line_out);
		
		-- Verify if signals for the datapath are valid		
		assert DpRegFileReadAddrB = r0 report "Invalid value" severity FAILURE;
		assert DpRegFileReadAddrA = r2 report "Invalid value" severity FAILURE;
		assert DpRegFileWriteAddr = r2 report "Invalid value" severity FAILURE;       
		assert MuxDp = fromAlu report "Invalid value" severity FAILURE;		
		assert DpAluOp = alu_sum report "Invalid value" severity FAILURE;		
		assert DpRegFileReadEnB = '1' report "Invalid value" severity FAILURE;
		assert DpRegFileReadEnA = '1' report "Invalid value" severity FAILURE;
		assert MuxRegDp = fromRegFileA report "Invalid value" severity FAILURE;
		wait for CLK_period;	-- Executing ... 1
		
		-- State writing on the registers
		assert DpRegFileWriteEn = '1' report "Invalid value" severity FAILURE;				
		
		wait for CLK_period;	-- Executing ...2 (Releasing lines.... (Next instruction should come...)				
		
		-- Verify if all lines are unasserted
		assert DpRegFileWriteEn = '0' report "Invalid value" severity FAILURE;
		assert DpRegFileReadEnB = '0' report "Invalid value" severity FAILURE;
		assert DpRegFileReadEnA = '0' report "Invalid value" severity FAILURE;
		assert DpRegFileWriteEn = '0' report "Invalid value" severity FAILURE;
		assert outEnDp = disable report "Invalid value" severity FAILURE;
		-------------------------------------------------------------------------------------------------
		
		-- ADD r2,2 (Compare control unit outputs with Datapath)--------------------------------------
		REPORT "ADD r2,2" SEVERITY NOTE;
		MemoryDataInput <= add_val & conv_std_logic_vector(reg2Num(r2),4) & conv_std_logic_vector(2, 22);
		wait for CLK_period;	-- Fetch
		wait for CLK_period;	-- Decode
		wait for CLK_period;	-- Execute
		
		-- Write the command to a file (This will be usefull for the top Testing later)
		WRITE (line_out, MemoryDataInput);
		WRITELINE (cmdfile, line_out);
		
		-- Verify if signals for the datapath are valid		
		assert ImmDp = conv_std_logic_vector(2, nBits) report "Invalid value" severity FAILURE;
		assert DpRegFileWriteAddr = r2 report "Invalid value" severity FAILURE; 
      assert DpAluOp = alu_sum report "Invalid value" severity FAILURE;
		assert MuxDp = fromAlu report "Invalid value" severity FAILURE;				
		assert MuxRegDp = fromImediate report "Invalid value" severity FAILURE;
		assert DpRegFileReadAddrB = r2 report "Invalid value" severity FAILURE;
		assert DpRegFileReadEnB = '1' report "Invalid value" severity FAILURE;
				
		wait for CLK_period;	-- Executing ... 1
		
		-- State writing on the registers
		assert DpRegFileWriteEn = '1' report "Invalid value" severity FAILURE;				
		
		wait for CLK_period;	-- Executing ...2 (Releasing lines.... (Next instruction should come...)				
		
		-- Verify if all lines are unasserted
		assert DpRegFileWriteEn = '0' report "Invalid value" severity FAILURE;
		assert DpRegFileReadEnB = '0' report "Invalid value" severity FAILURE;
		assert DpRegFileReadEnA = '0' report "Invalid value" severity FAILURE;
		assert DpRegFileWriteEn = '0' report "Invalid value" severity FAILURE;
		assert outEnDp = disable report "Invalid value" severity FAILURE;
		-------------------------------------------------------------------------------------------------
		
		-- sto r2,10 (Store into memory address pointed by r2 the value 50)------------------------------
		REPORT "STO r2,50" SEVERITY NOTE;
		MemoryDataInput <= stom_val & conv_std_logic_vector(reg2Num(r2),4) & conv_std_logic_vector(50, 22);
		wait for CLK_period;	-- Fetch
		wait for CLK_period;	-- Decode
		wait for CLK_period;	-- Execute
		
		-- Write the command to a file (This will be usefull for the top Testing later)
		WRITE (line_out, MemoryDataInput);
		WRITELINE (cmdfile, line_out);
		
		-- Verify if signals for the datapath are valid		
		assert MemoryDataOut = conv_std_logic_vector(50, 22) report "Invalid value" severity FAILURE;
		
		wait for CLK_period;	-- Executing ... 1
						
		wait for CLK_period;	-- Executing ... 2		
								
		wait for CLK_period;	-- Executing ... 3
						
		wait for CLK_period;	-- Executing ... 4
		
		-- Verify memory strobe signal
		assert MemoryDataWriteEn = '1' report "Invalid value" severity FAILURE;
				
		-------------------------------------------------------------------------------------------------
		
		-- ld r5,20 (Load into r5 register the content of the memory at address 20)----------------------
		REPORT "ld r5,20" SEVERITY NOTE;
		MemoryDataInput <= ld_val & conv_std_logic_vector(reg2Num(r5),4) & conv_std_logic_vector(20, 22);
		wait for CLK_period;	-- Fetch
		wait for CLK_period;	-- Decode
		wait for CLK_period;	-- Execute
		
		-- Write the command to a file (This will be usefull for the top Testing later)
		WRITE (line_out, MemoryDataInput);
		WRITELINE (cmdfile, line_out);
		
		assert MemoryDataRdAddr = conv_std_logic_vector(20, 32) report "Invalid value" severity FAILURE;
		
		wait for CLK_period;	-- Executing ... 1
		
		wait for CLK_period;	-- Executing ... 2
		
		wait for CLK_period;	-- Executing ... 3
		
		wait for CLK_period;	-- Executing ... 4
		
		--wait for CLK_period;	-- Executing ... 4
		
		-------------------------------------------------------------------------------------------------
		
		-- jmp 0 (Jump to position 0)--------------------------------------------------------------------
		REPORT "jmp 0" SEVERITY NOTE;
		MemoryDataInput <= jmp_val & conv_std_logic_vector(0,4) & conv_std_logic_vector(0, 22);
		wait for CLK_period;	-- Fetch
		wait for CLK_period;	-- Decode
		wait for CLK_period;	-- Execute
		
		-- Write the command to a file (This will be usefull for the top Testing later)
		WRITE (line_out, MemoryDataInput);
		WRITELINE (cmdfile, line_out);
		
		--wait for CLK_period;	-- Executing ... 1
		--assert MemoryDataRdAddr = conv_std_logic_vector(0, 32) report "Invalid value" severity FAILURE;
		
		--wait for CLK_period;	-- Executing ... 2
				
		-------------------------------------------------------------------------------------------------
		
		-- jmpr 3 (Jump to position Current + 3)--------------------------------------------------------------------
		REPORT "jmpr 3" SEVERITY NOTE;
		MemoryDataInput <= jmpr_val & conv_std_logic_vector(0,4) & conv_std_logic_vector(3, 22);
		wait for CLK_period;	-- Fetch
		wait for CLK_period;	-- Decode
		wait for CLK_period;	-- Execute
		
		-- Write the command to a file (This will be usefull for the top Testing later)
		WRITE (line_out, MemoryDataInput);
		WRITELINE (cmdfile, line_out);
		
		wait for CLK_period;	-- Executing ... 1
		--assert MemoryDataRdAddr = conv_std_logic_vector(3, 32) report "Invalid value" severity FAILURE;
		
		--wait for CLK_period;	-- Executing ... 2
				
		-------------------------------------------------------------------------------------------------

      -- Close file
		file_close(cmdfile);
		-- Finish simulation
		assert false report "NONE. End of simulation." severity failure;
		wait;
   end process;

END;
