LIBRARY ieee, std;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
use ieee.std_logic_textio.all;
use std.textio.all;

ENTITY HeaderRam IS
	GENERIC
	(
		ADDRESS_WIDTH	: integer := 10;
		DATA_WIDTH		: integer := 8
	);
	PORT
	(
		clk				: IN  std_logic;
		d				: IN  std_logic_vector(DATA_WIDTH - 1 DOWNTO 0);
		waddr			: IN  std_logic_vector(ADDRESS_WIDTH - 1 DOWNTO 0);
		raddr			: IN  std_logic_vector(ADDRESS_WIDTH - 1 DOWNTO 0);
		we				: IN  std_logic;
		q				: OUT std_logic_vector(DATA_WIDTH - 1 DOWNTO 0)
	);
END HeaderRam;

ARCHITECTURE rtl OF HeaderRam IS

TYPE RamType IS ARRAY(0 TO 2 ** ADDRESS_WIDTH - 1) OF std_logic_vector(DATA_WIDTH - 1 DOWNTO 0);

impure function InitRamFromFile(RamFileName : in string) return RamType is
	FILE RamFile : text is in RamFileName;
	variable RamFileLine : line;
	variable RAM : RamType;
begin
	for l in RamType'range loop
		readline(RamFile, RamFileLine);
		hread(RamFileLine, RAM(l));
	end loop;
	return RAM;
end function;

--SIGNAL ram_block : RamType := InitRamFromFile("../design/jfifgen/header.hex");
SIGNAL ram_block : RamType;
attribute ram_init_file : string;
attribute ram_init_file of ram_block :
signal is "./src/jpg/JFIFGen/header.mif";
BEGIN
	PROCESS (clk)
	BEGIN
		IF (clk'event AND clk = '1') THEN
			IF (we = '1') THEN
			    ram_block(to_integer(unsigned(waddr))) <= d;
			END IF;

			q <= ram_block(to_integer(unsigned(raddr)));
		END IF;
	END PROCESS;
END rtl;
