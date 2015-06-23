------------------------------------------------------------------------------
-- Title       : PIF2WB
-- Project    : Bridge PIF to WISHBONE / WISHBONE to PIF
-------------------------------------------------------------------------------
-- File       : PIF2WB.vhd
-- Author     : Edoardo Paone, Paolo Motto, Sergio Tota, Mario Casu
--              {sergio.tota,mario.casu}@polito.it
--              http://vlsilab.polito.it
-- Company    : Politecnico of Torino, VLSI-Lab, Dipartimento di Elettronica,
--              Corso Duca degli Abruzzi 24, 10129 Torino, Italy
-- Last update: 2007/08/01
-- Platform   : 
-------------------------------------------------------------------------------
-- Description: This bridge interfaces the Tensilica (www.tensilica.com) proprietary
--              PIF bus protocol with the OpenCores WishBone. It currently supports
--              a master PIF and a slave WB. Single-cycle as well burst transfers
--              are possible.
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author          Description
-- 2007/04/18  1.0      Edoardo         Created
-- 2007/07/18  1.1      Paolo Motto     2nd Revision
-- 2007/08/01  1.2      Sergio Tota     3rd Revision
-------------------------------------------------------------------------------

-- I have replaced all undefined signals with the low value '0'
-- BTE_O, in case of burst transfer, must always be "00", because this bridge supports
-- only linear incremental burst mode
-- State :
-- IDLE
-- SR    : Single Read
-- BR    : Block Read
-- SW    : Single Write
-- BW    : Block Write
-- R_ACK : Response to ACK_I in Block Read
-- W_ACK : Response to ACK_I in Block Write


library ieee;
use ieee.std_logic_1164.all;

entity PIF2WB is

  generic (
    constant DATA_SIZE_PIF : integer := 32;  -- this value specifies the data bus PIF parallelism
    constant DATA_SIZE_WB  : integer := 32;  -- this value specifies the data bus Wishbone parallelism    
    constant ADRS_SIZE     : integer := 32;  -- this value specifies the address bus length
    constant CNTL_PIF      : integer := 8;   -- The PIF CNTL vector size
    constant MSB_PIF       : integer := 31;  -- The PIF most significant bit
    constant LSB_PIF       : integer := 0;   -- The PIF least significant bit 
    constant MSB_WB        : integer := 31;  -- The Wishbone most significant bit
    constant LSB_WB        : integer := 0;   -- The Wishbone least significant bit
    constant ADRS_BITS	   : integer := 4;
    constant ADRS_RANGE    : integer := 8);


  port (

    CLK     : in std_logic;             -- the clock signal
    RST     : in std_logic;             -- the syncronus reset signal


    -- PIF signals

    PIReqVALID  : in  std_logic;
                                        -- Indicates that there is a valid request
    PIReqCNTL   : in  std_logic_vector(CNTL_PIF-1 downto 0);
                                        -- Encodes the data, size and last transfer information for requests
    PIReqADRS   : in  std_logic_vector(ADRS_SIZE-1 downto 0);
                                        -- Request address
    PIReqDATA   : in  std_logic_vector(DATA_SIZE_PIF-1 downto 0);
                                        -- Data used by requests that require data
    PIReqDataBE : in  std_logic_vector(DATA_SIZE_PIF/8-1 downto 0);
                                        -- Indicates valid bytes lanes of PIReqDATA
    POReqRDY    : out std_logic;
                                        -- Indicates that the slave is ready to accept requests
    PORespVALID : out std_logic;
                                        -- Indicates that there is a valid response
    PORespCNTL  : out std_logic_vector(CNTL_PIF-1 downto 0);
                                        -- Encodes the response type and any error
    PORespDATA  : out std_logic_vector(DATA_SIZE_PIF-1 downto 0);
                                        --Response data
    PIRespRDY   : in  std_logic;
                                        -- Indicates that the master is ready to accept responses

    -- WISHBONE signals

    ACK_I : in  std_logic;              -- The acknowledge input
    DAT_I : in  std_logic_vector(DATA_SIZE_WB-1 downto 0);
                                        -- The data input array
    ERR_I : in  std_logic;              -- Incates address or data error in transaction
    ADR_O : out std_logic_vector(ADRS_SIZE-1 downto 0);
                                        -- The address data output array
    DAT_O : out std_logic_vector(DATA_SIZE_WB-1 downto 0);
                                        -- The data output array
    CYC_O : out std_logic;              -- The cycle output
    SEL_O : out std_logic_vector(DATA_SIZE_WB/8-1 downto 0);
                                        -- The select output array
    STB_O : out std_logic;              -- The strobe output
    WE_O  : out std_logic;              -- The write enable output
    BTE_O : out std_logic_vector(1 downto 0);
                                        -- Indicates the burst length
    CTI_O : out std_logic_vector(2 downto 0) );
                                        -- Indicates the bus cycle type
end PIF2WB;


architecture PIF2WB_3process of PIF2WB is

  component Counter is
  	  generic (
  	  	constant DATA_SIZE_WB :     integer := 32;
    		constant ADRS_SIZE    :     integer := 32 );  -- Address bus length
	  port (
		CLK        : in  std_logic;
		RST        : in  std_logic;
		LOAD_ADDR  : in  std_logic;
		GO_UP      : in  std_logic;
		ADR_INIT   : in  std_logic_vector(ADRS_SIZE-1 downto 0);
		ADR_CNTR   : out std_logic_vector(ADRS_SIZE-1 downto 0);
		N_TRANSFER : out integer range 0 to 15);
  end component;

  component AdrDec is
  	  generic (
    		constant ADRS_SIZE    :     integer := 32;
    		constant ADRS_BITS    :     integer := 4;
    		constant ADRS_RANGE   :     integer := 8 );
	  port (
		AdrIn                 : in  std_logic_vector(ADRS_SIZE-1 downto ADRS_SIZE-ADRS_BITS);
    		AdrValid 	      : out std_logic);
  end component;
  
  component sel_reg is
		port (
				clk   : in std_logic;
				rst   : in std_logic;
				En    : in std_logic;
				sel_i : in  std_logic_vector (3 downto 0);
				sel_o : out std_logic_vector (3 downto 0)
				);
  end component;
  
  component tran_reg is
		port (
				clk   : in std_logic;
				rst   : in std_logic;
				En    : in std_logic;
				Num_i : in  integer range 0 to 15;
				Num_o : out integer range 0 to 15
				);
  end component;

  type state_type is (IDLE, SR, BR, SW, BW, R_ACK, W_ACK);

  signal state, next_state : state_type;
  signal N_TRANSFER          : integer range 0 to 15;
  signal TOT_TRANSFER_I      : integer range 0 to 15;
  signal TOT_TRANSFER_O      : integer range 0 to 15;
  
  -- Signals used by Counter
  signal LOAD_ADDR : std_logic;
  signal GO_UP     : std_logic;
  
  -- Signals used by Registers and Address Comparator
  signal AddressValid : std_logic;
  signal Enable       : std_logic;


begin

  Dec : AdrDec
	port map (
		AdrIn 	 => PIReqADRS (ADRS_SIZE-1 downto ADRS_SIZE-ADRS_BITS),
		AdrValid => AddressValid);
		
  reg0 : sel_reg
   	port map (
		clk 	=> clk,
		rst 	=> rst,
		En 	=> Enable,
		sel_i   => PIReqDataBE,
		sel_o   => SEL_O);
		
  reg1 : tran_reg
   	port map (
		clk 	=> clk,
		rst 	=> rst,
		En 	=> Enable,
		Num_i   => TOT_TRANSFER_I,
		Num_o   => TOT_TRANSFER_O);

  -- Counter used in burst mode
  Counter_Burst_Transfer : COUNTER
    	port map( CLK, RST, LOAD_ADDR, GO_UP, PIReqADRS, ADR_O, N_TRANSFER);

  -- purpose: every clock cycle updates the signals
  -- type   : sequential
  -- inputs : CLK, RST
  State_Register : process (CLK, RST)
  begin  -- process State_Register
    if  RST = '1' then
      state   <= IDLE;
    elsif CLK'event and CLK = '1' then  -- rising clock edge
      state <= next_state;
    end if;
  end process State_Register;

  -- purpose: It determines which will be the next state
  -- type   : combinational
  -- inputs : state, PIReqVALID, PIRespRDY, ACK_I, PIReqCNTL, N_TRANSFER, TOT_TRANSFER_O
  -- outputs: next_state
  Next_State_Function : process (state, PIReqVALID, PIRespRDY, ACK_I, PIReqCNTL, N_TRANSFER, TOT_TRANSFER_O, AddressValid)
  begin  -- process Next_State_Function
    case state is
      
      when IDLE =>
        if(PIReqVALID = '1' and ACK_I = '0' and AddressValid = '1') then  -- ACK_I=0 means POReqRDY='1'
          if(PIReqCNTL(7) = '0' and PIReqCNTL(4) = '0') then   
            	next_state <= SR;	-- single read cycle			
          elsif(PIReqCNTL(7) = '0' and PIReqCNTL(4) = '1') then                    
           	next_state <= BR;	-- burst read cycle
	  elsif(PIReqCNTL(7) = '1' and PIReqCNTL(4) = '0') then
		next_state <= SW;	-- single write cycle
	  elsif(PIReqCNTL(7) = '1' and PIReqCNTL(4) = '1') then
		next_state <= BW;	-- burst write cycle
	  else
		next_state <=  IDLE;
          end if;
	else
		next_state <= IDLE;
        end if;

      when SR =>
	if(ACK_I = '1' and PIRespRDY = '1') then
            next_state <= IDLE;
        else                          
            next_state <= SR;
        end if;

      when BR =>
	if (ACK_I = '1' and PIRespRDY = '1') then
	    	next_state <= R_ACK; 
	else
		next_state <= BR;
     end if;

      when SW =>
	if(ACK_I = '1' and PIRespRDY = '1') then
            next_state <= IDLE;
        else                          
            next_state <= SW;
        end if;

      when BW =>
	if (ACK_I = '1' and PIRespRDY = '1') then
	    	next_state <= W_ACK; 
	else
		next_state <= BW;
     end if;

      when R_ACK =>
	if (ACK_I = '0') then
		if N_TRANSFER = TOT_TRANSFER_O then
			next_state <= IDLE;
		else
			next_state <= BR;
		end if;
	else
		next_state <= R_ACK;
	end if;

      when W_ACK =>
	if (ACK_I = '0') then
		if (N_TRANSFER = TOT_TRANSFER_O  and  PIReqCNTL(0) = '1') then
			next_state <= IDLE;
		else
			next_state <= BW;
		end if;
	else
		next_state <= W_ACK;
	end if;

      when others =>
	next_state <= IDLE;
    
     end case;
  end process Next_State_Function;

  -- purpose: It assigns the correct values to output signals
  -- type   : combinational
  -- inputs : state, N_TRANSFER_O, PIReqCNTL, PIReqDATA, DAT_I, GO_UP, ERR_I
  -- outputs: 
  Output_Function : process (state, N_TRANSFER, TOT_TRANSFER_O, PIReqCNTL, PIReqDATA, DAT_I, ERR_I, ACK_I, DAT_I)
  begin  -- process Output_Function

    LOAD_ADDR 					<= '0';
    Enable    					<= '0';
    GO_UP					<= '0';
 
    BTE_O     					<= "00";
    DAT_O					<= (others => 'Z');
    CYC_O					<= '0';
    STB_O					<= '0';
    WE_O					<= '0';
    CTI_O					<= (others => '0');
    
    PORespVALID             			<= ACK_I;
    POReqRDY 					<= '1';
    PORespDATA					<= (others => 'Z');
    PORespCNTL (7 downto 3)			<= (others => '0');
    PORespCNTL (0)				<= '0';

    if ERR_I = '1' then
      PORespCNTL(2 downto 1) 			<= "11";
    else
      PORespCNTL(2 downto 1) 			<= "00";
    end if;

    case state is
      when IDLE =>
	Enable 				   	<= '1';
        LOAD_ADDR              		   	<= '1';
        CYC_O                  		   	<= '0';
        STB_O                  		   	<= '0';
        DAT_O                  		   	<= (others => 'Z');
        WE_O                   		   	<= '0';
        CTI_O                  		   	<= (others => '0');
        PORespCNTL(7 downto 3) 		   	<= "00000";
        PORespCNTL(0)          		   	<= '0';
        PORespDATA             		   	<= (others => 'Z');
	
	case PIReqCNTL(2 downto 1) is
      		when "00"   =>
        		TOT_TRANSFER_I 		<= 1;
      		when "01"   =>
        		TOT_TRANSFER_I 		<= 3;
      		when "10"   =>
        		TOT_TRANSFER_I 		<= 7;
      		when "11"   =>
        		TOT_TRANSFER_I 		<= 15;
      		when others =>
        		TOT_TRANSFER_I 		<= 0;
    	end case;
  
     when SR =>
	CYC_O   	       		   	<= '1';
   	STB_O                  		   	<= '1';
   	CTI_O                  		   	<= (others => '0');               -- single transfer
   	WE_O    	       		   	<= '0';
	DAT_O                  		   	<= (others => 'Z');
	PORespDATA(MSB_PIF downto LSB_PIF) 	<= DAT_I(MSB_WB downto LSB_WB);
	PORespCNTL(7 downto 3) 		   	<= "00000";
	PORespCNTL(0)  	        		<= '1';
	
     when BR =>
	CYC_O   	       		   	<= '1';
   	STB_O                  	 	   	<= '1';
	WE_O    	       		  	<= '0';
	CTI_O                     	   	<= "010";
	DAT_O                         		<= (others => 'Z');
   	PORespDATA(MSB_PIF downto LSB_PIF) 	<= DAT_I(MSB_WB downto LSB_WB);
	PORespCNTL(7 downto 3)        		<= "00000";
        if (N_TRANSFER = TOT_TRANSFER_O) then 
        	PORespCNTL(0)           	<= '1';
		CTI_O                      	<= "111";
	else
		PORespCNTL(0)             	<= '0';
		CTI_O                      	<= "010";
	end if;

     when SW =>
	CYC_O                       	   	<= '1';
        STB_O                       	   	<= '1';        
        CTI_O                       	   	<= (others => '0');  		-- single transfer
	WE_O                        	   	<= '1';
	DAT_O(MSB_WB downto LSB_WB) 	   	<= PIReqDATA(MSB_PIF downto LSB_PIF);
	PORespDATA                         	<= (others => 'Z');
	PORespCNTL(7 downto 3)             	<= "00000";
	PORespCNTL(0)			   	<= '1';

     when BW =>
	CYC_O   	       		   	<= '1';
        STB_O                  	   	   	<= '1';
	WE_O           	        	   	<= '1';
	CTI_O                       	   	<= "010";
	DAT_O(MSB_WB downto LSB_WB)        	<= PIReqDATA(MSB_PIF downto LSB_PIF);
	PORespDATA                         	<= (others => 'Z');
	PORespCNTL(7 downto 3)             	<= "00000";
	if (N_TRANSFER = TOT_TRANSFER_O) then 
        	PORespCNTL(0)             	<= '1';
		CTI_O                           <= "111";
	else
		PORespCNTL(0)             	<= '0';
		CTI_O                           <= "010";
	end if;

     when R_ACK => 
	GO_UP     				<= '1';
        STB_O                              	<= '0';
	WE_O           	                   	<= '0';
	CTI_O                              	<= "010";
	DAT_O                              	<= (others => 'Z');
        PORespDATA(MSB_PIF downto LSB_PIF) 	<= DAT_I(MSB_WB downto LSB_WB);
	PORespCNTL(7 downto 3)             	<= "00000";
        PORespCNTL(0)             	   	<= '0';
	if (N_TRANSFER = TOT_TRANSFER_O) then 
        	PORespCNTL(0)             	<= '1';
		CTI_O                           <= "111";
		CYC_O   	                <= '0';
	else
		PORespCNTL(0)             	<= '0';
		CTI_O                           <= "010";
		CYC_O   	                <= '1';
	end if;

     when W_ACK => 
	GO_UP     			   	<= '1';
        STB_O                              	<= '0';
	CTI_O                  	    	   	<= "010";
	DAT_O(MSB_WB downto LSB_WB) 	   	<= PIReqDATA(MSB_PIF downto LSB_PIF);
	PORespDATA                         	<= (others => 'Z');
        PORespCNTL(7 downto 3)             	<= "00000";
	if (N_TRANSFER = TOT_TRANSFER_O) then 
        	PORespCNTL(0)             	<= '1';
		CTI_O                           <= "111";
		CYC_O   	                <= '0';
		WE_O           	           	<= '0';
	else
		PORespCNTL(0)             	<= '0';
		CTI_O                           <= "010";
		CYC_O   	                <= '1';
		WE_O           	           	<= '1';
	end if;

     end case;
  end process Output_Function;

end PIF2WB_3process;
