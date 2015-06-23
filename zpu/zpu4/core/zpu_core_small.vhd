-- ZPU
--
-- Copyright 2004-2008 oharboe - Øyvind Harboe - oyvind.harboe@zylin.com
-- 
-- The FreeBSD license
-- 
-- Redistribution and use in source and binary forms, with or without
-- modification, are permitted provided that the following conditions
-- are met:
-- 
-- 1. Redistributions of source code must retain the above copyright
--    notice, this list of conditions and the following disclaimer.
-- 2. Redistributions in binary form must reproduce the above
--    copyright notice, this list of conditions and the following
--    disclaimer in the documentation and/or other materials
--    provided with the distribution.
-- 
-- THIS SOFTWARE IS PROVIDED BY THE ZPU PROJECT ``AS IS'' AND ANY
-- EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
-- THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
-- PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
-- ZPU PROJECT OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
-- INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
-- (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
-- OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
-- HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
-- STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
-- ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
-- ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
-- 
-- The views and conclusions contained in the software and documentation
-- are those of the authors and should not be interpreted as representing
-- official policies, either expressed or implied, of the ZPU Project.

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

library work;
use work.zpu_config.all;
use work.zpupkg.all;


entity zpu_core is
    Port ( clk : in std_logic;
    		  -- asynchronous reset signal
	 		  areset : in std_logic;
	 		  -- this particular implementation of the ZPU does not
	 		  -- have a clocked enable signal
	 		  enable : in std_logic; 
	 		  in_mem_busy : in std_logic; 
	 		  mem_read : in std_logic_vector(wordSize-1 downto 0);
	 		  mem_write : out std_logic_vector(wordSize-1 downto 0);			  
	 		  out_mem_addr : out std_logic_vector(maxAddrBitIncIO downto 0);
			  out_mem_writeEnable : out std_logic; 
			  out_mem_readEnable : out std_logic;
			  -- this implementation of the ZPU *always* reads and writes entire
			  -- 32 bit words, so mem_writeMask is tied to (others => '1').
	 		  mem_writeMask: out std_logic_vector(wordBytes-1 downto 0);
	 		  -- Set to one to jump to interrupt vector
	 		  -- The ZPU will communicate with the hardware that caused the
	 		  -- interrupt via memory mapped IO or the interrupt flag can
	 		  -- be cleared automatically
	 		  interrupt : in std_logic;
	 		  -- Signal that the break instruction is executed, normally only used
	 		  -- in simulation to stop simulation
	 		  break : out std_logic);
end zpu_core;

architecture behave of zpu_core is

signal		readIO : std_logic;



signal memAWriteEnable : std_logic;
signal memAAddr : unsigned(maxAddrBit downto minAddrBit);
signal memAWrite : unsigned(wordSize-1 downto 0);
signal memARead : unsigned(wordSize-1 downto 0);
signal memBWriteEnable : std_logic;
signal memBAddr : unsigned(maxAddrBit downto minAddrBit);
signal memBWrite : unsigned(wordSize-1 downto 0);
signal memBRead : unsigned(wordSize-1 downto 0);



signal	pc				: unsigned(maxAddrBit downto 0);
signal	sp				: unsigned(maxAddrBit downto minAddrBit);

-- this signal is set upon executing an IM instruction
-- the subsequence IM instruction will then behave differently.
-- all other instructions will clear the idim_flag.
-- this yields highly compact immediate instructions.
signal	idim_flag			: std_logic;

signal	busy 				: std_logic;

signal	begin_inst			: std_logic;



signal trace_opcode		: std_logic_vector(7 downto 0);
signal	trace_pc				: std_logic_vector(maxAddrBitIncIO downto 0);
signal	trace_sp				: std_logic_vector(maxAddrBitIncIO downto minAddrBit);
signal	trace_topOfStack				: std_logic_vector(wordSize-1 downto 0);
signal	trace_topOfStackB				: std_logic_vector(wordSize-1 downto 0);

-- state machine.
type State_Type is
(
State_Fetch,
State_WriteIODone,
State_Execute,
State_StoreToStack,
State_Add,
State_Or,
State_And,
State_Store,
State_ReadIO,
State_WriteIO,
State_Load,
State_FetchNext,
State_AddSP,
State_ReadIODone,
State_Decode,
State_Resync,
State_Interrupt

);

type DecodedOpcodeType is
(
Decoded_Nop,
Decoded_Im,
Decoded_ImShift,
Decoded_LoadSP,
Decoded_StoreSP	,
Decoded_AddSP,
Decoded_Emulate,
Decoded_Break,
Decoded_PushSP,
Decoded_PopPC,
Decoded_Add,
Decoded_Or,
Decoded_And,
Decoded_Load,
Decoded_Not,
Decoded_Flip,
Decoded_Store,
Decoded_PopSP,
Decoded_Interrupt
);



signal sampledOpcode : std_logic_vector(OpCode_Size-1 downto 0);
signal opcode : std_logic_vector(OpCode_Size-1 downto 0);

signal decodedOpcode : DecodedOpcodeType;
signal sampledDecodedOpcode : DecodedOpcodeType;


signal state : State_Type;

subtype AddrBitBRAM_range is natural range maxAddrBitBRAM downto minAddrBit;
signal memAAddr_stdlogic  : std_logic_vector(AddrBitBRAM_range);
signal memAWrite_stdlogic : std_logic_vector(memAWrite'range);
signal memARead_stdlogic  : std_logic_vector(memARead'range);
signal memBAddr_stdlogic  : std_logic_vector(AddrBitBRAM_range);
signal memBWrite_stdlogic : std_logic_vector(memBWrite'range);
signal memBRead_stdlogic  : std_logic_vector(memBRead'range);

subtype index is integer range 0 to 3;

signal tOpcode_sel : index;


signal inInterrupt : std_logic;



begin

	-- generate a trace file.
	-- 
	-- This is only used in simulation to see what instructions are
	-- executed. 
	--
	-- a quick & dirty regression test is then to commit trace files
	-- to CVS and compare the latest trace file against the last known
	-- good trace file
	traceFileGenerate:
   if Generate_Trace generate
	trace_file: trace port map (
       	clk => clk,
       	begin_inst => begin_inst,
       	pc => trace_pc,
		opcode => trace_opcode,
		sp => trace_sp,
		memA => trace_topOfStack,
		memB => trace_topOfStackB,
		busy => busy,
		intsp => (others => 'U')
        );
	end generate;



    -- mem_writeMask is not used in this design, tie it to 1
    mem_writeMask <= (others => '1');



	memAAddr_stdlogic  <= std_logic_vector(memAAddr(AddrBitBRAM_range));
	memAWrite_stdlogic <= std_logic_vector(memAWrite);
	memBAddr_stdlogic  <= std_logic_vector(memBAddr(AddrBitBRAM_range));
	memBWrite_stdlogic <= std_logic_vector(memBWrite);
	
	
	-- dualport_ram must be defined by the application. 
	-- 
	-- How this can be implemented is highly dependent on the FPGA
	-- and synthesis technology used. 
	--
	-- sometimes it can be instantiated as in the 
	-- zpu/example/helloworld.vhd, using inference,
	-- but oftentimes it must be instantiated directly
	-- portmapping to part specific FPGA resources
	-- 
	--
	-- DANGER!!!!!! If inference fails, then synthesis will try
	-- to implement the memory using basic logic resources. This
	-- will almost certainly cause the compiler to get "stuck"
	-- since synthesising such a huge number of basic logic resources
	-- will take more or less forever.
	--
	-- So: if your compiler gets "stuck" then inference is not
	-- the way to go.
	memory: dualport_ram port map (
       	clk => clk,
	memAWriteEnable => memAWriteEnable,
	memAAddr => memAAddr_stdlogic,
	memAWrite => memAWrite_stdlogic,
	memARead => memARead_stdlogic,
	memBWriteEnable => memBWriteEnable,
	memBAddr => memBAddr_stdlogic,
	memBWrite => memBWrite_stdlogic,
	memBRead => memBRead_stdlogic
        );
	memARead <= unsigned(memARead_stdlogic);
	memBRead <= unsigned(memBRead_stdlogic);



	tOpcode_sel <= to_integer(pc(minAddrBit-1 downto 0));



	-- move out calculation of the opcode to a seperate process
	-- to make things a bit easier to read
	decodeControl:
	process(memBRead, pc,tOpcode_sel)
		variable tOpcode : std_logic_vector(OpCode_Size-1 downto 0);
	begin

        -- simplify opcode selection a bit so it passes more synthesizers
        case (tOpcode_sel) is

            when 0 => tOpcode := std_logic_vector(memBRead(31 downto 24));

            when 1 => tOpcode := std_logic_vector(memBRead(23 downto 16));

            when 2 => tOpcode := std_logic_vector(memBRead(15 downto 8));

            when 3 => tOpcode := std_logic_vector(memBRead(7 downto 0));

            when others => tOpcode := std_logic_vector(memBRead(7 downto 0));
        end case;

		sampledOpcode <= tOpcode;

		if (tOpcode(7 downto 7)=OpCode_Im) then
			sampledDecodedOpcode<=Decoded_Im;
		elsif (tOpcode(7 downto 5)=OpCode_StoreSP) then
			sampledDecodedOpcode<=Decoded_StoreSP;
		elsif (tOpcode(7 downto 5)=OpCode_LoadSP) then
			sampledDecodedOpcode<=Decoded_LoadSP;
		elsif (tOpcode(7 downto 5)=OpCode_Emulate) then
			sampledDecodedOpcode<=Decoded_Emulate;
		elsif (tOpcode(7 downto 4)=OpCode_AddSP) then
			sampledDecodedOpcode<=Decoded_AddSP;
		else
			case tOpcode(3 downto 0) is
				when OpCode_Break =>
					sampledDecodedOpcode<=Decoded_Break;
				when OpCode_PushSP =>
					sampledDecodedOpcode<=Decoded_PushSP;
				when OpCode_PopPC =>
					sampledDecodedOpcode<=Decoded_PopPC;
				when OpCode_Add =>
					sampledDecodedOpcode<=Decoded_Add;
				when OpCode_Or =>
					sampledDecodedOpcode<=Decoded_Or;
				when OpCode_And =>
					sampledDecodedOpcode<=Decoded_And;
				when OpCode_Load =>
					sampledDecodedOpcode<=Decoded_Load;
				when OpCode_Not =>
					sampledDecodedOpcode<=Decoded_Not;
				when OpCode_Flip =>
					sampledDecodedOpcode<=Decoded_Flip;
				when OpCode_Store =>
					sampledDecodedOpcode<=Decoded_Store;
				when OpCode_PopSP =>
					sampledDecodedOpcode<=Decoded_PopSP;
				when others =>
					sampledDecodedOpcode<=Decoded_Nop;
			end case;
		end if;
	end process;


	opcodeControl:
	process(clk, areset)
		variable spOffset : unsigned(4 downto 0);
	begin
		if areset = '1' then
			state <= State_Resync;
			break <= '0';
			sp <= unsigned(spStart(maxAddrBit downto minAddrBit));
			pc <= (others => '0');
			idim_flag <= '0';
			begin_inst <= '0';
			memAAddr <= (others => '0');
			memBAddr <= (others => '0');
			memAWriteEnable <= '0';
			memBWriteEnable <= '0';
			out_mem_writeEnable <= '0';
			out_mem_readEnable <= '0';
			memAWrite <= (others => '0');
			memBWrite <= (others => '0');
			inInterrupt <= '0';
		elsif (clk'event and clk = '1') then
			memAWriteEnable <= '0';
			memBWriteEnable <= '0';
			-- This saves ca. 100 LUT's, by explicitly declaring that the
            -- memAWrite can be left at whatever value if memAWriteEnable is
			-- not set.
			memAWrite <= (others => DontCareValue);
			memBWrite <= (others => DontCareValue);
--			out_mem_addr <= (others => DontCareValue);
--			mem_write <= (others => DontCareValue);
			spOffset := (others => DontCareValue);
			memAAddr <= (others => DontCareValue);
			memBAddr <= (others => DontCareValue);
			
			out_mem_writeEnable <= '0';
			out_mem_readEnable <= '0';
			begin_inst <= '0';
			out_mem_addr <= std_logic_vector(memARead(maxAddrBitIncIO downto 0));
			mem_write <= std_logic_vector(memBRead);
			
			decodedOpcode <= sampledDecodedOpcode;
			opcode <= sampledOpcode;
			if interrupt='0' then
				inInterrupt <= '0'; -- no longer in an interrupt
			end if;

			case state is
				when State_Execute =>
					state <= State_Fetch;
					-- at this point:
					-- memBRead contains opcode word
					-- memARead contains top of stack
					pc <= pc + 1;
	
					-- trace
					begin_inst <= '1';
					trace_pc <= (others => '0');
					trace_pc(maxAddrBit downto 0) <= std_logic_vector(pc);
					trace_opcode <= opcode;
					trace_sp <= (others => '0');
					trace_sp(maxAddrBit downto minAddrBit) <= std_logic_vector(sp);
					trace_topOfStack <= std_logic_vector(memARead);
					trace_topOfStackB <= std_logic_vector(memBRead);

					-- during the next cycle we'll be reading the next opcode	
					spOffset(4):=not opcode(4);
					spOffset(3 downto 0) := unsigned(opcode(3 downto 0));
	
					idim_flag <= '0';
					case decodedOpcode is
						when Decoded_Interrupt =>
							sp <= sp - 1;
							memAAddr <= sp - 1;
							memAWriteEnable <= '1';
							memAWrite <= (others => DontCareValue);
							memAWrite(maxAddrBit downto 0) <= pc;
							pc <= to_unsigned(32, maxAddrBit+1); -- interrupt address
			  				report "ZPU jumped to interrupt!" severity note;
						when Decoded_Im =>
							idim_flag <= '1';
							memAWriteEnable <= '1';
							if (idim_flag='0') then
								sp <= sp - 1;
								memAAddr <= sp-1;
								for i in wordSize-1 downto 7 loop
									memAWrite(i) <= opcode(6);
								end loop;
								memAWrite(6 downto 0) <= unsigned(opcode(6 downto 0));
							else
								memAAddr <= sp;
								memAWrite(wordSize-1 downto 7) <= memARead(wordSize-8 downto 0);
								memAWrite(6 downto 0) <= unsigned(opcode(6 downto 0));
							end if;
						when Decoded_StoreSP =>
							memBWriteEnable <= '1';
							memBAddr <= sp+spOffset;
							memBWrite <= memARead;
							sp <= sp + 1;
							state <= State_Resync;
						when Decoded_LoadSP =>
							sp <= sp - 1;
							memAAddr <= sp+spOffset;
						when Decoded_Emulate =>
							sp <= sp - 1;
							memAWriteEnable <= '1';
							memAAddr <= sp - 1;
							memAWrite <= (others => DontCareValue);
							memAWrite(maxAddrBit downto 0) <= pc + 1;
							-- The emulate address is:
							--        98 7654 3210
							-- 0000 00aa aaa0 0000
							pc <= (others => '0');
							pc(9 downto 5) <= unsigned(opcode(4 downto 0));
						when Decoded_AddSP =>
							memAAddr <= sp;
							memBAddr <= sp+spOffset;
							state <= State_AddSP;
						when Decoded_Break =>
							report "Break instruction encountered" severity failure;
							break <= '1';
						when Decoded_PushSP =>
							memAWriteEnable <= '1';
							memAAddr <= sp - 1;
							sp <= sp - 1;
							memAWrite <= (others => DontCareValue);
							memAWrite(maxAddrBit downto minAddrBit) <= sp;
						when Decoded_PopPC =>
							pc <= memARead(maxAddrBit downto 0);
							sp <= sp + 1;
							state <= State_Resync;
						when Decoded_Add =>
							sp <= sp + 1;
							state <= State_Add;
						when Decoded_Or =>
							sp <= sp + 1;
							state <= State_Or;
						when Decoded_And =>
							sp <= sp + 1;
							state <= State_And;
						when Decoded_Load =>
							if (memARead(ioBit)='1') then
								out_mem_addr <= std_logic_vector(memARead(maxAddrBitIncIO downto 0));
								out_mem_readEnable <= '1';
								state <= State_ReadIO;
							else 
								memAAddr <= memARead(maxAddrBit downto minAddrBit);
							end if;
						when Decoded_Not =>
							memAAddr <= sp(maxAddrBit downto minAddrBit);
							memAWriteEnable <= '1';
							memAWrite <= not memARead;
						when Decoded_Flip =>
							memAAddr <= sp(maxAddrBit downto minAddrBit);
							memAWriteEnable <= '1';
							for i in 0 to wordSize-1 loop
								memAWrite(i) <= memARead(wordSize-1-i);
				  			end loop;
						when Decoded_Store =>
							memBAddr <= sp + 1;
							sp <= sp + 1;
							if (memARead(ioBit)='1') then
								state <= State_WriteIO;
							else
								state <= State_Store;
							end if;
						when Decoded_PopSP =>
							sp <= memARead(maxAddrBit downto minAddrBit);
							state <= State_Resync;
						when Decoded_Nop =>	
							memAAddr <= sp;
						when others =>	
							null; 
					end case;
				when State_ReadIO =>
					if (in_mem_busy = '0') then
						state <= State_Fetch;
						memAWriteEnable <= '1';
						memAWrite <= unsigned(mem_read);
					end if;
				when State_WriteIO =>
					sp <= sp + 1;
					out_mem_writeEnable <= '1';
					out_mem_addr <= std_logic_vector(memARead(maxAddrBitIncIO downto 0));
					mem_write <= std_logic_vector(memBRead);
					state <= State_WriteIODone;
				when State_WriteIODone =>
					if (in_mem_busy = '0') then
						state <= State_Resync;
					end if;
				when State_Fetch =>
					-- We need to resync. During the *next* cycle
					-- we'll fetch the opcode @ pc and thus it will
					-- be available for State_Execute the cycle after
					-- next
					memBAddr <= pc(maxAddrBit downto minAddrBit);
					state <= State_FetchNext;
				when State_FetchNext =>
					-- at this point memARead contains the value that is either
					-- from the top of stack or should be copied to the top of the stack
					memAWriteEnable <= '1';
					memAWrite <= memARead; 
					memAAddr <= sp;
					memBAddr <= sp + 1;
					state <= State_Decode;
				when State_Decode =>
					if interrupt='1' and inInterrupt='0' and idim_flag='0' then
						-- We got an interrupt, execute interrupt instead of next instruction
						inInterrupt <= '1';
						decodedOpcode <= Decoded_Interrupt;
					end if;
					-- during the State_Execute cycle we'll be fetching SP+1
					memAAddr <= sp;
					memBAddr <= sp + 1;
					state <= State_Execute;
				when State_Store =>
					sp <= sp + 1;
					memAWriteEnable <= '1';
					memAAddr <= memARead(maxAddrBit downto minAddrBit);
					memAWrite <= memBRead;
					state <= State_Resync;
				when State_AddSP =>
					state <= State_Add;
				when State_Add =>
					memAAddr <= sp;
					memAWriteEnable <= '1';
					memAWrite <= memARead + memBRead;
					state <= State_Fetch;
				when State_Or =>
					memAAddr <= sp;
					memAWriteEnable <= '1';
					memAWrite <= memARead or memBRead;
					state <= State_Fetch;
				when State_Resync =>
					memAAddr <= sp;
					state <= State_Fetch;
				when State_And =>
					memAAddr <= sp;
					memAWriteEnable <= '1';
					memAWrite <= memARead and memBRead;
					state <= State_Fetch;
				when others =>
					null;
			end case;
			
		end if;
	end process;



end behave;
