----------------------------------------------------------------------
--                                                                  --
--  THIS VHDL SOURCE CODE IS PROVIDED UNDER THE GNU PUBLIC LICENSE  --
--                                                                  --
----------------------------------------------------------------------
--                                                                  --
--    Filename            : waveform_gen.vhd                        --
--                                                                  --
--    Author              : Simon Doherty                           --
--                          Senior Design Consultant                --
--                          www.zipcores.com                        --
--                                                                  --
--    Date last modified  : 24.10.2008                              --
--                                                                  --
--    Description         : NCO / Periodic Waveform Generator       --
--                                                                  --
----------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;


entity waveform_gen is

port (

  -- system signals
  clk         : in  std_logic;
  reset       : in  std_logic;
  
  -- clock-enable
  en          : in  std_logic;
  
  -- NCO frequency control
  phase_inc   : in  std_logic_vector(31 downto 0);
  
  -- Output waveforms
  sin_out     : out std_logic_vector(11 downto 0);
  cos_out     : out std_logic_vector(11 downto 0);
  squ_out     : out std_logic_vector(11 downto 0);
  saw_out     : out std_logic_vector(11 downto 0) );
  
end entity;


architecture rtl of waveform_gen is


component sincos_lut

port (

  clk      : in  std_logic;
  en       : in  std_logic;
  addr     : in  std_logic_vector(11 downto 0);
  sin_out  : out std_logic_vector(11 downto 0);
  cos_out  : out std_logic_vector(11 downto 0));
  
end component;


signal  phase_acc     : std_logic_vector(31 downto 0);
signal  lut_addr      : std_logic_vector(11 downto 0);
signal  lut_addr_reg  : std_logic_vector(11 downto 0);


begin


--------------------------------------------------------------------------
-- Phase accumulator increments by 'phase_inc' every clock cycle        --
-- Output frequency determined by formula: Phase_inc = (Fout/Fclk)*2^32 --
-- E.g. Fout = 36MHz, Fclk = 100MHz,  Phase_inc = 36*2^32/100           --
-- Frequency resolution is 100MHz/2^32 = 0.00233Hz                      --
--------------------------------------------------------------------------

phase_acc_reg: process(clk, reset)
begin
  if reset = '0' then
    phase_acc <= (others => '0');
  elsif clk'event and clk = '1' then
    if en = '1' then
      phase_acc <= unsigned(phase_acc) + unsigned(phase_inc); 
    end if;
  end if;
end process phase_acc_reg;

---------------------------------------------------------------------
-- use top 12-bits of phase accumulator to address the SIN/COS LUT --
---------------------------------------------------------------------

lut_addr <= phase_acc(31 downto 20);

----------------------------------------------------------------------
-- SIN/COS LUT is 4096 by 12-bit ROM                                --
-- 12-bit output allows sin/cos amplitudes between 2047 and -2047   --
-- (-2048 not used to keep the output signal perfectly symmetrical) --
-- Phase resolution is 2Pi/4096 = 0.088 degrees                     --
----------------------------------------------------------------------

lut: sincos_lut

  port map (

    clk       => clk,
    en        => en,
    addr      => lut_addr,
    sin_out   => sin_out,
    cos_out   => cos_out );

---------------------------------
-- Hide the latency of the LUT --
---------------------------------

delay_regs: process(clk)
begin
  if clk'event and clk = '1' then
    if en = '1' then
      lut_addr_reg <= lut_addr;
    end if;
  end if;
end process delay_regs;

---------------------------------------------
-- Square output is msb of the accumulator --
---------------------------------------------

squ_out <= "011111111111" when lut_addr_reg(11) = '1' else "100000000000";

-------------------------------------------------------
-- Sawtooth output is top 12-bits of the accumulator --
-------------------------------------------------------

saw_out <= lut_addr_reg;
    
    
end rtl;