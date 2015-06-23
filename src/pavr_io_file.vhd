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
-- This defines pAVR's IO File.
-- The IO File is composed of a set of discrete registers, that are grouped
--    in a memory-like entity. The IO File has a general write/read port that is
--    byte-oriented, and separate read and write ports for each register in the
--    IO File.
-- The general IO File port is a little bit more elaborated than a simple
--    read/write port. It can read bytes from IO registers to output and write
--    bytes from input to IO registers. Also, it can do some bit processing: load
--    bits (from SREG to output), store bits (from input to SREG), set IO bits,
--    clear IO bits. Bit loading/storing is done through the T bit in SREG.
--    An opcode has to be provided to specify one of the actions that this port
--    is capable of. The following opcodes are implemented for the IO File general
--    port:
--    - read byte (needed by instructions IN, SBIC, SBIS)
--    - write byte (OUT)
--    - clear bit (CBI)
--    - set bit (SBI)
--    - load bit (BLD)
--    - store bit (BST)
-- </File info>



-- <File body>
library work;
use work.std_util.all;
use work.pavr_util.all;
use work.pavr_constants.all;
library IEEE;
use IEEE.std_logic_1164.all;



entity pavr_iof is
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
      pavr_iof_pa: inout std_logic_vector(7 downto 0);

      -- Interrupt-related interface signals to control module (to the pipeline).
      pavr_disable_int  : in  std_logic;                       -- Is the pipeline ready to process a new interrupt?
      pavr_int_rq       : out std_logic;                       -- Ask the pipeline to process an interrupt.
      pavr_int_vec      : out std_logic_vector(21 downto 0)    -- Tell the pipeline what is the interrupt vector.
   );
end;



architecture pavr_iof_arch of pavr_iof is
   -- Kernel registers
   signal pavr_iof_sreg_int:   std_logic_vector(7 downto 0);
   signal pavr_iof_sph_int:    std_logic_vector(7 downto 0);
   signal pavr_iof_spl_int:    std_logic_vector(7 downto 0);
   signal pavr_iof_rampx_int:  std_logic_vector(7 downto 0);
   signal pavr_iof_rampy_int:  std_logic_vector(7 downto 0);
   signal pavr_iof_rampz_int:  std_logic_vector(7 downto 0);
   signal pavr_iof_rampd_int:  std_logic_vector(7 downto 0);
   signal pavr_iof_eind_int:   std_logic_vector(7 downto 0);

   -- Feature registers
   -- Microcontroller control
   signal pavr_iof_mcucr:  std_logic_vector(7 downto 0);
   -- General interrupt mask
   signal pavr_iof_gimsk:  std_logic_vector(7 downto 0);
   -- General interrupt flags
   signal pavr_iof_gifr:   std_logic_vector(7 downto 0);
   -- Timer 0
   signal pavr_iof_tcnt0:  std_logic_vector(8 downto 0);    -- *** 9 bits wide, to manage overflow.
   signal pavr_iof_tccr0:  std_logic_vector(7 downto 0);
   signal pavr_iof_tifr:   std_logic_vector(7 downto 0);
   signal pavr_iof_timsk:  std_logic_vector(7 downto 0);
   -- Port A
   signal pavr_iof_porta:  std_logic_vector(7 downto 0);
   signal pavr_iof_ddra:   std_logic_vector(7 downto 0);
   signal pavr_iof_pina:   std_logic_vector(7 downto 0);    -- *** This is not a register; these are just wires.

   -- Local wires
   signal pavr_tmpdi:      std_logic_vector(7 downto 0);
   signal pavr_int_flgs:      std_logic_vector(31 downto 0);   -- !!! Can it be introduced into process as var?
   signal pavr_int_flgs_dcd:  std_logic_vector(31 downto 0);   -- -"-

   signal pavr_int0_clk: std_logic;

   signal pavr_t0_clk, next_pavr_t0_clk: std_logic;
   signal clk_t0_cnt: std_logic_vector(9 downto 0);

begin

   -- Build interrupt flags vector and decode that vector. That is, prioritize
   --    interrupts and find what interrupt has to be processed.
   process(pavr_disable_int,
           pavr_int_flgs,
           pavr_iof_sreg_int,
           pavr_iof_gifr, pavr_iof_gimsk,
           pavr_iof_tifr, pavr_iof_timsk)
   begin
      pavr_int_flgs     <= int_to_std_logic_vector(0, pavr_int_flgs'length);
      pavr_int_flgs_dcd <= int_to_std_logic_vector(0, pavr_int_flgs'length);

      -- Build active interrupts flags vector
      -- First, check if the pipeline is ready to process an interrupt.
      if (pavr_disable_int = '0') then
          -- Check if interrupts are globally enabled.
         if (pavr_iof_sreg_int(7) = '1') then
            -- Check all interrupts sources if active and enabled.
            pavr_int_flgs(pavr_int0_int_pri) <= pavr_iof_gifr(6) and pavr_iof_gimsk(6);
            pavr_int_flgs(pavr_tov0_int_pri) <= pavr_iof_tifr(1) and pavr_iof_timsk(1);
         end if;
      end if;

      -- Prioritize interrupts
      pavr_int_flgs_dcd <= prioritize_int(pavr_int_flgs);
   end process;



   -- Build Timer 0 clock.
   t0_clk:
   process(pavr_iof_clk, clk_t0_cnt, pavr_iof_pina, pavr_iof_tccr0)
   begin
      next_pavr_t0_clk <= '0';
      case pavr_iof_tccr0(2 downto 0) is
         when "000" =>
            null;
         when "001" =>
            next_pavr_t0_clk <= pavr_iof_clk;
         when "010" =>
            next_pavr_t0_clk <= clk_t0_cnt(2);
         when "011" =>
            next_pavr_t0_clk <= clk_t0_cnt(5);
         when "100" =>
            next_pavr_t0_clk <= clk_t0_cnt(7);
         when "101" =>
            next_pavr_t0_clk <= clk_t0_cnt(9);
         when "110" =>
            next_pavr_t0_clk <= not pavr_iof_pina(1);
         when others =>
            next_pavr_t0_clk <= pavr_iof_pina(1);
      end case;
   end process t0_clk;



   -- Manage IOF data in.
   manage_iof_di:
   process(pavr_iof_opcode, pavr_iof_bitaddr, pavr_iof_di)
   begin
      pavr_tmpdi <= int_to_std_logic_vector(0, 8);

      case pavr_iof_opcode is
         when pavr_iof_opcode_wrbyte =>
            pavr_tmpdi <= pavr_iof_di;
         when pavr_iof_opcode_clrbit =>
            pavr_tmpdi <= pavr_iof_di;
            pavr_tmpdi(std_logic_vector_to_nat(pavr_iof_bitaddr)) <= '0';
         when pavr_iof_opcode_setbit =>
            pavr_tmpdi <= pavr_iof_di;
            pavr_tmpdi(std_logic_vector_to_nat(pavr_iof_bitaddr)) <= '1';
         when others =>
            null;
      end case;
   end process manage_iof_di;



   -- Managing IOF registers
   manage_iof_regs:
   process(pavr_iof_clk, pavr_iof_res, pavr_iof_syncres,
           pavr_iof_opcode, pavr_iof_addr, pavr_iof_di, pavr_iof_bitaddr,
           pavr_tmpdi,
           pavr_iof_sreg_wr, pavr_iof_sreg_di,
           pavr_iof_sph_wr, pavr_iof_sph_di,
           pavr_iof_spl_wr, pavr_iof_spl_di,
           pavr_iof_rampx_wr, pavr_iof_rampx_di,
           pavr_iof_rampy_wr, pavr_iof_rampy_di,
           pavr_iof_rampz_wr, pavr_iof_rampz_di,
           pavr_iof_rampd_wr, pavr_iof_rampd_di,
           pavr_iof_eind_wr, pavr_iof_eind_di,
           pavr_int_flgs_dcd,
           pavr_t0_clk, next_pavr_t0_clk, clk_t0_cnt,
           pavr_int0_clk,
           pavr_iof_sreg_int,
           pavr_iof_sph_int, pavr_iof_spl_int,
           pavr_iof_rampx_int, pavr_iof_rampy_int, pavr_iof_rampz_int,
           pavr_iof_rampd_int,
           pavr_iof_eind_int,
           pavr_iof_mcucr,
           pavr_iof_gimsk, pavr_iof_gifr,
           pavr_iof_timsk, pavr_iof_tifr,
           pavr_iof_tcnt0, pavr_iof_tccr0,
           pavr_iof_porta, pavr_iof_ddra,  pavr_iof_pina, pavr_iof_pa
          )
      variable pavr_iof_portaz: std_logic_vector(pavr_iof_porta'length - 1 downto 0);
   begin

      -- Port A asynchronous circuitry.
      for i in 0 to 7 loop
         if pavr_iof_ddra(i)='1' then
            pavr_iof_portaz(i) := pavr_iof_porta(i);
         else
            -- *** When synthesizing, to check if the technology permits weak
            --    pull-ups and high Z. If it doesn't, workaround these lines.
            if pavr_iof_porta(i)='1' then
               -- Weak pull-ups
               pavr_iof_portaz(i) := 'H';
            else
               -- High Z
               pavr_iof_portaz(i) := 'Z';
            end if;
         end if;
      end loop;
      pavr_iof_pa    <= pavr_iof_portaz;
      pavr_iof_pina  <= pavr_iof_pa;

      if (pavr_iof_res = '1') then
         -- Reset
         -- IOF registers
         pavr_iof_sreg_int    <= int_to_std_logic_vector(0, 8);
         pavr_iof_sph_int     <= int_to_std_logic_vector(0, 8);
         pavr_iof_spl_int     <= int_to_std_logic_vector(0, 8);
         pavr_iof_rampx_int   <= int_to_std_logic_vector(0, 8);
         pavr_iof_rampy_int   <= int_to_std_logic_vector(0, 8);
         pavr_iof_rampz_int   <= int_to_std_logic_vector(0, 8);
         pavr_iof_rampd_int   <= int_to_std_logic_vector(0, 8);
         pavr_iof_eind_int    <= int_to_std_logic_vector(0, 8);

         pavr_iof_mcucr       <= int_to_std_logic_vector(0, 8);
         pavr_iof_gimsk       <= int_to_std_logic_vector(0, 8);
         pavr_iof_gifr        <= int_to_std_logic_vector(0, 8);

         pavr_iof_tcnt0       <= int_to_std_logic_vector(0, 9);
         pavr_iof_tccr0       <= int_to_std_logic_vector(0, 8);
         pavr_iof_tifr        <= int_to_std_logic_vector(0, 8);
         pavr_iof_timsk       <= int_to_std_logic_vector(0, 8);

         pavr_iof_porta       <= int_to_std_logic_vector(0, 8);
         pavr_iof_ddra        <= int_to_std_logic_vector(0, 8);

         -- Local registers
         clk_t0_cnt <= int_to_std_logic_vector(0, clk_t0_cnt'length);
         pavr_t0_clk <= '0';
         pavr_int0_clk <= '0';
      elsif pavr_iof_clk'event and pavr_iof_clk = '1' then

         pavr_iof_bitout <= '0';
         pavr_int_rq  <= '0';
         pavr_int_vec <= int_to_std_logic_vector(0, 22);


         -- Feature registers-related circuitry -------------------------------
         -- External interrupt 0
         case pavr_iof_mcucr(1 downto 0) is
            when "00" =>
               -- Trigger external interrupt 0 on low level.
               if pavr_iof_pa(0)='0' then
                  pavr_iof_gifr(6) <= '1';
               end if;
            when "01" =>
               -- Not used.
               null;
            when "10" =>
               -- Trigger external interrupt 0 on negative edge.
               if pavr_int0_clk='1' and pavr_iof_pa(0)='0' then
                  pavr_iof_gifr(6) <= '1';
               end if;
            when others =>
               -- Trigger external interrupt 0 on positive edge.
               if pavr_int0_clk='0' and pavr_iof_pa(0)='1' then
                  pavr_iof_gifr(6) <= '1';
               end if;
         end case;
         pavr_int0_clk <= pavr_iof_pa(0);

         -- Timer 0
         -- Build timer 0's clock.
         -- Update counter 0.
         case pavr_iof_tccr0(2 downto 0) is
            when "000" =>
               null;
            when "001" =>
               pavr_iof_tcnt0 <= pavr_iof_tcnt0 + 1;
            when others =>
               if pavr_t0_clk='0' and next_pavr_t0_clk='1' then
                  pavr_iof_tcnt0 <= pavr_iof_tcnt0 + 1;
               end if;
         end case;
         -- Capture timer 0 overflow event.
         if pavr_iof_tcnt0(8) = '1' then
            -- Set timer 0 overflow flag in TIFR register.
            pavr_iof_tifr(1)  <= '1';
            -- Reset overflow (MSBit) in TCNT0 register, because we don't want to
            --    set overflow flag over and over again from now on.
            pavr_iof_tcnt0(8) <= '0';
         end if;
         pavr_t0_clk <= next_pavr_t0_clk;
         clk_t0_cnt <= clk_t0_cnt+1;


         -- Interrupt Manager -------------------------------------------------
         -- If interrupt 0 is decoded as a winner interrupt, then acknowledge it.
         if pavr_int_flgs_dcd(pavr_int0_int_pri) = '1' then
            pavr_iof_gifr(6) <= '0';
            pavr_int_rq      <= '1';
            pavr_int_vec     <= int_to_std_logic_vector(pavr_int0_int_vec, 22);
         end if;

         -- If timer 0 overflow interrupt is decoded as a winner interrupt, then
         --    acknowledge it.
         if pavr_int_flgs_dcd(pavr_tov0_int_pri) = '1' then
            pavr_iof_tifr(1) <= '0';
            pavr_int_rq      <= '1';
            pavr_int_vec     <= int_to_std_logic_vector(pavr_tov0_int_vec, 22);
         end if;


         -- Check IOF opcode and process it. ----------------------------------
         case pavr_iof_opcode is
            -- Read byte.
            when pavr_iof_opcode_rdbyte =>
               case std_logic_vector_to_nat(pavr_iof_addr) is
                  when pavr_sreg_addr =>
                     pavr_iof_do <= pavr_iof_sreg_int;
                  when pavr_sph_addr =>
                     pavr_iof_do <= pavr_iof_sph_int;
                  when pavr_spl_addr =>
                     pavr_iof_do <= pavr_iof_spl_int;
                  when pavr_rampx_addr =>
                     pavr_iof_do <= pavr_iof_rampx_int;
                  when pavr_rampy_addr =>
                     pavr_iof_do <= pavr_iof_rampy_int;
                  when pavr_rampz_addr =>
                     pavr_iof_do <= pavr_iof_rampz_int;
                  when pavr_rampd_addr =>
                     pavr_iof_do <= pavr_iof_rampd_int;
                  when pavr_eind_addr =>
                     pavr_iof_do <= pavr_iof_eind_int;
                  when pavr_mcucr_addr =>
                     pavr_iof_do <= pavr_iof_mcucr;
                  when pavr_gimsk_addr =>
                     pavr_iof_do <= pavr_iof_gimsk;
                  when pavr_gifr_addr =>
                     pavr_iof_do <= pavr_iof_gifr;
                  when pavr_tcnt0_addr =>
                     pavr_iof_do <= pavr_iof_tcnt0(7 downto 0);
                  when pavr_tccr0_addr =>
                     pavr_iof_do <= pavr_iof_tccr0;
                  when pavr_tifr_addr =>
                     pavr_iof_do <= pavr_iof_tifr;
                  when pavr_timsk_addr =>
                     pavr_iof_do <= pavr_iof_timsk;
                  when pavr_porta_addr =>
                     pavr_iof_do <= pavr_iof_porta;
                  when pavr_ddra_addr =>
                     pavr_iof_do <= pavr_iof_ddra;
                  when pavr_pina_addr =>
                     pavr_iof_do <= pavr_iof_pina;
                  when others =>
                     null;
               end case;
            -- Write byte | clear bit | set bit.
            when pavr_iof_opcode_wrbyte | pavr_iof_opcode_clrbit | pavr_iof_opcode_setbit =>
               case std_logic_vector_to_nat(pavr_iof_addr) is
                  when pavr_sreg_addr =>
                     pavr_iof_sreg_int <= pavr_tmpdi;
                  when pavr_sph_addr =>
                     pavr_iof_sph_int <= pavr_tmpdi;
                  when pavr_spl_addr =>
                     pavr_iof_spl_int <= pavr_tmpdi;
                  when pavr_rampx_addr =>
                     pavr_iof_rampx_int <= pavr_tmpdi;
                  when pavr_rampy_addr =>
                     pavr_iof_rampy_int <= pavr_tmpdi;
                  when pavr_rampz_addr =>
                     pavr_iof_rampz_int <= pavr_tmpdi;
                  when pavr_rampd_addr =>
                     pavr_iof_rampd_int <= pavr_tmpdi;
                  when pavr_eind_addr =>
                     pavr_iof_eind_int <= pavr_tmpdi;
                  when pavr_mcucr_addr =>
                     pavr_iof_mcucr <= pavr_tmpdi;
                  when pavr_gimsk_addr =>
                     pavr_iof_gimsk <= pavr_tmpdi;
                  when pavr_gifr_addr =>
                     pavr_iof_gifr <= pavr_tmpdi;
                  when pavr_tcnt0_addr =>
                     pavr_iof_tcnt0(         8) <= '0';
                     pavr_iof_tcnt0(7 downto 0) <= pavr_tmpdi;
                  when pavr_tccr0_addr =>
                     pavr_iof_tccr0 <= pavr_tmpdi;
                  when pavr_tifr_addr =>
                     pavr_iof_tifr <= pavr_tmpdi;
                  when pavr_timsk_addr =>
                     pavr_iof_timsk <= pavr_tmpdi;
                  when pavr_porta_addr =>
                     pavr_iof_porta <= pavr_tmpdi;
                  when pavr_ddra_addr =>
                     pavr_iof_ddra <= pavr_tmpdi;
                  when pavr_pina_addr =>
                     -- PinA is just a read-only wire.
                     null;
                  when others =>
                     null;
               end case;
            -- Load bit.
            when pavr_iof_opcode_ldbit =>
               pavr_iof_do <= pavr_iof_di;
               pavr_iof_do(std_logic_vector_to_nat(pavr_iof_bitaddr)) <= pavr_iof_sreg_int(6);
            -- Store bit.
            when pavr_iof_opcode_stbit =>
               pavr_iof_sreg_int(6) <= pavr_iof_di(std_logic_vector_to_nat(pavr_iof_bitaddr));
            -- pavr_iof_opcode_nop
            when others =>
               null;
         end case;

         -- Kernel registers ports --------------------------------------------
         -- Status register (SREG) port
         if (pavr_iof_sreg_wr = '1') then
            pavr_iof_sreg_int <= pavr_iof_sreg_di;
         end if;

         -- Stack pointer (SPH&SPL) ports
         if (pavr_iof_sph_wr = '1') then
            pavr_iof_sph_int <= pavr_iof_sph_di;
         end if;
         if (pavr_iof_spl_wr = '1') then
            pavr_iof_spl_int <= pavr_iof_spl_di;
         end if;

         -- Pointer registers X extension (RAMPX) port
         if (pavr_iof_rampx_wr = '1') then
            pavr_iof_rampx_int <= pavr_iof_rampx_di;
         end if;

         -- Pointer registers Y extension (RAMPY) port
         if (pavr_iof_rampy_wr = '1') then
            pavr_iof_rampy_int <= pavr_iof_rampy_di;
         end if;

         -- Pointer registers Z extension (RAMPZ) port
         if (pavr_iof_rampz_wr = '1') then
            pavr_iof_rampz_int <= pavr_iof_rampz_di;
         end if;

         -- Data Memory extension address (RAMPD) register
         if (pavr_iof_rampd_wr = '1') then
            pavr_iof_rampd_int <= pavr_iof_rampd_di;
         end if;

         -- Program Memory extension address (EIND) register
         if (pavr_iof_eind_wr = '1') then
            pavr_iof_eind_int <= pavr_iof_eind_di;
         end if;

         if (pavr_iof_syncres = '1') then
            -- Synchronous reset
            -- IOF registers
            pavr_iof_sreg_int    <= int_to_std_logic_vector(0, 8);
            pavr_iof_sph_int     <= int_to_std_logic_vector(0, 8);
            pavr_iof_spl_int     <= int_to_std_logic_vector(0, 8);
            pavr_iof_rampx_int   <= int_to_std_logic_vector(0, 8);
            pavr_iof_rampy_int   <= int_to_std_logic_vector(0, 8);
            pavr_iof_rampz_int   <= int_to_std_logic_vector(0, 8);
            pavr_iof_rampd_int   <= int_to_std_logic_vector(0, 8);
            pavr_iof_eind_int    <= int_to_std_logic_vector(0, 8);

            pavr_iof_mcucr       <= int_to_std_logic_vector(0, 8);
            pavr_iof_gimsk       <= int_to_std_logic_vector(0, 8);
            pavr_iof_gifr        <= int_to_std_logic_vector(0, 8);

            pavr_iof_tcnt0       <= int_to_std_logic_vector(0, 9);
            pavr_iof_tccr0       <= int_to_std_logic_vector(0, 8);
            pavr_iof_tifr        <= int_to_std_logic_vector(0, 8);
            pavr_iof_timsk       <= int_to_std_logic_vector(0, 8);

            pavr_iof_porta       <= int_to_std_logic_vector(0, 8);
            pavr_iof_ddra        <= int_to_std_logic_vector(0, 8);

            -- Local registers
            clk_t0_cnt <= int_to_std_logic_vector(0, clk_t0_cnt'length);
            pavr_t0_clk <= '0';
            pavr_int0_clk <= '0';
         end if;
      end if;
   end process manage_iof_regs;



   -- Zero-level assignments.
   pavr_iof_sreg  <= pavr_iof_sreg_int;
   pavr_iof_sph   <= pavr_iof_sph_int;
   pavr_iof_spl   <= pavr_iof_spl_int;
   pavr_iof_rampx <= pavr_iof_rampx_int;
   pavr_iof_rampy <= pavr_iof_rampy_int;
   pavr_iof_rampz <= pavr_iof_rampz_int;
   pavr_iof_rampd <= pavr_iof_rampd_int;
   pavr_iof_eind  <= pavr_iof_eind_int;

end;
-- </File body>
