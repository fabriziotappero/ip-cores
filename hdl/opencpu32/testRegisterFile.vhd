--! @file
--! @brief Testbench for Alu

--! Use standard library and import the packages (std_logic_1164,std_logic_unsigned,std_logic_arith)
LIBRARY ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;
 
--! Use CPU Definitions package
use work.pkgOpenCPU32.all;
 
ENTITY testRegisterFile IS
END testRegisterFile;
 
--! @brief testRegisterFile Testbench file
--! @details Test read/write on the registers, testing also the dual port reading feature...
ARCHITECTURE behavior OF testRegisterFile IS 
    
	--! Component declaration to instantiate the testRegisterFile circuit
    COMPONENT RegisterFile
    generic (n : integer := nBits - 1);						--! Generic value (Used to easily change the size of the registers)
	 Port ( clk : in  STD_LOGIC;									--! Clock signal
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
    

   --Inputs
   signal clk : std_logic := '0';															--! Wire to connect Test signal to component
   signal writeEn : std_logic := '0';														--! Wire to connect Test signal to component
   signal writeAddr : generalRegisters := r0;											--! Wire to connect Test signal to component
   signal input : std_logic_vector((nBits - 1) downto 0) := (others => '0');	--! Wire to connect Test signal to component
   signal Read_A_En : std_logic := 'X';													--! Wire to connect Test signal to component
   signal Read_A_Addr : generalRegisters := r0;											--! Wire to connect Test signal to component
   signal Read_B_En : std_logic := 'X';													--! Wire to connect Test signal to component
   signal Read_B_Addr : generalRegisters := r0;											--! Wire to connect Test signal to component

 	--Outputs
   signal A_Out : std_logic_vector((nBits - 1) downto 0);							--! Wire to connect Test signal to component
   signal B_Out : std_logic_vector((nBits - 1) downto 0);   						--! Wire to connect Test signal to component
	
	constant num_cycles : integer := 320;													--! Number of clock iterations
 
BEGIN
 
	--! Instantiate the Unit Under Test (RegisterFile) (Doxygen bug if it's not commented!)
   uut: RegisterFile PORT MAP (
          clk => clk,
          writeEn => writeEn,
          writeAddr => writeAddr,
          input => input,
          Read_A_En => Read_A_En,
          Read_A_Addr => Read_A_Addr,
          Read_B_En => Read_B_En,
          Read_B_Addr => Read_B_Addr,
          A_Out => A_Out,
          B_Out => B_Out
        );

   --! Process that will stimulate all register assignments, and reads...
   stim_proc: process
	variable allZ : std_logic_vector((nBits - 1) downto 0) := (others => 'Z');
   begin		      		
		-- r0=1 ... r15=16---------------------------------------------------------------------------
		for i in 0 to (numGenRegs-1) loop
			clk <= '0';		
			REPORT "Write r0 := 1" SEVERITY NOTE;
			writeEn <= '1';
			writeAddr <= Num2reg(i);
			input <= conv_std_logic_vector(i+1, nBits);	
			wait for 1 ns;
			clk <= '1';
			wait for 1 ns;  -- Wait to stabilize the response
		end loop;
				
		-- Mark write end....
		clk <= '0';
		writeEn <= '0';
		wait for 1 ns;  -- Wait to stabilize the response		
		
		-- Read r0..r15 PortA-------------------------------------------------------------------------
		for i in 0 to (numGenRegs-1) loop
			REPORT "Check r0 = 1" SEVERITY NOTE;
			Read_A_En <= '1';
			Read_A_Addr <= Num2reg(i);
			wait for 1 ns;  -- Wait to stabilize the response
			assert A_Out = conv_std_logic_vector(i+1, nBits) report "Invalid value r0" severity FAILURE;		
			assert B_Out = allZ report "PortB should be high impedance" severity FAILURE;		
		end loop;
		
		-- Mark read A end
		Read_A_En <= 'X';
		
		-- Read r0..r15 PortB-------------------------------------------------------------------------
		for i in 0 to (numGenRegs-1) loop
			REPORT "Check r0 = 1" SEVERITY NOTE;
			Read_B_En <= '1';
			Read_B_Addr <= Num2reg(i);
			wait for 1 ns;  -- Wait to stabilize the response
			assert B_Out = conv_std_logic_vector(i+1, nBits) report "Invalid value r0" severity FAILURE;		
			assert A_Out = allZ report "PortB should be high impedance" severity FAILURE;		
		end loop;
		
		-- Mark read B end
		Read_B_En <= 'X';
      
		
		-- Finish simulation
		assert false report "NONE. End of simulation." severity failure;
   end process;

END;
