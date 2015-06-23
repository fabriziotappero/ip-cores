// definition of maximum test application command length
#define MAX_COMMAND_LEN 100
#define MAX_DESCRIPTION_LEN 1000
#define NUM_OF_COMMANDS 15

char GSA_COMMANDS [NUM_OF_COMMANDS][MAX_COMMAND_LEN] = {
    "help",
    "quit",
    "set_pci_region",
    "write",
    "read",
    "target_write",
    "dump",
    "master_read",
    "master_buf_fill",
    "master_write",
    "master_chk_write",
    "target_chk_write",
    "target_programmed_tests",
    "set_wb_region",
    "master_programmed_tests"
} ;

char GSA_COMMAND_DESCRIPTIONS [NUM_OF_COMMANDS][MAX_DESCRIPTION_LEN] = {
    "Displays basic command and parameter reference.",
    "Exits the program.",
    "Selects one of 6 bridge pci address regions <region> for subsequent accesses.",
    "Writes 32 bit word <value> to specified offset <offset> and performs read-back.",
    "Reads data from the specified offset <offset>.",
    "Initiates <number of transactions> write transactions with <transaction size> size. It starts from specified offset<offset>. <pattern> selects the pattern to write to on-board buffer.",
    "Reads 32 words from specified offset<offset>.",
    "Configures master to read data from the system memory buffer. Reads start at specified offset <offset>, using <number of transactions> read operations of size <transaction size>.",
    "Fills system buffer with the specified pattern <pattern>.",
    "Writes contents of device's RAM on specified offset to system memory. Writes start at specified offset <offset>, using <number of transactions> write operations of size <transaction size>.",
    "Checks <size> words of data in system memory from offset <offset> against a specified pattern <pattern>.",
    "Checks data in onboard buffer from offset <offset> against a specified pattern. Buffer is read with <number of transactions> transactions of size <transaction size>.",
    "Performs arround 2M read/write transactions through target. Writes write pseudo random data, reads check the data.",
    "Enables WISHBONE image <image[1:5]> for subsequent PCI Master accesses. The command doesn't check for implemented WB images!",
    "Executes the master test program code written in the function in the pci_bridge32_test.c file!"
} ;

char GSA_PARAMETERS [NUM_OF_COMMANDS][MAX_COMMAND_LEN] = {
    "",
    "",
    "<region[0:5]>",
    "<offset> <value>",
    "<offset>",
    "<starting offset> <number of transactions> <transaction size> <pattern>",
    "<offset>",
    "<offset> <number of transactions> <transaction size>",
    "<pattern>",
    "<offset> <number of transactions> <transaction size>",
    "<offset> <size> <pattern>",
    "<offset> <number of transactions> <transaction size> <pattern>",
    "",
    "<image[1:5]>",
    ""
} ;

#define GET_CMD(i) (GSA_COMMANDS[i])
#define GET_CMD_DES(i) (GSA_COMMAND_DESCRIPTIONS[i])
#define GET_CMD_PARMS(i) (GSA_PARAMETERS[i])

#define SYS_BUFFER_SIZE           (4096)
#define SPARTAN_BOARD_BUFFER_SIZE (1024)

#define TARGET_BUFFER_SIZE       (1024)

#define MASTER_TRANS_SIZE_OFFSET      (0x1000)
#define MASTER_TRANS_COUNT_OFFSET     (0x1004)
#define MASTER_OP_CODE_OFFSET         (0x1008)
#define MASTER_ADDR_REG_OFFSET        (0x100c)
#define TARGET_BURST_TRANS_CNT_OFFSET (0x1010)
#define TARGET_TEST_SIZE_OFFSET       (0x1014)
#define TARGET_TEST_START_ADR_OFFSET  (0x1018)
#define TARGET_TEST_START_DATA_OFFSET (0x101C)
#define TARGET_TEST_ERR_REP_OFFSET    (0x1020)
#define MASTER_NUM_OF_WB_OFFSET       (0x1024)
#define MASTER_NUM_OF_PCI_OFFSET      (0x1028)
#define MASTER_TEST_SIZE_OFFSET       (0x102C)
#define MASTER_TEST_START_DATA_OFFSET (0x1030)
#define MASTER_TEST_DATA_ERROR_OFFSET (0x1034)
