----------------------------------------------------------------------------------
-- Company:  ziti, Uni. HD
-- Engineer:  wgao
-- 
-- Create Date:    11:47:02 07 Dec 2006 
-- Design Name: 
-- Module Name:    Tx_Output_Arbitor - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies:
--
-- Revision 1.00 - first release.  14.12.2006
-- 
-- Additional Comments:
--                      Dimension can be easily expanded.
-- 
----------------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

library work;
use work.abb64Package.all;


-----------  Top entity   ---------------
entity Tx_Output_Arbitor is
        port (
              rst_n     : IN  std_logic;
              clk       : IN  std_logic;

              arbtake   : IN  std_logic;                                       -- take a valid arbitration by the user
              Req       : IN  std_logic_vector(C_ARBITRATE_WIDTH-1 downto 0);  -- similar to FIFO not-empty

              bufread   : OUT std_logic_vector(C_ARBITRATE_WIDTH-1 downto 0);  -- Read FIFO
              Ack       : OUT std_logic_vector(C_ARBITRATE_WIDTH-1 downto 0)   -- tells who is the winner
        );
end Tx_Output_Arbitor;


architecture Behavioral of Tx_Output_Arbitor is

  TYPE ArbStates is         ( 
                               aSt_Reset
                             , aSt_Idle
                             , aSt_ReadOne
                             , aSt_Ready
                             );

  signal Arb_FSM             : ArbStates;
  signal Arb_FSM_NS          : ArbStates;


  TYPE PriorMatrix is ARRAY (C_ARBITRATE_WIDTH-1 downto 0) 
                               of std_logic_vector (C_ARBITRATE_WIDTH-1 downto 0);

  signal ChPriority          : PriorMatrix;

  signal Prior_Init_Value    : PriorMatrix;

  signal Wide_Req            : PriorMatrix;

  signal Wide_Req_turned     : PriorMatrix;


  signal  take_i             :  std_logic;
  signal  Req_i              :  std_logic_vector(C_ARBITRATE_WIDTH-1 downto 0);

  signal  Req_r1             :  std_logic_vector(C_ARBITRATE_WIDTH-1 downto 0);

  signal  read_prep          :  std_logic_vector(C_ARBITRATE_WIDTH-1 downto 0);
  signal  read_i             :  std_logic_vector(C_ARBITRATE_WIDTH-1 downto 0);
  signal  Indice_prep        :  std_logic_vector(C_ARBITRATE_WIDTH-1 downto 0);
  signal  Indice_i           :  std_logic_vector(C_ARBITRATE_WIDTH-1 downto 0);

  signal  Champion_Vector    :  std_logic_vector (C_ARBITRATE_WIDTH-1 downto 0);


begin

   bufread   <= read_i;
   Ack       <= Indice_i;

   take_i    <= arbtake;
   Req_i     <= Req;

  -- ------------------------------------------------------------
  Prior_Init_Value(0) <= C_LOWEST_PRIORITY;
  Gen_Prior_Init_Values:
    FOR i IN 1 TO C_ARBITRATE_WIDTH-1 generate
      Prior_Init_Value(i) <= Prior_Init_Value(i-1)(C_ARBITRATE_WIDTH-2 downto 0) & '1';
    end generate;


  -- ------------------------------------------------------------
  --  Mask the requests
  -- 
  Gen_Wide_Requests:
    FOR i IN 0 TO C_ARBITRATE_WIDTH-1 generate
      Wide_Req(i) <= ChPriority(i) when Req_i(i)='1'
                     else C_ALL_ZEROS(C_ARBITRATE_WIDTH-1 downto 0);
    end generate;


-- ------------------------------------
-- Synchronous Delay: Req
--
   Synch_Delay_Req:
   process(clk)
   begin
     if clk'event and clk = '1' then
       Req_r1  <= Req_i;
     end if;
   end process;


-- ------------------------------------
-- Synchronous: States
--
   Seq_FSM_NextState:
   process(clk, rst_n)
   begin
     if (rst_n = '0') then
       Arb_FSM <= aSt_Reset;
     elsif clk'event and clk = '1' then
       Arb_FSM <= Arb_FSM_NS;
     end if;
   end process;


-- ------------------------------------
-- Combinatorial: Next States
--
   Comb_FSM_NextState:
   process ( 
             Arb_FSM
           , take_i
           , Req_r1
           )
   begin
     case Arb_FSM  is

       when aSt_Reset  =>
          Arb_FSM_NS <= aSt_Idle;

       when aSt_Idle  =>
          if Req_r1 = C_ALL_ZEROS(C_ARBITRATE_WIDTH-1 downto 0) then
             Arb_FSM_NS <= aSt_Idle;
          else
             Arb_FSM_NS <= aSt_ReadOne;
          end if;

       when aSt_ReadOne  =>
          if Req_r1 = C_ALL_ZEROS(C_ARBITRATE_WIDTH-1 downto 0) then  -- Ghost Request !!!
             Arb_FSM_NS <= aSt_Idle;
          else
             Arb_FSM_NS <= aSt_Ready;
          end if;

       when aSt_Ready  =>
          if take_i = '0' then
             Arb_FSM_NS <= aSt_Ready;
          elsif Req_r1 = C_ALL_ZEROS(C_ARBITRATE_WIDTH-1 downto 0) then
             Arb_FSM_NS <= aSt_Idle;
          else
             Arb_FSM_NS <= aSt_ReadOne;
          end if;

       when Others  =>
          Arb_FSM_NS <= aSt_Reset;

     end case;

   end process;


-- --------------------------------------------------
-- Turn the Request-Array Around
--
   Turn_the_Request_Array_Around:
       FOR i IN 0 TO C_ARBITRATE_WIDTH-1 generate
         Dimension_2nd:
         FOR j IN 0 TO C_ARBITRATE_WIDTH-1 generate
            Wide_Req_turned(i)(j) <= Wide_Req(j)(i);
         END generate;
       END generate;


-- --------------------------------------------------
-- Synchronous Calculation: Champion_Vector
--
   Sync_Champion_Vector:
   process(clk)
   begin
     if clk'event and clk = '1' then

       FOR i IN 0 TO C_ARBITRATE_WIDTH-1 LOOP
         if Wide_Req_turned(i)=C_ALL_ZEROS(C_ARBITRATE_WIDTH-1 downto 0) then
            Champion_Vector(i) <= '0';
         else
            Champion_Vector(i) <= '1';
         end if;
       END LOOP;

     end if;
   end process;


-- --------------------------------------------------
--  Prepare the buffer read signal: read_i
-- 
   Gen_Read_Signals:
     FOR i IN 0 TO C_ARBITRATE_WIDTH-1 generate
       read_prep(i) <= '1' when Champion_Vector=ChPriority(i) else '0';
     end generate;


-- --------------------------------------------------
-- FSM Output :  Buffer read_i and Indice_i
--
   FSM_Output_read_Indice:
   process (clk, rst_n)
   begin
     if (rst_n = '0') then
       read_i      <= C_ALL_ZEROS(C_ARBITRATE_WIDTH-1 downto 0);
       Indice_prep <= C_ALL_ZEROS(C_ARBITRATE_WIDTH-1 downto 0);
       Indice_i    <= C_ALL_ZEROS(C_ARBITRATE_WIDTH-1 downto 0);
     elsif clk'event and clk = '1' then

       case Arb_FSM is

         when aSt_ReadOne =>
           read_i      <= read_prep;
           Indice_prep <= read_prep;
           Indice_i    <= C_ALL_ZEROS(C_ARBITRATE_WIDTH-1 downto 0);

         when aSt_Ready =>
           read_i      <= C_ALL_ZEROS(C_ARBITRATE_WIDTH-1 downto 0);
           Indice_prep <= Indice_prep;
           if take_i ='1' then
            Indice_i    <= C_ALL_ZEROS(C_ARBITRATE_WIDTH-1 downto 0);
           else
            Indice_i    <= Indice_prep;
           end if;

         when Others =>
           read_i      <= C_ALL_ZEROS(C_ARBITRATE_WIDTH-1 downto 0);
           Indice_prep <= Indice_prep;
           Indice_i    <= C_ALL_ZEROS(C_ARBITRATE_WIDTH-1 downto 0);

       end case;

     end if;
   end process;


-- --------------------------------------------------
--
 Gen_Modify_Priorities:

   FOR i IN 0 TO C_ARBITRATE_WIDTH-1 generate

      Proc_Priority_Cycling:
      process (clk, rst_n)
      begin
        if (rst_n = '0') then
          ChPriority(i) <= Prior_Init_Value(i);
        elsif clk'event and clk = '1' then

          case Arb_FSM is

            when aSt_ReadOne =>
              if ChPriority(i) = Champion_Vector then
                 ChPriority(i) <= C_LOWEST_PRIORITY;
              elsif (ChPriority(i) and Champion_Vector) = Champion_Vector then
                 ChPriority(i) <= ChPriority(i);
              else
                 ChPriority(i) <= ChPriority(i)(C_ARBITRATE_WIDTH-2 downto 0) & '1';
              end if;

            when Others =>
                 ChPriority(i) <= ChPriority(i);

          end case;

        end if;
      end process;

  end generate;


end architecture Behavioral;
