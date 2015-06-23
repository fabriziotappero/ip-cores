--! @file
--! @brief Testbench for OpenCpu top design

--! Use standard library and import the packages (std_logic_1164,std_logic_unsigned,std_logic_arith)
LIBRARY ieee;
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
 
ENTITY testOpenCpu IS
generic (n : integer := nBits - 1);											--! Generic value (Used to easily change the size of the Alu on the package)
END testOpenCpu;
 
--! @brief openCpu Testbench file
--! @details This is the top-level test...
ARCHITECTURE behavior OF testOpenCpu IS 
 
    --! Component declaration to instantiate the Multiplexer circuit			
    COMPONENT openCpu
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
    END COMPONENT;
    

   --Inputs
   signal rst : std_logic := '0';														--! Wire to connect Test signal to component
   signal clk : std_logic := '0';														--! Wire to connect Test signal to component
   signal mem_data_in : std_logic_vector(n downto 0) := (others => '0');	--! Wire to connect Test signal to component

 	--Outputs
   signal mem_rd : std_logic;																--! Wire to connect Test signal to component
   signal mem_rd_addr : std_logic_vector(n downto 0);								--! Wire to connect Test signal to component
   signal mem_wr : std_logic;																--! Wire to connect Test signal to component
   signal mem_wr_addr : std_logic_vector(n downto 0);								--! Wire to connect Test signal to component
   signal mem_data_out : std_logic_vector(n downto 0);							--! Wire to connect Test signal to component

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
	--! Instantiate the Unit Under Test (openCpu) (Doxygen bug if it's not commented!)
   uut: openCpu PORT MAP (
          rst => rst,
          clk => clk,
          mem_rd => mem_rd,
          mem_rd_addr => mem_rd_addr,
          mem_wr => mem_wr,
          mem_wr_addr => mem_wr_addr,
          mem_data_in => mem_data_in,
          mem_data_out => mem_data_out
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
	file cmdfile: TEXT;       			-- Define the file 'handle'
	variable line_in: Line; -- Line buffer
	variable good: boolean;				-- Flag to detect a good line read
	variable instructionCode : std_logic_vector(n downto 0);
   begin		
      -- Reset operation
		REPORT "RESET" SEVERITY NOTE;
		-- Open source file for reading...
		FILE_OPEN(cmdfile,"testCode/testCodeBin.dat",READ_MODE);
		
		-- Check end of file
		if endfile(cmdfile) then
			assert false report "End of file found..." severity failure;
		end if;
		
		rst <= '1';
      wait for 15 ns;	     
		rst <= '0';
		wait for 15 ns;

		while not endfile( cmdfile ) loop
			readline(cmdfile,line_in);     			 -- Read a line from the file
			read(line_in,instructionCode,good);     -- Read the CI input
			assert good report "Could not parse the line" severity ERROR;
			mem_data_in <= instructionCode;

			wait until mem_rd = '0';						
		end loop;										
		
		wait until mem_rd = '0';
		wait for CLK_period;	-- Execute
		wait for CLK_period;	-- Execute
		wait for CLK_period;	-- Execute
		wait for CLK_period;	-- Execute

      -- Finish simulation
		assert false report "NONE. End of simulation." severity failure;
		wait;
   end process;

END;
