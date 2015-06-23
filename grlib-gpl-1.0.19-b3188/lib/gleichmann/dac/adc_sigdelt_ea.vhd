
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity adc_sigdelt is
  generic(c_adcin_length : positive := 8);  -- length of binary input vector adc_in
  port(
    rstn    : in  std_ulogic;           -- resets integrator, high-active
    clk     : in  std_ulogic;           -- sampling clock
    valid   : out std_ulogic;
    adc_fb  : out std_ulogic;           -- feedback
    adc_out : out std_logic_vector(c_adcin_length-1 downto 0);  -- output vector
    adc_in  : in  std_ulogic            -- input bit stream
    );
end adc_sigdelt;

architecture rtl of adc_sigdelt is
  signal ff            : std_ulogic;    -- registered input flipflop
  signal width_counter : integer range 0 to 2**c_adcin_length - 1;
  signal one_counter   : integer range 0 to 2**c_adcin_length - 1;
begin

  parallelize : process (clk, rstn) is
  begin
    if rstn = '0' then
      ff            <= '0';
      width_counter <= 0;
      one_counter   <= 0;
      valid         <= '0';
      adc_out       <= (others => '0');
    elsif rising_edge(clk) then
      ff <= adc_in;

      if width_counter < 2**c_adcin_length-1 then
        width_counter <= width_counter + 1;
        valid         <= '0';
        if ff = '1' then
          one_counter <= one_counter + 1;
        end if;
      else -- counter overflow
        -- reset counters
        width_counter <= 0;
        one_counter   <= 0;
        -- output parallelized value and signal that it is valid
        adc_out       <= std_logic_vector(to_unsigned(one_counter, c_adcin_length));
        valid         <= '1';
      end if;

    end if;
  end process parallelize;

  -- feed back read value to comparator
  adc_fb <= ff;

end rtl;

