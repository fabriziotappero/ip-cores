--======================================================================================--
--          Verilog to VHDL conversion by Martin Neumann martin@neumnns-mail.de         --
--                                                                                      --
--          ///////////////////////////////////////////////////////////////////         --
--          //                                                               //         --
--          //  USB 1.1 PHY                                                  //         --
--          //  RX & DPLL                                                    //         --
--          //                                                               //         --
--          //                                                               //         --
--          //  Author: Rudolf Usselmann                                     //         --
--          //          rudi@asics.ws                                        //         --
--          //                                                               //         --
--          //                                                               //         --
--          //  Downloaded from: http://www.opencores.org/cores/usb_phy/     //         --
--          //                                                               //         --
--          ///////////////////////////////////////////////////////////////////         --
--          //                                                               //         --
--          //  Copyright (C) 2000-2002 Rudolf Usselmann                     //         --
--          //                          www.asics.ws                         //         --
--          //                          rudi@asics.ws                        //         --
--          //                                                               //         --
--          //  This source file may be used and distributed without         //         --
--          //  restriction provided that this copyright statement is not    //         --
--          //  removed from the file and that any derivative work contains  //         --
--          //  the original copyright notice and the associated disclaimer. //         --
--          //                                                               //         --
--          //      THIS SOFTWARE IS PROVIDED ``AS IS'' AND WITHOUT ANY      //         --
--          //  EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED    //         --
--          //  TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS    //         --
--          //  FOR A PARTICULAR PURPOSE. IN NO EVENT SHALL THE AUTHOR       //         --
--          //  OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,          //         --
--          //  INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES     //         --
--          //  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE    //         --
--          //  GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR         //         --
--          //  BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF   //         --
--          //  LIABILITY, WHETHER IN  CONTRACT, STRICT LIABILITY, OR TORT   //         --
--          //  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT   //         --
--          //  OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE          //         --
--          //  POSSIBILITY OF SUCH DAMAGE.                                  //         --
--          //                                                               //         --
--          ///////////////////////////////////////////////////////////////////         --
--======================================================================================--
--                                                                                      --
-- Change history                                                                       --
-- +-------+-----------+-------+------------------------------------------------------+ --
-- | Vers. | Date      | Autor | Comment                                              | --
-- +-------+-----------+-------+------------------------------------------------------+ --
-- |  1.0  |04 Feb 2011|  MN   | Initial version                                      | --
-- |  1.1  |23 Apr 2011|  MN   | Added 'rst' to most latched signals.                 | --
-- |       |           |       | Added ELSE construct in fs_next_state process to     | --
-- |       |           |       |   prevent an undesired latch implementation.         | --
--======================================================================================--

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity usb_rx_phy is
  port (
    clk             : in  std_logic;
    rst             : in  std_logic;
    -- Transciever Interface
    fs_ce_o         : out std_logic;
    rxd, rxdp, rxdn : in  std_logic;
    -- UTMI Interface
    DataIn_o        : out std_logic_vector(7 downto 0);
    RxValid_o       : out std_logic;
    RxActive_o      : out std_logic;
    RxError_o       : out std_logic;
    RxEn_i          : in  std_logic;
    LineState       : out std_logic_vector(1 downto 0)
  );
end usb_rx_phy;

architecture RTL of usb_rx_phy is

  signal fs_ce                              : std_logic;
  signal rxd_s0, rxd_s1, rxd_s              : std_logic;
  signal rxdp_s0, rxdp_s1, rxdp_s, rxdp_s_r : std_logic;
  signal rxdn_s0, rxdn_s1, rxdn_s, rxdn_s_r : std_logic;
  signal synced_d                           : std_logic;
  signal k, j, se0                          : std_logic;
  signal rxd_r                              : std_logic;
  signal rx_en                              : std_logic;
  signal rx_active                          : std_logic;
  signal bit_cnt                            : std_logic_vector(2 downto 0);
  signal rx_valid1, rx_valid                : std_logic;
  signal shift_en                           : std_logic;
  signal sd_r                               : std_logic;
  signal sd_nrzi                            : std_logic;
  signal hold_reg                           : std_logic_vector(7 downto 0);
  signal drop_bit                           : std_logic;    -- Indicates a stuffed bit
  signal one_cnt                            : std_logic_vector(2 downto 0);
  signal dpll_state, dpll_next_state        : std_logic_vector(1 downto 0);
  signal fs_ce_d                            : std_logic;
  signal change                             : std_logic;
  signal lock_en                            : std_logic;
  signal fs_state, fs_next_state            : std_logic_vector(2 downto 0);
  signal rx_valid_r                         : std_logic;
  signal sync_err_d, sync_err               : std_logic;
  signal bit_stuff_err                      : std_logic;
  signal se0_r, byte_err                    : std_logic;
  signal se0_s                              : std_logic;
  signal fs_ce_r1, fs_ce_r2                 : std_logic;

  constant FS_IDLE  : std_logic_vector(2 downto 0) := "000";
  constant K1       : std_logic_vector(2 downto 0) := "001";
  constant J1       : std_logic_vector(2 downto 0) := "010";
  constant K2       : std_logic_vector(2 downto 0) := "011";
  constant J2       : std_logic_vector(2 downto 0) := "100";
  constant K3       : std_logic_vector(2 downto 0) := "101";
  constant J3       : std_logic_vector(2 downto 0) := "110";
  constant K4       : std_logic_vector(2 downto 0) := "111";

begin

  --====================================================================================--
  -- Misc Logic                                                                         --
  --====================================================================================--

  fs_ce_o    <= fs_ce;
  RxActive_o <= rx_active;
  RxValid_o  <= rx_valid;
  RxError_o  <= sync_err or bit_stuff_err or byte_err;
  DataIn_o   <= hold_reg;
  LineState  <= rxdn_s1 & rxdp_s1;

  p_rx_en: process (clk)
  begin
    if rising_edge(clk) then
      rx_en <= RxEn_i;
    end if;
  end process;

  p_sync_err: process (clk, rst)
  begin
    if rst ='0' then
      sync_err <= '0';
    elsif rising_edge(clk) then
      sync_err <= not rx_active and sync_err_d;
    end if;
  end process;

  --====================================================================================--
  -- Synchronize Inputs                                                                 --
  --====================================================================================--

  -- First synchronize to the local system clock to
  -- avoid metastability outside the sync block (*_s0).
  -- Then make sure we see the signal for at least two
  -- clock cycles stable to avoid glitches and noise

  p_rxd_s: process (clk) -- Avoid detecting Line Glitches and noise
  begin
    if rising_edge(clk) then
        rxd_s0 <= rxd;
        rxd_s1 <= rxd_s0;
        if rxd_s0 ='1' and rxd_s1 ='1' then
          rxd_s <= '1';
        elsif not rxd_s0 ='1' and not rxd_s1 ='1' then
          rxd_s <= '0';
        end if;
    end if;
  end process;

  p_rxdp_s: process (clk)
  begin
    if rising_edge(clk) then
      rxdp_s0  <= rxdp;
      rxdp_s1  <= rxdp_s0;
      rxdp_s_r <= rxdp_s0 and rxdp_s1;
      rxdp_s   <= (rxdp_s0 and rxdp_s1) or rxdp_s_r;
    end if;
  end process;

  p_rxdn_s: process (clk)
  begin
    if rising_edge(clk) then
      rxdn_s0  <= rxdn;
      rxdn_s1  <= rxdn_s0;
      rxdn_s_r <= rxdn_s0 and rxdn_s1;
      rxdn_s   <= (rxdn_s0 and rxdn_s1) or rxdn_s_r;
    end if;
  end process;

  j   <=     rxdp_s and not rxdn_s;
  k   <= not rxdp_s and     rxdn_s;
  se0 <= not rxdp_s and not rxdn_s;

  p_se0_s: process (clk, rst)
  begin
    if rst ='0' then
      se0_s <= '0';
    elsif rising_edge(clk) then
      if fs_ce ='1' then
        se0_s   <= se0;
      end if;
    end if;
  end process;

  --====================================================================================--
  -- DPLL                                                                               --
  --====================================================================================--

  -- This design uses a clock enable to do 12Mhz timing and not a
  -- real 12Mhz clock. Everything always runs at 48Mhz. We want to
  -- make sure however, that the clock enable is always exactly in
  -- the middle between two virtual 12Mhz rising edges.
  -- We monitor rxdp and rxdn for any changes and do the appropiate
  -- adjustments.
  -- In addition to the locking done in the dpll FSM, we adjust the
  -- final latch enable to compensate for various sync registers ...

  lock_en <= rx_en; -- Allow clock adjustments only when we are receiving

  p_rxd_r: process (clk)
  begin
    if rising_edge(clk) then
      rxd_r   <= rxd_s;
    end if;
  end process;

  change  <= rxd_r xor rxd_s; -- Edge detector

  -- DPLL FSM
  p_dpll_state: process (clk, rst)
  begin
    if rst ='0' then
      dpll_state <= "01";
    elsif rising_edge(clk) then
      dpll_state <= dpll_next_state;
    end if;
  end process;

  p_dpll_next_state: process (dpll_state, lock_en, change)
  begin
    case (dpll_state) is
      when "00" =>
        if ((lock_en = '1') and (change = '1')) then
          dpll_next_state <= "00";
        else
          dpll_next_state <= "01";
        end if;
      when "01" =>
        if ((lock_en = '1') and (change = '1')) then
          dpll_next_state <= "11";
        else
          dpll_next_state <= "10";
        end if;
      when "10" =>
        if ((lock_en = '1') and (change = '1')) then
          dpll_next_state <= "00";
        else
          dpll_next_state <= "11";
        end if;
      when OTHERS =>
          dpll_next_state <= "00";
    end case;
  end process;

  fs_ce_d <= '1' when dpll_state = "01" else '0';

  -- Compensate for sync registers at the input - allign full speed ...
  -- ... clock enable to be in the middle between two bit changes :

  p_fs_ce: process (clk)
  begin
    if rising_edge(clk) then
      fs_ce_r1  <= fs_ce_d;
      fs_ce_r2  <= fs_ce_r1;
      fs_ce <= fs_ce_r2;
    end if;
  end process;

  --====================================================================================--
  -- Find Sync Pattern FSM                                                              --
  --====================================================================================--

  p_fs_state: process (clk, rst)
  begin
    if rst ='0' then
      fs_state  <= FS_IDLE;
    elsif rising_edge(clk) then
      fs_state  <= fs_next_state;
    end if;
  end process;

  p_fs_next_state: process (fs_state, fs_ce, k, j, rx_en, rx_active, se0, se0_s)
  begin
    if fs_ce='1' and  rx_active='0' and se0='0' and se0_s='0' then
      case fs_state is
        when FS_IDLE => if k ='1' and rx_en ='1' then -- 0
                          fs_next_state <= K1;
                          sync_err_d    <= '0';
                        else
                          fs_next_state <= FS_IDLE;
                          sync_err_d    <= '0';
                        end if;
        when K1      => if j ='1' and rx_en ='1' then -- 1
                          fs_next_state <= J1;
                          sync_err_d    <= '0';
                        else
                          fs_next_state <= FS_IDLE;
                          sync_err_d    <= '1';
                        end if;
        when J1      => if k ='1' and rx_en ='1' then -- 2
                          fs_next_state <= K2;
                          sync_err_d    <= '0';
                        else
                          fs_next_state <= FS_IDLE;
                          sync_err_d    <= '1';
                        end if;
        when K2      => if j ='1' and rx_en ='1' then -- 3
                          fs_next_state <= J2;
                          sync_err_d    <= '0';
                        else
                          fs_next_state <= FS_IDLE;
                          sync_err_d    <= '1';
                        end if;
        when J2      => if k ='1' and rx_en ='1' then -- 4
                          fs_next_state <= K3;
                          sync_err_d    <= '0';
                        else
                          fs_next_state <= FS_IDLE;
                          sync_err_d    <= '1';
                        end if;
        when K3      => if j ='1' and rx_en ='1' then -- 5
                          fs_next_state <= J3;
                          sync_err_d    <= '0';
                        elsif k ='1' and rx_en ='1' then  -- Allow missing first K-J
                          fs_next_state <= FS_IDLE;
                          sync_err_d    <= '0';
                        else
                          fs_next_state <= FS_IDLE;
                          sync_err_d    <= '1';
                        end if;
        when J3      => if k ='1' and rx_en ='1' then -- 6
                          fs_next_state <= K4;
                          sync_err_d    <= '0';
                        else
                          fs_next_state <= FS_IDLE;
                          sync_err_d    <= '1';
                        end if;
        when K4      => if k ='1' and rx_en ='1' then -- 7
                          sync_err_d    <= '0';
                        else
                          sync_err_d    <= '1';
                        end if;
                        fs_next_state <= FS_IDLE;
        when others  => fs_next_state <= FS_IDLE;
                        sync_err_d    <= '1';
      end case;
    else
      fs_next_state <= fs_state;
      sync_err_d    <= '0';
    end if;
  end process;

  synced_d   <= fs_ce and rx_en when (fs_state =K3 and k ='1') or  -- Allow missing first K-J
                                     (fs_state =K4 and k ='1') else '0';

  --====================================================================================--
  -- Generate RxActive                                                                  --
  --====================================================================================--

  p_rx_active: process (clk, rst)
  begin
    if rst ='0' then
      rx_active   <= '0';
    elsif rising_edge(clk) then
      if synced_d ='1' and rx_en ='1' then
        rx_active <= '1';
      elsif se0 ='1' and rx_valid_r ='1' then
        rx_active <= '0';
      end if;
    end if;
  end process;

  p_rx_valid_r: process (clk, rst)
  begin
    if rst ='0' then
      rx_valid_r <= '0';
    elsif rising_edge(clk) then
      if rx_valid ='1' then
        rx_valid_r      <= '1';
      elsif fs_ce ='1' then
        rx_valid_r      <= '0';
      end if;
    end if;
  end process;

  --====================================================================================--
  -- NRZI Decoder                                                                       --
  --====================================================================================--

  p_sd_r: process (clk, rst)
  begin
    if rst ='0' then
      sd_r <= '0';
    elsif rising_edge(clk) then
      if fs_ce ='1' then
        sd_r <= rxd_s;
      end if;
    end if;
  end process;

  p_sd_nrzi: process (clk, rst)
  begin
    if rst ='0' then
      sd_nrzi <= '0';
    elsif rising_edge(clk) then
      if rx_active ='0' then
        sd_nrzi <= '1';
      elsif rx_active ='1' and fs_ce ='1' then
        sd_nrzi <= not (rxd_s xor sd_r);
      end if;
    end if;
  end process;

  --====================================================================================--
  -- Bit Stuff Detect                                                                   --
  --====================================================================================--

  p_one_cnt: process (clk, rst)
  begin
    if rst ='0' then
      one_cnt <= "000";
    elsif rising_edge(clk) then
      if shift_en ='0' then
        one_cnt <= "000";
      elsif fs_ce ='1' then
        if sd_nrzi ='0' or drop_bit ='1' then
          one_cnt <= "000";
        else
          one_cnt <= one_cnt + 1;
        end if;
      end if;
    end if;
  end process;

  drop_bit <= '1' when one_cnt ="110" else '0';

  p_bit_stuff_err: process (clk, rst) -- Bit Stuff Error
  begin
    if rst ='0' then
      bit_stuff_err <= '0';
    elsif rising_edge(clk) then
      bit_stuff_err <= drop_bit and sd_nrzi and fs_ce and not se0 and rx_active;
    end if;
  end process;

  --====================================================================================--
  -- Serial => Parallel converter                                                       --
  --====================================================================================--

  p_shift_en: process (clk, rst)
  begin
    if rst ='0' then
      shift_en <= '0';
    elsif rising_edge(clk) then
      if fs_ce ='1' then
        shift_en <= synced_d or rx_active;
      end if;
    end if;
  end process;

  p_hold_reg: process (clk)
  begin
    if rising_edge(clk) then
      if fs_ce ='1' and shift_en ='1' and drop_bit ='0' then
        hold_reg <= sd_nrzi & hold_reg(7 downto 1);
      end if;
    end if;
  end process;

  --====================================================================================--
  -- Generate RxValid                                                                  --
  --====================================================================================--

  p_bit_cnt: process (clk, rst)
  begin
    if rst ='0' then
      bit_cnt <= "000";
    elsif rising_edge(clk) then
      if shift_en ='0' then
        bit_cnt <=  "000";
      elsif fs_ce ='1' and drop_bit ='0' then
        bit_cnt <= unsigned(bit_cnt) + 1;
      end if;
    end if;
  end process;

  p_rx_valid1: process (clk, rst)
  begin
    if rst ='0' then
      rx_valid1 <= '0';
    elsif rising_edge(clk) then
      if fs_ce ='1' and drop_bit ='0' and bit_cnt ="111" then
        rx_valid1 <= '1';
      elsif rx_valid1 ='1' and fs_ce ='1' and drop_bit ='0' then
        rx_valid1 <= '0';
      end if;
    end if;
  end process;

  p_rx_valid: process (clk, rst)
  begin
    if rst ='0' then
      rx_valid <= '0';
    elsif rising_edge(clk) then
      rx_valid <= not drop_bit and rx_valid1 and fs_ce;
    end if;
  end process;

  p_se0_r: process (clk)
  begin
    if rising_edge(clk) then
      se0_r <= se0;
    end if;
  end process;

  p_byte_err: process (clk, rst)
  begin
    if rst ='0' then
      byte_err <= '0';
    elsif rising_edge(clk) then
      byte_err <= se0 and not se0_r and (bit_cnt(1) or bit_cnt(2)) and rx_active;
    end if;
  end process;

end RTL;
