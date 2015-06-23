library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

--  Uncomment the following lines to use the declarations that are
--  provided for instantiating Xilinx primitive components.
--library UNISIM;
--use UNISIM.VComponents.all;

entity output is
    Port ( clk : in std_logic;
           rst : in std_logic;
           Iout          : in std_logic_vector(13 downto 0);
           Qout          : in std_logic_vector(13 downto 0);
           Output_enable : in std_logic;
           addrout_out   : out  std_logic_vector(5 downto 0);
           txserial : out std_logic
           );
end output;

architecture output of output is

type state is (s0,s1,s2,s3,s4,s5,s6,s7,s8);
signal st : state;

signal addr : std_logic_vector(5 downto 0);
begin

addrout_out <= addr;

acoes:process(clk,rst)
begin
   if rst ='1' then
      addr <= conv_std_logic_vector(1,6);
      txserial <= '1';
   elsif clk'event and clk='1' then
      case st is
         when s0 => -- espera output_enable
            txserial <= '1';
            addr <= conv_std_logic_vector(1,6);
         when s1|s2|s3|s4 => -- qam decoder
            txserial <= Iout(13);
         when s5|s6|s8 =>
            txserial <= Qout(13);
         when s7 =>
            txserial <= Qout(13);
            if addr /= 31 then
               addr <= addr+1;
            else
               addr <= conv_std_logic_vector(1,6);
            end if;
      end case;
   end if;
end process;

estados:process(clk,rst)
begin
   if rst ='1' then
      st <= s0;
   elsif clk'event and clk='1' then
      case st is
         when s0 =>
            if Output_enable = '1' then
               st <= s1;
            else
               st <= s0;
            end if;
         when s1 =>
            st <= s2;
         when s2 =>
            st <= s3;
         when s3 =>
            st <= s4;
         when s4 =>
            st <= s5;
         when s5 =>
            st <= s6;
         when s6 =>
            st <= s7;
         when s7=>
            st <= s8;
         when s8=>
            st <= s1;
      end case;
   end if;
end process;
end output;