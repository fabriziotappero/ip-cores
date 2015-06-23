----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    19:08:19 10/29/2009 
-- Design Name: 
-- Module Name:    montgomery - Behavioral 
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

entity pe_wrapper is

  port(
    clk          : in  std_logic;
    reset        : in  std_logic;
    ab_valid     : in  std_logic;
    valid_in     : in  std_logic;
    a            : in  std_logic_vector(15 downto 0);
    b            : in  std_logic_vector(15 downto 0);
    n            : in  std_logic_vector(15 downto 0);
    s_prev       : in  std_logic_vector(15 downto 0);
    n_c          : in  std_logic_vector(15 downto 0);
    s            : out std_logic_vector( 15 downto 0);
    data_ready   : out std_logic;
    fifo_req     : out std_logic;
    m_val        : out std_logic;
    reset_the_PE : in  std_logic);      -- estamos preparados para aceptar el siguiente dato

end pe_wrapper;

architecture Behavioral of pe_wrapper is

  component pe is
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
                        fifo_req     : out std_logic);
  end component;

  component m_calc is
                     port(
                       clk        : in  std_logic;
                       reset      : in  std_logic;
                       ab         : in  std_logic_vector (15 downto 0);
                       t          : in  std_logic_vector (15 downto 0);
                       n_cons     : in  std_logic_vector (15 downto 0);
                       m          : out std_logic_vector (15 downto 0);
                       mult_valid : in  std_logic;
                       m_valid    : out std_logic);
  end component;

  signal aj_bi, m, next_m, m_out          : std_logic_vector(15 downto 0);
  signal mult_valid, valid_m, valid_m_reg : std_logic;  --lo registro para compararlos

begin

  pe_0 : pe port map(
    clk          => clk,
    reset        => reset,
    a_j          => a,
    b_i          => b,
    s_prev       => s_prev,
    m            => m,
    n_j          => n,
    s_next       => s,
    aj_bi        => aj_bi,
    ab_valid_in  => ab_valid,
    valid_in     => valid_in,
    ab_valid_out => mult_valid,
    valid_out    => data_ready,
    fifo_req     => fifo_req);

  mcons_0 : m_calc port map(
    clk        => clk,
    reset      => reset,
    ab         => aj_bi,
    t          => s_prev,
    n_cons     => n_c,
    m          => m_out,
    mult_valid => mult_valid,
    m_valid    => valid_m);

  process(clk, reset)
  begin
    if(clk = '1' and clk'event) then

      if(reset = '1')then
        m           <= (others => '0' );
        valid_m_reg <= '0';
      else
        m           <= next_m;
        valid_m_reg <= valid_m;
      end if;
    end if;
  end process;

  process(m_out, valid_m, valid_m_reg, m)
  begin
    m_val    <= valid_m_reg;
    if(valid_m = '1' and valid_m_reg = '0') then
      next_m <= m_out;
    else
      next_m <= m;
    end if;
  end process;

end Behavioral;

