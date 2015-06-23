----------------------------------------------------------------------------------
-- Company: Eastern Washington University, Cheney, WA 
-- Engineer: Justin Wagner
-- 
-- Create Date:    7/Oct/2011
-- Design Name: 
-- Module Name:    arp_responder - rtl 
-- Project Name: 
-- Target Devices:  n/a
-- Tool versions: 
-- Description: Project for Job application to XR Trading
--
-- Dependencies: arp_package.vhdl (Definitions of various constants)
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use work.arp_package.all;

entity arp_responder is
Port (  ARESET        : in   STD_LOGIC;
        MY_MAC        : in   std_logic_vector(47 downto 0); --my MAC address
        MY_IPV4       : in   std_logic_vector(31 downto 0); --my IPV4 address
        CLK_RX        : in   STD_LOGIC;
        DATA_VALID_RX : in   STD_LOGIC;
        DATA_RX       : in   std_logic_vector(7 downto 0);
        CLK_TX        : in   STD_LOGIC;
        DATA_ACK_TX   : in   STD_LOGIC;
        DATA_VALID_TX : out  STD_LOGIC;
        DATA_TX       : out  std_logic_vector(7 downto 0)
      );
end arp_responder;
----------------------------------------------------------------------------------
architecture rtl of arp_responder is
    -- Edge Detector used to find positive edge of DATA_VALID_RX
    component edge_detector
        port(
                din   :  in  std_logic;
                clk   :  in  std_logic;
                rst_n :  in  std_logic;
                dout  :  out std_logic
            );
    end component edge_detector;

    --the following declares the various states for the machine
    type state_type is (IDLE, 
                        CHECK_DA, CHECK_SA, CHECK_E_TYPE, CHECK_H_TYPE, CHECK_P_TYPE, 
                        CHECK_H_LEN, CHECK_P_LEN, CHECK_OPER, CHECK_SHA, CHECK_SPA, 
                        IGNORE_THA, CHECK_TPA,
                        GEN_DA, GEN_SA, GEN_E_TYPE, GEN_H_TYPE, GEN_P_TYPE, 
                        GEN_H_LEN, GEN_P_LEN, GEN_OPER, GEN_SHA, GEN_SPA, 
                        GEN_THA, GEN_TPA);

    signal SA_mem, next_SA_mem                      : HA_mem_type;
    signal SPA_mem, next_SPA_mem                    : PA_mem_type;
    signal next_state, state                        : state_type;    
    signal next_counter, counter                    : std_logic_vector(3 downto 0);
    signal posedge_DATA_VALID_RX                    : std_logic;
    signal next_DATA_VALID_TX, next_2_DATA_VALID_TX : std_logic;
    signal next_DATA_TX, next_2_DATA_TX             : std_logic_vector(7 downto 0);

begin

    -- A positive edge detector for the DATA_VALID_RX signal
    ed_1: edge_detector
          port map(
                  din   =>  DATA_VALID_RX,
                  clk   =>  CLK_RX,
                  rst_n =>  not(ARESET),
                  dout  =>  posedge_DATA_VALID_RX
                  );

----------------------------------------------------------------------------------
-- This process describes the flow from one state to another in the FSM-----------
-- It also describes what the outputs should be at each state---------------------
----------------------------------------------------------------------------------
combo:process(state, posedge_DATA_VALID_RX, counter, SA_mem, SPA_mem, DATA_ACK_TX, 
                MY_MAC, MY_IPV4)
begin
-- Hold Values by Default
-- These values will hold true in every state unless a state explicitly defines 
-- a different value for any of these signals.
 next_DATA_TX           <= (others => '0');
 next_DATA_VALID_TX     <= '0';
 next_counter           <= counter;
 next_SA_mem            <= SA_mem;
 next_SPA_mem           <= SPA_mem;

------------------------------------------------------------------
--State Machine Start...Please see ASM chart for State Diagram----
    case state is

        when IDLE =>
            if (posedge_DATA_VALID_RX ='1') then
              next_state                    <= CHECK_DA;
            else                            
              next_state                    <= IDLE;
            end if;
            next_SA_mem                     <=  ((others => '0'),(others => '0'),(others => '0'),(others => '0'),(others => '0'),(others => '0'));                         
            next_SPA_mem                    <=  ((others => '0'),(others => '0'),(others => '0'),(others => '0'));                          
            next_counter                    <=  (others => '0');

        when CHECK_DA =>
        -- Validate that the DA is a Broadcast, if not return to IDLE
            next_counter                    <= counter + 1;
            if (DATA_RX = MAC_BDCST_ADDR(conv_integer(counter))) then
                if (counter < 5) then
                    next_state              <= CHECK_DA;
                else                        
                    next_state              <= CHECK_SA;
                    next_counter            <= (others => '0');
                end if;
            else
                next_state                  <= IDLE;
                next_counter                <= (others => '0');
            end if;

        when CHECK_SA =>
        -- Lets store the SA so we can respond to it later
            next_counter                        <= counter + 1;
            next_state                          <= CHECK_SA;
            next_SA_mem(conv_integer(counter))  <= DATA_RX;
            if (counter >= 5) then
                next_state                  <= CHECK_E_TYPE;
                next_counter                <= (others => '0');
            end if;

        when CHECK_E_TYPE =>  
        -- Verify that the E_TYPE is the ARP ETYPE
            next_counter                    <= counter + 1;
            if (DATA_RX = E_TYPE_ARP(conv_integer(counter))) then
                next_state                  <= CHECK_E_TYPE;
                if (counter >= 1) then
                    next_state              <= CHECK_H_TYPE;
                    next_counter            <= (others => '0');
                end if;
            else
                next_state                  <= IDLE;
                next_counter                <= (others => '0');
            end if;

        when CHECK_H_TYPE =>
        -- Verify that the H_TYPE is the Ethernet HTYPE
            next_counter                    <= counter + 1;
            if (DATA_RX = H_TYPE_ETH(conv_integer(counter))) then
                next_state                  <= CHECK_H_TYPE;
                if (counter >= 1) then
                    next_state              <= CHECK_P_TYPE;
                    next_counter            <= (others => '0');
                end if;
            else
                next_state                  <= IDLE;
                next_counter                <= (others => '0');
            end if;

        when CHECK_P_TYPE =>
        -- Verify that the P_TYPE is the IPV4 PTYPE
            next_counter                    <= counter + 1;
            if (DATA_RX = P_TYPE_IPV4(conv_integer(counter))) then
                next_state                  <= CHECK_P_TYPE;
                if (counter >= 1) then
                    next_state              <= CHECK_H_LEN;
                    next_counter            <= (others => '0');
                end if;
            else
                next_state                  <= IDLE;
                next_counter                <= (others => '0');
            end if;

        when CHECK_H_LEN =>
        -- Verify that the H_LEN is the Ethernet Length
            next_counter                    <= (others => '0');
            if (DATA_RX = H_TYPE_ETH_LEN) then
                next_state                  <= CHECK_P_LEN;
            else
                next_state                  <= IDLE;
            end if;

        when CHECK_P_LEN =>
        -- Verify that the P_LEN is the IPV4 Length
            next_counter                    <= (others => '0');
            if (DATA_RX = P_TYPE_IPV4_LEN) then
                next_state                  <= CHECK_OPER;
            else
                next_state                  <= IDLE;
            end if;

        when CHECK_OPER =>
        -- Verify that we received an ARP Request
            next_counter                    <= counter + 1;
            if (DATA_RX = ARP_OPER_REQ(conv_integer(counter))) then
                next_state                  <= CHECK_OPER;
                if (counter >= 1) then
                    next_state              <= CHECK_SHA;
                    next_counter            <= (others => '0');
                end if;
            else
                next_state                  <= IDLE;
                next_counter                <= (others => '0');
            end if;

        when CHECK_SHA =>
        -- Ignore the SHA field since we already retrieved this 
        -- from the Ethernet header
            next_counter                    <= counter + 1;
            next_state                      <= CHECK_SHA;
            if (counter >= 5) then
                next_counter                <= (others => '0');
                next_state                  <= CHECK_SPA;
            end if;

        when CHECK_SPA =>         
        -- Lets store the SPA so we can respond to it later
            next_counter                        <= counter + 1;
            next_state                          <= CHECK_SPA;
            next_SPA_mem(conv_integer(counter)) <= DATA_RX;
            if (counter >= 3) then
                next_state                  <= IGNORE_THA;
                next_counter                <= (others => '0');
            end if;

        when IGNORE_THA => 
        -- Ignore the destination Hardware Address (ARP requests can't fill this out by definition)
            next_state                      <= IGNORE_THA;
            next_counter                    <= counter + 1;
            if (counter >= 5) then
                next_state                  <= CHECK_TPA;
                next_counter                <= (others => '0');
            end if;

        when CHECK_TPA =>       
        -- Make sure we are the destination Protocol Address       
            next_counter                    <= counter + 1;
            if (DATA_RX = MY_IPV4((31-(conv_integer(counter)*8)) downto (24-(conv_integer(counter)*8)))) then
                next_state                  <= CHECK_TPA;
                if (counter >= 3) then
                    next_state              <= GEN_DA;
                    next_counter            <= (others => '0');
                end if;
            else
                next_state                  <= IDLE;
                next_counter                <= (others => '0');
            end if;

        -- GENERATE AN ARP RESPONSE

        when GEN_DA =>  
        -- Generate the DA for the response
            next_DATA_VALID_TX              <= '1';
            next_DATA_TX                    <= SA_mem(conv_integer(counter));
            if (DATA_ACK_TX = '0' AND counter = 0) then
                next_counter                <= (others => '0');
            else
                next_counter                <= counter + 1;
            end if;
            if (counter < 5) then
                next_state                  <= GEN_DA;
            else                            
                next_state                  <= GEN_SA;
                next_counter                <= (others => '0');
            end if;

        when GEN_SA =>  
        -- Generate the DA for the response
            next_DATA_VALID_TX              <= '1';
            next_counter                    <= counter + 1;
            next_DATA_TX                    <= MY_MAC((47-(conv_integer(counter)*8)) downto (40-(conv_integer(counter)*8)));
            if (counter < 5) then
                next_state                  <= GEN_SA;
            else                            
                next_state                  <= GEN_E_TYPE;
                next_counter                <= (others => '0');
            end if;

        when GEN_E_TYPE =>                  
        -- Generate the E_TYPE for the response
            next_DATA_VALID_TX              <= '1';
            next_counter                    <= counter + 1;
            next_DATA_TX                    <= E_TYPE_ARP(conv_integer(counter));
            if (counter < 1) then
                next_state                  <= GEN_E_TYPE;
            else                            
                next_state                  <= GEN_H_TYPE;
                next_counter                <= (others => '0');
            end if;

        when GEN_H_TYPE =>                  
        -- Generate the H_TYPE for the response
            next_DATA_VALID_TX              <= '1';
            next_counter                    <= counter + 1;
            next_DATA_TX                    <= H_TYPE_ETH(conv_integer(counter));
            if (counter < 1) then
                next_state                  <= GEN_H_TYPE;
            else                            
                next_state                  <= GEN_P_TYPE;
                next_counter                <= (others => '0');
            end if;

        when GEN_P_TYPE =>                  
        -- Generate the P_TYPE for the response
            next_DATA_VALID_TX              <= '1';
            next_counter                    <= counter + 1;
            next_DATA_TX                    <= P_TYPE_IPV4(conv_integer(counter));
            if (counter < 1) then
                next_state                  <= GEN_P_TYPE;
            else                            
                next_state                  <= GEN_H_LEN;
                next_counter                <= (others => '0');
            end if;

        when GEN_H_LEN =>                   
            next_DATA_VALID_TX              <= '1';
            next_DATA_TX                    <= H_TYPE_ETH_LEN;
            next_state                      <= GEN_P_LEN;              

        when GEN_P_LEN =>                   
            next_DATA_VALID_TX              <= '1';
            next_DATA_TX                    <= P_TYPE_IPV4_LEN;
            next_state                      <= GEN_OPER;              

        when GEN_OPER =>                    
            next_DATA_VALID_TX              <= '1';
            next_counter                    <= counter + 1;
            next_DATA_TX                    <= ARP_OPER_RESP(conv_integer(counter));
            if (counter < 1) then
                next_state                  <= GEN_OPER;
            else                            
                next_state                  <= GEN_SHA;
                next_counter                <= (others => '0');
            end if;

        when GEN_SHA =>                     
            next_DATA_VALID_TX              <= '1';
            next_counter                    <= counter + 1;
            next_DATA_TX                    <= MY_MAC((47-(conv_integer(counter)*8)) downto (40-(conv_integer(counter)*8)));
            if (counter < 5) then
                next_state                  <= GEN_SHA;
            else                            
                next_state                  <= GEN_SPA;
                next_counter                <= (others => '0');
            end if;

        when GEN_SPA =>                     
            next_DATA_VALID_TX              <= '1';
            next_counter                    <= counter + 1;
            next_DATA_TX                    <= MY_IPV4((31-(conv_integer(counter)*8)) downto (24-(conv_integer(counter)*8)));
            if (counter < 3) then
                next_state                  <= GEN_SPA;
            else                            
                next_state                  <= GEN_THA;
                next_counter                <= (others => '0');
            end if;

        when GEN_THA =>                     
        -- Generate the THA for the response
            next_DATA_VALID_TX              <= '1';
            next_counter                    <= counter + 1;
            next_DATA_TX                    <= SA_mem(conv_integer(counter));
            if (counter < 5) then
                next_state                  <= GEN_THA;
            else                            
                next_state                  <= GEN_TPA;
                next_counter                <= (others => '0');
            end if;

        when GEN_TPA =>                     
        -- Generate the TPA for the response
            next_DATA_VALID_TX              <= '1';
            next_counter                    <= counter + 1;
            next_DATA_TX                    <= SPA_mem(conv_integer(counter));
            if (counter < 3) then
                next_state                  <= GEN_TPA;
            else                            
                next_state                  <= IDLE;
                next_counter                <= (others => '0');
            end if;
               
        when others =>            
            next_state    <= IDLE;

    end case;

end process combo;
----------------------------------------------------------------------------------
--Sequential Logic Processes--------------------------------------------------------
----------------------------------------------------------------------------------
seq_RX:process(CLK_RX, ARESET)
begin

    if (ARESET='1') then --resetting the board
        state               <= IDLE;
        counter             <= (others => '0');
        SA_mem              <= ((others => '0'),(others => '0'),(others => '0'),(others => '0'),(others => '0'),(others => '0'));
        SPA_mem             <= ((others => '0'),(others => '0'),(others => '0'),(others => '0'));
      
    -- move next state values into registers on clock edge
    elsif (CLK_RX'event and CLK_RX ='1') then 
        state               <= next_state;
        counter             <= next_counter;
        SA_mem              <= next_SA_mem;
        SPA_mem             <= next_SPA_mem;
       
    else
        NULL;
    end if;

end process seq_RX;

seq_TX:process(CLK_TX, ARESET)
begin

    if (ARESET='1') then --resetting the board
        DATA_VALID_TX               <= '0'; 
        DATA_TX                     <= (others => '0'); 
        next_2_DATA_VALID_TX        <= '0';
        next_2_DATA_TX              <= (others => '0'); 
    -- move next state values into registers on clock edge
    elsif (CLK_TX'event and CLK_TX ='1') then 
        next_2_DATA_VALID_TX        <= next_DATA_VALID_TX;
        next_2_DATA_TX              <= next_DATA_TX;
        DATA_VALID_TX               <= next_2_DATA_VALID_TX;
        DATA_TX                     <= next_2_DATA_TX;
    else
        NULL;
    end if;

end process seq_TX;

end rtl;
