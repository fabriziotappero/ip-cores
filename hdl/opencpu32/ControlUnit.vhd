--! @file
--! @brief ControlUnit http://en.wikipedia.org/wiki/Control_unit

--! Use standard library and import the packages (std_logic_1164,std_logic_unsigned,std_logic_arith)
library IEEE;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

--! Use CPU Definitions package
use work.pkgOpenCPU32.all;

--! The control unit coordinates the input and output devices of a computer system. It fetches the code of all of the instructions \n
--! in the microprograms. It directs the operation of the other units by providing timing and control signals. \n
--! all computer resources are managed by the Control Unit.It directs the flow of data between the cpu and the other devices.\n
--! The outputs of the control unit control the activity of the rest of the device. A control unit can be thought of as a finite-state machine.

--! The purpose of datapaths is to provide routes for data to travel between functional units.
entity ControlUnit is
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
end ControlUnit;

--! @brief ControlUnit http://en.wikipedia.org/wiki/Control_unit
--! @details The control unit receives external instructions or commands which it converts into a sequence of control signals that the control \n
--! unit applies to data path to implement a sequence of register-transfer level operations.
architecture Behavioral of ControlUnit is

signal currentCpuState : controlUnitStates;					-- CPU states
signal nextCpuState    : controlUnitStates;					-- CPU states

signal currentExState  : executionStates;						-- Execution states
signal nextExState     : executionStates;						-- Execution states

signal PC              : std_logic_vector(n downto 0);	-- Program Counter
signal IR              : std_logic_vector(n downto 0);	-- Intruction register
signal currInstruction : std_logic_vector(n downto 0);	-- Current Intruction
begin

	-- Next state logic (CPU, fetch, decode, execute states)
	process (clk, reset)
	begin
		if (reset = '1') then
			currentCpuState <= initial;			
		elsif rising_edge(clk) then
			currentCpuState <= nextCpuState;
		end if;
	end process;
	
	-- Next state logic (Execution states)
	process (clk, currentCpuState)
	begin
		if (reset = '1') then
			currentExState <= initInstructionExecution;
		elsif rising_edge(clk) then
			currentExState <= nextExState;
		end if;
	end process;
	
	-- States Fetch, decode, execute from the processor (Also handles the execution of jump instructions)
	process (currentCpuState)
	variable cyclesExecute : integer range 0 to 20; 		-- Cycles to wait while executing instruction
	variable opcodeIR : std_logic_vector(5 downto 0);
	variable operand_reg1 : std_logic_vector(3 downto 0);
	variable operand_imm  : std_logic_vector(21 downto 0);
	variable accDp : std_logic_vector(n downto 0);			-- Value stored from DataPath
	begin
		opcodeIR := IR((IR'HIGH) downto (IR'HIGH - 5));
		operand_reg1 := IR((IR'HIGH - 6) downto (IR'HIGH - 9));		-- 4 bits register operand1 (Max 16 registers)
		operand_imm  := IR((IR'HIGH - 10) downto (IR'LOW));			-- 22 bits imediate value (Max value 4194304)
		case currentCpuState is			
			-- Initial state left from reset ...
			when initial =>
				cyclesExecute := 0;
				PC <= (others => '0');
				IR <= (others => '0');
				MemoryDataRdAddr <= (others => '0');
				MemoryDataReadEn <= '0';
				MemoryDataWriteEn <= '0';				
				nextCpuState <= fetch;
			
			-- Fetch state (Go to memory and get a instruction)
			when fetch =>
				-- Increment program counter (Remember that PC will be update only on the next cycle...
				PC <= PC + conv_std_logic_vector(1, nBits);
				MemoryDataRdAddr <= PC;	-- Warning PC is not 1 yet...
				IR <= MemoryDataInput;
				MemoryDataReadEn <= '1';
				MemoryDataWriteEn <= '0';
				nextCpuState <= decode;
			
			-- Detect with instruction came from memory, set the number of cycles to execute...
			when decode =>
				MemoryDataReadEn <= '0';
				MemoryDataWriteEn <= '0';
				
				-- The high attribute points to the highes bit position
				case opcodeIR is
					when mov_reg | mov_val | add_reg | add_val | sub_reg | and_reg | or_reg | xor_reg =>
							nextCpuState <= execute;
							cyclesExecute := 1;	-- Wait 1 cycles
							currInstruction <= IR;
					
					when ld_reg | ld_val | stom_reg | stom_val =>
							nextCpuState <= execute;
							cyclesExecute := 2;	-- Wait 2 cycles
							currInstruction <= IR;
					
					when jmp_val | jmpr_val =>
						nextCpuState <= execute;
						cyclesExecute := 0;		-- No Wait cycle
					
					-- Invalid instruction (Now will be ignored, but latter should raise a trap
					when others =>						
						null;
				end case;
			
			-- Wait while the process that handles the execution works..
			when execute =>
				-- On the case of jump instructions, it's execution will be handled on this process
				case opcodeIR is
					
					when jmp_val =>
						PC	<= "0000000000" & operand_imm;
						nextCpuState <= fetch;
					
					when jmpr_val =>
						PC	<= PC + ("0000000000" & operand_imm);
						nextCpuState <= fetch;
					
					-- ld r5,20 (Load into r5 register the content of the memory at address 20)
					when ld_val =>
						MemoryDataRdAddr <= "0000000000" & operand_imm;
						MemoryDataReadEn <= '1';
						if cyclesExecute = 0 then
							MemoryDataReadEn <= '0';
						end if;
					
					-- STORE r1,10 (Store the value 10 on memory address pointed by r1)
					when stom_val =>
						-- And put the imediate value ...							
							MemoryDataOut <= "0000000000" & operand_imm;								
							if cyclesExecute = 1 then
								-- After the register data is avaible in DataDp we put it's address and								
								accDp := DataDp;
								MemoryDataWrAddr <= accDp;								
							elsif cyclesExecute = 0 then
								-- strobe in to enter the data
								MemoryDataWriteEn <= '1';
							end if;
						
					when others =>						
						null;
				end case;
				
				if cyclesExecute = 0 then
					-- Finish the instruction execution get next
					nextCpuState <= fetch;
				else
					nextCpuState <= executing;					
				end if;				
			
			-- Just wait a cycle and back again to execute state which verify if still need to wait some cycles
			when executing =>
				cyclesExecute := cyclesExecute - 1;				
				nextCpuState <= execute;											
			
			when others =>
				null;
		end case;
	end process;
	
	-- Process that handles the execution of each instruction (Excluding the call,jump,load,store instructions)
	process (currentExState)	
	--variable operando1_reg : std_logic_vector(generalRegisters'range);
	variable opcodeIR     : std_logic_vector(5 downto 0);
	variable operand_reg1 : std_logic_vector(3 downto 0);
	variable operand_reg2 : std_logic_vector(3 downto 0);
	variable operand_imm  : std_logic_vector(21 downto 0);
	begin
		-- Parse the common operands
		opcodeIR := IR((IR'HIGH) downto (IR'HIGH - 5));					-- 6 Bits opcode (Max 64 instructions)
		operand_reg1 := IR((IR'HIGH - 6) downto (IR'HIGH - 9));		-- 4 bits register operand1 (Max 16 registers)
		operand_reg2 := IR((IR'HIGH - 10) downto (IR'HIGH - 13));   -- 4 bits register operand2 (Max 16 registers
		operand_imm  := IR((IR'HIGH - 10) downto (IR'LOW));			-- 22 bits imediate value (Max value 4194304)
		
		-- Select the instruction and init it's execution
		case currentExState is
			when initInstructionExecution =>
				nextExState <= waitToExecute;
			
			when waitToExecute =>
				if ( (currentCpuState /= execute) and (currentCpuState /= executing) ) then
					nextExState <= initInstructionExecution;					
				else
					case opcodeIR is					
					-- MOV r2,r1 (See the testDatapath to see how to drive the datapath for this function)
					when mov_reg =>						
						MuxDp <= fromRegFileB;						
						DpRegFileReadAddrB <= Num2reg(conv_integer(UNSIGNED(operand_reg2)));
						DpRegFileWriteAddr <= Num2reg(conv_integer(UNSIGNED(operand_reg1)));						
						DpRegFileReadEnB <= '1';
						nextExState <= writeRegister;
					
					-- LOAD r1,10 (Load into r1, the value in the main memory located at address 10)
					when ld_val =>
						MuxDp <= fromMemory;	
						DpRegFileWriteAddr <= Num2reg(conv_integer(UNSIGNED(operand_reg1)));
						-- The part that interface with the memory is located on the first process
						nextExState <= writeRegister;
					
					-- STORE r1,10 (Store the value 10 on the main memory pointed by r1)
					when stom_val =>
					MuxDp <= fromRegFileB;
					DpRegFileReadAddrB <= Num2reg(conv_integer(UNSIGNED(operand_reg1)));					
					DpRegFileReadEnB <= '1';
					-- The part that interface with the memory is located on the first process
					nextExState <= readRegisterB;										
					
					-- ADD r2,r0 (See the testDatapath to see how to drive the datapath for this function)
					when add_reg | sub_reg | and_reg | or_reg | xor_reg =>
						MuxDp <= fromAlu;
						MuxRegDp <= fromRegFileA;
						DpRegFileReadAddrA <= Num2reg(conv_integer(UNSIGNED(operand_reg1)));	-- Read first operand
						DpRegFileReadAddrB <= Num2reg(conv_integer(UNSIGNED(operand_reg2))); -- Read second operand
						DpRegFileReadEnA <= '1';
						DpRegFileReadEnB <= '1';												
						DpRegFileWriteAddr <= Num2reg(conv_integer(UNSIGNED(operand_reg1)));	-- Point to write in first operand (pointing to register)					
						DpAluOp <= opcode2AluOp(opcodeIR);	-- Select the alu operation from the operand
						nextExState <= writeRegister;
						
					-- MOV r0,10d (See the testDatapath to see how to drive the datapath for this function)
					when mov_val =>						
						MuxDp <= fromImediate;						
						DpRegFileWriteAddr <= Num2reg(conv_integer(UNSIGNED(operand_reg1)));						
						ImmDp <= "0000000000" & operand_imm;	-- & is used to concatenate signals
						nextExState <= writeRegister;	

					-- ADD r3,2 (r2 <= r2+2) (See the testDatapath to see how to drive the datapath for this function)
					when add_val | sub_val | and_val | or_val | xor_val =>
						MuxDp <= fromAlu;
						MuxRegDp <= fromImediate;
						DpRegFileWriteAddr <= Num2reg(conv_integer(UNSIGNED(operand_reg1)));	
						DpRegFileReadAddrB <= Num2reg(conv_integer(UNSIGNED(operand_reg1)));	-- Read first operand
						DpRegFileReadEnB <= '1';												
						ImmDp <= "0000000000" & operand_imm;	-- & is used to concatenate signals						
						DpAluOp <= opcode2AluOp(opcodeIR);	-- Select the alu operation from the operand
						nextExState <= writeRegister;
					
					when others =>
						null;
					end case;				
				end if;					
			
			-- Write something on the register files
			when writeRegister =>
				DpRegFileWriteEn <= '1';
				nextExState <= releaseWriteRead;
			
			when readRegisterB =>
				DpRegFileReadEnB <= '1';
				outEnDp <= enable;
				nextExState <= releaseWriteRead;
			
			when readRegisterA =>
				DpRegFileReadEnA <= '1';
				outEnDp <= enable;
				nextExState <= releaseWriteRead;
			
			-- Release lines (Reset Datapath lines to something that does nothing...)
			when releaseWriteRead =>
				DpRegFileReadEnB <= '0';
				DpRegFileReadEnA <= '0';
				DpRegFileWriteEn <= '0';
				outEnDp <= disable;
				-- Come back to waiting state
				nextExState <= waitToExecute;				
			
			when others =>
				null;
		end case;
	end process;

end Behavioral;

