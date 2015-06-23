library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

use work.TinyXconfig.ALL;

--  Uncomment the following lines to use the declarations that are
--  provided for instantiating Xilinx primitive components.
--library UNISIM;
--use UNISIM.VComponents.all;

entity ALU is
    Port ( opa : in cpuWord;
           opb : in cpuWord;
           res : out cpuWord;
           cin : in std_logic;
           cout : out std_logic;
           zero : out std_logic;
           sign : out std_logic;
           over : out std_logic;
           what : in std_logic_vector(3 downto 0));
end ALU;

architecture Behavioral of ALU is

  constant alu_mov   : std_logic_vector(3 downto 0) := "0000";
  constant alu_and   : std_logic_vector(3 downto 0) := "0001";
  constant alu_or    : std_logic_vector(3 downto 0) := "0010";
  constant alu_xor   : std_logic_vector(3 downto 0) := "0011";
  constant alu_add   : std_logic_vector(3 downto 0) := "0100";
  constant alu_sub   : std_logic_vector(3 downto 0) := "0101";
  constant alu_ror   : std_logic_vector(3 downto 0) := "0110";
  constant alu_lsr   : std_logic_vector(3 downto 0) := "0111";
  constant alu_lsra  : std_logic_vector(3 downto 0) := "1000";
  constant alu_swap  : std_logic_vector(3 downto 0) := "1001";
  constant alu_swapb : std_logic_vector(3 downto 0) := "1010";
  constant alu_inc   : std_logic_vector(3 downto 0) := "1011";
  constant alu_dec   : std_logic_vector(3 downto 0) := "1100";
  constant alu_rorb  : std_logic_vector(3 downto 0) := "1101";

begin

  assert XLEN > 31 report "XLEN must at least 32 and multiple of 8";
  assert (XLEN rem 8) = 0 report "XLEN must at least 32 and multiple of 8"; 

  process(opa, opb, cin, what)
    variable temp   : std_logic_vector(XLEN downto 0);
    variable ctr    : integer;
    variable help   : std_logic_vector((XLEN-1) downto 0);
    variable helper : std_logic_vector(XLEN downto 0);
  begin
    case what is
      when alu_mov =>
        res  <= opb;
        temp := ("0" & opb);
        cout <= cin;
        over <= '0';
      when alu_and =>
        res  <= opa and opb;
        temp := ("0" & opa) and ("0" & opb);
        cout <= cin;
        over <= '0';
      when alu_or  =>
        res  <= opa or opb;
        temp := ("0" & opa) or ("0" & opb);
        cout <= cin;
        over <= '0';
      when alu_xor =>
        res  <= opa xor opb;
        temp := ("0" & opa) xor ("0" & opb);
        cout <= cin;
        over <= '0';
      when alu_add =>
        res  <= opa + opb + (getStdLogicVectorZeroes(XLEN-1) & cin);
        temp := ("0" & opa) + ("0" & opb) + (getStdLogicVectorZeroes(XLEN-1) & cin);
        cout <= temp(XLEN);
        over <= (opa(XLEN-1) and opb(XLEN-1) and  not temp(XLEN-1)) OR (not opa(XLEN-1) and not opb(XLEN-1) and temp(XLEN-1));
      when alu_sub =>
        res  <= opa - opb - (getStdLogicVectorZeroes(XLEN-1) & cin);
        temp := ("0" & opa) - ("0" & opb) - (getStdLogicVectorZeroes(XLEN-1) & cin);
        cout <= temp(XLEN);
        over <= (opa(XLEN-1) and opb(XLEN-1) and not temp(XLEN-1)) OR (not opa(XLEN-1) and not opb(XLEN-1) and temp(XLEN-1));
      when alu_ror =>
        res  <= opa(0) & opa((XLEN-1) downto 1);
        temp := "0" & opa(0) & opa((XLEN-1) downto 1);
        cout <= opa(0);
        over <= '0';
      when alu_lsr =>
        res  <= cin & opa((XLEN-1) downto 1);
        temp := "00" & opa((XLEN-1) downto 1);
        cout <= opa(0);
        over <= '0';
      when alu_lsra =>
        res  <= opa(XLEN-1) & opa((XLEN-1) downto 1);
        temp := "0" & opa(XLEN-1) & opa((XLEN-1) downto 1);
        cout <= opa(0);
        over <= '0';
      when alu_swap =>
        res  <= opa((XLEN/2-1) downto 0) & opa((XLEN-1) downto (XLEN/2));
        temp := "0" & opa((XLEN/2-1) downto 0) & opa((XLEN-1) downto (XLEN/2));
        cout <= cin;
        over <= '0';
      when alu_swapb =>
        ctr := XLEN / 8;
        help := opa(7 downto 0) & getStdLogicVectorZeroes(XLEN-8);
        swb: for index in 1 to ctr-2 loop
          help := help or (getStdLogicVectorZeroes(index*8) & opa(((index+1)*8-1) downto (index*8)) & getStdLogicVectorZeroes((ctr-index-1)*8));
        end loop;
        help := help or (getStdLogicVectorZeroes(XLEN-8) & opa((XLEN-1) downto (XLEN-8)));
        res <= help;
        helper := "0" & opa(7 downto 0) & getStdLogicVectorZeroes(XLEN-8);
        swt: for index in 1 to ctr-2 loop
          helper := helper or ("0" & getStdLogicVectorZeroes(index*8) & opa(((index+1)*8-1) downto (index*8)) & getStdLogicVectorZeroes((ctr-index-1)*8));
        end loop;
        helper := helper or ("0" & getStdLogicVectorZeroes(XLEN-8) & opa((XLEN-1) downto (XLEN-8)));
        temp := helper;
        --res <= opa(7 downto 0) & opa(15 downto 8) & opa(23 downto 16) & opa(31 downto 24);
        --temp := "0" & opa(7 downto 0) & opa(15 downto 8) & opa(23 downto 16) & opa(31 downto 24);
        cout <= cin;
        over <= '0';
      when alu_inc =>
        res  <= opa + "1" + cin;
        temp := opa + "1" + cin;
        cout <= temp(XLEN);
        over <= '0';
      when alu_dec =>
        res  <= opa - "1" - cin;
        temp := opa - "1" - cin;
        cout <= temp(XLEN);
        over <= '0';
      when alu_rorb =>
        res  <= opa(7 downto 0) & opa((XLEN-1) downto 8);
        temp := "0" & opa(7 downto 0) & opa((XLEN-1) downto 8);
        cout <= cin;
        over <= '0';
      when others =>
        res  <= getStdLogicVectorZeroes(XLEN);
        temp := getStdLogicVectorZeroes(XLEN);
        cout <= cin;
        over <= '0';
    end case;
    sign <= temp(XLEN-1);
    if temp((XLEN-1) downto 0) = 0 then
      zero <= '1';
    else
      zero <= '0';
    end if;
  end process;
end Behavioral;

