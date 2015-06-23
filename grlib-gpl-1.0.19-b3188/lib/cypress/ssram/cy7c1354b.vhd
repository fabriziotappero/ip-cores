-----------------------------------------------------------------------------------------
--
--     File Name:  CY7C1354B.VHD
--       Version:  2.0
--          Date:  Nov 22nd, 2004
--         Model:  BUS Functional
--     
-- 
--        Author:  RKF 
--       Company:  Cypress Semiconductor
--         Model:  CY7C1354B (256k x 36)
--          Mode:  Pipelined
--
--   Description:  NoBL SRAM VHDL Model
--
--    Limitation:  None
--
--          Note:  - BSDL Model available separately
--                 - Set simulator resolution to "ps" timescale
--
--    Disclaimer:  THESE DESIGNS ARE PROVIDED "AS IS" WITH NO WARRANTY
--                 WHATSOEVER AND CYPRESS SPECIFICALLY DISCLAIMS ANY
--                 IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR
--                 A PARTICULAR PURPOSE, OR AGAINST INFRINGEMENT.
--
--                 Copyright (c) 2004 Cypress Semiconductor 
--                 All rights reserved
--
--     Trademarks: NoBL and No Bus Latency are trademarks of Cypress Semiconductor
--
--  Rev  Author          Date        Changes
--  ---  --------       -------     ----------  
--  2.0  RKF 		11/22/2004  - Second Release
--				    - Fully Tested with New Test Bench and Test Vectors	
-----------------------------------------------------------------------------------------

LIBRARY ieee,work,grlib,gaisler;
	USE ieee.std_logic_1164.all;
--	USE ieee.std_logic_unsigned.all;
--	Use IEEE.Std_Logic_Arith.all;
--	Use work.all;   
	USE work.package_utility.all;   
	use grlib.stdlib.all;
	use ieee.std_logic_1164.all;
	use std.textio.all;
	use gaisler.sim.all;
	

ENTITY cy7c1354 IS

    GENERIC (
	
	fname	: string := "prom.srec"; -- File to read from
	
        -- Constant parameters
	addr_bits : INTEGER := 18;
	data_bits : INTEGER := 36;

        -- Timing parameters for -5 (225 Mhz)
        tCYC	: TIME    := 4.4 ns;
        tCH	: TIME    :=  1.8 ns;
        tCL	: TIME    :=  1.8 ns;
        tCO	: TIME    :=  2.8 ns;
        tAS	: TIME    :=  1.4 ns;
        tCENS	: TIME    :=  1.4 ns;
        tWES	: TIME    :=  1.4 ns;
        tDS	: TIME    :=  1.4 ns;
        tAH	: TIME    :=  0.4 ns;
        tCENH	: TIME    :=  0.4 ns;
        tWEH	: TIME    :=  0.4 ns;
        tDH	: TIME    :=  0.4 ns


     
        -- Timing parameters for -5 (200 Mhz)
        --tCYC	: TIME    := 5.0 ns;
        --tCH	: TIME    :=  2.0 ns;
        --tCL	: TIME    :=  2.0 ns;
        --tCO	: TIME    :=  3.2 ns;
        --tAS	: TIME    :=  1.5 ns;
        --tCENS	: TIME    :=  1.5 ns;
        --tWES	: TIME    :=  1.5 ns;
        --tDS	: TIME    :=  1.5 ns;
        --tAH	: TIME    :=  0.5 ns;
        --tCENH	: TIME    :=  0.5 ns;
        --tWEH	: TIME    :=  0.5 ns;
        --tDH	: TIME    :=  0.5 ns
         

        -- Timing parameters for -5 (166 Mhz)
        --tCYC	: TIME    := 6.0 ns;
        --tCH	: TIME    :=  2.4 ns;
        --tCL	: TIME    :=  2.4 ns;
        --tCO	: TIME    :=  3.5 ns;
        --tAS	: TIME    :=  1.5 ns;
        --tCENS	: TIME    :=  1.5 ns;
        --tWES	: TIME    :=  1.5 ns;
        --tDS	: TIME    :=  1.5 ns;
        --tAH	: TIME    :=  0.5 ns;
        --tCENH	: TIME    :=  0.5 ns;
        --tWEH	: TIME    :=  0.5 ns;
        --tDH	: TIME    :=  0.5 ns

       

         );

    -- Port Declarations
    PORT (
	Dq	: INOUT STD_LOGIC_VECTOR ((data_bits - 1) DOWNTO 0);   	-- Data I/O
	Addr	: IN	STD_LOGIC_VECTOR ((addr_bits - 1) DOWNTO 0);   	-- Address
	Mode	: IN	STD_LOGIC	:= '1'; 			-- Burst Mode
	Clk	: IN	STD_LOGIC;                                   -- Clk
	CEN_n	: IN	STD_LOGIC;                                   -- CEN#
	AdvLd_n	: IN	STD_LOGIC;                                   -- Adv/Ld#
	Bwa_n	: IN	STD_LOGIC;                                   -- Bwa#
	Bwb_n	: IN	STD_LOGIC;                                   -- BWb#
	Bwc_n	: IN	STD_LOGIC;                                   -- Bwc#
	Bwd_n	: IN	STD_LOGIC;                                   -- BWd#
	Rw_n	: IN	STD_LOGIC;                                   -- RW#
	Oe_n	: IN	STD_LOGIC;                                   -- OE#
	Ce1_n	: IN	STD_LOGIC;                                   -- CE1#
	Ce2	: IN	STD_LOGIC;                                   -- CE2
	Ce3_n	: IN	STD_LOGIC;                                   -- CE3#
	Zz	: IN	STD_LOGIC                                    -- Snooze Mode
    );
END cy7c1354;

ARCHITECTURE behave OF cy7c1354 IS
    SIGNAL ce : STD_LOGIC := '0';
    SIGNAL doe : STD_LOGIC := '0';
    SIGNAL dout : STD_LOGIC_VECTOR ((data_bits - 1) DOWNTO 0) := (OTHERS => 'Z');
    SIGNAL Addr_read_sig : STD_LOGIC_VECTOR ((addr_bits - 1) DOWNTO 0) := (OTHERS => 'Z');

BEGIN


    ce <= NOT(Ce1_n) AND NOT(Ce3_n) AND Ce2;

    doe <= NOT(Oe_n) AND NOT(Zz);

    -- Output Buffers
    WITH doe SELECT
        Dq <= TRANSPORT dout            AFTER (tCO) WHEN '1',
                        (OTHERS => 'Z') AFTER (tCO) WHEN OTHERS;
    
                           
 
    -- Check for Clock Timing Violation
--    clk_check : PROCESS
--        VARIABLE clk_high, clk_low : TIME := 0 ns;
--    BEGIN
--        WAIT ON Clk;
--            IF Clk = '1' AND NOW >= tCYC THEN
--                ASSERT (NOW - clk_low >= tCH)
--                    REPORT "Clk width low - tCH violation"
--                    SEVERITY ERROR;
--                ASSERT (NOW - clk_high >= tCYC)
--                    REPORT "Clk period high - tCYC violation"
--                    SEVERITY ERROR;
--                clk_high := NOW;
--            ELSIF Clk = '0' AND NOW /= 0 ns THEN
--                ASSERT (NOW - clk_high >= tCL)
--                    REPORT "Clk width high - tCL violation"
--                    SEVERITY ERROR;
--                ASSERT (NOW - clk_low >= tCYC)
--                    REPORT "Clk period low - tCYC violation"
--                    SEVERITY ERROR;
--                clk_low := NOW;
--            END IF;
--    END PROCESS;

    -- Check for Setup Timing Violation
    setup_check : PROCESS
    BEGIN
        WAIT ON Clk;
        IF Clk = '1' THEN
            ASSERT (Addr'LAST_EVENT >= tAS)
                REPORT "Addr - tAS violation"
                SEVERITY ERROR;
            ASSERT (CEN_n'LAST_EVENT >= tCENS)
                REPORT "CKE# - tCENS violation"
                SEVERITY ERROR;
            ASSERT (Ce1_n'LAST_EVENT >= tWES)
                REPORT "CE1# - tWES violation"
                SEVERITY ERROR;
            ASSERT (Ce2'LAST_EVENT >= tWES)
                REPORT "CE2 - tWES violation"
                SEVERITY ERROR;
            ASSERT (Ce3_n'LAST_EVENT >= tWES)
                REPORT "CE3# - tWES violation"
                SEVERITY ERROR;
            ASSERT (AdvLd_n'LAST_EVENT >= tWES)
                REPORT "ADV/LD# - tWES violation"
                SEVERITY ERROR;
            ASSERT (Rw_n'LAST_EVENT >= tWES)
                REPORT "RW# - tWES violation"
                SEVERITY ERROR;
            ASSERT (Bwa_n'LAST_EVENT >= tWES)
                REPORT "BWa# - tWES violation"
                SEVERITY ERROR;
            ASSERT (Bwb_n'LAST_EVENT >= tWES)
                REPORT "BWb# - tWES violation"
                SEVERITY ERROR;
            ASSERT (Bwc_n'LAST_EVENT >= tWES)
                REPORT "BWc# - tWES violation"
                SEVERITY ERROR;
            ASSERT (Bwd_n'LAST_EVENT >= tWES)
                REPORT "BWd# - tWES violation"
                SEVERITY ERROR;
            --ASSERT (Dq'LAST_EVENT >= tDS)
            --    REPORT "Dq - tDS violation"
            --    SEVERITY ERROR;
        END IF;
    END PROCESS;

    -- Check for Hold Timing Violation
    hold_check : PROCESS
    BEGIN
        WAIT ON Clk'DELAYED(tAH), Clk'DELAYED(tCENH), Clk'DELAYED(tWEH), Clk'DELAYED(tDH);
        IF Clk'DELAYED(tAH) = '1' THEN
            ASSERT (Addr'LAST_EVENT > tAH)
                REPORT "Addr - tAH violation"
                SEVERITY ERROR;
        END IF;
        IF Clk'DELAYED(tCENH) = '1' THEN
            ASSERT (CEN_n'LAST_EVENT > tCENH)
                REPORT "CKE# - tCENH violation"
                SEVERITY ERROR;
        END IF;
        --IF Clk'DELAYED(tDH) = '1' THEN
        --    ASSERT (Dq'LAST_EVENT > tDH)
        --        REPORT "Dq - tDH violation"
        --        SEVERITY ERROR;
        --END IF;
        IF Clk'DELAYED(tWEH) = '1' THEN
            ASSERT (Ce1_n'LAST_EVENT > tWEH)
                REPORT "CE1# - tWEH violation"
                SEVERITY ERROR;
            ASSERT (Ce2'LAST_EVENT > tWEH)
                REPORT "CE2 - tWEH violation"
                SEVERITY ERROR;
            ASSERT (Ce3_n'LAST_EVENT > tWEH)
                REPORT "CE3 - tWEH violation"
                SEVERITY ERROR;
            ASSERT (AdvLd_n'LAST_EVENT > tWEH)
                REPORT "ADV/LD# - tWEH violation"
                SEVERITY ERROR;
            ASSERT (Rw_n'LAST_EVENT > tWEH)
                        REPORT "RW# - tWEH violation"
                SEVERITY ERROR;
            ASSERT (Bwa_n'LAST_EVENT > tWEH)
                REPORT "BWa# - tWEH violation"
                SEVERITY ERROR;
            ASSERT (Bwb_n'LAST_EVENT > tWEH)
                REPORT "BWb# - tWEH violation"
                SEVERITY ERROR;
            ASSERT (Bwc_n'LAST_EVENT > tWEH)
                REPORT "BWc# - tWEH violation"
                SEVERITY ERROR;
            ASSERT (Bwd_n'LAST_EVENT > tWEH)
                REPORT "BWd# - tWEH violation"
                SEVERITY ERROR;
        END IF;
        
    END PROCESS;

   -- Main Program
    main : PROCESS 

--    TYPE memory_array IS ARRAY ((2**addr_bits) - 1 DOWNTO 0) OF STD_LOGIC_VECTOR ((data_bits / 4) - 1 DOWNTO 0);
    	TYPE memory_array IS ARRAY (0 TO (2**addr_bits) - 1) OF STD_LOGIC_VECTOR ((data_bits / 4) - 1 DOWNTO 0);       
        
	VARIABLE Addr_in 	: STD_LOGIC_VECTOR ((addr_bits - 1) DOWNTO 0) := (OTHERS => '0');
        VARIABLE first_Addr 	: STD_LOGIC_VECTOR (1 DOWNTO 0) := (OTHERS => '0');
        VARIABLE Addr_read 	: STD_LOGIC_VECTOR ((addr_bits - 1) DOWNTO 0) := (OTHERS => '0');
        VARIABLE Addr_write 	: STD_LOGIC_VECTOR ((addr_bits - 1) DOWNTO 0) := (OTHERS => '0');
        VARIABLE bAddr0, bAddr1 : STD_LOGIC := '0';
        VARIABLE bank0 		: memory_array;
        VARIABLE bank1 		: memory_array;
        VARIABLE bank2 		: memory_array;
        VARIABLE bank3 		: memory_array;

        VARIABLE ce_in 		: STD_LOGIC_VECTOR (1 DOWNTO 0) := "00";
        VARIABLE rw_in 		: STD_LOGIC_VECTOR (2 DOWNTO 0) := "111";
        VARIABLE bwa_in 	: STD_LOGIC_VECTOR (2 DOWNTO 0) := "000";
        VARIABLE bwb_in 	: STD_LOGIC_VECTOR (2 DOWNTO 0) := "000";
        VARIABLE bwc_in 	: STD_LOGIC_VECTOR (2 DOWNTO 0) := "000";
        VARIABLE bwd_in 	: STD_LOGIC_VECTOR (2 DOWNTO 0) := "000";
        VARIABLE bcnt 		: STD_LOGIC_VECTOR (1 DOWNTO 0) := "00";
	
	variable FIRST		: boolean := true;
	file TCF : text open read_mode is fname;
	variable rectype : std_logic_vector(3 downto 0);
  	variable recaddr : std_logic_vector(31 downto 0);
  	variable reclen  : std_logic_vector(7 downto 0);
  	variable recdata : std_logic_vector(0 to 16*8-1);
	variable CH : character;
	variable ai : integer := 0;
	variable L1 : line;

    BEGIN
      if FIRST then

      L1:= new string'("");
      while not endfile(TCF) loop
        readline(TCF,L1);
        if (L1'length /= 0) then
          while (not (L1'length=0)) and (L1(L1'left) = ' ') loop
            std.textio.read(L1,CH);
          end loop;

          if L1'length > 0 then
            std.textio.read(L1, ch);
            if (ch = 'S') or (ch = 's') then
              hexread(L1, rectype);
              hexread(L1, reclen);
	      recaddr := (others => '0');
	      case rectype is 
		when "0001" =>
                  hexread(L1, recaddr(15 downto 0));
		when "0010" =>
                  hexread(L1, recaddr(23 downto 0));
		when "0011" =>
                  hexread(L1, recaddr);
		  recaddr(31 downto 24) := (others => '0');
		when others => next;
	      end case;
              hexread(L1, recdata);
              ai := conv_integer(recaddr)/4;
 	      for i in 0 to 3 loop
                bank3 (ai+i) := '0' & recdata((i*32) to (i*32+7));
		bank2 (ai+i) := '0' & recdata((i*32+8) to (i*32+8+7));
		bank1 (ai+i) := '0' & recdata((i*32+16) to (i*32+16+7));
		bank0 (ai+i) := '0' & recdata((i*32+24) to (i*32+24+7));
	      end loop;
            end if;
          end if;
        end if;
      end loop;

      FIRST := false;
    end if;	
	
	WAIT ON Clk;
        IF Clk'EVENT AND Clk = '1' THEN
            IF CEN_n = '0' AND Zz = '0' THEN
                -- Write Address Register
                Addr_write := Addr_read;

                -- Read Address Register
                Addr_read := Addr_in ((addr_bits - 1) DOWNTO 2) & bAddr1 & bAddr0;

                -- Address Register
                IF AdvLd_n = '0' and ce = '1' THEN
                  Addr_in := Addr;
                  first_Addr := Addr(1 DOWNTO 0);
                  bcnt := Addr(1 DOWNTO 0);
              END IF;


                -- Burst Logic
              IF Mode = '0' AND AdvLd_n = '1' THEN
                  bcnt := bcnt + 1;
              ELSIF Mode = '1' AND AdvLd_n = '1' THEN
			IF (CONV_INTEGER1 (first_Addr) REM 2 = 0) THEN
                  		bcnt := bcnt + 1;
			ELSIF (CONV_INTEGER1 (first_Addr) REM 2 = 1) THEN
                  		bcnt := bcnt - 1;
              		END IF;
              END IF;
				

                  bAddr1 := bcnt (1);
                  bAddr0 := bcnt (0);

                -- Read Logic
                ce_in (0) := ce_in (1);

                IF AdvLd_n = '0' THEN
                    ce_in (1) := ce;
                END IF;

                rw_in (0) := rw_in (1);
                rw_in (1) := rw_in (2);

                IF AdvLd_n = '0' THEN
                    rw_in (2) := NOT(ce AND NOT(Rw_n));
                END IF;

                -- Write Registry and Data Coherency Control Logic
                bwa_in (0) := bwa_in (1);
                bwb_in (0) := bwb_in (1);
                bwc_in (0) := bwc_in (1);
                bwd_in (0) := bwd_in (1);
                bwa_in (1) := bwa_in (2);
                bwb_in (1) := bwb_in (2);
                bwc_in (1) := bwc_in (2);
                bwd_in (1) := bwd_in (2);
                bwa_in (2) := Bwa_n;
                bwb_in (2) := Bwb_n;
                bwc_in (2) := Bwc_n;
                bwd_in (2) := Bwd_n;

                -- Write Data to Memory
                IF rw_in (0) = '0' AND bwa_in (0) = '0' THEN
                    bank0 (CONV_INTEGER1 (Addr_write)) := '0' & Dq ( ((data_bits-4) / 4) - 1 DOWNTO  0);
                END IF;
                IF rw_in (0) = '0' AND bwb_in (0) = '0' THEN
                    bank1 (CONV_INTEGER1 (Addr_write)) := '0' & Dq (((data_bits-4) / 2 - 1) DOWNTO  ((data_bits-4) / 4));
                END IF;
                IF rw_in (0) = '0' AND bwc_in (0) = '0' THEN
                    bank2 (CONV_INTEGER1 (Addr_write)) := '0' & Dq ((3 * ((data_bits-4) / 4)) - 1 DOWNTO  ((data_bits-4) / 2));
                END IF;
                IF rw_in (0) = '0' AND bwd_in (0) = '0' THEN
                    bank3 (CONV_INTEGER1 (Addr_write)) := '0' & Dq ((data_bits-4) - 1 DOWNTO  (3 * ((data_bits-4) / 4)));
                END IF;
            END IF;

		Addr_read_sig	<= Addr_read;

            -- Read Data from Memory Array
            IF ce_in (0) = '1' AND rw_in (1) = '1' THEN
                dout (((data_bits-4) / 4) - 1 DOWNTO  0) <= bank0 (CONV_INTEGER1 (Addr_read))(7 downto 0);
                dout (((data_bits-4) / 2 - 1) DOWNTO  ((data_bits-4) / 4)) <= bank1 (CONV_INTEGER1 (Addr_read))(7 downto 0);
                dout ((3 * ((data_bits-4) / 4)) - 1 DOWNTO  ((data_bits-4) / 2)) <= bank2 (CONV_INTEGER1 (Addr_read))(7 downto 0);
                dout ((data_bits-4) - 1 DOWNTO  (3 * ((data_bits-4) / 4))) <= bank3 (CONV_INTEGER1 (Addr_read))(7 downto 0);

--                dout ((data_bits / 4) - 1 DOWNTO  0) <= bank0 (CONV_INTEGER1 (Addr_read));
--                dout ((data_bits / 2 - 1) DOWNTO  (data_bits / 4)) <= bank1 (CONV_INTEGER1 (Addr_read));
--                dout ((3 * (data_bits / 4)) - 1 DOWNTO  (data_bits / 2)) <= bank2 (CONV_INTEGER1 (Addr_read));
--                dout (data_bits - 1 DOWNTO  (3 * (data_bits / 4))) <= bank3 (CONV_INTEGER1 (Addr_read));

            ELSE
                dout <= (OTHERS => 'Z');
            END IF;
       END IF;
    END PROCESS;

END behave;



