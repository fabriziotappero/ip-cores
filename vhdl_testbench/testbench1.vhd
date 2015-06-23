--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   19:16:58 10/08/2013
-- Design Name:   
-- Module Name:   C:/ISE_PROJECTS/sobel_EDA/src/testbench1.vhd
-- Project Name:  sobel_EDA
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: topVGA
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
USE ieee.numeric_std.ALL;
 
ENTITY testbench1 IS
END testbench1;
 
ARCHITECTURE behavior OF testbench1 IS 
 
 
 
   type FileType is file of integer;

 
   COMPONENT top
   PORT(
        clk : IN  std_logic;
		rstn : IN std_logic; 
        data_in : IN  std_logic_vector(7 downto 0);
        fsync_in : IN  std_logic;
        fsync_out : OUT  std_logic;
        data_out : OUT  std_logic_vector(7 downto 0)
       );
   END COMPONENT;
    
	

   --Inputs
   signal clk : std_logic := '0';
   signal rstn : std_logic := '0';
   signal data_in : std_logic_vector(7 downto 0) := (others => '0');
   signal fsync_in : std_logic := '0';

 	--Outputs
   signal fsync_out : std_logic;
   signal data_out : std_logic_vector(7 downto 0);

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN

   --variable i : integer := 1;
 
	-- Instantiate the Unit Under Test (UUT)
   uut: top PORT MAP (
          clk => clk,
		  rstn => rstn,
          data_in => data_in,
          fsync_in => fsync_in,
          fsync_out => fsync_out,
          data_out => data_out
        );

   -- Clock process definitions
   clk_process :process
   begin
		clk <= '1';
		wait for clk_period/2;
		clk <= '0';
		wait for clk_period/2;
   end process;


   -- Stimulus process
   stim_proc: process
   file text_in: FileType open read_mode is "inputdata";
   file text_out: FileType open write_mode is "outputdata";

   variable chr: integer := 0;

   begin		
     wait for clk_period*1;
	  rstn <= '1';
     -- hold reset state for 100 ns.
     --wait for 100 ns;	
		 
     wait for clk_period*18;
	  
	  wait for 7 ns;
	  
--	  fsync_in <= '1';
--	  for i in 0 to 400000 loop
--	  if i < 307200 then
--	    fsync_in <= '1';
--     	read(text_in,chr);
--		data_in  <= std_logic_vector(to_unsigned(chr, 8));
--		--data_in  <= '0' & std_logic_vector(to_unsigned(i, 7));
--	  else
--		fsync_in <= '0';
--	  end if;
--	  if fsync_out = '1' then 
--	      write(text_out, to_integer(unsigned(data_out)));
--	  end if;
--	  wait for clk_period;
--	  end loop;

     fsync_in <= '1'; 
	  for i in 0 to 99 loop
	    fsync_in <= '1';
     	 read(text_in,chr);
		 data_in  <= std_logic_vector(to_unsigned(chr, 8));
		 --data_in  <= '0' & std_logic_vector(to_unsigned(i, 7));
	    if fsync_out = '1' then 
	      write(text_out, to_integer(unsigned(data_out)));
	    end if;
	    wait for clk_period;
     end loop; 	  
	  
	  fsync_in <= '0'; 
	  for i in 0 to 99999 loop
	    fsync_in <= '0';
	    if fsync_out = '1' then 
	      write(text_out, to_integer(unsigned(data_out)));
	    end if;
	    wait for clk_period;
      end loop;  

	  fsync_in <= '1'; 
	  for i in 100 to 307199 loop
	    fsync_in <= '1';
	    read(text_in,chr);
		 data_in  <= std_logic_vector(to_unsigned(chr, 8));
		 --data_in  <= '0' & std_logic_vector(to_unsigned(i, 7));
	    if fsync_out = '1' then 
	      write(text_out, to_integer(unsigned(data_out)));
	    end if;
	    wait for clk_period;
      end loop;  
	  
	  fsync_in <= '0'; 
	  for i in 0 to 199999 loop
	    fsync_in <= '0';
	    if fsync_out = '1' then 
	      write(text_out, to_integer(unsigned(data_out)));
	    end if;
	    wait for clk_period;
      end loop;    

      -- insert stimulus here 

      wait;
   end process;

END;
