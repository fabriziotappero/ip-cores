library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_pinger is
  
  generic (
    data_width_g     : integer := 32;
    comm_width_g     : integer := 3;
    own_hibi_addr_g  : integer;
    init_send_addr_g : integer;
    start_sending_g  : integer );
  port (
    clk      : in  std_logic;
    rst_n    : in  std_logic;
    data_in  : in  std_logic_vector(data_width_g-1 downto 0);
    comm_in  : in  std_logic_vector(comm_width_g-1 downto 0);
    av_in    : in  std_logic;
    empty_in : in  std_logic;
    re_out   : out std_logic;
    data_out : out std_logic_vector(data_width_g-1 downto 0);
    comm_out : out std_logic_vector(comm_width_g-1 downto 0);
    av_out   : out std_logic;
    full_in  : in  std_logic;
    we_out   : out std_logic);

end tb_pinger;

architecture rtl of tb_pinger is

  signal data_counter_r : integer;
signal inc_data_counter : std_logic;
  
  signal wait_delay_r    : integer;
  signal delay_counter_r : integer;
  signal ping_counter_r  : integer;
  type   states is (wait_data, wait_counter, send_av, send_amount, send_data);
  signal state           : states;
  signal ret_addr_r      : std_logic_vector(data_width_g-1 downto 0);
  signal amount_r : std_logic_vector(data_width_g-1 downto 0);
  
  signal addr_sent : std_logic;
  signal data_sent : std_logic;
  signal amount_sent : std_logic;
begin  -- rtl

  process (clk, rst_n)
  begin  -- process
    if rst_n = '0' then                 -- asynchronous reset (active low)
      ret_addr_r      <= std_logic_vector(to_unsigned(init_send_addr_g, data_width_g));
      if start_sending_g = 1 then
        state           <= send_av;        
      else
        state <= wait_data;
      end if;
      

      wait_delay_r    <= 1;
      ping_counter_r  <= 0;
      delay_counter_r <= 0;
      data_counter_r  <= 0;
      amount_r <= std_logic_vector( to_unsigned( 10, data_width_g) );
      
    elsif clk'event and clk = '1' then  -- rising clock edge
      case state is
        when wait_data =>
          if av_in = '0' and empty_in = '0' then

            if data_counter_r = 0 then
              amount_r <= data_in;
            end if;
            if data_counter_r = 1 then
              ret_addr_r <= data_in;
            end if;

            if data_counter_r = to_integer(unsigned(amount_r)+1) then
              state          <= wait_counter;
              data_counter_r <= 0;
            else
              data_counter_r <= data_counter_r + 1;              
            end if;
          end if;

        when wait_counter =>
          if delay_counter_r = wait_delay_r then
            state           <= send_av;
            delay_counter_r <= 0;
          else
            delay_counter_r <= delay_counter_r + 1;
          end if;

        when send_av =>
          
          if addr_sent = '1' then
            state <= send_amount;
          end if;

        when send_amount =>
          if amount_sent = '1' then
            state <= send_data;
          end if;
          
        when send_data =>
          
          if inc_data_counter = '1' then
            data_counter_r <= data_counter_r + 1;
          end if;
          
          if data_sent = '1' then
            state          <= wait_data;
            data_counter_r <= 0;

            if ping_counter_r = 100 then
              ping_counter_r <= 0;
              wait_delay_r   <= wait_delay_r + 1;
            else
              ping_counter_r <= ping_counter_r + 1;
            end if;

          end if;
      end case;
    end if;
  end process;

  process (full_in, state, ret_addr_r, rst_n, data_counter_r, amount_r)
  begin  -- process
    av_out    <= '0';
    we_out    <= '0';
    data_out  <= (others => '0');
    comm_out  <= (others => '0');
    re_out    <= '0';
    data_sent <= '0';
    addr_sent <= '0';
    amount_sent <= '0';
    inc_data_counter <= '0';

    case state is
      when wait_data =>
        re_out <= '1';
      when wait_counter =>
        re_out <= '1';

      when send_av =>
        if full_in = '0' and rst_n = '1' then
          we_out    <= '1';
          av_out    <= '1';
          data_out  <= ret_addr_r;
          comm_out  <= "010";
          addr_sent <= '1';
        end if;

      when send_amount =>
        if full_in = '0' then
          we_out    <= '1';
          data_out  <= std_logic_vector( unsigned( amount_r ) + 1 );
          comm_out  <= "010";
          amount_sent <= '1';
        end if;

      when send_data =>
        if full_in = '0' then
          we_out   <= '1';
          if data_counter_r = 0 then
            data_out <= std_logic_vector(to_unsigned(own_hibi_addr_g, data_width_g));
          else
            data_out <= std_logic_vector(to_unsigned(data_counter_r,data_width_g));
          end if;
          comm_out <= "010";

          inc_data_counter <= '1';
          
          if data_counter_r = to_integer( unsigned(amount_r) + 1) then
            data_sent <= '1';
          end if;
          
        end if;
    end case;
    
  end process;

end rtl;
