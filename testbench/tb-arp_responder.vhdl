library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use std.textio.all;
use work.arp_package.all;

entity tb_arp_responder is
  --empty
end tb_arp_responder;


architecture beh of tb_arp_responder is

    COMPONENT arp_responder
    PORT(
         ARESET          : IN   std_logic;
         MY_MAC          : IN   std_logic_vector(47 downto 0);
         MY_IPV4         : IN   std_logic_vector(31 downto 0);
         CLK_RX          : IN   std_logic;
         DATA_VALID_RX   : IN   std_logic;
         DATA_RX         : IN   std_logic_vector(7 downto 0);
         CLK_TX          : IN   std_logic;
         DATA_ACK_TX     : IN   std_logic;
         DATA_VALID_TX   : OUT  std_logic;
         DATA_TX         : OUT  std_logic_vector(7 downto 0)
        );
    END COMPONENT;

    constant severity_c  : severity_level := failure;

    --Inputs
    signal ARESET        : std_logic := '0';
    signal MY_MAC        : std_logic_vector(47 downto 0) := x"00_01_42_00_5F_FF";
    signal MY_IPV4       : std_logic_vector(31 downto 0) := x"C0_A8_01_02";
    signal CLK_RX        : std_logic := '0';
    signal DATA_VALID_RX : std_logic := '0';
    signal DATA_RX       : std_logic_vector(7 downto 0) := (others => '0');
    signal CLK_TX        : std_logic := '0';
    signal TB_CLK        : std_logic := '0';
    signal DATA_ACK_TX   : std_logic := '0';
    
      --Outputs
    signal DATA_VALID_TX : std_logic;
    signal DATA_TX       : std_logic_vector(7 downto 0);
    
    -- Clock period definitions
    constant CLK_period  : time := 8 ns;
    constant TB_CLK_SKEW : time := 1 ns;
 
BEGIN
 
    -- Instantiate the Unit Under Test (UUT)
    uut: arp_responder PORT MAP (
          ARESET        => ARESET,
          MY_MAC        => MY_MAC,
          MY_IPV4       => MY_IPV4,
          CLK_RX        => CLK_RX,
          DATA_VALID_RX => DATA_VALID_RX,
          DATA_RX       => DATA_RX,
          CLK_TX        => CLK_TX,
          DATA_ACK_TX   => DATA_ACK_TX,
          DATA_VALID_TX => DATA_VALID_TX,
          DATA_TX       => DATA_TX
        );

    ----Testbench Clock Generator:
    tb_clk_gen : process
    begin
        TB_CLK <= '0';
        wait for CLK_period/2;
        TB_CLK <= '1';
        wait for CLK_period/2;
    end process;

    CLK_RX <= transport TB_CLK after TB_CLK_SKEW;
    CLK_TX <= not(CLK_RX);

    -- Stimulus process
    stim_proc: process

    --
    -- wait for the rising edge of tb_ck
    --
    procedure wait_tb_clk(num_cyc : integer := 1) is
    begin
        for i in 1 to num_cyc loop
            wait until TB_CLK'event and TB_CLK = '1';
        end loop;
    end wait_tb_clk;
    
    --
    -- wait for the rising edge of rx clk
    --
    procedure wait_rx_clk(num_cyc : integer := 1) is
    begin
        for i in 1 to num_cyc loop
            wait until CLK_RX'event and CLK_RX = '1';
        end loop;
    end wait_rx_clk;

    --
    -- wait for the rising edge of tx clk
    --
    procedure wait_tx_clk(num_cyc : integer := 1) is
    begin
        for i in 1 to num_cyc loop
            wait until CLK_TX'event and CLK_TX = '1';
        end loop;
    end wait_tx_clk;

    -- 
    -- Generate a valid ARP request
    -- 
    procedure gen_valid_arp_req is
    begin                
        -- Set the Data Valid flag
        DATA_VALID_RX <= '1';

        -- Generate BDCST DA
        for i in 0 to 5 loop
            DATA_RX       <= MAC_BDCST_ADDR(i);
            wait_tb_clk;
        end loop;
        
        -- Generate SA
        for i in 0 to 5 loop
            DATA_RX       <= CMP_A_MAC_ADDR(i);
            wait_tb_clk;
        end loop;
        
        -- Generate ARP E_TYPE
        for i in 0 to 1 loop
            DATA_RX       <= E_TYPE_ARP(i);
            wait_tb_clk;
        end loop;

        -- Generate Ethernet H_TYPE
        for i in 0 to 1 loop
            DATA_RX       <= H_TYPE_ETH(i);
            wait_tb_clk;
        end loop;

        -- Generate IPV4 P_TYPE
        for i in 0 to 1 loop
            DATA_RX       <= P_TYPE_IPV4(i);
            wait_tb_clk;
        end loop;

        -- Generate Ethernet H_LEN
        DATA_RX       <= H_TYPE_ETH_LEN;
        wait_tb_clk;

        -- Generate IPV4 P_LEN
        DATA_RX       <= P_TYPE_IPV4_LEN;
        wait_tb_clk;

        -- Generate OPER for ARP Request
        for i in 0 to 1 loop
            DATA_RX       <= ARP_OPER_REQ(i);
            wait_tb_clk;
        end loop;

        -- Generate SHA
        for i in 0 to 5 loop
            DATA_RX       <= CMP_A_MAC_ADDR(i);
            wait_tb_clk;
        end loop;

        -- Generate SPA
        for i in 0 to 3 loop
            DATA_RX       <= CMP_A_IPV4_ADDR(i);
            wait_tb_clk;
        end loop;

        -- Generate THA (Zero since we don't know it!)
        for i in 0 to 5 loop
            DATA_RX       <= (others => '0');
            wait_tb_clk;
        end loop;

        -- Generate TPA
        for i in 0 to 3 loop
            DATA_RX       <= MY_IPV4((31-i*8) downto (24-i*8));
            wait_tb_clk;
        end loop;

        -- Remove the Data Valid flag
        DATA_VALID_RX <= '0';

        -- End of Generated ARP Packet
    end gen_valid_arp_req;

    -- 
    -- Generate a valid ARP request
    -- 
    procedure gen_valid_eth_pkt(payload_size_bytes : integer := 46) is
    begin                
        -- Set the Data Valid flag
        DATA_VALID_RX <= '1';

        -- Generate BDCST DA
        for i in 0 to 5 loop
            DATA_RX       <= MY_MAC((47-i*8) downto (40-i*8));
            wait_tb_clk;
        end loop;
        
        -- Generate SA
        for i in 0 to 5 loop
            DATA_RX       <= CMP_A_MAC_ADDR(i);
            wait_tb_clk;
        end loop;
        
        -- Generate E_TYPE for IPV4
        for i in 0 to 1 loop
            DATA_RX       <= P_TYPE_IPV4(i);
            wait_tb_clk;
        end loop;

        -- Generate Payload
        for i in 1 to payload_size_bytes loop
            -- Incrementing bytes for payload
            DATA_RX       <= conv_std_logic_vector((i-1),8);
            wait_tb_clk;
        end loop;

        -- Generate fake FCS
        for i in 1 to 4 loop
            -- Incrementing bytes for FCS (x"F0",x"F1",etc)
            DATA_RX       <= conv_std_logic_vector(240+(i-1),8);
            wait_tb_clk;
        end loop;

        -- Remove the Data Valid flag
        DATA_VALID_RX <= '0';

        -- End of Generated Ethernet Packet
    end gen_valid_eth_pkt;

    -- 
    -- Receive an ARP response
    -- 
    procedure rec_arp_resp(wait_data_ack_tx : integer := 10) is
    begin     
        -- Handle the response
        wait until DATA_VALID_TX = '1';
        wait_tx_clk(wait_data_ack_tx);
        DATA_ACK_TX   <= '1';
        wait_tx_clk;
        DATA_ACK_TX   <= '0';
        wait until DATA_VALID_TX = '0'; 
    end rec_arp_resp;

    -- 
    -- Reset the Testbench
    -- 
    procedure reset_tb(time : integer := 10) is
    begin     
        -- hold reset state
        wait_tb_clk;
        ARESET <= '1';
        wait_tb_clk(time);
        ARESET <= '0';
    end reset_tb;

    -------------------------------------------------------------
    ----- BEGIN PROCESS -----------------------------------------
    -------------------------------------------------------------
    begin

        reset_tb;    
        gen_valid_arp_req;
        rec_arp_resp;
        wait_tb_clk(10);
        gen_valid_eth_pkt(46);
        wait_tb_clk(10);
        gen_valid_arp_req;
        rec_arp_resp;
        wait_tb_clk(10);
        gen_valid_arp_req;
        rec_arp_resp;
        wait_tb_clk(10);
        gen_valid_eth_pkt(46);
        wait_tb_clk(10);
        gen_valid_eth_pkt(76);
        wait_tb_clk(10);

        -- stop the simulation once you're done
        wait_tb_clk(50);
        assert false
        report "End of Simulation"
        severity severity_c;

    end process;


end beh;


