library ieee;
use ieee.std_logic_1164.all;
use ieee.math_real.all;
use ieee.numeric_std.all;
use std.textio.all;
use ieee.std_logic_textio.all;

entity IQGainPhaseCorrection_testbench is
end entity;


--The read architecture reads I and Q samples from a text file.
--The values were created by the MATLAB reference model for the design.

architecture IQGainPhaseCorrection_testbench_read of IQGainPhaseCorrection_testbench is

--declare the DUT as a component.
component IQGainPhaseCorrection is
	generic(width :natural);
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
end component;


--tell the testbench which architecture we're using.
--for DUT: IQGainPhaseCorrection use entity IQGainPhaseCorrection_entity(IQGainPhaseCorrection_arch_integer);




--provide signals to run the DUT.
signal clk_tb			: std_logic := '0';
signal clk_tb_delayed	: std_logic	:= '0';
signal x1_tb			: signed(31 downto 0);
signal y1_tb			: signed(31 downto 0);
signal gain_error_tb	: signed(31 downto 0);
signal gain_lock_tb		: bit;
signal phase_error_tb	: signed(31 downto 0);
signal phase_lock_tb	: bit;
signal corrected_x1_tb	: signed(31 downto 0);
signal corrected_y1_tb	: signed(31 downto 0);



begin

	--connect the testbench signal to the component
	DUT:IQGainPhaseCorrection
	generic map(
	width => 32
	)
	port map(
	clk => clk_tb_delayed,
	x1 => x1_tb,
	y1 => y1_tb,
	gain_error => gain_error_tb,
	gain_lock => gain_lock_tb,
	phase_error => phase_error_tb,
	phase_lock => phase_lock_tb,
	corrected_x1 => corrected_x1_tb,
	corrected_y1 => corrected_y1_tb
	);

		 
--Read I and Q from a text file created by MATLAB.


--type file_type is file of element_type;
--
--the read and endfile operations are implicitly declared as
--
--procedure read ( file f : file_type;  value : out element_type );
--function endfile ( file f : file_type ) return boolean;



READ_I_Q_SAMPLES: process (clk_tb) is

--read input data into process using the readline technique
file I_data : text open READ_MODE is "I_data_octave"; 
file Q_data : text open READ_MODE is "Q_data_octave"; 
variable incoming : line;


variable local_x1 : real;	
variable local_y1 : real; 
variable int_x1 : integer;
variable returned_x1 : signed(31 downto 0);  --need to parameterize this 
variable int_y1 : integer;
variable returned_y1 : signed(31 downto 0);  --need to parameterize this

begin 
	
	if (clk_tb'event and clk_tb = '1') then

		if (not endfile(I_data) and not endfile(Q_data)) then
			
			readline(I_data, incoming);  --read in the first line.
			read(incoming, local_x1);  --get the real value from the first line
			report "Reading " & real'image(local_x1) & " from I_data.";
			local_x1 := local_x1/(1.11); --model AGC
			report "AGC applied. Result: " & real'image(local_x1) & ".";
			int_x1 := integer(trunc(local_x1*((2.0**31.0)-1.0)));  --scaled
			report "Converted real I_data to the integer " & integer'image(int_x1) & ".";
			returned_x1 := (to_signed(int_x1, 32));
			x1_tb <= returned_x1;
			
			readline(Q_data, incoming);  --read in the first line.
			read(incoming, local_y1);  --get the real value from the first line
			report "Reading " & real'image(local_y1) & " from Q_data.";
			local_y1 := local_y1/(1.11); --model AGC
			report "AGC applied. Result: " & real'image(local_y1) & ".";
			int_y1 := integer(trunc(local_y1*((2.0**31.0)-1.0)));  --scaled
			report "Converted real Q_data to the integer " & integer'image(int_y1) & ".";
			returned_y1 := (to_signed(int_y1, 32));
			y1_tb <= returned_y1;
			
		else
			file_close(I_data);
			file_close(Q_data);
		end if;
	end if;	
end process READ_I_Q_SAMPLES;



COMPARE_RESULTS : process (clk_tb) is

--compare process output with data file using the readline technique
file phase_error : text open READ_MODE is "phase_error_estimate_octave";
file gain_error : text open READ_MODE is "gain_error_estimate_octave";
variable incoming : line;
variable filter_delay : natural := 0;

variable local_phase_error : real;
variable int_phase_error : integer;
variable octave_phase_error : signed(31 downto 0); 
variable local_gain_error : real;
variable int_gain_error : integer;
variable octave_gain_error : signed(31 downto 0);

begin
	if (clk_tb'event and clk_tb = '1') then
		if filter_delay > 3 then
			if (not endfile(phase_error) and not endfile(gain_error)) then
				--read in a result and compare with testbench result
				readline(phase_error, incoming);  --read in the first line.
				read(incoming, local_phase_error);  --get the real value from the first line
				report "Phase error from model: " & real'image(local_phase_error) & ".";
				int_phase_error := integer(trunc(local_phase_error*((2.0**31.0)-1.0)));  --scaled
				report "Converted real phase_error to the integer " & integer'image(int_phase_error) & ".";
				octave_phase_error := (to_signed(int_phase_error, 32));
				--does the phase error from the block match octave_phase_error?
				
				readline(gain_error, incoming);  --read in the first line.
				read(incoming, local_gain_error);  --get the real value from the first line
				report "Gain error from model: " & real'image(local_gain_error) & ".";
				int_gain_error := integer(trunc(local_gain_error*((2.0**31.0)-1.0)));  --scaled
				report "Converted real gain_error to the integer " & integer'image(int_gain_error) & ".";
				octave_gain_error := (to_signed(int_gain_error, 32));
				--does the gain error from the block match octave_gain_error?
				
				
				
			else
--				file_close(phase_error);
--				file_close(gain_error);
			end if;
		else
			filter_delay := filter_delay + 1;
		end if;
	end if;
end process COMPARE_RESULTS;






DRIVE_CLOCK:process
begin 
	wait for 50 ns;
	clk_tb <= not clk_tb;
	clk_tb_delayed <= not clk_tb_delayed after 1 ns;
end process;

end IQGainPhaseCorrection_testbench_read;