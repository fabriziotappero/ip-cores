library verilog;
use verilog.vl_types.all;
entity streamScaler is
    generic(
        DATA_WIDTH      : integer := 8;
        CHANNELS        : integer := 1;
        DISCARD_CNT_WIDTH: integer := 8;
        INPUT_X_RES_WIDTH: integer := 11;
        INPUT_Y_RES_WIDTH: integer := 11;
        OUTPUT_X_RES_WIDTH: integer := 11;
        OUTPUT_Y_RES_WIDTH: integer := 11;
        FRACTION_BITS   : integer := 8;
        SCALE_INT_BITS  : integer := 4;
        SCALE_FRAC_BITS : integer := 14;
        BUFFER_SIZE     : integer := 4
    );
    port(
        clk             : in     vl_logic;
        rst             : in     vl_logic;
        dIn             : in     vl_logic_vector;
        dInValid        : in     vl_logic;
        nextDin         : out    vl_logic;
        start           : in     vl_logic;
        dOut            : out    vl_logic_vector;
        dOutValid       : out    vl_logic;
        nextDout        : in     vl_logic;
        inputDiscardCnt : in     vl_logic_vector;
        inputXRes       : in     vl_logic_vector;
        inputYRes       : in     vl_logic_vector;
        outputXRes      : in     vl_logic_vector;
        outputYRes      : in     vl_logic_vector;
        xScale          : in     vl_logic_vector;
        yScale          : in     vl_logic_vector;
        leftOffset      : in     vl_logic_vector;
        topFracOffset   : in     vl_logic_vector;
        nearestNeighbor : in     vl_logic
    );
end streamScaler;
