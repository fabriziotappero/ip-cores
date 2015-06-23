-------------------------------------------------------------------------------
--
-- Title       : fp24_rambq_init_m1_pkg
-- Design      : fp24fftk
-- Author      : Kapitanov
-- Company     :
--
-------------------------------------------------------------------------------
--
-- Description :  ramb initialization for coe_rom: xilinx primitive RAMB16_S18_S18
--
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
--		(c) Copyright 2015 													 
--		Kapitanov.                                          				 
--		All rights reserved.                                                 
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

package	fp24_rambq_init_m1_pkg is
	component fp24_rambq_init_m1 is
	  generic ( 
	    fp_teylor	: boolean:=false
	  );
	  port(
   		doa  	: out std_logic_vector(47 downto 0);
   		dob  	: out std_logic_vector(47 downto 0);
--   		dopa 	: out std_logic_vector(5 downto 0);
--   		dopb 	: out std_logic_vector(5 downto 0);
	
	    addra 	: in std_logic_vector(9 downto 0);
	    addrb 	: in std_logic_vector(9 downto 0); 
		
	    clka  	: in std_ulogic;
	    clkb  	: in std_ulogic;
		
	    dia   	: in std_logic_vector(15 downto 0);
	    dib   	: in std_logic_vector(15 downto 0);
--	    dipa  	: in std_logic_vector(1 downto 0);
--	    dipb  	: in std_logic_vector(1 downto 0);
		
	    ena   	: in std_ulogic;
	    enb   	: in std_ulogic;
	    ssra  	: in std_ulogic;
	    ssrb  	: in std_ulogic;
	    wea   	: in std_ulogic;
	    web   	: in std_ulogic
	    );	
	end component;
end package;


library ieee;
use ieee.std_logic_1164.all; 
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;  

library unisim;
use unisim.vcomponents.all; 

use work.ramb_teylor_init_pkg.all;
use work.fp24_init1_pkg.all;
use work.fp24_type_pkg.all;
use work.sp_int2str_pkg.all;

entity fp24_rambq_init_m1 is
  generic ( 
	fp_teylor	: boolean:=false
  );	
  port(
    doa  	: out std_logic_vector(47 downto 0);
    dob  	: out std_logic_vector(47 downto 0);
--    dopa 	: out std_logic_vector(5 downto 0);
--    dopb 	: out std_logic_vector(5 downto 0);

    addra 	: in std_logic_vector(9 downto 0);
    addrb 	: in std_logic_vector(9 downto 0); 
	
    clka  	: in std_ulogic;
    clkb  	: in std_ulogic;
	
    dia   	: in std_logic_vector(15 downto 0);
    dib   	: in std_logic_vector(15 downto 0);
--    dipa  	: in std_logic_vector(1 downto 0);
--    dipb  	: in std_logic_vector(1 downto 0);
	
    ena   	: in std_ulogic;
    enb   	: in std_ulogic;
    ssra  	: in std_ulogic;
    ssrb  	: in std_ulogic;
    wea   	: in std_ulogic;
    web   	: in std_ulogic
    );
	
end fp24_rambq_init_m1;

architecture fp24_rambq_init_m1 of fp24_rambq_init_m1 is

signal    doa_rom  	: std_logic_vector(47 downto 0);
signal    dob_rom  	: std_logic_vector(47 downto 0);

function read_ini_file(ramb_sel: integer range 0 to 2; use_teylor : boolean) return std_logic_array_64x256 is

variable kk : integer range 0 to 36;
variable mem_inis	: bit_array_1024x48;
variable ramb_init	: std_logic_array_64x256;

begin
	if use_teylor = true then
		mem_inis := ramb_teylor_init_pkg.mem_init0;
	else
		mem_inis := fp24_init1_pkg.mem_init1;
	end if;
	
	kk := 16*ramb_sel;
	for jj in 0 to 63 loop
		for ii in 0 to 15 loop
				ramb_init(jj)((ii+1)*16-1 downto ii*16):=mem_inis(ii+16*jj)(15+kk downto kk); 
		end loop;
	end loop;	
	
	return ramb_init;
end read_ini_file;	 

begin

doa  <= doa_rom; 
dob  <= dob_rom; 

gen_s18: for ii in 0 to 2 generate
--attribute RLOC	: string;
--constant xx : natural:=0; 
--constant yy	: natural:=conv_integer(conv_std_logic_vector(ii, 2)(1 downto 0));
--constant rloc_str : string :="X" & nat2str(xx,2) & "Y" & nat2str(yy,2) ;
--attribute RLOC of ramb : label is rloc_str; 
constant const_init : std_logic_array_64x256:=read_ini_file(ii, fp_teylor);  
begin
	--const_init(ii) <= read_ini_file(ii);
ramb: RAMB16_S18_S18 
generic map(
    INIT_00 => const_init(0),	
    INIT_01 => const_init(1),
    INIT_02 => const_init(2),
    INIT_03 => const_init(3),
    INIT_04 => const_init(4),
    INIT_05 => const_init(5),
    INIT_06 => const_init(6),
    INIT_07 => const_init(7),
    INIT_08 => const_init(8),
    INIT_09 => const_init(9),
    INIT_0A => const_init(10),
    INIT_0B => const_init(11),
    INIT_0C => const_init(12),
    INIT_0D => const_init(13),
    INIT_0E => const_init(14),
    INIT_0F => const_init(15),
    INIT_10 => const_init(16),
    INIT_11 => const_init(17),
    INIT_12 => const_init(18),
    INIT_13 => const_init(19),
    INIT_14 => const_init(20),
    INIT_15 => const_init(21),
    INIT_16 => const_init(22),
    INIT_17 => const_init(23),
    INIT_18 => const_init(24),
    INIT_19 => const_init(25),
    INIT_1A => const_init(26),
    INIT_1B => const_init(27),
    INIT_1C => const_init(28),
    INIT_1D => const_init(29),
    INIT_1E => const_init(30),
    INIT_1F => const_init(31),
    INIT_20 => const_init(32),
    INIT_21 => const_init(33),
    INIT_22 => const_init(34),
    INIT_23 => const_init(35),
    INIT_24 => const_init(36),
    INIT_25 => const_init(37),
    INIT_26 => const_init(38),
    INIT_27 => const_init(39),
    INIT_28 => const_init(40),
    INIT_29 => const_init(41),
    INIT_2A => const_init(42),
    INIT_2B => const_init(43),
    INIT_2C => const_init(44),
    INIT_2D => const_init(45),
    INIT_2E => const_init(46),
    INIT_2F => const_init(47),
    INIT_30 => const_init(48),
    INIT_31 => const_init(49),
    INIT_32 => const_init(50),
    INIT_33 => const_init(51),
    INIT_34 => const_init(52),
    INIT_35 => const_init(53),
    INIT_36 => const_init(54),
    INIT_37 => const_init(55),
    INIT_38 => const_init(56),
    INIT_39 => const_init(57),
    INIT_3A => const_init(58),
    INIT_3B => const_init(59),
    INIT_3C => const_init(60),
    INIT_3D => const_init(61),
    INIT_3E => const_init(62),
    INIT_3F => const_init(63)

--    INITP_00 => const_init(64),
--    INITP_01 => const_init(65),
--    INITP_02 => const_init(66),
--    INITP_03 => const_init(67),
--    INITP_04 => const_init(68),
--    INITP_05 => const_init(69),
--    INITP_06 => const_init(70),
--    INITP_07 => const_init(71)

--    INIT_A => X"00000",
--    INIT_B => X"00000", 
--
--    SIM_COLLISION_CHECK =>  "ALL",
--    SRVAL_A => X"00000",
--    SRVAL_B => X"00000",
--    WRITE_MODE_A => "WRITE_FIRST",
--    WRITE_MODE_B => "WRITE_FIRST"
    )

  port map(
    doa  	=> doa_rom(15+16*ii downto 16*ii), 
    dob  	=> dob_rom(15+16*ii downto 16*ii), 
--    dopa 	=> dopa_rom(1+2*ii downto 2*ii), 
--    dopb 	=> dopb_rom(1+2*ii downto 2*ii), 
			        
    addra 	=> addra, 
    addrb 	=> addrb, 
    clka  	=> clka , 
    clkb  	=> clkb , 
    dia   	=> dia  , 
    dib   	=> dib  , 
    dipa  	=> (others => '0'), 
    dipb  	=> (others => '0'), 
    ena   	=> ena  , 
    enb   	=> enb  , 
    ssra  	=> ssra , 
    ssrb  	=> ssrb , 
    wea   	=> wea  , 
    web   	=> web   	 
    );
 
end generate;

end fp24_rambq_init_m1;