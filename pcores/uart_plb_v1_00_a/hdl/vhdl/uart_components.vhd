library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

package uart_components is

component uart
    generic (DATA_BITS        : integer);
    Port (
        rst                   : in  std_logic;
        clk                   : in  std_logic;
        dlw                   : in  std_logic_vector(15 downto 0);
        --
        -- DLW = round(clk_Hz / (Desired_BaudRate x 16)) - 2
        -- For baudrate 115200Hz :
        -- 62.5MHz  :  DLW = 0x001F
        -- 50.0MHz  :  DLW = 0x0019
        --
        tx_wr                 : in  std_logic;   -- pulse signal
        tx_fifo_reset         : in  std_logic;   -- pulse signal
        tx_din                : in  std_logic_vector(DATA_BITS-1 downto 0);
        tx_fifo_full          : out std_logic;   -- level signal
        tx_fifo_almost_full   : out std_logic;   -- level signal
        tx_fifo_empty         : out std_logic;   -- level signal
        tx_fifo_almost_empty  : out std_logic;   -- level signal
        tx_xmt_empty          : out std_logic;   -- level signal, transmit shift register empty
        --
        rx_rd                 : in  std_logic;   -- pulse signal
        rx_fifo_reset         : in  std_logic;   -- pulse signal
        rx_dout               : out std_logic_vector(DATA_BITS-1 downto 0);
        rx_fifo_full          : out std_logic;   -- level signal
        rx_fifo_almost_full   : out std_logic;   -- level signal
        rx_fifo_empty         : out std_logic;   -- level signal
        rx_fifo_almost_empty  : out std_logic;   -- level signal
        rx_timeout            : out std_logic;   -- pulse signal
        --
        tx_sout               : out std_logic;
        rx_sin                : in  std_logic
     );
end component;

component baudrate
    port(
        clk                   : in  std_logic;
        rst                   : in  std_logic;
        dlw                   : in  std_logic_vector(15 downto 0);
        tick                  : out std_logic   -- baudrate * 16 tick
    );
end component;

component xmt
    generic (DATA_BITS : integer);
    port (
        clk                   : in  std_logic;  -- Clock
        rst                   : in  std_logic;  -- Reset
        tick                  : in  std_logic;  -- baudrate * 16 tick
        wr                    : in  std_logic;  -- write din to transmitter
        din                   : in  std_logic_vector(DATA_BITS-1 downto 0);  -- Input data
        sout                  : out std_logic;  -- Transmitter serial output
        done                  : out std_logic   -- Transmitter operation finished
    );
end component;

component rcv
    generic (DATA_BITS : integer);
    port (
        clk                   : in  std_logic;  -- Clock
        rst                   : in  std_logic;  -- Reset
        tick                  : in  std_logic;  -- baudrate * 16 tick
        sin                   : in  std_logic;  -- Receiver serial input
        dout                  : out std_logic_vector(DATA_BITS-1 downto 0);   -- Output data
        done                  : out std_logic   -- Receiver operation finished
    );
end component;

component tmo
    Port (
        clk                   : in  std_logic;
        clr                   : in  std_logic;
        tick                  : in  std_logic;
        timeout               : out std_logic
    );
end component;

COMPONENT fifo_generator_v8_1_8x16
    PORT (
        clk                   : IN  STD_LOGIC;
        srst                  : IN  STD_LOGIC;
        din                   : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
        wr_en                 : IN  STD_LOGIC;
        rd_en                 : IN  STD_LOGIC;
        dout                  : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
        full                  : OUT STD_LOGIC;
        almost_full           : OUT STD_LOGIC;
        empty                 : OUT STD_LOGIC;
        almost_empty          : OUT STD_LOGIC
  );
END COMPONENT;

end uart_components;

package body uart_components is

end uart_components;
