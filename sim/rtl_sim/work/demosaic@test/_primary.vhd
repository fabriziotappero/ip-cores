library verilog;
use verilog.vl_types.all;
entity demosaicTest is
    generic(
        X_RES           : integer := 639;
        Y_RES           : integer := 511;
        DATA_WIDTH      : integer := 8;
        X_RES_WIDTH     : integer := 11;
        Y_RES_WIDTH     : integer := 11;
        BUFFER_SIZE     : integer := 5;
        DIN_VALID_PERIOD: integer := 1000;
        DIN_VALID_ON    : integer := 1000;
        DOUT_VALID_PERIOD: integer := 1000;
        DOUT_VALID_ON   : integer := 1000
    );
    port(
        inputFilename   : in     vl_logic_vector(400 downto 0);
        outputFilename  : in     vl_logic_vector(400 downto 0);
        done            : out    vl_logic
    );
end demosaicTest;
