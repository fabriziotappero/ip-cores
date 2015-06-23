library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;



entity IQGainPhaseCorrection is

generic(width:natural);

port(
	clk				:in std_logic;
	x1				:in signed(width-1 downto 0);
	y1				:in signed(width-1 downto 0);
	gain_error		:out signed(width-1 downto 0);
	gain_lock		:out bit;
	phase_error		:out signed(width-1 downto 0);
	phase_lock		:out bit;
	corrected_x1	:out signed(width-1 downto 0);
	corrected_y1	:out signed(width-1 downto 0)
	);

end IQGainPhaseCorrection;

