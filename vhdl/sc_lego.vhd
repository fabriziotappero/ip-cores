--
--
--  This file is a part of JOP, the Java Optimized Processor
--
--  Copyright (C) 2001-2008, Martin Schoeberl (martin@jopdesign.com)
--
--  This program is free software: you can redistribute it and/or modify
--  it under the terms of the GNU General Public License as published by
--  the Free Software Foundation, either version 3 of the License, or
--  (at your option) any later version.
--
--  This program is distributed in the hope that it will be useful,
--  but WITHOUT ANY WARRANTY; without even the implied warranty of
--  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--  GNU General Public License for more details.
--
--  You should have received a copy of the GNU General Public License
--  along with this program.  If not, see <http://www.gnu.org/licenses/>.
--


--
--      sc_lego.vhd
--
--      Motor and sensor interface for LEGO MindStorms
--      
--      Original author: Martin Schoeberl       martin@jopdesign.com
--      Author: Peter Hilber                    peter.hilber@student.tuwien.ac.at
--
--      address map:
--		see read and write processes
--
--
--      2005-12-22      adapted for SimpCon interface
--      2007-03-13      extended for Lego PCB
--
--      todo:
--
--


--
--	lego io
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.lego_pld_pack.all;
use work.lego_pack.all;

entity sc_lego is
    generic (addr_bits : integer;
             clk_freq : integer);

    port (
        clk		: in std_logic;
        reset	: in std_logic;

        -- SimpCon interface

        address		: in std_logic_vector(addr_bits-1 downto 0);
        wr_data		: in std_logic_vector(31 downto 0);
        rd, wr		: in std_logic;
        rd_data		: out std_logic_vector(31 downto 0);
        rdy_cnt		: out unsigned(1 downto 0);
		
		-- speaker
		
		speaker : out std_logic;
		
        -- motor stuff

        m0en : out std_logic;
        m0dir : out std_logic;
        m0break : out std_logic;
        m0dia : in std_logic;
        m0doa : out std_logic;
        m0dib : in std_logic;
        m0dob : out std_logic;

        m1en : out std_logic;
        m1dir : out std_logic;
        m1break : out std_logic;
        m1dia : in std_logic;
        m1doa : out std_logic;
        m1dib : in std_logic;
        m1dob : out std_logic;

        m2en : out std_logic;
        m2dir : out std_logic;
        m2break : out std_logic;

        -- sensor stuff
        
        s0di : in std_logic;
        s0do : out std_logic;
        s0pi : out std_logic;
        s1di : in std_logic;
        s1do : out std_logic;
        s1pi : out std_logic;
        s2di : in std_logic;
        s2do : out std_logic;
        s2pi : out std_logic;

        mic1do : out std_logic;
        mic1 : in std_logic;
        

		-- pld
		pld_strobe 		: out std_logic;
		pld_data		: inout std_logic;
		pld_clk			: out std_logic

        );
end sc_lego;

architecture rtl of sc_lego is
    -- settings for components
    constant adc_width               : integer := 9;

    -- settings for motor
    constant motor_dout_width : integer := 9;    
    constant duty_cycle_width        : integer := 14;
    
    constant ld_ratio_measure_to_pwm : integer := 4;   -- ld(bit width time/bit width time spent measuring)
    constant clkint_prescaler_width  : integer := 18;	
    constant counter_width           : integer := clkint_prescaler_width + ld_ratio_measure_to_pwm + 1;
    constant clksd_prescaler_width   : integer := clkint_prescaler_width - motor_dout_width;

	
	constant audio_input_width : integer := 8;


	-- pld	
	
    signal pld_out_pins : FORWARDED_PINS;
    signal pld_in_pins  : FORWARDED_PINS;

	-- signals
	
	signal sensor0_dout: std_logic_vector(adc_width-1 downto 0);
	signal sensor1_dout: std_logic_vector(adc_width-1 downto 0);
	signal sensor2_dout: std_logic_vector(adc_width-1 downto 0);

	-- motors
	
    signal motor0_state: 		lego_motor_state;
    signal motor0_duty_cycle: 	unsigned(duty_cycle_width-1 downto 0);
    signal motor0_measure:      std_logic;

	signal motor0_dout1: 	std_logic_vector(motor_dout_width-1 downto 0);
	signal motor0_dout2: 	std_logic_vector(motor_dout_width-1 downto 0);
	
	signal motor1_state: 		lego_motor_state;
    signal motor1_duty_cycle: 	unsigned(duty_cycle_width-1 downto 0);
    signal motor1_measure:      std_logic;

	signal motor1_dout1: 	std_logic_vector(motor_dout_width-1 downto 0);
	signal motor1_dout2: 	std_logic_vector(motor_dout_width-1 downto 0);
	
	signal motor2_state: 		lego_motor_state;
    signal motor2_duty_cycle: 	unsigned(duty_cycle_width-1 downto 0);
    signal motor2_measure:      std_logic;

	signal motor1_buf_bemf: 	std_logic_vector(motor_dout_width*2-1 downto 0);

	-- microphone

	signal micro_dout:			std_logic_vector(adc_width-1 downto 0);
	
	signal cmp_micro_counter: unsigned(clkint_prescaler_width-1 downto 0);
	signal cmp_micro_clksd: std_logic;
	signal cmp_micro_clkint: std_logic;
	
	-- speaker
	
	signal audio_input:			std_logic_vector(audio_input_width-1 downto 0);
begin

    rdy_cnt <= "00";	-- no wait states

--
--	The registered MUX is all we need for a SimpCon read.
--	The read data is stored in registered rd_data.
--
    read: process(clk, reset)
    begin

        if (reset='1') then
            rd_data <= (others => '0');
        elsif rising_edge(clk) then

            if rd='1' then
				rd_data <= (others => '0');
                -- that's our very simple address decoder
                case address(3 downto 0) is
					-- sensors
					when "0000" => 
						rd_data(adc_width*3-1 downto 0) <= sensor2_dout & sensor1_dout & sensor0_dout;
					-- microphone
					when "0001" =>
						rd_data(adc_width-1 downto 0) <= micro_dout;
					-- motor 0 back-emf
					when "0010" =>
						rd_data(motor_dout_width*2-1 downto 0) <= motor0_dout2 & motor0_dout1;
					-- motor 1 back-emf
					when "0011" =>
						rd_data(motor_dout_width*2-1 downto 0) <= motor1_dout2 & motor1_dout1;
					-- buttons
					when "0100" =>
						rd_data(3 downto 0) <= pld_in_pins(btn3) & pld_in_pins(btn2) & pld_in_pins(btn1) & pld_in_pins(btn0);
					-- digital inputs
					when "0101" =>
						rd_data(2 downto 0) <= pld_in_pins(i2) & pld_in_pins(i1) & pld_in_pins(i0);
					-- for future use
					when "0110" =>
						rd_data(9 downto 0) <= pld_in_pins(unused9) & pld_in_pins(unused8) & pld_in_pins(unused7) & 
												pld_in_pins(unused6) & pld_in_pins(unused5) & pld_in_pins(unused4) & 
												pld_in_pins(unused3) & pld_in_pins(unused2) & pld_in_pins(unused1) & 
												pld_in_pins(unused0);
					-- pld raw input
					when "0111" =>
						rd_data(20 downto 0) <= pld_in_pins;
					-- motor 0 back-emf
					when "1000" =>
						rd_data(motor_dout_width*2-1 downto 0) <= motor0_dout2 & motor0_dout1;
						motor1_buf_bemf <= motor1_dout2 & motor1_dout1;
					-- motor 1 back-emf
					when "1001" =>
						rd_data(motor_dout_width*2-1 downto 0) <= motor1_buf_bemf;
                	when others => 
                end case;
            end if;
        end if;

    end process;


--
--	SimpCon write is very simple
--
    write: process(clk, reset)

    begin

        if (reset='1') then
			pld_out_pins <= (others => '0');

            motor0_state      <= LEGO_MOTOR_STATE_OFF;
            motor0_duty_cycle <= (others => '0');
            motor0_measure    <= '0';		

            motor1_state      <= LEGO_MOTOR_STATE_OFF;
            motor1_duty_cycle <= (others => '0');
            motor1_measure    <= '0';			

            motor2_state      <= LEGO_MOTOR_STATE_OFF;
            motor2_duty_cycle <= (others => '0');
			motor2_measure 	  <= '0';

        elsif rising_edge(clk) then

            if wr='1' then

				case address(2 downto 0) is
				    -- leds
					when "000" =>
						pld_out_pins(led0) <= wr_data(0);
						pld_out_pins(led1) <= wr_data(1);
						pld_out_pins(led2) <= wr_data(2);
						pld_out_pins(led3) <= wr_data(3);
					-- motor 0
					when "001" =>
						motor0_state <= lego_motor_state(wr_data(lego_motor_state'high downto 0));
						motor0_duty_cycle <= unsigned(wr_data(lego_motor_state'high+1+(duty_cycle_width-1) downto lego_motor_state'high+1));
						motor0_measure <= wr_data((duty_cycle_width-1)+lego_motor_state'high+2);
					-- motor 1
					when "010" =>
						motor1_state <= lego_motor_state(wr_data(lego_motor_state'high downto 0));
						motor1_duty_cycle <= unsigned(wr_data(lego_motor_state'high+1+(duty_cycle_width-1) downto lego_motor_state'high+1));
						motor1_measure <= wr_data((duty_cycle_width-1)+lego_motor_state'high+2);
					-- motor 2
					when "011" =>
						motor2_state <= lego_motor_state(wr_data(lego_motor_state'high downto 0));
						motor2_duty_cycle <= unsigned(wr_data(lego_motor_state'high+1+(duty_cycle_width-1) downto lego_motor_state'high+1));
						-- no actual back-emf measurement available
						motor2_measure <= wr_data((duty_cycle_width-1)+lego_motor_state'high+2);
					-- for future use
					when "110" =>
						pld_out_pins(unused9) <= wr_data(9);
						pld_out_pins(unused8) <= wr_data(8);
						pld_out_pins(unused7) <= wr_data(7);
						pld_out_pins(unused6) <= wr_data(6);
						pld_out_pins(unused5) <= wr_data(5);
						pld_out_pins(unused4) <= wr_data(4);
						pld_out_pins(unused3) <= wr_data(3);
						pld_out_pins(unused2) <= wr_data(2);
						pld_out_pins(unused1) <= wr_data(1);
						pld_out_pins(unused0) <= wr_data(0);
						pld_out_pins(10 downto 4) <= "0000000";
					when "111" =>
						audio_input <= wr_data(audio_input_width-1 downto 0);
					when others =>
						null;
				end case;
            end if;

        end if;

    end process;
        

    cmp_pld_interface: entity work.pld_interface
        port map(
            clk => clk,
            reset => reset,
            out_pins => pld_out_pins,
            in_pins => pld_in_pins,
            pld_strobe => pld_strobe,
            pld_clk => pld_clk,
            data => pld_data);

	cmp_sensor0: entity work.lesens generic map (
        clk_freq => clk_freq
        )
		port map(
			clk => clk,
        	reset => reset,
			dout => sensor0_dout,
			sp => s0pi,
        	sdi => s0di,
			sdo => s0do);

	cmp_sensor1: entity work.lesens generic map (
        clk_freq => clk_freq
        )
		port map(
			clk => clk,
        	reset => reset,
			dout => sensor1_dout,
			sp => s1pi,
        	sdi => s1di,
			sdo => s1do);
			
	cmp_sensor2: entity work.lesens generic map (
        clk_freq => clk_freq
        )
		port map(
			clk => clk,
        	reset => reset,
			dout => sensor2_dout,
			sp => s2pi,
        	sdi => s2di,
			sdo => s2do);
				
	cmp_motor0: entity work.lego_motor
        generic map (
            duty_cycle_width        => duty_cycle_width,
            counter_width           => counter_width,
            ld_ratio_measure_to_pwm => ld_ratio_measure_to_pwm,
            clksd_prescaler_width   => clksd_prescaler_width,
            clkint_prescaler_width  => clkint_prescaler_width,
            dout_width              => motor_dout_width)
        port map (
            clk                     => clk,
            reset                   => reset,
            state                   => motor0_state,
            duty_cycle              => motor0_duty_cycle,
            measure                 => motor0_measure,
            dout_1                  => motor0_dout1,
            dout_2					=> motor0_dout2,
            men                     => m0en,
			mdir					=> m0dir,
			mbreak					=> m0break,
            mdia                    => m0dia,
            mdoa                    => m0doa,
            mdib                    => m0dib,
            mdob                    => m0dob);

	cmp_motor1: entity work.lego_motor
        generic map (
            duty_cycle_width        => duty_cycle_width,
            counter_width           => counter_width,
            ld_ratio_measure_to_pwm => ld_ratio_measure_to_pwm,
            clksd_prescaler_width   => clksd_prescaler_width,
            clkint_prescaler_width  => clkint_prescaler_width,
            dout_width              => motor_dout_width)
        port map (
            clk                     => clk,
            reset                   => reset,
            state                   => motor1_state,
            duty_cycle              => motor1_duty_cycle,
            measure                 => motor1_measure,
            dout_1                  => motor1_dout1,
            dout_2					=> motor1_dout2,
            men                     => m1en,
			mdir					=> m1dir,
			mbreak					=> m1break,
            mdia                    => m1dia,
            mdoa                    => m1doa,
            mdib                    => m1dib,
            mdob                    => m1dob);

	-- no back-emf measurement available for this motor due to lack of pins :(
	cmp_motor2: entity work.lego_motor
        generic map (
            duty_cycle_width        => duty_cycle_width,
            counter_width           => counter_width,
            ld_ratio_measure_to_pwm => ld_ratio_measure_to_pwm,
            clksd_prescaler_width   => clksd_prescaler_width,
            clkint_prescaler_width  => clkint_prescaler_width,
            dout_width              => motor_dout_width)
        port map (
            clk                     => clk,
            reset                   => reset,
            state                   => motor2_state,
            duty_cycle              => motor2_duty_cycle,
            measure                 => motor2_measure,
            --dout_1                => motor2_dout1,
            --dout_2				=> motor2_dout2,
            men                     => m2en,
			mdir					=> m2dir,
			mbreak					=> m2break,
            mdia                  	=> '0',
            --mdoa                  => m2doa,
            mdib                  	=> '0'
            --mdob                  => m2dob
			);
			
	-- XXX
	cmp_micro_count: process(clk, reset)
  	begin
    	if reset = '1' then
      		cmp_micro_counter <= (others => '0');
    	elsif rising_edge(clk) then
      		cmp_micro_counter <= cmp_micro_counter + 1;
    	end if;
  	end process;

  	cmp_micro_clksd <= '1' when (cmp_micro_counter(clksd_prescaler_width-1 downto 0) = 0) else '0';
  	cmp_micro_clkint <= '1' when (cmp_micro_counter(clkint_prescaler_width-1 downto 0) = 0) else '0';	
	
	cmp_micro: entity work.sigma_delta
    generic map (
      dout_width => adc_width)
    port map (
      clk    => clk,
      reset  => reset,
      clksd  => cmp_micro_clksd,
      clkint => cmp_micro_clkint,
      dout   => micro_dout,
      sdi    => mic1,
      sdo    => mic1do);

	cmp_audio: entity work.audio
	generic map (
		input_width => audio_input_width)
	port map (
		clk => clk,
		reset => reset,
		input => audio_input,
		output => speaker);

end rtl;
