-------------------------------------------------------------------------------
-- title      : tb_fifo_stratix
-- project    : 
-------------------------------------------------------------------------------
-- file       : tb_fifo_stratix.vhdl
-- author     : kulmala3
-- created    : 08.09.2004
-- last update: 31.05.2005
-- description: tests that fifo_stratix works in fpga. synthesizable test bench
-------------------------------------------------------------------------------
-- revisions  :
-- date        version  author  description
-- 08.09.2004  1.0      ak      created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity tb_fifo_stratix is
  
  port (
    clk           : in  std_logic;
    rst_n         : in  std_logic;
    led_state_out : out std_logic_vector(3 downto 0);
    led_error_out : out std_logic_vector(3 downto 0)
    );

end tb_fifo_stratix;

architecture rtl of tb_fifo_stratix is

  component fifo
    generic (
      data_width_g : integer;
      depth_g      : integer);
    port (
      clk       : in  std_logic;
      rst_n     : in  std_logic;
      data_in   : in  std_logic_vector (data_width_g-1 downto 0);
      we_in     : in  std_logic;
      one_p_out : out std_logic;
      full_out  : out std_logic;
      data_out  : out std_logic_vector (data_width_g-1 downto 0);
      re_in     : in  std_logic;
      empty_out : out std_logic;
      one_d_out : out std_logic);
  end component;

  type ctrl_state is (initial, write_fifo, read_fifo);

  signal control_r       : ctrl_state;
  signal write_counter_r : integer range 0 to 2**16-1;
  signal read_counter_r  : integer range 0 to 2**16-1;
  signal read_data_r     : integer range 0 to 2**16-1;
  signal error_counter_r : integer range 0 to 2**16-1;

  constant initial_c : std_logic_vector := "0001";
  constant write_c   : std_logic_vector := "0010";
  constant read_c    : std_logic_vector := "0100";


  constant width : integer := 16;
  constant depth : integer := 5;

  signal data_to_fifo     : std_logic_vector (width-1 downto 0);
  signal write_enable     : std_logic;
  signal one_place_left_r : std_logic;
  signal full_r           : std_logic;
  signal data_from_fifo   : std_logic_vector (width-1 downto 0);
  signal read_enable      : std_logic;
  signal empty_r          : std_logic;
  signal one_data_left_r  : std_logic;

  signal ef_r : std_logic_vector(1 downto 0);
  signal temp : std_logic;
begin  -- rtl

  data_to_fifo  <= conv_std_logic_vector(write_counter_r, width);
  read_data_r   <= conv_integer(data_from_fifo);
  ef_r          <= empty_r & full_r;
  led_error_out <= conv_std_logic_vector(error_counter_r, 4);
  temp          <= one_data_left_r and one_place_left_r;

  fifo_1 : fifo
    generic map (
      data_width_g => width,
      depth_g      => depth)
    port map (
      clk       => clk,
      rst_n     => rst_n,
      data_in   => data_to_fifo,
      we_in     => write_enable,
      one_p_out => one_place_left_r,
      full_out  => full_r,
      data_out  => data_from_fifo,
      re_in     => read_enable,
      empty_out => empty_r,
      one_d_out => one_data_left_r);

  process (clk, rst_n)
  begin  -- process
    if rst_n = '0' then                 -- asynchronous reset (active low)
      control_r       <= initial;
      write_enable    <= '0';
      read_enable     <= '0';
      write_counter_r <= 0;
      read_counter_r  <= 1;
      -- just to use one_data_left_r and one_place_left_r
      led_state_out   <= temp & temp & temp & temp;
      error_counter_r <= 0;
      
    elsif clk'event and clk = '1' then  -- rising clock edge

      case control_r is
        when initial =>
          case ef_r is
            when "00" | "01" =>  -- not empty, not full or full-> read              
              control_r    <= read_fifo;
              write_enable <= '0';
              read_enable  <= '0';
            when "10" =>                -- empty, write
              control_r    <= write_fifo;
              write_enable <= '0';
              read_enable  <= '0';
            when others => null;        --empty and full, not possible...
          end case;
          led_state_out <= initial_c;
          
        when write_fifo =>
          read_enable <= '0';
          if full_r = '0' then          -- not yet full
            write_enable    <= '1';
            write_counter_r <= write_counter_r+1;
            control_r       <= write_fifo;
          else
            -- fifo full
            write_enable    <= '0';
            -- write_counter_r+1 always written, so we do -1 here.
            write_counter_r <= write_counter_r-1;
            control_r       <= read_fifo;
          end if;
          led_state_out <= write_c;
          
        when read_fifo =>
          write_enable <= '0';
          if empty_r = '0' then
            read_enable <= '1';
            if read_enable = '1' then
              if read_data_r /= read_counter_r then
                -- error!
                assert false report "fifo read error, wrong data" severity error;
                if error_counter_r >= 2**4-1 then
                  error_counter_r <= 0;
                else
                  error_counter_r <= error_counter_r +1;
                end if;
                -- if something was missing, start from the new data value
                read_counter_r <= read_data_r+1;
              else
                error_counter_r <= error_counter_r;
                read_counter_r  <= read_counter_r+1;
              end if;
              control_r <= read_fifo;
            end if;
          else
            -- empty
            read_enable     <= '0';
            read_counter_r  <= read_counter_r;
            error_counter_r <= error_counter_r;
            control_r       <= initial;
          end if;

          led_state_out <= read_c;

          
        when others => null;

                       
      end case;

      
    end if;
  end process;
  

end rtl;
