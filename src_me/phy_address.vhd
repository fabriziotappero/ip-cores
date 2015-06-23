----------------------------------------------------------------------------
--  This file is a part of the LM VHDL IP LIBRARY
--  Copyright (C) 2009 Jose Nunez-Yanez
--
--  This program is free software; you can redistribute it and/or modify
--  it under the terms of the GNU General Public License as published by
--  the Free Software Foundation; either version 2 of the License, or
--  (at your option) any later version.
--
--  See the file COPYING for the full details of the license.
--
--  The license allows free and unlimited use of the library and tools for research and education purposes. 
--  The full LM core supports many more advanced motion estimation features and it is available under a 
--  low-cost commercial license. See the readme file to learn more or contact us at 
--  eejlny@byacom.co.uk or www.byacom.co.uk
-----------------------------------------------------------------------------
-- Entity: 	phy_address.vhd
-- Author:	Jose Luis Nunez 
-- Description:	conversion to move from mvx and mvy to phy address in a 5x5 macroblocks reference data 
------------------------------------------------------------------------------


library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.Numeric_STD.all;
use IEEE.std_logic_unsigned."+";
use IEEE.std_logic_unsigned."=";


entity phy_address is
    port( 
      clk : in std_logic;
	   clear : in std_logic;
	   reset : in std_logic;
      partition_count : in std_logic_vector(3 downto 0); --identify the subpartition active
      line_offset : in std_logic_vector(5 downto 0); -- read multiple lines
      mvx : in std_logic_vector(7 downto 0); --two lsb are fractional only for fractional me 
      mvy : in std_logic_vector (7 downto 0);
      phy_address : out std_logic_vector (13 downto 0)
      );
end;


architecture rtl of phy_address is
    
signal component_x,component_y : std_logic_vector(13 downto 0);
subtype word is integer range -4096 to 5888;
type mem is array (0 to 127) of word;

type type_register_file is record
	mvy,mvx : std_logic_vector(7 downto 0);
end record;

signal r,r_in : type_register_file;


signal memory : mem := ( 
0,128,256,384,512,
640,768,896,1024,
1152,1280,1408,1536,
1664,1792,1920,2048,
2176,2304,2432,2560,
2688,2816,2944,3072,
3200,3328,3456,3584,
3712,3840,3968,4096,
4224,4352,4480,4608,
4736,4864,4992,5120,
5248,5376,5504,5632,
5760,5888,0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
-4096,-3968,-3840,-3712,
-3584,-3456,-3328,-3200,
-3072,-2944,-2816,-2688,
-2560,-2432,-2304,-2176,
-2048,-1920,-1792,-1664,
-1536,-1408,-1280,-1152,
-1024,-896,-768,-640,-512,
-384,-256,-128);


--attribute syn_romstyle : string;
--attribute syn_romstyle of memory : signal is "logic";

begin
    
  adjust_address : process(mvy,line_offset)
 
  variable vmvy : std_logic_vector(7 downto 0);
  
  begin
      
      vmvy := mvy;
	   
	   r_in.mvy <= vmvy + line_offset;   
      
end process adjust_address;
	     
	
r_in.mvx <= mvx;	     
	     
	     
  px : process(r.mvx)
  
  variable vmvx : std_logic_vector(7 downto 0);
  variable vmvx_long : std_logic_vector(13 downto 0);
  begin
    vmvx := r.mvx;
    if(vmvx(7) = '1') then -- negative number
          vmvx_long := ("111111"&vmvx);
    else
          vmvx_long := ("000000"&vmvx);
     end if; 
     
   component_x <= vmvx_long;
  end process;
  

  py : process(r.mvy)
  variable vaddr : integer range 0 to 127;
  variable vmvy,vmvy_ref : std_logic_vector(7 downto 0);
  variable vrom_data : std_logic_vector(13 downto 0);
  
	begin
	      vmvy := r.mvy;
--	      vmvy_ref := r.mvy;
--	      if (vmvy(5) = '1') then -- negative number
--	            for i in 5 downto 0 loop
--	               vmvy(i) := not(vmvy(i));
--	            end loop;
--	            vmvy := vmvy + "000001"; -- now is positive
--	      end if;
	  
	     
			vaddr := To_integer(unsigned(vmvy(6 downto 0)));
			vrom_data := (std_logic_vector(to_signed(memory(vaddr),14)));
		
		   
--		   if (vmvy_ref(5)='1') then-- negative number : we need to substract to departure address
--		          for i in 12 downto 0 loop
--		                  vrom_data(i) := not(vrom_data(i));        
--		          end loop;
--		          vrom_data := vrom_data + "0000000000001"; -- now is negative
--		   end if;
		   
		   component_y <= vrom_data;
		   
	 end process;
  
  
   -- 4144 is reference position of current macroblock at 0,0
  address_reference : process(component_x,component_y,partition_count)
  begin
	case partition_count is
  		when "0000" => phy_address <= std_logic_vector(to_unsigned(4144,14)) + component_x + component_y ;
		when "0010" => phy_address <= std_logic_vector(to_unsigned(4152,14)) + component_x + component_y ;
		when "1000" => phy_address <= std_logic_vector(to_unsigned(5168,14)) + component_x + component_y ;
		when "1010" => phy_address <= std_logic_vector(to_unsigned(5176,14)) + component_x + component_y ;
		when others => null;
	end case;

  end process;
  
-- pipeline for performance reasons

regs : process(clk,clear)

begin

 if (clear = '1') then
		r.mvy <= (others => '0');
		r.mvx <= (others => '0');
 elsif rising_edge(clk) then 
		if (reset = '1') then -- general enable
			    	r.mvy <= (others => '0');
			    	r.mvx <= (others => '0');
		else 
				  r <= r_in;
		end if;
 end if;

end process regs; 
 

end rtl;
