-----------------------------------------------------------------------------
-- Wishbone TIMER 8bit ------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity wb_timer_8 is
   port (
      clk      : in  std_ulogic;
      reset    : in  std_ulogic;
      -- Wishbone bus
      wb_adr_i : in  std_ulogic_vector(7 downto 0);
      wb_dat_i : in  std_ulogic_vector(7 downto 0);
      wb_dat_o : out std_ulogic_vector(7 downto 0);
      wb_cyc_i : in  std_ulogic;
      wb_stb_i : in  std_ulogic;
      wb_ack_o : out std_ulogic;
      wb_we_i  : in  std_ulogic;
      wb_irq0_o: out std_ulogic;
      wb_irq1_o: out std_ulogic );
end wb_timer_8;

-----------------------------------------------------------------------------
-- 0x00: TCR0          Timer Control and Status Register
-- 0x04: COMPARE0
-- 0x08: COUNTER0
-- 0x0C: TCR1
-- 0x10: COMPARE1
-- 0x14: COUNTER1
--
-- TCRx:
-- 
--   +-----------------------------------+-----+-----+--------+-------+
--   |     ZEROs ( 7 downto 4)           | en0 | ar0 | irq0en | trig0 |
--   +-----------------------------------+-----+-----+--------+-------+
--

-----------------------------------------------------------------------------
-- Implementation -----------------------------------------------------------
architecture rtl of wb_timer_8 is
	constant	ADDR_TRC0 		: std_ulogic_vector(7 downto 0) := x"00";
	constant	ADDR_COMPARE0	: std_ulogic_vector(7 downto 0) := x"04";
	constant	ADDR_COUNTER0	: std_ulogic_vector(7 downto 0) := x"08";
	constant	ADDR_TRC1 		: std_ulogic_vector(7 downto 0) := x"0C";
	constant	ADDR_COMPARE1	: std_ulogic_vector(7 downto 0) := x"10";
	constant	ADDR_COUNTER1	: std_ulogic_vector(7 downto 0) := x"14";

signal wbactive      : std_ulogic;

signal counter0      : unsigned(7 downto 0);
signal counter1      : unsigned(7 downto 0);

signal compare0      : unsigned(7 downto 0);
signal compare1      : unsigned(7 downto 0);

signal en0, en1      : std_ulogic;     -- Enable counter
signal ar0, ar1      : std_ulogic;     -- Auto Reload
signal trig0, trig1  : std_ulogic;     -- Triggered

signal irq0en, irq1en: std_ulogic;     -- Enable Interrupt

signal tcr0, tcr1    : std_ulogic_vector(7 downto 0);


begin

-----------------------------------------------------------------------------
-- Wishbone handling --------------------------------------------------------
wbactive <= wb_stb_i and wb_cyc_i;

wb_ack_o <= wbactive;

wb_dat_o <= tcr0                        when wbactive='1' and wb_adr_i=ADDR_TRC0		else
            std_ulogic_vector(compare0)  when wbactive='1' and wb_adr_i=ADDR_COMPARE0	else
            std_ulogic_vector(counter0)  when wbactive='1' and wb_adr_i=ADDR_COUNTER0	else
            tcr1                        when wbactive='1' and wb_adr_i=ADDR_TRC1		else
            std_ulogic_vector(compare1)  when wbactive='1' and wb_adr_i=ADDR_COMPARE1	else
            std_ulogic_vector(counter1)  when wbactive='1' and wb_adr_i=ADDR_COUNTER1	else
            (others => '-');

wb_irq0_o <= trig0 and irq0en;
wb_irq1_o <= trig1 and irq1en;

tcr0 <= "0000" & en0 & ar0 & irq0en & trig0;
tcr1 <= "0000" & en1 & ar1 & irq1en & trig1;

timerproc: process (reset, clk) is
variable val : std_ulogic_vector(7 downto 0);
begin
	if reset='1' then 
		en0       <= '0';      -- enable
		en1       <= '0';
		ar0       <= '0';      -- auto reload
		ar1       <= '0';
		trig0     <= '0';      -- triggered
		trig1     <= '0';
		irq0en    <= '0';      -- IRQ enable
		irq1en    <= '0';
		compare0  <= TO_UNSIGNED(0, 8);        -- compare
		compare1  <= TO_UNSIGNED(0, 8);
		counter0  <= TO_UNSIGNED(0, 8);        -- actual counter
		counter1  <= TO_UNSIGNED(0, 8);
	elsif clk'event and clk='1' then

		-- Reset trigX on TCR access --------------------------------
		if wbactive='1' and wb_adr_i=x"00" then
			trig0 <= '0';
		end if;
		if wbactive='1' and wb_adr_i=x"0C" then
			trig1 <= '0';
		end if;

		-- WB write register ----------------------------------------
		if wbactive='1' and wb_we_i='1' then 

			val := wb_dat_i;

			-- decode WB_ADR_I --
			if wb_adr_i=ADDR_TRC0 then 
				en0    <= val(3);
				ar0    <= val(2);
				irq0en <= val(1);
			elsif wb_adr_i=ADDR_COMPARE0 then 
				compare0 <= unsigned(val);
			elsif wb_adr_i=ADDR_COUNTER0 then
				counter0 <= unsigned(val);
			elsif wb_adr_i=ADDR_TRC1 then
				en1    <= val(3);
				ar1    <= val(2);
				irq1en <= val(1);
			elsif wb_adr_i=ADDR_COMPARE1 then
				compare1 <= unsigned(val);
			elsif wb_adr_i=ADDR_COUNTER1 then
				counter1 <= unsigned(val);
			end if;
		end if;


		-- timer0 ---------------------------------------------------
		if en0='1' then 
			if counter0 = compare0 then
				trig0 <= '1';
				if ar0='1' then
					counter0 <= to_unsigned(1, 8);
				else 
					en0 <= '0';
				end if;
			else
				counter0 <= counter0 + 1;
			end if;
		end if;

		-- timer1 ---------------------------------------------------
		if en1='1' then 
			if counter1 = compare1 then
				trig1 <= '1';
				if ar1='1' then
					counter1 <= to_unsigned(1, 8);
				else 
					en1 <= '0';
				end if;
			else
				counter1 <= counter1 + 1;
			end if;
		end if;

	end if;
end process;

end rtl;
