Interconnect Conventions
=========================
 
These are the interface conventions followed by the VHDLToolbox.
The main aims of the interface are:
  - To be simple to implement.
  - Add little performance/logic overhead.
  - Allow designs to grow without adding extra levels of asynchronous logic.
  - Easy to interface with standard interconnects.
 
::
 
  RST >-o-----------------------------+
  CLK >-+-o-------------------------+ |
        | |                         | |
        | |   +-----------+         | |     +--------------+
        | |   | TX        |         | |     | RX           |
        | +--->           |         | +----->              |
        +----->           |         +------->              |
              |           |                 |              |
              |           | <BUS_NAME>      |              |
              |       out >=================> in           |
              |           | <BUS_NAME>_STB  |              |
              |       out >-----------------> in           |
              |           | <BUS_NAME>_ACK  |              |
              |       in  <-----------------< out          |
              |           |                 |              |
              +-----------+                 +--------------+
 
Global Signals
--------------
 
  +------+------------+-------------------+--------------+
  | Name |  Direction |        Type       |  Description |
  +======+============+===================+==============+
  | CLK  |    input   |  std_logic Global |     Clock    |
  +------+------------+-------------------+--------------+
  | RST  |    input   |  std_logic Global |     Reset    |
  +------+------------+-------------------+--------------+
 
Interconnect Signals
--------------------
 
  +----------------+------------+-------------------+------------------------------------------------------------+
  |      Name      |  Direction |        Type       |                         Description                        |
  +================+============+===================+============================================================+
  |   <BUS_NAME>   |  TX to RX  |  std_logic_vector |                        Payload Data                        |
  +----------------+------------+-------------------+------------------------------------------------------------+
  | <BUS_NAME>_STB |  TX to RX  |      std_logic    |  '1' indicates that payload data is valid and TX is ready. |
  +----------------+------------+-------------------+------------------------------------------------------------+
  | <BUS_NAME>_ACK |  TX to RX  |      std_logic    |               '1' indicates that RX is ready.              |
  +----------------+------------+-------------------+------------------------------------------------------------+
 
Interconnect Bus Transaction
----------------------------
 
  - Both transmitter and receiver shall be synchronised to the '0' -> '1' transition of CLK.
  - If RST is set to '1' upon the '0' -> '1' transition of clock the transmitter shall terminate any active bus transaction and set <BUS_NAME>_STB to '0'.
  - If RST is set to '1' upon the '0' -> '1' transition of clock the receiver shall terminate any active bus transaction and set <BUS_NAME>_ACK to '0'.
  - If RST is set to '0', normal operation shall commence as follows:
  - The transmitter may insert wait states on the bus by setting <BUS_NAME>_STB '0'.
  - The transmitter shall set <BUS_NAME>_STB to '1' to signify that data is valid.
  - Once <BUS_NAME>_STB has been set to '1', it shall remain at '1' until the transaction completes.
  - The transmitter shall ensure that <BUS_NAME> contains valid data for the entire period that <BUS_NAME>_STB is '1'.
  - The transmitter may set <BUS_NAME> to any value when <BUS_NAME>_STB is '0'.
  - The receiver may insert wait states on the bus by setting <BUS_NAME>_ACK to '0'.
  - The receiver shall set <BUS_NAME>_ACK to '1' to signify that it is ready to receive data.
  - Once <BUS_NAME>_ACK has been set to '1', it shall remain at '1' until the transaction completes.
  - Whenever <BUS_NAME>_STB is '1' and <BUS_NAME>_ACK are '1', a bus transaction shall complete on the following '0' -> '1' transition of CLK.
 
::
 
RST                                                                           
                 --------------------------------------------------------------
                   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -  
 CLK              | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | |
                 -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -
 
                 ----- ------- ------------------------------------------------
<BUS_NAME>           X VALID X
                 ----- ------- ------------------------------------------------
                       -------
<BUS_NAME>_STB       |       |                                               
                 -----         ------------------------------------------------
                           ---
<BUS_NAME>_ACK           |   |                                                
                 ---------     ------------------------------------------------
 
 
                       ^^^^ RX adds wait states
 
                           ^^^^  Data transfers
 
RST                                                                          
                 --------------------------------------------------------------
                   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -  
 CLK              | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | |
                 -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -
 
                 ----- ------- ------------------------------------------------
<BUS_NAME>           X VALID X
                 ----- ------- ------------------------------------------------
                           ---
<BUS_NAME>_STB           |   |                                               
                 ---------     ------------------------------------------------
                       -------
<BUS_NAME>_ACK       |       |                                                
                 -----         ------------------------------------------------
 
 
                       ^^^^ TX adds wait states
 
                           ^^^^  Data transfers
 
- Both the transmitter and receiver may commence a new transaction without inserting any wait states.
 
::
RST                                                                          
                 --------------------------------------------------------------
                   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -  
 CLK              | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | |
                 -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -
 
                 ----- ------- ---- ---- --------------------------------------
<BUS_NAME>           X D0    X D1 X D2 X
                 ----- ------- ---- ---- --------------------------------------
                           -------------
<BUS_NAME>_STB           |             |                                     
                 ---------               --------------------------------------
                       -----------------
<BUS_NAME>_ACK       |                 |                                      
                 -----                   --------------------------------------
 
                        ^^^^ TX adds wait states
 
                             ^^^^  Data transfers
 
                                 ^^^^ STB and ACK needn't return to 0 between data words
 
 
- The receiver may delay a transaction by inserting wait states until the transmitter indicates that data is available.
 
- The transmitter shall not delay a transaction by inserting wait states until the receiver is ready to accept data.
 
- Deadlock would occur if both the transmitter and receiver delayed a transaction until the other was ready.
 
Example Transmitter FSM
-----------------------
 
::
 
  ...
 
  process
  begin
    wait until rising_edge(CLK);
 
    case STATE is
 
      ...
 
      when TRANSMIT_STATE =>
 
        S_BUS_STB <= '1';
        if S_BUS_STB = '1' and BUS_ACK = '1';
          LOCAL_DATA <= BUS;
          S_BUS_STB <= '0';
          STATE <= NEXT_STATE;
        end if;
 
      ...
 
      if RST = '1' then
        S_BUS_STB <= '0';
        ...
      end if;
 
  end process;
 
  BUS_STB <= S_BUS_STB;
 
  ...
 
 
Example Reciever FSM
--------------------
 
::
 
  ...
 
  process
  begin
    wait until rising_edge(CLK);
 
    case STATE is
 
      ...
 
      when RECIEVE_STATE =>
 
        S_BUS_ACK <= '1';
        BUS <= LOCAL_DATA;
        if BUS_STB = '1' and S_BUS_ACK = '1';
          S_BUS_ACK <= '0';
          STATE <= NEXT_STATE;
        end if;
 
      ...
      if RST = '1' then
        S_BUS_ACK <= '0';
        ...
      end if;
 
  end process;
 
  BUS_ACK <= S_BUS_ACK;
 
  ...
