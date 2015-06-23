library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity txrx is
    Port ( clk : in std_logic;
           rst : in std_logic;
           Output_enable : in std_logic;
           mem_block : in std_logic;
           mem_ready : out std_logic;
           wen : out std_logic;
           address_read : out std_logic_vector(5 downto 0);
           address_write: out std_logic_vector(6 downto 0)
           );
end txrx;

architecture interface of txrx is

type state is (s0,s1,s2,s3);
signal st : state;

signal add : std_logic_vector(6 downto 0);
signal wen_aux : std_logic;
begin

address_read <= add(5 downto 0);

process(clk,rst)
begin
   if rst ='1' then
      address_write <= (others => '0');
      wen <= '0';
   elsif clk'event and clk='1' then
      address_write <= add;
      wen <= wen_aux;
   end if;
end process;

   process(clk,rst)
   begin
      if rst = '1' then
         add <= (others => '0');
         wen_aux <= '0';
         mem_ready <= '0';
      elsif clk'event and clk='1' then
         case st is
            when s0 => -- para contagem
               wen_aux <= '0';
               add <= add;
               mem_ready <= '0';
            when s1 => -- inicialização
               wen_aux <= '1';
               if mem_block = '1' then
                  add <= (others => '0');
               else
                  add <= conv_std_logic_vector(64,7);
               end if;
            when s2 => --contagem
               add <= add + 1;
            when s3 => --fim contagem
               add <= add + 1;
               mem_ready <= '1';
         end case;
      end if;
   end process;

   process(clk,rst)
   begin
      if rst = '1' then
         st <= s0;
      elsif clk'event and clk='1' then
         case st is
            when s0 => -- para contagem
               if Output_enable = '1' then
                  st <= s1;
               end if;
            when s1 => -- inicialização
               st <= s2;
            when s2 => -- contagem
               if (add(5 downto 0) = 61) then
                  st <= s3;
               end if;
            when s3 => -- fim contagem
               st <= s0;
         end case;
      end if;
   end process;

end interface;