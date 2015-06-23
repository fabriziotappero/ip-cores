-- test file for log_anal.vhd
-- this entity tests the Logic Ananyser (LA) by recording up-counter states
-- for which only bit -4 is always one data_ce= data(4) or data(3)
-- trig_ce= data(5)
-- the triger value is set by the WISHBONE bus and then after all data 
-- has been written to the internal memory the WISHBONE writes the data to la_data.bin file
-- which can be then read by la_view file


library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

entity la_test is
end la_test;


architecture la_test of la_test is
  -- generic values for log_anal
  constant data_width: integer:= 16; -- width of the data that are analysed (must be power of 2)
  constant mem_adr_width: integer:= 9; -- internal memory address width
  constant adr_width: integer:= 11; -- adr_I address width
  constant trig_width: integer:= 8; -- width of the triger logic
  constant two_clocks: integer:= 1;
  
  constant Data_File : string := "la_data.bin"; -- a file to which acquired data are written

  
component log_anal
  generic(data_width: integer:= 16; -- width of the data that are analysed (must be power of 2)
      mem_adr_width: integer:= 9; -- internal memory address width
	  adr_width: integer:= 11; -- adr_I address width
      trig_width: integer:= 8; -- width of the triger logic
	  two_clocks: integer:= 0); -- two seperate clocks for control interface and logic analyser
  port (arst: in std_logic; -- global asynchronous set reset signal (mainly for simulation purposes)
	  -- interface for logic analyser 
	  clk: in std_logic; -- seperate clock for logic analyzer
	  data: in std_logic_vector(data_width-1 downto 0); -- data that are analysied
	  ce_data: in std_logic; -- clock enable -- should be used if data are recorded e.g. every second la_clk
      trig: in std_logic_vector(trig_width-1 downto 0); -- triger bus (can be different that data bus
	  ce_trig: in std_logic; -- clock enable for triger bus
	  -- control WISHBOBE slave interface - interface for setting logic analyser options and transfering analysed data to computer
      wb_clk_I: in STD_LOGIC; -- clock (common for every logic every logic analyser signals) - common for loagic analyser and WISHBONE control interface
	  wb_adr_I: in std_logic_vector(adr_width-1 downto 0); -- address bus (one bit wider than mem_adr_width)
	  wb_dat_I: in std_logic_vector(7 downto 0);
	  wb_dat_O: out std_logic_vector(7 downto 0);
	  wb_stb_I, wb_we_I: in std_logic; 
	  -- wb_cyc_I: in std_logic; -- signal is ignored
	  -- wb_rst_I: in std_logic; -- the WISHBONE interface need not be reseted
	  wb_ack_O: buffer std_logic); 
  end component;
  -- signals the same as for log_anal
  signal arst: std_logic; -- global asynchronous set reset signal (mainly for simulation purposes)
  signal clk: std_logic; -- seperate clock for logic analyzer
  signal data: std_logic_vector(data_width-1 downto 0); -- data that are analysied
  signal ce_data: std_logic; -- clock enable -- should be used if data are recorded e.g. every second la_clk
  signal trig: std_logic_vector(trig_width-1 downto 0); -- triger bus (can be different that data bus
  signal ce_trig: std_logic; -- clock enable for triger bus
  signal wb_clk_I: STD_LOGIC; -- clock (common for every logic every logic analyser signals) - common for loagic analyser and WISHBONE control interface
  signal wb_adr_I: std_logic_vector(adr_width-1 downto 0); -- address bus (one bit wider than mem_adr_width)
  signal wb_dat_I: std_logic_vector(7 downto 0);
  signal wb_dat_O: std_logic_vector(7 downto 0);
  signal wb_stb_I, wb_we_I: std_logic; 
  signal wb_ack_O, wb_ack_O_q: std_logic;
  type wb_trig_reg_type is array (7 downto 0) of std_logic_vector(7 downto 0);
  signal wb_trig_reg: wb_trig_reg_type; -- data written to the triger registers (address 8-F)
  signal wb_status_reg: std_logic_vector(7 downto 0);
  signal wb_access, la_data_read: integer:= 0;
  signal la_finish: std_logic:= '0'; -- the LA has finished data acquisition
begin
  UUT: log_anal
  generic map (data_width=> data_width, mem_adr_width=>mem_adr_width, 
      adr_width=> adr_width, trig_width=> trig_width, two_clocks=> two_clocks)
  port map (arst=> arst, 
	  clk=> clk, data=> data, ce_data=> ce_data, 
      trig=>trig, ce_trig=> ce_trig,
      wb_clk_I=> wb_clk_I, wb_adr_I=>wb_adr_I, wb_dat_I=>wb_dat_I,
	  wb_dat_O=>wb_dat_O, wb_stb_I=>wb_stb_I, wb_we_I=> wb_we_I, wb_ack_O=> wb_ack_O);

-------------------------------
-- clock generation
  process begin
	  wait for 10 ns;
	  wb_clk_I<= '0';
	  wait for 10 ns;
	  wb_clk_I<= '1';
  end process;
  
  gclk0: if two_clocks= 0 generate 
	  clk<= wb_clk_I;
  end generate;

  gclk1: if two_clocks= 1 generate
    process begin
	  wait for 17 ns;
	  clk<= '0';
	  wait for 17 ns;
	  clk<= '1';
    end process;
  end generate;
  
  arst<= '1' after 0ns, '0' after 20ns;
-----------------------------------------
-- the LA interface signals
  -- counter
  process(clk, arst) begin
    if arst='1' then data<= (others=>'0');
	elsif clk'event and clk='1' then
		data<= data + 1 after 500ps;
    end if;
  end process;
  
  ce_data<= data(4) or data(3);
  trig<= data(trig_width-1 downto 0);
  ce_trig<= data(5);

-------------------------------------------------------------
-- the WISHBONE interface
  wb_status_reg<=  "00111111"; -- triger at the end
  wb_trig_reg(0)<= "11111111"; -- triger value
  wb_trig_reg(4)<= "10001111"; -- triger care

  wb_we_i<= '1' when wb_access<12 else '0'; -- at first write to configuration registers
    -- wb_stb_i
  wb_stb_i<= '0' when wb_ack_o_q='1' and (wb_access rem 7)=5 else '1'; -- only sametimes not active
  -- wb_address
  wb_adr_i<= conv_std_logic_vector(2**(adr_width-1) + 8 + wb_access, adr_width) -- triger register address
     when wb_access< 8 else
	 conv_std_logic_vector(2**(adr_width-1), adr_width) when la_finish='0' else -- status register address 
  	 conv_std_logic_vector(la_data_read, adr_width); -- read 
	   
process(wb_clk_i)
  -- file access variables
  type integer_file_type is file of integer; -- data will be written to the file as integers
  file integer_file: integer_file_type; --    
  variable data_out: std_logic_vector(31 downto 0);	-- data that will be writen to the file
  variable data_out_byte: integer:= 0; -- to which segment of 32-bit data_out the 8-bit WISHBONE bus is writting
  variable data_out_int: integer;
begin
  -- wb_dat_i
  if wb_access<8 then wb_dat_i<= wb_trig_reg(wb_access);
	else wb_dat_i<= wb_status_reg;
  end if;
  -- acctive transfer
  if wb_clk_i='1' and wb_clk_i'event then
	  wb_ack_o_q<= wb_ack_o;
	  if wb_ack_o='1' then 
		if wb_access>=12 then
		  if la_finish='0' then 
			  if wb_dat_o(6)='1' then -- check is data acquisition is finished
				  la_finish<= '1';
		     	  FILE_OPEN (integer_file, Data_File, WRITE_MODE); 
			  end if;
		  else -- read data from internal memory and registers
			 if la_data_read< 2**(adr_width-1)+ 16 then -- not all data has been read
				data_out_byte:= la_data_read rem 4;
				data_out(7 + data_out_byte*8 downto data_out_byte*8):= wb_dat_o;
				if data_out_byte=3 then -- whole 32 bits has been read
					data_out_int:= conv_integer(data_out);
					WRITE ( integer_file, data_out_int );
				end if;	
				la_data_read<= la_data_read + 1;
			 else -- all data has been read
				 FILE_CLOSE ( integer_file );
			     assert false
		  			report "O.K. Simulation has been finished successfully"
	      			severity failure; 
			 end if;
		  end if;
		end if;
		wb_access<= wb_access + 1; -- transfer cycle
     end if; -- wb_ack_i='1'
  end if;
end process;		
	  
  
end la_test;
