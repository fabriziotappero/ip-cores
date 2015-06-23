----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    16:01:04 12/13/2009 
-- Design Name: 
-- Module Name:    rsa_top - Behavioral 
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
-- synthesis translate_off
library UNISIM;
use UNISIM.VCOMPONENTS.all;
-- synthesis translate_on

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity rsa_top is
  port(
    clk       : in  std_logic;
    reset     : in  std_logic;
    valid_in  : in  std_logic;
    start_in  : in  std_logic;
    x         : in  std_logic_vector(15 downto 0);  -- estos 3 son x^y mod m
    y         : in  std_logic_vector(15 downto 0);
    m         : in  std_logic_vector(15 downto 0);
    r_c       : in  std_logic_vector(15 downto 0);  --constante de montgomery r^2 mod m
    s         : out std_logic_vector( 15 downto 0);
    valid_out : out std_logic;
    bit_size  : in  std_logic_vector(15 downto 0)  --tamano bit del exponente y (log2(y))
    );
end rsa_top;

architecture Behavioral of rsa_top is

  component n_c_core
    port (clk   : in  std_logic;
          m_lsw : in  std_logic_vector(15 downto 0);
          ce    : in  std_logic;
          n_c   : out std_logic_vector(15 downto 0);
          done  : out std_logic
          );
  end component;

--Multiplicador de Montgomery que sera instanciado 2 veces
  component montgomery_mult
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
      valid_out : out std_logic         -- es le valid out TODO : cambiar nombre
      );
  end component;

--Memoria para guardar el exponente y el modulo
  component Mem_b
    port (
      clka  : in  std_logic;
      wea   : in  std_logic_vector(0 downto 0);
      addra : in  std_logic_vector(5 downto 0);
      dina  : in  std_logic_vector(15 downto 0);
      douta : out std_logic_vector(15 downto 0));
  end component;


--fifos para los resultados de las mult parciales
  component res_out_fifo
    port (
      clk   : in  std_logic;
      rst   : in  std_logic;
      din   : in  std_logic_vector(31 downto 0);
      wr_en : in  std_logic;
      rd_en : in  std_logic;
      dout  : out std_logic_vector(31 downto 0);
      full  : out std_logic;
      empty : out std_logic);
  end component;


  signal valid_in_mon_1, valid_in_mon_2, valid_out_mon_1, valid_out_mon_2, fifo_1_rd, fifo_1_wr : std_logic;

  signal a_mon_1, b_mon_1, n_mon_1, s_p_mon_1, s_out_mon_1, a_mon_2, b_mon_2, n_mon_2, s_p_mon_2, s_out_mon_2, fifo_1_in, fifo_2_in, fifo_1_out, exp_out, n_out : std_logic_vector(15 downto 0);

  signal fifo_out, fifo_in : std_logic_vector(31 downto 0);

  signal addr_exp, addr_n, next_addr_exp, next_addr_n : std_logic_vector(5 downto 0);

  type state_type is (wait_start, prepare_data, wait_constants, writting_cts_fifo, processing_data_0, processing_data_1, wait_results, transition, prepare_next, writting_results, final_mult, show_final, prepare_final, wait_final);
  signal state, next_state                                            : state_type;
  signal w_numb, next_w_numb                                          : std_logic_vector(7 downto 0);
--Señales registradas
  signal n_c_reg, next_n_c_reg                                        : std_logic_vector(15 downto 0);
  --Cuenta los datos que se van metiendo al multiplicador para generar el padding por si solo.
  signal count_input, next_count_input, bit_counter, next_bit_counter : std_logic_vector(15 downto 0);

  signal bsize_reg, next_bsize_reg : std_logic_vector (15 downto 0);
  signal write_b_n                 : std_logic_vector(0 downto 0);

  signal n_c_o    : std_logic_vector(15 downto 0);
  signal n_c      : std_logic_vector(15 downto 0);
  signal n_c_load : std_logic;

begin

  n_c1 : n_c_core
    port map (
      clk   => clk,
      m_lsw => m,
      ce    => start_in,
      n_c   => n_c_o,
      done  => n_c_load
      );


  mon_1 : montgomery_mult port map(
    clk       => clk,
    reset     => reset,
    valid_in  => valid_in_mon_1,
    a         => a_mon_1,
    b         => b_mon_1,
    n         => n_mon_1,
    s_prev    => s_p_mon_1,
    n_c       => n_c_reg,
    s         => s_out_mon_1,
    valid_out => valid_out_mon_1
    );

  mon_2 : montgomery_mult port map(
    clk       => clk,
    reset     => reset,
    valid_in  => valid_in_mon_2,
    a         => a_mon_2,
    b         => b_mon_2,
    n         => n_mon_2,
    s_prev    => s_p_mon_2,
    n_c       => n_c_reg,
    s         => s_out_mon_2,
    valid_out => valid_out_mon_2
    );


  fifo_mon_out : res_out_fifo
    port map (
      clk   => clk,
      rst   => reset,
      din   => fifo_in,
      wr_en => fifo_1_wr,
      rd_en => fifo_1_rd,
      dout  => fifo_out
      );

  exp : Mem_b port map (
    clka  => clk,
    wea   => write_b_n,
    addra => addr_exp,
    dina  => y,
    douta => exp_out);

  n_mod : Mem_b port map (
    clka  => clk,
    wea   => write_b_n,
    addra => addr_n,
    dina  => m,
    douta => n_out);



  process(clk, reset)
  begin

    if(clk = '1' and clk'event) then

      if(reset = '1')then
        state       <= wait_start;
        n_c_reg     <= (others => '0');
        w_numb      <= (others => '0');
        count_input <= (others => '0');
        addr_exp    <= (others => '0');
        addr_n      <= (others => '0');
        bit_counter <= (others => '0');
        bsize_reg   <= (others => '0');
        n_c         <= (others => '0');

      else
        if(n_c_load = '1') then
          n_c       <= n_c_o;
        end if;
        state       <= next_state;
        n_c_reg     <= next_n_c_reg;
        w_numb      <= next_w_numb;
        count_input <= next_count_input;
        addr_exp    <= next_addr_exp;
        addr_n      <= next_addr_n;
        bit_counter <= next_bit_counter;
        bsize_reg   <= next_bsize_reg;
      end if;
    end if;
  end process;

  process(state, bsize_reg, n_c_reg, valid_in, x, n_c, r_c, m, y, w_numb, count_input, addr_exp, addr_n, s_out_mon_1, s_out_mon_2, bit_size, valid_out_mon_1, bit_counter, exp_out, fifo_out, n_out)

    variable mask : std_logic_vector(3 downto 0);

  begin

    --Registers update
    next_state       <= state;
    next_n_c_reg     <= n_c_reg;
    next_w_numb      <= w_numb;
    next_count_input <= count_input;
    next_bsize_reg   <= bsize_reg;
    --Entradas de los montgomerys.
    valid_in_mon_1   <= '0';
    valid_in_mon_2   <= '0';
    a_mon_1          <= (others => '0');
    b_mon_1          <= (others => '0');
    n_mon_1          <= (others => '0');
    a_mon_2          <= (others => '0');
    b_mon_2          <= (others => '0');
    n_mon_2          <= (others => '0');
    s_p_mon_1        <= (others => '0');
    s_p_mon_2        <= (others => '0');
    --Control de las fifos
    fifo_1_rd        <= '0';
    fifo_in          <= (others => '0');
    fifo_1_wr        <= '0';
    --Control de memorias de exp y modulo
    write_b_n        <= b"0";
    next_addr_exp    <= addr_exp;
    next_addr_n      <= addr_n;
    next_bit_counter <= bit_counter;
    --Outputs
    valid_out        <= '0';
    s                <= (others => '0');
    case state is

      when wait_start =>

        valid_in_mon_1 <= valid_in;
        valid_in_mon_2 <= valid_in;
        if(valid_in = '1') then
          a_mon_1      <= x;
          b_mon_1      <= r_c;
          n_mon_1      <= m;

          a_mon_2          <= x"0001";
          b_mon_2          <= r_c;
          n_mon_2          <= m;
          next_w_numb      <= x"23";    --Se extiende en 3 para poder usar las multiplicaciones modulares
          next_n_c_reg     <= n_c;
          next_state       <= prepare_data;
          next_count_input <= x"0001";

          write_b_n      <= b"1";       --Notificamos que hay que guardar el exponente y modulo
          next_addr_exp  <= "000001";
          next_addr_n    <= "000001";
          next_bsize_reg <= bit_size-1;
        end if;

      when prepare_data =>
        next_count_input <= count_input+1;
        valid_in_mon_1   <= '1';
        valid_in_mon_2   <= '1';
        --Esto es solo mientras los datos en la entrada son validos, cuando no lo son
        --se meten 0s para la extension de 3 palabras en los montgomerys
        if(valid_in = '1') then
          a_mon_1        <= x;
          b_mon_1        <= r_c;
          n_mon_1        <= m;
          b_mon_2        <= r_c;
          n_mon_2        <= m;

          write_b_n     <= b"1";
          next_addr_exp <= addr_exp+1;
          next_addr_n   <= addr_n+1;
        end if;
        if(count_input = w_numb) then
          next_state    <= wait_constants;
          next_addr_n   <= (others => '0');

          next_addr_exp                                                    <= bsize_reg(9 downto 4);
                                        --Decodificador para establecer la mascara
          mask := bsize_reg(3 downto 0);
          case (mask) is
            when "0000"                                => next_bit_counter <= "0000000000000001";
            when "0001"                                => next_bit_counter <= "0000000000000010";
            when "0010"                                => next_bit_counter <= "0000000000000100";
            when "0011"                                => next_bit_counter <= "0000000000001000";
            when "0100"                                => next_bit_counter <= "0000000000010000";
            when "0101"                                => next_bit_counter <= "0000000000100000";
            when "0110"                                => next_bit_counter <= "0000000001000000";
            when "0111"                                => next_bit_counter <= "0000000010000000";
            when "1000"                                => next_bit_counter <= "0000000100000000";
            when "1001"                                => next_bit_counter <= "0000001000000000";
            when "1010"                                => next_bit_counter <= "0000010000000000";
            when "1011"                                => next_bit_counter <= "0000100000000000";
            when "1100"                                => next_bit_counter <= "0001000000000000";
            when "1101"                                => next_bit_counter <= "0010000000000000";
            when "1110"                                => next_bit_counter <= "0100000000000000";
            when "1111"                                => next_bit_counter <= "1000000000000000";
            when others                                =>
          end case;
          next_count_input                                                 <= (others => '0');
        end if;

        --Esperamos los valores validos de la salida de los montgomery                  
      when wait_constants =>

        --Comienzo a escribir en la fifo de datos
        if(valid_out_mon_1 = '1') then
          fifo_1_wr        <= '1';
          fifo_in          <= s_out_mon_1 & s_out_mon_2;
          next_count_input <= count_input+1;
          next_state       <= writting_cts_fifo;
        end if;

        --Escribimos las dos constantes iniciales en las fifos
      when writting_cts_fifo =>
        fifo_1_wr        <= valid_out_mon_1;
        next_count_input <= count_input+1;
        if(count_input < x"20") then
          fifo_in        <= s_out_mon_1 & s_out_mon_2;
        end if;

        --Pedimos el siguiente input para la multiplicacion
        if(valid_out_mon_1 = '0') then
          next_count_input <= (others => '0');
          next_state       <= transition;
        end if;

      when transition =>

        next_count_input <= count_input+1;

        if(count_input > 2) then
          next_count_input <= (others => '0');
                                        --fifo_1_rd <= '1';
                                        --next_addr_n <= addr_n+1;
          if((bit_counter and exp_out) = x"0000") then
            next_state     <= processing_data_0;
          else
            next_state     <= processing_data_1;
          end if;

        end if;

        --se van ejecutando las multiplicaciones sucesivas
      when processing_data_1 =>


        if(count_input > x"0000")then
          valid_in_mon_1 <= '1';
          valid_in_mon_2 <= '1';
        end if;


        fifo_1_rd <= '1';

        a_mon_1 <= fifo_out(31 downto 16);
        b_mon_1 <= fifo_out(15 downto 0);
        n_mon_1 <= n_out;

        a_mon_2 <= fifo_out(31 downto 16);
        b_mon_2 <= fifo_out(31 downto 16);
        n_mon_2 <= n_out;

        next_addr_n      <= addr_n+1;
        next_count_input <= count_input +1;

        --Cuando llego al final cambio de estado a esperar resultados
        if(count_input = w_numb) then
          next_state <= wait_results;
        end if;

      when processing_data_0 =>

        if(count_input > x"0000")then
          valid_in_mon_1 <= '1';
          valid_in_mon_2 <= '1';
        end if;

        fifo_1_rd <= '1';

        a_mon_1 <= fifo_out(15 downto 0);
        b_mon_1 <= fifo_out(15 downto 0);
        n_mon_1 <= n_out;

        a_mon_2 <= fifo_out(31 downto 16);
        b_mon_2 <= fifo_out(15 downto 0);
        n_mon_2 <= n_out;

        next_addr_n      <= addr_n+1;
        next_count_input <= count_input +1;

        --Cuando llego al final cambio de estado a esperar resultados
        if(count_input = w_numb) then
          next_state       <= wait_results;
          next_count_input <= (others => '0');
        end if;

      when wait_results =>

        --Comienzo a escribir en la fifo de datos
        if(valid_out_mon_1 = '1') then
          fifo_1_wr        <= '1';
          fifo_in          <= s_out_mon_2 & s_out_mon_1;
          next_count_input <= x"0001";
          next_state       <= writting_results;
        end if;

      when writting_results =>

        next_addr_n      <= (others => '0');
        fifo_1_wr        <= valid_out_mon_1;
        next_count_input <= count_input+1;
        if(count_input < x"20") then
          fifo_in        <= s_out_mon_2 & s_out_mon_1;
        end if;

        --Pedimos el siguiente input para la multiplicacion
        if(valid_out_mon_1 = '0') then
          next_count_input   <= (others => '0');
          next_state         <= prepare_next;
                                        --Calculo del siguiente bit del exponente
                                        --Shifto uno la mascara
          next_bit_counter   <= '0'&bit_counter(15 downto 1);
          if(bit_counter = x"0001")
          then
            next_addr_exp    <= addr_exp -1;
            next_bit_counter <= "1000000000000000";
          end if;
          if((bit_counter = x"0001") and addr_exp = "000000000")
          then
            next_state       <= final_mult;
            next_count_input <= (others => '0');
            next_addr_exp    <= (others => '0');
          end if;
        end if;

      when prepare_next             =>
        next_state       <= transition;
        next_count_input <= (others => '0');
        fifo_1_rd        <= '0';

      when final_mult =>
        next_count_input <= count_input+1;

        if(count_input > 2) then
          next_count_input <= (others => '0');
          next_state       <= prepare_final;
        end if;

      when prepare_final =>

        if(count_input > x"0000")then
          valid_in_mon_1 <= '1';
        end if;

        fifo_1_rd <= '1';

        a_mon_1   <= fifo_out(15 downto 0);
        if(count_input = x"0001") then
          b_mon_1 <= x"0001";
        end if;
        n_mon_1   <= n_out;

        next_addr_n      <= addr_n+1;
        next_count_input <= count_input +1;

        --Cuando llego al final cambio de estado a esperar resultados
        if(count_input = w_numb) then
          next_state       <= wait_final;
          next_count_input <= (others => '0');
        end if;

      when wait_final =>

        if(valid_out_mon_1 = '1') then
          valid_out        <= '1';
          s                <= s_out_mon_1;
          next_state       <= show_final;
          next_count_input <= count_input +1;
        end if;

      when show_final =>
        valid_out        <= '1';
        s                <= s_out_mon_1;
        next_count_input <= count_input +1;
        --Cuando llego al final cambio de estado a esperar resultados
        if(count_input = x"20") then
          valid_out      <= '0';
          next_state     <= wait_start;
        end if;

    end case;

  end process;

end Behavioral;

