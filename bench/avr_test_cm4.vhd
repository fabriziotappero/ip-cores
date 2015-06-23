--------------------------------------------------------------
--	Simple testbench for AVR CM4 core running program_a.dec,
--	program_b.dec, program_c.dec and program_d.dec
--------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.std_logic_arith.all;
USE IEEE.std_logic_textio.all;
USE std.textio.all;
USE WORK.all;
LIBRARY STD;
USE STD.TEXTIO.ALL;

entity avr_cm4_test is
end avr_cm4_test;

architecture behavioral of avr_cm4_test is

constant MAX_ROM_SIZE : positive := 512;
constant MAX_RAM_SIZE : positive := 65536;
file inFile_a : Text open read_mode is "program_a.dec";
file inFile_b : Text open read_mode is "program_b.dec";
file inFile_c : Text open read_mode is "program_c.dec";
file inFile_d : Text open read_mode is "program_d.dec";

signal system_clk	: std_logic;
signal system_reset : Std_logic := '0';
signal cp2 : std_logic;
signal cp2_cml_1 : std_logic;
signal cp2_cml_2 : std_logic;
signal cp2_cml_3 : std_logic;
signal cmls : integer range 0 to 3 := 3;
signal cml0_clk : std_logic;
signal cml1_clk : std_logic;
signal cml2_clk : std_logic;
signal cml3_clk : std_logic;
signal cml0_reset : std_logic := '0';
signal cml1_reset : std_logic := '0';
signal cml2_reset : std_logic := '0';
signal cml3_reset : std_logic := '0';
signal disable_second : std_logic;

signal core_pc_0   : std_logic_vector (15 downto 0); 
signal core_pc_1   : std_logic_vector (15 downto 0); 
signal core_pc_2   : std_logic_vector (15 downto 0); 
signal core_pc_3   : std_logic_vector (15 downto 0); 

signal ireset : std_logic;
signal gnd : std_logic;
signal vcc : std_logic;
signal core_pc : std_logic_vector (15 downto 0); 
signal core_inst : std_logic_vector (15 downto 0); 
signal core_adr : std_logic_vector (5 downto 0);
signal core_iore : std_logic;                    
signal core_iowe : std_logic;
signal core_ramadr : std_logic_vector (15 downto 0);
signal core_ramadr_0 : std_logic_vector (15 downto 0);
signal core_ramadr_1 : std_logic_vector (15 downto 0);
signal core_ramadr_2 : std_logic_vector (15 downto 0);
signal core_ramadr_3 : std_logic_vector (15 downto 0);
signal core_ramre : std_logic;
signal core_ramre_0 : std_logic;
signal core_ramre_1 : std_logic;
signal core_ramre_2 : std_logic;
signal core_ramre_3 : std_logic;
signal core_ramwe : std_logic;
signal core_ramwe_0 : std_logic;
signal core_ramwe_1 : std_logic;
signal core_ramwe_2 : std_logic;
signal core_ramwe_3 : std_logic;
signal core_cpuwait : std_logic;                    
signal core_dbusin : std_logic_vector (7 downto 0);
signal core_dbusout : std_logic_vector (7 downto 0);
signal core_irqlines : std_logic_vector(22 downto 0);
signal core_irqack : std_logic;
signal core_irqackad : std_logic_vector(4 downto 0);
signal sleepi : std_logic;
signal irqok : std_logic;
signal globint : std_logic;
signal core_wdri : std_logic; 

component AVR_Core is port(
	--Clock and reset
		cp2 : in  std_logic;
		cp2en : in  std_logic;
		ireset : in  std_logic;
	-- JTAG OCD support
		valid_instr : out std_logic;
		insert_nop : in  std_logic; 
		block_irq : in  std_logic;
		change_flow : out std_logic;
	-- Program Memory
		pc : out std_logic_vector(15 downto 0);   
		inst : in  std_logic_vector(15 downto 0);
	-- I/O control
		adr : out std_logic_vector(5 downto 0); 	
		iore : out std_logic;                       
		iowe : out std_logic;						
	-- Data memory control
		ramadr : out std_logic_vector(15 downto 0);
		ramre : out std_logic;
		ramwe : out std_logic;
		cpuwait : in  std_logic;
	-- Data paths
		dbusin : in  std_logic_vector(7 downto 0);
		dbusout : out std_logic_vector(7 downto 0);
	-- Interrupt
		irqlines : in  std_logic_vector(22 downto 0);
		irqack : out std_logic;
		irqackad : out std_logic_vector(4 downto 0);
	--Sleep Control
		sleepi : out std_logic;
		irqok	: out std_logic;
		globint : out std_logic;
	--Watchdog
		wdri : out std_logic);
end component;

component AVR_Core_cm4 is port(
		cp2_cml_1 : in std_logic;
		cp2_cml_2 : in std_logic;
		cp2_cml_3 : in std_logic;
	--Clock and reset
		cp2 : in  std_logic;
		cp2en : in  std_logic;
		ireset : in  std_logic;
	-- JTAG OCD support
		valid_instr : out std_logic;
		insert_nop : in  std_logic; 
		block_irq : in  std_logic;
		change_flow : out std_logic;
	-- Program Memory
		pc : out std_logic_vector(15 downto 0);   
		inst : in  std_logic_vector(15 downto 0);
	-- I/O control
		adr : out std_logic_vector(5 downto 0); 	
		iore : out std_logic;                       
		iowe : out std_logic;						
	-- Data memory control
		ramadr : out std_logic_vector(15 downto 0);
		ramre : out std_logic;
		ramwe : out std_logic;
		cpuwait : in  std_logic;
	-- Data paths
		dbusin : in  std_logic_vector(7 downto 0);
		dbusout : out std_logic_vector(7 downto 0);
	-- Interrupt
		irqlines : in  std_logic_vector(22 downto 0);
		irqack : out std_logic;
		irqackad : out std_logic_vector(4 downto 0);
	--Sleep Control
		sleepi : out std_logic;
		irqok	: out std_logic;
		globint : out std_logic;
	--Watchdog
		wdri : out std_logic);
end component;

TYPE std_logic_array_rom IS ARRAY (INTEGER RANGE 0 to (4 * MAX_ROM_SIZE) - 1) of Std_logic_vector(15 downto 0);
SIGNAL rom_array :Std_logic_array_rom;
TYPE std_logic_array_ram IS ARRAY (INTEGER RANGE 0 to (4 * MAX_RAM_SIZE) - 1) of Std_logic_vector(7 downto 0);
SIGNAL ram_array :Std_logic_array_ram;


BEGIN

------------------------------------------------------------------------
--	CMLS indicates current pipe
--	clocks for AVR Core CM3
------------------------------------------------------------------------
cmls_gen : process (system_clk)
begin
if (system_clk'event and system_clk = '1') then
	cp2 <= system_clk;
	cp2_cml_1 <= system_clk;
	cp2_cml_2 <= system_clk;
	cp2_cml_3 <= system_clk;
	if (cmls = 3) then 
		cmls <= 0; 
	else 
		cmls <= cmls + 1; 
	end if;
end if;
if (system_clk'event and system_clk = '0') then
	cp2 <= '0';
	cp2_cml_1 <= '0';
	cp2_cml_2 <= '0';
	cp2_cml_3 <= '0';
end if;
end process;

------------------------------------------------------------------------
--	stimuli
------------------------------------------------------------------------
vcc <= '1';
gnd <= '0';
core_cpuwait <= '0';
core_irqlines <= "00000000000000000000000";

------------------------------------------------------------------------
--	ROM
------------------------------------------------------------------------
rom_read_gen:PROCESS
variable thisInt : integer range 0 to 65535;
variable i: integer;
variable inLine: Line;
BEGIN
	readline(inFile_a, inLine);
	read(inLine, thisInt);
	for i in 0 to thisInt - 1 loop
		readline(inFile_a, inLine);
		read(inLine, thisInt);
		rom_array(i) <= conv_std_logic_vector(conv_unsigned(thisInt, 16), 16);
	end loop;
	readline(inFile_b, inLine);
	read(inLine, thisInt);
	for i in 0 to thisInt - 1 loop
		readline(inFile_b, inLine);
		read(inLine, thisInt);
		rom_array(MAX_ROM_SIZE + i) <= conv_std_logic_vector(conv_unsigned(thisInt, 16), 16);
	end loop;
	readline(inFile_c, inLine);
	read(inLine, thisInt);
	for i in 0 to thisInt - 1 loop
		readline(inFile_c, inLine);
		read(inLine, thisInt);
		rom_array((2 * MAX_ROM_SIZE) + i) <= conv_std_logic_vector(conv_unsigned(thisInt, 16), 16);
	end loop;
	readline(inFile_d, inLine);
	read(inLine, thisInt);
	for i in 0 to thisInt - 1 loop
		readline(inFile_d, inLine);
		read(inLine, thisInt);
		rom_array((3 * MAX_ROM_SIZE) + i) <= conv_std_logic_vector(conv_unsigned(thisInt, 16), 16);
	end loop;
      WAIT FOR 8000 ms;
end process;

core_inst_gen : PROCESS(core_pc, cmls)
BEGIN
	if (cmls = 3) then
		core_inst <=	rom_array(conv_integer(unsigned(core_pc)))(7 downto 0) & 
					rom_array(conv_integer(unsigned(core_pc)))(15 downto 8);
	else
	if (cmls = 0) then
		core_inst <=	rom_array(MAX_ROM_SIZE + conv_integer(unsigned(core_pc)))(7 downto 0) & 
					rom_array(MAX_ROM_SIZE + conv_integer(unsigned(core_pc)))(15 downto 8);
	else
	if (cmls = 1) then
		core_inst <=	rom_array((2 * MAX_ROM_SIZE) + conv_integer(unsigned(core_pc)))(7 downto 0) & 
					rom_array((2 * MAX_ROM_SIZE) + conv_integer(unsigned(core_pc)))(15 downto 8);
	else
		core_inst <=	rom_array((3 * MAX_ROM_SIZE) + conv_integer(unsigned(core_pc)))(7 downto 0) & 
					rom_array((3 * MAX_ROM_SIZE) + conv_integer(unsigned(core_pc)))(15 downto 8);
	end if;
	end if;
	end if;
end process;

------------------------------------------------------------------------
--	RAM
------------------------------------------------------------------------
ram_gen : PROCESS(system_clk, system_reset)
variable i: integer;
BEGIN
if (system_reset = '0') then
	if (disable_second = '0') then
		for i in 0 to ((4 * MAX_RAM_SIZE) - 1) loop
			ram_array(i) <= conv_std_logic_vector(0, 8);
		end loop;
	end if;
else
if (system_clk'event and system_clk = '1') then
	if (core_ramwe = '1') then
		if (cmls = 0) then
			ram_array(conv_integer(unsigned(core_ramadr))) <= core_dbusout;
		else
		if (cmls = 1) then
			ram_array(MAX_RAM_SIZE + conv_integer(unsigned(core_ramadr))) <= core_dbusout;
		else
		if (cmls = 2) then
			ram_array((2 * MAX_RAM_SIZE) + conv_integer(unsigned(core_ramadr))) <= core_dbusout;
		else
			ram_array((3 * MAX_RAM_SIZE) + conv_integer(unsigned(core_ramadr))) <= core_dbusout;
		end if;
		end if;
		end if;
	end if;
end if;
end if;
end process;

core_dbusin <= 	ram_array(conv_integer(unsigned(core_ramadr)))	when (cmls = 0) else
			ram_array(MAX_RAM_SIZE + conv_integer(unsigned(core_ramadr))) when (cmls = 1) else
			ram_array((2 * MAX_RAM_SIZE) + conv_integer(unsigned(core_ramadr))) when (cmls = 2) else
			ram_array((3 * MAX_RAM_SIZE) + conv_integer(unsigned(core_ramadr))) ;



------------------------------------------------------------------------
--	system_clk
------------------------------------------------------------------------
clk_gen:PROCESS
VARIABLE lin:line;
   BEGIN
      system_clk <= '1';
      WAIT FOR 12 ns;
      system_clk <= '0';
      WAIT FOR 12 ns;
   END PROCESS;

------------------------------------------------------------------------
--	system_reset and kill/restart second core
------------------------------------------------------------------------
reset_gen:PROCESS
   BEGIN
      system_reset <= '0';
	disable_second <= '0';
      WAIT FOR 65 ns;
      system_reset <= '1' ;
      WAIT FOR 100000 ns;
	WAIT UNTIL (cmls = 0);
	disable_second <= '1';
      WAIT FOR 100000 ns;
	WAIT UNTIL (cmls = 3);
	WAIT UNTIL (system_clk = '1');
      system_reset <= '0';
	WAIT UNTIL (system_clk = '0');
      WAIT FOR 2 ns;
      system_reset <= '1' ;
      WAIT FOR 2 ns;
	disable_second <= '0';
      WAIT FOR 100000 ns;
      ASSERT false REPORT "test passed, done !!!" severity failure;
   END PROCESS;

------------------------------------------------------------------------
--	AVR_Core CM4
------------------------------------------------------------------------
AVR_Core_Inst_cm4:  AVR_Core_cm4 port map(
		cp2_cml_1 => cp2_cml_1,
		cp2_cml_2 => cp2_cml_2,
		cp2_cml_3 => cp2_cml_3,
	--Clock and reset
		cp2 => cp2,
		cp2en => vcc,
		ireset => ireset,
	-- JTAG OCD support
		valid_instr => open,
		insert_nop => gnd,
		block_irq => gnd,
		change_flow => open,
	-- Program Memory
		pc => core_pc,
		inst => core_inst,
	-- I/O control
		adr => core_adr,
		iore => core_iore,
		iowe => core_iowe,
	-- Data memory control
		ramadr => core_ramadr,
		ramre => core_ramre,
		ramwe => core_ramwe,
		cpuwait => core_cpuwait,
	-- Data paths
		dbusin => core_dbusin,
		dbusout => core_dbusout,
	-- Interrupts
		irqlines => core_irqlines, 
		irqack => core_irqack,
		irqackad => core_irqackad, 
	--Sleep Control
		sleepi => sleepi,
		irqok	=> irqok,
		globint => globint,
	--Watchdog
		wdri => core_wdri);


------------------------------------------------------------------------
------------------------------------------------------------------------
------------------------------------------------------------------------
--	Insertion of 4 additional AVR cores for virtual debugging
------------------------------------------------------------------------
------------------------------------------------------------------------
------------------------------------------------------------------------
--	generate individual clocks for AVR 0, 1, 2 and 3
------------------------------------------------------------------------
subckl_gen : process (system_clk)
begin
if (cmls = 3) then
	cml0_clk <= system_clk;
	cml1_clk <= '0';
	cml2_clk <= '0';
	cml3_clk <= '0';
else
if (cmls = 0) then
	cml0_clk <= '0';
	if (disable_second = '0') then
		cml1_clk <= system_clk;
	end if;
	cml2_clk <= '0';
	cml3_clk <= '0';
else
if (cmls = 1) then
	cml0_clk <= '0';
	cml1_clk <= '0';
	cml2_clk <= system_clk;
	cml3_clk <= '0';
else
	cml0_clk <= '0';
	cml1_clk <= '0';
	cml2_clk <= '0';
	cml3_clk <= system_clk;
end if;
end if;
end if;
end process;

------------------------------------------------------------------------
--	generate individual resets for AVR 0, 1, 2 and 3
------------------------------------------------------------------------
system_reset_in_gen : PROCESS(system_clk, system_reset, disable_second)
BEGIN
if (disable_second = '0') then
	if (system_clk'event and system_clk = '0') then
		cml3_reset <= cml2_reset;
		cml2_reset <= cml1_reset;
		cml1_reset <= cml0_reset;
		cml0_reset <= system_reset;
	end if;
else
	cml1_reset <= system_reset;
end if;
end process;

ireset <= cml3_reset AND system_reset;
--ireset <= system_reset;

------------------------------------------------------------------------
--	for processors a comparison of PC is enough
------------------------------------------------------------------------
check_gen : PROCESS(system_clk, system_reset)
BEGIN
if (ireset = '1') then
if (system_clk'event and system_clk = '0') then
	if (cmls = 3) then
		if NOT (core_pc = core_pc_0) then
			ASSERT false REPORT "PC 0 mismatch" severity failure;
		end if;
		if NOT (core_ramadr = core_ramadr_0) then
			ASSERT false REPORT "RAMADR 0 mismatch" severity failure;
		end if;
		if NOT (core_ramre = core_ramre_0) then
			ASSERT false REPORT "RAMRE 0 mismatch" severity failure;
		end if;
		if NOT (core_ramwe = core_ramwe_0) then
			ASSERT false REPORT "RAMWE 0 mismatch" severity failure;
		end if;
	else
	if (cmls = 0) then
		if (disable_second = '0') then
 			if NOT (core_pc = core_pc_1) then
				ASSERT false REPORT "PC 1 mismatch" severity failure;
			end if;
			if NOT (core_ramadr = core_ramadr_1) then
				ASSERT false REPORT "RAMADR 1 mismatch" severity failure;
			end if;
			if NOT (core_ramre = core_ramre_1) then
				ASSERT false REPORT "RAMRE 1 mismatch" severity failure;
			end if;
			if NOT (core_ramwe = core_ramwe_1) then
				ASSERT false REPORT "RAMWE 1 mismatch" severity failure;
			end if;
		end if;
	else
	if (cmls = 1) then
		if NOT (core_pc = core_pc_2) then
			ASSERT false REPORT "PC 2 mismatch" severity failure;
		end if;
		if NOT (core_ramadr = core_ramadr_2) then
			ASSERT false REPORT "RAMADR 2 mismatch" severity failure;
		end if;
		if NOT (core_ramre = core_ramre_2) then
			ASSERT false REPORT "RAMRE 2 mismatch" severity failure;
		end if;
		if NOT (core_ramwe = core_ramwe_2) then
			ASSERT false REPORT "RAMWE 2 mismatch" severity failure;
		end if;
	else
		if NOT (core_pc = core_pc_3) then
			ASSERT false REPORT "PC 3 mismatch" severity failure;
		end if;
		if NOT (core_ramadr = core_ramadr_3) then
			ASSERT false REPORT "RAMADR 3 mismatch" severity failure;
		end if;
		if NOT (core_ramre = core_ramre_3) then
			ASSERT false REPORT "RAMRE 3 mismatch" severity failure;
		end if;
		if NOT (core_ramwe = core_ramwe_3) then
			ASSERT false REPORT "RAMWE 3 mismatch" severity failure;
		end if;
	end if;
	end if;
	end if;
end if;
end if;
end process;


------------------------------------------------------------------------
--	AVR_Core virtual 0
------------------------------------------------------------------------
AVR_Core_Inst_0:  AVR_Core port map(
	--Clock and reset
		cp2 => cml0_clk,
		cp2en => vcc,
		ireset => cml0_reset,
	-- JTAG OCD support
		valid_instr => open,
		insert_nop => gnd,
		block_irq => gnd,
		change_flow => open,
	-- Program Memory
		pc => core_pc_0,
		inst => core_inst,
	-- I/O control
		adr => open,
		iore => open,
		iowe => open,
	-- Data memory control
		ramadr => core_ramadr_0,
		ramre => core_ramre_0,
		ramwe => core_ramwe_0,
		cpuwait => core_cpuwait,
	-- Data paths
		dbusin => core_dbusin,
		dbusout => open,
	-- Interrupts
		irqlines => core_irqlines, 
		irqack => open,
		irqackad => open, 
	--Sleep Control
		sleepi => open,
		irqok	=> open,
		globint => open,
	--Watchdog
		wdri => open);

------------------------------------------------------------------------
--	AVR_Core virtual 1
------------------------------------------------------------------------
AVR_Core_Inst_1:  AVR_Core port map(
	--Clock and reset
		cp2 => cml1_clk,
		cp2en => vcc,
		ireset => cml1_reset,
	-- JTAG OCD support
		valid_instr => open,
		insert_nop => gnd,
		block_irq => gnd,
		change_flow => open,
	-- Program Memory
		pc => core_pc_1,
		inst => core_inst,
	-- I/O control
		adr => open,
		iore => open,
		iowe => open,
	-- Data memory control
		ramadr => core_ramadr_1,
		ramre => core_ramre_1,
		ramwe => core_ramwe_1,
		cpuwait => core_cpuwait,
	-- Data paths
		dbusin => core_dbusin,
		dbusout => open,
	-- Interrupts
		irqlines => core_irqlines, 
		irqack => open,
		irqackad => open, 
	--Sleep Control
		sleepi => open,
		irqok	=> open,
		globint => open,
	--Watchdog
		wdri => open);

------------------------------------------------------------------------
--	AVR_Core virtual 2
------------------------------------------------------------------------
AVR_Core_Inst_2:  AVR_Core port map(
	--Clock and reset
		cp2 => cml2_clk,
		cp2en => vcc,
		ireset => cml2_reset,
	-- JTAG OCD support
		valid_instr => open,
		insert_nop => gnd,
		block_irq => gnd,
		change_flow => open,
	-- Program Memory
		pc => core_pc_2,
		inst => core_inst,
	-- I/O control
		adr => open,
		iore => open,
		iowe => open,
	-- Data memory control
		ramadr => core_ramadr_2,
		ramre => core_ramre_2,
		ramwe => core_ramwe_2,
		cpuwait => core_cpuwait,
	-- Data paths
		dbusin => core_dbusin,
		dbusout => open,
	-- Interrupts
		irqlines => core_irqlines, 
		irqack => open,
		irqackad => open, 
	--Sleep Control
		sleepi => open,
		irqok	=> open,
		globint => open,
	--Watchdog
		wdri => open);

------------------------------------------------------------------------
--	AVR_Core virtual 3
------------------------------------------------------------------------
AVR_Core_Inst_3:  AVR_Core port map(
	--Clock and reset
		cp2 => cml3_clk,
		cp2en => vcc,
		ireset => cml3_reset,
	-- JTAG OCD support
		valid_instr => open,
		insert_nop => gnd,
		block_irq => gnd,
		change_flow => open,
	-- Program Memory
		pc => core_pc_3,
		inst => core_inst,
	-- I/O control
		adr => open,
		iore => open,
		iowe => open,
	-- Data memory control
		ramadr => core_ramadr_3,
		ramre => core_ramre_3,
		ramwe => core_ramwe_3,
		cpuwait => core_cpuwait,
	-- Data paths
		dbusin => core_dbusin,
		dbusout => open,
	-- Interrupts
		irqlines => core_irqlines, 
		irqack => open,
		irqackad => open, 
	--Sleep Control
		sleepi => open,
		irqok	=> open,
		globint => open,
	--Watchdog
		wdri => open);

end behavioral;


