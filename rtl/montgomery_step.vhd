----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    10:40:41 11/01/2009 
-- Design Name: 
-- Module Name:    module_with_fifo - Behavioral 
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

entity montgomery_step is
  port(
    clk       : in  std_logic;
    reset     : in  std_logic;
    valid_in  : in  std_logic;
    a         : in  std_logic_vector(15 downto 0);
    b         : in  std_logic_vector(15 downto 0);
    n         : in  std_logic_vector(15 downto 0);
    s_prev    : in  std_logic_vector(15 downto 0);
    n_c       : in  std_logic_vector(15 downto 0);
    s         : out std_logic_vector( 15 downto 0);
    valid_out : out std_logic;          -- es le valid out TODO : cambiar nombre
    busy      : out std_logic;
    b_req     : out std_logic;
    a_out     : out std_logic_vector(15 downto 0);
    n_out     : out std_logic_vector(15 downto 0);  --señal que indica que el modulo está ocupado y no puede procesar nuevas peticiones
    c_step    : out std_logic;          --genera un pulso cuando termina su computo para avisar al modulo superior
    stop      : in  std_logic
    );
end montgomery_step;

architecture Behavioral of montgomery_step is

  component pe_wrapper
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
      reset_the_PE : in  std_logic);    -- estamos preparados para aceptar el siguiente dato
  end component;

  --Inputs

  signal ab_valid                                               : std_logic;
  signal valid_mont, fifo_read, m_val, valid_mont_out, reset_pe : std_logic;
  --Outputs


  --definimos los estados
  type state_type is (wait_valid, wait_m, mont_proc, getting_results, prep_m, b_stable);
  signal state, next_state     : state_type;
  signal counter, next_counter : std_logic_vector(7 downto 0);  -- cuenta las palabras que han salido para ir cortando


  --Señales nuevas
  signal mont_input_a, mont_input_n, mont_input_s                   : std_logic_vector(15 downto 0);
  signal reg_constant, next_reg_constant, next_reg_input, reg_input : std_logic_vector(47 downto 0);
  signal reg_out, reg_out_1, reg_out_2, reg_out_3, reg_out_4        : std_logic_vector(31 downto 0);
  signal next_reg_out                                               : std_logic_vector(31 downto 0);

  --Cadena de registros hacia fuera
  signal reg_input_1, reg_input_2, reg_input_3, reg_input_4, reg_input_5 : std_logic_vector(47 downto 0);


begin

  mont : pe_wrapper port map (
    clk          => clk,
    reset        => reset,
    ab_valid     => ab_valid,
    a            => mont_input_a,
    b            => b,
    n            => mont_input_n,
    s_prev       => mont_input_s,
    n_c          => n_c,
    s            => s,
    valid_in     => valid_mont,
    data_ready   => valid_mont_out,
    m_val        => m_val,
    reset_the_PE => reset_pe
    );

  process(clk, reset)
  begin
    if(clk = '1' and clk'event) then

      if(reset = '1')then
        state        <= wait_valid;
        counter      <= (others => '0');
        reg_constant <= (others => '0');
        reg_input    <= (others => '0');
        reg_input_1  <= (others => '0');
        reg_input_2  <= (others => '0');
        reg_input_3  <= (others => '0');
        reg_input_4  <= (others => '0');

        reg_out   <= (others => '0');
        reg_out_1 <= (others => '0');
        reg_out_2 <= (others => '0');
        reg_out_3 <= (others => '0');
        reg_out_4 <= (others => '0');

      else
        reg_input   <= next_reg_input;
        reg_input_1 <= reg_input;
        reg_input_2 <= reg_input_1;
        reg_input_3 <= reg_input_2;
        reg_input_4 <= reg_input_3;
        reg_input_5 <= reg_input_4;

        reg_out   <= reg_input_4(47 downto 32) & reg_input_4(31 downto 16);
        reg_out_1 <= reg_out;
        reg_out_2 <= reg_out_1;
        reg_out_3 <= reg_out_2;
        reg_out_4 <= reg_out_3;

        state        <= next_state;
        counter      <= next_counter;
        reg_constant <= next_reg_constant;
      end if;
    end if;
  end process;

  process(state, valid_in, m_val, a, n, s_prev, counter, valid_mont_out, stop, reg_constant, reg_input_5, reg_out_4)
  begin
    --reset_fifo <= '0';
    next_reg_input <= a&n&s_prev;       --Propagación de la entrada TODO add variable 
    --next_reg_out <= a&n;              --Vamos retrasando la entrada TODO add variable 


    a_out <= reg_out_4(31 downto 16);
    n_out <= reg_out_4(15 downto 0);

    next_state   <= state;
    next_counter <= counter;
    --write_fifos <= valid_in;
    ab_valid     <= '0';
    valid_mont   <= '0';
    valid_out    <= '0';
    reset_pe     <= '0';
    busy         <= '1';
    b_req        <= '0';
    c_step       <= '0';

    --Todo esto es nuevo
    mont_input_a      <= (others => '0');
    mont_input_n      <= (others => '0');
    mont_input_s      <= (others => '0');
    next_reg_constant <= reg_constant;

    case state is
      when wait_valid =>
        busy     <= '0';                --esperamos la peticion
        reset_pe <= '1';
        if(valid_in = '1') then

          b_req             <= '1';     --Solicitamos al modulo externo la b
          next_state        <= b_stable;
          next_reg_constant <= a&n&s_prev;  --TODO add variable                                                          
        end if;
      when b_stable =>
        next_state          <= prep_m;
      when prep_m   =>
        mont_input_a        <= reg_constant(47 downto 32);  --TODO add this to sensitivity
        mont_input_n        <= reg_constant(31 downto 16);
        mont_input_s        <= reg_constant(15 downto 0);
        ab_valid            <= '1';
        next_state          <= wait_m;
      when wait_m   =>

        --Mantenemos las entradas para que nos calcule m correctamente
        mont_input_a <= reg_constant(47 downto 32);  --TODO add this to sensitivity
        mont_input_n <= reg_constant(31 downto 16);
        mont_input_s <= reg_constant(15 downto 0);


        if (m_val = '1') then

          valid_mont   <= '1';
          next_state   <= mont_proc;
          mont_input_a <= reg_input_5(47 downto 32);
          mont_input_n <= reg_input_5(31 downto 16);
          mont_input_s <= reg_input_5(15 downto 0);

        end if;

      when mont_proc =>

        valid_mont   <= '1';
        mont_input_a <= reg_input_5(47 downto 32);
        mont_input_n <= reg_input_5(31 downto 16);
        mont_input_s <= reg_input_5(15 downto 0);

        if(valid_mont_out = '1') then

          next_counter <= x"00";
          next_state   <= getting_results;
        end if;

      when getting_results =>

        valid_out    <= '1';
        next_counter <= counter+1;
        valid_mont   <= '1';

        mont_input_a <= reg_input_5(47 downto 32);
        mont_input_n <= reg_input_5(31 downto 16);
        mont_input_s <= reg_input_5(15 downto 0);

        if(counter = (x"22")) then
          next_state <= wait_valid;
          c_step     <= '1';
          reset_pe   <= '1';
        end if;

    end case;

    if(stop = '1') then
      next_state <= wait_valid;
      --reset_fifo <= '1';
      reset_pe   <= '1';
    end if;

  end process;

end Behavioral;
