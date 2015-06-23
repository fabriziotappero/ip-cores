library ieee;
use ieee.std_logic_1164.all;
use ieee.math_real.all;
use ieee.numeric_std.all;
use work.normal_distribution_random_noise.all;
use work.create_sample.all;

entity IQGainPhaseCorrection_testbench is
end entity;





--The create architecture creates I and Q samples programmatically
--using trigonometric identities. It's supported by two packages, 
--normal_distribution_random_noise and create_sample. create_sample
--needs normal_distribution_random_noise in order to add normally
--distributed noise to the sample. 

architecture IQGainPhaseCorrection_testbench_create of IQGainPhaseCorrection_testbench is

--declare the DUT as a component.
component IQGainPhaseCorrection is
	generic(width :natural);
	port(
	clk				:in std_logic;
	x1				:in signed(width downto 0);
	y1				:in signed(width downto 0);
	gain_error		:out signed(width downto 0);
	gain_lock		:out bit;
	phase_error		:out signed(width downto 0);
	phase_lock		:out bit;
	corrected_x1	:out signed(width downto 0);
	corrected_y1	:out signed(width downto 0)
	);
	end component;

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
	width => 31
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

		 
--create I and Q. MTreseler says, "sin in vhdl I use use ieee.math_real.all and cast to integer."

CREATE_I_Q_SAMPLES: process (clk_tb) is
--for both I and Q
variable n_dat : integer := 0;
variable freq : real := 0.03; --relative frequency
variable sgma : real :=0.01; --sigma of noise
variable amplitude : real := 1.0; --amplitude
--for Q
variable e1 : real := 0.1; --gain error
variable a1 : real := (10.0*math_pi)/180.0; --phase error of 10 degrees

begin
	if (clk_tb'event and clk_tb = '1') then
		x1_tb <= create_I_sample(n_dat, freq, sgma, amplitude, 31);
		y1_tb <= create_Q_sample(n_dat, freq, sgma, amplitude, 31, e1, a1);
		n_dat := n_dat + 1;
	end if;
end process CREATE_I_Q_SAMPLES;	



DRIVE_CLOCK:process
begin 
	wait for 50 ns;
	clk_tb <= not clk_tb;
	clk_tb_delayed <= not clk_tb_delayed after 1 ns;
end process;

end IQGainPhaseCorrection_testbench_create;	





                              