--! @file
--! @brief Testbench for Datapath

--! Use standard library and import the packages (std_logic_1164,std_logic_unsigned,std_logic_arith)
library IEEE;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

--! Use CPU Definitions package
use work.pkgOpenCPU32.all;
 
ENTITY testDataPath IS
generic (n : integer := nBits - 1);										--! Generic value (Used to easily change the size of the Alu on the package)
END testDataPath;
 
--! @brief Datapath Testbench file
--! @details Attention to this testbench because it will give you hints on how the control circuit must work....
--! for more information: http://vhdlguru.blogspot.com/2010/03/how-to-write-testbench.html
ARCHITECTURE behavior OF testDataPath IS 
     
	 --! Component declaration to instantiate the Alu circuit
    COMPONENT DataPath
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
    END COMPONENT;
    

   --Inputs
   signal inputMm : std_logic_vector(n downto 0) := (others => 'U');		--! Wire to connect Test signal to component
   signal inputImm : std_logic_vector(n downto 0) := (others => 'U');	--! Wire to connect Test signal to component
   signal clk : std_logic := '0';													--! Wire to connect Test signal to component
   signal outEn : typeEnDis := disable;											--! Wire to connect Test signal to component
   signal aluOp : aluOps := alu_pass;												--! Wire to connect Test signal to component
   signal muxSel : dpMuxInputs := fromMemory;									--! Wire to connect Test signal to component
	signal muxRegFile : dpMuxAluIn := fromMemory; 								--! Wire to connect Test signal to component
   signal regFileWriteAddr : generalRegisters := r0;							--! Wire to connect Test signal to component
   signal regFileWriteEn : std_logic := '0';										--! Wire to connect Test signal to component
   signal regFileReadAddrA : generalRegisters := r0;							--! Wire to connect Test signal to component
	signal regFileReadAddrB : generalRegisters := r0;							--! Wire to connect Test signal to component   
   signal regFileEnA : std_logic := '0';											--! Wire to connect Test signal to component
   signal regFileEnB : std_logic := '0';											--! Wire to connect Test signal to component

 	--Outputs
   signal outputDp : std_logic_vector(n downto 0);								--! Wire to connect Test signal to component
   signal dpFlags : std_logic_vector(2 downto 0);								--! Wire to connect Test signal to component
   
	-- Clock period definitions
   constant CLK_period : time := 10 ns;
 
BEGIN
 
	--! Instantiate the Unit Under Test (Alu) (Doxygen bug if it's not commented!)
   uut: DataPath PORT MAP (
          inputMm => inputMm,
          inputImm => inputImm,
          clk => clk,
          outEn => outEn,
          aluOp => aluOp,
          muxSel => muxSel,
			 muxRegFile => muxRegFile,
          regFileWriteAddr => regFileWriteAddr,
          regFileWriteEn => regFileWriteEn,
          regFileReadAddrA => regFileReadAddrA,
          regFileReadAddrB => regFileReadAddrB,
          regFileEnA => regFileEnA,
          regFileEnB => regFileEnB,
          outputDp => outputDp,
          dpFlags => dpFlags
        );
	
	-- Clock process definitions
   CLK_process :process
   begin
                CLK <= '0';
                wait for CLK_period/2;
                CLK <= '1';
                wait for CLK_period/2;
   end process;
  
   -- Stimulus process
   stim_proc: process
   begin		
      -- MOV r0,10d ---------------------------------------------------------------------------------
		REPORT "MOV r0,10" SEVERITY NOTE;
		inputImm <= conv_std_logic_vector(10, nBits);
		regFileWriteAddr <= r0;
      aluOp <= alu_pass;
		muxSel <= fromImediate;
		muxRegFile <= fromRegFileA;
		regFileWriteEn <= '1';
		wait for CLK_period;    -- Wait for clock cycle to latch some data to the register file
		-- Read value in r0 to verify if is equal to 20
		regFileWriteEn <= '0';
		inputImm <= (others => 'U');
		muxSel <= fromRegFileA;
		regFileReadAddrA <= r0;	-- Read data from r0 and verify if it's 10
		regFileEnA <= '1';
		outEn <= enable;
		wait for 1 ns;	-- Wait for data to settle
		assert outputDp = conv_std_logic_vector(10, nBits) report "Invalid value" severity FAILURE;
		wait for 1 ns;	-- Finish test case
		muxSel <= fromMemory;
		regFileEnA <= '0';
		outEn <= disable;
		
		
		-- MOV r1,20d ---------------------------------------------------------------------------------
		REPORT "MOV r1,20" SEVERITY NOTE;
		inputImm <= conv_std_logic_vector(20, nBits);
		regFileWriteAddr <= r1;
      aluOp <= alu_pass;
		muxSel <= fromImediate;
		muxRegFile <= fromRegFileA;
		regFileWriteEn <= '1';
		wait for CLK_period;    -- Wait for clock cycle to latch some data to the register file
		-- Read value in r1 to verify if is equal to 20
		regFileWriteEn <= '0';
		inputImm <= (others => 'U');
		muxSel <= fromRegFileA;
		regFileReadAddrA <= r1;	-- Read data from r0 and verify if it's 10
		regFileEnA <= '1';
		outEn <= enable;
		wait for 1 ns;	-- Wait for data to settle
		assert outputDp = conv_std_logic_vector(20, nBits) report "Invalid value" severity FAILURE;
		wait for 1 ns;	-- Finish test case
		muxSel <= fromMemory;
		regFileEnA <= '0';
		outEn <= disable;
		
		
		-- MOV r2,r1 (r2 <= r1) --------------------------------------------------------------------
		REPORT "MOV r2,r1" SEVERITY NOTE;
		regFileReadAddrB <= r1;	-- Read data from r1 
		regFileEnB <= '1';		
		regFileWriteAddr <= r2; -- Write data in r2
		muxSel <= fromRegFileB;	-- Select the PortB output from regFile
		muxRegFile <= fromRegFileA;
		regFileWriteEn <= '1';
		wait for CLK_period;    -- Wait for clock cycle to write into r2
		-- Read value in r2 to verify if is equal to r1(20)
		regFileWriteEn <= '0';
		inputImm <= (others => 'U');
		muxSel <= fromRegFileA;
		regFileReadAddrA <= r2;	-- Read data from r0 and verify if it's 10
		regFileEnA <= '1';
		outEn <= enable;
		wait for 1 ns;	-- Wait for data to settle
		assert outputDp = conv_std_logic_vector(20, nBits) report "Invalid value" severity FAILURE;
		wait for 1 ns;	-- Finish test case
		muxSel <= fromMemory;
		regFileEnA <= '0';
		outEn <= disable;
		wait for 1 ns;	-- Finish test case
		
		-- ADD r2,r0 (r2 <= r2+r0)
		REPORT "ADD r2,r0" SEVERITY NOTE;
		regFileReadAddrA <= r2;	-- Read data from r2
		regFileEnA <= '1';		
		regFileReadAddrB <= r0;	-- Read data from r0 
		regFileEnB <= '1';
		aluOp <= alu_sum;				
		regFileWriteAddr <= r2; -- Write data in r2
		muxSel <= fromAlu;	-- Select the Alu output
		muxRegFile <= fromRegFileA;
		regFileWriteEn <= '1';
		wait for CLK_period;    -- Wait for clock cycle to write into r2
		-- Read value in r2 to verify if is equal to 30(10+20)
		regFileWriteEn <= '0';
		inputImm <= (others => 'U');
		muxSel <= fromRegFileB;	-- Must access from other Port otherwise you will need an extra cycle to change it's address
		regFileReadAddrB <= r2;	-- Read data from r0 and verify if it's 10
		regFileEnB <= '1';
		outEn <= enable;
		wait for 1 ns;	-- Wait for data to settle
		assert outputDp = conv_std_logic_vector(30, nBits) report "Invalid value" severity FAILURE;
		wait for 1 ns;	-- Finish test case
		muxSel <= fromMemory;
		regFileEnA <= '0';
		regFileEnB <= '0';
		outEn <= disable;
		wait for 1 ns;	-- If you don't use this wait the signals will not change...! (Take care of this when implementing the ControlUnit)
		
		-- ADD r3,r2,r0 (r3 <= r2+r0)
		REPORT "ADD r3,r2,r0" SEVERITY NOTE;
		regFileReadAddrA <= r2;	-- Read data from r2
		regFileEnA <= '1';		
		regFileReadAddrB <= r0;	-- Read data from r0 
		regFileEnB <= '1';
		aluOp <= alu_sum;				
		regFileWriteAddr <= r3; -- Write data in r2
		muxSel <= fromAlu;	-- Select the Alu output
		muxRegFile <= fromRegFileA;
		regFileWriteEn <= '1';
		wait for CLK_period;    -- Wait for clock cycle to write into r2
		-- Read value in r2 to verify if is equal to 30(10+20)
		regFileWriteEn <= '0';
		inputImm <= (others => 'U');
		muxSel <= fromRegFileB;	-- Must access from other Port otherwise you will need an extra cycle to change it's address
		regFileReadAddrB <= r3;	-- Read data from r0 and verify if it's 10
		regFileEnB <= '1';
		outEn <= enable;
		wait for 1 ns;	-- Wait for data to settle
		assert outputDp = conv_std_logic_vector(40, nBits) report "Invalid value" severity FAILURE;
		wait for 1 ns;	-- Finish test case
		muxSel <= fromMemory;
		regFileEnA <= '0';
		regFileEnB <= '0';
		outEn <= disable;
		
		-- ADD r3,2 (r2 <= r2+2)
		REPORT "ADD r3,2" SEVERITY NOTE;
		inputImm <= conv_std_logic_vector(2, nBits);
		regFileReadAddrB <= r3;	-- Read data from r2
		regFileEnB <= '1';		
		regFileWriteAddr <= r3;
		muxRegFile <= fromImediate;
      aluOp <= alu_sum;
		muxSel <= fromAlu;	-- Select the Alu output		
		regFileWriteEn <= '1';
		wait for CLK_period;    -- Wait for clock cycle to write into r2
		-- Read value in r2 to verify if is equal to 42(40+2)
		regFileWriteEn <= '0';
		inputImm <= (others => 'U');
		muxSel <= fromRegFileA;	-- Must access from other Port otherwise you will need an extra cycle to change it's address
		regFileReadAddrA <= r3;	-- Read data from r0 and verify if it's 10
		regFileEnA <= '1';
		outEn <= enable;
		wait for 1 ns;	-- Wait for data to settle
		assert outputDp = conv_std_logic_vector(42, nBits) report "Invalid value" severity FAILURE;
		wait for 1 ns;	-- Finish test case
		muxSel <= fromMemory;
		regFileEnA <= '0';
		regFileEnB <= '0';
		outEn <= disable;
		wait for 1 ns;	-- If you don't use this wait the signals will not change...! (Take care of this when implementing the ControlUnit)
		

      -- Finish simulation
		assert false report "NONE. End of simulation." severity failure;
		wait;
   end process;

END;
