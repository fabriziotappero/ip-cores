library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
--use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity Reg_file_block is
port(
		Clk : in std_logic;
		rst : in  STD_LOGIC;
		vector_on : in std_logic_vector(2 downto 0);
		Reg_Write : in std_logic;
		Reg_Imm_not : in std_logic;
		rs : in std_logic_vector(4 downto 0);
		rt : in std_logic_vector(4 downto 0);
		rd : in std_logic_vector(4 downto 0);
		Bus_W : in std_logic_vector(31 downto 0);
		Bus_A : out std_logic_vector(31 downto 0);
		Bus_B : out std_logic_vector(31 downto 0)
		
);
end entity Reg_file_block;

architecture Reg_file of Reg_file_block is  --Regfile_block


-- Declarations of Register File type & signal
type Regfile_type is array (natural range<>) of std_logic_vector(31 downto 0);

signal Regfile_Coff : Regfile_type(0 to 31):= ((others=> (others=>'0')));
signal Addr_in : std_logic_vector(4 downto 0);
signal Bus_A_reg,Bus_B_reg : std_logic_vector(31 downto 0);
begin

process(Clk,rst,Reg_Write,Reg_Imm_not,rs,rt,rd,Bus_W,Regfile_Coff,vector_on)
variable adr : std_logic_vector(4 downto 0):= "00000";
Constant A_vector : std_logic_vector(31 Downto 0) := "00001110000000000000000000011011";
Constant B_vector : std_logic_vector(31 Downto 0) := "00001100000000000000000000011011";
begin
-- Regfile_Read Assignments
if(FALLING_EDGE(Clk))then
	Bus_A_reg <= Regfile_Coff(conv_integer(rs));
	Bus_B_reg <= Regfile_Coff(conv_integer(rt));
end if;
	
-- Write Address Assignment
if (Reg_Imm_Not = '1') then
		Addr_in <= rd;
	elsif (Reg_Imm_Not = '0') then
		Addr_in <= rt;
end if;
-- Vector initialize
if (((vector_on or "110") = "111") and (rst = '0')) then
   if vector_on  = "001" then
     adr := "10010";
	  Regfile_Coff(conv_integer(Adr)) <= A_vector;
   elsif vector_on  = "011" then
	  adr := "10011";
	  Regfile_Coff(conv_integer(Adr)) <= B_vector;
	elsif vector_on  = "101" then
	  adr := "01010";
	  Regfile_Coff(conv_integer(Adr)) <= A_vector;
   elsif vector_on  = "111" then
	  adr := "10001";
	  Regfile_Coff(conv_integer(Adr)) <= B_vector;
  	end if;  
end if;
-- Regfile_Write Assignments
if rst = '0' then
   Addr_in <= "00000";
elsif(RISING_EDGE(Clk))then
	if(Reg_Write = '1' and Addr_in /= "00000") then
		Regfile_Coff(conv_integer(Addr_in)) <= Bus_W;
	end if;
end if;
if rst = '0' then
Bus_A <= (others => '0');
Bus_B <= (others => '0');
elsif(RISING_EDGE(Clk))then 
Bus_A<=Bus_A_reg; 
Bus_B<=Bus_B_reg;
end if;
end process;

--------------------------------------------------------
end architecture Reg_file;
