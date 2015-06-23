library verilog;
use verilog.vl_types.all;
entity ramFifo is
    generic(
        DATA_WIDTH      : integer := 8;
        ADDRESS_WIDTH   : integer := 8;
        BUFFER_SIZE     : integer := 3
    );
    port(
        clk             : in     vl_logic;
        rst             : in     vl_logic;
        advanceRead     : in     vl_logic;
        advanceWrite    : in     vl_logic;
        writeData       : in     vl_logic_vector;
        writeAddress    : in     vl_logic_vector;
        writeEnable     : in     vl_logic;
        fillCount       : out    vl_logic_vector;
        readData0       : out    vl_logic_vector;
        readData1       : out    vl_logic_vector;
        readData2       : out    vl_logic_vector;
        readAddress     : in     vl_logic_vector
    );
end ramFifo;
