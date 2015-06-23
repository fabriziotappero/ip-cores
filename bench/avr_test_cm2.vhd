--------------------------------------------------------------
--	Simple testbench for AVR CM2 core running program_a.dec
--	and program_b.dec
--------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.std_logic_arith.all;
USE IEEE.std_logic_textio.all;
USE std.textio.all;
USE WORK.all;
LIBRARY STD;
USE STD.TEXTIO.ALL;

entity avr_cm2_test is
end avr_cm2_test;

architecture behavioral of avr_cm2_test is

constant MAX_ROM_SIZE : positive := 256;
constant MAX_RAM_SIZE : positive := 65536;
file inFile_a : Text open read_mode is "program_a.dec";
file inFile_b : Text open read_mode is "program_b.dec";

signal system_clk	: std_logic;
signal system_reset : Std_logic;
signal cp2 : std_logic;
signal cp2_cml_1 : std_logic;
signal cml : integer range 0 to 1;
signal cml0_clk : std_logic;
signal cml1_clk : std_logic;
signal cml0_reset : std_logic;
signal cml1_reset : std_logic;
signal disable_second : std_logic;

signal core_pc_0   : std_logic_vector (15 downto 0); 
signal core_pc_1   : std_logic_vector (15 downto 0); 
signal core_ramadr_0 : std_logic_vector (15 downto 0);
signal core_ramadr_1 : std_logic_vector (15 downto 0);
signal core_ramre_0 : std_logic;
signal core_ramre_1 : std_logic;
signal core_ramwe_0 : std_logic;
signal core_ramwe_1 : std_logic;

signal gnd : std_logic;
signal vcc : std_logic;
signal core_pc : std_logic_vector (15 downto 0); 
signal core_inst : std_logic_vector (15 downto 0); 
signal core_adr : std_logic_vector (5 downto 0);
signal core_iore : std_logic;                    
signal core_iowe : std_logic;
signal core_ramadr : std_logic_vector (15 downto 0);
signal core_ramre : std_logic;
signal core_ramwe : std_logic;
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

component AVR_Core_cm2 is port(
		cp2_cml_1 : in std_logic;
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

TYPE std_logic_array_rom IS ARRAY (INTEGER RANGE 0 to (2 * MAX_ROM_SIZE) - 1) of Std_logic_vector(15 downto 0);
SIGNAL rom_array :Std_logic_array_rom;
TYPE std_logic_array_ram IS ARRAY (INTEGER RANGE 0 to (2 * MAX_RAM_SIZE) - 1) of Std_logic_vector(7 downto 0);
SIGNAL ram_array :Std_logic_array_ram;


BEGIN

------------------------------------------------------------------------
--	CML indicates current pipe
--	clocks for AVR Core CM2
------------------------------------------------------------------------
cml_gen : process (system_clk)
begin
if (system_clk'event and system_clk = '1') then
	if (disable_second = '0') then
		cp2 <= system_clk;
		cp2_cml_1 <= system_clk;
	else
		if (cml = 1) then
			cp2 <= system_clk;
		else
			cp2_cml_1 <= system_clk;
		end if;
	end if;
	if (cml = 1) then 
		cml <= 0; 
	else 
		cml <= 1; 
	end if;
end if;
if (system_clk'event and system_clk = '0') then
	cp2 <= '0';
	cp2_cml_1 <= '0';
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
      WAIT FOR 8000 ms;
end process;

core_inst_gen : PROCESS(core_pc, cml)
BEGIN
	if (cml = 0) then
		core_inst <=	rom_array(conv_integer(unsigned(core_pc)))(7 downto 0) & 
					rom_array(conv_integer(unsigned(core_pc)))(15 downto 8);
	else
		core_inst <=	rom_array(MAX_ROM_SIZE + conv_integer(unsigned(core_pc)))(7 downto 0) & 
					rom_array(MAX_ROM_SIZE + conv_integer(unsigned(core_pc)))(15 downto 8);
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
		for i in 0 to (2 * MAX_RAM_SIZE) - 1 loop
			ram_array(i) <= conv_std_logic_vector(0, 8);
		end loop;
	end if;
else
if (system_clk'event and system_clk = '1') then
	if (core_ramwe = '1') then
		if (cml = 0) then
			ram_array(conv_integer(unsigned(core_ramadr))) <= core_dbusout;
		else
			ram_array(MAX_RAM_SIZE + conv_integer(unsigned(core_ramadr))) <= core_dbusout;
		end if;
	end if;
end if;
end if;
end process;

core_dbusin <= 	ram_array(conv_integer(unsigned(core_ramadr)))	when (cml = 0) else
			ram_array(MAX_RAM_SIZE + conv_integer(unsigned(core_ramadr)));

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
      WAIT FOR 110 ns;
      system_reset <= '1' ;
      WAIT FOR 100000 ns;
	WAIT UNTIL (cml = 0);
	disable_second <= '1';
      WAIT FOR 100000 ns;
	WAIT UNTIL (cml = 0);
	WAIT UNTIL (system_clk = '1');
      system_reset <= '0';
	WAIT UNTIL (system_clk = '0');
      WAIT FOR 2 ns;
      system_reset <= '1' ;
      WAIT FOR 2 ns;
	disable_second <= '0';
      WAIT FOR 100000 ns;
      ASSERT false REPORT "test passed, done" severity failure;
   END PROCESS;

------------------------------------------------------------------------
--	AVR_Core CM2
------------------------------------------------------------------------
AVR_Core_Inst_cm2:  AVR_Core_cm2 port map(
		cp2_cml_1 => cp2_cml_1,
	--Clock and reset
		cp2 => cp2,
		cp2en => vcc,
		ireset => cml1_reset,
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
--	Insertion of 2 additional AVR cores for virtual debugging
------------------------------------------------------------------------
------------------------------------------------------------------------
------------------------------------------------------------------------
--	generate individual clocks for AVR 0 and 1
------------------------------------------------------------------------
subckl_gen : process (system_clk)
begin
if (cml = 0) then
	cml0_clk <= system_clk;
	cml1_clk <= '0';
else
	cml0_clk <= '0';
	if (disable_second = '0') then
		cml1_clk <= system_clk;
	end if;
end if;
end process;

------------------------------------------------------------------------
--	generate individual resets for AVR 0 and 1
------------------------------------------------------------------------
system_reset_in_gen : PROCESS(system_clk, system_reset, disable_second)
BEGIN
if (disable_second = '0') then
	if (system_clk'event and system_clk = '0') then
		cml1_reset <= cml0_reset;
		cml0_reset <= system_reset;
	end if;
else
	cml1_reset <= system_reset;
end if;
end process;

------------------------------------------------------------------------
--	output comparison
------------------------------------------------------------------------
check_gen : PROCESS(system_clk, system_reset)
BEGIN
if (system_reset = '1') then
if (system_clk'event and system_clk = '0') then
	if (cml = 0) then
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


end behavioral;


