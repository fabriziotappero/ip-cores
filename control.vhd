library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity control is
  port(
    data				  : in std_logic_vector(7 downto 0);   -- input for data version(4B), hashprevblock(32B), merklehash(32B), time(4B), target(4B), difficulty(32B)
    loaddata			: in std_logic; 									   -- loaddata = 1 for load input data
    dataout			  :	out bit_vector ( 7 downto 0); 		 -- output for results
    loaddataout		:	out bit;									         -- loaddataout = 1 when results are ready
    clk           : in  std_logic;                     -- master clock signal
    controlrst    : in std_logic                       -- master reset signal                 
  );
end control;

architecture phy2 of control is

  signal    md        		:   bit_vector (31 downto 0) := (others => '0'); 	   
  signal    v		          :   bit := '0';                        	             
  signal    m		          :   bit_vector ( 31 downto 0) := (others => '0'); 	
  signal    ld			      :   bit := '0';                       	             
  signal    init		      :   bit := '0';                       	             
  signal    rst           :   std_logic := '0';                                
	signal   	hash      	  :   bit_vector (255 downto 0) := (others => '0');    
	signal   	cmphash    	  :   bit_vector (255 downto 0) := (others => '0');    
	signal   	reset			    :   bit := '0'; 
	signal   	resethash	    :   bit := '0';
	signal   	pom			      :		bit := '0';
	signal   	start			    :		bit := '0';                                     
  signal   	start2			  :		bit := '0';                                     
	signal 		difficulty	  :		bit_vector (255 downto 0) := (others => '0');   
	signal 		cmpstart		  :		bit := '0';	                                     
	signal 		loaded		    :		bit := '0';	                                    
	signal 		output		    :		std_logic := '0';	                               
	signal 		output_slow		:		std_logic := '0';	                               
	signal 		clkreset		  :		std_logic := '0';	
  signal 		stop     		  :		std_logic := '0';
  signal    ntime         :   bit_vector (31 downto 0) :=	(others => '0');    
  signal    ntime_max     :   bit_vector (31 downto 0) :=	(others => '0');     
  signal    sendend       :   std_logic := '0';
  signal    nonce_out     :   bit_vector (31 downto 0) :=	(others => '0');
  signal    ntime_out     :   bit_vector (31 downto 0) :=	(others => '0');

	signal   	data1      	  :     bit_vector (31 downto 0) := (others => '0'); 
	signal   	data2      	  :     bit_vector (31 downto 0) := (others => '0'); 
	signal   	data3      	  :     bit_vector (31 downto 0) := (others => '0'); 
	signal   	data4      	  :     bit_vector (31 downto 0) := (others => '0');
	signal   	data5      	  :     bit_vector (31 downto 0) := (others => '0');
	signal   	data6      	  :     bit_vector (31 downto 0) := (others => '0'); 
	signal   	data7      	  :     bit_vector (31 downto 0) := (others => '0'); 
	signal   	data8      	  :     bit_vector (31 downto 0) := (others => '0'); 
	signal   	data9      	  :     bit_vector (31 downto 0) := (others => '0'); 
	signal   	data10      	:     bit_vector (31 downto 0) := (others => '0');
	signal   	data11      	:     bit_vector (31 downto 0) := (others => '0'); 
	signal   	data12      	:     bit_vector (31 downto 0) := (others => '0'); 
	signal   	data13      	:     bit_vector (31 downto 0) := (others => '0'); 
	signal   	data14      	:     bit_vector (31 downto 0) := (others => '0'); 
	signal   	data15      	:     bit_vector (31 downto 0) := (others => '0'); 
	signal   	data16      	:     bit_vector (31 downto 0) := (others => '0'); 
	signal   	data17      	:     bit_vector (31 downto 0) := (others => '0'); 
	signal   	data18      	:     bit_vector (31 downto 0) := (others => '0'); 
	signal   	data19      	:     bit_vector (31 downto 0) := (others => '0'); 
	signal   	data20      	:     bit_vector (31 downto 0) := X"00000000";--(others => '0'); -- nonce (32bitu)
	signal   	data21      	:     bit_vector (31 downto 0) := X"00000080"; -- padding
	signal   	data22      	:     bit_vector (31 downto 0) := X"00000000"; -- padding
	signal   	data23      	:     bit_vector (31 downto 0) := X"00000000"; -- padding
	signal   	data24      	:     bit_vector (31 downto 0) := X"00000000"; -- padding
	signal   	data25      	:     bit_vector (31 downto 0) := X"00000000"; -- padding
	signal   	data26      	:     bit_vector (31 downto 0) := X"00000000"; -- padding
	signal   	data27      	:     bit_vector (31 downto 0) := X"00000000"; -- padding
	signal   	data28      	:     bit_vector (31 downto 0) := X"00000000"; -- padding
	signal   	data29     		:     bit_vector (31 downto 0) := X"00000000"; -- padding
	signal   	data30      	:     bit_vector (31 downto 0) := X"00000000"; -- padding
	signal   	data31      	:     bit_vector (31 downto 0) := X"00000000"; -- padding
	signal   	data32      	:     bit_vector (31 downto 0) := X"80020000"; -- padding

begin

  -- sha256 unit
  hashsha256: entity work.sha256
    port map(
        m => m,               -- input data for hash (16*32 bits = 512bits)
        init => init,         -- init signal
        ld => ld,             -- load signal (ld = 1 for loading 256 bits, after ld = 0)
        md => md,             -- result hash 8*32 bits (256bits)
        v => v,               -- output signal = hash is ready
        clk => CLK,
        rst => rst
      );

	rst <= to_stdulogic(resethash);
	
	-- load hash from sha256 unit
  loadhash: process(clk,reset,controlrst,sendend,stop,loaded)
	variable cnt_in : integer := 0;
	variable cnt_in2 : integer := 0;
	variable final : integer := 0;
	variable complete : integer := 0; 

   begin
		if ((clk = '1') and clk'event) then
    
			pom <= '0';
			cmpstart <= '0';
    
			if ((controlrst = '1') or (reset = '1') or ((stop = '1') and (loaded = '0'))) then
					cnt_in := 0;
					cnt_in2 := 0;
					final := 0;
      end if;
        	
    			if((v = '1') and (complete = 1)) then
    				cnt_in2 := cnt_in2+1;
    				complete :=0;
    				cmpstart <= '1';
    			elsif ((v = '1') and (final = 0)) then
    				final := 1;
    			elsif ((v = '1') and (final = 1)) then
    				cnt_in := cnt_in+1;
    				final := 0;
    				complete :=1;
    			end if;
          
    		
    			if (cnt_in > 0) then				
    					
    				CASE cnt_in IS
    				 WHEN  2 => hash(255 downto 224) <= md; 
      			 WHEN  3 => hash(223 downto 192) <= md; 
      			 WHEN  4 => hash(191 downto 160) <= md; 
      			 WHEN  5 => hash(159 downto 128) <= md; 
      			 WHEN  6 => hash(127 downto 96) <= md; 
      			 WHEN  7 => hash(95 downto 64) <= md;   
      			 WHEN  8 => hash(63 downto 32) <= md;   
      			 WHEN  9 => hash(31 downto 0) <= md;  
    				 when others => 
    				END CASE;
    				
    				if((cnt_in = 9) and (complete = 1)) then			
    					pom <= '1';
    				end if;
            
    				cnt_in:=cnt_in+1;
    			end if;		
    			
    			if (cnt_in2 > 0) then				
    					
    				CASE cnt_in2 IS
      				 WHEN  2 => cmphash(255 downto 224) <= md; 
        			 WHEN  3 => cmphash(223 downto 192) <= md; 
        			 WHEN  4 => cmphash(191 downto 160) <= md; 
        			 WHEN  5 => cmphash(159 downto 128) <= md; 
        			 WHEN  6 => cmphash(127 downto 96) <= md; 
        			 WHEN  7 => cmphash(95 downto 64) <= md;   
        			 WHEN  8 => cmphash(63 downto 32) <= md;   
        			 WHEN  9 => cmphash(31 downto 0) <= md;  
      				 when others => 
    				END CASE;
    			
    				cnt_in2:=cnt_in2+1;
    			end if;		
  	 end if;
   end process;	

	-- process sets control signals 
	setsignals: process(clk,reset,loaded,start2,controlrst,stop)
	variable cnt : integer := 0;
	variable rstcnt : integer := 0;
	variable complete : integer := 0;
	variable final : integer := 0;
	variable resetoff : integer := 0;

   begin
		if ((clk = '1') and clk'event) then
    
			ld <= '0';
			init <= '0';
			resethash <= '0';
		
		  if ((controlrst = '1') or ((stop = '1') and (loaded = '0'))) then
				cnt := 0;
				final := 0;
				resethash <= '1';
			else
		
    			if(cnt > 0) then
    				cnt := cnt+1;
    			end if;
    		
    			if((loaded = '1') and (cnt = 0)) then
    				cnt := 1;
    				resetoff := 1;
    			end if;
          
    			if(resetoff = 1) then
    				resethash <= '0';
    			else
    				resethash <= '1';
    			end if;
    			
    			if (reset = '1') then
    				cnt := 1;
    				final := 0;
    			end if;
          
    			if((cnt > 0) and (cnt < 17)) then
    				ld <= '1';
    			end if;			
    			
    			if((v = '1') and (complete = 1)) then
    				complete :=0;
    				rstcnt := rstcnt+1;
    			elsif ((v = '1') and (final = 0)) then
    				final := 1;
    			elsif ((v = '1') and (final = 1)) then
    				rstcnt := rstcnt+1;
    				final := 0;
    				complete :=1;
    			end if;
    			
    			if(rstcnt > 0 and (rstcnt < 10)) then
    				rstcnt := rstcnt+1;
    			end if;
    			
    			if((rstcnt = 10) and (start2 = '1') and (complete = 0)) then
    				reset <= '1';
    				resethash <= '1';
    				rstcnt := 11;
    			elsif((rstcnt = 10) and (start2 = '0') and (complete = 0)) then
    				resethash <= '1';
    				reset <= '1';
    			elsif((rstcnt = 11) and (complete = 0)) then
    				reset <= '0';
    				rstcnt := 0;
    			end if;
             
          if((rstcnt = 10) and (complete = 1)) then
    				reset <= '1';
    				resethash <= '1';
    				rstcnt := 11; 
      		elsif((rstcnt = 11) and (complete = 1)) then
      				reset <= '0';
      				rstcnt := 0;
      		end if;
          
    			if(cnt = 1) then
    				init <= '1';
    			end if;
    			
    			if ((cnt > 75) and (cnt < 92)) then		
    				ld <= '1';
    			end if;					
			end if;		
    end if;	
   end process;	

	-- load data to sha256 unit
	loadhashdata: process(CLK,pom,loaded,reset,start,controlrst,stop)
	variable cnt1 : integer := 0;
	variable cnt2 : integer := 0;
	variable settime : integer := 0;
   begin		
		if((clk = '1') and clk'event) then
		
			if((controlrst = '1') or (reset = '1') or ((stop = '1') and (loaded = '0'))) then
				cnt1:=0;
				cnt2:=0;
				settime := 0;
		  end if;
		
    			if((loaded = '1') and (cnt1 = 0)) then
    				cnt1:= 1;
    			end if;
    			
    			if(start = '1') then
    				cnt1:= 1;
    			end if;
    			
    			if (pom = '1') then
    				cnt2 := 1;
    			end if;
    			
    			if ((cnt1 > 0) and (cnt1 < 92)) then
    			
    				C2: case cnt1 is			
    						when 1 => m <= data1;
    						when 2 => m <= data2;
    						when 3 => m <= data3;
    						when 4 => m <= data4;
    						when 5 => m <= data5;
    						when 6 => m <= data6;
    						when 7 => m <= data7;
    						when 8 => m <= data8;
    						when 9 => m <= data9;
    						when 10 => m <= data10;
    						when 11 => m <= data11;
    						when 12 => m <= data12;
    						when 13 => m <= data13;
    						when 14 => m <= data14;
    						when 15 => m <= data15;
    						when 16 => m <= data16;
    										
    					
    						when 76 => m <= data17;
    						when 78 => m <= data19;
    						when 79 => m <= data20;
    						when 80 => m <= data21;
    						when 81 => m <= data22;
    						when 82 => m <= data23;
    						when 83 => m <= data24;
    						when 84 => m <= data25;
    						when 85 => m <= data26;
    						when 86 => m <= data27;
    						when 87 => m <= data28;
    						when 88 => m <= data29;
    						when 89 => m <= data30;
    						when 90 => m <= data31;
    						when 91 => m <= data32;
    						when others =>
    					end case C2;
    				
    				  
    				  if((cnt1 = 77) and (settime = 0)) then
    				    m <= data18;
    				    settime := 1;
    				  elsif((cnt1 = 77) and (settime = 1)) then 
    				    m <= ntime;
    				  end if;
    				
    					cnt1 := cnt1+1;			
    				end if;
    				
    			if ((cnt2 > 0) and (cnt2 < 18)) then
    				
    				CASE cnt2 IS
    					 WHEN  1 => m <= hash(255 downto 224);
    					 WHEN  2 => m <= hash(223 downto 192);
    					 WHEN  3 => m <= hash(191 downto 160);
    					 WHEN  4 => m <= hash(159 downto 128);
    					 WHEN  5 => m <= hash(127 downto 96);
    					 WHEN  6 => m <= hash(95 downto 64);
    					 WHEN  7 => m <= hash(63 downto 32);
    					 WHEN  8 => m <= hash(31 downto 0);
    					 WHEN  9 => m <= X"80000000";
    					 WHEN  10 => m <= X"00000000";
    					 WHEN  11 => m <= X"00000000";
    					 WHEN  12 => m <= X"00000000";
    					 WHEN  13 => m <= X"00000000";
    					 WHEN  14 => m <= X"00000000";
    					 WHEN  15 => m <= X"00000000";
    					 WHEN  16 => m <= X"00000100";				 
    					 when others =>
    				END CASE;
    				
    				cnt2 := cnt2+1;		
    			 end if;
    	end if;		 
   end process;
	
	-- compare computed hash with difficulty	
	compare: process(CLK,cmpstart,controlrst,stop,loaded)
	variable cmpcnt : integer := 0;
  variable startcnt : integer := 0;
  variable finish : integer := 0;
  variable pomhash : unsigned(255 downto 0);
  variable diff : unsigned(255 downto 0);
	variable nonce : bit_vector(31 downto 0) := X"00000000";
	variable one : bit_vector(31 downto 0) := X"00000001";
	variable pom_ntime : bit_vector(31 downto 0);
	variable settime : integer := 0;
   begin		

	if ((clk = '1') and clk'event) then
		
		output <= '0';
		start <= '0';
    start2 <= '0';
    sendend <= '0';
		
    if((controlrst = '1') or ((stop = '1') and (loaded = '0'))) then
      cmpcnt := 0;
      startcnt := 0;
      nonce_out <= X"00000000";
      nonce := X"00000000";
      data20 <= X"00000000";
      ntime_out <= X"00000000";
      settime := 0;
    end if;
    
    		if(cmpstart = '1') then
    			cmpcnt := cmpcnt+1;
    		end if;
    	
    		if(cmpcnt > 0) then
    			cmpcnt := cmpcnt+1;
    		end if;
    	
    		if(startcnt > 0) then
          startcnt := startcnt+1;
        end if;
    		
        if(startcnt = 80580) then
          start2 <= '1';
        end if;
    	
        if(startcnt = 80581) then
          start <= '1';
          startcnt := 0;    
        end if;
      
    		if(cmpcnt = 10) then		
    		  if(settime = 0) then
    		    ntime <= data18;
    		    settime := 1;
    		  end if;
    	 
          if(cmphash <= difficulty) then
          
            nonce_out <= data20;
            ntime_out <= pom_ntime;
          
    			  if((nonce = X"ffffffff") and (ntime = ntime_max)) then
               if(finish = 0) then
                 sendend <= '1';
    			       output <= '1';
                 finish := 1;
               end if; 
    			  elsif(nonce = X"ffffffff") then
              nonce := X"00000000";
              if(ntime < ntime_max) then
                pom_ntime := to_bitvector(std_logic_vector(unsigned(to_stdlogicvector(ntime)) + X"00000001"));
                ntime <= pom_ntime; 
              end if;
            end if;
    			
    				cmpcnt := 0;
    				nonce := to_bitvector(std_logic_vector(unsigned(to_stdlogicvector(data20(31 downto 0))) + unsigned(to_stdlogicvector(one))));
    				data20(31 downto 0) <= nonce;
    				output <= '1';
            startcnt := 1; 
               
    			else 
          
    			  if((nonce = X"ffffffff") and (ntime = ntime_max)) then
    			     output <= '0';
    			  elsif(nonce = X"ffffffff") then
              nonce := X"00000000";
              if(ntime < ntime_max) then
                pom_ntime := to_bitvector(std_logic_vector(unsigned(to_stdlogicvector(ntime)) + X"00000001"));
                ntime <= pom_ntime; 
              end if;
            end if;
    			
    				cmpcnt := 0;
    				nonce := to_bitvector(std_logic_vector(unsigned(to_stdlogicvector(data20(31 downto 0))) + unsigned(to_stdlogicvector(one)))); 
    				data20(31 downto 0) <= nonce;
    				output <= '0';	
            startcnt := 1;   
    			end if;
    		end if;
    end if;
end process;

	-- load input data version(4B), hashprevblock(32B), merklehash(32B), time(4B), target(4B), difficulty(32B)
	loadingdata: process(clk,loaddata,controlrst)
	variable cnt : integer := 0;
   begin		
	
	 if ((clk = '1') and clk'event) then

    if((controlrst = '1')) then
      cnt := 0;
    end if;
  
		if((loaddata = '1')) then
			cnt := cnt+1;
		
		CASE cnt IS
				-- version
				WHEN  1 => data1(31 downto 24) <= to_bitvector(data);
				WHEN  2 => data1(23 downto 16) <= to_bitvector(data);
				WHEN  3 => data1(15 downto 8) <= to_bitvector(data);
				WHEN  4 => data1(7 downto 0) <= to_bitvector(data);
				-- hashprevblock
				WHEN  5 => data2(31 downto 24) <= to_bitvector(data);
				WHEN  6 => data2(23 downto 16) <= to_bitvector(data);
				WHEN  7 => data2(15 downto 8) <= to_bitvector(data);
				WHEN  8 => data2(7 downto 0) <= to_bitvector(data);
				-- hashprevblock
				WHEN  9 => data3(31 downto 24) <= to_bitvector(data);
				WHEN  10 => data3(23 downto 16) <= to_bitvector(data);
				WHEN  11 => data3(15 downto 8) <= to_bitvector(data);
				WHEN  12 => data3(7 downto 0) <= to_bitvector(data);
				-- hashprevblock
				WHEN  13 => data4(31 downto 24) <= to_bitvector(data);
				WHEN  14 => data4(23 downto 16) <= to_bitvector(data);
				WHEN  15 => data4(15 downto 8) <= to_bitvector(data);
				WHEN  16 => data4(7 downto 0) <= to_bitvector(data);
				-- hashprevblock
				WHEN  17 => data5(31 downto 24) <= to_bitvector(data);
				WHEN  18 => data5(23 downto 16) <= to_bitvector(data);
				WHEN  19 => data5(15 downto 8) <= to_bitvector(data);
				WHEN  20 => data5(7 downto 0) <= to_bitvector(data);
				-- hashprevblock
				WHEN  21 => data6(31 downto 24) <= to_bitvector(data);
				WHEN  22 => data6(23 downto 16) <= to_bitvector(data);
				WHEN  23 => data6(15 downto 8) <= to_bitvector(data);
				WHEN  24 => data6(7 downto 0) <= to_bitvector(data);
				-- hashprevblock
				WHEN  25 => data7(31 downto 24) <= to_bitvector(data);
				WHEN  26 => data7(23 downto 16) <= to_bitvector(data);
				WHEN  27 => data7(15 downto 8) <= to_bitvector(data);
				WHEN  28 => data7(7 downto 0) <= to_bitvector(data);
				-- hashprevblock
				WHEN  29 => data8(31 downto 24) <= to_bitvector(data);
				WHEN  30 => data8(23 downto 16) <= to_bitvector(data);
				WHEN  31 => data8(15 downto 8) <= to_bitvector(data);
				WHEN  32 => data8(7 downto 0) <= to_bitvector(data);
				-- hashprevblock
				WHEN  33 => data9(31 downto 24) <= to_bitvector(data);
				WHEN  34 => data9(23 downto 16) <= to_bitvector(data);
				WHEN  35 => data9(15 downto 8) <= to_bitvector(data);
				WHEN  36 => data9(7 downto 0) <= to_bitvector(data);
				-- merklehash
				WHEN  37 => data10(31 downto 24) <= to_bitvector(data);
				WHEN  38 => data10(23 downto 16) <= to_bitvector(data);
				WHEN  39 => data10(15 downto 8) <= to_bitvector(data);
				WHEN  40 => data10(7 downto 0) <= to_bitvector(data);
				-- merklehash
				WHEN  41 => data11(31 downto 24) <= to_bitvector(data);
				WHEN  42 => data11(23 downto 16) <= to_bitvector(data);
				WHEN  43 => data11(15 downto 8) <= to_bitvector(data);
				WHEN  44 => data11(7 downto 0) <= to_bitvector(data);
				-- merklehash
				WHEN  45 => data12(31 downto 24) <= to_bitvector(data);
				WHEN  46 => data12(23 downto 16) <= to_bitvector(data);
				WHEN  47 => data12(15 downto 8) <= to_bitvector(data);
				WHEN  48 => data12(7 downto 0) <= to_bitvector(data);
				-- merklehash
				WHEN  49 => data13(31 downto 24) <= to_bitvector(data);
				WHEN  50 => data13(23 downto 16) <= to_bitvector(data);
				WHEN  51 => data13(15 downto 8) <= to_bitvector(data);
				WHEN  52 => data13(7 downto 0) <= to_bitvector(data);
				-- merklehash
				WHEN  53 => data14(31 downto 24) <= to_bitvector(data);
				WHEN  54 => data14(23 downto 16) <= to_bitvector(data);
				WHEN  55 => data14(15 downto 8) <= to_bitvector(data);
				WHEN  56 => data14(7 downto 0) <= to_bitvector(data);
				-- merklehash
				WHEN  57 => data15(31 downto 24) <= to_bitvector(data);
				WHEN  58 => data15(23 downto 16) <= to_bitvector(data);
				WHEN  59 => data15(15 downto 8) <= to_bitvector(data);
				WHEN  60 => data15(7 downto 0) <= to_bitvector(data);
				-- merklehash
				WHEN  61 => data16(31 downto 24) <= to_bitvector(data);
				WHEN  62 => data16(23 downto 16) <= to_bitvector(data);
				WHEN  63 => data16(15 downto 8) <= to_bitvector(data);
				WHEN  64 => data16(7 downto 0) <= to_bitvector(data);
				-- merklehash
				WHEN  65 => data17(31 downto 24) <= to_bitvector(data);
				WHEN  66 => data17(23 downto 16) <= to_bitvector(data);
				WHEN  67 => data17(15 downto 8) <= to_bitvector(data);
				WHEN  68 => data17(7 downto 0) <= to_bitvector(data);
				-- time
				WHEN  69 => data18(31 downto 24) <= to_bitvector(data);
				WHEN  70 => data18(23 downto 16) <= to_bitvector(data);
				WHEN  71 => data18(15 downto 8) <= to_bitvector(data);
				WHEN  72 => data18(7 downto 0) <= to_bitvector(data);
				-- target
				WHEN  73 => data19(31 downto 24) <= to_bitvector(data);
				WHEN  74 => data19(23 downto 16) <= to_bitvector(data);
				WHEN  75 => data19(15 downto 8) <= to_bitvector(data);
				WHEN  76 => data19(7 downto 0) <= to_bitvector(data);
				
				-- difficulty (256bits)
				WHEN  77 => difficulty(255 downto 248) <= to_bitvector(data);
				WHEN  78 => difficulty(247 downto 240) <= to_bitvector(data);
				WHEN  79 => difficulty(239 downto 232) <= to_bitvector(data);
				WHEN  80 => difficulty(231 downto 224) <= to_bitvector(data);
				WHEN  81 => difficulty(223 downto 216) <= to_bitvector(data);
				WHEN  82 => difficulty(215 downto 208) <= to_bitvector(data);
				WHEN  83 => difficulty(207 downto 200) <= to_bitvector(data);
				WHEN  84 => difficulty(199 downto 192) <= to_bitvector(data);
				WHEN  85 => difficulty(191 downto 184) <= to_bitvector(data);
				WHEN  86 => difficulty(183 downto 176) <= to_bitvector(data);
				WHEN  87 => difficulty(175 downto 168) <= to_bitvector(data);
				WHEN  88 => difficulty(167 downto 160) <= to_bitvector(data);
				WHEN  89 => difficulty(159 downto 152) <= to_bitvector(data);
				WHEN  90 => difficulty(151 downto 144) <= to_bitvector(data);
				WHEN  91 => difficulty(143 downto 136) <= to_bitvector(data);
				WHEN  92 => difficulty(135 downto 128) <= to_bitvector(data);
				WHEN  93 => difficulty(127 downto 120) <= to_bitvector(data);
				WHEN  94 => difficulty(119 downto 112) <= to_bitvector(data);
				WHEN  95 => difficulty(111 downto 104) <= to_bitvector(data);
				WHEN  96 => difficulty(103 downto 96) <= to_bitvector(data);
				WHEN  97 => difficulty(95 downto 88) <= to_bitvector(data);
				WHEN  98 => difficulty(87 downto 80) <= to_bitvector(data);
				WHEN  99 => difficulty(79 downto 72) <= to_bitvector(data);
				WHEN  100 => difficulty(71 downto 64) <= to_bitvector(data);
				WHEN  101 => difficulty(63 downto 56) <= to_bitvector(data);
				WHEN  102 => difficulty(55 downto 48) <= to_bitvector(data);
				WHEN  103 => difficulty(47 downto 40) <= to_bitvector(data);
				WHEN  104 => difficulty(39 downto 32) <= to_bitvector(data);
				WHEN  105 => difficulty(31 downto 24) <= to_bitvector(data);
				WHEN  106 => difficulty(23 downto 16) <= to_bitvector(data);
				WHEN  107 => difficulty(15 downto 8) <= to_bitvector(data);
				WHEN  108 => difficulty(7 downto 0) <= to_bitvector(data);
				when others =>
			END CASE;		
		end if;

    if((cnt = 4) and (data1 = X"73746f70")) then
      stop <= '1';
      loaded <= '0';
      cnt := 0;
    elsif(cnt = 108) then
			loaded <= '1';
			cnt := 0;
			stop <= '0';
    else
      loaded <= '0';  
		end if;

    if(cnt = 73) then
      ntime_max <= to_bitvector(std_logic_vector(unsigned(to_stdlogicvector(data18)) + X"00001c20"));
    end if;

	
		
	end if;
end process;

	-- write results to output
	sendingdata: process(clk,output,controlrst,stop,loaddata)
	variable cnt : integer := 0;
   begin		

		if ((clk = '1') and clk'event) then
  
      if((controlrst = '1') and (stop = '1')) then
        cnt := 0;
      end if;
  
  		if((cnt > 0) and (busy = '0') and (loaddata = '0') and (stop = '0')) then
  			cnt := cnt+1;
        loaddataout <= '1';
      elsif((output = '1') and (cnt = 0) and (busy = '0') and (loaddata = '0') and (stop = '0')) then
        cnt := cnt+1;
        loaddataout <= '1';
      else
        loaddataout <= '0';
  		end if;
  				
  		CASE cnt IS
        WHEN  1 => dataout <= nonce_out(31 downto 24);
        WHEN  2 => loaddataout <= '0';
  		  WHEN  3 => dataout <= nonce_out(23 downto 16);
  		  WHEN  4 => loaddataout <= '0';
  			WHEN  5 => dataout <= nonce_out(15 downto 8);
  			WHEN  6 => loaddataout <= '0';
  			WHEN  7 => dataout <= nonce_out(7 downto 0);
  			WHEN  8 => loaddataout <= '0';
  			WHEN  9 => dataout <= ntime_out(31 downto 24);
  			WHEN  10 => loaddataout <= '0';
  			WHEN  11 => dataout <= ntime_out(23 downto 16);
  			WHEN  12 => loaddataout <= '0';
  			WHEN  13 => dataout <= ntime_out(15 downto 8);
  			WHEN  14 => loaddataout <= '0';
  			WHEN  15 => dataout <= ntime_out(7 downto 0);
  			when others =>
  		END CASE;
      
      if(cnt = 15) then
  			cnt := 0;	
  		end if;
    
	end if;
end process;

end phy2;