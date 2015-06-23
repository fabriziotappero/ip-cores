LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

PACKAGE cpu_types IS
  CONSTANT a_bus_width : INTEGER := 8;
  CONSTANT d_bus_width : INTEGER := 8;
  CONSTANT zero_bus : std_logic_vector(d_bus_width-1 downto 0) := (others =>'0');
--  constant notinit :  std_logic_vector(d_bus_width-1 downto 0) := (others =>'U');
    
  SUBTYPE a_bus IS STD_LOGIC_VECTOR(a_bus_width-1 DOWNTO 0);
  SUBTYPE d_bus IS STD_LOGIC_VECTOR(d_bus_width-1 DOWNTO 0);

  TYPE ram_memory IS ARRAY (integer range 0 TO 2**a_bus_width-1) OF d_bus;
  type rom_memory is array (integer range 0 to 2**a_bus_width-1) of d_bus;
  type opcode is (nop, neg_s, and_s, exor_s, or_s, sra_s, ror_s, add_s, addc_s,
                  jmp_1, jmpc_1, jmpz_1, jmp_2, jmpc_2, jmpz_2, lda_const_1, lda_const_2,
                  ldb_const_1, ldb_const_2, lda_addr_1, lda_addr_2,
                  ldb_addr_1, ldb_addr_2, sta_1, sta_2, jnt );

  PROCEDURE addc (SIGNAL a, b : IN STD_LOGIC_VECTOR(d_bus_width-1 DOWNTO 0);
                  SIGNAL cin : IN STD_LOGIC;
                  SIGNAL cout : OUT STD_LOGIC;
                  variable sum : out STD_LOGIC_VECTOR(d_bus_width-1 DOWNTO 0));
END cpu_types;

PACKAGE BODY cpu_types IS
  PROCEDURE addc (SIGNAL a, b : IN STD_LOGIC_VECTOR(d_bus_width-1 DOWNTO 0);
                  SIGNAL cin : IN STD_LOGIC;
                  SIGNAL cout : OUT STD_LOGIC;
                  variable sum : out STD_LOGIC_VECTOR(d_bus_width-1 DOWNTO 0)) is
    variable temp_carry : std_logic_vector(d_bus_width downto 0);
    variable temp_sum : std_logic_vector(d_bus_width-1 downto 0);
  begin
    temp_carry(0) := cin;
    for i in 0 to d_bus_width-1 loop
      temp_carry(i+1) := ((a(i) and b(i)) or (a(i) and temp_carry(i)) or (b(i) and temp_carry(i)));
      temp_sum(i) := a(i) xor b(i) xor temp_carry(i);
    end loop;
    sum := temp_sum;
    cout <= temp_carry(temp_carry'high);
  end procedure addc;  
END cpu_types;
