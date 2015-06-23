--------------------------------------------------------------------------------
-- Generated from template tb_template.vhdl by hexconv.pl
--------------------------------------------------------------------------------
-- Light8080 simulation test bench.
--------------------------------------------------------------------------------
-- This test bench was built from a generic template. The details on what tests
-- are performed by this test bench can be found in the assembly source for the 
-- 8080 program, in file asm\tb0.asm.
-------------------------------------------------------------------------------- 
-- 
-- This test bench provides a simulated CPU system to test programs. This test 
-- bench does not do any assertions or checks, all assertions are left to the 
-- software.
--
-- The simulated environment has 2KB of RAM, mirror-mapped to all the memory 
-- map of the 8080, initialized with the test program object code. See the perl
-- script 'util\hexconv.pl' and BAT files in the asm directory.
--
-- Besides, it provides some means to trigger hardware irq from software, 
-- including the specification of the instructions fed to the CPU as interrupt
-- vectors during inta cycles.
--
-- We will simulate 8 possible irq sources. The software can trigger any one of 
-- them by writing at ports 0x010 to 0x011. Port 0x010 holds the irq source to 
-- be triggered (0 to 7) and port 0x011 holds the number of clock cycles that 
-- will elapse from the end of the instruction that writes to the register to 
-- the assertion of intr. Port 0x012 holds the number of cycles intr will remain 
-- high. Intr will be asserted for 1 cycle at least, so writing a 0 here is the 
-- same as writing 1.
--
-- When the interrupt is acknowledged and inta is asserted, the test bench reads
-- the value at register 0x010 as the irq source, and feeds an instruction to 
-- the CPU starting from the RAM address 0040h+source*4.
-- That is, address range 0040h-005fh is reserved for the simulated 'interrupt
-- vectors', a total of 4 bytes for each of the 8 sources. This allows the 
-- software to easily test different interrupt vectors without any hand 
-- assembly. All of this is strictly simulation-only stuff.
--
-- Upon completion, the software must write a value to register 0x020. Writing 
-- a 0x055 means 'success', writing a 0x0aa means 'failure'. The write operation
-- will stop the simulation. Success and failure conditions are defined by the 
-- software.
--
-- If a time period defined as constant MAX_SIM_LENGTH passes before anything
-- is written to io address 0x020, the test bench assumes the software ran away
-- and quits with an error message.
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.ALL;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.ALL;

entity light8080_tb0 is
end entity light8080_tb0;

architecture behavior of light8080_tb0 is

--------------------------------------------------------------------------------
-- Simulation parameters

-- T: simulated clock period
constant T : time := 100 ns;

-- MAX_SIM_LENGTH: maximum simulation time
constant MAX_SIM_LENGTH : time := T*7000; -- enough for the tb0


--------------------------------------------------------------------------------

-- Component Declaration for the Unit Under Test (UUT)
component light8080
  port (  
    addr_out :  out std_logic_vector(15 downto 0);
    
    inta :      out std_logic;
    inte :      out std_logic;
    halt :      out std_logic;                
    intr :      in std_logic;
      
    vma :       out std_logic;
    io :        out std_logic;
    rd :        out std_logic;
    wr :        out std_logic;
    fetch :     out std_logic;
    data_in :   in std_logic_vector(7 downto 0);  
    data_out :  out std_logic_vector(7 downto 0);
    
    clk :       in std_logic;
    reset :     in std_logic );
end component;


signal data_i :           std_logic_vector(7 downto 0) := (others=>'0');
signal vma_o  :           std_logic;
signal rd_o :             std_logic;
signal wr_o :             std_logic;
signal io_o :             std_logic;
signal data_o :           std_logic_vector(7 downto 0);
signal data_mem :         std_logic_vector(7 downto 0);
signal addr_o :           std_logic_vector(15 downto 0);
signal fetch_o :          std_logic;
signal inta_o :           std_logic;
signal inte_o :           std_logic;
signal intr_i :           std_logic := '0';
signal halt_o :           std_logic;
                          
signal reset :            std_logic := '0';
signal clk :              std_logic := '1';
signal done :             std_logic := '0';

type t_rom is array(0 to 2047) of std_logic_vector(7 downto 0);

signal rom : t_rom := (

X"31",X"1d",X"06",X"3e",X"77",X"e6",X"00",X"ca",
X"0d",X"00",X"cd",X"0a",X"05",X"d2",X"13",X"00",
X"cd",X"0a",X"05",X"ea",X"19",X"00",X"cd",X"0a",
X"05",X"f2",X"1f",X"00",X"cd",X"0a",X"05",X"c2",
X"2e",X"00",X"da",X"2e",X"00",X"e2",X"2e",X"00",
X"fa",X"2e",X"00",X"c3",X"31",X"00",X"cd",X"0a",
X"05",X"c6",X"06",X"c2",X"39",X"00",X"cd",X"0a",
X"05",X"da",X"42",X"00",X"e2",X"42",X"00",X"f2",
X"45",X"00",X"cd",X"0a",X"05",X"c6",X"70",X"e2",
X"4d",X"00",X"cd",X"0a",X"05",X"fa",X"56",X"00",
X"ca",X"56",X"00",X"d2",X"59",X"00",X"cd",X"0a",
X"05",X"c6",X"81",X"fa",X"61",X"00",X"cd",X"0a",
X"05",X"ca",X"6a",X"00",X"da",X"6a",X"00",X"e2",
X"6d",X"00",X"cd",X"0a",X"05",X"c6",X"fe",X"da",
X"75",X"00",X"cd",X"0a",X"05",X"ca",X"7e",X"00",
X"e2",X"7e",X"00",X"fa",X"81",X"00",X"cd",X"0a",
X"05",X"fe",X"00",X"da",X"99",X"00",X"ca",X"99",
X"00",X"fe",X"f5",X"da",X"99",X"00",X"c2",X"99",
X"00",X"fe",X"ff",X"ca",X"99",X"00",X"da",X"9c",
X"00",X"cd",X"0a",X"05",X"ce",X"0a",X"ce",X"0a",
X"fe",X"0b",X"ca",X"a8",X"00",X"cd",X"0a",X"05",
X"d6",X"0c",X"d6",X"0f",X"fe",X"f0",X"ca",X"b4",
X"00",X"cd",X"0a",X"05",X"de",X"f1",X"de",X"0e",
X"fe",X"f0",X"ca",X"c0",X"00",X"cd",X"0a",X"05",
X"e6",X"55",X"dc",X"0a",X"05",X"cc",X"0a",X"05",
X"fe",X"50",X"ca",X"d0",X"00",X"cd",X"0a",X"05",
X"f6",X"3a",X"dc",X"0a",X"05",X"cc",X"0a",X"05",
X"fe",X"7a",X"ca",X"e0",X"00",X"cd",X"0a",X"05",
X"ee",X"0f",X"dc",X"0a",X"05",X"cc",X"0a",X"05",
X"fe",X"75",X"ca",X"f0",X"00",X"cd",X"0a",X"05",
X"e6",X"00",X"dc",X"0a",X"05",X"e4",X"0a",X"05",
X"fc",X"0a",X"05",X"c4",X"0a",X"05",X"fe",X"00",
X"ca",X"06",X"01",X"cd",X"0a",X"05",X"d6",X"77",
X"d4",X"0a",X"05",X"ec",X"0a",X"05",X"f4",X"0a",
X"05",X"cc",X"0a",X"05",X"fe",X"89",X"ca",X"1c",
X"01",X"cd",X"0a",X"05",X"e6",X"ff",X"e4",X"29",
X"01",X"fe",X"d9",X"ca",X"86",X"01",X"cd",X"0a",
X"05",X"e8",X"c6",X"10",X"ec",X"35",X"01",X"c6",
X"02",X"e0",X"cd",X"0a",X"05",X"e0",X"c6",X"20",
X"fc",X"41",X"01",X"c6",X"04",X"e8",X"cd",X"0a",
X"05",X"f0",X"c6",X"80",X"f4",X"4d",X"01",X"c6",
X"80",X"f8",X"cd",X"0a",X"05",X"f8",X"c6",X"40",
X"d4",X"59",X"01",X"c6",X"40",X"f0",X"cd",X"0a",
X"05",X"d8",X"c6",X"8f",X"dc",X"65",X"01",X"d6",
X"02",X"d0",X"cd",X"0a",X"05",X"d0",X"c6",X"f7",
X"c4",X"71",X"01",X"c6",X"fe",X"d8",X"cd",X"0a",
X"05",X"c8",X"c6",X"01",X"cc",X"7d",X"01",X"c6",
X"d0",X"c0",X"cd",X"0a",X"05",X"c0",X"c6",X"47",
X"fe",X"47",X"c8",X"cd",X"0a",X"05",X"3e",X"77",
X"3c",X"47",X"04",X"48",X"0d",X"51",X"5a",X"63",
X"6c",X"7d",X"3d",X"4f",X"59",X"6b",X"45",X"50",
X"62",X"7c",X"57",X"14",X"6a",X"4d",X"0c",X"61",
X"44",X"05",X"58",X"7b",X"5f",X"1c",X"43",X"60",
X"24",X"4c",X"69",X"55",X"15",X"7a",X"67",X"25",
X"54",X"42",X"68",X"2c",X"5d",X"1d",X"4b",X"79",
X"6f",X"2d",X"65",X"5c",X"53",X"4a",X"41",X"78",
X"fe",X"77",X"c4",X"0a",X"05",X"af",X"06",X"01",
X"0e",X"03",X"16",X"07",X"1e",X"0f",X"26",X"1f",
X"2e",X"3f",X"80",X"81",X"82",X"83",X"84",X"85",
X"87",X"fe",X"f0",X"c4",X"0a",X"05",X"90",X"91",
X"92",X"93",X"94",X"95",X"fe",X"78",X"c4",X"0a",
X"05",X"97",X"c4",X"0a",X"05",X"3e",X"80",X"87",
X"06",X"01",X"0e",X"02",X"16",X"03",X"1e",X"04",
X"26",X"05",X"2e",X"06",X"88",X"06",X"80",X"80",
X"80",X"89",X"80",X"80",X"8a",X"80",X"80",X"8b",
X"80",X"80",X"8c",X"80",X"80",X"8d",X"80",X"80",
X"8f",X"fe",X"37",X"c4",X"0a",X"05",X"3e",X"80",
X"87",X"06",X"01",X"98",X"06",X"ff",X"80",X"99",
X"80",X"9a",X"80",X"9b",X"80",X"9c",X"80",X"9d",
X"fe",X"e0",X"c4",X"0a",X"05",X"3e",X"80",X"87",
X"9f",X"fe",X"ff",X"c4",X"0a",X"05",X"3e",X"ff",
X"06",X"fe",X"0e",X"fc",X"16",X"ef",X"1e",X"7f",
X"26",X"f4",X"2e",X"bf",X"37",X"a7",X"dc",X"0a",
X"05",X"a1",X"a2",X"a3",X"a4",X"a5",X"a7",X"fe",
X"24",X"c4",X"0a",X"05",X"af",X"06",X"01",X"0e",
X"02",X"16",X"04",X"1e",X"08",X"26",X"10",X"2e",
X"20",X"37",X"b0",X"dc",X"0a",X"05",X"b1",X"b2",
X"b3",X"b4",X"b5",X"b7",X"fe",X"3f",X"c4",X"0a",
X"05",X"3e",X"00",X"26",X"8f",X"2e",X"4f",X"37",
X"a8",X"dc",X"0a",X"05",X"a9",X"aa",X"ab",X"ac",
X"ad",X"fe",X"cf",X"c4",X"0a",X"05",X"af",X"c4",
X"0a",X"05",X"06",X"44",X"0e",X"45",X"16",X"46",
X"1e",X"47",X"26",X"05",X"2e",X"16",X"70",X"06",
X"00",X"46",X"3e",X"44",X"b8",X"c4",X"0a",X"05",
X"72",X"16",X"00",X"56",X"3e",X"46",X"ba",X"c4",
X"0a",X"05",X"73",X"1e",X"00",X"5e",X"3e",X"47",
X"bb",X"c4",X"0a",X"05",X"74",X"26",X"05",X"2e",
X"16",X"66",X"3e",X"05",X"bc",X"c4",X"0a",X"05",
X"75",X"26",X"05",X"2e",X"16",X"6e",X"3e",X"16",
X"bd",X"c4",X"0a",X"05",X"26",X"05",X"2e",X"16",
X"3e",X"32",X"77",X"be",X"c4",X"0a",X"05",X"86",
X"fe",X"64",X"c4",X"0a",X"05",X"af",X"7e",X"fe",
X"32",X"c4",X"0a",X"05",X"26",X"05",X"2e",X"16",
X"7e",X"96",X"c4",X"0a",X"05",X"3e",X"80",X"87",
X"8e",X"fe",X"33",X"c4",X"0a",X"05",X"3e",X"80",
X"87",X"9e",X"fe",X"cd",X"c4",X"0a",X"05",X"37",
X"a6",X"dc",X"0a",X"05",X"c4",X"0a",X"05",X"3e",
X"25",X"37",X"b6",X"dc",X"0a",X"05",X"fe",X"37",
X"c4",X"0a",X"05",X"37",X"ae",X"dc",X"0a",X"05",
X"fe",X"05",X"c4",X"0a",X"05",X"36",X"55",X"34",
X"35",X"86",X"fe",X"5a",X"c4",X"0a",X"05",X"01",
X"ff",X"12",X"11",X"ff",X"12",X"21",X"ff",X"12",
X"03",X"13",X"23",X"3e",X"13",X"b8",X"c4",X"0a",
X"05",X"ba",X"c4",X"0a",X"05",X"bc",X"c4",X"0a",
X"05",X"3e",X"00",X"b9",X"c4",X"0a",X"05",X"bb",
X"c4",X"0a",X"05",X"bd",X"c4",X"0a",X"05",X"0b",
X"1b",X"2b",X"3e",X"12",X"b8",X"c4",X"0a",X"05",
X"ba",X"c4",X"0a",X"05",X"bc",X"c4",X"0a",X"05",
X"3e",X"ff",X"b9",X"c4",X"0a",X"05",X"bb",X"c4",
X"0a",X"05",X"bd",X"c4",X"0a",X"05",X"32",X"16",
X"05",X"af",X"3a",X"16",X"05",X"fe",X"ff",X"c4",
X"0a",X"05",X"2a",X"14",X"05",X"22",X"16",X"05",
X"3a",X"14",X"05",X"47",X"3a",X"16",X"05",X"b8",
X"c4",X"0a",X"05",X"3a",X"15",X"05",X"47",X"3a",
X"17",X"05",X"b8",X"c4",X"0a",X"05",X"3e",X"aa",
X"32",X"16",X"05",X"44",X"4d",X"af",X"0a",X"fe",
X"aa",X"c4",X"0a",X"05",X"3c",X"02",X"3a",X"16",
X"05",X"fe",X"ab",X"c4",X"0a",X"05",X"3e",X"77",
X"32",X"16",X"05",X"2a",X"14",X"05",X"11",X"00",
X"00",X"eb",X"af",X"1a",X"fe",X"77",X"c4",X"0a",
X"05",X"af",X"84",X"85",X"c4",X"0a",X"05",X"3e",
X"cc",X"12",X"3a",X"16",X"05",X"fe",X"cc",X"12",
X"3a",X"16",X"05",X"fe",X"cc",X"c4",X"0a",X"05",
X"21",X"77",X"77",X"29",X"3e",X"ee",X"bc",X"c4",
X"0a",X"05",X"bd",X"c4",X"0a",X"05",X"21",X"55",
X"55",X"01",X"ff",X"ff",X"09",X"3e",X"55",X"d4",
X"0a",X"05",X"bc",X"c4",X"0a",X"05",X"3e",X"54",
X"bd",X"c4",X"0a",X"05",X"21",X"aa",X"aa",X"11",
X"33",X"33",X"19",X"3e",X"dd",X"bc",X"c4",X"0a",
X"05",X"bd",X"c4",X"0a",X"05",X"37",X"d4",X"0a",
X"05",X"3f",X"dc",X"0a",X"05",X"3e",X"aa",X"2f",
X"fe",X"55",X"c4",X"0a",X"05",X"b7",X"27",X"fe",
X"55",X"c4",X"0a",X"05",X"3e",X"88",X"87",X"27",
X"fe",X"76",X"c4",X"0a",X"05",X"af",X"3e",X"aa",
X"27",X"d4",X"0a",X"05",X"fe",X"10",X"c4",X"0a",
X"05",X"af",X"3e",X"9a",X"27",X"d4",X"0a",X"05",
X"c4",X"0a",X"05",X"37",X"3e",X"42",X"07",X"dc",
X"0a",X"05",X"07",X"d4",X"0a",X"05",X"fe",X"09",
X"c4",X"0a",X"05",X"0f",X"d4",X"0a",X"05",X"0f",
X"fe",X"42",X"c4",X"0a",X"05",X"17",X"17",X"d4",
X"0a",X"05",X"fe",X"08",X"c4",X"0a",X"05",X"1f",
X"1f",X"dc",X"0a",X"05",X"fe",X"02",X"c4",X"0a",
X"05",X"01",X"34",X"12",X"11",X"aa",X"aa",X"21",
X"55",X"55",X"af",X"c5",X"d5",X"e5",X"f5",X"01",
X"00",X"00",X"11",X"00",X"00",X"21",X"00",X"00",
X"3e",X"c0",X"c6",X"f0",X"f1",X"e1",X"d1",X"c1",
X"dc",X"0a",X"05",X"c4",X"0a",X"05",X"e4",X"0a",
X"05",X"fc",X"0a",X"05",X"3e",X"12",X"b8",X"c4",
X"0a",X"05",X"3e",X"34",X"b9",X"c4",X"0a",X"05",
X"3e",X"aa",X"ba",X"c4",X"0a",X"05",X"bb",X"c4",
X"0a",X"05",X"3e",X"55",X"bc",X"c4",X"0a",X"05",
X"bd",X"c4",X"0a",X"05",X"21",X"00",X"00",X"39",
X"22",X"1b",X"05",X"31",X"1a",X"05",X"3b",X"3b",
X"33",X"3b",X"3e",X"55",X"32",X"18",X"05",X"2f",
X"32",X"19",X"05",X"c1",X"b8",X"c4",X"0a",X"05",
X"2f",X"b9",X"c4",X"0a",X"05",X"21",X"1a",X"05",
X"f9",X"21",X"33",X"77",X"3b",X"3b",X"e3",X"3a",
X"19",X"05",X"fe",X"77",X"c4",X"0a",X"05",X"3a",
X"18",X"05",X"fe",X"33",X"c4",X"0a",X"05",X"3e",
X"55",X"bd",X"c4",X"0a",X"05",X"2f",X"bc",X"c4",
X"0a",X"05",X"2a",X"1b",X"05",X"f9",X"21",X"0f",
X"05",X"e9",X"3e",X"aa",X"d3",X"20",X"76",X"3e",
X"55",X"d3",X"20",X"76",X"16",X"05",X"00",X"00",
X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",
X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",
X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",
X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",
X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",
X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",
X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",
X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",
X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",
X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",
X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",
X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",
X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",
X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",
X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",
X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",
X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",
X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",
X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",
X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",
X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",
X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",
X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",
X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",
X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",
X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",
X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",
X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",
X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",
X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",
X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",
X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",
X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",
X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",
X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",
X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",
X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",
X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",
X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",
X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",
X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",
X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",
X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",
X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",
X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",
X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",
X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",
X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",
X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",
X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",
X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",
X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",
X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",
X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",
X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",
X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",
X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",
X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",
X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",
X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",
X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",
X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",
X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",
X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",
X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",
X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",
X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",
X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",
X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",
X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",
X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",
X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",
X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",
X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",
X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",
X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",
X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",
X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",
X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",
X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",
X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",
X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",
X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",
X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",
X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",
X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",
X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",
X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",
X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",
X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",
X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",
X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",
X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00"

);

signal irq_vector_byte:   std_logic_vector(7 downto 0);
signal irq_source :       integer range 0 to 7;
signal cycles_to_intr :   integer range -10 to 255;
signal intr_width :       integer range 0 to 255;
signal int_vector_index : integer range 0 to 3;
signal addr_vector_table: integer range 0 to 65535;

begin

  -- Instantiate the Unit Under Test (UUT)
  uut: light8080 PORT MAP(
    clk => clk,
    reset => reset,
    vma => vma_o,
    rd => rd_o,
    wr => wr_o,
    io => io_o,
    fetch => fetch_o,
    addr_out => addr_o, 
    data_in => data_i,
    data_out => data_o,
    
    intr => intr_i,
    inte => inte_o,
    inta => inta_o,
    halt => halt_o
  );


-- clock: run clock until test is done
clock:
process(done, clk)
begin
  if done = '0' then
    clk <= not clk after T/2;
  end if;
end process clock;


-- Drive reset and done 
main_test:
process
begin
  -- Assert reset for at least one full clk period
  reset <= '1';
  wait until clk = '1';
  wait for T/2;
  reset <= '0';

  -- Remember to 'cut away' the preceding 3 clk semiperiods from 
  -- the wait statement...
  wait for (MAX_SIM_LENGTH - T*1.5);

  -- Maximum sim time elapsed, assume the program ran away and
  -- stop the clk process asserting 'done' (which will stop the simulation)
  done <= '1';
  
  assert (done = '1') 
  report "Test timed out."
  severity failure;
  
  wait;
end process main_test;


-- Synchronous RAM; 2KB mirrored everywhere
synchronous_ram:
process(clk)
begin
  if (clk'event and clk='1') then
    data_mem <= rom(conv_integer(addr_o(10 downto 0)));
    if wr_o = '1' and addr_o(15 downto 11)="00000" then
      rom(conv_integer(addr_o(10 downto 0))) <= data_o;
    end if;  
  end if;
end process synchronous_ram;


irq_trigger_register:
process(clk)
begin
  if (clk'event and clk='1') then
    if reset='1' then
      cycles_to_intr <= -10; -- meaning no interrupt pending
    else
      if io_o='1' and wr_o='1' and addr_o(7 downto 0)=X"11" then
        cycles_to_intr <= conv_integer(data_o) + 1;
      else
        if cycles_to_intr >= 0 then
          cycles_to_intr <= cycles_to_intr - 1;
        end if;
      end if;
    end if;
  end if;
end process irq_trigger_register;

irq_pulse_width_register:
process(clk)
variable intr_pulse_countdown : integer;
begin
  if (clk'event and clk='1') then
    if reset='1' then
      intr_width <= 1;
      intr_pulse_countdown := 0;
      intr_i <= '0';
    else
      if io_o='1' and wr_o='1' and addr_o(7 downto 0)=X"12" then
        intr_width <= conv_integer(data_o) + 1;
      end if;

      if cycles_to_intr = 0 then
        intr_i <= '1';
        intr_pulse_countdown := intr_width;
      elsif intr_pulse_countdown <= 1 then
        intr_i <= '0';
      else
        intr_pulse_countdown := intr_pulse_countdown - 1;
      end if;
    end if;
  end if;
end process irq_pulse_width_register;

irq_source_register:
process(clk)
begin
  if (clk'event and clk='1') then
    if reset='1' then
      irq_source <= 0;
    else
      if io_o='1' and wr_o='1' and addr_o(7 downto 0)=X"10" then
        irq_source <= conv_integer(data_o(2 downto 0));
      end if;
    end if;
  end if;
end process irq_source_register;


-- 'interrupt vector' logic.
irq_vector_table:
process(clk)
begin
  if (clk'event and clk='1') then
    if vma_o = '1' and rd_o='1' then
      if inta_o = '1' then
        int_vector_index <= int_vector_index + 1;
      else
        int_vector_index <= 0;
      end if;
    end if;
    -- this is the address of the byte we'll feed to the CPU
    addr_vector_table <= 64+irq_source*4+int_vector_index;
  end if;
end process irq_vector_table;
irq_vector_byte <= rom(addr_vector_table);

data_i <= data_mem when inta_o='0' else irq_vector_byte;


test_outcome_register:
process(clk)
variable outcome : std_logic_vector(7 downto 0);
begin
  if (clk'event and clk='1') then
    if io_o='1' and wr_o='1' and addr_o(7 downto 0)=X"20" then
    assert (data_o /= X"55") report "Software reports SUCCESS" severity failure;
    assert (data_o /= X"aa") report "Software reports FAILURE" severity failure;
    assert ((data_o = X"aa") or (data_o = X"55")) 
    report "Software reports unexpected outcome value." 
    severity failure;
    end if;
  end if;
end process test_outcome_register;


end;
