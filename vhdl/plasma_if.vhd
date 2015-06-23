---------------------------------------------------------------------
-- TITLE: Plamsa Interface (clock divider and interface to FPGA board)
-- AUTHOR: Steve Rhoads (rhoadss@yahoo.com)
-- DATE CREATED: 6/6/02
-- FILENAME: plasma_if.vhd
-- PROJECT: Plasma CPU core
-- COPYRIGHT: Software placed into the public domain by the author.
--    Software 'as is' without warranty.  Author liable for nothing.
-- DESCRIPTION:
--    This entity divides the clock by two and interfaces to the 
--    Altera EP20K200EFC484-2X FPGA board.
--    Xilinx Spartan-3 XC3S200FT256-4 FPGA.
---------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
--use work.mlite_pack.all;

entity plasma_if is
   port(clk_in      : in std_logic;
        reset       : in std_logic;
        uart_read   : in std_logic;
        uart_write  : out std_logic;

        ram_address : out std_logic_vector(31 downto 2);
        ram_data    : inout std_logic_vector(31 downto 0);
        ram_ce1_n   : out std_logic;
        ram_ub1_n   : out std_logic;
        ram_lb1_n   : out std_logic;
        ram_ce2_n   : out std_logic;
        ram_ub2_n   : out std_logic;
        ram_lb2_n   : out std_logic;
        ram_we_n    : out std_logic;
        ram_oe_n    : out std_logic;
         
        gpio0_out   : out std_logic_vector(31 downto 0);
        gpioA_in    : in std_logic_vector(31 downto 0));
end; --entity plasma_if


architecture logic of plasma_if is

   component plasma
      generic(memory_type : string := "XILINX_16X"; --"DUAL_PORT_" "ALTERA_LPM";
              log_file    : string := "UNUSED");
      port(clk               : in std_logic;
           reset             : in std_logic;
           uart_write        : out std_logic;
           uart_read         : in std_logic;
   
           address           : out std_logic_vector(31 downto 2);
           byte_we           : out std_logic_vector(3 downto 0); 
           data_write        : out std_logic_vector(31 downto 0);
           data_read         : in std_logic_vector(31 downto 0);
           mem_pause_in      : in std_logic;
        
           gpio0_out         : out std_logic_vector(31 downto 0);
           gpioA_in          : in std_logic_vector(31 downto 0));
   end component; --plasma

   signal clk_reg      : std_logic;
   signal we_n_next    : std_logic;
   signal we_n_reg     : std_logic;
   signal mem_address  : std_logic_vector(31 downto 2);
   signal data_write   : std_logic_vector(31 downto 0);
   signal data_reg     : std_logic_vector(31 downto 0);
   signal byte_we      : std_logic_vector(3 downto 0);
   signal mem_pause_in : std_logic;

begin  --architecture
   --Divide 50 MHz clock by two
   clk_div: process(reset, clk_in, clk_reg, we_n_next)
   begin
      if reset = '1' then
         clk_reg <= '0';
      elsif rising_edge(clk_in) then
         clk_reg <= not clk_reg;
      end if;

      if reset = '1' then
         we_n_reg <= '1';
         data_reg <= (others => '0');
      elsif falling_edge(clk_in) then
         we_n_reg <= we_n_next or not clk_reg;
         data_reg <= ram_data;
      end if;
   end process; --clk_div

   mem_pause_in <= '0';
   ram_address <= mem_address(31 downto 2);
   ram_we_n <= we_n_reg;

   --For Xilinx Spartan-3 Starter Kit
   ram_control:   
   process(clk_reg, mem_address, byte_we, data_write)
   begin
      if mem_address(30 downto 28) = "001" then  --RAM
         ram_ce1_n <= '0';
         ram_ce2_n <= '0';
         if byte_we = "0000" then      --read
            ram_data  <= (others => 'Z');
            ram_ub1_n <= '0';
            ram_lb1_n <= '0';
            ram_ub2_n <= '0';
            ram_lb2_n <= '0';
            we_n_next <= '1';
            ram_oe_n  <= '0';
         else                                    --write
            if clk_reg = '1' then
               ram_data <= (others => 'Z');
            else
               ram_data <= data_write;
            end if;
            ram_ub1_n <= not byte_we(3);
            ram_lb1_n <= not byte_we(2);
            ram_ub2_n <= not byte_we(1);
            ram_lb2_n <= not byte_we(0);
            we_n_next <= '0';
            ram_oe_n  <= '1';
         end if;
      else
         ram_data <= (others => 'Z');
         ram_ce1_n <= '1';
         ram_ub1_n <= '1';
         ram_lb1_n <= '1';
         ram_ce2_n <= '1';
         ram_ub2_n <= '1';
         ram_lb2_n <= '1';
         we_n_next <= '1';
         ram_oe_n  <= '1';
      end if;
   end process; --ram_control

   u1_plama: plasma 
      generic map (memory_type => "XILINX_16X",
                   log_file    => "UNUSED")
      PORT MAP (
         clk               => clk_reg,
         reset             => reset,
         uart_write        => uart_write,
         uart_read         => uart_read,
 
         address           => mem_address,
         byte_we           => byte_we,
         data_write        => data_write,
         data_read         => data_reg,
         mem_pause_in      => mem_pause_in,
         
         gpio0_out         => gpio0_out,
         gpioA_in          => gpioA_in);
         
end; --architecture logic

