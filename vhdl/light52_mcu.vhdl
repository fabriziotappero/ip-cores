--------------------------------------------------------------------------------
-- light52_mcu.vhdl -- MCU/SoC built around light52 CPU.
--------------------------------------------------------------------------------
-- The MCU is a minimalistic SoC built around the light52 core mostly for
-- demonstration purposes. It has more or less the same features as a plain old
-- i8051: an UART, a timer and a bunch of i/o.
-- While it can be used as it stands, it is meant to be modified to suit each 
-- particular application of the core. Thus, no effort has been made to provide 
-- a variety of general purpose peripherals. You are supposed to supply them 
-- yourself.
-- 
--
-- A complete explanation of all the peripherals and their SFRs can be found in
-- the core datasheet.
--
--------------------------------------------------------------------------------
-- INTERFACE SIGNALS
--
-- clk :                Clock, active rising edge.
-- reset :              Synchronous reset, hold for at least 1 cycle.
--
-- rxd :                UART RxD input.
-- txd :                UART TxD output.
--
-- external_irq :       External interrupt request inputs. 
--                      Level active: Will trigger interrupt #0 as long as any 
--                      of them is high (if enabled).
--
-- p0_out :             Output GP port 0.
-- p1_out :             Output GP port 1.
-- p2_in :              Input GP port 2.
-- p3_out :             Input GP port 3.
--
--------------------------------------------------------------------------------
-- GENERICS:
--
-- CODE_ROM_SIZE 
--  Size in bytes of XCODE ROM block to be initialized with application object 
--  code. Must be 512 <= CODE_ROM_SIZE < 64K.
--
-- XDATA_RAM_SIZE               
-- Size of XDATA RAM. Can be zero. 
--
-- OBJ_CODE
--  Object code constant hardwired onto XCODE ROM block. This value is meant to 
--  come from a constant defined in an 'object code package', built from the 
--  project application object code. See the datasheet.
--
-- IMPLEMENT_BCD_INSTRUCTIONS
--  Whether or not to implement BCD instructions. 
--  When true, instructions DA and XCHD will work as in the original MCS51.
--  When false, those instructions will work as NOP, saving some logic.
--
-- SEQUENTIAL_MULTIPLIER
--  Sequential vs. combinational multiplier.
--  When true, a sequential implementation will be used for the multiplier, 
--  which will usually save a lot of logic or a dedicated multiplier.
--  When false, a combinational registered multiplier will be used.
--  (NOT IMPLEMENTED -- setting it to true will raise an assertion failure).
--
-- USE_BRAM_FOR_XRAM            
--  Use extra space in IRAM/uCode RAM as XRAM.
--  When true, extra logic will be generated so that the extra space in the 
--  RAM block used for IRAM/uCode can be used as XRAM.
--  This prevents RAM waste at some cost in area and clock rate.
--  When false, any extra space in the IRAM physical block will be wasted.
--
-- UART_HARDWIRED               
--  UART baud rate is hardwired to its default value, writes to the SBPL, SBPH 
--  SFR registers have no effect.
--
-- UART_BAUD_RATE               
--  Default UART baud rate. Must be <= (CLOCK_RATE/16).
--
-- CLOCK_RATE                   
--  Main clock frequency in Hz. Used in the computation of the periods of the 
--  UART and the timer.
--
-- TIMER0_COUNT_RATE 
--  Count rate of Timer0. Used to compute the value of the Timer0 prescaler.
--
--------------------------------------------------------------------------------
-- Copyright (C) 2012 Jose A. Ruiz
--                                                              
-- This source file may be used and distributed without         
-- restriction provided that this copyright statement is not    
-- removed from the file and that any derivative work contains  
-- the original copyright notice and the associated disclaimer. 
--                                                              
-- This source file is free software; you can redistribute it   
-- and/or modify it under the terms of the GNU Lesser General   
-- Public License as published by the Free Software Foundation; 
-- either version 2.1 of the License, or (at your option) any   
-- later version.                                               
--                                                              
-- This source is distributed in the hope that it will be       
-- useful, but WITHOUT ANY WARRANTY; without even the implied   
-- warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      
-- PURPOSE.  See the GNU Lesser General Public License for more 
-- details.                                                     
--                                                              
-- You should have received a copy of the GNU Lesser General    
-- Public License along with this source; if not, download it   
-- from http://www.opencores.org/lgpl.shtml
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.light52_pkg.all;
use work.obj_code_pkg.all;


entity light52_mcu is
    generic (
        -- External memory configuration -- These default values will be 
        -- overriden in the actual project instantiation.
        CODE_ROM_SIZE :         natural := 2*1024;
        XDATA_RAM_SIZE :        natural := 0;
        OBJ_CODE :              t_obj_code := default_object_code;
        -- CPU configuration (see CPU module).
        USE_BRAM_FOR_XRAM :     boolean := false;
        IMPLEMENT_BCD_INSTRUCTIONS : boolean := false;
        SEQUENTIAL_MULTIPLIER : boolean := false;
        -- Peripheral configuration (see peripheral modules).
        UART_HARDWIRED :        boolean := false;
        UART_BAUD_RATE :        natural := 19200;
        CLOCK_RATE :            natural := 50e6;
        -- Timer0 count period = 20 us by default (20e-6 = 1/50e3)
        TIMER0_COUNT_RATE :     natural := 50e3
    );
    port(
        clk             : in std_logic;
        reset           : in std_logic;
                       
        rxd             : in std_logic;
        txd             : out std_logic;
        
        external_irq    : in std_logic_vector(7 downto 0);
        
        p0_out          : out std_logic_vector(7 downto 0);
        p1_out          : out std_logic_vector(7 downto 0);
        p2_in           : in std_logic_vector(7 downto 0);
        p3_in           : in std_logic_vector(7 downto 0)                       
    );
end entity light52_mcu;


architecture rtl of light52_mcu is

---- SFR addresses -------------------------------------------------------------

subtype t_mcu_sfr_addr is std_logic_vector(7 downto 0);

-- These include only the SFR addresses of the MCU peripherals; the CPU SFRs are
-- covered in the main package.
-- Note these addresses overlap those of the original 8051 but the SFRs 
-- themselves are NOT compatible!
constant SFR_ADDR_SCON      : t_mcu_sfr_addr := X"98";
constant SFR_ADDR_SBUF      : t_mcu_sfr_addr := X"99";
constant SFR_ADDR_SBPL      : t_mcu_sfr_addr := X"9a";
constant SFR_ADDR_SBPH      : t_mcu_sfr_addr := X"9b";
constant SFR_ADDR_P0        : t_mcu_sfr_addr := X"80";
constant SFR_ADDR_P1        : t_mcu_sfr_addr := X"90";
constant SFR_ADDR_P2        : t_mcu_sfr_addr := X"a0";
constant SFR_ADDR_P3        : t_mcu_sfr_addr := X"b0";
constant SFR_ADDR_TCON      : t_mcu_sfr_addr := X"88";
constant SFR_ADDR_TL        : t_mcu_sfr_addr := X"8c";
constant SFR_ADDR_TH        : t_mcu_sfr_addr := X"8d";
constant SFR_ADDR_TCL       : t_mcu_sfr_addr := X"8e";
constant SFR_ADDR_TCH       : t_mcu_sfr_addr := X"8f";
constant SFR_ADDR_EXTINT    : t_mcu_sfr_addr := X"c0";

constant P0_RESET_VALUE     : std_logic_vector(7 downto 0) := X"00";
constant P1_RESET_VALUE     : std_logic_vector(7 downto 0) := X"00";


----- XCODE interface ----------------------------------------------------------

signal code_addr :          std_logic_vector(15 downto 0);
signal code_rd :            std_logic_vector(7 downto 0);

-- Code ROM must be initialized with the object code.
signal code_bram :          t_bram(0 to CODE_ROM_SIZE-1) := 
                            objcode_to_bram(OBJ_CODE, CODE_ROM_SIZE);
signal code_addr_slice :    std_logic_vector(log2(CODE_ROM_SIZE)-1 downto 0);


---- XDATA interface -----------------------------------------------------------

signal xdata_addr :         std_logic_vector(15 downto 0);
signal xdata_rd :           std_logic_vector(7 downto 0);
signal xdata_wr :           std_logic_vector(7 downto 0);
signal xdata_vma :          std_logic;
signal xdata_we :           std_logic;

signal xdata_ram :          t_bram(0 to XDATA_RAM_SIZE-1);
signal data_addr_slice :    std_logic_vector(log2(XDATA_RAM_SIZE)-1 downto 0);

---- SFR and peripheral module interface signals -------------------------------

signal sfr_addr :           std_logic_vector(7 downto 0);
signal sfr_rd :             std_logic_vector(7 downto 0);
signal sfr_wr :             std_logic_vector(7 downto 0);
signal sfr_vma :            std_logic;
signal sfr_we :             std_logic;

signal uart_re :            std_logic;
signal uart_ce :            std_logic;
signal uart_sfr_rd :        std_logic_vector(7 downto 0);
signal uart_irq :           std_logic;

signal timer_we :           std_logic;
signal timer_ce :           std_logic;
signal timer_sfr_rd :       std_logic_vector(7 downto 0);
signal timer_irq :          std_logic;

signal io_ce :              std_logic;
signal p0_reg :             std_logic_vector(7 downto 0);
signal p1_reg :             std_logic_vector(7 downto 0);
signal p2_reg :             std_logic_vector(7 downto 0);
signal p3_reg :             std_logic_vector(7 downto 0);

signal ext_irq_ce :         std_logic;
signal external_irq_reg :   std_logic_vector(7 downto 0);
signal ext_irq :            std_logic;

signal irq_source :         std_logic_vector(4 downto 0);


begin

---- CPU entity instantiation --------------------------------------------------

    cpu: entity work.light52_cpu 
    generic map (
        USE_BRAM_FOR_XRAM => USE_BRAM_FOR_XRAM,
        IMPLEMENT_BCD_INSTRUCTIONS => IMPLEMENT_BCD_INSTRUCTIONS,
        SEQUENTIAL_MULTIPLIER => SEQUENTIAL_MULTIPLIER
    )
    port map (
        clk         => clk,
        reset       => reset,
        
        code_addr   => code_addr,
        code_rd     => code_rd,

        irq_source  => irq_source,
        
        xdata_addr  => xdata_addr,
        xdata_rd    => xdata_rd,
        xdata_wr    => xdata_wr,
        xdata_vma   => xdata_vma,
        xdata_we    => xdata_we,

        
        sfr_addr    => sfr_addr,
        sfr_rd      => sfr_rd,
        sfr_wr      => sfr_wr,
        sfr_vma     => sfr_vma,
        sfr_we      => sfr_we
    );

    -- Connect peripheral IRQ inputs to the CPU.
    irq_source <= uart_irq & "00" & timer_irq & ext_irq;

---- SFR input mux -------------------------------------------------------------

    -- You have to modify simplified addressing if you add new peripherals.
    -- WARNING:
    -- If we use constant slices for decoding instead of bit vector literals,
    -- Xilinx ISE 9.2i will complain that 'sfr_rd is not assigned' and will 
    -- optimize away the SFR input mux.
    -- The only way I've found to fix this is to use literals, though it 
    -- defeats the purpose of using constants in the first place...
    with sfr_addr(7 downto 3) select sfr_rd <=
        uart_sfr_rd     when "10011",       -- SFR_ADDR_SCON(7 downto 3)
        timer_sfr_rd    when "10001",       -- SFR_ADDR_TCON(7 downto 3)
        p0_reg          when "10000",       -- SFR_ADDR_P0(7 downto 3)
        p1_reg          when "10010",       -- SFR_ADDR_P1(7 downto 3)
        p2_reg          when "10100",       -- SFR_ADDR_P2(7 downto 3)
        p3_reg          when others;
        
    
---- XCODE memory block --------------------------------------------------------

    -- Make sure the XCODE size is within bounds.
    assert 512 <= CODE_ROM_SIZE and CODE_ROM_SIZE <= 65536
    report "Invalid value for CODE_ROM_SIZE (<512 or >64KB)."
    severity failure;


    code_addr_slice <= code_addr(code_addr_slice'high downto 0);

    code_ram_block:
    process(clk)
    begin
        if clk'event and clk='1' then
            code_rd <= code_bram(to_integer(unsigned(code_addr_slice)));
        end if;
    end process code_ram_block;

---- XDATA memory block --------------------------------------------------------

    -- Make sure the XDATA size is within bounds.
    assert XDATA_RAM_SIZE <= 65536
    report "Invalid value for XDATA_RAM_SIZE (>64KB)."
    severity failure;

    -- If the XDATA memory is implemented, infer a synchronous RAM block.
    -- This block will be mirrored all over the 64K space, as usual.
    xdata_implemented:
    if XDATA_RAM_SIZE > 0 generate

    data_addr_slice <= xdata_addr(data_addr_slice'high downto 0);

    xdata_ram_block:
    process(clk)
    begin
        if clk'event and clk='1' then
            if xdata_we='1' then
                xdata_ram(to_integer(unsigned(data_addr_slice))) <= xdata_wr;
            end if;
            xdata_rd <= xdata_ram(to_integer(unsigned(data_addr_slice)));
        end if;
    end process xdata_ram_block;

    end generate xdata_implemented;
    
    -- If the XDATA memory is not implemented, ground the data input.
    xdata_unimplemented:
    if XDATA_RAM_SIZE = 0 generate
    
        xdata_rd <= (others => '0');
    
    end generate xdata_unimplemented;
  
    

---- UART ----------------------------------------------------------------------

    uart : entity work.light52_uart
    generic map (
        HARDWIRED => UART_HARDWIRED,
        CLOCK_FREQ => CLOCK_RATE,
        BAUD_RATE => UART_BAUD_RATE
    )
    port map (
        rxd_i   => rxd,
        txd_o   => txd,
        
        irq_o   => uart_irq,
        
        data_i  => sfr_wr,
        data_o  => uart_sfr_rd,
        
        addr_i  => sfr_addr(1 downto 0),
        wr_i    => sfr_we,
        rd_i    => uart_re,
        ce_i    => uart_ce,
        
        clk_i   => clk,
        reset_i => reset
    );

    -- Make sure the simplifications we'll do in the address decoding are valid.
    assert SFR_ADDR_SCON=X"98" and SFR_ADDR_SBUF=X"99" and 
           SFR_ADDR_SBPL=X"9a" and SFR_ADDR_SBPH=X"9b"
    report "MCU SFR address decoding assumes standard UART register addresses "&
           "but addresses configured in light52_mcu are not standard."
    severity failure;

    uart_ce <= '1' when sfr_addr(7 downto 3)=SFR_ADDR_SCON(7 downto 3) else '0';
    uart_re <= sfr_vma and not sfr_we;


---- Timer ---------------------------------------------------------------------

    -- This is a basic 16-bit timer set up as a 20-microsecond-period counter
    timer: entity work.light52_timer
    generic map (
        PRESCALER_VALUE => CLOCK_RATE / TIMER0_COUNT_RATE
    )
    port map (
        irq_o   => timer_irq,
        
        data_i  => sfr_wr,
        data_o  => timer_sfr_rd,
        
        addr_i  => sfr_addr(2 downto 0),
        wr_i    => timer_we,
        ce_i    => timer_ce,
        
        clk_i   => clk,
        reset_i => reset
    );

    timer_ce <= '1' when sfr_addr(7 downto 3)=SFR_ADDR_TCON(7 downto 3) and
                sfr_vma='1' 
                else '0';
    timer_we <= sfr_we;

    -- Make sure the simplifications we do in the address decoding are valid.
    assert SFR_ADDR_TCON=X"88" and SFR_ADDR_TL=X"8c"
    report "MCU SFR simplified address decoding makes assumptions that conflict "&
           "with the SFR addresses configured in light52_mcu."
    severity failure;


---- Input/Output ports --------------------------------------------------------
-- FIXME this should be encapsulated in a separate module

    -- Make sure the simplifications we'll do in the address decoding are valid.
    assert SFR_ADDR_P0=X"80" and SFR_ADDR_P1=X"90" and 
           SFR_ADDR_P2=X"a0" and SFR_ADDR_P3=X"b0"
    report "MCU SFR address decoding assumes I/O port addresses are standard "&
           "but addresses configured in light52_pkg are not."
    severity failure;

    io_ce <= '1' when sfr_addr(7 downto 6)=SFR_ADDR_P0(7 downto 6) and 
                      sfr_addr(3 downto 0)="0000" and
                      sfr_vma='1'
                      else '0';

    output_ports:
    process(clk)
    begin
        if clk'event and clk='1' then
            if reset='1' then 
                p0_reg <= P0_RESET_VALUE;
                p1_reg <= P1_RESET_VALUE;
            else
                if io_ce='1' and sfr_we='1' then
                    if sfr_addr(5 downto 4)=SFR_ADDR_P0(5 downto 4) then
                        p0_reg <= sfr_wr;
                    end if;
                    if sfr_addr(5 downto 4)=SFR_ADDR_P1(5 downto 4) then
                        p1_reg <= sfr_wr;
                    end if;
                end if;
            end if;
        end if;
    end process output_ports;

    -- Note that for output ports the CPU will ALWAYS read the output register and
    -- not the actual pin status -- like read-modify-write instructions in the
    -- original MCS51.
    p0_out <= p0_reg;
    p1_out <= p1_reg;

    -- NOTE: input ports are registered but NOT protected against metastability.
    -- Add a second layer of registers if your application needs the protection.
    input_ports:
    process(clk)
    begin
        if clk'event and clk='1' then
            p2_reg <= p2_in;
            p3_reg <= p3_in;
        end if;
    end process input_ports;


---- External interrupt block --------------------------------------------------
-- FIXME this should be encapsulated in a separate module

    ext_irq_ce <= '1' when sfr_addr(7 downto 6)=SFR_ADDR_EXTINT(7 downto 6) and 
                      sfr_addr(3 downto 0)="0000" and
                      sfr_vma='1'
                      else '0';

    external_interrupt_register:
    process(clk)
    begin
        if clk'event and clk='1' then
            if reset='1' then
                external_irq_reg <= (others => '0');
            else
                if ext_irq_ce='1' and sfr_we='1' then
                    -- All bits in this register are w1c
                    external_irq_reg <= external_irq_reg and (not sfr_wr);
                else
                    external_irq_reg <= external_irq or external_irq_reg;
                end if;
            end if;
        end if;
    end process external_interrupt_register;

    ext_irq <= '1' when external_irq_reg/=X"00" else '0';

end architecture rtl;
