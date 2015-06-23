-- Copyright (C) 1991-2006 Altera Corporation
-- Your use of Altera Corporation's design tools, logic functions 
-- and other software and tools, and its AMPP partner logic 
-- functions, and any output files any of the foregoing 
-- (including device programming or simulation files), and any 
-- associated documentation or information are expressly subject 
-- to the terms and conditions of the Altera Program License 
-- Subscription Agreement, Altera MegaCore Function License 
-- Agreement, or other applicable license agreement, including, 
-- without limitation, that your use is for the sole purpose of 
-- programming logic devices manufactured by Altera and sold by 
-- Altera or its authorized distributors.  Please refer to the 
-- applicable agreement for further details.

-- *****************************************************************************
-- This file contains a Vhdl test bench with test vectors .The test vectors     
-- are exported from a vector file in the Quartus Waveform Editor and apply to  
-- the top level entity of the current Quartus project .The user can use this   
-- testbench to simulate his design using a third-party simulation tool .       
-- *****************************************************************************
-- Generated on "12/14/2006 19:48:14"
                                                                        
-- Vhdl Self-Checking Test Bench (with test vectors) for design :       marca
-- 
-- Simulation tool : 3rd Party
-- 

LIBRARY ieee;                                               
USE ieee.std_logic_1164.all;                                

LIBRARY STD;                                                            
USE STD.textio.ALL;                                                     

PACKAGE marca_vhd_tb_types IS
-- input port types                                                       
SUBTYPE i1_type IS STD_LOGIC;
SUBTYPE i2_type IS STD_LOGIC_VECTOR(1 DOWNTO 0);
SUBTYPE i3_type IS STD_LOGIC;
-- output port types                                                      
SUBTYPE o1_type IS STD_LOGIC_VECTOR(1 DOWNTO 0);
-- output port names                                                     
CONSTANT o1_name : STRING (1 TO 7) := "ext_out";
-- n(outputs)                                                            
CONSTANT o_num : INTEGER := 1;
-- mismatches vector type                                                
TYPE mmvec IS ARRAY (0 to (o_num - 1)) OF INTEGER;
-- exp o/ first change track vector type                                     
TYPE trackvec IS ARRAY (1 to o_num) OF BIT;
-- sampler type                                                            
SUBTYPE sample_type IS STD_LOGIC;                                          
-- utility functions                                                     
FUNCTION std_logic_to_char (a: STD_LOGIC) RETURN CHARACTER;              
FUNCTION std_logic_vector_to_string (a: STD_LOGIC_VECTOR) RETURN STRING; 
PROCEDURE write (l:INOUT LINE; value:IN STD_LOGIC; justified: IN SIDE:= RIGHT; field:IN WIDTH:=0);                                               
PROCEDURE write (l:INOUT LINE; value:IN STD_LOGIC_VECTOR; justified: IN SIDE:= RIGHT; field:IN WIDTH:=0);                                        
PROCEDURE throw_error(output_port_name: IN STRING; expected_value : IN STD_LOGIC; real_value : IN STD_LOGIC);                                   
PROCEDURE throw_error(output_port_name: IN STRING; expected_value : IN STD_LOGIC_VECTOR; real_value : IN STD_LOGIC_VECTOR);                     

END marca_vhd_tb_types;

PACKAGE BODY marca_vhd_tb_types IS
        FUNCTION std_logic_to_char (a: STD_LOGIC)  
                RETURN CHARACTER IS                
        BEGIN                                      
        CASE a IS                                  
         WHEN 'U' =>                               
          RETURN 'U';                              
         WHEN 'X' =>                               
          RETURN 'X';                              
         WHEN '0' =>                               
          RETURN '0';                              
         WHEN '1' =>                               
          RETURN '1';                              
         WHEN 'Z' =>                               
          RETURN 'Z';                              
         WHEN 'W' =>                               
          RETURN 'W';                              
         WHEN 'L' =>                               
          RETURN 'L';                              
         WHEN 'H' =>                               
          RETURN 'H';                              
         WHEN '-' =>                               
          RETURN 'D';                              
        END CASE;                                  
        END;                                       

        FUNCTION std_logic_vector_to_string (a: STD_LOGIC_VECTOR)       
                RETURN STRING IS                                        
        VARIABLE result : STRING(1 TO a'LENGTH);                        
        VARIABLE j : NATURAL := 1;                                      
        BEGIN                                                           
                FOR i IN a'RANGE LOOP                                   
                        result(j) := std_logic_to_char(a(i));           
                        j := j + 1;                                     
                END LOOP;                                               
                RETURN result;                                          
        END;                                                            

        PROCEDURE write (l:INOUT LINE; value:IN STD_LOGIC; justified: IN SIDE:=RIGHT; field:IN WIDTH:=0) IS 
        BEGIN                                                           
                write(L,std_logic_to_char(VALUE),JUSTIFIED,field);      
        END;                                                            
                                                                        
        PROCEDURE write (l:INOUT LINE; value:IN STD_LOGIC_VECTOR; justified: IN SIDE:= RIGHT; field:IN WIDTH:=0) IS                           
        BEGIN                                                               
                write(L,std_logic_vector_to_string(VALUE),JUSTIFIED,field); 
        END;                                                                

        PROCEDURE throw_error(output_port_name: IN STRING; expected_value : IN STD_LOGIC; real_value : IN STD_LOGIC) IS                               
        VARIABLE txt : LINE;                                              
        BEGIN                                                             
        write(txt,string'("ERROR! Vector Mismatch for output port "));  
        write(txt,output_port_name);                                      
        write(txt,string'(" :: @time = "));                             
        write(txt,NOW);                                                   
        write(txt,string'(", Expected value = "));                      
        write(txt,expected_value);                                        
        write(txt,string'(", Real value = "));                          
        write(txt,real_value);                                            
        writeline(output,txt);                                            
        END;                                                              

        PROCEDURE throw_error(output_port_name: IN STRING; expected_value : IN STD_LOGIC_VECTOR; real_value : IN STD_LOGIC_VECTOR) IS                 
        VARIABLE txt : LINE;                                              
        BEGIN                                                             
        write(txt,string'("ERROR! Vector Mismatch for output port "));  
        write(txt,output_port_name);                                      
        write(txt,string'(" :: @time = "));                             
        write(txt,NOW);                                                   
        write(txt,string'(", Expected value = "));                      
        write(txt,expected_value);                                        
        write(txt,string'(", Real value = "));                          
        write(txt,real_value);                                            
        writeline(output,txt);                                            
        END;                                                              

END marca_vhd_tb_types;

LIBRARY ieee;                                               
USE ieee.std_logic_1164.all;                                

USE WORK.marca_vhd_tb_types.ALL;                                         

ENTITY marca_vhd_sample_tst IS
PORT (
	s1 : IN i1_type;
	s2 : IN i2_type;
	s3 : IN i3_type;
	sampler : OUT sample_type
	);
END marca_vhd_sample_tst;

ARCHITECTURE sample_arch OF marca_vhd_sample_tst IS
SIGNAL clk : sample_type := '1';
BEGIN
t_prcs_sample : PROCESS ( s1 , s2 , s3 )
BEGIN
	IF (NOW > 0 ps) AND (NOW < 850000000 ps) THEN
		clk <= NOT clk ;
	END IF;
END PROCESS t_prcs_sample;
sampler <= clk;
END sample_arch;

LIBRARY ieee;                                               
USE ieee.std_logic_1164.all;                                

LIBRARY STD;                                                            
USE STD.textio.ALL;                                                     

USE WORK.marca_vhd_tb_types.ALL;                                         

ENTITY marca_vhd_check_tst IS 
GENERIC (
	debug_tbench : BIT := '0'
);
PORT (
	o1 : IN o1_type;
	sampler : IN sample_type
);
END marca_vhd_check_tst;
ARCHITECTURE ovec_arch OF marca_vhd_check_tst IS
SIGNAL t_sig_o1_expected,t_sig_o1_expected_prev,t_sig_o1_prev : o1_type;

SIGNAL trigger : BIT := '0';
SIGNAL trigger_e : BIT := '0';
SIGNAL trigger_r : BIT := '0';
SIGNAL trigger_i : BIT := '0';
SIGNAL num_mismatches : mmvec := (OTHERS => 0);

BEGIN

-- Update history buffers  expected /o
t_prcs_update_o_expected_hist : PROCESS (trigger) 
BEGIN
	t_sig_o1_expected_prev <= t_sig_o1_expected;
END PROCESS t_prcs_update_o_expected_hist;


-- Update history buffers  real /o
t_prcs_update_o_real_hist : PROCESS (trigger) 
BEGIN
	t_sig_o1_prev <= o1;
END PROCESS t_prcs_update_o_real_hist;


-- expected ext_out[1]
t_prcs_ext_out_1: PROCESS
BEGIN
	t_sig_o1_expected(1) <= '0';
	WAIT FOR 93383521 ps;
	t_sig_o1_expected(1) <= '1';
	WAIT FOR 100000 ps;
	t_sig_o1_expected(1) <= '0';
	WAIT FOR 95600000 ps;
	t_sig_o1_expected(1) <= '1';
	WAIT FOR 100000 ps;
	t_sig_o1_expected(1) <= '0';
	WAIT FOR 95050000 ps;
	t_sig_o1_expected(1) <= '1';
	WAIT FOR 100000 ps;
	t_sig_o1_expected(1) <= '0';
	WAIT FOR 95600000 ps;
	t_sig_o1_expected(1) <= '1';
	WAIT FOR 100000 ps;
	t_sig_o1_expected(1) <= '0';
WAIT;
END PROCESS t_prcs_ext_out_1;
-- expected ext_out[0]
t_prcs_ext_out_0: PROCESS
BEGIN
	t_sig_o1_expected(0) <= '1';
	WAIT FOR 387433530 ps;
	t_sig_o1_expected(0) <= '0';
	WAIT FOR 8800000 ps;
	FOR i IN 1 TO 3
	LOOP
		t_sig_o1_expected(0) <= '1';
		WAIT FOR 17600000 ps;
		t_sig_o1_expected(0) <= '0';
		WAIT FOR 17600000 ps;
	END LOOP;
	t_sig_o1_expected(0) <= '1';
	WAIT FOR 8800000 ps;
	FOR i IN 1 TO 2
	LOOP
		t_sig_o1_expected(0) <= '0';
		WAIT FOR 17600000 ps;
		t_sig_o1_expected(0) <= '1';
		WAIT FOR 17600000 ps;
	END LOOP;
	t_sig_o1_expected(0) <= '0';
	WAIT FOR 8800000 ps;
	t_sig_o1_expected(0) <= '1';
	WAIT FOR 8800000 ps;
	t_sig_o1_expected(0) <= '0';
	WAIT FOR 26400000 ps;
	FOR i IN 1 TO 2
	LOOP
		t_sig_o1_expected(0) <= '1';
		WAIT FOR 17600000 ps;
		t_sig_o1_expected(0) <= '0';
		WAIT FOR 17600000 ps;
	END LOOP;
	t_sig_o1_expected(0) <= '1';
	WAIT FOR 8800000 ps;
	t_sig_o1_expected(0) <= '0';
	WAIT FOR 8800000 ps;
	t_sig_o1_expected(0) <= '1';
	WAIT FOR 8800000 ps;
	t_sig_o1_expected(0) <= '0';
	WAIT FOR 35200000 ps;
	t_sig_o1_expected(0) <= '1';
WAIT;
END PROCESS t_prcs_ext_out_0;

-- Set trigger on real/expected o/ pattern changes                        

t_prcs_trigger_e : PROCESS(t_sig_o1_expected)
BEGIN
	trigger_e <= NOT trigger_e;
END PROCESS t_prcs_trigger_e;

t_prcs_trigger_r : PROCESS(o1)
BEGIN
	trigger_r <= NOT trigger_r;
END PROCESS t_prcs_trigger_r;


t_prcs_selfcheck : PROCESS
VARIABLE i : INTEGER := 1;
VARIABLE txt : LINE;

VARIABLE last_o1_exp : o1_type := (OTHERS => 'U');

VARIABLE on_first_change : trackvec := "1";
BEGIN

WAIT UNTIL (sampler'LAST_VALUE = '1'OR sampler'LAST_VALUE = '0')
	AND sampler'EVENT;
IF (debug_tbench = '1') THEN
	write(txt,string'("Scanning pattern "));
	write(txt,i);
	writeline(output,txt);
	write(txt,string'("| expected "));write(txt,o1_name);write(txt,string'(" = "));write(txt,t_sig_o1_expected_prev);
	writeline(output,txt);
	write(txt,string'("| real "));write(txt,o1_name);write(txt,string'(" = "));write(txt,t_sig_o1_prev);
	writeline(output,txt);
	i := i + 1;
END IF;
IF ( t_sig_o1_expected_prev /= "XX" ) AND (t_sig_o1_expected_prev /= "UU" ) AND (t_sig_o1_prev /= t_sig_o1_expected_prev) AND (
	(t_sig_o1_expected_prev /= last_o1_exp) OR
	(on_first_change(1) = '1')
		) THEN
	throw_error("ext_out",t_sig_o1_expected_prev,t_sig_o1_prev);
	num_mismatches(0) <= num_mismatches(0) + 1;
	on_first_change(1) := '0';
	last_o1_exp := t_sig_o1_expected_prev;
END IF;
    trigger_i <= NOT trigger_i;
END PROCESS t_prcs_selfcheck;


t_prcs_trigger_res : PROCESS(trigger_e,trigger_i,trigger_r)
BEGIN
	trigger <= trigger_i XOR trigger_e XOR trigger_r;
END PROCESS t_prcs_trigger_res;

t_prcs_endsim : PROCESS
VARIABLE txt : LINE;
VARIABLE total_mismatches : INTEGER := 0;
BEGIN
WAIT FOR 850000000 ps;
total_mismatches := num_mismatches(0);
IF (total_mismatches = 0) THEN                                              
        write(txt,string'("Simulation passed !"));                        
        writeline(output,txt);                                              
ELSE                                                                        
        write(txt,total_mismatches);                                        
        write(txt,string'(" mismatched vectors : Simulation failed !"));  
        writeline(output,txt);                                              
END IF;                                                                     
WAIT;
END PROCESS t_prcs_endsim;

END ovec_arch;

LIBRARY ieee;                                               
USE ieee.std_logic_1164.all;                                

LIBRARY STD;                                                            
USE STD.textio.ALL;                                                     

USE WORK.marca_vhd_tb_types.ALL;                                         

ENTITY marca_vhd_vec_tst IS
END marca_vhd_vec_tst;
ARCHITECTURE marca_arch OF marca_vhd_vec_tst IS
-- constants                                                 
-- signals                                                   
SIGNAL t_sig_clock : STD_LOGIC;
SIGNAL t_sig_ext_in : STD_LOGIC_VECTOR(1 DOWNTO 0);
SIGNAL t_sig_ext_out : STD_LOGIC_VECTOR(1 DOWNTO 0);
SIGNAL t_sig_ext_reset : STD_LOGIC;
SIGNAL t_sig_sampler : sample_type;

COMPONENT marca
	PORT (
	clock : IN STD_LOGIC;
	ext_in : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
	ext_out : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
	ext_reset : IN STD_LOGIC
	);
END COMPONENT;
COMPONENT marca_vhd_check_tst
PORT (
	o1 : IN o1_type;
	sampler : IN sample_type
);
END COMPONENT;
COMPONENT marca_vhd_sample_tst
PORT (
	s1 : IN i1_type;
	s2 : IN i2_type;
	s3 : IN i3_type;
	sampler : OUT sample_type
	);
END COMPONENT;
BEGIN
	i1 : marca
	PORT MAP (
-- list connections between master ports and signals
	clock => t_sig_clock,
	ext_in => t_sig_ext_in,
	ext_out => t_sig_ext_out,
	ext_reset => t_sig_ext_reset
	);

-- clock
t_prcs_clock: PROCESS
BEGIN
LOOP
	t_sig_clock <= '0';
	WAIT FOR 25000 ps;
	t_sig_clock <= '1';
	WAIT FOR 25000 ps;
	IF (NOW >= 850000000 ps) THEN WAIT; END IF;
END LOOP;
END PROCESS t_prcs_clock;

-- ext_reset
t_prcs_ext_reset: PROCESS
BEGIN
	t_sig_ext_reset <= '0';
	WAIT FOR 100000 ps;
	t_sig_ext_reset <= '1';
WAIT;
END PROCESS t_prcs_ext_reset;
-- ext_in[1]
t_prcs_ext_in_1: PROCESS
BEGIN
	t_sig_ext_in(1) <= '0';
WAIT;
END PROCESS t_prcs_ext_in_1;
-- ext_in[0]
t_prcs_ext_in_0: PROCESS
BEGIN
	t_sig_ext_in(0) <= '1';
	WAIT FOR 8680000 ps;
	t_sig_ext_in(0) <= '0';
	WAIT FOR 8680000 ps;
	t_sig_ext_in(0) <= '1';
	WAIT FOR 8680000 ps;
	t_sig_ext_in(0) <= '0';
	WAIT FOR 26040000 ps;
	t_sig_ext_in(0) <= '1';
	WAIT FOR 17360000 ps;
	t_sig_ext_in(0) <= '0';
	WAIT FOR 17360000 ps;
	t_sig_ext_in(0) <= '1';
	WAIT FOR 17360000 ps;
	t_sig_ext_in(0) <= '0';
	WAIT FOR 17360000 ps;
	t_sig_ext_in(0) <= '1';
	WAIT FOR 8680000 ps;
	t_sig_ext_in(0) <= '0';
	WAIT FOR 17360000 ps;
	t_sig_ext_in(0) <= '1';
	WAIT FOR 17360000 ps;
	t_sig_ext_in(0) <= '0';
	WAIT FOR 17360000 ps;
	t_sig_ext_in(0) <= '1';
	WAIT FOR 17360000 ps;
	t_sig_ext_in(0) <= '0';
	WAIT FOR 8680000 ps;
	t_sig_ext_in(0) <= '1';
	WAIT FOR 17360000 ps;
	t_sig_ext_in(0) <= '0';
	WAIT FOR 17360000 ps;
	t_sig_ext_in(0) <= '1';
	WAIT FOR 17360000 ps;
	t_sig_ext_in(0) <= '0';
	WAIT FOR 17360000 ps;
	t_sig_ext_in(0) <= '1';
	WAIT FOR 17360000 ps;
	t_sig_ext_in(0) <= '0';
	WAIT FOR 17360000 ps;
	t_sig_ext_in(0) <= '1';
	WAIT FOR 8680000 ps;
	t_sig_ext_in(0) <= '0';
	WAIT FOR 8680000 ps;
	t_sig_ext_in(0) <= '1';
	WAIT FOR 8680000 ps;
	t_sig_ext_in(0) <= '0';
	WAIT FOR 34720000 ps;
	t_sig_ext_in(0) <= '1';
WAIT;
END PROCESS t_prcs_ext_in_0;
tb_sample : marca_vhd_sample_tst
PORT MAP (
	s1 => t_sig_clock,
	s2 => t_sig_ext_in,
	s3 => t_sig_ext_reset,
	sampler => t_sig_sampler
	);

tb_out : marca_vhd_check_tst
PORT MAP (
	o1 => t_sig_ext_out,
	sampler => t_sig_sampler
	);
END marca_arch;
