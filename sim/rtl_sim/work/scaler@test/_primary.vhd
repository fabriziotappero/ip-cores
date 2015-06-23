library verilog;
use verilog.vl_types.all;
entity scalerTest is
    generic(
        INPUT_X_RES     : integer := 119;
        INPUT_Y_RES     : integer := 89;
        OUTPUT_X_RES    : integer := 1279;
        OUTPUT_Y_RES    : integer := 959;
        DATA_WIDTH      : integer := 8;
        CHANNELS        : integer := 3;
        DISCARD_CNT_WIDTH: integer := 8;
        INPUT_X_RES_WIDTH: integer := 11;
        INPUT_Y_RES_WIDTH: integer := 11;
        OUTPUT_X_RES_WIDTH: integer := 11;
        OUTPUT_Y_RES_WIDTH: integer := 11;
        BUFFER_SIZE     : integer := 6
    );
    port(
        inputFilename   : in     vl_logic_vector(400 downto 0);
        outputFilename  : in     vl_logic_vector(400 downto 0);
        inputDiscardCnt : in     vl_logic_vector;
        leftOffset      : in     vl_logic_vector;
        topFracOffset   : in     vl_logic_vector(13 downto 0);
        nearestNeighbor : in     vl_logic;
        done            : out    vl_logic
    );
end scalerTest;
