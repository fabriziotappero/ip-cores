--======================================================================================--
--          Verilog to VHDL conversion by Martin Neumann martin@neumnns-mail.de         --
--                                                                                      --
--          ///////////////////////////////////////////////////////////////////         --
--          //                                                               //         --
--          //  USB 1.1 PHY                                                  //         --
--          //  TX                                                           //         --
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
-- |  1.1  |23 Apr 2011|  MN   | Added missing 'rst' in process sensitivity lists     | --
-- |       |           |       | Added ELSE constructs in next_state process to       | --
-- |       |           |       |   prevent an undesired latch implementation.         | --
--======================================================================================--

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity usb_tx_phy is
  port (
    clk              : in  std_logic;
    rst              : in  std_logic;
    fs_ce            : in  std_logic;
    phy_mode         : in  std_logic;
    -- Transciever Interface
    txdp, txdn, txoe : out std_logic;
    -- UTMI Interface
    DataOut_i        : in  std_logic_vector(7 downto 0);
    TxValid_i        : in  std_logic;
    TxReady_o        : out std_logic
  );
end usb_tx_phy;

architecture RTL of usb_tx_phy is

  signal hold_reg           : std_logic_vector(7 downto 0);
  signal ld_data            : std_logic;
  signal ld_data_d          : std_logic;
  signal ld_eop_d           : std_logic;
  signal ld_sop_d           : std_logic;
  signal bit_cnt            : std_logic_vector(2 downto 0);
  signal sft_done_e         : std_logic;
  signal append_eop         : std_logic;
  signal append_eop_sync1   : std_logic;
  signal append_eop_sync2   : std_logic;
  signal append_eop_sync3   : std_logic;
  signal append_eop_sync4   : std_logic;
  signal data_done          : std_logic;
  signal eop_done           : std_logic;
  signal hold_reg_d         : std_logic_vector(7 downto 0);
  signal one_cnt            : std_logic_vector(2 downto 0);
  signal sd_bs_o            : std_logic;
  signal sd_nrzi_o          : std_logic;
  signal sd_raw_o           : std_logic;
  signal sft_done           : std_logic;
  signal sft_done_r         : std_logic;
  signal state, next_state  : std_logic_vector(2 downto 0);
  signal stuff              : std_logic;
  signal tx_ip              : std_logic;
  signal tx_ip_sync         : std_logic;
  signal txoe_r1, txoe_r2   : std_logic;

  constant IDLE_STATE       : std_logic_vector := "000";
  constant SOP_STATE        : std_logic_vector := "001";
  constant DATA_STATE       : std_logic_vector := "010";
  constant EOP1_STATE       : std_logic_vector := "011";
  constant EOP2_STATE       : std_logic_vector := "100";
  constant WAIT_STATE       : std_logic_vector := "101";

begin

--======================================================================================--
  -- Misc Logic                                                                         --
--======================================================================================--

  p_TxReady_o: process (clk, rst)
  begin
    if rst ='0' then
      TxReady_o <= '0';
    elsif rising_edge(clk) then
      TxReady_o <= ld_data_d and TxValid_i;
    end if;
  end process;

  p_ld_data: process (clk)
  begin
    if rising_edge(clk) then
      ld_data <= ld_data_d;
    end if;
  end process;

--======================================================================================--
  -- Transmit in progress indicator                                                     --
--======================================================================================--

  p_tx_ip: process (clk, rst)
  begin
    if rst ='0' then
      tx_ip <= '0';
    elsif rising_edge(clk) then
      if ld_sop_d  ='1' then
        tx_ip <= '1';
      elsif eop_done ='1' then
        tx_ip <= '0';
      end if;
    end if;
  end process;

  p_tx_ip_sync: process (clk, rst)
  begin
    if rst ='0' then
      tx_ip_sync <= '0';
    elsif rising_edge(clk) then
      if fs_ce ='1' then
        tx_ip_sync <= tx_ip;
      end if;
    end if;
  end process;

  -- data_done helps us to catch cases where TxValid drops due to
  -- packet end and then gets re-asserted as a new packet starts.
  -- We might not see this because we are still transmitting.
  -- data_done should solve those cases ...
  p_data_done: process (clk, rst)
  begin
    if rst ='0' then
      data_done <= '0';
    elsif rising_edge(clk) then
      if TxValid_i ='1' and tx_ip ='0' then
        data_done <= '1';
      elsif TxValid_i = '0' then
        data_done <= '0';
      end if;
    end if;
  end process;

--======================================================================================--
  -- Shift Register                                                                     --
--======================================================================================--

  p_bit_cnt: process (clk, rst)
  begin
    if rst ='0' then
      bit_cnt <= "000";
    elsif rising_edge(clk) then
      if tx_ip_sync ='0' then
        bit_cnt <= "000";
      elsif fs_ce ='1' and stuff ='0' then
        bit_cnt <= bit_cnt + 1;
      end if;
    end if;
  end process;

  p_sd_raw_o: process (clk)
  begin
    if rising_edge(clk) then
      if tx_ip_sync ='0' then
        sd_raw_o <= '0';
      else
        sd_raw_o <= hold_reg_d(CONV_INTEGER(UNSIGNED(bit_cnt)));
      end if;
    end if;
  end process;

  p_sft_done: process (clk)
  begin
    if rising_edge(clk) then
      if bit_cnt = "111" then
        sft_done <= not stuff;
      else
        sft_done <= '0';
      end if;
    end if;
  end process;

  p_sft_done_r: process (clk)
  begin
    if rising_edge(clk) then
      sft_done_r      <= sft_done;
    end if;
  end process;

  sft_done_e <= sft_done and not sft_done_r;

  -- Out Data Hold Register
  p_hold_reg: process (clk, rst)
  begin
    if rst ='0' then
        hold_reg   <= X"00";
        hold_reg_d <= X"00";
    elsif rising_edge(clk) then
      if ld_sop_d ='1' then
        hold_reg <= X"80";
      elsif ld_data ='1' then
        hold_reg <= DataOut_i;
      end if;
      hold_reg_d <= hold_reg;
    end if;
  end process;

--======================================================================================--
  -- Bit Stuffer                                                                        --
--======================================================================================--

  p_one_cnt: process (clk, rst)
  begin
    if rst ='0' then
      one_cnt <= "000";
    elsif rising_edge(clk) then
      if tx_ip_sync ='0' then
        one_cnt <= "000";
      elsif fs_ce ='1' then
        if sd_raw_o ='0' or stuff = '1' then
          one_cnt <= "000";
        else
          one_cnt <= one_cnt + 1;
        end if;
      end if;
    end if;
  end process;

  stuff   <= '1' when one_cnt = "110" else '0';

  p_sd_bs_o: process (clk, rst)
  begin
    if rst ='0' then
      sd_bs_o <= '0';
    elsif rising_edge(clk) then
      if fs_ce ='1' then
        if tx_ip_sync ='0' then
          sd_bs_o <= '0';
        else
          if stuff ='1' then
            sd_bs_o <= '0';
          else
            sd_bs_o <= sd_raw_o;
          end if;
        end if;
      end if;
    end if;
  end process;

--======================================================================================--
  -- NRZI Encoder                                                                       --
--======================================================================================--

  p_sd_nrzi_o: process (clk, rst)
  begin
    if rst ='0' then
      sd_nrzi_o <= '1';
    elsif rising_edge(clk) then
      if tx_ip_sync ='0' or txoe_r1 ='0' then
        sd_nrzi_o <= '1';
      elsif fs_ce ='1' then
        if sd_bs_o ='1' then
          sd_nrzi_o <= sd_nrzi_o;
        else
          sd_nrzi_o <= not sd_nrzi_o;
        end if;
      end if;
    end if;
  end process;

--======================================================================================--
  -- EOP append logic                                                                   --
--======================================================================================--

  p_append_eop: process (clk, rst)
  begin
    if rst ='0' then
      append_eop <= '0';
    elsif rising_edge(clk) then
      if ld_eop_d ='1' then
        append_eop <= '1';
      elsif append_eop_sync2 ='1' then
        append_eop <= '0';
      end if;
    end if;
  end process;

  p_append_eop_sync: process (clk, rst)
  begin
    if rst ='0' then
      append_eop_sync1 <= '0';
      append_eop_sync2 <= '0';
      append_eop_sync3 <= '0';
      append_eop_sync4 <= '0';
    elsif rising_edge(clk) then
      if fs_ce ='1' then
        append_eop_sync1 <= append_eop;
        append_eop_sync2 <= append_eop_sync1;
        append_eop_sync3 <= append_eop_sync2 or -- Make sure always 2 bit wide
                            (append_eop_sync3 and not append_eop_sync4);
        append_eop_sync4 <= append_eop_sync3;
      end if;
    end if;
  end process;

  eop_done <= append_eop_sync3;

--======================================================================================--
  -- Output Enable Logic                                                                --
--======================================================================================--

  p_txoe: process (clk, rst)
  begin
    if rst ='0' then
      txoe_r1 <= '0';
      txoe_r2 <= '0';
      txoe    <= '1';
    elsif rising_edge(clk) then
      if fs_ce ='1' then
        txoe_r1 <= tx_ip_sync;
        txoe_r2 <= txoe_r1;
        txoe    <= not (txoe_r1 or txoe_r2);
      end if;
    end if;
  end process;

--======================================================================================--
  -- Output Registers                                                                   --
--======================================================================================--

  p_txdpn: process (clk, rst)
  begin
    if rst ='0' then
      txdp <= '1';
      txdn <= '0';
    elsif rising_edge(clk) then
      if fs_ce ='1' then
        if phy_mode ='1' then
          txdp <= not append_eop_sync3 and     sd_nrzi_o;
          txdn <= not append_eop_sync3 and not sd_nrzi_o;
        else
          txdp <= sd_nrzi_o;
          txdn <= append_eop_sync3;
        end if;
      end if;
    end if;
  end process;

--======================================================================================--
  -- Tx Statemashine                                                                    --
--======================================================================================--

  p_state: process (clk, rst)
  begin
    if rst ='0' then
      state <= IDLE_STATE;
    elsif rising_edge(clk) then
      state <= next_state;
    end if;
  end process;

  p_next_state: process (rst, state, TxValid_i, data_done, sft_done_e, eop_done, fs_ce)
  begin
    if rst='0' then
      next_state <= IDLE_STATE;
    else
      case (state) is
        when IDLE_STATE => if TxValid_i ='1' then
                             next_state <= SOP_STATE;
                           ELSE
                             next_state <= IDLE_STATE;
                           end if;
        when SOP_STATE  => if sft_done_e ='1' then
                             next_state <= DATA_STATE;
                           ELSE
                             next_state <= SOP_STATE;
                           end if;
        when DATA_STATE => if data_done ='0' and sft_done_e ='1' then
                             next_state <= EOP1_STATE;
                           ELSE
                             next_state <= DATA_STATE;
                           end if;
        when EOP1_STATE => if eop_done ='1' then
                             next_state <= EOP2_STATE;
                           ELSE
                             next_state <= EOP1_STATE;
                           end if;
        when EOP2_STATE => if eop_done ='0' and fs_ce ='1' then
                             next_state <= WAIT_STATE;
                           ELSE
                             next_state <= EOP2_STATE;
                           end if;
        when WAIT_STATE => if fs_ce = '1' then
                             next_state <= IDLE_STATE;
                           ELSE
                             next_state <= WAIT_STATE;
                           end if;
        when others     => next_state <= IDLE_STATE;
      end case;
    end if;
  end process;

  ld_sop_d  <= TxValid_i  when state = IDLE_STATE else '0';
  ld_data_d <= sft_done_e when state = SOP_STATE or (state = DATA_STATE and data_done ='1') else '0';
  ld_eop_d  <= sft_done_e when state = Data_STATE and data_done ='0' else '0';

end RTL;

