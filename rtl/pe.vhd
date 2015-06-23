----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    20:36:31 10/27/2009 
-- Design Name: 
-- Module Name:    PE - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity pe is
  port ( clk          : in  std_logic;
         reset        : in  std_logic;
         a_j          : in  std_logic_vector(15 downto 0);
         b_i          : in  std_logic_vector(15 downto 0);
         s_prev       : in  std_logic_vector(15 downto 0);  --entrada de la s anterior para la suma
         m            : in  std_logic_vector(15 downto 0);
         n_j          : in  std_logic_vector(15 downto 0);
         s_next       : out std_logic_vector(15 downto 0);  --salida con la siguiente s
         aj_bi        : out std_logic_vector(15 downto 0);  --salida de multiplicador reutilizado para calcular a*b
         ab_valid_in  : in  std_logic;  --indica que los datos de entrada en el multiplicador son validos
         valid_in     : in  std_logic;  --todas las entradas son validas, y la m está calculada
         ab_valid_out : out std_logic;  --indica que la multiplicacion de un a y b validos se ha realizado con exito
         valid_out    : out std_logic;
         fifo_req     : out std_logic);  --peticion de las siguientes entradas a, b, s, m
end pe;

architecture Behavioral of pe is

  signal prod_aj_bi, next_prod_aj_bi, mult_aj_bi                     : std_logic_vector(31 downto 0);  -- registros para la primera mult
  signal prod_nj_m, next_prod_nj_m, mult_nj_m, mult_nj_m_reg         : std_logic_vector(31 downto 0);
  signal sum_1, next_sum_1                                           : std_logic_vector(31 downto 0);
  signal sum_2, next_sum_2                                           : std_logic_vector(31 downto 0);
  signal ab_valid_reg, valid_out_reg, valid_out_reg2, valid_out_reg3 : std_logic;
  signal n_reg, next_n_reg, s_prev_reg, next_s_prev_reg, ab_out_reg  : std_logic_vector(15 downto 0);
  --signal prod_aj_bi_out, next_prod_aj_bi_out : std_logic_vector(15 downto 0);

begin


  mult_aj_bi <= a_j * b_i;
  mult_nj_m  <= n_reg *m;


  process(clk, reset)
  begin

    if(clk = '1' and clk'event)
    then
      if(reset = '1') then
        prod_aj_bi     <= (others => '0');
        prod_nj_m      <= (others => '0');
        sum_1          <= (others => '0');
        sum_2          <= (others => '0');
        ab_valid_reg   <= '0';
        n_reg          <= (others => '0');
        valid_out_reg  <= '0';
        valid_out_reg2 <= '0';
        valid_out_reg3 <= '0';
        s_prev_reg     <= (others => '0');
      else
        --prod_aj_bi_out <= next_prod_aj_bi_out;
        prod_aj_bi     <= next_prod_aj_bi;
        prod_nj_m      <= next_prod_nj_m;
        sum_1          <= next_sum_1;
        sum_2          <= next_sum_2;
        ab_valid_reg   <= ab_valid_in;
        ab_out_reg     <= mult_aj_bi(15 downto 0);
        n_reg          <= next_n_reg;
        valid_out_reg  <= valid_in;     --registramos el valid out para sacarle al tiempo de los datos validos
        valid_out_reg2 <= valid_out_reg;
        valid_out_reg3 <= valid_out_reg2;
        s_prev_reg     <= next_s_prev_reg;
        --mult_nj_m_reg <= mult_nj_m;
      end if;
    end if;

  end process;

  process(s_prev, prod_aj_bi, prod_nj_m, sum_1, sum_2, mult_aj_bi, mult_nj_m, valid_in, ab_valid_reg, n_j, n_reg, valid_out_reg3, s_prev_reg, ab_out_reg)
  begin
    ab_valid_out      <= ab_valid_reg;
    aj_bi             <= ab_out_reg(15 downto 0);  --Sacamos uno de los dos registros de la multiplicacion fuera para el calculo de la constante
    s_next            <= sum_2(15 downto 0);  --salida de la pipe
    fifo_req          <= valid_in;
    valid_out         <= valid_out_reg3;
    next_sum_1        <= sum_1;
    next_sum_2        <= sum_2;
    next_prod_nj_m    <= prod_nj_m;
    next_prod_aj_bi   <= prod_aj_bi;
    next_n_reg        <= n_reg;
    next_s_prev_reg   <= s_prev_reg;
    if(valid_in = '1') then
      next_s_prev_reg <= s_prev;
      next_n_reg      <= n_j;
      next_prod_aj_bi <= mult_aj_bi;
      next_prod_nj_m  <= mult_nj_m;     --registramos la multiplicacion de n_j,m
      next_sum_1      <= prod_aj_bi+sum_1(31 downto 16)+s_prev_reg;
      next_sum_2      <= prod_nj_m+sum_2(31 downto 16) + sum_1(15 downto 0);
    else
      next_s_prev_reg <= (others => '0');
      next_n_reg      <= (others => '0');
      next_prod_aj_bi <= (others => '0');
      next_prod_nj_m  <= (others => '0');
      next_sum_1      <= (others => '0');
      next_sum_2      <= (others => '0');
    end if;



  end process;

end Behavioral;

