-- <File header>
-- Project
--    pAVR (pipelined AVR) is an 8 bit RISC controller, compatible with Atmel's
--    AVR core, but about 3x faster in terms of both clock frequency and MIPS.
--    The increase in speed comes from a relatively deep pipeline. The original
--    AVR core has only two pipeline stages (fetch and execute), while pAVR has
--    6 pipeline stages:
--       1. PM    (read Program Memory)
--       2. INSTR (load Instruction)
--       3. RFRD  (decode Instruction and read Register File)
--       4. OPS   (load Operands)
--       5. ALU   (execute ALU opcode or access Unified Memory)
--       6. RFWR  (write Register File)
-- Version
--    0.32
-- Date
--    2002 August 07
-- Author
--    Doru Cuturela, doruu@yahoo.com
-- License
--    This program is free software; you can redistribute it and/or modify
--    it under the terms of the GNU General Public License as published by
--    the Free Software Foundation; either version 2 of the License, or
--    (at your option) any later version.
--    This program is distributed in the hope that it will be useful,
--    but WITHOUT ANY WARRANTY; without even the implied warranty of
--    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--    GNU General Public License for more details.
--    You should have received a copy of the GNU General Public License
--    along with this program; if not, write to the Free Software
--    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
-- </File header>



-- <File info>
-- This tests pAVR's IO File.
-- The following tests are performed on the IOF:
--    - test the IOF general write/read/bit processing port.
--       Test all opcodes that this port is capable of:
--       - wrbyte
--       - rdbyte
--       - clrbit
--       - setbit
--       - stbit
--       - ldbit
--    - test the IOF port A.
--       Port A is intended to offer to pAVR pin-level IO connectivity with the
--       outside world.
--       Test that Port A pins correctly take the appropriate logic values
--       (high, low, high Z or weak high).
--    - test Timer 0.
--       - test Timer 0 prescaler.
--       - test Timer 0 overflow.
--       - test Timer 0 interrupt.
--    - test External Interrupt 0.
--       External Interrupt 0 is mapped on port A pin 0.
--       Test if each possible configuration (activation on low level, rising edge
--       or falling edge) correctly triggers External Interrupt 0.
-- </File info>



-- <File body>
library ieee;
use ieee.std_logic_1164.all;
library work;
use work.std_util.all;
use work.pavr_util.all;
use work.pavr_constants.all;



entity test_pavr_iof is
end;



architecture test_pavr_iof_arch of test_pavr_iof is
   signal clk, res, syncres: std_logic;

   -- Clock counter
   signal cnt: std_logic_vector(20 downto 0);

   -- IOF general read and write port
   signal pavr_iof_opcode  : std_logic_vector(pavr_iof_opcode_w - 1 downto 0);
   signal pavr_iof_addr    : std_logic_vector(5 downto 0);
   signal pavr_iof_di      : std_logic_vector(7 downto 0);
   signal pavr_iof_do      : std_logic_vector(7 downto 0);
   signal pavr_iof_bitaddr : std_logic_vector(2 downto 0);
   signal pavr_iof_bitout  : std_logic;

   -- SREG port
   signal pavr_iof_sreg    : std_logic_vector(7 downto 0);
   signal pavr_iof_sreg_wr : std_logic;
   signal pavr_iof_sreg_di : std_logic_vector(7 downto 0);

   -- SP port
   signal pavr_iof_spl     : std_logic_vector(7 downto 0);
   signal pavr_iof_spl_wr  : std_logic;
   signal pavr_iof_spl_di  : std_logic_vector(7 downto 0);

   signal pavr_iof_sph     : std_logic_vector(7 downto 0);
   signal pavr_iof_sph_wr  : std_logic;
   signal pavr_iof_sph_di  : std_logic_vector(7 downto 0);

   -- RAMPX port
   signal pavr_iof_rampx      : std_logic_vector(7 downto 0);
   signal pavr_iof_rampx_wr   : std_logic;
   signal pavr_iof_rampx_di   : std_logic_vector(7 downto 0);

   -- RAMPY port
   signal pavr_iof_rampy      : std_logic_vector(7 downto 0);
   signal pavr_iof_rampy_wr   : std_logic;
   signal pavr_iof_rampy_di   : std_logic_vector(7 downto 0);

   -- RAMPZ port
   signal pavr_iof_rampz      : std_logic_vector(7 downto 0);
   signal pavr_iof_rampz_wr   : std_logic;
   signal pavr_iof_rampz_di   : std_logic_vector(7 downto 0);

   -- RAMPD port
   signal pavr_iof_rampd      : std_logic_vector(7 downto 0);
   signal pavr_iof_rampd_wr   : std_logic;
   signal pavr_iof_rampd_di   : std_logic_vector(7 downto 0);

   -- EIND port
   signal pavr_iof_eind       : std_logic_vector(7 downto 0);
   signal pavr_iof_eind_wr    : std_logic;
   signal pavr_iof_eind_di    : std_logic_vector(7 downto 0);

   -- Port A
   signal pavr_iof_pa         : std_logic_vector(7 downto 0);

   -- Interrupt-related interface signals to control module (to the pipeline).
   signal pavr_disable_int    : std_logic;
   signal pavr_int_rq         : std_logic;
   signal pavr_int_vec        : std_logic_vector(21 downto 0);

   -- Declare the IO File.
   component pavr_iof
   port(
      pavr_iof_clk      : in std_logic;
      pavr_iof_res      : in std_logic;
      pavr_iof_syncres  : in std_logic;

      -- General IO file port
      pavr_iof_opcode   : in  std_logic_vector(pavr_iof_opcode_w - 1 downto 0);
      pavr_iof_addr     : in  std_logic_vector(5 downto 0);
      pavr_iof_di       : in  std_logic_vector(7 downto 0);
      pavr_iof_do       : out std_logic_vector(7 downto 0);
      pavr_iof_bitout   : out std_logic;
      pavr_iof_bitaddr  : in  std_logic_vector(2 downto 0);

      -- AVR kernel register ports
      -- Status register (SREG)
      pavr_iof_sreg     : out std_logic_vector(7 downto 0);
      pavr_iof_sreg_wr  : in  std_logic;
      pavr_iof_sreg_di  : in  std_logic_vector(7 downto 0);

      -- Stack pointer (SP = SPH&SPL)
      pavr_iof_sph      : out std_logic_vector(7 downto 0);
      pavr_iof_sph_wr   : in  std_logic;
      pavr_iof_sph_di   : in  std_logic_vector(7 downto 0);
      pavr_iof_spl      : out std_logic_vector(7 downto 0);
      pavr_iof_spl_wr   : in  std_logic;
      pavr_iof_spl_di   : in  std_logic_vector(7 downto 0);

      -- Pointer registers extensions (RAMPX, RAMPY, RAMPZ)
      pavr_iof_rampx    : out std_logic_vector(7 downto 0);
      pavr_iof_rampx_wr : in  std_logic;
      pavr_iof_rampx_di : in  std_logic_vector(7 downto 0);

      pavr_iof_rampy    : out std_logic_vector(7 downto 0);
      pavr_iof_rampy_wr : in  std_logic;
      pavr_iof_rampy_di : in  std_logic_vector(7 downto 0);

      pavr_iof_rampz    : out std_logic_vector(7 downto 0);
      pavr_iof_rampz_wr : in  std_logic;
      pavr_iof_rampz_di : in  std_logic_vector(7 downto 0);

      -- Data Memory extension address register (RAMPD)
      pavr_iof_rampd    : out std_logic_vector(7 downto 0);
      pavr_iof_rampd_wr : in  std_logic;
      pavr_iof_rampd_di : in  std_logic_vector(7 downto 0);

      -- Program Memory extension address register (EIND)
      pavr_iof_eind     : out std_logic_vector(7 downto 0);
      pavr_iof_eind_wr  : in  std_logic;
      pavr_iof_eind_di  : in  std_logic_vector(7 downto 0);

      -- AVR non-kernel (feature) register ports
      -- Port A
      pavr_iof_pa : inout std_logic_vector(7 downto 0);

      -- Interrupt-related interface signals to control module (to the pipeline).
      pavr_disable_int  : in  std_logic;
      pavr_int_rq       : out std_logic;
      pavr_int_vec      : out std_logic_vector(21 downto 0)
   );
   end component;
   for all: pavr_iof use entity work.pavr_iof(pavr_iof_arch);

begin

   -- Instantiate the IO File.
   pavr_iof_instance1: pavr_iof
   port map(
      clk,
      res,
      syncres,

      -- General IO file port
      pavr_iof_opcode,
      pavr_iof_addr,
      pavr_iof_di,
      pavr_iof_do,
      pavr_iof_bitout,
      pavr_iof_bitaddr,

      -- AVR kernel register ports
      -- Status register (SREG)
      pavr_iof_sreg,
      pavr_iof_sreg_wr,
      pavr_iof_sreg_di,

      -- Stack pointer (SP = SPH&SPL)
      pavr_iof_sph,
      pavr_iof_sph_wr,
      pavr_iof_sph_di,
      pavr_iof_spl,
      pavr_iof_spl_wr,
      pavr_iof_spl_di,

      -- Pointer registers extensions (RAMPX, RAMPY, RAMPZ)
      pavr_iof_rampx,
      pavr_iof_rampx_wr,
      pavr_iof_rampx_di,

      pavr_iof_rampy,
      pavr_iof_rampy_wr,
      pavr_iof_rampy_di,

      pavr_iof_rampz,
      pavr_iof_rampz_wr,
      pavr_iof_rampz_di,

      -- Data Memory extension address register (RAMPD)
      pavr_iof_rampd,
      pavr_iof_rampd_wr,
      pavr_iof_rampd_di,

      -- Program Memory extension address register (EIND)
      pavr_iof_eind,
      pavr_iof_eind_wr,
      pavr_iof_eind_di,

      -- AVR non-kernel (feature) register ports
      -- Port A
      pavr_iof_pa,

      -- Interrupt-related interface signals to control module (to the pipeline).
      pavr_disable_int,
      pavr_int_rq,
      pavr_int_vec
   );


   generate_clock:
   process
   begin
      clk <= '1';
      wait for 50 ns;
      clk <= '0';
      wait for 50 ns;
   end process generate_clock;


   generate_reset:
   process
   begin
      res <= '0';
      wait for 100 ns;
      res <= '1';
      wait for 110 ns;
      res <= '0';
      wait for 1 ms;
   end process generate_reset;


   generate_sync_reset:
   process
   begin
      syncres <= '0';
      wait for 300 ns;
      syncres <= '1';
      wait for 110 ns;
      syncres <= '0';
      wait for 1 ms;
   end process generate_sync_reset;


   test_main:
   process(clk, res, syncres,
           cnt,
           pavr_iof_opcode, pavr_iof_addr, pavr_iof_di, pavr_iof_bitaddr,
           pavr_iof_sreg_di,
           pavr_iof_spl_di,
           pavr_iof_sph_di,
           pavr_iof_rampx_di,
           pavr_iof_rampy_di,
           pavr_iof_rampz_di,
           pavr_iof_rampd_di,
           pavr_iof_eind_di,

           pavr_iof_rampy
          )
   begin
      if res='1' then
         -- Async reset
         -- The IO File should take care of reseting its registers. Check this.
         cnt <= int_to_std_logic_vector(0, cnt'length);
      elsif clk'event and clk='1' then
         -- Clock counter
         cnt <= cnt+1;

         -- Initialize inputs.
         pavr_iof_opcode      <= int_to_std_logic_vector(0, pavr_iof_opcode'length);
         pavr_iof_addr        <= int_to_std_logic_vector(0, pavr_iof_addr'length);
         pavr_iof_di          <= int_to_std_logic_vector(0, pavr_iof_di'length);
         pavr_iof_bitaddr     <= int_to_std_logic_vector(0, pavr_iof_bitaddr'length);

         pavr_iof_sreg_wr     <= '0';
         pavr_iof_sreg_di     <= int_to_std_logic_vector(0, pavr_iof_sreg_di'length);

         pavr_iof_spl_wr      <= '0';
         pavr_iof_spl_di      <= int_to_std_logic_vector(0, pavr_iof_spl_di'length);

         pavr_iof_sph_wr      <= '0';
         pavr_iof_sph_di      <= int_to_std_logic_vector(0, pavr_iof_sph_di'length);

         pavr_iof_rampx_wr    <= '0';
         pavr_iof_rampx_di    <= int_to_std_logic_vector(0, pavr_iof_rampx_di'length);

         pavr_iof_rampy_wr    <= '0';
         pavr_iof_rampy_di    <= int_to_std_logic_vector(0, pavr_iof_rampy_di'length);

         pavr_iof_rampz_wr    <= '0';
         pavr_iof_rampz_di    <= int_to_std_logic_vector(0, pavr_iof_rampz_di'length);

         pavr_iof_rampd_wr    <= '0';
         pavr_iof_rampd_di    <= int_to_std_logic_vector(0, pavr_iof_rampd_di'length);

         pavr_iof_eind_wr     <= '0';
         pavr_iof_eind_di     <= int_to_std_logic_vector(0, pavr_iof_eind_di'length);

         pavr_disable_int     <= '0';

         case std_logic_vector_to_nat(cnt) is
            -- TEST 1. Test IO general port.
            -- IOF opcode = wrbyte. Write RAMPY.
            when 3 =>
               pavr_iof_opcode   <= pavr_iof_opcode_wrbyte;
               pavr_iof_addr     <= int_to_std_logic_vector(pavr_rampy_addr, pavr_iof_addr'length);
               pavr_iof_di       <= int_to_std_logic_vector(16#C5#, pavr_iof_di'length);
            -- IOF opcode = rdbyte. Read RAMPY.
            when 4 =>
               pavr_iof_opcode   <= pavr_iof_opcode_rdbyte;
               pavr_iof_addr     <= int_to_std_logic_vector(pavr_rampy_addr, pavr_iof_addr'length);
            -- IOF opcode = clrbit. Clear bit 2 of RAMPY.
            when 5 =>
               pavr_iof_opcode   <= pavr_iof_opcode_clrbit;
               pavr_iof_addr     <= int_to_std_logic_vector(pavr_rampy_addr, pavr_iof_addr'length);
               pavr_iof_di       <= pavr_iof_rampy;
               pavr_iof_bitaddr  <= int_to_std_logic_vector(2, pavr_iof_bitaddr'length);
            -- IOF opcode = setbit. Set bit 3 of RAMPY.
            when 6 =>
               pavr_iof_opcode   <= pavr_iof_opcode_setbit;
               pavr_iof_addr     <= int_to_std_logic_vector(pavr_rampy_addr, pavr_iof_addr'length);
               pavr_iof_di       <= pavr_iof_rampy;
               pavr_iof_bitaddr  <= int_to_std_logic_vector(3, pavr_iof_bitaddr'length);
            -- IOF opcode = stbit. Store bit 4 of input into T flag.
            when 7 =>
               pavr_iof_opcode   <= pavr_iof_opcode_stbit;
               pavr_iof_di       <= int_to_std_logic_vector(16#93#, pavr_iof_di'length);
               pavr_iof_bitaddr  <= int_to_std_logic_vector(4, pavr_iof_bitaddr'length);
            -- IOF opcode = ldbit. Load T flag into bit 5 of output.
            when 8 =>
               pavr_iof_opcode   <= pavr_iof_opcode_ldbit;
               pavr_iof_di       <= int_to_std_logic_vector(16#93#, pavr_iof_di'length);
               pavr_iof_bitaddr  <= int_to_std_logic_vector(5, pavr_iof_bitaddr'length);


            -- TEST 2. Write some of the IOF registers that have dedicated write
            --    ports.
            when 9 =>
               pavr_iof_sph_wr   <= '1';
               pavr_iof_sph_di   <= int_to_std_logic_vector(16#5E#, 8);
               pavr_iof_eind_wr  <= '1';
               pavr_iof_eind_di  <= int_to_std_logic_vector(16#A2#, 8);


            -- TEST 3. Test Port A.
            -- The idea is:
            --    - 1. set some bits in PORTA
            --    - 2. set some bits in DDRA
            --    Now check the output pins PA to see which is Hi Z input, weakly
            --       pulled hi input, or output low/hi.
            --    - 3. read PINA and see if IOF data out gets all those HiZ/H/0/1
            --       lines.
            -- Write PORTA.
            when 20 =>
               pavr_iof_opcode   <= pavr_iof_opcode_wrbyte;
               pavr_iof_addr     <= int_to_std_logic_vector(pavr_porta_addr, pavr_iof_addr'length);
               pavr_iof_di       <= int_to_std_logic_vector(16#0F#, pavr_iof_di'length);
               -- Set port pins into Hi Z (nobody sources or sink into/from them
               --    from outside). Note that a 3 state latch is generated.
               pavr_iof_pa <= "ZZZZZZZZ";
            -- Write DDRA.
            when 21 =>
               pavr_iof_opcode   <= pavr_iof_opcode_wrbyte;
               pavr_iof_addr     <= int_to_std_logic_vector(pavr_ddra_addr, pavr_iof_addr'length);
               pavr_iof_di       <= int_to_std_logic_vector(16#33#, pavr_iof_di'length);
            -- Read PINA.
            when 22 =>
               pavr_iof_opcode   <= pavr_iof_opcode_rdbyte;
               pavr_iof_addr     <= int_to_std_logic_vector(pavr_pina_addr, pavr_iof_addr'length);
            -- Now clear the Port A mess for next tests (remember that PA also has
            --    alternate functions: int 0 and timer 0, that will be tested
            --    below). Thus, set PA as Hi Z input (DDRA=0 and PORTA=0).
            when 23 =>
               pavr_iof_opcode   <= pavr_iof_opcode_wrbyte;
               pavr_iof_addr     <= int_to_std_logic_vector(pavr_ddra_addr, pavr_iof_addr'length);
               pavr_iof_di       <= int_to_std_logic_vector(16#00#, pavr_iof_di'length);
               pavr_iof_pa <= "ZZZZZZZZ";
            when 24 =>
               pavr_iof_opcode   <= pavr_iof_opcode_wrbyte;
               pavr_iof_addr     <= int_to_std_logic_vector(pavr_porta_addr, pavr_iof_addr'length);
               pavr_iof_di       <= int_to_std_logic_vector(16#00#, pavr_iof_di'length);


            -- TEST 4. Test timer 0 prescaler options.
            -- Timer 0 clock = main clock.
            when 30 =>
               pavr_iof_opcode   <= pavr_iof_opcode_wrbyte;
               pavr_iof_addr     <= int_to_std_logic_vector(pavr_tccr0_addr, pavr_iof_addr'length);
               pavr_iof_di       <= int_to_std_logic_vector(16#01#, pavr_iof_di'length);
            -- Timer 0 clock = main clock / 8.
            when 40 =>
               pavr_iof_opcode   <= pavr_iof_opcode_wrbyte;
               pavr_iof_addr     <= int_to_std_logic_vector(pavr_tccr0_addr, pavr_iof_addr'length);
               pavr_iof_di       <= int_to_std_logic_vector(16#02#, pavr_iof_di'length);
            -- Timer 0 clock = main clock / 64.
            when 100 =>
               pavr_iof_opcode   <= pavr_iof_opcode_wrbyte;
               pavr_iof_addr     <= int_to_std_logic_vector(pavr_tccr0_addr, pavr_iof_addr'length);
               pavr_iof_di       <= int_to_std_logic_vector(16#03#, pavr_iof_di'length);
            -- Timer 0 clock = main clock / 256.
            when 250 =>
               pavr_iof_opcode   <= pavr_iof_opcode_wrbyte;
               pavr_iof_addr     <= int_to_std_logic_vector(pavr_tccr0_addr, pavr_iof_addr'length);
               pavr_iof_di       <= int_to_std_logic_vector(16#04#, pavr_iof_di'length);
            -- Timer 0 clock = main clock / 1024.
            when 1000 =>
               pavr_iof_opcode   <= pavr_iof_opcode_wrbyte;
               pavr_iof_addr     <= int_to_std_logic_vector(pavr_tccr0_addr, pavr_iof_addr'length);
               pavr_iof_di       <= int_to_std_logic_vector(16#05#, pavr_iof_di'length);
            -- Timer 0 clock = dedicated external input PINA(1), negative edge.
            when 5000 =>
               pavr_iof_opcode   <= pavr_iof_opcode_wrbyte;
               pavr_iof_addr     <= int_to_std_logic_vector(pavr_tccr0_addr, pavr_iof_addr'length);
               pavr_iof_di       <= int_to_std_logic_vector(16#06#, pavr_iof_di'length);
               pavr_iof_pa(1) <= '0';
            when 5001 | 5002 =>
               pavr_iof_pa(1) <= '0';
            when 5003 | 5004 =>
               pavr_iof_pa(1) <= '1';
            when 5005 | 5006 | 5007 =>
               pavr_iof_pa(1) <= '0';
            when 5008 | 5009 =>
               pavr_iof_pa(1) <= '1';
            when 5010 | 5011 | 5012 =>
               pavr_iof_pa(1) <= '0';
            when 5013 | 5014 | 5015 | 5016 | 5017 | 5018 | 5019 =>
               pavr_iof_pa(1) <= '1';
            when 5020 =>
               pavr_iof_pa(1) <= '0';
            -- Timer 0 clock = dedicated external input PINA(1), positive edge.
            when 5030 =>
               pavr_iof_opcode   <= pavr_iof_opcode_wrbyte;
               pavr_iof_addr     <= int_to_std_logic_vector(pavr_tccr0_addr, pavr_iof_addr'length);
               pavr_iof_di       <= int_to_std_logic_vector(16#07#, pavr_iof_di'length);
            when 5031 | 5032 =>
               pavr_iof_pa(1) <= '0';
            when 5033 | 5034 =>
               pavr_iof_pa(1) <= '1';
            when 5035 | 5036 | 5037 =>
               pavr_iof_pa(1) <= '0';
            when 5038 | 5039 =>
               pavr_iof_pa(1) <= '1';
            when 5040 | 5041 | 5042 =>
               pavr_iof_pa(1) <= '0';
            when 5043 | 5044 | 5045 | 5046 | 5047 | 5048 | 5049 =>
               pavr_iof_pa(1) <= '1';
            when 5050 =>
               pavr_iof_pa(1) <= '0';


            -- TEST 5. Test timer 0 overflow.
            -- Check if timer 0 overflows and if the overflow event is captured in
            --    TIFR(1). Set timer 0 clock to main clock, to count faster.
            when 5100 =>
               pavr_iof_opcode   <= pavr_iof_opcode_wrbyte;
               pavr_iof_addr     <= int_to_std_logic_vector(pavr_tccr0_addr, pavr_iof_addr'length);
               pavr_iof_di       <= int_to_std_logic_vector(16#01#, pavr_iof_di'length);


            -- TEST 6. Test timer 0 overflow interrupt.
            -- Enable interrupts globally, by setting set SREG(7).
            when 5500 =>
               pavr_iof_opcode   <= pavr_iof_opcode_wrbyte;
               pavr_iof_addr     <= int_to_std_logic_vector(pavr_sreg_addr, pavr_iof_addr'length);
               pavr_iof_di       <= int_to_std_logic_vector(16#80#, pavr_iof_di'length);
            -- Enable timer 0 overflow interrupt, by setting TIMSK(1).
            when 5501 =>
               pavr_iof_opcode   <= pavr_iof_opcode_wrbyte;
               pavr_iof_addr     <= int_to_std_logic_vector(pavr_timsk_addr, pavr_iof_addr'length);
               pavr_iof_di       <= int_to_std_logic_vector(16#02#, pavr_iof_di'length);
            -- Set timer 0 clock to system clock (highest speed).
            when 5502 =>
               pavr_iof_opcode   <= pavr_iof_opcode_wrbyte;
               pavr_iof_addr     <= int_to_std_logic_vector(pavr_tccr0_addr, pavr_iof_addr'length);
               pavr_iof_di       <= int_to_std_logic_vector(16#01#, pavr_iof_di'length);
            -- Disable timer 0 overflow interrupt, to keep the timer 0 `quiet'
            --    during next tests.
            when 5503 =>
               pavr_iof_opcode   <= pavr_iof_opcode_wrbyte;
               pavr_iof_addr     <= int_to_std_logic_vector(pavr_timsk_addr, pavr_iof_addr'length);
               pavr_iof_di       <= int_to_std_logic_vector(16#00#, pavr_iof_di'length);


            -- TEST 7. Test external interrupt 0.
            -- Enable external interrupt 0.
            when 5799 =>
               pavr_iof_opcode   <= pavr_iof_opcode_wrbyte;
               pavr_iof_addr     <= int_to_std_logic_vector(pavr_gimsk_addr, pavr_iof_addr'length);
               pavr_iof_di       <= int_to_std_logic_vector(16#40#, pavr_iof_di'length);
               pavr_iof_pa(0)    <= '1';
            -- Check if external interrupt 0 event is captured in GIFR(6).
            -- External interrupt 0 triggers on low PA(0).
            when 5800 =>
               pavr_iof_opcode   <= pavr_iof_opcode_wrbyte;
               pavr_iof_addr     <= int_to_std_logic_vector(pavr_mcucr_addr, pavr_iof_addr'length);
               pavr_iof_di       <= int_to_std_logic_vector(16#00#, pavr_iof_di'length);
               pavr_iof_pa(0)    <= '1';
            when 5801 =>
               pavr_iof_pa(0)    <= '0';
            -- External interrupt 0 triggers on negative edge of PA(0).
            when 5802 | 5803 =>
               pavr_iof_opcode   <= pavr_iof_opcode_wrbyte;
               pavr_iof_addr     <= int_to_std_logic_vector(pavr_mcucr_addr, pavr_iof_addr'length);
               pavr_iof_di       <= int_to_std_logic_vector(16#02#, pavr_iof_di'length);
               pavr_iof_pa(0)    <= '0';
            when 5804 | 5805 =>
               pavr_iof_pa(0)    <= '1';
            when 5806 | 5807 =>
               pavr_iof_pa(0)    <= '0';
            when 5808 | 5809 | 5810 | 5811 =>
               pavr_iof_pa(0)    <= '1';
            -- External interrupt 0 triggers on positive edge of PA(0).
            when 5812 | 5813 =>
               pavr_iof_opcode   <= pavr_iof_opcode_wrbyte;
               pavr_iof_addr     <= int_to_std_logic_vector(pavr_mcucr_addr, pavr_iof_addr'length);
               pavr_iof_di       <= int_to_std_logic_vector(16#03#, pavr_iof_di'length);
               pavr_iof_pa(0)    <= '0';
            when 5814 | 5815 =>
               pavr_iof_pa(0)    <= '1';
            when 5816 | 5817 =>
               pavr_iof_pa(0)    <= '0';
            when 5818 | 5819 =>
               pavr_iof_pa(0)    <= '1';


            -- That's all about testing IO File.
            when others =>
               null;
         end case;

         if syncres='1' then
            -- Sync reset
            -- The IO File should take care of reseting its registers. Check this.
            cnt <= int_to_std_logic_vector(0, cnt'length);
         end if;
      end if;
   end process test_main;


end;
-- </File body>
