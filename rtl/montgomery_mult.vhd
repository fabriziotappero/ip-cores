----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    20:03:35 11/02/2009 
-- Design Name: 
-- Module Name:    etapas - Behavioral 
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

entity montgomery_mult is

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
    valid_out : out std_logic           -- es le valid out TODO : cambiar nombre
    );

end montgomery_mult;

architecture Behavioral of montgomery_mult is

  component montgomery_step is
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
                                valid_out : out std_logic;  -- es le valid out TODO : cambiar nombre
                                busy      : out std_logic;
                                b_req     : out std_logic;
                                a_out     : out std_logic_vector(15 downto 0);
                                n_out     : out std_logic_vector(15 downto 0);  --señal que indica que el modulo está ocupado y no puede procesar nuevas peticiones
                                c_step    : out std_logic;  --genera un pulso cuando termina su computo para avisar al modulo superior
                                stop      : in  std_logic
                                );
  end component;

  component fifo_512_bram
    port (
      clk   : in  std_logic;
      rst   : in  std_logic;
      din   : in  std_logic_vector(15 downto 0);
      wr_en : in  std_logic;
      rd_en : in  std_logic;
      dout  : out std_logic_vector(15 downto 0);
      full  : out std_logic;
      empty : out std_logic);
  end component;

  component fifo_256_feedback
    port (
      clk   : in  std_logic;
      rst   : in  std_logic;
      din   : in  std_logic_vector(48 downto 0);
      wr_en : in  std_logic;
      rd_en : in  std_logic;
      dout  : out std_logic_vector(48 downto 0);
      full  : out std_logic;
      empty : out std_logic);
  end component;

  type arr_dat_out is array(0 to 7) of std_logic_vector(15 downto 0);
  type arr_val is array(0 to 7) of std_logic;
  type arr_b is array(0 to 7) of std_logic_vector(15 downto 0);

  signal b_reg, next_b_reg                                              : arr_b;
  signal valid_mid, fifo_reqs, fifo_reqs_reg, next_fifo_reqs_reg, stops : arr_val;
  signal a_out_mid, n_out_mid, s_out_mid                                : arr_dat_out;  --std_logic_vector(15 downto 0);

  --Señales a la fifo
  signal wr_en, rd_en, empty : std_logic;
  signal fifo_out            : std_logic_vector(15 downto 0);

  signal fifo_out_feedback, fifo_in_feedback : std_logic_vector(48 downto 0);
  signal read_fifo_feedback, empty_feedback  : std_logic;

  --Señales de entrada al primer PE
  signal a_in, s_in, n_in : std_logic_vector(15 downto 0);
  signal f_valid, busy_pe : std_logic;

  --salida c_step del primer PE para ir contando y saber cuando sacar el valor correcto.
  signal c_step, reg_c_step : std_logic;

  --contador para saber cuando coño acabamos :)
  signal count, next_count : std_logic_vector(7 downto 0);

  --señal para escribir el loopback en la fifo de entrada de feedback
  signal wr_fifofeed : std_logic;

  type state_type is (rst_fifos, wait_start, process_data, dump_feed);
  signal state, next_state                   : state_type;
  signal reg_busy                            : std_logic;
  signal reset_fifos                         : std_logic;
  signal count_feedback, next_count_feedback : std_logic_vector(15 downto 0);

begin

--Fifo para almacenar b
  fifo_b : fifo_512_bram port map (
    clk   => clk,
    rst   => reset_fifos,
    din   => b,
    wr_en => wr_en,
    rd_en => rd_en,
    dout  => fifo_out,
    empty => empty
    );

--Fifo para el feedback al primer PE
  fifo_feed : fifo_256_feedback port map (
    clk   => clk,
    rst   => reset_fifos,
    din   => fifo_in_feedback,
    wr_en => wr_fifofeed,
    rd_en => read_fifo_feedback,
    dout  => fifo_out_feedback,
    empty => empty_feedback
    );



--Primer PE
  et_first : montgomery_step port map(
    clk       => clk,
    reset     => reset,
    valid_in  => f_valid,
    a         => a_in,
    b         => b_reg(0),
    n         => n_in,
    s_prev    => s_in,
    n_c       => n_c,
    s         => s_out_mid(0),
    valid_out => valid_mid(0),
    busy      => busy_pe,
    b_req     => fifo_reqs(0),
    a_out     => a_out_mid(0),
    n_out     => n_out_mid(0),
    c_step    => c_step,
    stop      => stops(0)
    );

--Ultimo PE
  et_last : montgomery_step port map(
    clk       => clk,
    reset     => reset,
    valid_in  => valid_mid(6),
    a         => a_out_mid(6),
    b         => b_reg(7),
    n         => n_out_mid(6),
    s_prev    => s_out_mid(6),
    n_c       => n_c,
    s         => s_out_mid(7),
    valid_out => valid_mid(7),
    b_req     => fifo_reqs(7),
    a_out     => a_out_mid(7),
    n_out     => n_out_mid(7),
    stop      => stops(7)
    );

  g1     : for i in 1 to 6 generate
    et_i : montgomery_step port map(
      clk       => clk,
      reset     => reset,
      valid_in  => valid_mid(i-1),
      a         => a_out_mid(i-1),
      b         => b_reg(i),
      n         => n_out_mid(i-1),
      s_prev    => s_out_mid(i-1),
      n_c       => n_c,
      s         => s_out_mid(i),
      valid_out => valid_mid(i),
      b_req     => fifo_reqs(i),
      a_out     => a_out_mid(i),
      n_out     => n_out_mid(i),
      stop      => stops(i)
      );

  end generate g1;


  process(clk, reset)
  begin

    if(clk = '1' and clk'event) then

      if(reset = '1')then
        state               <= wait_start;
        count_feedback      <= (others => '0');
        reg_busy            <= '0';
        for i in 0 to 7 loop
          b_reg(i)          <= (others => '0');
          fifo_reqs_reg (i) <= '0';
          count             <= (others => '0');
          reg_c_step        <= '0';

        end loop;
      else
        state               <= next_state;
        reg_busy            <= busy_pe;
        count_feedback      <= next_count_feedback;
        for i in 0 to 7 loop
          b_reg(i)          <= next_b_reg(i);
          fifo_reqs_reg (i) <= next_fifo_reqs_reg(i);
          count             <= next_count;
          reg_c_step        <= c_step;
        end loop;
      end if;
    end if;

  end process;


  --Proceso combinacional que controla las lecturas a la fifo
  process(fifo_reqs_reg, fifo_out, b, fifo_reqs, b_reg, state, empty)
  begin


    for i in 0 to 7 loop
      next_b_reg(i)         <= b_reg(i);
      next_fifo_reqs_reg(i) <= fifo_reqs(i);
    end loop;

    if(state = wait_start) then
      next_b_reg(0)           <= b;
      next_fifo_reqs_reg(0)   <= '0';   --anulamos la peticion de b
      for i in 1 to 7 loop
        next_b_reg(i)         <= (others => '0');
        next_fifo_reqs_reg(i) <= '0';
      end loop;
    else
      for i in 0 to 7 loop
        if(fifo_reqs_reg(i) = '1' and empty = '0') then
          next_b_reg(i)       <= fifo_out;
        end if;
      end loop;
    end if;
  end process;

  --Proceso combinacional fsm principal
  process( valid_in, b, state, fifo_reqs, a_out_mid, n_out_mid, s_out_mid, valid_mid, a, s_prev, n, busy_pe, empty_feedback, fifo_out_feedback, count, reg_c_step, reset, reg_busy, count_feedback )
  begin

    --las peticiones a la fifo son las or de los modulos
    rd_en              <= fifo_reqs(0) or fifo_reqs(1) or fifo_reqs(2) or fifo_reqs(3) or fifo_reqs(4) or fifo_reqs(5) or fifo_reqs(6) or fifo_reqs(7);
    next_state         <= state;
    wr_en              <= '0';
    fifo_in_feedback   <= a_out_mid(7)&n_out_mid(7)&s_out_mid(7)&valid_mid(7);
    read_fifo_feedback <= '0';
    wr_fifofeed        <= '0';
    --Controlamos el primer PE
    a_in               <= a;
    s_in               <= s_prev;
    n_in               <= n;
    f_valid            <= valid_in;
    reset_fifos        <= reset;
    --ponemos las salidas
    s                  <= (others => '0');
    valid_out          <= '0';

    --Incrementamos el contador solo cuando el primer PE termina su cuenta
    next_count          <= count;
    next_count_feedback <= count_feedback;
    --El contador solo se incrementa una vez por ciclo de la pipeline, así me evito que cada PE lo incremente
    if(reg_c_step = '1') then
      next_count        <= count + 8;
    end if;
    --durante el ciclo de la pipeline que sea considerado el ultimo, sacamos los datos
    if( count = x"20") then
      s                 <= s_out_mid(0);
      valid_out         <= valid_mid(0);
    end if;

    for i in 0 to 7 loop
      stops(i) <= '0';
    end loop;

    case state is
      --Esperamos a que tengamos un input y vamos cargando las b's
      when wait_start =>
        --reset_fifos   <= '1';
        if(valid_in = '1') then
          reset_fifos <= '0';
          --next_b_reg(0) <= b;
          next_state  <= process_data;
                                        --wr_en <= '1';
        end if;

      when process_data =>
        wr_fifofeed           <= valid_mid(7);
        if(valid_in = '1') then
          wr_en               <= '1';
        end if;
        --Miramos si hay que volver a meter datos a la b
        if(empty_feedback = '0' and reg_busy = '0') then
          read_fifo_feedback  <= '1';
          next_state          <= dump_feed;
          next_count_feedback <= x"0000";
        end if;

        --Si ya hemos sobrepasado el limite paramos y volvemos a la espera
        if( count > x"23") then
          next_state <= wait_start;
                                        --y
          for i in 0 to 7 loop
            stops(i) <= '1';
          end loop;
          next_count <= (others => '0');
        end if;

        --Vacia la fifo de feedback
      when dump_feed =>
        if(empty_feedback = '0')
        then
          next_count_feedback <= count_feedback+1;
        end if;
        wr_fifofeed           <= valid_mid(7);
        read_fifo_feedback    <= '1';
        a_in                  <= fifo_out_feedback(48 downto 33);
        n_in                  <= fifo_out_feedback(32 downto 17);
        s_in                  <= fifo_out_feedback(16 downto 1);
        f_valid               <= fifo_out_feedback(0);
        if(empty_feedback = '1') then
          next_state          <= process_data;

        end if;
        if(count_feedback = x"22") then
          read_fifo_feedback <= '0';
          next_state         <= process_data;
        end if;
      when rst_fifos =>
        next_state           <= wait_start;
        reset_fifos          <= '1';
    end case;

  end process;
end Behavioral;

