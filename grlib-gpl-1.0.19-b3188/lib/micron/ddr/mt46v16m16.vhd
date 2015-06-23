-----------------------------------------------------------------------------------------
--
--     File Name: MT46V16M16.VHD
--       Version: 3.1
--          Date: January 14th, 2002
--         Model: Behavioral
--     Simulator: NCDesktop      - http://www.cadence.com
--                ModelSim PE    - http://www.model.com
--
--  Dependencies: None
--
--         Email: modelsupport@micron.com
--       Company: Micron Technology, Inc.
--   Part Number: MT46V16M16 (4 Mb x 16 x 4 Banks)
--
--   Description: Micron 256 Mb SDRAM DDR (Double Data Rate)
--
--    Limitation: Doesn't model internal refresh counter
--
--          Note: 
--
--    Disclaimer: THESE DESIGNS ARE PROVIDED "AS IS" WITH NO WARRANTY 
--                WHATSOEVER AND MICRON SPECIFICALLY DISCLAIMS ANY 
--                IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR
--                A PARTICULAR PURPOSE, OR AGAINST INFRINGEMENT.
--
--                Copyright (c) 1998 Micron Semiconductor Products, Inc.
--                All rights researved
--
--  Rev  Author                        Date        Changes
--  ---  ----------------------------  ----------  -------------------------------------
--  2.1  SH                            01/14/2002  - Fix Burst_counter
--       Micron Technology, Inc.
--
--  2.0  SH                            11/08/2001  - Second release
--       Micron Technology, Inc.                   - Rewrote and remove SHARED VARIABLE
--  3.1  Craig Hanson    cahanson      05/28/2003  - update all models to release version 3.1
--                       @micron.com                 (no changes to this model)
-----------------------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
LIBRARY WORK;
    USE WORK.MTI_PKG.ALL;
    use std.textio.all;

library grlib;
use grlib.stdlib.all;
library gaisler;
use gaisler.sim.all;

ENTITY MT46V16M16 IS
    GENERIC (                                   -- Timing for -75Z CL2
        tCK       : TIME    :=  7.500 ns;
        tCH       : TIME    :=  3.375 ns;       -- 0.45*tCK
        tCL       : TIME    :=  3.375 ns;       -- 0.45*tCK
        tDH       : TIME    :=  0.500 ns;
        tDS       : TIME    :=  0.500 ns;
        tIH       : TIME    :=  0.900 ns;
        tIS       : TIME    :=  0.900 ns;
        tMRD      : TIME    := 15.000 ns;
        tRAS      : TIME    := 40.000 ns;
        tRAP      : TIME    := 20.000 ns;
        tRC       : TIME    := 65.000 ns;
        tRFC      : TIME    := 75.000 ns;
        tRCD      : TIME    := 20.000 ns;
        tRP       : TIME    := 20.000 ns;
        tRRD      : TIME    := 15.000 ns;
        tWR       : TIME    := 15.000 ns;
        addr_bits : INTEGER := 13;
        data_bits : INTEGER := 16;
        cols_bits : INTEGER :=  9;
        index     : INTEGER :=  0;
	fname     : string := "sdram.srec";	-- File to read from
        bbits     : INTEGER :=  16
    );
    PORT (
        Dq    : INOUT STD_LOGIC_VECTOR (data_bits - 1 DOWNTO 0) := (OTHERS => 'Z');
        Dqs   : INOUT STD_LOGIC_VECTOR (1 DOWNTO 0) := "ZZ";
        Addr  : IN    STD_LOGIC_VECTOR (addr_bits - 1 DOWNTO 0);
        Ba    : IN    STD_LOGIC_VECTOR (1 DOWNTO 0);
        Clk   : IN    STD_LOGIC;
        Clk_n : IN    STD_LOGIC;
        Cke   : IN    STD_LOGIC;
        Cs_n  : IN    STD_LOGIC;
        Ras_n : IN    STD_LOGIC;
        Cas_n : IN    STD_LOGIC;
        We_n  : IN    STD_LOGIC;
        Dm    : IN    STD_LOGIC_VECTOR (1 DOWNTO 0)
    );
END MT46V16M16;

ARCHITECTURE behave OF MT46V16M16 IS
    -- Array for Read pipeline
    TYPE Array_Read_cmnd IS ARRAY (8 DOWNTO 0) OF STD_LOGIC;
    TYPE Array_Read_bank IS ARRAY (8 DOWNTO 0) OF STD_LOGIC_VECTOR (1 DOWNTO 0);
    TYPE Array_Read_cols IS ARRAY (8 DOWNTO 0) OF STD_LOGIC_VECTOR (cols_bits - 1 DOWNTO 0);

    -- Array for Write pipeline
    TYPE Array_Write_cmnd IS ARRAY (2 DOWNTO 0) OF STD_LOGIC;
    TYPE Array_Write_bank IS ARRAY (2 DOWNTO 0) OF STD_LOGIC_VECTOR (1 DOWNTO 0);
    TYPE Array_Write_cols IS ARRAY (2 DOWNTO 0) OF STD_LOGIC_VECTOR (cols_bits - 1 DOWNTO 0);

    -- Array for Auto Precharge
    TYPE Array_Read_precharge  IS ARRAY (3 DOWNTO 0) OF STD_LOGIC;
    TYPE Array_Write_precharge IS ARRAY (3 DOWNTO 0) OF STD_LOGIC;
    TYPE Array_Count_precharge IS ARRAY (3 DOWNTO 0) OF INTEGER;

    -- Array for Manual Precharge
    TYPE Array_A10_precharge  IS ARRAY (8 DOWNTO 0) OF STD_LOGIC;
    TYPE Array_Bank_precharge IS ARRAY (8 DOWNTO 0) OF STD_LOGIC_VECTOR (1 DOWNTO 0);
    TYPE Array_Cmnd_precharge IS ARRAY (8 DOWNTO 0) OF STD_LOGIC;
    
    -- Array for Burst Terminate
    TYPE Array_Cmnd_bst IS ARRAY (8 DOWNTO 0) OF STD_LOGIC;

    -- Array for Memory Access
    TYPE Array_ram_type IS ARRAY (2**cols_bits - 1 DOWNTO 0) OF STD_LOGIC_VECTOR (data_bits - 1 DOWNTO 0);
    TYPE Array_ram_pntr IS ACCESS Array_ram_type;
    TYPE Array_ram_stor IS ARRAY (2**addr_bits - 1 DOWNTO 0) OF Array_ram_pntr;

    -- Data pair
    SIGNAL Dq_pair : STD_LOGIC_VECTOR (2 * data_bits - 1 DOWNTO 0);
    SIGNAL Dm_pair : STD_LOGIC_VECTOR (3 DOWNTO 0);

    -- Mode Register
    SIGNAL Mode_reg : STD_LOGIC_VECTOR (addr_bits - 1 DOWNTO 0) := (OTHERS => '0');
    
    -- Command Decode Variables
    SIGNAL Active_enable, Aref_enable, Burst_term, Ext_mode_enable : STD_LOGIC := '0';
    SIGNAL Mode_reg_enable, Prech_enable, Read_enable, Write_enable : STD_LOGIC := '0';
    
    -- Burst Length Decode Variables
    SIGNAL Burst_length_2, Burst_length_4, Burst_length_8, Burst_length_f : STD_LOGIC := '0';
    
    -- Cas Latency Decode Variables
    SIGNAL Cas_latency_15, Cas_latency_2, Cas_latency_25, Cas_latency_3, Cas_latency_4 : STD_LOGIC := '0';

    -- Internal Control Signals
    SIGNAL Cs_in, Ras_in, Cas_in, We_in : STD_LOGIC := '0';

    -- System Clock
    SIGNAL Sys_clk : STD_LOGIC := '0';

    -- Dqs buffer
    SIGNAL Dqs_out : STD_LOGIC_VECTOR (1 DOWNTO 0) := "ZZ";

BEGIN
    -- Strip the strength
    Cs_in  <= To_X01 (Cs_n);
    Ras_in <= To_X01 (Ras_n);
    Cas_in <= To_X01 (Cas_n);
    We_in  <= To_X01 (We_n);
    
    -- Commands Decode
    Active_enable   <= NOT(Cs_in) AND NOT(Ras_in) AND     Cas_in  AND     We_in;
    Aref_enable     <= NOT(Cs_in) AND NOT(Ras_in) AND NOT(Cas_in) AND     We_in;
    Burst_term      <= NOT(Cs_in) AND     Ras_in  AND     Cas_in  AND NOT(We_in);
    Ext_mode_enable <= NOT(Cs_in) AND NOT(Ras_in) AND NOT(Cas_in) AND NOT(We_in) AND     Ba(0)  AND NOT(Ba(1));
    Mode_reg_enable <= NOT(Cs_in) AND NOT(Ras_in) AND NOT(Cas_in) AND NOT(We_in) AND NOT(Ba(0)) AND NOT(Ba(1));
    Prech_enable    <= NOT(Cs_in) AND NOT(Ras_in) AND     Cas_in  AND NOT(We_in);
    Read_enable     <= NOT(Cs_in) AND     Ras_in  AND NOT(Cas_in) AND     We_in;
    Write_enable    <= NOT(Cs_in) AND     Ras_in  AND NOT(Cas_in) AND NOT(We_in);

    -- Burst Length Decode
    Burst_length_2  <= NOT(Mode_reg(2)) AND NOT(Mode_reg(1)) AND     Mode_reg(0);
    Burst_length_4  <= NOT(Mode_reg(2)) AND     Mode_reg(1)  AND NOT(Mode_reg(0));
    Burst_length_8  <= NOT(Mode_reg(2)) AND     Mode_reg(1)  AND     Mode_reg(0);
    Burst_length_f  <=    (Mode_reg(2)) AND     Mode_reg(1)  AND     Mode_reg(0);

    -- CAS Latency Decode
    Cas_latency_15  <=     Mode_reg(6)  AND NOT(Mode_reg(5)) AND    (Mode_reg(4));
    Cas_latency_2   <= NOT(Mode_reg(6)) AND     Mode_reg(5)  AND NOT(Mode_reg(4));
    Cas_latency_25  <=     Mode_reg(6)  AND     Mode_reg(5)  AND NOT(Mode_reg(4));
    Cas_latency_3   <= NOT(Mode_reg(6)) AND     Mode_reg(5)  AND     Mode_reg(4);
    Cas_latency_4   <=    (Mode_reg(6)) AND NOT(Mode_reg(5)) AND NOT(Mode_reg(4));

    -- Dqs buffer
    Dqs <= Dqs_out;

    --
    -- System Clock
    --
    int_clk : PROCESS (Clk, Clk_n)
        VARIABLE ClkZ, CkeZ : STD_LOGIC := '0';
    begin
        IF Clk = '1' AND Clk_n = '0' THEN
            ClkZ := '1';
            CkeZ := Cke;
        ELSIF Clk = '0' AND Clk_n = '1' THEN
            ClkZ := '0';
        END IF;
        Sys_clk <= CkeZ AND ClkZ;
    END PROCESS;

    --
    -- Main Process
    --
    state_register : PROCESS
        -- Precharge Variables
        VARIABLE Pc_b0, Pc_b1, Pc_b2, Pc_b3 : STD_LOGIC := '0';

        -- Activate Variables
        VARIABLE Act_b0, Act_b1, Act_b2, Act_b3 : STD_LOGIC := '1';

        -- Data IO variables
        VARIABLE Data_in_enable, Data_out_enable : STD_LOGIC := '0';

        -- Internal address mux variables
        VARIABLE Cols_brst : STD_LOGIC_VECTOR (2 DOWNTO 0);
        VARIABLE Prev_bank : STD_LOGIC_VECTOR (1 DOWNTO 0) := "00";
        VARIABLE Bank_addr : STD_LOGIC_VECTOR (1 DOWNTO 0) := "00";
        VARIABLE Cols_addr : STD_LOGIC_VECTOR (cols_bits - 1 DOWNTO 0);
        VARIABLE Rows_addr : STD_LOGIC_VECTOR (addr_bits - 1 DOWNTO 0);
        VARIABLE B0_row_addr : STD_LOGIC_VECTOR (addr_bits - 1 DOWNTO 0);
        VARIABLE B1_row_addr : STD_LOGIC_VECTOR (addr_bits - 1 DOWNTO 0);
        VARIABLE B2_row_addr : STD_LOGIC_VECTOR (addr_bits - 1 DOWNTO 0);
        VARIABLE B3_row_addr : STD_LOGIC_VECTOR (addr_bits - 1 DOWNTO 0);

        -- DLL Reset variables
        VARIABLE DLL_enable : STD_LOGIC := '0';
        VARIABLE DLL_reset : STD_LOGIC := '0';
        VARIABLE DLL_done : STD_LOGIC := '0';
        VARIABLE DLL_count : INTEGER := 0;
        
        -- Timing Check
        VARIABLE MRD_chk : TIME := 0 ns;
        VARIABLE RFC_chk : TIME := 0 ns;
        VARIABLE RRD_chk : TIME := 0 ns;
        VARIABLE RAS_chk0, RAS_chk1, RAS_chk2, RAS_chk3 : TIME := 0 ns;
        VARIABLE RAP_chk0, RAP_chk1, RAP_chk2, RAP_chk3 : TIME := 0 ns;
        VARIABLE RC_chk0, RC_chk1, RC_chk2, RC_chk3 : TIME := 0 ns;
        VARIABLE RCD_chk0, RCD_chk1, RCD_chk2, RCD_chk3 : TIME := 0 ns;
        VARIABLE RP_chk0, RP_chk1, RP_chk2, RP_chk3 : TIME := 0 ns;
        VARIABLE WR_chk0, WR_chk1, WR_chk2, WR_chk3 : TIME := 0 ns;

        -- Read pipeline variables
        VARIABLE Read_cmnd : Array_Read_cmnd;
        VARIABLE Read_bank : Array_Read_bank;
        VARIABLE Read_cols : Array_Read_cols;

        -- Write pipeline variables
        VARIABLE Write_cmnd : Array_Write_cmnd;
        VARIABLE Write_bank : Array_Write_bank;
        VARIABLE Write_cols : Array_Write_cols;

        -- Auto Precharge variables
        VARIABLE Read_precharge  : Array_Read_precharge  := ('0' & '0' & '0' & '0');
        VARIABLE Write_precharge : Array_Write_precharge := ('0' & '0' & '0' & '0');
        VARIABLE Count_precharge : Array_Count_precharge := ( 0  &  0  &  0  &  0 );

        -- Manual Precharge variables
        VARIABLE A10_precharge  : Array_A10_precharge;
        VARIABLE Bank_precharge : Array_Bank_precharge;
        VARIABLE Cmnd_precharge : Array_Cmnd_precharge;

        -- Burst Terminate variable
        VARIABLE Cmnd_bst : Array_Cmnd_bst;

        -- Memory Banks
        VARIABLE Bank0 : Array_ram_stor;
        VARIABLE Bank1 : Array_ram_stor;
        VARIABLE Bank2 : Array_ram_stor;
        VARIABLE Bank3 : Array_ram_stor;

        -- Burst Counter
        VARIABLE Burst_counter : STD_LOGIC_VECTOR (cols_bits - 1 DOWNTO 0);

        -- Internal Dqs initialize
        VARIABLE Dqs_int : STD_LOGIC := '0';

        -- Data buffer for DM Mask
        VARIABLE Data_buf : STD_LOGIC_VECTOR (data_bits - 1 DOWNTO 0) := (OTHERS => 'Z');

        -- Load and Dumb variables
        FILE     file_load : TEXT open read_mode is fname;   -- Data load
        FILE     file_dump : TEXT open write_mode is "dumpdata.txt";   -- Data dump
        VARIABLE Bank_Load : std_logic_vector ( 1 DOWNTO 0);
        VARIABLE rows_load : std_logic_vector (12 DOWNTO 0);
        VARIABLE cols_load : std_logic_vector ( 8 DOWNTO 0);
        VARIABLE data_load : std_logic_vector (15 DOWNTO 0);
        VARIABLE i, j      : INTEGER;
        VARIABLE good_load : BOOLEAN;
        VARIABLE l         : LINE;
	variable file_loaded : boolean := false;
	variable dump : std_logic := '0';
	variable ch   : character;
	variable rectype : std_logic_vector(3 downto 0);
	variable recaddr : std_logic_vector(31 downto 0);
	variable reclen : std_logic_vector(7 downto 0);
	variable recdata : std_logic_vector(0 to 16*8-1);

        --
        -- Initialize empty rows
        --
        PROCEDURE Init_mem (Bank : STD_LOGIC_VECTOR; Row_index : INTEGER) IS
            VARIABLE i, j : INTEGER := 0;
        BEGIN
            IF Bank = "00" THEN
                IF Bank0 (Row_index) = NULL THEN                        -- Check to see if row empty
                    Bank0 (Row_index) := NEW Array_ram_type;            -- Open new row for access
                    FOR i IN (2**cols_bits - 1) DOWNTO 0 LOOP           -- Filled row with zeros
                        FOR j IN (data_bits - 1) DOWNTO 0 LOOP
                            Bank0 (Row_index) (i) (j) := '0';
                        END LOOP;
                    END LOOP;
                END IF;
            ELSIF Bank = "01" THEN
                IF Bank1 (Row_index) = NULL THEN
                    Bank1 (Row_index) := NEW Array_ram_type;
                    FOR i IN (2**cols_bits - 1) DOWNTO 0 LOOP
                        FOR j IN (data_bits - 1) DOWNTO 0 LOOP
                            Bank1 (Row_index) (i) (j) := '0';
                        END LOOP;
                    END LOOP;
                END IF;
            ELSIF Bank = "10" THEN
                IF Bank2 (Row_index) = NULL THEN
                    Bank2 (Row_index) := NEW Array_ram_type;
                    FOR i IN (2**cols_bits - 1) DOWNTO 0 LOOP
                        FOR j IN (data_bits - 1) DOWNTO 0 LOOP
                            Bank2 (Row_index) (i) (j) := '0';
                        END LOOP;
                    END LOOP;
                END IF;
            ELSIF Bank = "11" THEN
                IF Bank3 (Row_index) = NULL THEN
                    Bank3 (Row_index) := NEW Array_ram_type;
                    FOR i IN (2**cols_bits - 1) DOWNTO 0 LOOP
                        FOR j IN (data_bits - 1) DOWNTO 0 LOOP
                            Bank3 (Row_index) (i) (j) := '0';
                        END LOOP;
                    END LOOP;
                END IF;
            END IF;
        END;

        --
        -- Burst Counter
        --
        PROCEDURE Burst_decode IS
            VARIABLE Cols_temp : STD_LOGIC_VECTOR (cols_bits - 1 DOWNTO 0) := (OTHERS => '0');
        BEGIN
            -- Advance burst counter
            Burst_counter := Burst_counter + 1;

            -- Burst Type
            IF Mode_reg (3) = '0' THEN
                Cols_temp := Cols_addr + 1;
            ELSIF Mode_reg (3) = '1' THEN
                Cols_temp (2) := Burst_counter (2) XOR Cols_brst (2);
                Cols_temp (1) := Burst_counter (1) XOR Cols_brst (1);
                Cols_temp (0) := Burst_counter (0) XOR Cols_brst (0);
            END IF;

            -- Burst Length
            IF Burst_length_2 = '1' THEN
                Cols_addr (0) := Cols_temp (0);
            ELSIF Burst_length_4 = '1' THEN
                Cols_addr (1 DOWNTO 0) := Cols_temp (1 DOWNTO 0);
            ELSIF Burst_length_8 = '1' THEN
                Cols_addr (2 DOWNTO 0) := Cols_temp (2 DOWNTO 0);
            ELSE
                Cols_addr := Cols_temp;
            END IF;

            -- Data counter
            IF Burst_length_2 = '1' THEN
                IF conv_integer(Burst_counter) >=  2 THEN
                    IF Data_in_enable = '1' THEN
                        Data_in_enable := '0';
                    ELSIF Data_out_enable = '1' THEN
                        Data_out_enable := '0';
                    END IF;
                END IF;
            ELSIF Burst_length_4 = '1' THEN
                IF conv_integer(Burst_counter) >= 4 THEN
                    IF Data_in_enable = '1' THEN
                        Data_in_enable := '0';
                    ELSIF Data_out_enable = '1' THEN
                        Data_out_enable := '0';
                    END IF;
                END IF;
            ELSIF Burst_length_8 = '1' THEN
                IF conv_integer(Burst_counter) >= 8 THEN
                    IF Data_in_enable = '1' THEN
                        Data_in_enable := '0';
                    ELSIF Data_out_enable = '1' THEN
                        Data_out_enable := '0';
                    END IF;
                END IF;
            END IF;
        END;

    BEGIN
        WAIT ON Sys_clk;

        --
        -- Manual Precharge Pipeline
        --
        IF ((Sys_clk'EVENT AND Sys_clk = '0') OR (Sys_clk'EVENT AND Sys_clk = '1')) THEN
            -- A10 Precharge Pipeline
            A10_precharge(0) := A10_precharge(1);
            A10_precharge(1) := A10_precharge(2);
            A10_precharge(2) := A10_precharge(3);
            A10_precharge(3) := A10_precharge(4);
            A10_precharge(4) := A10_precharge(5);
            A10_precharge(5) := A10_precharge(6);
            A10_precharge(6) := A10_precharge(7);
            A10_precharge(7) := A10_precharge(8);
            A10_precharge(8) := '0';

            -- Bank Precharge Pipeline
            Bank_precharge(0) := Bank_precharge(1);
            Bank_precharge(1) := Bank_precharge(2);
            Bank_precharge(2) := Bank_precharge(3);
            Bank_precharge(3) := Bank_precharge(4);
            Bank_precharge(4) := Bank_precharge(5);
            Bank_precharge(5) := Bank_precharge(6);
            Bank_precharge(6) := Bank_precharge(7);
            Bank_precharge(7) := Bank_precharge(8);
            Bank_precharge(8) := "00";

            -- Command Precharge Pipeline
            Cmnd_precharge(0) := Cmnd_precharge(1);
            Cmnd_precharge(1) := Cmnd_precharge(2);
            Cmnd_precharge(2) := Cmnd_precharge(3);
            Cmnd_precharge(3) := Cmnd_precharge(4);
            Cmnd_precharge(4) := Cmnd_precharge(5);
            Cmnd_precharge(5) := Cmnd_precharge(6);
            Cmnd_precharge(6) := Cmnd_precharge(7);
            Cmnd_precharge(7) := Cmnd_precharge(8);
            Cmnd_precharge(8) := '0';

            -- Terminate Read if same bank or all banks
            IF ((Cmnd_precharge (0) = '1') AND
                (Bank_precharge (0) = Bank_addr OR A10_precharge (0) = '1') AND
                (Data_out_enable = '1')) THEN
                Data_out_enable := '0';
            END IF;
        END IF;

        --
        -- Burst Terminate Pipeline
        --
        IF ((Sys_clk'EVENT AND Sys_clk = '0') OR (Sys_clk'EVENT AND Sys_clk = '1')) THEN
            -- Burst Terminate pipeline
            Cmnd_bst (0) := Cmnd_bst (1);
            Cmnd_bst (1) := Cmnd_bst (2);
            Cmnd_bst (2) := Cmnd_bst (3);
            Cmnd_bst (3) := Cmnd_bst (4);
            Cmnd_bst (4) := Cmnd_bst (5);
            Cmnd_bst (5) := Cmnd_bst (6);
            Cmnd_bst (6) := Cmnd_bst (7);
            Cmnd_bst (7) := Cmnd_bst (8);
            Cmnd_bst (8) := '0';

            -- Terminate current Read
            IF ((Cmnd_bst  (0) = '1') AND (Data_out_enable = '1')) THEN
                Data_out_enable := '0';
            END IF;
        END IF;

        --
        -- Dq and Dqs Drivers
        --
        IF ((Sys_clk'EVENT AND Sys_clk = '0') OR (Sys_clk'EVENT AND Sys_clk = '1')) THEN
            -- Read Command Pipeline
            Read_cmnd (0) := Read_cmnd (1);
            Read_cmnd (1) := Read_cmnd (2);
            Read_cmnd (2) := Read_cmnd (3);
            Read_cmnd (3) := Read_cmnd (4);
            Read_cmnd (4) := Read_cmnd (5);
            Read_cmnd (5) := Read_cmnd (6);
            Read_cmnd (6) := Read_cmnd (7);
            Read_cmnd (7) := Read_cmnd (8);
            Read_cmnd (8) := '0';

            -- Read Bank Pipeline
            Read_bank (0) := Read_bank (1);
            Read_bank (1) := Read_bank (2);
            Read_bank (2) := Read_bank (3);
            Read_bank (3) := Read_bank (4);
            Read_bank (4) := Read_bank (5);
            Read_bank (5) := Read_bank (6);
            Read_bank (6) := Read_bank (7);
            Read_bank (7) := Read_bank (8);
            Read_bank (8) := "00";

            -- Read Column Pipeline
            Read_cols (0) := Read_cols (1);
            Read_cols (1) := Read_cols (2);
            Read_cols (2) := Read_cols (3);
            Read_cols (3) := Read_cols (4);
            Read_cols (4) := Read_cols (5);
            Read_cols (5) := Read_cols (6);
            Read_cols (6) := Read_cols (7);
            Read_cols (7) := Read_cols (8);
            Read_cols (8) := (OTHERS => '0');

            -- Initialize Read command
            IF Read_cmnd (0) = '1' THEN
                Data_out_enable := '1';
                Bank_addr := Read_bank (0);
                Cols_addr := Read_cols (0);
                Cols_brst := Cols_addr (2 DOWNTO 0);
                Burst_counter := (OTHERS => '0');

                -- Row address mux
                CASE Bank_addr IS
                    WHEN "00"   => Rows_addr := B0_row_addr;
                    WHEN "01"   => Rows_addr := B1_row_addr;
                    WHEN "10"   => Rows_addr := B2_row_addr;
                    WHEN OTHERS => Rows_addr := B3_row_addr;
                END CASE;
            END IF;

            -- Toggle Dqs during Read command
            IF Data_out_enable = '1' THEN
                Dqs_int := '0';
                IF Dqs_out = "00" THEN
                    Dqs_out <= "11";
                ELSIF Dqs_out = "11" THEN
                    Dqs_out <= "00";
                ELSE
                    Dqs_out <= "00";
                END IF;
            ELSIF Data_out_enable = '0' AND Dqs_int = '0' THEN
                Dqs_out <= "ZZ";
            END IF;

            -- Initialize Dqs for Read command
            IF Read_cmnd (2) = '1' THEN
                IF Data_out_enable = '0' THEN
                    Dqs_int := '1';
                    Dqs_out <= "00";
                END IF;
            END IF;

            -- Read Latch
            IF Data_out_enable = '1' THEN
                -- Initialize Memory
                Init_mem (Bank_addr, CONV_INTEGER(Rows_addr));
                
                -- Output Data
                CASE Bank_addr IS
                    WHEN "00"   => Dq <= Bank0 (CONV_INTEGER(Rows_addr)) (CONV_INTEGER(Cols_addr));
                    WHEN "01"   => Dq <= Bank1 (CONV_INTEGER(Rows_addr)) (CONV_INTEGER(Cols_addr));
                    WHEN "10"   => Dq <= Bank2 (CONV_INTEGER(Rows_addr)) (CONV_INTEGER(Cols_addr));
                    WHEN OTHERS => Dq <= Bank3 (CONV_INTEGER(Rows_addr)) (CONV_INTEGER(Cols_addr));
                END CASE;

                --  Increase Burst Counter
                Burst_decode;
            ELSE
                Dq <= (OTHERS => 'Z');
            END IF;
        END IF;

        --
        -- Write FIFO and DM Mask Logic
        --
        IF Sys_clk'EVENT AND Sys_clk = '1' THEN
            -- Write command pipeline
            Write_cmnd (0) := Write_cmnd (1);
            Write_cmnd (1) := Write_cmnd (2);
            Write_cmnd (2) := '0';

            -- Write command pipeline
            Write_bank (0) := Write_bank (1);
            Write_bank (1) := Write_bank (2);
            Write_bank (2) := "00";

            -- Write column pipeline
            Write_cols (0) := Write_cols (1);
            Write_cols (1) := Write_cols (2);
            Write_cols (2) := (OTHERS => '0');

            -- Initialize Write command
            IF Write_cmnd (0) = '1' THEN
                Data_in_enable := '1';
                Bank_addr := Write_bank (0);
                Cols_addr := Write_cols (0);
                Cols_brst := Cols_addr (2 DOWNTO 0);
                Burst_counter := (OTHERS => '0');

                -- Row address mux
                CASE Bank_addr IS
                    WHEN "00"   => Rows_addr := B0_row_addr;
                    WHEN "01"   => Rows_addr := B1_row_addr;
                    WHEN "10"   => Rows_addr := B2_row_addr;
                    WHEN OTHERS => Rows_addr := B3_row_addr;
                END CASE;
            END IF;

            -- Write data
            IF Data_in_enable = '1' THEN
                -- Initialize memory
                Init_mem (Bank_addr, CONV_INTEGER(Rows_addr));
                
                -- Write first data
                IF Dm_pair (1) = '0' OR Dm_pair (0) = '0' THEN
                    -- Data Buffer
                    CASE Bank_addr IS
                        WHEN "00"   => Data_buf := Bank0 (CONV_INTEGER(Rows_addr)) (CONV_INTEGER(Cols_addr));
                        WHEN "01"   => Data_buf := Bank1 (CONV_INTEGER(Rows_addr)) (CONV_INTEGER(Cols_addr));
                        WHEN "10"   => Data_buf := Bank2 (CONV_INTEGER(Rows_addr)) (CONV_INTEGER(Cols_addr));
                        WHEN OTHERS => Data_buf := Bank3 (CONV_INTEGER(Rows_addr)) (CONV_INTEGER(Cols_addr));
                    END CASE;

                    -- Perform DM Mask
                    IF Dm_pair (0) = '0' THEN
                        Data_buf ( 7 DOWNTO 0) := Dq_pair ( 7 DOWNTO 0);
                    END IF;
                    IF Dm_pair (1) = '0' THEN
                        Data_buf (15 DOWNTO 8) := Dq_pair (15 DOWNTO 8);
                    END IF;

                    -- Write Data
                    CASE Bank_addr IS
                        WHEN "00"   => Bank0 (CONV_INTEGER(Rows_addr)) (CONV_INTEGER(Cols_addr)) := Data_buf;
                        WHEN "01"   => Bank1 (CONV_INTEGER(Rows_addr)) (CONV_INTEGER(Cols_addr)) := Data_buf;
                        WHEN "10"   => Bank2 (CONV_INTEGER(Rows_addr)) (CONV_INTEGER(Cols_addr)) := Data_buf;
                        WHEN OTHERS => Bank3 (CONV_INTEGER(Rows_addr)) (CONV_INTEGER(Cols_addr)) := Data_buf;
                    END CASE;
                END IF;

                --  Increase Burst Counter
                Burst_decode;

                -- Write second data
                IF Dm_pair (3) = '0' OR Dm_pair (2) = '0' THEN
                    -- Data Buffer
                    CASE Bank_addr IS
                        WHEN "00"   => Data_buf := Bank0 (CONV_INTEGER(Rows_addr)) (CONV_INTEGER(Cols_addr));
                        WHEN "01"   => Data_buf := Bank1 (CONV_INTEGER(Rows_addr)) (CONV_INTEGER(Cols_addr));
                        WHEN "10"   => Data_buf := Bank2 (CONV_INTEGER(Rows_addr)) (CONV_INTEGER(Cols_addr));
                        WHEN OTHERS => Data_buf := Bank3 (CONV_INTEGER(Rows_addr)) (CONV_INTEGER(Cols_addr));
                    END CASE;

                    -- Perform DM Mask
                    IF Dm_pair (2) = '0' THEN
                        Data_buf ( 7 DOWNTO 0) := Dq_pair (23 DOWNTO 16);
                    END IF;
                    IF Dm_pair (3) = '0' THEN
                        Data_buf (15 DOWNTO 8) := Dq_pair (31 DOWNTO 24);
                    END IF;

                    -- Write Data
                    CASE Bank_addr IS
                        WHEN "00"   => Bank0 (CONV_INTEGER(Rows_addr)) (CONV_INTEGER(Cols_addr)) := Data_buf;
                        WHEN "01"   => Bank1 (CONV_INTEGER(Rows_addr)) (CONV_INTEGER(Cols_addr)) := Data_buf;
                        WHEN "10"   => Bank2 (CONV_INTEGER(Rows_addr)) (CONV_INTEGER(Cols_addr)) := Data_buf;
                        WHEN OTHERS => Bank3 (CONV_INTEGER(Rows_addr)) (CONV_INTEGER(Cols_addr)) := Data_buf;
                    END CASE;
                END IF;
                
                -- Increase Burst Counter
                Burst_decode;

                -- tWR start and tWTR check
                IF Dm_pair (3 DOWNTO 2) = "00" OR Dm_pair (1 DOWNTO 0) = "00" THEN
                    CASE Bank_addr IS
                        WHEN "00"   => WR_chk0 := NOW;
                        WHEN "01"   => WR_chk1 := NOW;
                        WHEN "10"   => WR_chk2 := NOW;
                        WHEN OTHERS => WR_chk3 := NOW;
                    END CASE;

                    -- tWTR check
                    ASSERT (Read_enable = '0')
                        REPORT "tWTR violation during Read"
                        SEVERITY WARNING;
                END IF;
            END IF;
        END IF;

        --
        -- Auto Precharge Calculation
        --
        IF Sys_clk'EVENT AND Sys_clk = '1' THEN
            -- Precharge counter
            IF Read_precharge (0) = '1' OR Write_precharge (0) = '1' THEN
                Count_precharge (0) := Count_precharge (0) + 1;
            END IF;
            IF Read_precharge (1) = '1' OR Write_precharge (1) = '1' THEN
                Count_precharge (1) := Count_precharge (1) + 1;
            END IF;
            IF Read_precharge (2) = '1' OR Write_precharge (2) = '1' THEN
                Count_precharge (2) := Count_precharge (2) + 1;
            END IF;
            IF Read_precharge (3) = '1' OR Write_precharge (3) = '1' THEN
                Count_precharge (3) := Count_precharge (3) + 1;
            END IF;

            -- Read with AutoPrecharge Calculation
            --      The device start internal precharge when:
            --          1.  Meet tRAS requirement
            --          2.  BL/2 cycles after command
            IF ((Read_precharge(0) = '1') AND (NOW - RAS_chk0 >= tRAS)) THEN
                IF ((Burst_length_2 = '1' AND Count_precharge(0) >= 1)  OR
                    (Burst_length_4 = '1' AND Count_precharge(0) >= 2)  OR
                    (Burst_length_8 = '1' AND Count_precharge(0) >= 4)) THEN
                    Pc_b0 := '1';
                    Act_b0 := '0';
                    RP_chk0 := NOW;
                    Read_precharge(0) := '0';
                END IF;
            END IF;
            IF ((Read_precharge(1) = '1') AND (NOW - RAS_chk1 >= tRAS)) THEN
                IF ((Burst_length_2 = '1' AND Count_precharge(1) >= 1)  OR
                    (Burst_length_4 = '1' AND Count_precharge(1) >= 2)  OR
                    (Burst_length_8 = '1' AND Count_precharge(1) >= 4)) THEN
                    Pc_b1 := '1';
                    Act_b1 := '0';
                    RP_chk1 := NOW;
                    Read_precharge(1) := '0';
                END IF;
            END IF;
            IF ((Read_precharge(2) = '1') AND (NOW - RAS_chk2 >= tRAS)) THEN
                IF ((Burst_length_2 = '1' AND Count_precharge(2) >= 1)  OR
                    (Burst_length_4 = '1' AND Count_precharge(2) >= 2)  OR
                    (Burst_length_8 = '1' AND Count_precharge(2) >= 4)) THEN
                    Pc_b2 := '1';
                    Act_b2 := '0';
                    RP_chk2 := NOW;
                    Read_precharge(2) := '0';
                END IF;
            END IF;
            IF ((Read_precharge(3) = '1') AND (NOW - RAS_chk3 >= tRAS)) THEN
                IF ((Burst_length_2 = '1' AND Count_precharge(3) >= 1)  OR
                    (Burst_length_4 = '1' AND Count_precharge(3) >= 2)  OR
                    (Burst_length_8 = '1' AND Count_precharge(3) >= 4)) THEN
                    Pc_b3 := '1';
                    Act_b3 := '0';
                    RP_chk3 := NOW;
                    Read_precharge(3) := '0';
                END IF;
            END IF;

            -- Write with AutoPrecharge Calculation
            --      The device start internal precharge when:
            --          1.  Meet tRAS requirement
            --          2.  Two clock after last burst
            -- Since tWR is time base, the model will compensate tRP
            IF ((Write_precharge(0) = '1') AND (NOW - RAS_chk0 >= tRAS)) THEN
                IF ((Burst_length_2 = '1' AND Count_precharge (0) >= 4) OR
                    (Burst_length_4 = '1' AND Count_precharge (0) >= 5) OR
                    (Burst_length_8 = '1' AND Count_precharge (0) >= 7)) THEN
                    Pc_b0 := '1';
                    Act_b0 := '0';
                    RP_chk0 := NOW - ((2 * tCK) - tWR);
                    Write_precharge(0) := '0';
                END IF;
            END IF;
            IF ((Write_precharge(1) = '1') AND (NOW - RAS_chk1 >= tRAS)) THEN
                IF ((Burst_length_2 = '1' AND Count_precharge (1) >= 4) OR
                    (Burst_length_4 = '1' AND Count_precharge (1) >= 5) OR
                    (Burst_length_8 = '1' AND Count_precharge (1) >= 7)) THEN
                    Pc_b1 := '1';
                    Act_b1 := '0';
                    RP_chk1 := NOW - ((2 * tCK) - tWR);
                    Write_precharge(1) := '0';
                END IF;
            END IF;
            IF ((Write_precharge(2) = '1') AND (NOW - RAS_chk2 >= tRAS)) THEN
                IF ((Burst_length_2 = '1' AND Count_precharge (2) >= 4) OR
                    (Burst_length_4 = '1' AND Count_precharge (2) >= 5) OR
                    (Burst_length_8 = '1' AND Count_precharge (2) >= 7)) THEN
                    Pc_b2 := '1';
                    Act_b2 := '0';
                    RP_chk2 := NOW - ((2 * tCK) - tWR);
                    Write_precharge(2) := '0';
                END IF;
            END IF;
            IF ((Write_precharge(3) = '1') AND (NOW - RAS_chk3 >= tRAS)) THEN
                IF ((Burst_length_2 = '1' AND Count_precharge (3) >= 4) OR
                    (Burst_length_4 = '1' AND Count_precharge (3) >= 5) OR
                    (Burst_length_8 = '1' AND Count_precharge (3) >= 7)) THEN
                    Pc_b3 := '1';
                    Act_b3 := '0';
                    RP_chk3 := NOW - ((2 * tCK) - tWR);
                    Write_precharge(3) := '0';
                END IF;
            END IF;
        END IF;
        
        --
        -- DLL Counter
        --
        IF Sys_clk'EVENT AND Sys_clk = '1' THEN
            IF (DLL_Reset = '1' AND DLL_done = '0') THEN
                DLL_count := DLL_count + 1;
                IF (DLL_count >= 200) THEN
                    DLL_done := '1';
                END IF;
            END IF;
        END IF;

        --
        -- Control Logic
        --
        IF Sys_clk'EVENT AND Sys_clk = '1' THEN
            -- Auto Refresh
            IF Aref_enable = '1' THEN
                -- Auto Refresh to Auto Refresh
                ASSERT (NOW - RFC_chk >= tRFC)
                    REPORT "tRFC violation during Auto Refresh"
                    SEVERITY WARNING;

                -- Precharge to Auto Refresh
                ASSERT ((NOW - RP_chk0 >= tRP) AND (NOW - RP_chk1 >= tRP) AND
                        (NOW - RP_chk2 >= tRP) AND (NOW - RP_chk3 >= tRP))
                    REPORT "tRP violation during Auto Refresh"
                    SEVERITY WARNING;

                -- Precharge to Auto Refresh
                ASSERT (Pc_b0 = '1' AND Pc_b1 = '1' AND Pc_b2 = '1' AND Pc_b3 = '1')
                    REPORT "All banks must be Precharge before Auto Refresh"
                    SEVERITY WARNING;

                -- Record current tRFC time
                RFC_chk := NOW;
            END IF;

            -- Extended Load Mode Register
            IF Ext_mode_enable = '1' THEN
                IF (Pc_b0 = '1' AND Pc_b1 = '1' AND Pc_b2 = '1' AND Pc_b3 = '1') THEN
                    IF (Addr (0) = '0') THEN
                        DLL_enable := '1';
                    ELSE
                        DLL_enable := '0';
                    END IF;
                END IF;
                
                -- Precharge to EMR
                ASSERT (Pc_b0 = '1' AND Pc_b1 = '1' AND Pc_b2 = '1' AND Pc_b3 = '1')
                    REPORT "All bank must be Precharged before Extended Mode Register"
                    SEVERITY WARNING;
                
                -- Precharge to EMR
                ASSERT ((NOW - RP_chk0 >= tRP) AND (NOW - RP_chk1 >= tRP) AND
                        (NOW - RP_chk2 >= tRP) AND (NOW - RP_chk3 >= tRP))
                    REPORT "tRP violation during Extended Load Register"
                    SEVERITY WARNING;

                -- LMR/EMR to EMR
                ASSERT (NOW - MRD_chk >= tMRD)
                    REPORT "tMRD violation during Extended Mode Register"
                    SEVERITY WARNING;

                -- Record current tMRD time
                MRD_chk := NOW;
            END IF;

            -- Load Mode Register
            IF Mode_reg_enable = '1' THEN
                -- Register mode
                Mode_reg <= Addr;
                
                -- DLL Reset
                IF (DLL_enable = '1' AND Addr (8) = '1') THEN
                    DLL_reset := '1';
                    DLL_done  := '0';
                    DLL_count := 0;
                ELSIF (DLL_enable = '1' AND DLL_reset = '0' AND Addr (8) = '0') THEN
                    ASSERT (FALSE)
                        REPORT "DLL is ENABLE: DLL RESET is require"
                        SEVERITY WARNING;
                ELSIF (DLL_enable = '0' AND Addr (8) = '1') THEN
                    ASSERT (FALSE)
                        REPORT "DLL is DISABLE: DLL RESET will be ignored"
                        SEVERITY WARNING;
                END IF;

                -- Precharge to LMR
                ASSERT (Pc_b0 = '1' AND Pc_b1 = '1' AND Pc_b2 = '1' AND Pc_b3 = '1')
                    REPORT "All bank must be Precharged before Load Mode Register"
                    SEVERITY WARNING;

                -- Precharge to EMR
                ASSERT ((NOW - RP_chk0 >= tRP) AND (NOW - RP_chk1 >= tRP) AND
                        (NOW - RP_chk2 >= tRP) AND (NOW - RP_chk3 >= tRP))
                    REPORT "tRP violation during Load Mode Register"
                    SEVERITY WARNING;

                -- LMR/ELMR to LMR
                ASSERT (NOW - MRD_chk >= tMRD)
                    REPORT "tMRD violation during Load Mode Register"
                    SEVERITY WARNING;

                -- Check for invalid Burst Length
                ASSERT ((Addr (2 DOWNTO 0) = "001") OR      -- BL = 2
                        (Addr (2 DOWNTO 0) = "010") OR      -- BL = 4
                        (Addr (2 DOWNTO 0) = "011"))        -- BL = 8
                    REPORT "Invalid Burst Length during Load Mode Register"
                    SEVERITY WARNING;

                -- Check for invalid CAS Latency
                ASSERT ((Addr (6 DOWNTO 4) = "010") OR      -- CL = 2.0
                        (Addr (6 DOWNTO 4) = "110"))        -- CL = 2.5
                    REPORT "Invalid CAS Latency during Load Mode Register"
                    SEVERITY WARNING;

                -- Record current tMRD time
                MRD_chk := NOW;
            END IF;

            -- Active Block (latch Bank and Row Address)
            IF Active_enable = '1' THEN
                -- Activate an OPEN bank can corrupt data
                ASSERT ((Ba = "00" AND Act_b0 = '0') OR
                        (Ba = "01" AND Act_b1 = '0') OR
                        (Ba = "10" AND Act_b2 = '0') OR
                        (Ba = "11" AND Act_b3 = '0'))
                    REPORT "Bank is already activated - data can be corrupted"
                    SEVERITY WARNING;

                -- Activate Bank 0
                IF Ba = "00" AND Pc_b0 = '1' THEN
                    -- Activate to Activate (same bank)
                    ASSERT (NOW - RC_chk0 >= tRC)
                        REPORT "tRC violation during Activate Bank 0"
                        SEVERITY WARNING;

                    -- Precharge to Active
                    ASSERT (NOW - RP_chk0 >= tRP)
                        REPORT "tRP violation during Activate Bank 0"
                        SEVERITY WARNING;

                    -- Record Variables for checking violation
                    Act_b0 := '1';
                    Pc_b0 := '0';
                    B0_row_addr := Addr;
                    RC_chk0 := NOW;
                    RCD_chk0 := NOW;
                    RAS_chk0 := NOW;
                    RAP_chk0 := NOW;
                END IF;

                -- Activate Bank 1
                IF Ba = "01" AND Pc_b1 = '1' THEN
                    -- Activate to Activate (same bank)
                    ASSERT (NOW - RC_chk1 >= tRC)
                        REPORT "tRC violation during Activate Bank 1"
                        SEVERITY WARNING;

                    -- Precharge to Active
                    ASSERT (NOW - RP_chk1 >= tRP)
                        REPORT "tRP violation during Activate Bank 1"
                        SEVERITY WARNING;

                    -- Record Variables for checking violation
                    Act_b1 := '1';
                    Pc_b1 := '0';
                    B1_row_addr := Addr;
                    RC_chk1 := NOW;
                    RCD_chk1 := NOW;
                    RAS_chk1 := NOW;
                    RAP_chk1 := NOW;
                END IF;

                -- Activate Bank 2
                IF Ba = "10" AND Pc_b2 = '1' THEN
                    -- Activate to Activate (same bank)
                    ASSERT (NOW - RC_chk2 >= tRC)
                        REPORT "tRC violation during Activate Bank 2"
                        SEVERITY WARNING;

                    -- Precharge to Active
                    ASSERT (NOW - RP_chk2 >= tRP)
                        REPORT "tRP violation during Activate Bank 2"
                        SEVERITY WARNING;

                    -- Record Variables for checking violation
                    Act_b2 := '1';
                    Pc_b2 := '0';
                    B2_row_addr := Addr;
                    RC_chk2 := NOW;
                    RCD_chk2 := NOW;
                    RAS_chk2 := NOW;
                    RAP_chk2 := NOW;
                END IF;

                -- Activate Bank 3
                IF Ba = "11" AND Pc_b3 = '1' THEN
                    -- Activate to Activate (same bank)
                    ASSERT (NOW - RC_chk3 >= tRC)
                        REPORT "tRC violation during Activate Bank 3"
                        SEVERITY WARNING;

                    -- Precharge to Active
                    ASSERT (NOW - RP_chk3 >= tRP)
                        REPORT "tRP violation during Activate Bank 3"
                        SEVERITY WARNING;

                    -- Record Variables for checking violation
                    Act_b3 := '1';
                    Pc_b3 := '0';
                    B3_row_addr := Addr;
                    RC_chk3 := NOW;
                    RCD_chk3 := NOW;
                    RAS_chk3 := NOW;
                    RAP_chk3 := NOW;
                END IF;

                -- Activate Bank A to Activate Bank B
                IF (Prev_bank /= Ba) THEN
                    ASSERT (NOW - RRD_chk >= tRRD)
                        REPORT "tRRD violation during Activate"
                        SEVERITY WARNING;
                END IF;
                
                -- AutoRefresh to Activate
                ASSERT (NOW - RFC_chk >= tRFC)
                    REPORT "tRFC violation during Activate"
                    SEVERITY WARNING;
                
                -- Record Variables for Checking Violation
                RRD_chk := NOW;
                Prev_bank := Ba;
            END IF;

            -- Precharge Block - Consider NOP if bank already precharged or in process of precharging
            IF Prech_enable = '1' THEN
                -- EMR or LMR to Precharge
                ASSERT (NOW - MRD_chk >= tMRD)
                    REPORT "tMRD violation during Precharge"
                    SEVERITY WARNING;

                -- Precharge Bank 0
                IF ((Addr (10) = '1' OR (Addr (10) = '0' AND Ba = "00")) AND Act_b0 = '1') THEN
                    Act_b0 := '0';
                    Pc_b0 := '1';
                    RP_chk0 := NOW;

                    -- Activate to Precharge bank 0
                    ASSERT (NOW - RAS_chk0 >= tRAS)
                        REPORT "tRAS violation during Precharge"
                        SEVERITY WARNING;

                    -- tWR violation check for Write
                    ASSERT (NOW - WR_chk0 >= tWR)
                        REPORT "tWR violation during Precharge"
                        SEVERITY WARNING;
                END IF;

                -- Precharge Bank 1
                IF ((Addr (10) = '1' OR (Addr (10) = '0' AND Ba = "01")) AND Act_b1 = '1') THEN
                    Act_b1 := '0';
                    Pc_b1 := '1';
                    RP_chk1 := NOW;

                    -- Activate to Precharge
                    ASSERT (NOW - RAS_chk1 >= tRAS)
                        REPORT "tRAS violation during Precharge"
                        SEVERITY WARNING;

                    -- tWR violation check for Write
                    ASSERT (NOW - WR_chk1 >= tWR)
                        REPORT "tWR violation during Precharge"
                        SEVERITY WARNING;
                END IF;

                -- Precharge Bank 2
                IF ((Addr (10) = '1' OR (Addr (10) = '0' AND Ba = "10")) AND Act_b2 = '1') THEN
                    Act_b2 := '0';
                    Pc_b2 := '1';
                    RP_chk2 := NOW;

                    -- Activate to Precharge
                    ASSERT (NOW - RAS_chk2 >= tRAS)
                        REPORT "tRAS violation during Precharge"
                        SEVERITY WARNING;

                    -- tWR violation check for Write
                    ASSERT (NOW - WR_chk2 >= tWR)
                        REPORT "tWR violation during Precharge"
                        SEVERITY WARNING;
                END IF;

                -- Precharge Bank 3
                IF ((Addr (10) = '1' OR (Addr (10) = '0' AND Ba = "11")) AND Act_b3 = '1') THEN
                    Act_b3 := '0';
                    Pc_b3 := '1';
                    RP_chk3 := NOW;

                    -- Activate to Precharge
                    ASSERT (NOW - RAS_chk3 >= tRAS)
                        REPORT "tRAS violation during Precharge"
                        SEVERITY WARNING;

                    -- tWR violation check for Write
                    ASSERT (NOW - WR_chk3 >= tWR)
                        REPORT "tWR violation during Precharge"
                        SEVERITY WARNING;
                END IF;

                -- Pipeline for READ
                IF CAS_latency_15 = '1' THEN
                    A10_precharge  (3) := Addr(10);
                    Bank_precharge (3) := Ba;
                    Cmnd_precharge (3) := '1';
                ELSIF CAS_latency_2 = '1' THEN
                    A10_precharge  (4) := Addr(10);
                    Bank_precharge (4) := Ba;
                    Cmnd_precharge (4) := '1';
                ELSIF CAS_latency_25 = '1' THEN
                    A10_precharge  (5) := Addr(10);
                    Bank_precharge (5) := Ba;
                    Cmnd_precharge (5) := '1';
                ELSIF CAS_latency_3 = '1' THEN
                    A10_precharge  (6) := Addr(10);
                    Bank_precharge (6) := Ba;
                    Cmnd_precharge (6) := '1';
                ELSIF CAS_latency_4 = '1' THEN
                    A10_precharge  (8) := Addr(10);
                    Bank_precharge (8) := Ba;
                    Cmnd_precharge (8) := '1';
                END IF;
            END IF;

            -- Burst Terminate
            IF Burst_term = '1' THEN
                -- Pipeline for Read
                IF CAS_latency_15 = '1' THEN
                    Cmnd_bst (3) := '1';
                ELSIF CAS_latency_2 = '1' THEN
                    Cmnd_bst (4) := '1';
                ELSIF CAS_latency_25 = '1' THEN
                    Cmnd_bst (5) := '1';
                ELSIF CAS_latency_3 = '1' THEN
                    Cmnd_bst (6) := '1';
                ELSIF CAS_latency_4 = '1' THEN
                    Cmnd_bst (8) := '1';
                END IF;

                -- Terminate Write
                ASSERT (Data_in_enable = '0')
                    REPORT "It's illegal to Burst Terminate a Write"
                    SEVERITY WARNING;

                -- Terminate Read with Auto Precharge
                ASSERT (Read_precharge (0) = '0' AND Read_precharge (1) = '0' AND
                        Read_precharge (2) = '0' AND Read_precharge (3) = '0')
                    REPORT "It's illegal to Burst Terminate a Read with Auto Precharge"
                    SEVERITY WARNING;
            END IF;

            -- Read Command
            IF Read_enable = '1' THEN
                -- CAS Latency Pipeline
                IF Cas_latency_15 = '1' THEN
                    Read_cmnd (3) := '1';
                    Read_bank (3) := Ba;
                    Read_cols (3) := Addr (8 DOWNTO 0);
                ELSIF Cas_latency_2 = '1' THEN
                    Read_cmnd (4) := '1';
                    Read_bank (4) := Ba;
                    Read_cols (4) := Addr (8 DOWNTO 0);
                ELSIF Cas_latency_25 = '1' THEN
                    Read_cmnd (5) := '1';
                    Read_bank (5) := Ba;
                    Read_cols (5) := Addr (8 DOWNTO 0);
                ELSIF Cas_latency_3 = '1' THEN
                    Read_cmnd (6) := '1';
                    Read_bank (6) := Ba;
                    Read_cols (6) := Addr (8 DOWNTO 0);
                ELSIF Cas_latency_4 = '1' THEN
                    Read_cmnd (8) := '1';
                    Read_bank (8) := Ba;
                    Read_cols (8) := Addr (8 DOWNTO 0);
                END IF;

                -- Write to Read: Terminate Write Immediately
                IF Data_in_enable = '1' THEN
                    Data_in_enable := '0';
                END IF;

                -- Interrupting a Read with Auto Precharge (same bank only)
                ASSERT (Read_precharge(CONV_INTEGER(Ba)) = '0')
                    REPORT "It's illegal to interrupt a Read with Auto Precharge"
                    SEVERITY WARNING;

                -- Activate to Read
                ASSERT ((Ba = "00" AND Act_b0 = '1') OR
                        (Ba = "01" AND Act_b1 = '1') OR
                        (Ba = "10" AND Act_b2 = '1') OR
                        (Ba = "11" AND Act_b3 = '1'))
                    REPORT "Bank is not Activated for Read"
                    SEVERITY WARNING;

                -- Activate to Read without Auto Precharge
                IF Addr (10) = '0' THEN
                    ASSERT ((Ba = "00" AND NOW - RCD_chk0 >= tRCD) OR
                            (Ba = "01" AND NOW - RCD_chk1 >= tRCD) OR
                            (Ba = "10" AND NOW - RCD_chk2 >= tRCD) OR
                            (Ba = "11" AND NOW - RCD_chk3 >= tRCD))
                        REPORT "tRCD violation during Read"
                        SEVERITY WARNING;
                END IF;

                -- Activate to Read with Auto Precharge
                IF Addr (10) = '1' THEN
                    ASSERT ((Ba = "00" AND NOW - RAP_chk0 >= tRAP) OR
                            (Ba = "01" AND NOW - RAP_chk1 >= tRAP) OR
                            (Ba = "10" AND NOW - RAP_chk2 >= tRAP) OR
                            (Ba = "11" AND NOW - RAP_chk3 >= tRAP))
                        REPORT "tRAP violation during Read"
                        SEVERITY WARNING;
                END IF;

                -- Auto precharge
                IF Addr (10) = '1' THEN
                    Read_precharge (Conv_INTEGER(Ba)) := '1';
                    Count_precharge (Conv_INTEGER(Ba)) := 0;
                END IF;

                -- DLL Check
                IF (DLL_reset = '1') THEN
                    ASSERT (DLL_done = '1')
                        REPORT "DLL RESET not complete"
                        SEVERITY WARNING;
                END IF;
            END IF;

            -- Write Command
            IF Write_enable = '1' THEN
                -- Pipeline for Write
                Write_cmnd (2) := '1';
                Write_bank (2) := Ba;
                Write_cols (2) := Addr (8 DOWNTO 0);

                -- Interrupting a Write with Auto Precharge (same bank only)
                ASSERT (Write_precharge(CONV_INTEGER(Ba)) = '0')
                    REPORT "It's illegal to interrupt a Write with Auto Precharge"
                    SEVERITY WARNING;

                -- Activate to Write
                ASSERT ((Ba = "00" AND Act_b0 = '1') OR
                        (Ba = "01" AND Act_b1 = '1') OR
                        (Ba = "10" AND Act_b2 = '1') OR
                        (Ba = "11" AND Act_b3 = '1'))
                    REPORT "Bank is not Activated for Write"
                    SEVERITY WARNING;

                -- Activate to Write
                ASSERT ((Ba = "00" AND NOW - RCD_chk0 >= tRCD) OR
                        (Ba = "01" AND NOW - RCD_chk1 >= tRCD) OR
                        (Ba = "10" AND NOW - RCD_chk2 >= tRCD) OR
                        (Ba = "11" AND NOW - RCD_chk3 >= tRCD))
                    REPORT "tRCD violation during Write"
                    SEVERITY WARNING;

                -- Auto precharge
                IF Addr (10) = '1' THEN
                    Write_precharge (Conv_INTEGER(Ba)) := '1';
                    Count_precharge (Conv_INTEGER(Ba)) := 0;
                END IF;
            END IF;
        END IF;

        IF not file_loaded THEN 		--'
	    file_loaded := true;
            WHILE NOT endfile(file_load) LOOP
                readline(file_load, l);
                read(l, ch);
                if (ch /= 'S') or (ch /= 's') then
                  hexread(l, rectype);
                  hexread(l, reclen);
		  recaddr := (others => '0');
		  case rectype is 
		  when "0001" =>
                    hexread(l, recaddr(15 downto 0));
		  when "0010" =>
                    hexread(l, recaddr(23 downto 0));
		  when "0011" =>
                    hexread(l, recaddr);
		  when "0111" =>
                    hexread(l, recaddr);
--		    if (index = 0) then print("Start address : " & tost(recaddr)); end if;
		    next;
		  when others => next;
		  end case;
	 	  case bbits is
		  when 64 =>	-- 64-bit bank with four 16-bit DDRs
		    recaddr(31 downto 27) := (others => '0');
                    hexread(l, recdata);
		    Bank_Load := recaddr(26 downto 25);
		    Rows_Load := recaddr(24 downto 12);
		    Cols_Load := recaddr(11 downto 3);
                    Init_mem (Bank_Load, To_Integer(Rows_Load));
                    IF Bank_Load = "00" THEN
		      for i in 0 to 1 loop
                        Bank0 (To_Integer(Rows_Load)) (To_Integer(Cols_Load)+i) := (recdata(i*64+index*16 to i*64+index*16+15));
		      end loop;
                    ELSIF Bank_Load = "01" THEN
		      for i in 0 to 3 loop
                        Bank1 (To_Integer(Rows_Load)) (To_Integer(Cols_Load)+i) := (recdata(i*64+index*16 to i*64+index*16+15));
		      end loop;
                    ELSIF Bank_Load = "10" THEN
		      for i in 0 to 3 loop
                        Bank2 (To_Integer(Rows_Load)) (To_Integer(Cols_Load)+i) := (recdata(i*64+index*16 to i*64+index*16+15));
		      end loop;
                    ELSIF Bank_Load = "11" THEN
		      for i in 0 to 3 loop
                        Bank3 (To_Integer(Rows_Load)) (To_Integer(Cols_Load)+i) := (recdata(i*64+index*16 to i*64+index*16+15));
		      end loop;
                    END IF;

		  when 32 =>	-- 32-bit bank with two 16-bit DDRs
		    recaddr(31 downto 26) := (others => '0');
                    hexread(l, recdata);
		    Bank_Load := recaddr(25 downto 24);
		    Rows_Load := recaddr(23 downto 11);
		    Cols_Load := recaddr(10 downto 2);
                    Init_mem (Bank_Load, To_Integer(Rows_Load));

                    IF Bank_Load = "00" THEN
		      for i in 0 to 3 loop
                        Bank0 (To_Integer(Rows_Load)) (To_Integer(Cols_Load)+i) := (recdata(i*32+index*16 to i*32+index*16+15));
		      end loop;
                    ELSIF Bank_Load = "01" THEN
		      for i in 0 to 3 loop
                        Bank1 (To_Integer(Rows_Load)) (To_Integer(Cols_Load)+i) := (recdata(i*32+index*16 to i*32+index*16+15));
		      end loop;
                    ELSIF Bank_Load = "10" THEN
		      for i in 0 to 3 loop
                        Bank2 (To_Integer(Rows_Load)) (To_Integer(Cols_Load)+i) := (recdata(i*32+index*16 to i*32+index*16+15));
		      end loop;
                    ELSIF Bank_Load = "11" THEN
		      for i in 0 to 3 loop
                        Bank3 (To_Integer(Rows_Load)) (To_Integer(Cols_Load)+i) := (recdata(i*32+index*16 to i*32+index*16+15));
		      end loop;
                    END IF;

		  when others =>	-- 16-bit bank with one 16-bit DDR
                    hexread(l, recdata);
		    recaddr(31 downto 25) := (others => '0');
		    Bank_Load := recaddr(24 downto 23);
		    Rows_Load := recaddr(22 downto 10);
		    Cols_Load := recaddr(9 downto 1);
                    Init_mem (Bank_Load, To_Integer(Rows_Load));

                    IF Bank_Load = "00" THEN
		      for i in 0 to 3 loop
                        Bank0 (To_Integer(Rows_Load)) (To_Integer(Cols_Load)+i) := (recdata(i*16 to i*16+15));
                        Bank0 (To_Integer(Rows_Load)) (To_Integer(Cols_Load)+i+4) := (recdata((i+4)*16 to (i+4)*16+15));
		      end loop;
                    ELSIF Bank_Load = "01" THEN
		      for i in 0 to 3 loop
                        Bank1 (To_Integer(Rows_Load)) (To_Integer(Cols_Load)+i) := (recdata(i*16 to i*16+15));
                        Bank1 (To_Integer(Rows_Load)) (To_Integer(Cols_Load)+i+4) := (recdata((i+4)*16 to (i+4)*16+15));
		      end loop;
                    ELSIF Bank_Load = "10" THEN
		      for i in 0 to 3 loop
                        Bank2 (To_Integer(Rows_Load)) (To_Integer(Cols_Load)+i) := (recdata(i*16 to i*16+15));
                        Bank2 (To_Integer(Rows_Load)) (To_Integer(Cols_Load)+i+4) := (recdata((i+4)*16 to (i+4)*16+15));
		      end loop;
                    ELSIF Bank_Load = "11" THEN
		      for i in 0 to 3 loop
                        Bank3 (To_Integer(Rows_Load)) (To_Integer(Cols_Load)+i) := (recdata(i*16 to i*16+15));
                        Bank3 (To_Integer(Rows_Load)) (To_Integer(Cols_Load)+i+4) := (recdata((i+4)*16 to (i+4)*16+15));
		      end loop;
                    END IF;

                  END case;
                END IF;
            END LOOP;
          END IF;
    
    END PROCESS;

    --
    -- Dqs Receiver
    --
    dqs_rcvrs : PROCESS
        VARIABLE Dm_temp : STD_LOGIC_VECTOR (1 DOWNTO 0);
        VARIABLE Dq_temp : STD_LOGIC_VECTOR (data_bits - 1 DOWNTO 0);
    BEGIN
        WAIT ON Dqs;
        -- Latch data at posedge Dqs
        IF Dqs'EVENT AND Dqs (1) = '1' AND Dqs (0) = '1' THEN
            Dq_temp := Dq;
            Dm_temp := Dm;
        END IF;
        -- Latch data at negedge Dqs
        IF Dqs'EVENT AND Dqs (1) = '0' AND Dqs (0) = '0' THEN
            Dq_pair <= (Dq & Dq_temp);
            Dm_pair <= (Dm & Dm_temp);
        END IF;
    END PROCESS;

    --
    -- Setup timing checks
    --
    Setup_check : PROCESS
    BEGIN
        WAIT ON Sys_clk;
        IF Sys_clk'EVENT AND Sys_clk = '1' THEN
            ASSERT(Cke'LAST_EVENT >= tIS)
                REPORT "CKE Setup time violation -- tIS"
                SEVERITY WARNING;
            ASSERT(Cs_n'LAST_EVENT >= tIS)
                REPORT "CS# Setup time violation -- tIS"
                SEVERITY WARNING;
            ASSERT(Cas_n'LAST_EVENT >= tIS)
                REPORT "CAS# Setup time violation -- tIS"
                SEVERITY WARNING;
            ASSERT(Ras_n'LAST_EVENT >= tIS)
                REPORT "RAS# Setup time violation -- tIS"
                SEVERITY WARNING;
            ASSERT(We_n'LAST_EVENT >= tIS)
                REPORT "WE# Setup time violation -- tIS"
                SEVERITY WARNING;
            ASSERT(Addr'LAST_EVENT >= tIS)
                REPORT "ADDR Setup time violation -- tIS"
                SEVERITY WARNING;
            ASSERT(Ba'LAST_EVENT >= tIS)
                REPORT "BA Setup time violation -- tIS"
                SEVERITY WARNING;
        END IF;   
    END PROCESS;

    --
    -- Hold timing checks
    --
    Hold_check : PROCESS
    BEGIN
        WAIT ON Sys_clk'DELAYED (tIH);
        IF Sys_clk'DELAYED (tIH) = '1' THEN
            ASSERT(Cke'LAST_EVENT >= tIH)
                REPORT "CKE Hold time violation -- tIH"
                SEVERITY WARNING;
            ASSERT(Cs_n'LAST_EVENT >= tIH)
                REPORT "CS# Hold time violation -- tIH"
                SEVERITY WARNING;
            ASSERT(Cas_n'LAST_EVENT >= tIH)
                REPORT "CAS# Hold time violation -- tIH"
                SEVERITY WARNING;
            ASSERT(Ras_n'LAST_EVENT >= tIH)
                REPORT "RAS# Hold time violation -- tIH"
                SEVERITY WARNING;
            ASSERT(We_n'LAST_EVENT >= tIH)
                REPORT "WE# Hold time violation -- tIH"
                SEVERITY WARNING;
            ASSERT(Addr'LAST_EVENT >= tIH)
                REPORT "ADDR Hold time violation -- tIH"
                SEVERITY WARNING;
            ASSERT(Ba'LAST_EVENT >= tIH)
                REPORT "BA Hold time violation -- tIH"
                SEVERITY WARNING;
        END IF;   
    END PROCESS;

END behave;
