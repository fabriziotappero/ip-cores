--##############################################################################
-- l80soc : light8080 SOC
--##############################################################################
-- v1.0    (27 mar 2012) First release. Jose A. Ruiz.
-- v2.0    (16 apr 2012) Made interface a bit more useable, added comments.
-- 
-- This SoC is meant as an usage example for the light8080 core. The code shows
-- how to interface the core to internal BRAM and other modules.
-- This module is not meant to be used in real applications though it can be
-- used as the starting point for one.
--
-- Please see the comments below for usage instructions.
-- 
-- This file and all the light8080 project files are freeware (See COPYING.TXT)
--##############################################################################

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use work.l80pkg.all;


--##############################################################################
-- Interface pins:
------------------
-- p1in :     Input port P1.
-- p2out :    Output port P2.
-- rxd :      UART RxD pin.
-- txd :      UART TxD pin.
-- extint :   External interrupt inputs, wired straight to the irq controller.
--            EXCEPT for the one used by the UART -- see generic UART_IRQ_LINE.
-- clk :      Master clock, rising edge active.
-- reset :    Synchronous reset, 1 cycle active to reset all SoC.
--
--------------------------------------------------------------------------------
-- Generics:
------------
-- OBJ_CODE (mandatory, no default value):  
-- Table that will be used to initialize internal BRAM, starting at address 0.
--
-- DEFAULT_RAM_SIZE (default = 0):
-- Internal RAM size. If set to zero, the RAM size will be determined from the 
-- size of OBJ_CODE as the smallest power of 2 larger than OBJ_CODE'length.
--
-- UART_IRQ_LINE (defaults to 4):
-- Index of the irq controller input the internal UART is wired to, or >3 to 
-- leave the UART unconnected to the IRQ controller.
-- The irq controller input used for the uart will be unconnected to the SoC
-- input port.
--
-- UART_HARDWIRED (defaults to true):
-- True when the UART baud rate is hardwired. the baud rate registers will be
-- 
-- BAUD_RATE (defaults to 19200):
-- UART default baud rate. When th UART is hardwired, the baud rate can't be
-- changed at run time. 
-- Note that you have to set generic z. This value is needed to compute the 
-- UART baud rate constants.
--
--------------------------------------------------------------------------------
-- I/O port map:
----------------
--
-- 080h..083h     UART registers.
-- 084h           P1 input port (read only, writes are ignored).
-- 086h           P2 output port (write only, reads undefined data).
-- 088h           IRQ enable register.
--
-- Please see the comments in the source of the relevant modules for a more
-- detailed explanation of their behavior.
--
-- All i/o  ports other than the above read as 00h.
--------------------------------------------------------------------------------
-- Notes:
---------
-- -# If you do not set a default memory size, you then have to take care to 
--    control the size of the object code table.
-- -# If you do set the default memory size, the code will not warn you if the
--    object code does not fit inside, it will silentl truncate it.
-- -# The internal memory block is mirrored over the entire address map. 
-- -# There is no write protection to any address range: you can overwrite the 
--    program. If you do that there's no way to recover it but reloading the 
--    FPGA, a reset will not do.
--##############################################################################
entity l80soc is
    generic (
      OBJ_CODE      : obj_code_t;       -- RAM initialization constant 
      DEFAULT_RAM_SIZE: integer := 0;   -- RAM size or 0 to stretch
      UART_IRQ_LINE : integer := 4;     -- [0..3] or >3 for none
      UART_HARDWIRED: boolean := true;  -- UART baud rate is hardwired
      BAUD_RATE     : integer := 19200; -- UART (default) baud rate
      CLOCK_FREQ    : integer := 50E6   -- Clock frequency in Hz
    );
    port (  
      p1in :          in std_logic_vector(7 downto 0);
      p2out :         out std_logic_vector(7 downto 0);
            
      rxd :           in std_logic;
      txd :           out std_logic;

      extint :        in std_logic_vector(3 downto 0);   

      clk :           in std_logic;
      reset :         in std_logic 
    );
end l80soc;

--##############################################################################
--
--##############################################################################

architecture hardwired of l80soc is

-- Helper functions ------------------------------------------------------------


-- soc_ram_size: compute size of internal RAM 
-- If default_size is /= 0, the size is the default. If it is zero, then the
-- size the smallest power of 2 larger than obj_code_size.
function soc_ram_size(default_size, obj_code_size: integer) return integer is
begin
  if default_size=0 then
    -- Default is zero: use a RAM as big as necessary for the obj code table
    -- rounding to the neares power of 2.
    return 2**log2(obj_code_size);
  else
    -- Default is not zero: use the default and do NOT check to see if the 
    -- object code fits.
    return default_size;
  end if;
end function soc_ram_size;

-- Custom types ----------------------------------------------------------------

subtype t_byte is std_logic_vector(7 downto 0);

-- CPU signals -----------------------------------------------------------------

signal cpu_vma :      std_logic;
signal cpu_rd :       std_logic;
signal cpu_wr :       std_logic;
signal cpu_io :       std_logic;
signal cpu_fetch :    std_logic;
signal cpu_addr :     std_logic_vector(15 downto 0);
signal cpu_data_i :   std_logic_vector(7 downto 0);
signal cpu_data_o :   std_logic_vector(7 downto 0);
signal cpu_intr :     std_logic;
signal cpu_inte :     std_logic;
signal cpu_inta :     std_logic;
signal cpu_halt :     std_logic;


-- Aux CPU signals -------------------------------------------------------------

-- io_wr: asserted in IO write cycles
signal io_wr :        std_logic;
-- io_rd: asserted in IO read cycles
signal io_rd :        std_logic;
-- io_addr: IO port address, lowest 8 bits of address bus
signal io_addr :      std_logic_vector(7 downto 0);
-- io_rd_data: data coming from IO ports (io input mux)
signal io_rd_data :   std_logic_vector(7 downto 0);
-- cpu_io_reg: registered cpu_io, used to control mux after cpu_io deasserts
signal cpu_io_reg :   std_logic;

-- UART ------------------------------------------------------------------------

signal uart_ce :      std_logic;
signal uart_data_rd : std_logic_vector(7 downto 0);
signal uart_irq :     std_logic;


-- RAM -------------------------------------------------------------------------

constant RAM_SIZE : integer := soc_ram_size(DEFAULT_RAM_SIZE,OBJ_CODE'length);
constant RAM_ADDR_SIZE : integer := log2(RAM_SIZE);

signal ram_rd_data :  std_logic_vector(7 downto 0);
signal ram_we :       std_logic;

signal ram :      ram_t(0 to RAM_SIZE-1) := objcode_to_bram(OBJ_CODE, RAM_SIZE);
signal ram_addr :     std_logic_vector(RAM_ADDR_SIZE-1 downto 0);

-- IRQ controller interface ----------------------------------------------------

signal irqcon_we :    std_logic;
signal irqcon_data_rd: std_logic_vector(7 downto 0);
signal irq :          std_logic_vector(3 downto 0);


-- IO ports addresses ----------------------------------------------------------

subtype io_addr_t is std_logic_vector(7 downto 0);

constant ADDR_UART_0 : io_addr_t  := X"80"; -- UART registers (80h..83h)
constant ADDR_UART_1 : io_addr_t  := X"81"; -- UART registers (80h..83h)
constant ADDR_UART_2 : io_addr_t  := X"82"; -- UART registers (80h..83h)
constant ADDR_UART_3 : io_addr_t  := X"83"; -- UART registers (80h..83h)
constant P1_DATA_REG : io_addr_t  := X"84"; -- port 1 data register 
constant P2_DATA_REG : io_addr_t  := X"86"; -- port 2 data register 
constant INTR_EN_REG : io_addr_t  := X"88"; -- interrupts enable register 


begin


  cpu: entity work.light8080 
  port map (
    clk =>      clk,
    reset =>    reset,
    vma =>      cpu_vma,
    rd =>       cpu_rd,
    wr =>       cpu_wr,
    io =>       cpu_io,
    fetch =>    cpu_fetch,
    addr_out => cpu_addr, 
    data_in =>  cpu_data_i,
    data_out => cpu_data_o,
    
    intr =>     cpu_intr,
    inte =>     cpu_inte,
    inta =>     cpu_inta,
    halt =>     cpu_halt
  );

  io_rd <= cpu_io and cpu_rd;
  io_wr <= '1' when cpu_io='1' and cpu_wr='1' else '0';
  io_addr <= cpu_addr(7 downto 0);
  
  -- Register some control signals that are needed to control multiplexors the
  -- cycle after the control signal asserts -- e.g. cpu_io.
  control_signal_registers:
  process(clk)
  begin
    if clk'event and clk='1' then
      cpu_io_reg <= cpu_io;
    end if;
  end process control_signal_registers;
  
  -- Input data mux -- remember, no 3-state buses within the FPGA --------------
  cpu_data_i <= 
      irqcon_data_rd    when cpu_inta = '1' else
      io_rd_data        when cpu_io_reg = '1' else 
      ram_rd_data;
  
  
  -- BRAM ----------------------------------------------------------------------
  
  ram_we <= '1' when cpu_io='0' and cpu_wr='1' else '0';
  ram_addr <= cpu_addr(RAM_ADDR_SIZE-1 downto 0);
  
  memory:
  process(clk)
  begin
    if clk'event and clk='1' then
      if ram_we = '1' then
        ram(conv_integer(ram_addr)) <= cpu_data_o;
      end if;
      ram_rd_data <= ram(conv_integer(ram_addr));
    end if;
  end process memory;
  
  
  -- Interrupt controller ------------------------------------------------------
  -- FIXME interrupts unused in this version
  
  irq_control: entity work.l80irq
  port map (
    clk =>          clk,
    reset =>        reset,
    
    irq_i =>        irq,
    
    data_i =>       cpu_data_o,
    data_o =>       irqcon_data_rd,
    addr_i =>       cpu_addr(0),
    data_we_i =>    irqcon_we,
    
    cpu_inta_i =>   cpu_inta,
    cpu_intr_o =>   cpu_intr,
    cpu_fetch_i =>  cpu_fetch
  );  
  
  irq_line_connections:
  for i in 0 to 3 generate
  begin
    uart_irq_connection:
    if i = UART_IRQ_LINE generate
    begin
      irq(i) <= uart_irq;
    end generate;
    other_irq_connections:
    if i /= UART_IRQ_LINE generate
      irq(i) <= extint(i);
    end generate;
  end generate irq_line_connections;
  
  irqcon_we <= '1' when io_addr=INTR_EN_REG and io_wr='1' else '0';

  -- UART -- simple UART with hardwired baud rate ------------------------------
  -- NOTE: the serial port does NOT have interrupt capability (yet)
  
  uart : entity work.uart
  generic map (
    BAUD_RATE =>      BAUD_RATE,
    CLOCK_FREQ =>     CLOCK_FREQ
  )
  port map (
    clk_i =>          clk,
    reset_i =>        reset,
    
    irq_o =>          uart_irq,
    data_i =>         cpu_data_o,
    data_o =>         uart_data_rd,
    addr_i =>         cpu_addr(1 downto 0),
    
    ce_i =>           uart_ce,
    wr_i =>           io_wr,
    rd_i =>           io_rd,
    
    rxd_i =>          rxd,
    txd_o =>          txd
  );
  
  -- UART write enable
  uart_ce <= '1' when 
        io_addr(7 downto 2) = ADDR_UART_0(7 downto 2)
        else '0';
  
  -- IO ports -- Simple IO ports with hardcoded direction ----------------------
  -- These are meant as an usage example mostly
  
  output_ports:
  process(clk)
  begin
    if clk'event and clk='1' then
      if reset = '1' then 
        -- Reset values for all io ports
        p2out <= (others => '0');
      else
        if io_wr = '1' then
          if conv_integer(io_addr) = P2_DATA_REG then
            p2out <= cpu_data_o;
          end if;
        end if;
      end if;
    end if;
  end process output_ports;
  
  -- Input IO data multiplexor
  with io_addr select io_rd_data <= 
    p1in            when P1_DATA_REG,
    uart_data_rd    when ADDR_UART_0,
    uart_data_rd    when ADDR_UART_1,
    uart_data_rd    when ADDR_UART_2,
    uart_data_rd    when ADDR_UART_3,
    irqcon_data_rd  when INTR_EN_REG,
    X"00"           when others;
  

end hardwired;

