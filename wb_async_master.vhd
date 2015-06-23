library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity wb_async_master is
    generic (
        dat_width: positive := 16;
        adr_width: positive := 20;
        ab_rd_delay: positive := 1
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
end wb_async_master;

architecture xilinx of wb_async_master is
    constant ab_wr_delay: positive := 2;
    -- delay lines for rd/wr edge detection
    signal rd_delay_rst: std_logic;
    signal rd_delay: std_logic_vector(ab_rd_delay downto 0);
    signal wr_delay: std_logic_vector(ab_wr_delay downto 0);
    -- one-cycle long pulses upon rd/wr edges
    signal ab_wr_pulse: std_logic;
    signal ab_rd_pulse: std_logic;
    -- one-cycle long pulse to latch address for writes
    signal ab_wr_latch_pulse: std_logic;
    -- WB data input register
    signal wb_dat_reg: std_logic_vector (dat_width-1 downto 0);
    -- internal copies of WB signals for feedback
    signal wb_cyc_l: std_logic;
    signal wb_we_l: std_logic;
    -- Comb. logic for active cycles
    signal ab_rd: std_logic;
    signal ab_wr: std_logic;
    signal ab_active: std_logic;
    -- internal copies of wait signals for feedback
    signal ab_wait_n_rst: std_logic;
    signal ab_wait_n_l: std_logic;
    signal ab_waiths_l: std_logic;
    signal ab_wait_n_l_delayed: std_logic;
    signal ab_waiths_l_delayed: std_logic;
    -- active when WB slave terminates the cycle (for any reason)
    signal wb_ack: std_logic;
    -- signals a scheduled or commencing posted write
    signal write_in_progress: std_logic;
begin
    ab_rd <= (not ab_ce_n) and (not ab_rd_n) and ab_wr_n;
    ab_wr <= (not ab_ce_n) and (not ab_wr_n) and ab_rd_n;
    ab_active <= not ab_ce_n;

    wb_ack <= wb_cyc_l and (wb_ack_i or wb_err_i or wb_rty_i);

    write_in_progress_gen: process
    begin
        if (wb_rst_i = '1') then
            write_in_progress <= '0';
        end if;
        wait until wb_clk_i'EVENT and wb_clk_i = '1';
        if ab_wr = '0' and wr_delay(wr_delay'HIGH) = '1' then
            write_in_progress <= '1';
        end if;
        if wb_ack = '1' then
            write_in_progress <= '0';
        end if;
    end process;

    -- Registers addr/data lines.
    reg_bus_lines: process
    begin
        if (wb_rst_i = '1') then
            wb_adr_o <= (others => '-');
            wb_sel_o <= (others => '-');
            wb_dat_o <= (others => '-');
            wb_dat_reg <= (others => '0');
        end if;
        wait until wb_clk_i'EVENT and wb_clk_i = '1';
        -- Store and sycnronize data and address lines if no (posted) write
        -- is in progress and there is an active asyncronous bus cycle.
        -- We store addresses for reads at the same time we sample the data so setup and hold
        -- times are the same.
        if (ab_wr = '1' or ab_rd_pulse = '1') and (write_in_progress = '0' or wb_ack = '1') then
            wb_adr_o <= ab_adr;
            for i in wb_sel_o'RANGE loop
                wb_sel_o(i) <= not ab_byteen_n(i);
            end loop;
        end if;
        if (ab_wr = '1') and (write_in_progress = '0' or wb_ack = '1') then
            wb_dat_o <= ab_dat;
        end if;

        -- en-register data input at the end of a read cycle
        if wb_ack = '1' then
            if wb_we_l = '0' then
                -- read cycle completed, store the result
                wb_dat_reg <= wb_dat_i;
            end if;
        end if;
    end process;

    -- Registers asycn bus control lines for sync edge detection.
    async_bus_wr_ctrl : process(wb_rst_i,wb_clk_i)
    begin
        if (wb_rst_i = '1') then
            wr_delay <= (others => '0');
--      end if;
        -- Post-layout simulation shows glitches on the output that violates setup times. 
        -- Clock on the other edge to solve this issue
--      elsif wb_clk_i'EVENT and wb_clk_i = '1' then
        elsif wb_clk_i'EVENT and wb_clk_i = '0' then
--      wait until wb_clk_i'EVENT and wb_clk_i = '1';
--      wait until wb_clk_i'EVENT and wb_clk_i = '0';
            -- delayed signals will be used in edge-detection
            for i in wr_delay'HIGH downto 1 loop
                wr_delay(i) <= wr_delay(i-1);-- and ab_rd;
            end loop;
            wr_delay(0) <= ab_wr;
        end if;
    end process;

    rd_delay_rst <= wb_rst_i or not ab_rd;
    async_bus_rd_ctrl : process(rd_delay_rst,wb_clk_i)
    begin
        if (rd_delay_rst = '1') then
            rd_delay <= (others => '0');
        -- Post-layout simulation shows glitches on the output that violates setup times. 
        -- Clock on the other edge to solve this issue
--      elsif wb_clk_i'EVENT and wb_clk_i = '1' then
        elsif wb_clk_i'EVENT and wb_clk_i = '0' then
            -- a sync-reset shift-register to delay read signal
            for i in rd_delay'HIGH downto 1 loop
                rd_delay(i) <= rd_delay(i-1) and ab_rd;
            end loop;
            if (wb_cyc_l = '1') then
                rd_delay(0) <= rd_delay(0);
            else
                rd_delay(0) <= ab_rd and not write_in_progress;
            end if;
        end if;
    end process;
    -- will be one for one cycle at the proper end of the async cycle
    ab_wr_pulse       <=     wr_delay(wr_delay'HIGH) and not wr_delay(wr_delay'HIGH-1);
    ab_wr_latch_pulse <= not wr_delay(wr_delay'HIGH) and     wr_delay(wr_delay'HIGH-1);
    ab_rd_pulse       <= not rd_delay(rd_delay'HIGH) and     rd_delay(rd_delay'HIGH-1);

    -- Generates WishBone control signals
    wb_ctrl_gen: process
    begin
        if (wb_rst_i = '1') then
            wb_stb_o <= '0';
            wb_cyc_l <= '0';
            wb_we_l <= '0';
        end if;
        wait until wb_clk_i'EVENT and wb_clk_i = '1';
--        if wb_ack = '1' then
        if wb_ack = '1' and ab_wr_pulse = '0' and ab_rd_pulse = '0' then
            wb_stb_o <= '0';
            wb_cyc_l <= '0';
            wb_we_l <= '0';
        end if;

        if ab_wr_pulse = '1' or ab_rd_pulse = '1' then
            wb_stb_o <= '1';
            wb_cyc_l <= '1';
            wb_we_l <= ab_wr_pulse;
        end if;
    end process;

    -- Generate asyncronous wait signal
    ab_wait_n_rst <= wb_rst_i or not ab_active;
    a_wait_n_gen: process(ab_wait_n_rst, wb_clk_i)
    begin
        if (ab_wait_n_rst = '1') then
            ab_wait_n_l <= '1';
        elsif wb_clk_i'EVENT and wb_clk_i = '1' then
            -- At the beginning of a read cycle, move wait low
            if ab_wait_n_l = '1' and ab_rd = '1' and rd_delay(0) = '0' then
                ab_wait_n_l <= '0';
            end if;
            -- At the beginning of any cycle, if the ss-master part is busy, wait
            if (ab_wait_n_l = '1' and (ab_rd = '1' or ab_wr = '1')) and
               (wb_cyc_l = '1')
            then
                ab_wait_n_l <= '0';
            end if;
            -- At the end of an ss-master cycle, remove wait
            if wb_ack = '1' and (
               (wb_we_l = '1' and ab_rd = '0') or -- no pending read
               wb_we_l = '0') -- was a read operation
            then
                ab_wait_n_l <= '1';
            end if;
        end if;
    end process;

    -- Generate handshake-type wait signal
    a_waiths_gen: process(wb_rst_i,wb_clk_i)
    begin
        if (wb_rst_i = '1') then
            ab_waiths_l <= '0';
        elsif wb_clk_i'EVENT and wb_clk_i = '1' then
            -- Write handling
            if wb_cyc_l = '0' and ab_wr = '1' then
                ab_waiths_l <= '1';
            end if;
            if wb_ack = '1' and ab_waiths_l = '1' then
                ab_waiths_l <= '0';
            end if;

            -- Read handling
            if wb_ack = '1' and ab_rd = '1' then
                ab_waiths_l <= '1';
            end if;

            if wb_cyc_l = '0' and ab_rd = '0' and ab_wr = '0' and wr_delay(wr_delay'HIGH) = '0'
            then
                ab_waiths_l <= '0';
            end if;
        end if;
    end process;

    -- connect local signals to external pins
    wb_cyc_o <= wb_cyc_l;
    wb_we_o <= wb_we_l;
--  ab_wait_n <= '0' when ab_wait_n_l = '0' else '1';
    ab_dat <= wb_dat_reg when ab_rd = '1' else (others => 'Z');

    -- On post-layout simulation it turned out that the data is not stable upon
    -- the raising edge of these wait signals. So we delay the raising edge with one-half clock
    delay_wait: process(wb_clk_i)
    begin
        if wb_clk_i'EVENT and wb_clk_i = '0' then
            ab_wait_n_l_delayed <= ab_wait_n_l;
            ab_waiths_l_delayed <= ab_waiths_l;
        end if;
    end process;
    ab_wait_n <= ab_wait_n_l and ab_wait_n_l_delayed;
    ab_waiths <= ab_waiths_l and ab_waiths_l_delayed;

--  ab_dat_gen: process(wb_clk_i,wb_rst_i)
--  begin
--        if (wb_rst_i = '1') then
--            ab_dat <= (others => 'Z');
--        elsif wb_clk_i'EVENT and wb_clk_i = '1' then
--          if (ab_rd = '1') then
--              ab_dat <= wb_dat_reg;
--          else
--              ab_dat <= (others => 'Z');
--          end if;
--      end if;
--  end process;

end xilinx;

