library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

--  Uncomment the following lines to use the declarations that are
--  provided for instantiating Xilinx primitive components.
--library UNISIM;
--use UNISIM.VComponents.all;

entity input is
    Port ( clk : in std_logic;
           rst : in std_logic;
           serial : in std_logic;
           mem_block : in std_logic;
           mem_ready : out std_logic;
           wen : out std_logic;
           address : out std_logic_vector (5 downto 0);
           i : out std_logic_vector(11 downto 0);
           q : out std_logic_vector(11 downto 0)
           );
end input;

architecture input of input is

type state is (s0, s1, s2, s3, s4, s5, s6, s7);
signal st: state;
signal meta, sync : std_logic;
signal addr : std_logic_vector(5 downto 0);
begin

process(clk,rst)
    --constant mais1  : std_logic_vector(11 downto 0) := "001100000000";
    constant mais1  : std_logic_vector(11 downto 0) := x"080";
    constant menos1 : std_logic_vector(11 downto 0) := "110100000000";
begin
--      0123.45678901 bits
--      0011.00000000 = +1
--      1101.00000000 = -1

--                Q
--        o       |       o 
--        01      |       00
--                |
--        ----------------- I
--                |
--        11      |       10
--        o       |        o

   if rst = '1' then
      st <= s0;
      mem_ready <= '0';
      wen <= '0';
      addr <= (others => '0');
      address <= (others => '0');
      i <= mais1;
      q <= mais1;
   elsif clk'event and clk='1' then
      case st is
         when s0 =>
            st <= s1;
            meta <= serial;
            wen <= '0';
         when s1 =>
            st <= s2;
            sync <= meta;
         when s2 =>
            st <= s3;
            if sync='0' then
               i <= mais1;
            else
               i <= menos1;
            end if;
         when s3 =>
            st <= s4;
         when s4 =>
            st <= s5;
            meta <= serial;
            addr <= addr +1;
         when s5 =>
            st <= s6;
            sync <= meta;
            if unsigned(addr) = 32 then
               addr <= conv_std_logic_vector(1,6);
               mem_ready <= '1';
            end if;
         when s6 =>
            st <= s7;
            mem_ready <= '0';            
            if sync='0' then
               q <= mais1;
            else
               q <= menos1;
            end if;
         when s7 =>
            st <= s0;
            if mem_block = '0' then
               address <= addr+32;
            else
               address <= addr;
            end if;
            wen <= '1';
      end case;
   end if;
end process;

end input;