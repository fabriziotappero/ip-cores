library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

library WB_TK;
use WB_TK.components.ALL;

entity wb_async_master_TB is
    generic (
        dat_width: positive := 8;
        adr_width: positive := 8;
        ab_rd_delay: positive := 2
    );
end wb_async_master_TB;

architecture xilinx of wb_async_master_TB is
    component wb_async_master_2
        generic (
            dat_width: positive := dat_width;
            adr_width: positive := adr_width;
            ab_rd_delay: positive := ab_rd_delay
        );
        port (
            wb_clk_i: in std_logic;
            wb_rst_i: in std_logic := '0';
            
            -- interface to wb slave devices
            wb_adr_o: out std_logic_vector (adr_width-1 downto 0);
            wb_sel_o: out std_logic_vector ((dat_width/8)-1 downto 0);
            wb_dat_i: in std_logic_vector (dat_width-1 downto 0);
            wb_dat_o: out std_logic_vector (dat_width-1 downto 0);
            wb_cyc_o: out std_logic;
            wb_ack_i: in std_logic;
            wb_err_i: in std_logic := '-';
            wb_rty_i: in std_logic := '-';
            wb_we_o: out std_logic;
            wb_stb_o: out std_logic;
            
            -- interface to the asyncronous master device
            ab_dat: inout std_logic_vector (dat_width-1 downto 0) := (others => 'Z');
            ab_adr: in std_logic_vector (adr_width-1 downto 0) := (others => 'U');
            ab_rd_n: in std_logic := '1';
            ab_wr_n: in std_logic := '1';
            ab_ce_n: in std_logic := '1';
            ab_byteen_n: in std_logic_vector ((dat_width/8)-1 downto 0);
            ab_wait_n: out std_logic; -- wait-state request 'open-drain' output
            ab_waiths: out std_logic  -- handshake-type totem-pole output
        );
    end component;

    signal wb_clk_i: std_logic;
    signal wb_rst_i: std_logic := '0';

    -- interface to wb slave devices
    signal wb_adr_o: std_logic_vector (adr_width-1 downto 0);
    signal wb_sel_o: std_logic_vector ((dat_width/8)-1 downto 0);
    signal wb_dat_i: std_logic_vector (dat_width-1 downto 0);
    signal wb_dat_o: std_logic_vector (dat_width-1 downto 0);
    signal wb_cyc_o: std_logic;
    signal wb_ack_i: std_logic;
    signal wb_err_i: std_logic := '-';
    signal wb_rty_i: std_logic := '-';
    signal wb_we_o: std_logic;
    signal wb_stb_o: std_logic;

    -- interface to asyncron master device
    signal ab_dat: std_logic_vector (dat_width-1 downto 0) := (others => 'Z');
    signal ab_adr: std_logic_vector (adr_width-1 downto 0) := (others => 'U');
    signal ab_rd_n: std_logic := '1';
    signal ab_wr_n: std_logic := '1';
    signal ab_ce_n: std_logic := '1';
    signal ab_byteen_n: std_logic_vector ((dat_width/8)-1 downto 0);
    signal ab_wait_n: std_logic;
    signal ab_waiths: std_logic;
    signal wait_mode: integer := 0;
    signal ab_wait: std_logic;
    
    procedure wait_for_cycle_end(
        signal ab_wait: in std_logic;
        wait_mode: in integer
    ) is begin
        if wait_mode = 0 then
            if ab_wait = '0' then
                wait until ab_wait /= '0';
            end if;
        elsif wait_mode = 1 then
            if ab_wait = '0' then
                wait until ab_wait = '1';
            end if;
        else
        end if;
    end wait_for_cycle_end;

    procedure wait_for_idle(
        signal ab_wait: in std_logic;
        wait_mode: in integer
    ) is begin
        if wait_mode = 0 then
            -- nothing to do in this case
        else
            if ab_wait = '1' then
                wait until ab_wait = '0';
            end if;
        end if;
    end wait_for_idle;

    procedure do_write(
        signal as_dat: inout std_logic_vector (dat_width-1 downto 0);
        signal as_adr: out std_logic_vector (adr_width-1 downto 0);
        signal as_rd_n: out std_logic;
        signal as_wr_n: out std_logic;
        signal as_ce_n: out std_logic;
        signal as_byteen_n: out std_logic_vector ((dat_width/8)-1 downto 0);
        signal as_wait: in std_logic;
        
        a_dat: in std_logic_vector(dat_width-1 downto 0);
        a_adr: in std_logic_vector(adr_width-1 downto 0);
        a_cycle_length: in time;
        a_setup_time: in time;
        a_wait_mode: in integer
    ) is begin
        wait_for_idle(as_wait,a_wait_mode);
        as_dat <= (others => 'X');
        as_adr <= (others => 'X');
        as_byteen_n <= (others => 'X');
        as_rd_n <= '1';
        as_wr_n <= '0';
        as_ce_n <= '0';
        wait for a_setup_time;
        as_dat <= a_dat;
        as_adr <= a_adr;
        as_byteen_n <= (others => '0');
        wait for a_cycle_length-a_setup_time;
        wait_for_cycle_end(as_wait,a_wait_mode);
        as_dat <= (others => 'Z');
        as_adr <= (others => 'U');
        as_byteen_n <= (others => 'U');
        as_rd_n <= '1';
        as_wr_n <= '1';
        as_ce_n <= '1';
    end do_write;

    procedure do_read(
        signal as_dat: inout std_logic_vector (dat_width-1 downto 0);
        signal as_adr: out std_logic_vector (adr_width-1 downto 0);
        signal as_rd_n: out std_logic;
        signal as_wr_n: out std_logic;
        signal as_ce_n: out std_logic;
        signal as_byteen_n: out std_logic_vector ((dat_width/8)-1 downto 0);
        signal as_wait: in std_logic;
        
        a_expected_dat: in std_logic_vector(dat_width-1 downto 0);
        a_adr: in std_logic_vector(adr_width-1 downto 0);
        a_cycle_length: in time;
        a_setup_time: in time;
        a_wait_mode: in integer
    ) is begin
        wait_for_idle(as_wait,a_wait_mode);
        as_dat <= "ZZZZZZZZ";
        as_adr <= (others => 'X');
        as_byteen_n <= (others => 'X');
        as_rd_n <= '0';
        as_wr_n <= '1';
        as_ce_n <= '0';
        wait for a_setup_time;
        as_adr <= a_adr;
        as_byteen_n <= (others => '0');
        wait for a_cycle_length-a_setup_time;
        wait_for_cycle_end(as_wait,a_wait_mode);
        for i in ab_dat'RANGE loop
            ASSERT (as_dat(i) = a_expected_dat(i)) report "Cannot read back data from bus!" severity error;
        end loop;
        wait for 12 ns;
        as_dat <= (others => 'Z');
        as_adr <= (others => 'U');
        as_byteen_n <= (others => 'U');
        as_rd_n <= '1';
        as_wr_n <= '1';
        as_ce_n <= '1';
    end do_read;
begin
    ab_wait <= ab_wait_n when wait_mode = 0 else ab_waiths;
    
    clk_gen: process
    begin
        wb_clk_i <= '1';
        wait for 25 ns;
        wb_clk_i <= '0';
        wait for 25 ns;
    end process;

    reset_gen: process
    begin
        wb_rst_i <= '1';
        wait for 100 ns;
        wb_rst_i <= '0';
			 wait;
    end process;

    ss_slave: process
    begin
        if wb_rst_i = '1' then
            wb_err_i <= '0';
            wb_rty_i <= '0';
            wb_ack_i <= '0';
            wb_dat_i <= (others => 'U');
        end if;
        wait until wb_clk_i'EVENT and wb_clk_i = '1';
        if wb_cyc_o = '1' then
            if wb_we_o = '1' then
                -- write cycle
                -- simulate 2 WS
                wb_ack_i <= '0';
                wb_dat_i <= (others => 'U');
                wait until wb_clk_i'EVENT and wb_clk_i = '1';
                wait until wb_clk_i'EVENT and wb_clk_i = '1';
                wb_ack_i <= '1';
                wait until wb_clk_i'EVENT and wb_clk_i = '1';
                wb_ack_i <= '0';
            else
                -- read cycle
                -- simulate 3 WS
                wb_dat_i <= (others => 'U');
                wb_ack_i <= '0';
                wait until wb_clk_i'EVENT and wb_clk_i = '1';
                wait until wb_clk_i'EVENT and wb_clk_i = '1';
                wait until wb_clk_i'EVENT and wb_clk_i = '1';
                wb_ack_i <= '1';
                wb_dat_i <= wb_adr_o(wb_dat_i'RANGE);
                wait until wb_clk_i'EVENT and wb_clk_i = '1';
                wb_dat_i <= (others => 'U');
                wb_ack_i <= '0';
            end if;
        end if;
    end process;

    as_master: process
    begin
        if (wb_rst_i = '1') then
            ab_adr <= (others => '0');
            ab_dat <= (others => 'Z');
            ab_rd_n <= '1';
            ab_wr_n <= '1';
            ab_ce_n <= '1';
            wait until wb_rst_i = '0';
        end if;
        wait for 210 ns;

        -- test1: normal write
        do_write(
            ab_dat,ab_adr,ab_rd_n,ab_wr_n,ab_ce_n,ab_byteen_n,ab_wait,
        
            "10000001",
            "01000001",
            202 ns,
            55 ns,
            wait_mode
        );

        wait for 300 ns;

        -- test2: normal read
        do_read(
            ab_dat,ab_adr,ab_rd_n,ab_wr_n,ab_ce_n,ab_byteen_n,ab_wait,
        
            "00000010",
            "00000010",
            202 ns,
            55 ns,
            wait_mode
        );

        wait for 55 ns;

        -- test3: normal write
        do_write(
            ab_dat,ab_adr,ab_rd_n,ab_wr_n,ab_ce_n,ab_byteen_n,ab_wait,
        
            "10010001",
            "01010001",
            402 ns,
            55 ns,
            wait_mode
        );

        wait for 300 ns;

        -- test4: normal read
        do_read(
            ab_dat,ab_adr,ab_rd_n,ab_wr_n,ab_ce_n,ab_byteen_n,ab_wait,
        
            "00010010",
            "00010010",
            502 ns,
            55 ns,
            wait_mode
        );

        wait for 55 ns;

        -- test5: normal write
        do_write(
            ab_dat,ab_adr,ab_rd_n,ab_wr_n,ab_ce_n,ab_byteen_n,ab_wait,
        
            "10000011",
            "01000011",
            202 ns,
            55 ns,
            wait_mode
        );

        wait for 55 ns;
        -- test4: overlapped read: should wait until posted write finishes
        do_read(
            ab_dat,ab_adr,ab_rd_n,ab_wr_n,ab_ce_n,ab_byteen_n,ab_wait,
        
            "00000100",
            "00000100",
            202 ns,
            55 ns,
            wait_mode
        );
        
        wait for 5 ns;
        -- test4: out-of-order read: should handled correctly without loosing sync
        do_read(
            ab_dat,ab_adr,ab_rd_n,ab_wr_n,ab_ce_n,ab_byteen_n,ab_wait,
        
            "00000100",
            "00000100",
            85 ns,
            55 ns,
            wait_mode
        );
        wait for 5 ns;
        -- test4: out-of-order read: should handled correctly without loosing sync
        do_read(
            ab_dat,ab_adr,ab_rd_n,ab_wr_n,ab_ce_n,ab_byteen_n,ab_wait,
        
            "00000100",
            "00000100",
            85 ns,
            55 ns,
            2 --wait_mode
        );
--        wait for 200 ns;
--        do_read(
--            ab_dat,ab_adr,ab_rd_n,ab_wr_n,ab_ce_n,ab_byteen_n,ab_wait,
--        
--            "00000100",
--            "00000100",
--            202 ns,
--            55 ns,
--            wait_mode
--        );
        
        wait for 200 ns;

        -- test5: normal write
        do_write(
            ab_dat,ab_adr,ab_rd_n,ab_wr_n,ab_ce_n,ab_byteen_n,ab_wait,
        
            "10000101",
            "01000101",
            202 ns,
            55 ns,
            wait_mode
        );

        wait for 55 ns;
        -- test5: overlapped write: should wait until posted write finishes
        do_write(
            ab_dat,ab_adr,ab_rd_n,ab_wr_n,ab_ce_n,ab_byteen_n,ab_wait,
        
            "10000110",
            "01000110",
            202 ns,
            55 ns,
            wait_mode
        );

        if wait_mode = 0 then
            wait for 450 ns;
            wait_mode <= 1;
            wait for 50 ns;
        else
            wait;
        end if;
    end process;

    UUT: wb_async_master_2 
        port map (
            wb_clk_i   =>     wb_clk_i,
            wb_rst_i   =>     wb_rst_i,

            -- interfaceto wb slave devices
            wb_adr_o =>     wb_adr_o,
            wb_sel_o =>     wb_sel_o,
            wb_dat_i =>     wb_dat_i,
            wb_dat_o =>     wb_dat_o,
            wb_cyc_o =>     wb_cyc_o,
            wb_ack_i =>     wb_ack_i,
            wb_err_i =>     wb_err_i,
            wb_rty_i =>     wb_rty_i,
            wb_we_o  =>     wb_we_o,
            wb_stb_o =>     wb_stb_o,

            -- interfaceto asyncron master device
            ab_dat   =>     ab_dat,
            ab_adr   =>     ab_adr,
            ab_rd_n  =>     ab_rd_n,
            ab_wr_n  =>     ab_wr_n,
            ab_ce_n  =>     ab_ce_n,
            ab_byteen_n =>  ab_byteen_n,
            ab_wait_n   =>  ab_wait_n,
            ab_waiths   =>  ab_waiths
    );
end xilinx;

