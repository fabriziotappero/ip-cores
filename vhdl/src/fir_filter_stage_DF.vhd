---------------------------------------------------------------------------------------------------
--! @file
--! @brief This is the top-level design for a direct-form FIR digital filter.			\n
--! @details It instantiate the three major components for constructing a digital filter such as;\n
--! adder (adder_gen), multiplier (multiplier_gen), and delay (delay_gen).			\n
--! The top-level is a structural description in a generic/scalable form.			\n
--! The filter coefficients and the quantization bit width should be edited/pasted		\n
--! into the fir_pkg.vhd. The filter coefficients should be given in integer format.		\n
--! Design specs:										\n
--! Unsigned single/multi-bit input (fir_in)							\n
--! Signed multi-bit output (fir_out)								\n
--! Active high asynchronous reset  (fir_clr)							\n
--! Rising edge clock (fir_clk)									\n
--
--! @image html firDF.png "Direct-form FIR Filter Structure" 
--
--! @author Ahmed Shahein
--! @email ahmed.shahein@ieee.org
--! @date 04.2012
---------------------------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;
USE ieee.std_logic_unsigned.all;
USE work.fir_pkg.all;

ENTITY fir_filter_stage_DF IS
  port (fir_clk 	: in  std_logic; 			--! Rising edge clock
  	fir_clr 	: in  std_logic;			--! Active high asynchronous reset
        fir_in          : in  std_logic_vector(0 downto 0); 	--! Unsigned single/multi-bit input
        fir_out         : out std_logic_vector(14 downto 0));	--! Signed multi-bit output
END ENTITY fir_filter_stage_DF;

--
ARCHITECTURE struct OF fir_filter_stage_DF IS
-- COMPONENT DECLARATION
component multiplier_gen
    generic (multi_width_const : natural;
             multi_width_in    : natural);
    port (multiplier_const  : in std_logic_vector(multi_width_const-1 downto 0);
          multiplier_in     : in std_logic_vector(multi_width_in-1 downto 0);
          multiplier_out    : out std_logic_vector((multi_width_const+multi_width_in)+1 downto 0));
end component;

component adder_gen
  generic (add_width : natural);
    port (add_a_in : in std_logic_vector(add_width-1 downto 0);
          add_b_in : in std_logic_vector(add_width-1 downto 0);
          add_out  : out std_logic_vector(add_width-1 downto 0));
end component;

component delay_gen
    generic (delay_width : natural);
    port (clk, clr  : in  std_logic;
          delay_in  : in  std_logic_vector(delay_width-1 downto 0);
          delay_out : out std_logic_vector(delay_width-1 downto 0));
end component;

-- CONSTANT DECLARATION
constant coeff 		: int_vector 	:= fir_coeff_thirdstage;	--! Filter coefficients defined in the fir_pkg.vhd
constant width_in    	: natural  	:= fir_in'length;		--! Input bit-width
constant width_out   	: natural  	:= fir_out'length;		--! Output bit-width
constant width_const 	: positive 	:= quantization;		--! Quantization bit-width defined in the fir_pkg.vhd
constant order       	: natural  	:= coeff'length;		--! Filter length

-- SIGNAL DECLARATION
signal multi_add   	: std_logic_vector(order*width_out-1 downto 0);		--! Internal signal holding multiplier's outputs and adder's inputs
signal add_add   	: std_logic_vector((order-1)*width_out-1 downto 0);	--! Internal signal holding preced adder output and proceed adder input
signal delay_multi   	: std_logic_vector((order-1)*width_in-1 downto 0);	--! Internal signal holding delay's output and multiplier's inputs

BEGIN
 
COEFFMULTIs: for i in 0 to order-1 generate			--! Generate the filter multipliers set 
    FirstMULT: if i = 0 generate
    MULTI: multiplier_gen
      generic map(multi_width_const => width_const,
               multi_width_in => width_in)
    	port map(
    		multiplier_const  	=> conv_std_logic_vector(coeff(i), width_const),
          	multiplier_in     	=> fir_in,
          	multiplier_out    	=> multi_add((i+1)*width_out-1 downto i*width_out)
	  	);		    
          end generate;
  InterMULTs: if i > 0 generate
  MULTIs: multiplier_gen
    	generic map(multi_width_const => width_const,
             multi_width_in => width_in)
    	port map(
    		multiplier_const  	=> conv_std_logic_vector(coeff(i), width_const),
         	multiplier_in     	=> delay_multi(i*width_in-1 downto (i-1)*width_in),
          	multiplier_out    	=> multi_add((i+1)*width_out-1 downto i*width_out)
	  	);  
       end generate;
      end generate;
            
  COEFFDELAY: for i in 1 to order-1 generate 			--! Generate the filter delays set 
  DELAY:  if i = 1 generate
  FirstDELAY: delay_gen
    	generic map(delay_width => width_in)
  	port map(
    		clr   		=> fir_clr,
    		delay_in  	=> fir_in,
    		delay_out 	=> delay_multi(i*width_in-1 downto (i-1)*width_in),
    		clk   		=> fir_clk
    		);  
        end generate; 
  InterDElAYs: if i > 1 generate 
  DELAYs:  delay_gen	  
  	generic map(delay_width => width_in)
  	port map(
   		clr   		=> fir_clr,
    		delay_in  	=> delay_multi((i-1)*width_in-1 downto (i-2)*width_in),
    		delay_out 	=> delay_multi(i*width_in-1 downto (i-1)*width_in),
    		clk   		=> fir_clk
    		); 	  
        end generate; 
      end generate;         
  
  COEFFADD: for i in 1 to order-1 generate 			--! Generate the filter adders set 
  FirstADDER: if i = 1 generate          
  ADDER0: adder_gen
  	generic map(add_width => width_out)
	port map( 
		add_a_in 	=> multi_add((i+1)*width_out-1 downto i*width_out), -- from multipliers
		add_b_in 	=> multi_add(i*width_out-1 downto (i-1)*width_out),
		add_out 	=> add_add(i*width_out-1 downto (i-1)*width_out)
		);	  
        end generate;
  InterADDER: if i > 1 generate          
  ADDERs: adder_gen
	generic map(add_width => width_out)
	port map( 
		add_a_in 	=> multi_add((i+1)*width_out-1 downto i*width_out), -- from multipliers
		add_b_in 	=> add_add((i-1)*width_out-1 downto (i-2)*width_out),
		add_out 	=> add_add(i*width_out-1 downto (i-1)*width_out)
		);	  
        end generate;
      end generate; 

fir_out <= add_add((order-1)*width_out-1 downto (order-1)*width_out-width_out);
            
END ARCHITECTURE struct;
