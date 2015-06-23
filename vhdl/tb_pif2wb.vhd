library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
USE IEEE.STD_LOGIC_TEXTIO.ALL;
USE STD.TEXTIO.ALL;

ENTITY test_bridge IS
END test_bridge;

ARCHITECTURE testbench_arch OF test_bridge IS
    FILE RESULTS: TEXT OPEN WRITE_MODE IS "results.txt";

    COMPONENT top
        PORT (
            SCLK : In std_logic;
            CLKETH : In std_logic;
            SReset : In std_logic;
            PIReqVALID : In std_logic;
            PIReqCNTL : In std_logic_vector (7 DownTo 0);
            PIReqADRS : In std_logic_vector (31 DownTo 0);
            PIReqDATA : In std_logic_vector (31 DownTo 0);
            PIReqDataBE : In std_logic_vector (3 DownTo 0);
            PIRespRDY : In std_logic;
            probe_mtxd_pad_o : Out std_logic_vector (3 DownTo 0);
            probe_mtxen_pad_o : Out std_logic;
            mtxerr_pad_o : Out std_logic;
            probe_mrxd_pad_i : In std_logic_vector (3 DownTo 0);
            probe_mrxdv_pad_i : In std_logic;
            probe_mrxerr_pad_i : In std_logic;
            probe_mcoll_pad_i : In std_logic;
            probe_mcrs_pad_i : In std_logic;
            probe_mdc_pad_o : Out std_logic;
            probe_md_pad_i : In std_logic;
            probe_md_pad_o : Out std_logic;
            probe_md_padoe_o : Out std_logic;
            interrupt : Out std_logic
        );
    END COMPONENT;

    SIGNAL SCLK : std_logic := '0';
    SIGNAL CLKETH : std_logic := '0';
    SIGNAL SReset : std_logic := '0';
    SIGNAL PIReqVALID : std_logic := '0';
    SIGNAL PIReqCNTL : std_logic_vector (7 DownTo 0) := "00000000";
    SIGNAL PIReqADRS : std_logic_vector (31 DownTo 0) := "00000000000000000000000000000000";
    SIGNAL PIReqDATA : std_logic_vector (31 DownTo 0) := "00000000000000000000000000000000";
    SIGNAL PIReqDataBE : std_logic_vector (3 DownTo 0) := "0000";
    SIGNAL PIRespRDY : std_logic := '0';
    SIGNAL probe_mtxd_pad_o : std_logic_vector (3 DownTo 0) := "0000";
    SIGNAL probe_mtxen_pad_o : std_logic := '0';
    SIGNAL mtxerr_pad_o : std_logic := '0';
    SIGNAL probe_mrxd_pad_i : std_logic_vector (3 DownTo 0) := "0000";
    SIGNAL probe_mrxdv_pad_i : std_logic := '0';
    SIGNAL probe_mrxerr_pad_i : std_logic := '0';
    SIGNAL probe_mcoll_pad_i : std_logic := '0';
    SIGNAL probe_mcrs_pad_i : std_logic := '0';
    SIGNAL probe_mdc_pad_o : std_logic := '0';
    SIGNAL probe_md_pad_i : std_logic := '0';
    SIGNAL probe_md_pad_o : std_logic := '0';
    SIGNAL probe_md_padoe_o : std_logic := '0';
    SIGNAL interrupt : std_logic := '0';

    constant PERIOD_CLKETH : time := 40 ns;
    constant DUTY_CYCLE_CLKETH : real := 0.5;
    constant OFFSET_CLKETH : time := 100 ns;
    constant PERIOD_SCLK : time := 20 ns;
    constant DUTY_CYCLE_SCLK : real := 0.5;
    constant OFFSET_SCLK : time := 100 ns;

    BEGIN
        UUT : top
        PORT MAP (
            SCLK => SCLK,
            CLKETH => CLKETH,
            SReset => SReset,
            PIReqVALID => PIReqVALID,
            PIReqCNTL => PIReqCNTL,
            PIReqADRS => PIReqADRS,
            PIReqDATA => PIReqDATA,
            PIReqDataBE => PIReqDataBE,
            PIRespRDY => PIRespRDY,
            probe_mtxd_pad_o => probe_mtxd_pad_o,
            probe_mtxen_pad_o => probe_mtxen_pad_o,
            mtxerr_pad_o => mtxerr_pad_o,
            probe_mrxd_pad_i => probe_mrxd_pad_i,
            probe_mrxdv_pad_i => probe_mrxdv_pad_i,
            probe_mrxerr_pad_i => probe_mrxerr_pad_i,
            probe_mcoll_pad_i => probe_mcoll_pad_i,
            probe_mcrs_pad_i => probe_mcrs_pad_i,
            probe_mdc_pad_o => probe_mdc_pad_o,
            probe_md_pad_i => probe_md_pad_i,
            probe_md_pad_o => probe_md_pad_o,
            probe_md_padoe_o => probe_md_padoe_o,
            interrupt => interrupt
        );

        PROCESS    -- clock process for CLK ETHERNET CONTROLLER
        BEGIN
            WAIT for OFFSET_CLKETH;
            CLOCK_LOOP : LOOP
                CLKETH <= '0';
                WAIT FOR (PERIOD_CLKETH - (PERIOD_CLKETH * DUTY_CYCLE_CLKETH));
                CLKETH <= '1';
                WAIT FOR (PERIOD_CLKETH * DUTY_CYCLE_CLKETH);
            END LOOP CLOCK_LOOP;
        END PROCESS;

        PROCESS    -- clock process for SCLK
        BEGIN
            WAIT for OFFSET_SCLK;
            CLOCK_LOOP : LOOP
                SCLK <= '0';
                WAIT FOR (PERIOD_SCLK - (PERIOD_SCLK * DUTY_CYCLE_SCLK));
                SCLK <= '1';
                WAIT FOR (PERIOD_SCLK * DUTY_CYCLE_SCLK);
            END LOOP CLOCK_LOOP;
        END PROCESS;

        PROCESS    -- Process for CLKETH
            BEGIN
                WAIT FOR 2040 ns;

            END PROCESS;

            PROCESS    -- Process for SCLK
                BEGIN
                    -- -------------  Current Time:  95ns Reset the System
                    WAIT FOR 95 ns;
                    SReset <= '1';
                    PIRespRDY <= '1';
                    -- ------------------------------------- End reset
                    -- -------------  Current Time:  135ns
                    WAIT FOR 40 ns;
                    SReset <= '0';
                    -- ------------------------------------- Single Read at Address 0x60000194
                    -- -------------  Current Time:  175ns   Test address out of range
                    WAIT FOR 40 ns;
                    PIReqVALID <= '1';
                    PIReqCNTL <= "00000001";
                    PIReqADRS <= "01100000000000000000100100010000";
                    PIReqDATA <= "10000000000000000000000000000000";
                    PIReqDataBE <= "1111";
                    -- ------------------------------------- End of Single Read
                    -- -------------  Current Time:  195ns
                    WAIT FOR 20 ns;
                    PIReqVALID <= '0';
                    PIReqCNTL <= "11111111";
                    PIReqDataBE <= "0000";
                    -- ------------------------------------- Single Read at Address 0x80000000
                    -- -------------  Current Time:  235ns   First Ethernet register	
                    WAIT FOR 40 ns;
                    PIReqVALID <= '1';
                    PIReqCNTL <= "00000001";
                    PIReqADRS <= "10000000000000000000000000000000";
                    PIReqDataBE <= "1111";
                    -- ------------------------------------- End of Single Read
                    -- -------------  Current Time:  255ns
                    WAIT FOR 20 ns;
                    PIReqVALID <= '0';
                    PIReqCNTL <= "11111111";
                    PIReqDataBE <= "0000";
                    -- ------------------------------------- Single Write at Address 0x80000000
                    -- -------------  Current Time:  295ns
                    WAIT FOR 40 ns;
                    PIReqVALID <= '1';
                    PIReqCNTL <= "10000001";
                    PIReqDATA <= "00000000000000001111111111111111";
                    PIReqDataBE <= "1111";
                    -- ------------------------------------- End of Single Write
                    -- -------------  Current Time:  315ns
                    WAIT FOR 20 ns;
                    PIReqVALID <= '0';
                    PIReqCNTL <= "11111111";
                    PIReqDataBE <= "0000";
                    -- ------------------------------------- Single Read at Address 0x80000000
                    -- -------------  Current Time:  355ns
                    WAIT FOR 40 ns;
                    PIReqVALID <= '1';
                    PIReqCNTL <= "00000001";
                    PIReqDATA <= "10000000000000000000000000000000";
                    PIReqDataBE <= "1111";
                    -- ------------------------------------- End of Single Read
                    -- -------------  Current Time:  375ns
                    WAIT FOR 20 ns;
                    PIReqVALID <= '0';
                    PIReqCNTL <= "11111111";
                    PIReqDataBE <= "0000";
                    -- ------------------------------------- Single Write at Address 0x80000001
                    -- -------------  Current Time:  415ns
                    WAIT FOR 40 ns;
                    PIReqVALID <= '1';
                    PIReqCNTL <= "10000001";
                    PIReqADRS <= "10000000000000000000000000000001";
                    PIReqDATA <= "00000000000000001111111111111111";
                    PIReqDataBE <= "1111";
                    -- ------------------------------------- End of Single Write
                    -- -------------  Current Time:  435ns
                    WAIT FOR 20 ns;
                    PIReqVALID <= '0';
                    PIReqCNTL <= "11111111";
                    PIReqDataBE <= "0000";
                    -- ------------------------------------- Single Read at Address 0x80000001
                    -- -------------  Current Time:  475ns
                    WAIT FOR 40 ns;
                    PIReqVALID <= '1';
                    PIReqCNTL <= "00000001";
                    PIReqDATA <= "10000000000000000000000000000000";
                    PIReqDataBE <= "1111";
                    -- ------------------------------------- End of Single Read
                    -- -------------  Current Time:  495ns
                    WAIT FOR 20 ns;
                    PIReqVALID <= '0';
                    PIReqCNTL <= "11111111";
                    PIReqDataBE <= "0000";
                    -- ------------------------------------- Block Read. Start Address 0x80000002
                    -- -------------  Current Time:  575ns   Number of Transfers 2
                    WAIT FOR 80 ns;
                    PIReqVALID <= '1';
                    PIReqCNTL <= "00010001";
                    PIReqADRS <= "10000000000000000000000000000010";
                    PIReqDataBE <= "1111";
                    -- -------------------------------------
                    -- -------------  Current Time:  595ns
                    WAIT FOR 20 ns;
                    PIReqVALID <= '0';
                    PIReqCNTL <= "11111111";
                    PIReqADRS <= "01100000000000000000000110010100";
                    PIReqDataBE <= "0000";
                    -- -------------------------------------
                    -- -------------  Current Time:  635ns
                    WAIT FOR 40 ns;
                    PIReqDataBE <= "1111";
                    -- ------------------------------------- End of Block Read
                    -- -------------  Current Time:  655ns
                    WAIT FOR 20 ns;
                    PIReqDataBE <= "0000";
                    -- ------------------------------------- Block Write. Start Address 0x80000002
                    -- -------------  Current Time:  715ns   Number of Transfers 2
                    WAIT FOR 60 ns;
                    PIReqVALID <= '1';
                    PIReqCNTL <= "10010001";
                    PIReqADRS <= "10000000000000000000000000000010";
                    PIReqDATA <= "00000000000000001111111111111111";
                    PIReqDataBE <= "1111";
                    -- -------------------------------------
                    -- -------------  Current Time:  735ns
                    WAIT FOR 20 ns;
                    PIReqVALID <= '0';
                    PIReqCNTL <= "11111111";
                    PIReqDataBE <= "0000";
                    -- -------------------------------------
                    -- -------------  Current Time:  775ns
                    WAIT FOR 40 ns;
                    PIReqVALID <= '1';
                    PIReqDATA <= "00000000000000001111000011110000";
                    PIReqDataBE <= "1111";
                    -- ------------------------------------- End of Block Write
                    -- -------------  Current Time:  795ns
                    WAIT FOR 20 ns;
                    PIReqVALID <= '0';
                    PIReqADRS <= "01100000000000000000000110010100";
                    PIReqDataBE <= "0000";
                    -- ------------------------------------- Block Read. Start Address 0x80000002
                    -- -------------  Current Time:  915ns   Number of Transfers 2
                    WAIT FOR 120 ns;
                    PIReqVALID <= '1';
                    PIReqCNTL <= "00010001";
                    PIReqADRS <= "10000000000000000000000000000010";
                    PIReqDATA <= "10000000000000000000000000000000";
                    PIReqDataBE <= "1111";
                    -- -------------------------------------
                    -- -------------  Current Time:  935ns
                    WAIT FOR 20 ns;
                    PIReqVALID <= '0';
                    PIReqCNTL <= "11111111";
                    PIReqDataBE <= "0000";
                    -- -------------------------------------
                    -- -------------  Current Time:  1055ns
                    WAIT FOR 120 ns;
                    PIReqVALID <= '1';
                    PIReqCNTL <= "10010011";
                    PIReqDATA <= "00000000000000000000000000001111";
                    PIReqDataBE <= "1111";
                    -- ------------------------------------- End of Block Read
                    -- -------------  Current Time:  1075ns
                    WAIT FOR 20 ns;
                    PIReqVALID <= '0';
                    PIReqCNTL <= "11111111";
                    PIReqDataBE <= "0000";
                    -- ------------------------------------- Block Write. Start Address 0x80000002
                    -- -------------  Current Time:  1115ns  Number of Transfers 4
                    WAIT FOR 40 ns;
                    PIReqVALID <= '1';
                    PIReqDATA <= "00000000000000000000000011110000";
                    PIReqDataBE <= "1111";
                    -- -------------------------------------
                    -- -------------  Current Time:  1135ns
                    WAIT FOR 20 ns;
                    PIReqVALID <= '0';
                    PIReqDataBE <= "0000";
                    -- -------------------------------------
                    -- -------------  Current Time:  1175ns
                    WAIT FOR 40 ns;
                    PIReqVALID <= '1';
                    PIReqDATA <= "00000000000000000000111100000000";
                    PIReqDataBE <= "1111";
                    -- -------------------------------------
                    -- -------------  Current Time:  1195ns
                    WAIT FOR 20 ns;
                    PIReqVALID <= '0';
                    PIReqDataBE <= "0000";
                    -- -------------------------------------
                    -- -------------  Current Time:  1235ns
                    WAIT FOR 40 ns;
                    PIReqVALID <= '1';
                    PIReqDATA <= "00000000000000001111000000000000";
                    PIReqDataBE <= "1111";
                    -- ------------------------------------- End of Block Write
                    -- -------------  Current Time:  1255ns
                    WAIT FOR 20 ns;
                    PIReqVALID <= '0';
                    PIReqDataBE <= "0000";
                    -- ------------------------------------- Block Read. Start Address 0x80000002
                    -- -------------  Current Time:  1335ns  Number of Transfers 4
                    WAIT FOR 80 ns;
                    PIReqVALID <= '1';
                    PIReqCNTL <= "00010011";
                    PIReqDATA <= "10000000000000000000000000001111";
                    PIReqDataBE <= "1111";
                    -- -------------------------------------
                    -- -------------  Current Time:  1355ns
                    WAIT FOR 20 ns;
                    PIReqVALID <= '0';
                    PIReqCNTL <= "11111111";
                    PIReqDataBE <= "0000";
                    -- -------------------------------------
                    -- -------------  Current Time:  1395ns
                    WAIT FOR 40 ns;
                    PIReqDataBE <= "1111";
                    -- -------------------------------------
                    -- -------------  Current Time:  1415ns
                    WAIT FOR 20 ns;
                    PIReqDataBE <= "0000";
                    -- -------------------------------------
                    -- -------------  Current Time:  1455ns
                    WAIT FOR 40 ns;
                    PIReqDataBE <= "1111";
                    -- -------------------------------------
                    -- -------------  Current Time:  1475ns
                    WAIT FOR 20 ns;
                    PIReqDataBE <= "0000";
                    -- -------------------------------------
                    -- -------------  Current Time:  1515ns
                    WAIT FOR 40 ns;
                    PIReqDataBE <= "1111";
                    -- ------------------------------------- End of Block Read
                    -- -------------  Current Time:  1535ns
                    WAIT FOR 20 ns;
                    PIReqDataBE <= "0000";
                    -- ------------------------------------- End of Testbench
                    WAIT FOR 505 ns;

                END PROCESS;

        END testbench_arch;

