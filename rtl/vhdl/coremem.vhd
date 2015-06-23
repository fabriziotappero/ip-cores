----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    12:27:16 02/09/2009 
-- Design Name: 
-- Module Name:    coremem - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--   TODO: Convert to use Xilinx instantiation, because the 18-bit wide memory
--         gets converted to 4 1k*16 and 1 4k*2, wasting a block ram.
--         This is because Xilinx tools do not automatically use the parity bits.
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.STD_LOGIC_TEXTIO.ALL;
use STD.TEXTIO.ALL;

---- For instantiating Xilinx block RAMs
--library UNISIM;
--use UNISIM.VComponents.all;

entity coremem is
    Port ( A : in  STD_LOGIC_VECTOR (0 to 11);
           CLK : in  STD_LOGIC;
			  -- The PDP-1 can write to high 6 bits, low 12 bits, or both.
			  -- To emulate this we need a higher clock to do load-modify-store.
			  -- TODO: Actually, the PDP-1 rewrites after every read, giving it the
			  -- opportunity to read-modify-write itself, and does so for Index.
			  -- So the memory is simpler, runs load/store at double rate,
			  -- but the CPU needs a matching redesign.
           WE : in  STD_LOGIC;
			  ENABLE : in STD_LOGIC := '1';
           DI : in  STD_LOGIC_VECTOR (0 to 17);
			  -- DO defaults to jump to 0 instruction
           DO : out  STD_LOGIC_VECTOR (0 to 17) := o"76_4200"	-- match core(0)!
		);
end coremem;

architecture Behavioral of coremem is
	constant ADDR_WIDTH : integer := 12;
	constant DATA_WIDTH : integer := 18;

	subtype word is std_logic_vector(0 to DATA_WIDTH-1);
        -- important: if downto is used, the code lines must be written backwards!
	type coremodule is array (0 to 2**ADDR_WIDTH-1) of word;

	-- only works for very small initial programs.
	impure function loadcore (filename : in string) return coremodule is
		FILE corefile		: text is in filename;
		variable coreline	: line;
		variable core		: coremodule := (others=>o"00_0000");
                variable addr : integer := 0;
        begin
          --file_open(corefile, filename, READ_MODE);
          for addr in coremodule'range loop
          --while (not endfile(corefile)) and (addr<2**ADDR_WIDTH) loop
            if not endfile(corefile) then
              readline (corefile, coreline);
              oread (coreline, core(addr));
              --addr := addr+1;
            end if;
          end loop;
          -- FIXME this isn't very robust, it breaks if there's an empty line
          --file_close(corefile);
          return core;
        end function;

	---- Xilinx IP generator version
	--component xilinx_core
	--port (
	--	clka: IN std_logic;
	--	wea: IN std_logic_VECTOR(0 downto 0);
	--	addra: IN std_logic_VECTOR(11 downto 0);
	--	dina: IN std_logic_VECTOR(17 downto 0);
	--	douta: OUT std_logic_VECTOR(17 downto 0));
	--end component;
	--signal wea: std_logic_vector(0 to 0);

	---- Synplicity black box declaration
	--attribute syn_black_box : boolean;
	--attribute syn_black_box of xilinx_core: component is true;

	signal core: coremodule :=
          --loadcore("testdpy.octal");
          --loadcore("spacewar.octal");
          (
            -- tape reader test program
            --o"73_0001",                 -- read paper alphanumeric with wait
            --o"76_0000",                 -- NOP
            --o"66_6777",                 -- shift left 9 bits
            --o"66_6001",                 -- and 1 bit, leaving the read byte at
            --                            -- left edge of IO register
            --o"60_0003",                 -- infinite loop to light AWAKE

            -- counter test program (loads result into IO for display)
            --o"60_0003",                 -- jump past constant
            --o"00_0001",                 -- constant one
            --o"00_0000",                 -- variable
            --o"40_0001",                 -- add one to AC
            --o"24_0002",                 -- store in memory
            --o"22_0002",                 -- load into IO

            --o"60_0000",                 -- jump back to start of program

            -- tape read in emulation (see readin.mac)
            8#0000# => o"60_7700",                 -- jump to program
            8#7700# => o"73_0002",                 -- read paper binary
            8#7701# => o"32_7706",                 -- deposit instruction just read
            8#7702# => o"20_7706",                 -- read into AC
            8#7703# => o"26_7710",                 -- deposit address into DIO for comparison
            8#7704# => o"50_7710",                 -- skip read if instruction not DIO
            8#7705# => o"73_0002",                 -- read word to be deposited
            8#7706# => o"76_0400",                 -- overwritten instruction; initially halt
            8#7707# => o"60_7700",                 -- repeat the loop
            8#7710# => o"32_0000",                 -- deposit IO for comparison
            
            others => o"60_0000"
            );  
          
--        signal unused : coremodule :=
--		(
--			o"60_0010",		-- jump past constants and variables
--			o"37_7400",		-- value to switch direction on
--			o"00_0000",		-- unused
--			o"00_0400",		-- step							-- addr 0003
--
--			o"00_0000",		-- variable
--			o"00_0000",		-- padding
--			o"00_0000",		-- padding
--			o"00_0000",		-- padding
--			
--			o"76_4200",		-- clear AC and IO			-- addr 0010 (start)
--			o"40_0003", 	-- add step to AC				-- addr 0011 (loop)
--			o"24_0004",		-- store AC to variable
--			o"22_0004",		-- load count to IO
--			o"76_1000",		-- complement AC
--			o"73_0007",		-- display, with waiting
--			o"76_1000",		-- switch AC back
--			o"52_0001",		-- skip next instruction if AC=endpoint
--			o"60_0011",		-- jump to beginning of loop
--			o"20_0001",		-- load endpoint
--			o"76_1000",		-- complement it
--			o"24_0001",		-- store it back
--			o"20_0003",		-- load step
--			o"76_1000",		-- complement it
--			o"24_0003",		-- store it back
--			o"20_0004",		-- load count again
--			o"60_0011",		-- jump back to loop
--			others => o"00_0000"
--		);

begin
	process (CLK)
	begin
		if (CLK'event and CLK = '1') then
			if (enable = '1') then 
				if (WE = '1') then
					core(conv_integer(A)) <= DI;
				end if;
				DO <= core(conv_integer(A));
			end if;
		end if;
	end process;
	--wea(0)<=we;
	--xil_core : xilinx_core
	--	port map (
	--		clka => clk,
	--		wea => wea,
	--		addra => a,
	--		dina => di,
	--		douta => do);
end Behavioral;

