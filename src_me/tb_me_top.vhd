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
--------------------------------------
--  entity       = tb_me_top            --
--  version      = 1.0              --
--  last update  = 20/07/06         --
--  author       = Jose Nunez       --
--------------------------------------


-- test bench me top of the hierarchy

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_misc.all;
use ieee.std_logic_textio.all;
use IEEE.std_logic_unsigned."+";
use IEEE.std_logic_unsigned."<";
use IEEE.std_logic_unsigned.">";
use IEEE.std_logic_unsigned."=";
use std.textio.all;


entity tb_me_top is
end tb_me_top;  

architecture tb of tb_me_top is


component me_top
 port ( clk : in std_logic;
        clear : in std_logic;
        reset : in std_logic;
	  register_file_address : in std_logic_vector(4 downto 0); --32
        register_file_write : in std_logic;
	  register_file_data_in : in std_logic_vector(31 downto 0);
	  register_file_data_out : out std_logic_vector(31 downto 0);
   done_interrupt : out std_logic; -- high when macroblock processing has completed    
 best_sad_debug : out std_logic_vector(15 downto 0); --debugging ports
	     best_mv_debug : out std_logic_vector(15 downto 0);
	     dma_rm_re_debug : in std_logic; --set to one to enable reading the reference area
	     dma_rm_debug : out std_logic_vector(63 downto 0); -- reference area data out
	  dma_address : in std_logic_vector(10 downto 0); -- next reference memory address or current macroblock address
     dma_data_in : in std_logic_vector(63 downto 0); -- pixel in from reference memory
     dma_rm_we : in std_logic;
	  dma_cm_we : in std_logic;
   dma_pom_we : in std_logic; -- enable writing to point memory
	   dma_prm_we : in std_logic;  -- enable writing to program memory
	  dma_residue_out : out std_logic_vector(63 downto 0); -- get residue from winner mv
	  dma_re_re : in std_logic -- enable reading residue
      );
end component;  


component reference_data0
    port(
      clk : in std_logic;
      reset : in std_logic;
      clear : in std_logic;
      addr : in std_logic_vector (9 downto 0);
      data : out std_logic_vector (63 downto 0)
      );
end component;


component reference_data1
    port(
      clk : in std_logic;
      reset : in std_logic;
      clear : in std_logic;
      addr : in std_logic_vector (9 downto 0);
      data : out std_logic_vector (63 downto 0)
      );
end component;

component reference_data2
    port(
      clk : in std_logic;
      reset : in std_logic;
      clear : in std_logic;
      addr : in std_logic_vector (9 downto 0);
      data : out std_logic_vector (63 downto 0)
      );
end component;


component macroblock_data0
    port(
      clk : in std_logic;
      reset : in std_logic;
      clear : in std_logic;
      addr : in std_logic_vector (4 downto 0);
      data : out std_logic_vector (63 downto 0)
      );
end component;

component macroblock_data1
    port(
      clk : in std_logic;
      reset : in std_logic;
      clear : in std_logic;
      addr : in std_logic_vector (4 downto 0);
      data : out std_logic_vector (63 downto 0)
      );
end component;

component macroblock_data2
    port(
      clk : in std_logic;
      reset : in std_logic;
      clear : in std_logic;
      addr : in std_logic_vector (4 downto 0);
      data : out std_logic_vector (63 downto 0)
      );
end component;

component macroblock_data3
    port(
      clk : in std_logic;
      reset : in std_logic;
      clear : in std_logic;
      addr : in std_logic_vector (4 downto 0);
      data : out std_logic_vector (63 downto 0)
      );
end component;

component macroblock_data4
    port(
      clk : in std_logic;
      reset : in std_logic;
      clear : in std_logic;
      addr : in std_logic_vector (4 downto 0);
      data : out std_logic_vector (63 downto 0)
      );
end component;

component macroblock_data5
    port(
      clk : in std_logic;
      reset : in std_logic;
      clear : in std_logic;
      addr : in std_logic_vector (4 downto 0);
      data : out std_logic_vector (63 downto 0)
      );
end component;

component macroblock_data6
    port(
      clk : in std_logic;
      reset : in std_logic;
      clear : in std_logic;
      addr : in std_logic_vector (4 downto 0);
      data : out std_logic_vector (63 downto 0)
      );
end component;

component macroblock_data7
    port(
      clk : in std_logic;
      reset : in std_logic;
      clear : in std_logic;
      addr : in std_logic_vector (4 downto 0);
      data : out std_logic_vector (63 downto 0)
      );
end component;
   

--********************************************************************
procedure print_error(expected_data: std_logic_vector(31 downto 0);received_data: std_logic_vector(31 downto 0))  is
  variable tranx : line;
 -- variable l : line;
--********************************************************************  
begin
   
   --print to output screen
   write(tranx, now, justified=>right,field =>10, unit=> ns );
   write(tranx, string'(" Error in MV/SAD  Expected: "));
   hwrite(tranx,expected_data);
   write(tranx, string'("   Received: "));
   hwrite(tranx,received_data);
   writeline(output,tranx);
end print_error;   

--********************************************************************
procedure print_ok(expected_data: std_logic_vector(31 downto 0);received_data: std_logic_vector(31 downto 0))  is
  variable tranx : line;
 -- variable l : line;
--********************************************************************  
begin
   
   --print to output screen
   write(tranx, now, justified=>right,field =>10, unit=> ns );
   write(tranx, string'(" MV/SAD OK  Expected: "));
   hwrite(tranx,expected_data);
   write(tranx, string'("   Received: "));
   hwrite(tranx,received_data);
   writeline(output,tranx);
end print_ok;  



--  set up constants for test vector application & monitoring

constant clock_period: time := 100 ns;
constant half_period : time := clock_period / 2;
constant strobe_time : time := 0.9 * half_period;


signal clk,clear,reset,register_file_write,zero,dma_pom_we,dma_prm_we  : std_logic;
signal register_file_address : std_logic_vector(4 downto 0);
signal register_file_data_in,register_file_data_out : std_logic_vector(31 downto 0);
signal dma_data_in : std_logic_vector(63 downto 0);
signal dut_address,current_dma_address : std_logic_vector(10 downto 0);
signal current_external_address : std_logic_vector(9 downto 0);
signal macroblock_data_out1,macroblock_data_out2,macroblock_data_out3,macroblock_data_out4,macroblock_data_out5,macroblock_data_out6,macroblock_data_out7,macroblock_data_out8,macroblock_data_out,reference_data_out,reference_data_out2,reference_data_out1,reference_data_out3,dma_residue_out,reference_data_out_delay : std_logic_vector(63 downto 0);
signal dma_loading, dma_rm_we, dma_cm_we,dma_re_re,done_interrupt: std_logic;
signal best_mv_debug,best_sad_debug : std_logic_vector(15 downto 0); --debugging ports
signal macroblock_count : integer;

type results_mem is array (0 to 7) of std_logic_vector(31 downto 0);
signal results : results_mem := ( 
x"FF000444",
x"FF000669",
x"0000095E",
x"02FC03BB",
x"FF000869",
x"00000C46",
x"FF000CEE",
x"00000000"
);



begin
    
zero <= '0';

reference_data1i : reference_data0
    port map(
      clk =>clk,
      reset =>reset,
      clear =>clear,
      addr =>current_external_address,
      data => reference_data_out1
      );
      
reference_data2i : reference_data1
     port map(
      clk =>clk,
      reset =>reset,
      clear =>clear,
      addr =>current_external_address,
      data => reference_data_out2
      );

reference_data3i : reference_data2
     port map(
      clk =>clk,
      reset =>reset,
      clear =>clear,
      addr =>current_external_address,
      data => reference_data_out3
      );


macroblock_data1i : macroblock_data0
    port map(
      clk =>clk,
      reset =>reset,
      clear =>clear,
      addr => current_dma_address(4 downto 0),
      data => macroblock_data_out1
      );
      

macroblock_data2i : macroblock_data1 
    port map(
      clk =>clk,
      reset =>reset,
      clear =>clear,
      addr =>current_dma_address(4 downto 0),
      data => macroblock_data_out2
      );

macroblock_data3i : macroblock_data2 
    port map(
      clk =>clk,
      reset =>reset,
      clear =>clear,
      addr =>current_dma_address(4 downto 0),
      data => macroblock_data_out3
      );

macroblock_data4i : macroblock_data3 
    port map(
      clk =>clk,
      reset =>reset,
      clear =>clear,
      addr =>current_dma_address(4 downto 0),
      data => macroblock_data_out4
      );

macroblock_data5i : macroblock_data4 
    port map(
      clk =>clk,
      reset =>reset,
      clear =>clear,
      addr =>current_dma_address(4 downto 0),
      data => macroblock_data_out5
      );

macroblock_data6i : macroblock_data5 
    port map(
      clk =>clk,
      reset =>reset,
      clear =>clear,
      addr =>current_dma_address(4 downto 0),
      data => macroblock_data_out6
      );

macroblock_data7i : macroblock_data6 
    port map(
      clk =>clk,
      reset =>reset,
      clear =>clear,
      addr =>current_dma_address(4 downto 0),
      data => macroblock_data_out7
      );


macroblock_data8i : macroblock_data7 
    port map(
      clk =>clk,
      reset =>reset,
      clear =>clear,
      addr =>current_dma_address(4 downto 0),
      data => macroblock_data_out8
      );


macroblock_data_out <= macroblock_data_out1 when macroblock_count = 1 else 
			     macroblock_data_out2 when macroblock_count = 2 else 
	     		     macroblock_data_out3 when macroblock_count = 3 else 
	                 macroblock_data_out4 when macroblock_count = 4 else 
	                 macroblock_data_out5 when macroblock_count = 5 else 
	                 macroblock_data_out6 when macroblock_count = 6 else 
	                 macroblock_data_out7 when macroblock_count = 7 else 
	                 macroblock_data_out8 when macroblock_count = 8 else
			     (others => '0'); 
	
      
reference_data_out <= reference_data_out1 when macroblock_count = 0 else 
			    reference_data_out2 when (macroblock_count > 0 and macroblock_count < 6) else
			    reference_data_out3;
			    
reference_data_out_delay <= reference_data_out after 10 ns;
      
dma_data_in <= reference_data_out_delay when dma_rm_we = '1' else 
		  (others => '0') when dma_prm_we = '1' else
		   macroblock_data_out;

DUT : me_top
 port map ( clk =>clk,
        clear =>clear,
        reset =>reset,
	     register_file_address =>register_file_address, -- 32
        register_file_write =>register_file_write,
	     register_file_data_in =>register_file_data_in,
	     register_file_data_out => register_file_data_out,
   done_interrupt => done_interrupt,
     best_sad_debug => best_sad_debug,  --debugging ports
	     best_mv_debug => best_mv_debug,
	     dma_rm_re_debug =>zero, -- set to one to enable reading the reference area
	     dma_rm_debug =>open, -- reference area data out
	     dma_address => dut_address, -- next reference memory address
        dma_data_in => dma_data_in, -- pixel in from reference memory		
        dma_rm_we => dma_rm_we,
	     dma_cm_we => dma_cm_we,
          dma_pom_we => dma_pom_we, -- enable writing to point memory
	    dma_prm_we => dma_prm_we,  -- enable writing to program memory
	    dma_residue_out => dma_residue_out,  -- get residue from winner mv
	    dma_re_re => dma_re_re -- enable reading residue
     );





clock_process : process

begin

	clk <= '1';

	wait for half_period;

	clk <= '0';

	wait for half_period;

end process clock_process;


test_vectors : process


begin

   macroblock_count <= 0;
   current_dma_address <= (others => '0');
   current_external_address <= (others => '0');
   dma_rm_we  <= '0';
   dma_cm_we <= '0';
   dma_re_re <= '0';
   dma_prm_we <= '0';  -- enable writing to program memory
   
	wait for 10 ns;

      register_file_address <= (others => '0');

	register_file_write <= '0';

	register_file_data_in <= (others => '0');
      	
	clear <= '0';

	reset <= '0';

	wait for clock_period; 	
	wait for 1 ns;

	clear <= '1';

	reset <= '1';

	wait for clock_period;

	clear <= '0';

	reset <= '0';
	
	wait for clock_period;

	current_dma_address <= "00000000001";


	wait for clock_period;

	--dma_prm_we <= '1'; -- modify the memory contents 


	
	
	wait for clock_period;

	dma_prm_we <= '0'; -- modify the memory contents 

	wait for clock_period;

	
	
	wait for clock_period;

	wait for clock_period;

    	register_file_address <= "00001"; --write frame dimensions CIF

	register_file_write <= '1';

	register_file_data_in <= x"00001612"; --352x288 22x18 in Mbs
	

	wait for clock_period;

      wait for clock_period;

    	register_file_address <= "00101"; --write motion vector candidate to reg 5

	register_file_write <= '1';

	register_file_data_in <= x"00000000"; 
	wait for clock_period;

	register_file_write <= '0';

	wait for clock_period;




		
	while (current_dma_address < 1279)  loop				-- write reference data
		
   dma_cm_we  <= '0';
   if (current_dma_address(3 downto 0) > 1 and current_dma_address(3 downto 0) < 12) then
      current_external_address <= current_external_address + "0000000001";
      dma_rm_we <= '1';
   else
      dma_rm_we <= '0';
   end if;
   current_dma_address <= current_dma_address + "00000000001";
   
   wait for clock_period;

   end loop;

	
	current_external_address <= (others => '0');
	current_dma_address <= (others => '0');
	dma_rm_we <= '0';
   	dma_cm_we  <= '0';
   	macroblock_count <= 1;

	
	wait for clock_period;
		
	while (current_dma_address < 1279)  loop				-- write reference data block 6
		
   dma_cm_we  <= '0';
   if (current_dma_address(3 downto 0) > 11 and current_dma_address(3 downto 0) < 14) then
       if (current_dma_address(3 downto 0) = 13) then
            current_external_address <= current_external_address + "0000001001"; -- one full row displacement 
      else
            current_external_address <= current_external_address + "0000000001";
      end if;
      dma_rm_we <= '1';
   else
      dma_rm_we <= '0';
   end if;
   current_dma_address <= current_dma_address + "00000000001";
   
   wait for clock_period;

   end loop;

	
	current_external_address <= (others => '0');
	current_dma_address <= (others => '0');
	dma_rm_we <= '0';
   dma_cm_we  <= '0';
   
   wait for clock_period;
	
	while (current_dma_address < x"020")  loop				-- write macroblock data
		
   dma_rm_we <= '0';
   dma_cm_we  <= '1';
   current_dma_address <= current_dma_address + "0000000001";

   wait for clock_period;

   end loop;
   
   current_dma_address <= (others => '0');
	dma_rm_we <= '0';
   dma_cm_we  <= '0';

  wait for 15000 ns;
   
   wait for clock_period;  

   ----------------------------------------------------------
   -- First macroblock processing
   ----------------------------------------------------------


	register_file_address <= "00000"; -- start processing

	register_file_write <= '1';

	register_file_data_in <= x"80000000"; -- for 16x16

    

	wait for clock_period;
 
   register_file_address <= (others => '0');

	register_file_write <= '0';

	register_file_data_in <= (others => '0');
	
	wait for clock_period;
	
   --write the next reference column in parallel with processing
	                        
   current_dma_address <= (others => '0');
   current_external_address <= "0000000010";
   
	wait for clock_period;
		
	while (current_dma_address < x"317")  loop				-- write reference data 1 column out of 5
		
   current_external_address <= current_external_address + "0000000001";
   dma_rm_we <= '1';
   dma_cm_we  <= '0';
   current_dma_address <= current_dma_address + "0000000001"; -- address for second 8 bytes

   wait for clock_period;
   
   if (current_dma_address < x"317") then
 
      current_external_address <= current_external_address + "0000001001"; -- one full row displacement 
      current_dma_address <= current_dma_address + "0000001111"; -- one full row displacement 

   end if;

   wait for clock_period;

   end loop;

  --write the next macroblock in parallel with processing

  macroblock_count <= 2;
   
  current_dma_address <= (others => '0');
	dma_rm_we <= '0';
   dma_cm_we  <= '0';   
   
    wait for clock_period;
	
	while (current_dma_address < x"020")  loop				-- write new macroblock data
		
   dma_rm_we <= '0';
   dma_cm_we  <= '1';
   current_dma_address <= current_dma_address + "0000000001";

   wait for clock_period;

   end loop;


-------------------------------------------------------------------------------------------------------------------
while (done_interrupt /= '1') loop

	wait for clock_period;
end loop;



  ---  check results


	wait for clock_period;

	register_file_address <= "01110"; -- register 14

	register_file_write <= '0';

	wait for clock_period;


	--vregister_file_data_out := register_file_data_out;

	if (register_file_data_out = results(0)) then
		print_ok(results(0),register_file_data_out);
	else 
		print_error(results(0),register_file_data_out);
	end if;




   ----------------------------------------------------------
   -- Second macroblock processing
   ----------------------------------------------------------


	wait for clock_period;

	register_file_address <= "00000"; -- start processing

	register_file_write <= '1';

	register_file_data_in <= x"80000100"; -- 


	wait for clock_period;
 
   register_file_address <= (others => '0');

	register_file_write <= '0';

	register_file_data_in <= (others => '0');
	
	wait for clock_period;

   
  	
-------------------------------------------------------------------------------------------------------------------
   -- macroblock 3
   --write the next reference column in parallel with processing
	                        
   current_dma_address <= (others => '0');
   current_external_address <= "0000000100";
   
	wait for clock_period;
		
	while (current_dma_address < x"317")  loop				-- write reference data 1 column out of 5
		
   current_external_address <= current_external_address + "0000000001";
   dma_rm_we <= '1';
   dma_cm_we  <= '0';
   current_dma_address <= current_dma_address + "0000000001"; -- address for second 8 bytes

   wait for clock_period;
   
   if (current_dma_address < x"317") then
 
      current_external_address <= current_external_address + "0000001001"; -- one full row displacement 
      current_dma_address <= current_dma_address + "0000001111"; -- one full row displacement 

   end if;

   wait for clock_period;

   end loop;

  --write the next macroblock in parallel with processing

  macroblock_count <= 3;
   
  current_dma_address <= (others => '0');
	dma_rm_we <= '0';
   dma_cm_we  <= '0';   
   
    wait for clock_period;
	
	while (current_dma_address < x"020")  loop				-- write new macroblock data
		
   dma_rm_we <= '0';
   dma_cm_we  <= '1';
   current_dma_address <= current_dma_address + "0000000001";

   wait for clock_period;

   end loop;	
   
      current_dma_address <= (others => '0');
	dma_rm_we <= '0';
   dma_cm_we  <= '0';

  

-------------------------------------------------------------------------------------------------------------------


-------------------------------------------------------------------------------------------------------------------
while (done_interrupt /= '1') loop

	wait for clock_period;
end loop;


	wait for clock_period;

 ---  check results


	wait for clock_period;

	register_file_address <= "01110"; -- register 14

	register_file_write <= '0';

	wait for clock_period;


	--vregister_file_data_out := register_file_data_out;

	if (register_file_data_out = results(1)) then
		print_ok(results(1),register_file_data_out);
	else 
		print_error(results(1),register_file_data_out);
	end if;

	wait for clock_period;

	register_file_address <= "00000"; -- start processing

	register_file_write <= '1';

	register_file_data_in <= x"80000200";

	wait for clock_period;
 
   register_file_address <= (others => '0');

	register_file_write <= '0';

	register_file_data_in <= (others => '0');
	
	wait for clock_period;

   
  	
-------------------------------------------------------------------------------------------------------------------
   -- macroblock 4
   --write the next reference column in parallel with processing
	                        
   current_dma_address <= (others => '0');
   current_external_address <= "0000000110";
   
	wait for clock_period;
		
	while (current_dma_address < x"317")  loop				-- write reference data 1 column out of 5
		
   current_external_address <= current_external_address + "0000000001";
   dma_rm_we <= '1';
   dma_cm_we  <= '0';
   current_dma_address <= current_dma_address + "0000000001"; -- address for second 8 bytes

   wait for clock_period;
   
   if (current_dma_address < x"317") then
 
      current_external_address <= current_external_address + "0000001001"; -- one full row displacement 
      current_dma_address <= current_dma_address + "0000001111"; -- one full row displacement 

   end if;

   wait for clock_period;

   end loop;

  --write the next macroblock in parallel with processing

  macroblock_count <= 4;
   
  current_dma_address <= (others => '0');
	dma_rm_we <= '0';
   dma_cm_we  <= '0';   
   
    wait for clock_period;
	
	while (current_dma_address < x"020")  loop				-- write new macroblock data
		
   dma_rm_we <= '0';
   dma_cm_we  <= '1';
   current_dma_address <= current_dma_address + "0000000001";

   wait for clock_period;

   end loop;	
   
      current_dma_address <= (others => '0');
	dma_rm_we <= '0';
   dma_cm_we  <= '0';

  

-------------------------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------------------------------------------
while (done_interrupt /= '1') loop

	wait for clock_period;
end loop;

 ---  check results


	wait for clock_period;

	register_file_address <= "01110"; -- register 14

	register_file_write <= '0';

	wait for clock_period;


	--vregister_file_data_out := register_file_data_out;

	if (register_file_data_out = results(2)) then
		print_ok(results(2),register_file_data_out);
	else 
		print_error(results(2),register_file_data_out);
	end if;

	wait for clock_period;


 	register_file_address <= "00101"; -- mv candidate

	register_file_write <= '1';

	register_file_data_in <= x"00000000";

	wait for clock_period;

	wait for clock_period;

	register_file_address <= "00000"; -- start processing

	register_file_write <= '1';

	register_file_data_in <= x"80000300";

	wait for clock_period;
 
   register_file_address <= (others => '0');

	register_file_write <= '0';

	register_file_data_in <= (others => '0');
	
	wait for clock_period;

   
  	
-------------------------------------------------------------------------------------------------------------------
   -- macroblock 5
   --write the next reference column in parallel with processing
	                        
   current_dma_address <= (others => '0');
   current_external_address <= "0000001000";
   
	wait for clock_period;
		
	while (current_dma_address < x"317")  loop				-- write reference data 1 column out of 5
		
   current_external_address <= current_external_address + "0000000001";
   dma_rm_we <= '1';
   dma_cm_we  <= '0';
   current_dma_address <= current_dma_address + "0000000001"; -- address for second 8 bytes

   wait for clock_period;
   
   if (current_dma_address < x"317") then
 
      current_external_address <= current_external_address + "0000001001"; -- one full row displacement 
      current_dma_address <= current_dma_address + "0000001111"; -- one full row displacement 

   end if;

   wait for clock_period;

   end loop;

  --write the next macroblock in parallel with processing

  macroblock_count <= 5;
   
  current_dma_address <= (others => '0');
	dma_rm_we <= '0';
   dma_cm_we  <= '0';   
   
    wait for clock_period;
	
	while (current_dma_address < x"020")  loop				-- write new macroblock data
		
   dma_rm_we <= '0';
   dma_cm_we  <= '1';
   current_dma_address <= current_dma_address + "0000000001";

   wait for clock_period;

   end loop;	
   
      current_dma_address <= (others => '0');
	dma_rm_we <= '0';
   dma_cm_we  <= '0';

  

-------------------------------------------------------------------------------------------------------------------
	
-------------------------------------------------------------------------------------------------------------------
while (done_interrupt /= '1') loop

	wait for clock_period;
end loop;


 ---  check results


	wait for clock_period;

	register_file_address <= "01110"; -- register 14

	register_file_write <= '0';

	wait for clock_period;


	--vregister_file_data_out := register_file_data_out;

	if (register_file_data_out = results(3)) then
		print_ok( results(3),register_file_data_out);
	else 
		print_error(results(3),register_file_data_out);
	end if;

	wait for clock_period;

 	register_file_address <= "00101"; -- mv candidate

	register_file_write <= '1';

	register_file_data_in <= x"00000000";

	wait for clock_period;

	register_file_address <= "00000"; -- start processing

	register_file_write <= '1';

	register_file_data_in <= x"80000400";

	wait for clock_period;
 
   register_file_address <= (others => '0');

	register_file_write <= '0';

	register_file_data_in <= (others => '0');
	
	wait for clock_period;

   
  	
-------------------------------------------------------------------------------------------------------------------
   -- macroblock 6
   --write the next reference column in parallel with processing
	                        
   current_dma_address <= (others => '0');
   current_external_address <= "0000000000";
   
	wait for clock_period;
		
	while (current_dma_address < x"317")  loop				-- write reference data 1 column out of 5
		
   current_external_address <= current_external_address + "0000000001";
   dma_rm_we <= '1';
   dma_cm_we  <= '0';
   current_dma_address <= current_dma_address + "0000000001"; -- address for second 8 bytes

   wait for clock_period;
   
   if (current_dma_address < x"317") then
 
      current_external_address <= current_external_address + "0000001001"; -- one full row displacement 
      current_dma_address <= current_dma_address + "0000001111"; -- one full row displacement 

   end if;

   wait for clock_period;

   end loop;

  --write the next macroblock in parallel with processing

  macroblock_count <= 6;
   
  current_dma_address <= (others => '0');
	dma_rm_we <= '0';
   dma_cm_we  <= '0';   
   
    wait for clock_period;
	
	while (current_dma_address < x"020")  loop				-- write new macroblock data
		
   dma_rm_we <= '0';
   dma_cm_we  <= '1';
   current_dma_address <= current_dma_address + "0000000001";

   wait for clock_period;

   end loop;	
   
      current_dma_address <= (others => '0');
	dma_rm_we <= '0';
   dma_cm_we  <= '0';

  

-------------------------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------------------------------------------
while (done_interrupt /= '1') loop

	wait for clock_period;
end loop;

 ---  check results


	wait for clock_period;

	register_file_address <= "01110"; -- register 14

	register_file_write <= '0';

	wait for clock_period;


	--vregister_file_data_out := register_file_data_out;

	if (register_file_data_out = results(4)) then
		print_ok(results(4),register_file_data_out);
	else 
		print_error(results(4),register_file_data_out);
	end if;

	wait for clock_period;

 	register_file_address <= "00101"; -- mv candidate

	register_file_write <= '1';

	register_file_data_in <= x"00000000";

	wait for clock_period;
	

	register_file_address <= "00000"; -- start processing

	register_file_write <= '1';

	register_file_data_in <= x"80000302";

	wait for clock_period;
 
   register_file_address <= (others => '0');

	register_file_write <= '0';

	register_file_data_in <= (others => '0');
	
	wait for clock_period;

   
  	
-------------------------------------------------------------------------------------------------------------------
   -- macroblock 7
   --write the next reference column in parallel with processing
	                        
   current_dma_address <= (others => '0');
   current_external_address <= "0000000010";
   
	wait for clock_period;
		
	while (current_dma_address < x"317")  loop				-- write reference data 1 column out of 5
		
   current_external_address <= current_external_address + "0000000001";
   dma_rm_we <= '1';
   dma_cm_we  <= '0';
   current_dma_address <= current_dma_address + "0000000001"; -- address for second 8 bytes

   wait for clock_period;
   
   if (current_dma_address < x"317") then
 
      current_external_address <= current_external_address + "0000001001"; -- one full row displacement 
      current_dma_address <= current_dma_address + "0000001111"; -- one full row displacement 

   end if;

   wait for clock_period;

   end loop;

  --write the next macroblock in parallel with processing

  macroblock_count <= 7;
   
  current_dma_address <= (others => '0');
	dma_rm_we <= '0';
   dma_cm_we  <= '0';   
   
    wait for clock_period;
	
	while (current_dma_address < x"020")  loop				-- write new macroblock data
		
   dma_rm_we <= '0';
   dma_cm_we  <= '1';
   current_dma_address <= current_dma_address + "0000000001";

   wait for clock_period;

   end loop;	
   
      current_dma_address <= (others => '0');
	dma_rm_we <= '0';
   dma_cm_we  <= '0';

  

-------------------------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------------------------------------------
while (done_interrupt /= '1') loop

	wait for clock_period;
end loop;


 ---  check results


	wait for clock_period;

	register_file_address <= "01110"; -- register 14

	register_file_write <= '0';

	wait for clock_period;


	--vregister_file_data_out := register_file_data_out;

	if (register_file_data_out = results(5)) then
		print_ok(results(5),register_file_data_out);
	else 
		print_error(results(5),register_file_data_out);
	end if;

	wait for clock_period;

 	register_file_address <= "00101"; -- mv candidate

	register_file_write <= '1';

	register_file_data_in <= x"00000000";

	wait for clock_period;

	wait for clock_period;

	register_file_address <= "00000"; -- start processing

	register_file_write <= '1';

	register_file_data_in <= x"80000302";

	wait for clock_period;
 
   register_file_address <= (others => '0');

	register_file_write <= '0';

	register_file_data_in <= (others => '0');
	
	wait for clock_period;

   
  	
-------------------------------------------------------------------------------------------------------------------
   -- macroblock 8
   --write the next reference column in parallel with processing
	                        
   current_dma_address <= (others => '0');
   current_external_address <= "0000001000";
   
	wait for clock_period;
		
	while (current_dma_address < x"317")  loop				-- write reference data 1 column out of 5
		
   current_external_address <= current_external_address + "0000000001";
   dma_rm_we <= '1';
   dma_cm_we  <= '0';
   current_dma_address <= current_dma_address + "0000000001"; -- address for second 8 bytes

   wait for clock_period;
   
   if (current_dma_address < x"317") then
 
      current_external_address <= current_external_address + "0000001001"; -- one full row displacement 
      current_dma_address <= current_dma_address + "0000001111"; -- one full row displacement 

   end if;

   wait for clock_period;

   end loop;

  --write the next macroblock in parallel with processing

  macroblock_count <= 8;
   
  current_dma_address <= (others => '0');
	dma_rm_we <= '0';
   dma_cm_we  <= '0';   
   
    wait for clock_period;
	
	while (current_dma_address < x"020")  loop				-- write new macroblock data
		
   dma_rm_we <= '0';
   dma_cm_we  <= '1';
   current_dma_address <= current_dma_address + "0000000001";

   wait for clock_period;

   end loop;	
   
      current_dma_address <= (others => '0');
	dma_rm_we <= '0';
   dma_cm_we  <= '0';

  

-------------------------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------------------------------------------
while (done_interrupt /= '1') loop

	wait for clock_period;
end loop;


 ---  check results


	wait for clock_period;

	register_file_address <= "01110"; -- register 14

	register_file_write <= '0';

	wait for clock_period;


	--vregister_file_data_out := register_file_data_out;

	if (register_file_data_out = results(6)) then
		print_ok(results(6),register_file_data_out);
	else 
		print_error(results(6),register_file_data_out);
	end if;

	wait for clock_period;


  	register_file_address <= "00101"; -- mv candidate

	register_file_write <= '1';

	register_file_data_in <= x"00000000";

	wait for clock_period;

	register_file_address <= "00000"; -- start processing

	register_file_write <= '1';

	register_file_data_in <= x"80000302";

	wait for clock_period;
 
   register_file_address <= (others => '0');

	register_file_write <= '0';

	register_file_data_in <= (others => '0');
	
	wait for clock_period;
   
while (done_interrupt /= '1') loop

	wait for clock_period;
end loop;


end process test_vectors;



regs : process(clk,clear)

begin

 if (clear = '1') then
    dut_address <= (others => '0');   
 elsif rising_edge(clk) then
  		dut_address <= current_dma_address after 10 ns;
 end if;

end process regs; 

dma_pom_we <= '0'; -- enable writing to point memo




end tb; --end of architecture

      
      
   









       