---====================== Start Copyright Notice ========================---
--==                                                                    ==--
--== Filename ..... codec_tb.vhd                                        ==--
--== Download ..... http://www.ida.ing.tu-bs.de                         ==--
--== Company ...... IDA TU Braunschweig, Prof. Dr.-Ing. Harald Michalik ==--
--== Authors ...... Björn Osterloh, Karel Kotarowski                    ==--
--== Contact ...... Björn Osterloh (b.osterloh@tu-bs.de)                ==--
--== Copyright .... Copyright (c) 2008 IDA                              ==--
--== Project ...... SoCWire CODEC Testbench                             ==--
--== Version ...... 1.00                                                ==--
--== Conception ... 22 April 2009                                       ==--
--== Modified ..... N/A                                                 ==--
--==                                                                    ==--
---======================= End Copyright Notice =========================---

---====================== CODEC Loopback Testbench ======================---
--== 1 SoCWire CODEC with 8 Bit data word width is operated in Loobpack
--== mode. Packets from 1 Byte to 64KByte length increased by 1 Byte 
--== are send over the link. Each packet is terminated with EOP marker. 
--== The packets are compared and errors reported. 
--== The active signal is monitored to report link errors.																
--========================================================================--

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE ieee.std_logic_unsigned.all;
USE ieee.std_logic_textio.all;
USE STD.TEXTIO.all;

ENTITY CODEC_Loopback_tb_vhd IS
GENERIC (
         --== USE GEREIC MAPPING FROM TOPLEVEL!!! ==--
	      datawidth            : NATURAL RANGE 8 TO 8192:=8;
         speed		            : NATURAL RANGE 1 TO 100:=10;		-- Set CODEC speed to system clock in nanoseconds !
         after64              : NATURAL RANGE 1 TO 6400:=64;   -- Spacewire Standard 6400 = 6.4 us
         after128             : NATURAL RANGE 1 TO 12800:=128; -- Spacewire Standard 12800 = 12.8 us                              
	      disconnect_detection : NATURAL RANGE 1 TO 850:=85     -- Spacewire Standard 850 = 850 ns
         );
END CODEC_Loopback_tb_vhd;

ARCHITECTURE behavior OF CODEC_Loopback_tb_vhd IS 

	COMPONENT socwire_codec
	GENERIC(
	      --== USE GEREIC MAPPING FROM TOPLEVEL!!!==--
	      datawidth            : NATURAL RANGE 8 TO 8192:=8;
         speed		              : NATURAL RANGE 1 TO 100:=10;		-- Set CODEC speed to system clock in nanoseconds !
         after64              : NATURAL RANGE 1 TO 6400:=64;   -- Spacewire Standard 6400 = 6.4 us
         after128             : NATURAL RANGE 1 TO 12800:=128; -- Spacewire Standard 12800 = 12.8 us                              
	      disconnect_detection : NATURAL RANGE 1 TO 850:=85     -- Spacewire Standard 850 = 850 ns
         );
	PORT(
		rst : IN std_logic;
		clk : IN std_logic;
		socw_en : IN std_logic;
		socw_dis : IN std_logic;
		rx : IN std_logic_vector(9 downto 0);
		rx_valid : IN std_logic;
		dat_nwrite : IN std_logic;
		dat_din : IN std_logic_vector(8 downto 0);
		dat_nread : IN std_logic;          
		tx : OUT std_logic_vector(9 downto 0);
		tx_valid : OUT std_logic;
		dat_full : OUT std_logic;
		dat_empty : OUT std_logic;
		dat_dout : OUT std_logic_vector(8 downto 0);
		active : OUT std_logic
		);
	END COMPONENT;

	--Inputs
	SIGNAL rst :  std_logic := '0';
	SIGNAL clk :  std_logic := '0';
	SIGNAL socw_en :  std_logic := '0';
	SIGNAL socw_dis :  std_logic := '0';
	SIGNAL rx_valid :  std_logic := '0';
	SIGNAL dat_nwrite :  std_logic := '0';
	SIGNAL dat_nread :  std_logic := '0';
	SIGNAL rx :  std_logic_vector(9 downto 0) := (others=>'0');
	SIGNAL dat_din :  std_logic_vector(8 downto 0) := (others=>'0');

	--Outputs
	SIGNAL tx :  std_logic_vector(9 downto 0);
	SIGNAL tx_valid :  std_logic;
	SIGNAL dat_full :  std_logic;
	SIGNAL dat_empty :  std_logic;
	SIGNAL dat_dout :  std_logic_vector(8 downto 0);
	SIGNAL active :  std_logic;
	
	--Testbench
	constant clk_per	: time      := 10 ns; -- 10 ns -> 100 MHz clock   
   signal   clk_cnt  : integer   := 0;     -- clock counter      
	signal   dat_cnt  : integer   := 0;     -- data counter    
	signal flag : std_logic:='0';
	signal data_gen : std_logic_vector (8 downto 0);
	signal data8bit : std_logic_vector (7 downto 0):=(others=>'0');
   signal   dat_len  : integer  :=0;
	signal loop_cnt : integer := 0;
	signal compare_cnt : std_logic_vector ( 7 downto 0):="00000001";
	signal monitoractive : std_logic:='0';
   Signal StartDatGen : std_logic:='0';
	Signal EndDatGen: std_logic;


BEGIN
   
	uut: socwire_codec 
	GENERIC MAP (
	      datawidth            =>datawidth,
         speed		            =>speed,
         after64              =>after64,
         after128             =>after128,
	      disconnect_detection =>disconnect_detection)
	PORT MAP(
		rst => rst,
		clk => clk,
		socw_en => socw_en,
		socw_dis => socw_dis,
		rx => rx,
		rx_valid => rx_valid,
		tx => rx,
		tx_valid => rx_valid,
		dat_full => dat_full,
		dat_nwrite => dat_nwrite,
		dat_din => dat_din,
		dat_nread => dat_nread,
		dat_empty => dat_empty,
		dat_dout => dat_dout,
		active => active
	);

   -- clock generation 
   clk_gen : process
    begin
      wait for clk_per / 2;
      clk <= not clk;
   end process;
		
   -- read data  
	read_core: process(clk,dat_empty)
	begin
	 If clk ='1' and clk'event then
	  If dat_empty = '0' and active = '1' then
		dat_nread<='0';
	  else
		dat_nread<='1';
	  end if;
	 end if;
	end process;
	
	-- Compare data
   compare_core: Process (clk,dat_nread)
   Begin
	 If CLK = '1' and CLK'event then
	  If dat_nread = '0' and dat_empty = '0' then
	   If dat_dout = 256 then
		 compare_cnt<="00000001";
		elsif dat_dout <= 255 then
		  If compare_cnt = dat_dout (7 downto 0) then
		   compare_cnt<=compare_cnt + '1';
		  else
			ASSERT False
         Report "Data Error"
         Severity Failure; 
		  end if;
		end if;
	  end if;
	 end if;
	end process;
	
	-- clock counter
   clk_counter : process(clk)
     begin 
       if CLK ='0' and CLK'event then 
         clk_cnt <= clk_cnt + 1;
       end if;
   end process;
	
	-- generate reset
   ctrl_sig_gen : process (clk, clk_cnt)
   begin    
   If CLK='1' and CLK'event then 
    case clk_cnt is
      when 1        => rst <= '1';
 	   when 10	     => rst <= '0';	      
     	when others => null;
    end case;    
   end if; 
   end process;
	
	-- data generation
	data_gen_p: Process (clk,rst,active,clk_cnt,dat_cnt,StartDatGen)
	begin
	 If rst = '1' then
	  data_gen<="000000000";
	  dat_nwrite<='1';
	  dat_cnt<= 0;
	  EndDatGen<='0';
	  data8bit<="00000001";
	 elsif Clk = '1' and clk'event then
	  If active = '1' and dat_full = '0' and StartDatGen ='1' then
	     EndDatGen<='0';
		  dat_cnt<=dat_cnt + 1;
		  If dat_cnt >= 1 and dat_cnt < dat_len then
			  dat_nwrite<='0';
	        data8Bit<=data8bit +'1';
			  dat_din<='0' & data8bit;
		  elsif dat_cnt = dat_len then
		     dat_din<="100000000";
		  elsif dat_cnt = dat_len+1 then
		      dat_nwrite<='1';
				dat_cnt<= 0 ;
				EndDatGen<= '1';
				data_gen<="000000000";
				data8bit<="00000001";
		  end if;
	  end if;
	 end if;
	end process;
	 
	
  -- observe active
  Process ( monitoractive,active)
  Begin
   If monitoractive = '1' then
		If active = '0' then
		 ASSERT False
       Report "Link Error"
       Severity Failure; 
		 end if;
	end if;

 end Process;

	
	
	
	tb : PROCESS
	BEGIN
	  StartDatGen<='0';
     dat_len <=1;
	  socw_en<='1';
	  wait until active = '1';
	  wait for 2 us;
	  StartDatGen<='1';
	  monitoractive<='1';
	  wait until EndDatGen = '1';
	  StartDatGen<='0';
	  wait for 200 ns;
  -- up to 64 KByte Packet length
     for index IN 0 to 65536 LOOP
     loop_cnt<=index;
	  dat_len <=dat_len +1;
	  StartDatGen<='1';
	  wait until EndDatGen = '1';
	  StartDatGen<='0';
	  wait for 500 ns;
     END LOOP;
    
	  wait for 5 us;
     ASSERT False
       Report "End of Test "
       Severity Failure; 
     END PROCESS;

END;
