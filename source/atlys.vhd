--------------------------------------------------------------------------------
---
---  CHIPS - 2.0 Simple Web App Demo
---
---  :Author: Jonathan P Dawson
---  :Date: 17/10/2013
---  :email: chips@jondawson.org.uk
---  :license: MIT
---  :Copyright: Copyright (C) Jonathan P Dawson 2013
---
---  A Serial Input Component
---
--------------------------------------------------------------------------------
---
---           +--------------+
---           | CLOCK TREE   |
---           +--------------+
---           |              >-- CLK1   (50MHz) ---> CLK
--- CLK_IN >-->              |
---           |              >-- CLK2   (100MHz)
---           |              |                     +-------+
---           |              +-- CLK3   (125MHz) ->+ ODDR2 +-->[GTXCLK]
---           |              |                     |       |
---           |              +-- CLK3_N (125MHZ) ->+       |
---           |              |                     +-------+
--- RST >----->              >-- CLK4   (200MHz)
---           |              |
---           |              |
---           |              |  CLK >--+--------+
---           |              |         |        |
---           |              |      +--v-+   +--v-+
---           |              |      |    |   |    |
---           |       LOCKED >------>    >--->    >-------> INTERNAL_RESET
---           |              |      |    |   |    |
---           +--------------+      +----+   +----+
---
---              +-------------+     +--------------+               
---              | SERVER      |     | USER DESIGN  |
---              +-------------+     +--------------+
---              |             |     |              |
---              |             >----->              <-------< SWITCHES
---              |             |     |              |
---              |             <-----<              >-------> LEDS
---              |             |     |              |               
---              |             |     |              <-------< BUTTONS
---              |             |     |              |
---              |             |     +----^----v----+
---              |             |          |    |
---              |             |     +----^----v----+
---              |             |     | UART         |
---              |             |     +--------------+
---              |             |     |              >-------> RS232-TX
---              |             |     |              |
---              +---v-----^---+     |              <-------< RS232-RX 
---                  |     |         +--------------+
---              +---v-----^---+           
---              | ETHERNET    |           
---              | MAC         |           
---              +-------------+           
---              |             +------> [PHY_RESET]           
---              |             |           
---[RXCLK] ----->+             +------> [TXCLK]           
---              |             |           
--- 125MHZ ----->+             +------> open           
---              |             |           
---  [RXD] ----->+             +------> [TXD]
---              |             |           
--- [RXDV] ----->+             +------> [TXEN]           
---              |             |           
--- [RXER] ----->+             +------> [TXER]           
---              |             |           
---              |             |
---              +-------------+
---

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library unisim;
use unisim.vcomponents.all;

entity ATLYS is
  port(
   CLK_IN        : in    std_logic;       
   RST           : in    std_logic;       

   --PHY INTERFACE
   TX            : out   std_logic;       
   RX            : in    std_logic;       
   PHY_RESET     : out   std_logic;       
   RXDV          : in    std_logic;       
   RXER          : in    std_logic;       
   RXCLK         : in    std_logic;       
   RXD           : in    std_logic_vector(7 downto 0);
   TXCLK         : in    std_logic;     
   GTXCLK        : out   std_logic;      
   TXD           : out   std_logic_vector(7 downto 0);
   TXEN          : out   std_logic;      
   TXER          : out   std_logic;   

   --LEDS
   GPIO_LEDS     : out std_logic_vector(7 downto 0);   
   GPIO_SWITCHES : in  std_logic_vector(7 downto 0);   
   GPIO_BUTTONS  : in  std_logic_vector(3 downto 0);   

   --RS232 INTERFACE
   RS232_RX      : in    std_logic;
   RS232_TX      : out   std_logic
  );
end entity ATLYS;

architecture RTL of ATLYS is

  component gigabit_ethernet is
    port(
      CLK         : in  std_logic;
      RST         : in  std_logic;

      --Ethernet Clock
      CLK_125_MHZ : in  std_logic;

      --GMII IF
      GTXCLK      : out std_logic;
      TXCLK       : in  std_logic;
      TXER        : out std_logic;
      TXEN        : out std_logic;
      TXD         : out std_logic_vector(7 downto 0);
      PHY_RESET   : out std_logic;
      RXCLK       : in  std_logic;
      RXER        : in  std_logic;
      RXDV        : in  std_logic;
      RXD         : in  std_logic_vector(7 downto 0);

      --RX STREAM
      TX          : in  std_logic_vector(15 downto 0);
      TX_STB      : in  std_logic;
      TX_ACK      : out std_logic;

      --RX STREAM
      RX          : out std_logic_vector(15 downto 0);
      RX_STB      : out std_logic;
      RX_ACK      : in  std_logic
    );
  end component gigabit_ethernet;

  component SERVER is
    port(
      CLK : in std_logic;
      RST : in std_logic;
    
      --ETH RX STREAM
      INPUT_ETH_RX : in std_logic_vector(15 downto 0);
      INPUT_ETH_RX_STB : in std_logic;
      INPUT_ETH_RX_ACK : out std_logic;

      --ETH TX STREAM
      output_eth_tx : out std_logic_vector(15 downto 0);
      OUTPUT_ETH_TX_STB : out std_logic;
      OUTPUT_ETH_TX_ACK : in std_logic;

      --SOCKET RX STREAM
      INPUT_SOCKET : in std_logic_vector(15 downto 0);
      INPUT_SOCKET_STB : in std_logic;
      INPUT_SOCKET_ACK : out std_logic;

      --SOCKET TX STREAM
      OUTPUT_SOCKET : out std_logic_vector(15 downto 0);
      OUTPUT_SOCKET_STB : out std_logic;
      OUTPUT_SOCKET_ACK : in std_logic

    );
  end component;

  component USER_DESIGN is
    port(
      CLK : in std_logic;
      RST : in std_logic;
    
      OUTPUT_LEDS : out std_logic_vector(15 downto 0);
      OUTPUT_LEDS_STB : out std_logic;
      OUTPUT_LEDS_ACK : in std_logic;

      INPUT_SWITCHES : in std_logic_vector(15 downto 0);
      INPUT_SWITCHES_STB : in std_logic;
      INPUT_SWITCHES_ACK : out std_logic;

      INPUT_BUTTONS : in std_logic_vector(15 downto 0);
      INPUT_BUTTONS_STB : in std_logic;
      INPUT_BUTTONS_ACK : out std_logic;

      --SOCKET RX STREAM
      INPUT_SOCKET : in std_logic_vector(15 downto 0);
      INPUT_SOCKET_STB : in std_logic;
      INPUT_SOCKET_ACK : out std_logic;

      --SOCKET TX STREAM
      OUTPUT_SOCKET : out std_logic_vector(15 downto 0);
      OUTPUT_SOCKET_STB : out std_logic;
      OUTPUT_SOCKET_ACK : in std_logic;

      --RS232 RX STREAM
      INPUT_RS232_RX : in std_logic_vector(15 downto 0);
      INPUT_RS232_RX_STB : in std_logic;
      INPUT_RS232_RX_ACK : out std_logic;

      --RS232 TX STREAM
      OUTPUT_RS232_TX : out std_logic_vector(15 downto 0);
      OUTPUT_RS232_TX_STB : out std_logic;
      OUTPUT_RS232_TX_ACK : in std_logic


    );
  end component;

  component SERIAL_INPUT is
    generic(
      CLOCK_FREQUENCY : integer;
      BAUD_RATE       : integer
    );
    port(
      CLK      : in std_logic;
      RST      : in std_logic;
      RX       : in std_logic;
     
      OUT1     : out std_logic_vector(7 downto 0);
      OUT1_STB : out std_logic;
      OUT1_ACK : in  std_logic
    );
  end component SERIAL_INPUT;

  component serial_output is
    generic(
      CLOCK_FREQUENCY : integer;
      BAUD_RATE       : integer
    );
    port(
      CLK     : in std_logic;
      RST     : in  std_logic;
      TX      : out std_logic;
     
      IN1     : in std_logic_vector(7 downto 0);
      IN1_STB : in std_logic;
      IN1_ACK : out std_logic
    );
  end component serial_output;

  --chips signals
  signal CLK : std_logic;
  signal RST_INV : std_logic;

  --clock tree signals
  signal clkin1            : std_logic;
  -- Output clock buffering
  signal clkfb             : std_logic;
  signal clk0              : std_logic;
  signal clk2x             : std_logic;
  signal clkfx             : std_logic;
  signal clkfx180          : std_logic;
  signal clkdv             : std_logic;
  signal clkfbout          : std_logic;
  signal locked_internal   : std_logic;
  signal status_internal   : std_logic_vector(7 downto 0);
  signal CLK_OUT1          : std_logic;
  signal CLK_OUT2          : std_logic;
  signal CLK_OUT3          : std_logic;
  signal CLK_OUT3_N        : std_logic;
  signal CLK_OUT4          : std_logic;
  signal NOT_LOCKED        : std_logic;
  signal INTERNAL_RST      : std_logic;
  signal RXD1              : std_logic;
  signal TX_LOCKED         : std_logic;
  signal INTERNAL_RXCLK    : std_logic;
  signal INTERNAL_RXCLK_BUF: std_logic;
  signal RXCLK_BUF         : std_logic;

  signal INTERNAL_TXD      : std_logic_vector(7 downto 0);
  signal INTERNAL_TXEN     : std_logic;      
  signal INTERNAL_TXER     : std_logic;   
  
  signal OUTPUT_LEDS : std_logic_vector(15 downto 0);
  signal OUTPUT_LEDS_STB : std_logic;
  signal OUTPUT_LEDS_ACK : std_logic;

  signal INPUT_SWITCHES : std_logic_vector(15 downto 0);
  signal INPUT_SWITCHES_STB : std_logic;
  signal INPUT_SWITCHES_ACK : std_logic;
  signal GPIO_SWITCHES_D : std_logic_vector(7 downto 0);

  signal INPUT_BUTTONS : std_logic_vector(15 downto 0);
  signal INPUT_BUTTONS_STB : std_logic;
  signal INPUT_BUTTONS_ACK : std_logic;
  signal GPIO_BUTTONS_D : std_logic_vector(3 downto 0);
  
  --ETH RX STREAM
  signal ETH_RX          : std_logic_vector(15 downto 0);
  signal ETH_RX_STB      : std_logic;
  signal ETH_RX_ACK      : std_logic;

  --ETH TX STREAM
  signal ETH_TX          : std_logic_vector(15 downto 0);
  signal ETH_TX_STB      : std_logic;
  signal ETH_TX_ACK      : std_logic;

  --RS232 RX STREAM
  signal INPUT_RS232_RX     : std_logic_vector(15 downto 0);
  signal INPUT_RS232_RX_STB : std_logic;
  signal INPUT_RS232_RX_ACK : std_logic;

  --RS232 TX STREAM
  signal OUTPUT_RS232_TX     : std_logic_vector(15 downto 0);
  signal OUTPUT_RS232_TX_STB      : std_logic;
  signal OUTPUT_RS232_TX_ACK      : std_logic;

  --SOCKET RX STREAM
  signal INPUT_SOCKET          : std_logic_vector(15 downto 0);
  signal INPUT_SOCKET_STB      : std_logic;
  signal INPUT_SOCKET_ACK      : std_logic;

  --SOCKET TX STREAM
  signal OUTPUT_SOCKET          : std_logic_vector(15 downto 0);
  signal OUTPUT_SOCKET_STB      : std_logic;
  signal OUTPUT_SOCKET_ACK      : std_logic;

begin

  gigabit_ethernet_inst_1 : gigabit_ethernet port map(
      CLK         => CLK,
      RST         => INTERNAL_RST,

      --Ethernet Clock
      CLK_125_MHZ => CLK_OUT3,

      --GMII IF
      GTXCLK      => open,
      TXCLK       => TXCLK,
      TXER        => INTERNAL_TXER,
      TXEN        => INTERNAL_TXEN,
      TXD         => INTERNAL_TXD,
      PHY_RESET   => PHY_RESET,
      RXCLK       => INTERNAL_RXCLK,
      RXER        => RXER,
      RXDV        => RXDV,
      RXD         => RXD,

      --RX STREAM
      TX          => ETH_TX,
      TX_STB      => ETH_TX_STB,
      TX_ACK      => ETH_TX_ACK,

      --RX STREAM
      RX          => ETH_RX,
      RX_STB      => ETH_RX_STB,
      RX_ACK      => ETH_RX_ACK
    );

  SERVER_INST_1 : SERVER port map(
      CLK => CLK,
      RST => INTERNAL_RST,
    
      --ETH RX STREAM
      INPUT_ETH_RX => ETH_RX,
      INPUT_ETH_RX_STB => ETH_RX_STB,
      INPUT_ETH_RX_ACK => ETH_RX_ACK,

      --ETH TX STREAM
      OUTPUT_ETH_TX => ETH_TX,
      OUTPUT_ETH_TX_STB => ETH_TX_STB,
      OUTPUT_ETH_TX_ACK => ETH_TX_ACK,

      --SOCKET STREAM
      INPUT_SOCKET => INPUT_SOCKET,
      INPUT_SOCKET_STB => INPUT_SOCKET_STB,
      INPUT_SOCKET_ACK => INPUT_SOCKET_ACK,

      --SOCKET STREAM
      OUTPUT_SOCKET => OUTPUT_SOCKET,
      OUTPUT_SOCKET_STB => OUTPUT_SOCKET_STB,
      OUTPUT_SOCKET_ACK => OUTPUT_SOCKET_ACK

    );

  USER_DESIGN_INST_1 : USER_DESIGN port map(
      CLK => CLK,
      RST => INTERNAL_RST,
    
      OUTPUT_LEDS => OUTPUT_LEDS,
      OUTPUT_LEDS_STB => OUTPUT_LEDS_STB,
      OUTPUT_LEDS_ACK => OUTPUT_LEDS_ACK,

      INPUT_SWITCHES => INPUT_SWITCHES,
      INPUT_SWITCHES_STB => INPUT_SWITCHES_STB,
      INPUT_SWITCHES_ACK => INPUT_SWITCHES_ACK,

      INPUT_BUTTONS => INPUT_BUTTONS,
      INPUT_BUTTONS_STB => INPUT_BUTTONS_STB,
      INPUT_BUTTONS_ACK => INPUT_BUTTONS_ACK,

      --RS232 RX STREAM
      INPUT_RS232_RX => INPUT_RS232_RX,
      INPUT_RS232_RX_STB => INPUT_RS232_RX_STB,
      INPUT_RS232_RX_ACK => INPUT_RS232_RX_ACK,

      --RS232 TX STREAM
      OUTPUT_RS232_TX => OUTPUT_RS232_TX,
      OUTPUT_RS232_TX_STB => OUTPUT_RS232_TX_STB,
      OUTPUT_RS232_TX_ACK => OUTPUT_RS232_TX_ACK,

      --SOCKET STREAM
      INPUT_SOCKET => OUTPUT_SOCKET,
      INPUT_SOCKET_STB => OUTPUT_SOCKET_STB,
      INPUT_SOCKET_ACK => OUTPUT_SOCKET_ACK,

      --SOCKET STREAM
      OUTPUT_SOCKET => INPUT_SOCKET,
      OUTPUT_SOCKET_STB => INPUT_SOCKET_STB,
      OUTPUT_SOCKET_ACK => INPUT_SOCKET_ACK

  );

  SERIAL_OUTPUT_INST_1 : serial_output generic map(
      CLOCK_FREQUENCY => 50000000,
      BAUD_RATE       => 115200
  )port map(
      CLK     => CLK,
      RST     => INTERNAL_RST,
      TX      => RS232_TX,
     
      IN1     => OUTPUT_RS232_TX(7 downto 0),
      IN1_STB => OUTPUT_RS232_TX_STB,
      IN1_ACK => OUTPUT_RS232_TX_ACK
  );

  SERIAL_INPUT_INST_1 : SERIAL_INPUT generic map(
      CLOCK_FREQUENCY => 50000000,
      BAUD_RATE       => 115200
  ) port map (
      CLK      => CLK,
      RST      => INTERNAL_RST,
      RX       => RS232_RX,
     
      OUT1     => INPUT_RS232_RX(7 downto 0),
      OUT1_STB => INPUT_RS232_RX_STB,
      OUT1_ACK => INPUT_RS232_RX_ACK
  );

  INPUT_RS232_RX(15 downto 8) <= (others => '0');

  process
  begin
    wait until rising_edge(CLK);
    NOT_LOCKED <= not LOCKED_INTERNAL;
    INTERNAL_RST <= NOT_LOCKED;
   
    if OUTPUT_LEDS_STB = '1' then
       GPIO_LEDS <= OUTPUT_LEDS(7 downto 0);
    end if;
    OUTPUT_LEDS_ACK <= '1';

    INPUT_SWITCHES_STB <= '1';
    GPIO_SWITCHES_D <= GPIO_SWITCHES;
    INPUT_SWITCHES(7 downto 0) <= GPIO_SWITCHES_D;
    INPUT_SWITCHES(15 downto 8) <= (others => '0');

    INPUT_BUTTONS_STB <= '1';
    GPIO_BUTTONS_D <= GPIO_BUTTONS;
    INPUT_BUTTONS(3 downto 0) <= GPIO_BUTTONS_D;
    INPUT_BUTTONS(15 downto 4) <= (others => '0');

  end process;


  -------------------------
  -- Output     Output     
  -- Clock     Freq (MHz)  
  -------------------------
  -- CLK_OUT1    50.000    
  -- CLK_OUT2   100.000    
  -- CLK_OUT3   125.000    
  -- CLK_OUT4   200.000    

  ----------------------------------
  -- Input Clock   Input Freq (MHz) 
  ----------------------------------
  -- primary         200.000        


  -- Input buffering
  --------------------------------------
  clkin1_buf : IBUFG
  port map
   (O  => clkin1,
    I  => CLK_IN);


  -- Clocking primitive
  --------------------------------------
  -- Instantiation of the DCM primitive
  --    * Unused inputs are tied off
  --    * Unused outputs are labeled unused
  dcm_sp_inst: DCM_SP
  generic map
   (CLKDV_DIVIDE          => 2.000,
    CLKFX_DIVIDE          => 4,
    CLKFX_MULTIPLY        => 5,
    CLKIN_DIVIDE_BY_2     => FALSE,
    CLKIN_PERIOD          => 10.0,
    CLKOUT_PHASE_SHIFT    => "NONE",
    CLK_FEEDBACK          => "1X",
    DESKEW_ADJUST         => "SYSTEM_SYNCHRONOUS",
    PHASE_SHIFT           => 0,
    STARTUP_WAIT          => FALSE)
  port map
   -- Input clock
   (CLKIN                 => clkin1,
    CLKFB                 => clkfb,
    -- Output clocks
    CLK0                  => clk0,
    CLK90                 => open,
    CLK180                => open,
    CLK270                => open,
    CLK2X                 => clk2x,
    CLK2X180              => open,
    CLKFX                 => clkfx,
    CLKFX180              => clkfx180,
    CLKDV                 => clkdv,
   -- Ports for dynamic phase shift
    PSCLK                 => '0',
    PSEN                  => '0',
    PSINCDEC              => '0',
    PSDONE                => open,
   -- Other control and status signals
    LOCKED                => TX_LOCKED,
    STATUS                => status_internal,
    RST                   => RST_INV,
   -- Unused pin, tie low
    DSSEN                 => '0');

  RST_INV <= not RST;



  -- Output buffering
  -------------------------------------
  clkfb <= CLK_OUT2;

  BUFG_INST1 : BUFG
  port map
   (O   => CLK_OUT1,
    I   => clkdv);

  BUFG_INST2 : BUFG
  port map
   (O   => CLK_OUT2,
    I   => clk0);

  BUFG_INST3 : BUFG
  port map
   (O   => CLK_OUT3,
    I   => clkfx);
  
  BUFG_INST4 : BUFG
  port map
   (O   => CLK_OUT3_N,
    I   => clkfx180);

  BUFG_INST5 : BUFG
  port map
   (O   => CLK_OUT4,
    I   => clk2x);
    
  ODDR2_INST1 : ODDR2
  generic map(
    DDR_ALIGNMENT => "NONE", -- Sets output alignment to "NONE", "C0", "C1" 
    INIT => '0',      -- Sets initial state of the Q output to '0' or '1'
    SRTYPE => "SYNC"
  ) port map (
    Q  => GTXCLK,     -- 1-bit output data
    C0 => CLK_OUT3,   -- 1-bit clock input
    C1 => CLK_OUT3_N, -- 1-bit clock input
    CE => '1',        -- 1-bit clock enable input
    D0 => '1',        -- 1-bit data input (associated with C0)
    D1 => '0',        -- 1-bit data input (associated with C1)
    R  => '0',        -- 1-bit reset input
    S  => '0'         -- 1-bit set input
  );

  -- Input buffering
  --------------------------------------
  BUFG_INST6 : IBUFG
  port map
   (O  => RXCLK_BUF,
    I  => RXCLK);

  -- DCM
  --------------------------------------
  dcm_sp_inst2: DCM_SP
  generic map
   (CLKDV_DIVIDE          => 2.000,
    CLKFX_DIVIDE          => 4,
    CLKFX_MULTIPLY        => 5,
    CLKIN_DIVIDE_BY_2     => FALSE,
    CLKIN_PERIOD          => 8.0,
    CLKOUT_PHASE_SHIFT    => "FIXED",
    CLK_FEEDBACK          => "1X",
    DESKEW_ADJUST         => "SYSTEM_SYNCHRONOUS",
    PHASE_SHIFT           => 14,
    STARTUP_WAIT          => FALSE)
  port map
   -- Input clock
   (CLKIN                 => RXCLK_BUF,
    CLKFB                 => INTERNAL_RXCLK,
    -- Output clocks
    CLK0                  => INTERNAL_RXCLK_BUF,
    CLK90                 => open,
    CLK180                => open,
    CLK270                => open,
    CLK2X                 => open,
    CLK2X180              => open,
    CLKFX                 => open,
    CLKFX180              => open,
    CLKDV                 => open,
   -- Ports for dynamic phase shift
    PSCLK                 => '0',
    PSEN                  => '0',
    PSINCDEC              => '0',
    PSDONE                => open,
   -- Other control and status signals
    LOCKED                => open,
    STATUS                => open,
    RST                   => RST_INV,
   -- Unused pin, tie low
    DSSEN                 => '0');

  -- Output buffering
  --------------------------------------
  BUFG_INST7 : BUFG
  port map
   (O  => INTERNAL_RXCLK,
    I  => INTERNAL_RXCLK_BUF);

  LOCKED_INTERNAL <= TX_LOCKED;

  -- Use ODDRs for clock/data forwarding
  --------------------------------------
  ODDR2_INST2_GENERATE : for I in 0 to 7 generate
    ODDR2_INST2 : ODDR2
       generic map(
         DDR_ALIGNMENT => "NONE", -- Sets output alignment to "NONE", "C0", "C1" 
         INIT => '0',      -- Sets initial state of the Q output to '0' or '1'
         SRTYPE => "SYNC"
       ) port map (
         Q  => TXD(I),          -- 1-bit output data
         C0 => CLK_OUT3,        -- 1-bit clock input
         C1 => CLK_OUT3_N,      -- 1-bit clock input
         CE => '1',             -- 1-bit clock enable input
         D0 => INTERNAL_TXD(I), -- 1-bit data input (associated with C0)
         D1 => INTERNAL_TXD(I), -- 1-bit data input (associated with C1)
         R  => '0',             -- 1-bit reset input
         S  => '0'              -- 1-bit set input
       );
  end generate;

  ODDR2_INST3 : ODDR2
  generic map(
    DDR_ALIGNMENT => "NONE", -- Sets output alignment to "NONE", "C0", "C1" 
    INIT => '0',      -- Sets initial state of the Q output to '0' or '1'
    SRTYPE => "SYNC"
  ) port map (
    Q  => TXEN,     -- 1-bit output data
    C0 => CLK_OUT3,   -- 1-bit clock input
    C1 => CLK_OUT3_N, -- 1-bit clock input
    CE => '1',        -- 1-bit clock enable input
    D0 => INTERNAL_TXEN,        -- 1-bit data input (associated with C0)
    D1 => INTERNAL_TXEN,        -- 1-bit data input (associated with C1)
    R  => '0',        -- 1-bit reset input
    S  => '0'         -- 1-bit set input
  );

  ODDR2_INST4 : ODDR2
  generic map(
    DDR_ALIGNMENT => "NONE", -- Sets output alignment to "NONE", "C0", "C1" 
    INIT => '0',      -- Sets initial state of the Q output to '0' or '1'
    SRTYPE => "SYNC"
  ) port map (
    Q  => TXER,     -- 1-bit output data
    C0 => CLK_OUT3,   -- 1-bit clock input
    C1 => CLK_OUT3_N, -- 1-bit clock input
    CE => '1',        -- 1-bit clock enable input
    D0 => INTERNAL_TXER,        -- 1-bit data input (associated with C0)
    D1 => INTERNAL_TXER,        -- 1-bit data input (associated with C1)
    R  => '0',        -- 1-bit reset input
    S  => '0'         -- 1-bit set input
  );
  


  -- Chips CLK frequency selection
  -------------------------------------

  CLK <= CLK_OUT1; --50 MHz
  --CLK <= CLK_OUT2; --100 MHz
  --CLK <= CLK_OUT3; --125 MHz
  --CLK <= CLK_OUT4; --200 MHz

end architecture RTL;
