library verilog;
use verilog.vl_types.all;
entity ramFifo is
    generic(
        DATA_WIDTH      : integer := 8;
        ADDRESS_WIDTH   : integer := 8;
        BUFFER_SIZE     : integer := 2
    );
    port(
        clk             : in     vl_logic;
        rst             : in     vl_logic;
        advanceRead1    : in     vl_logic;
        advanceRead2    : in     vl_logic;
        advanceWrite    : in     vl_logic;
        forceRead       : in     vl_logic;
        writeData       : in     vl_logic_vector;
        writeAddress    : in     vl_logic_vector;
        writeEnable     : in     vl_logic;
        fillCount       : out    vl_logic_vector;
        readData00      : out    vl_logic_vector;
        readData01      : out    vl_logic_vector;
        readData10      : out    vl_logic_vector;
        readData11      : out    vl_logic_vector;
        readAddress     : in     vl_logic_vector
    );
end ramFifo;
