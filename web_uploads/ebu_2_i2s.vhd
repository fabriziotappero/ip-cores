library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;
entity ebu_2_i2s is 
					port(spdif_in			: in   std_logic;  --  entree spdif
						 nreset			    : in   std_logic;  --  remise a 0
						 clock,ref_clock			    : in   std_logic;  --  a speed clock
						 sync_start		    : out  std_ulogic;  --  apres detection de preambule B
						 preambule_l		: out  std_ulogic;  --  -decoded data
						 preambule_r		: out  std_ulogic;  --  -decoded data
						 v_ctrl			    : out  std_ulogic;  --  -decoded data
						 pll_v_setting	:	OUT std_logic_vector(8 downto 0);	-- PLL parameter V
		                 pll_r_setting	:	OUT std_logic_vector(6 downto 0);	-- PLL parameter R
		                 pll_s_setting	:	OUT std_logic_vector(2 downto 0);	-- PLL parameter S
			            pll_npd			:	OUT std_logic; 
						 copie_d            : out std_ulogic;   
						 lr	,scl,serial_out           : out  std_ulogic;  --  -decoded data
						 data_v ,fin            : out std_ulogic;
						 begin_block	    : out  std_ulogic  --  -decoded data
						-- sclk			    : out  std_logic_vector(6 downto 0)  --  -decoded data
						-- bit_en,demi_bit_en : out  std_logic --  -decoded data
						);
end entity;
architecture archi of ebu_2_i2s is 

constant v_24_576mhz 	   : std_logic_vector(8 downto 0) := "101111000";	
constant r_24_576mhz 	   : std_logic_vector(6 downto 0) := "0010111";
constant s_24_576mhz 	   : std_logic_vector(2 downto 0) := "100";

signal var1,var2,var3,var4,var5,var6,var7,vara,varb,varc,vard,vare,varf,varg   : std_ulogic;
signal sortie                          : std_ulogic; 
signal  high                           : std_ulogic := '1';  
signal n_spdif_in                      : std_ulogic; 
signal remise_0,n_remise_0             : std_ulogic ;
signal       s                         : std_ulogic_vector ( 7 downto 0):= "11111111";   
signal enable                          : std_ulogic;
signal level_0,n_level_0               : std_ulogic;
signal preambule_m,preambule_w         : std_ulogic;
type  etat is (value,preamb_b,preamb_w,preamb_m);
signal status                          : etat := preamb_b;
signal entier                          : integer range 0 to 56 := 0;
signal register_dat                    : std_ulogic_vector ( 55 downto 0);
signal donnee                          : std_ulogic_vector ( 31 downto 0);
signal dat                             : std_ulogic_vector ( 27 downto 0);
signal end_frame                       : std_ulogic;  
signal   data_valid                    : std_ulogic;  
signal   pair                          : std_ulogic;
signal  sub_frame                      : integer range 0 to 384; 
signal echantillon1,echantillon0       : std_ulogic;
signal i2s_cl,word_sel                 : std_ulogic:='1'; 
signal left_right                      : std_ulogic:='0';  
signal valid_word                      : std_ulogic:='0'; 
signal copie                           : std_ulogic:='0'; 
signal charge,block_wsel  				   : std_ulogic:='0';  	
signal data_i                          : integer range 0 to 4;
component dff port   (  d,clk,clrn     : in std_ulogic;
			           q          	   : out std_ulogic);
end component;			
begin 

pll_v_setting <= v_24_576mhz; -- to programm th pll
pll_r_setting <= r_24_576mhz; -- to programm th pll
pll_s_setting <= s_24_576mhz; -- to programm th pll
pll_npd<='1';
 

n_spdif_in <= not spdif_in;
n_remise_0 <= not remise_0;
n_level_0  <= not level_0;

echantillon1 <=  var1 and var2 and  not var3 ;
echantillon0 <=  vara and varb and  not varc ;


 
-- les dff pour les echantillonnages
--------------------------------------------------------------
dff1          : dff port map (   d      =>   spdif_in,
								 clk    =>   clock,
								 clrn   =>   n_remise_0,
								 q      =>   var1 
							);

dff2          : dff port map (   d      =>   var1,
								 clk    =>   clock,
								 clrn   =>   n_remise_0,
								 q      =>   var2 
							);


dff3          : dff port map (   d      =>   var2,
								 clk    =>   clock,
								 clrn   =>   n_remise_0,
								 q      =>   var3 
							);	

dff4          : dff port map (   d      =>   var3,
								 clk    =>   clock,
								 clrn   =>   n_remise_0,
								 q      =>   var4
							);	
dff5          : dff port map (   d      =>   var4,
								 clk    =>   clock,
								 clrn   =>   n_remise_0,
								 q      =>   var5 
							);

dff6          : dff port map (   d      =>   var5,
								 clk    =>   clock,
								 clrn   =>   n_remise_0,
								 q      =>   var6 
							);


dff7          : dff port map (   d      =>   var6,
								 clk    =>   clock,
								 clrn   =>   n_remise_0,
								 q      =>   var7 
							);	

dff8          : dff port map (   d      =>   var7,
								 clk    =>   clock,
								 clrn   =>   n_remise_0,
								 q      =>   remise_0 
							);	
							
--------------------------------------------------------------							
dffa          : dff port map (   d      =>   n_spdif_in,   
								 clk    =>   clock,         
								 clrn   =>   n_level_0,
								 q      =>   vara 
							);

dffb          : dff port map (   d      =>   vara,
								 clk    =>   clock,
								 clrn   =>   n_level_0,
								 q      =>   varb 
							);


dffc          : dff port map (   d      =>   varb,
								 clk    =>   clock,
								 clrn   =>   n_level_0,
								 q      =>   varc 
							);	
dffd          : dff port map (   d      =>   varc,
								 clk    =>   clock,          
								 clrn   =>   n_level_0,      
								 q      =>   vard         
							);	
dffe          : dff port map (   d      =>   vard,   
								 clk    =>   clock,         
								 clrn   =>   n_level_0,
								 q      =>   vare 
							);

dfff          : dff port map (   d      =>   vare,
								 clk    =>   clock,
								 clrn   =>   n_level_0,
								 q      =>   varf 
							);


dffg          : dff port map (   d      =>   varf,
								 clk    =>   clock,
								 clrn   =>   n_level_0,
								 q      =>   varg 
							);	
dffh          : dff port map (   d      =>   varg,
								 clk    =>   clock,          
								 clrn   =>   n_level_0,      
								 q      =>   level_0         
							);		                 								                        
----------------------------------------------------------------------------+													
-- here I charge a register of 8 bits ,each bit correpsond to the value     + 
-- of a haf period in spdif this one is sampled in the middle approximatlly +
----------------------------------------------------------------------------------------------------------------+
charge_preambule : process (nreset,clock,var1,var2,var3,vara,varb,varc)   -- detection du preambule 		  --+	
		    begin                                                                                             --+
		    if nreset = '0' then    s <= (others => '0');                                                     --+ 
		    elsif clock 'event and clock ='1' then if ( echantillon1 = '1' ) then s <= s( 6 downto 0) & '1';  --+
		                                           elsif ( echantillon0 = '1') then s <= s( 6 downto 0) & '0';--+
		                                           end if;                                                    --+ 
		   end if;                                                                                            --+
		   end process; 	                                                                                  --+
																											  --+
----------------------------------------------------------------------------------------------------------------+		
		
		
-- after detection of each preambule we put a signal to a high level
-- for approximatly a half period of spdif  

--------------------------------------------------------------------------------------------------------------------

preambule_i :   process (nreset,clock,s)                                
				begin
				if nreset = '0'  then enable <= '0' ;preambule_w <= '0'; preambule_m <= '0';
				elsif clock 'event and clock ='0'  
												then case s is 
														             when  "11101000"  => enable <= '1' ;	
														             when  "00010111"  => enable <= '1' ;
														             when  "11100010"  => preambule_m <= '1';
														             when  "00011101"  => preambule_m <= '1';
														             when  "11100100"  => preambule_w <= '1';
																	 when  "00011011" => preambule_w <= '1'; 
														             when others       => enable <= '0' ;preambule_w <= '0';
																						 preambule_m <= '0';
														end case; 
												
				end if;													
 				end process;	

---------------------------------------------------------------------------------------------------------------
-- the state machine contains four states three for preambules and one for value
-- so here we can more serious in respect of synchronism



state_machine     :process(nreset,clock,pair,preambule_w,preambule_m,enable)
				   begin
				   if nreset ='0' then status <= preamb_b;
				   elsif clock 'event and  clock = '1' then    case status is
				                                                     when    preamb_b => if   enable = '1' then status <= value;  end if ;
				                                                     when    preamb_w => if preambule_w = '1' then status <= value ; end if;  
				                                                     when    preamb_m => if preambule_m ='1' then status <= value;  end if;
				                                                     when    value    => if end_frame = '0' then if data_valid ='1' then if pair = '1' then status <= preamb_m; 
																											                              else status <= preamb_w;		 end if;
																											    end if;
																						 else if data_valid ='1' then  status <= preamb_b;end if;
																						end if;
				                                                                         
				 										   end case;	
				   end if;										
			       end process;
			
			
-- the process here is to determine when finishing on the status value then deteminte o wich 
-- we must go 
--            /  preamb_w
--     value < ---              or preamb_b
--			  \ preamb_m
--------------------------------------------------	

		
pros :process(nreset,clock,status,echantillon1,echantillon0,entier)    
      
		begin
		if nreset = '0'  or  status = preamb_b or status = preamb_w or status = preamb_m  then      entier <= 0;
		elsif clock 'event and clock ='1' then if  status = value  then if ( echantillon1 ='1' ) then register_dat <= register_dat( 54 downto 0) & '1';
		                                                                       if entier = 56 then entier <= 0; else entier <= entier +1;end if;
		 																	        	
		                                                              elsif ( echantillon0 ='1') then register_dat <= register_dat( 54 downto 0) & '0';
		                                                                       if entier = 56 then entier <= 0; else entier <= entier +1;end if;
																						
		                                                              end if;
		                                       end if; 
		end if;
		if clock 'event and clock ='1' then if entier = 56 and status = value then data_valid <= '1';
		                                   else data_valid <= '0';end if;
		end if; 
		
	   end process;
	
--------------------------------------------------------------------------------------	
--end of block one block is 192 frames so 384 sub_frames
--------------------------------------------------------------------------------------
	
	end_block  :process (data_valid,nreset,entier)  -- counts the numbers of sub-frames
               -- variable sub_frame : integer range 0 to 384;
					begin
			   if nreset='0'  or status = preamb_b  then sub_frame<=0;
			   elsif data_valid 'event and data_valid='1' then   pair <= not pair;
							if  sub_frame=384 then sub_frame<=0;
							else sub_frame <=sub_frame +1;end if;
			   end if;
			 
		       if (sub_frame =383  and entier = 56 ) then end_frame<='1';
			   else end_frame<='0';	end if;
		       end process;
		
		
-------------------------------------------------------------------------------+
-- Second entity in the same block code                                        +
-- why ? for the reason that i will use the status variable to generate signals+
-- the things that is not possible with two entity                             +
--                                                                             +
---------------------------------------------------------------------------------------------------------+
   i2s_clock    : process(clock,echantillon1,echantillon0)                                             --+
				--	variable a_bit : integer range 0 to 31;                                            --+
			     begin                                                                                 --+
     		     if nreset ='0' then i2s_cl <= '1';                                                    --+
			     elsif clock 'event and clock ='1' then if echantillon1= '1' then i2s_cl <= not i2s_cl;--+
													 elsif echantillon0 ='1' then i2s_cl <= not i2s_cl;--+
													end if;		                                       --+
								                                                                       --+
			    end if;                                                                                --+  
         	    end process;                                                                           --+
---------------------------------------------------------------------------------------------------------+   
-- this process generates an i2s clock in this case we have 3.072Mhz

---------------------------------------------------------------------------------------------------------+ 
 w_valid         : process(status,nreset,entier)
                   begin
						if nreset ='0' then valid_word <= '0'; 
						elsif clock 'event and clock = '1' then if status= value and entier = 55 then 	valid_word <= '1';end if;
						end if;					
                   end process;

--------------------------------------------------------
-- only needed signal for the state machine
-----------------------------------------------
number_bits : process(nreset,i2s_cl,status)
        
            begin
			if nreset ='0' or status = value then  data_i <= 0;
			elsif i2s_cl 'event and i2s_cl = '1' then if (status= preamb_b or status = preamb_m or status = preamb_w)
														then if data_i = 4 then data_i <= 0 ; else data_i <= data_i +1; end if;
			end if;		end if;
			end process;



-------------------------------------------------------
-- only needed signal for the state machine
-----------------------------------------------
decal_dat : process(nreset,i2s_cl,status)
            begin
			if nreset ='0' then charge <= '0';
			elsif i2s_cl 'event and i2s_cl = '1' then case status is 
																when   value    => charge <= '0';block_wsel<='0';
																when   preamb_b => if data_i = 3 then  charge <= '1' ; end if;
																					if data_i = 4 then  block_wsel <= '1' ; end if;
																when   preamb_w => if data_i = 3 then  charge <= '1' ; end if;
																					if data_i = 4 then  block_wsel <= '1' ; end if;
																when   preamb_m => if data_i = 3 then  charge <= '1' ; end if;
																					if data_i = 4 then  block_wsel <= '1' ; end if;	
												  end case;	
			end if;		
			end process;
-------------------------------------------------------
-- in each sub-frames a send 32 bit so we complete these bits with 
-- zeros and the first zero in only for the reason that I implemented 
-- a left justified protocol 
-- so to change the i2s format change this process only
-----------------------------------------------------------
datas                : process (nreset,i2s_cl,charge)                        --les datas a sortir 
						begin
						if nreset = '0' then donnee <= (others => '0' );
						elsif i2s_cl 'event and i2s_cl='0' then if   charge ='1' and valid_word= '1' then  
																					
																donnee(31 downto 0) <= "0000000" & dat(27 downto 4) & '0';
																					if block_wsel ='0' then	 word_sel <= not word_sel; end if;
                                                                           else  donnee(31 downto 0)  <= '0' & donnee(31 downto 1) ;  
																		   end if; 														
   					    end if;
					 end process;
------------------------------------------+
-- the registerd dat contains only the values sampled so need to know 
-- the values corresponding : a xor function can do this 				
--------------------------------------------------+
msb_first : process(nreset,charge)
			--variable I    : integer range 0 to 27;
			begin
			if nreset = '0' then dat <=( others => '0');
			elsif charge 'event and charge = '1' then  for I in 0 to 27 loop
												dat(I) <= register_dat(2*I) xor register_dat (2*I +1); 
												end loop;
			end if;								
			end process;					
					
--------------------------------------------------+
v_ctrl <= '1' when status = preamb_b else '0';
sync_start <= echantillon0;
lr <=  word_sel;
preambule_l<= preambule_m;
preambule_r <= valid_word;
--sclk <= CONV_STD_LOGIC_VECTOR(entier,7);	
data_v <= donnee(0) when status = value else '0' when status = value else '0';	
begin_block <= end_frame;
fin <= i2s_cl;	
copie_d <= block_wsel;
serial_out <= donnee(0);																						
end architecture;					