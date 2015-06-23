component ezusb_io 
    generic (
        OUTEP : INTEGER := 2;                           -- EP for FPGA -> EZ-USB transfers
        INEP  : INTEGER := 6;                           -- EP for EZ-USB -> FPGA transfers 
        CLKBUF_TYPE  : STRING := ""                  	-- selects the clock preparation method (buffering, filtering, ...)
            						-- "SPARTAN6" for Xilinx Spartan 6, 
	                            			-- all other values: no clock preparation
    );                                                  -- "SERIES7" for Xilinx Series 7,                                      
    port (                                                     
        ifclk     : out std_logic;                      -- buffered output of the interface clock
        reset     : in std_logic;                       -- asynchronous reset input
        reset_out : out std_logic;                      -- synchronous reset output

        -- FPGA pins that are connected directly to EZ-USB.
        ifclk_in   : in std_logic;                        	-- interface clock IFCLK
        fd         : inout std_logic_vector(15  downto 0);      -- 16 bit data bus
        SLWR       : out std_logic;                             -- SLWR (slave write) flag
        PKTEND     : out std_logic;                             -- PKTEND (packet end) flag
        SLRD       : out std_logic;                             -- SLRD (slave read) flag
        SLOE       : out std_logic;                             -- SLOE (slave output enable) flag
        FIFOADDR   : out std_logic_vector(1  downto 0);         -- FIFOADDR pins select the endpoint
        EMPTY_FLAG : in std_logic;                              -- EMPTY flag of the slave FIFO interface
        FULL_FLAG  : in std_logic;                              -- FULL flag of the slave FIFO interface

	-- Signals for FPGA -> EZ-USB transfer. The are controlled by user logic.
        DI        : in std_logic_vector(15  downto 0);          -- data written to EZ-USB
        DI_valid  : in std_logic;                               -- 1 indicates valid data; DI and DI_valid must be hold if DI_ready is 0
        DI_ready  : out std_logic;                              -- 1 if new data are accepted
        DI_enable : in std_logic;                               -- setting to 0 disables FPGA -> EZ-USB transfers
        pktend_timeout : in std_logic_vector(15  downto 0);     -- timeout in multiples of 65536 clocks before a short packet committed
                                                                -- setting to 0 disables this feature                                   
	-- signals for EZ-USB -> FPGA transfer                                                                                                                          		
        DO       : out std_logic_vector(15  downto 0);          -- data read from EZ-USB
        DO_valid : out std_logic;                               -- 1 indicates valid data
        DO_ready : in std_logic;                                -- setting to 1 enables writing new data to DO in next clock
                                                                -- DO and DO_valid are hold if DO_ready is 0
                                                                -- set to 0 to disable data reads
        -- debug output
        status : out std_logic_vector(3  downto 0)
    );
end component; 

