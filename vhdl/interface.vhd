library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

--  Uncomment the following lines to use the declarations that are
--  provided for instantiating Xilinx primitive components.
--library UNISIM;
--use UNISIM.VComponents.all;

entity txrx is
    Port ( clk : in std_logic;
           rst : in std_logic;
           Output_enable : in std_logic;
           mem_block : in std_logic;
           --mem_ready : out std_logic;
           wen : out std_logic;
           address : out std_logic_vector(6 downto 0)
           );
end txrx;

architecture interface of txrx is

signal ifsel: boolean;
signal add : std_logic_vector(6 downto 0);
signal wen_aux : std_logic;
begin

wen <= wen_aux;
address <= add;
   process (clk,rst)
   begin
      if rst = '1' then
         add <= (others => '0');
         wen_aux <= '0';
      elsif clk'event and clk='1' then
         if Output_enable = '1' then
            wen_aux <= '1';
            if mem_block = '0' then
               add <= (others => '0');
            else
               add <= conv_std_logic_vector(64,7);
            end if;
         elsif wen_aux = '1' then
            if (add(5 downto 0) /= 63) then
               add <= add + 1;
            else
               wen_aux <= '0';
               add <= add;
            end if;
         end if;
      end if;
   end process;

end interface;