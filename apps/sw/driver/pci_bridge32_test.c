#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <malloc.h>
#include <unistd.h>
#include <stdio.h>
#include <spartan_kint.h>
#include <sys/ioctl.h>
#include <pci_bridge32_test.h>
#include <string.h>
#include <stdlib.h>

#define WALKING_ONES     0
#define WALKING_ZEROS    1
#define INVERTED_ADDRESS 2
#define ALL_ZEROS        3
#define ALL_ONES         4
#define PSEUDO_RANDOM    5

#define MAX_PATTERN 5

unsigned int guint_random_seed = 1 ;

void prompt(void) ;
int  execute_command(char *command) ;
void cmd_help (int command_num) ;
int  cmd_select_region (char *command_str) ;
int  sp_set_region(unsigned char region) ;
int  sp_write (unsigned int value) ;
int  sp_read(unsigned int *value) ;
int  cmd_write (char *command_str) ;
int  cmd_read (char *command_str) ;
int  cmd_burst_read(char *command_str) ;
int  cmd_target_write(char *command_str) ;
int  cmd_master_do(char *command_str, unsigned int opcode) ;
#define cmd_master_write(command_str) cmd_master_do(command_str, 0x00000001)
#define cmd_master_read(command_str)  cmd_master_do(command_str, 0x00000000)
int  cmd_master_fill(char *command_str) ;
int  cmd_target_slide_window_test (void) ;
int  cmd_master_slide_window_test (void) ;
int  cmd_enable_wb_image (char *command_str) ;
void master_buffer_fill(unsigned char pattern) ;
int  cmd_master_chk(char *command_str) ;
int  cmd_target_chk(char *command_str) ;
int  sp_target_write(unsigned int num_of_transactions, unsigned int transaction_size, unsigned int starting_offset, unsigned char pattern) ;
int  sp_target_check_data(unsigned int num_of_transactions, unsigned int transaction_size, unsigned int starting_offset, unsigned char pattern) ;
int  sp_master_check_data(unsigned int size, unsigned int offset, unsigned char pattern) ;
int  sp_master_do(unsigned int num_of_transactions, unsigned int transaction_size, unsigned int starting_offset, unsigned int opcode) ;
#define sp_master_write(num_of_transactions, transaction_size, starting_offset) sp_master_do(num_of_transactions, transaction_size, starting_offset, 0x00000001)
#define sp_master_read(num_of_transactions, transaction_size, starting_offset) sp_master_do(num_of_transactions, transaction_size, starting_offset, 0x00000000)
int  sp_get_pci_region (void) ;
unsigned int sp_get_first_val(unsigned char pattern) ;
unsigned int sp_get_next_val(unsigned int cur_val, unsigned char pattern) ; 

int spartan_fd ;

char unused_str [MAX_COMMAND_LEN + 1] ;

int main(int argc, char* argv[])
{
    FILE* cmd_file_fd ;

    unsigned short use_cmd_file ;
    
    char current_command [MAX_COMMAND_LEN + 2] ;

    spartan_fd = open("/dev/spartan", O_RDWR) ;

    if (spartan_fd <= 0) {
        printf("\nSpartan device not found!\n") ;
        printf("\nThe /dev/spartan device must exist with appropriate module loaded!\n") ;
        return spartan_fd ;
    }
    
    printf("\nPCI Bridge Test Application\n") ;
    printf("\nType help for list of available commands\n\n");
    prompt() ;

    use_cmd_file = 0 ;
    
    if (argc > 1) {

        // command line argument is input file name - open the file
        cmd_file_fd = fopen(argv[1], "r") ;
        if (cmd_file_fd <= 0) {
            printf("\nCannot open file %s in read mode!\n", argv[1]) ;
        }
        else
            use_cmd_file = 1 ;
    }
    
    while (1) {
        
        if (use_cmd_file)
            if (fgets(current_command, MAX_COMMAND_LEN + 2, cmd_file_fd) == NULL)
                use_cmd_file = 0 ;
            else
                printf ("%s", current_command) ;
        else
            fgets(current_command, MAX_COMMAND_LEN + 2, stdin) ;
        
        if (execute_command(current_command)) {
            return 0 ;
        }
        prompt() ;
    }

    printf("\n") ;
    return 0 ;
}

void prompt (void) {
    printf("\npci> ") ;
}

int execute_command (char *command) {
    int i = 0 ;
    char command_wo_param [MAX_COMMAND_LEN + 1] ;
    int result ;

    if (!(strcmp("\n", command))) return 0 ;

    result = sscanf(command, "%s", command_wo_param) ;

    if (result == EOF) return 0 ;

    if (result != 1) return 0 ;
    
    while ((i < NUM_OF_COMMANDS) & (strcmp(GET_CMD(i), command_wo_param))) {
        ++i ;
    }
    
    switch (i) {
        case 0 : cmd_help(-1); break ;
        case 1 : return 1 ;
        case 2 : if (cmd_select_region    (command)) cmd_help( 2) ; break ;
        case 3 : if (cmd_write            (command)) cmd_help( 3) ; break ;
        case 4 : if (cmd_read             (command)) cmd_help( 4) ; break ;
        case 5 : if (cmd_target_write     (command)) cmd_help( 5) ; break ;
        case 6 : if (cmd_burst_read       (command)) cmd_help( 6) ; break ;
        case 7 : if (cmd_master_read      (command)) cmd_help( 7) ; break ;
        case 8 : if (cmd_master_fill      (command)) cmd_help( 8) ; break ;
        case 9 : if (cmd_master_write     (command)) cmd_help( 9) ; break ;
        case 10: if (cmd_master_chk       (command)) cmd_help(10) ; break ;
        case 11: if (cmd_target_chk       (command)) cmd_help(11) ; break ;
        case 12: if (cmd_target_slide_window_test()) cmd_help(12) ; break ;
        case 13: if (cmd_enable_wb_image  (command)) cmd_help(13) ; break ;
        case 14: if (cmd_master_slide_window_test()) cmd_help(14) ; break ;
        default: printf("\n\nError: Unknown command!\n\n") ;
    }
    
    return 0 ;    
}

void cmd_help (int command_num) {
    int i, start, end ;
    
    if (command_num >= 0) start = end = command_num ;
    else { start = 0 ; end = NUM_OF_COMMANDS - 1; }

    for (i = start ; i <= end ; ++i) {
        printf("%s %s\n: %s\n\n", GET_CMD(i), GET_CMD_PARMS(i), GET_CMD_DES(i)) ;
    }
}

int cmd_select_region (char *command_str) {
    int result ;
    unsigned char sel_region ;
    unsigned int  base ;
    unsigned int  base_size ;
    
    result = sscanf(command_str, "%s %u", unused_str, &sel_region) ;

    if (result != 2) {
        printf("\nError: Wrong command, parameter or number of parameters!\n") ;
        return -1 ;
    }

    result = sp_set_region (sel_region) ;

    if (result) return 0 ;

    result = ioctl(spartan_fd, SPARTAN_IOC_CURBASE, &base) ;
    printf("\nNote: Selected region's base address 0x%x\n", base) ;

    result = ioctl(spartan_fd, SPARTAN_IOC_CURBASESIZE, &base_size) ; 
    printf("\nNote: Selected region's size %d\n", base_size) ;

    return 0 ;
}

int cmd_enable_wb_image (char *command_str) {

    // store current selected pci image number
    int current_pci_region = sp_get_pci_region() ;
    unsigned int region ;
    unsigned int i ;
    unsigned int base ;
    

    // check the parameter passed with the command
    if (sscanf(command_str, "%s %d", unused_str, &region) != 2) {
        printf("\nError: Invalid command, parameter or number of parameters!\n") ;
        return -1;
    }

    if ((region > 5) | (!region)) {
        printf("\nError: Invalid WB image selected!\n") ;
        return -1 ;
    }
    
    // activate region 0 - configuration space
    if (sp_set_region(0)) {
        printf("\nError: Failed to activate pci region 0 - configuration image!\n") ;
        return 0 ;
    }

    // first disable all wb images!
    for ( i = 0x18C ; i <= 0x1CC ; i = i + 0x10 ) {
        if (sp_seek(i)) {
            printf("\nError: Failed to write one of the WB address mask registers!\n") ;
            if (current_pci_region >= 0) sp_set_region(current_pci_region) ;
            return 0 ;
        }

        if (sp_write(0x00000000)) {
            printf("\nError: Failed to write one of the WB address mask registers!.\n") ;
            if (current_pci_region >= 0) sp_set_region(current_pci_region) ;
            return 0 ;
        }
    }
    
    // get base address of the system memory buffer
    ioctl(spartan_fd, SPARTAN_IOC_VIDEO_BASE, &base) ;
    
    i = 0x178 + 0x10 * region ;

    if (sp_seek(i)) {
        printf("\nError: Failed to write selected WB base address register!\n") ;
        if (current_pci_region >= 0) sp_set_region(current_pci_region) ;
        return 0 ;
    }

    if (sp_write(base)) {
        printf("\nError: Failed to write WB base address register!.\n") ;
        if (current_pci_region >= 0) sp_set_region(current_pci_region) ;
        return 0 ;
    }

    // write address mask register with all ones.
    i = 0x17C + 0x10 * region ;

    if (sp_seek(i)) {
        printf("\nError: Failed to write selected WB address mask register!\n") ;
        if (current_pci_region >= 0) sp_set_region(current_pci_region) ;
        return 0 ;
    }

    if (sp_write(0xFFFFFFFF)) {
        printf("\nError: Failed to write selected WB address mask register!.\n") ;
        if (current_pci_region >= 0) sp_set_region(current_pci_region) ;
        return 0 ;
    }
        
    if (current_pci_region >= 0) sp_set_region(current_pci_region) ;
    
    return 0 ;
}

int sp_set_region(unsigned char region) {
    int result = ioctl(spartan_fd, SPARTAN_IOC_NUMOFRES) ;

    if (result <= 0) {
        printf("\nError: Error accessing device!\n") ;
        return -1 ;
    }

    if (region > 5 ) {
        printf("\nError: Invalid region!\n") ;
        return -1 ;
    }

    if (result <= region) {
        printf("\nError: You selected region %u\n", region) ;
        printf("Driver reports only %u [0:%u] regions available!\n", result, result - 1) ;
        return -1 ;
    }

    result = ioctl(spartan_fd, SPARTAN_IOC_CURRESSET, region + 1) ;

    if (result) {
        printf("\nError: Driver reported failure to intialize resource %u!\n", region) ;
        return -1;
    }

    return 0 ;
}

int sp_get_pci_region (void) {
    return (ioctl(spartan_fd, SPARTAN_IOC_CURRESGET) - 1) ;
}

int cmd_write (char *command_str) {
    int result ;
    unsigned int value ;
    unsigned int offset ;
    
    result = sscanf(command_str, "%s %x %x", unused_str, &offset, &value) ;
    if (result != 3) {
        printf("\nError: Invalid command, parameter or number of parameters!\n") ;
        return -1;
    }

    if (sp_seek(offset)) {
        printf("\nError: Write failed. Couldn't write to offset 0x%x!\n", offset) ;
        return 0 ;
    }

    if (sp_write(value)) {
        printf("\nError: Write failed.\n") ;
        return 0 ;
    }

    if (sp_seek(offset)) {
        printf("\nError: Read-back failed. Couldn't read from offset 0x%x!\n", offset) ;
        return 0 ;
    }
    
    if (sp_read(&offset)) {
        printf("\nError: Read-back failed.\n") ;
        return 0;
    }

    printf("\n0x%08x\n", offset) ;

    return 0 ;
}

int cmd_read (char *command_str) {
    int result ;
    unsigned int value ;
    unsigned int offset ;

    result = sscanf(command_str, "%s %x", unused_str, &offset) ;
    if (result != 2) {
        printf("\nError: Invalid command, parameter or number of parameters!\n") ;
        return -1 ;
    }

    if (sp_seek(offset)) {
        printf("\nError: Read failed. Couldn't read from offset 0x%x!\n", offset) ;
        return 0 ;
    }

    if (sp_read(&value)) {
        printf("\nError: Read failed.\n") ;
        return 0 ;
    }

    printf("\n0x%08x\n", value) ;

    return 0 ;
}

int sp_write (unsigned int value) {
    int result = write(spartan_fd, &value, 4) ;
    if (result != 4)
        return -1 ;
    else
        return 0 ;
}

int sp_seek (unsigned int offset) {
    int result = lseek(spartan_fd, offset, SEEK_SET) ;
    if (result != offset)
        return -1 ;
    else
        return 0 ;
}

int sp_read (unsigned int *value) {

    int result = read(spartan_fd, (char *) value, 4) ;

    if (result != 4)
        return -1 ;
    else
        return 0 ;
}

int sp_target_write(unsigned int num_of_transactions, unsigned int transaction_size, unsigned int starting_offset, unsigned char pattern) {
    unsigned int buffer[SPARTAN_BOARD_BUFFER_SIZE] ;

    int i ;

    buffer[0] = sp_get_first_val(pattern) ;

    for (i = 1; i < SPARTAN_BOARD_BUFFER_SIZE ; i++) {
        buffer[i] = sp_get_next_val(buffer[i-1], pattern) ;
    }

    if (sp_seek(starting_offset*4)) {
        printf("\nError: Seek failed!\n") ;
        return -1 ;
    }    

    for (i = 0 ; i < num_of_transactions ; ++i) {
        if ((write(spartan_fd, buffer + (i*transaction_size) + starting_offset, transaction_size*4)) != (transaction_size*4)) {
            printf("\nError: Write test failed. Transaction number %d couldn't finish %d writes through target!\n", i, transaction_size) ;
            return -1 ;
        } 
    }

    return 0 ;
}

int sp_target_check_data(unsigned int num_of_transactions, unsigned int transaction_size, unsigned int starting_offset, unsigned char pattern) {
    unsigned int buffer[SPARTAN_BOARD_BUFFER_SIZE] ;
    unsigned int expected_value ;

    int i ;
    int j ;

    expected_value = sp_get_first_val(pattern) ;

    for (i = 1 ; i <= starting_offset ; ++i) {
        expected_value = sp_get_next_val(expected_value, pattern) ;
    }
    
    if (sp_seek(starting_offset * 4)) {
        printf("\nError: Seek failed!\n") ;
        return -1 ;
    }

    for (i = 0 ; i < num_of_transactions ; ++i) {
        
        if ((read(spartan_fd, buffer, transaction_size*4)) != (transaction_size*4)) {
            printf("\nError: Check data failed. Transaction number %d couldn't finish %d reads through target!\n", i, transaction_size) ;
            return -1 ;
        }

        for (j = 0 ; j < transaction_size ; ++j) {
            if ((*(buffer + j)) != (expected_value)) {
                printf("\nError: Value on offset 0x%x not as expected!\n", ((i*transaction_size*4) + (j * 4) + starting_offset * 4)) ;
                printf("\nExpected value: 0x%x\nActual value: 0x%x\n", expected_value, (*(buffer + j))) ;
                return 0 ;
            }
            
            expected_value = sp_get_next_val(expected_value, pattern) ;
        }
    }
    return 0 ;
}

unsigned int sp_get_first_val(unsigned char pattern) {
    unsigned int base ;

    switch (pattern) {
    case WALKING_ONES    : return 0x00000001 ; break ;
    case WALKING_ZEROS   : return 0xFFFFFFFE ; break ;
    case INVERTED_ADDRESS: ioctl(spartan_fd, SPARTAN_IOC_CURBASE, &base) ; return ~base ; break ; 
    case ALL_ZEROS       : return 0x00000000 ; break ;
    case ALL_ONES        : return 0xFFFFFFFF ; break ;
    case PSEUDO_RANDOM   : srand(guint_random_seed) ; return rand() ; break ;
    }
}

unsigned int sp_get_next_val(unsigned int cur_val, unsigned char pattern) {
    unsigned int new_val ;
    switch (pattern) {
    case WALKING_ONES    : new_val = cur_val << 1 ; if (new_val == 0) return (sp_get_first_val(pattern)); else return new_val; break ;
    case WALKING_ZEROS   : new_val = ~cur_val ; new_val = new_val << 1 ; if (new_val == 0) return (sp_get_first_val(pattern)); else return ~new_val ; break ;
    case INVERTED_ADDRESS: return ~((~cur_val) + 4) ; break ;
    case ALL_ZEROS       : return 0x00000000 ; break ;
    case ALL_ONES        : return 0xFFFFFFFF ; break ;
    case PSEUDO_RANDOM   : return rand() ; break ;
    }
}

int cmd_burst_read (char *command_str) {
    int result ;
    unsigned int base ;
    unsigned int buf [32] ;
    unsigned int offset ;

    result = sscanf(command_str, "%s %x", unused_str, &offset) ;

    if (result != 2) {
        printf("\nError: Wrong command, parameter or invalid number of parameters!\n") ;
        return -1 ;
    }

    if (sp_seek(offset)) {
        printf("\nError: Read failed. Couldn't read from offset 0x%x!\n", offset) ;
        return 0 ;
    }

    if ((read(spartan_fd, buf, 32*4)) != (32*4)) {
        printf("\nError: Read failed. Couldn't finish %d reads through target!\n", 32) ;
        return 0 ;
    }

    ioctl(spartan_fd, SPARTAN_IOC_CURBASE, &base) ;

    for (result = 0 ; result < 32 ; result = result + 4) {
        printf("\n0x%08x: ", base + offset + result * 4) ;
        printf("0x%08x 0x%08x 0x%08x 0x%08x", *(buf + result), *(buf + result + 1), *(buf + result + 2), *(buf + result + 3)) ;
    }

    printf("\n") ;
    return 0 ;
}

int cmd_master_do (char *command_str, unsigned int opcode) {    
    unsigned int offset ;
    unsigned int num_of_trans ;
    unsigned int trans_size ;

    if (sscanf(command_str, "%s %x %u %u", unused_str, &offset, &num_of_trans, &trans_size) != 4) {
        printf("\nError: Wrong command, parameter or number of parameters!\n") ;
        return -1 ;
    }

    if (((num_of_trans * trans_size) + (offset/4)) > SYS_BUFFER_SIZE) {
        printf("\nError: Size of data from specifed offset crosses system buffer boundary!\n") ;
        return 0 ;
    }

    sp_master_do(num_of_trans, trans_size, offset, opcode) ;

    return 0 ;
}

void master_buffer_fill(unsigned char pattern) {
    int i ;
    unsigned int buf[SYS_BUFFER_SIZE] ;
    
    buf[0] = sp_get_first_val(pattern) ;
    for (i = 1 ; i < SYS_BUFFER_SIZE ; ++i) {
        buf[i] = sp_get_next_val(buf[i-1], pattern) ;
    }

    ioctl(spartan_fd, SPARTAN_IOC_SET_VIDEO_BUFF, buf) ;
}

int cmd_master_fill (char *command_str) {
    unsigned int pattern ;

    if ((sscanf(command_str, "%s %u", unused_str, &pattern)) != 2) {
        printf("\nError: Invalid command, parameter or number of parameters!\n") ;
        return -1;
    }

    if (pattern > MAX_PATTERN) {
        printf("\nError: Invalid pattern selected!\n") ;
        return 0 ;
    }

    master_buffer_fill(pattern) ;

    return 0 ;
}

int cmd_master_chk(char *command_str) {
    unsigned int pattern ;
    unsigned int cur_val ;
    unsigned int offset ;
    unsigned int size ;
    unsigned int buf[SYS_BUFFER_SIZE] ;
    int i ;

    if ((sscanf(command_str, "%s %x %u %u", unused_str, &offset, &size, &pattern)) != 4) {
        printf("\nError: Wrong command, parameter or number of parameters!\n") ;
        return -1 ;
    }

    if (pattern > MAX_PATTERN) {
        printf("\nError: Invalid pattern selected!\n") ;
        return 0 ;
    }

    if ((offset/4 + size) > SYS_BUFFER_SIZE) {
        printf("\nError: <size> words of data from specified offset cross system buffer boundary!\n") ;
        return 0 ;
    }

    sp_master_check_data(size, offset, pattern) ;
    
    return 0 ;
}

int sp_master_check_data(unsigned int size, unsigned int offset, unsigned char pattern) {
    unsigned int cur_val = 0xDEADDEAD ;
    unsigned int buf[SYS_BUFFER_SIZE] ;
    int i ;
    int error_detected = 0 ;

    ioctl(spartan_fd, SPARTAN_IOC_GET_VIDEO_BUFF, buf) ;

    i = 0 ;

    for (i = 0 ; i < offset/4 ; ++i) {
        if (i % SPARTAN_BOARD_BUFFER_SIZE)
           cur_val = sp_get_next_val(cur_val, pattern) ;
        else
           cur_val = sp_get_first_val(pattern) ;
    }

    for(; i < (offset/4 + size); ++i) {
        if (i % SPARTAN_BOARD_BUFFER_SIZE)
            cur_val = sp_get_next_val(cur_val, pattern) ;
        else
            cur_val = sp_get_first_val(pattern) ;

        if (cur_val != buf[i]) {
            error_detected = 1 ;
            printf("\nError: Data on offset 0x%x wrong!\n", i*4) ;
            printf("Expected data 0x%08x, actual 0x%08x!\n", cur_val, buf[i]) ;
        }
    }
    
    return error_detected ;                
}

int cmd_target_write(char *command_str) {
    int result ;
    unsigned int num_of_trans ;
    unsigned int trans_size ;
    unsigned int pattern ;
    unsigned int starting_offset ;

    result = sscanf(command_str, "%s %x %u %u %u", unused_str, &starting_offset, &num_of_trans, &trans_size, &pattern ) ;

    if (result != 5) {
        printf("\nError: Wrong command, parameter or number of parameters!\n") ;
        return -1 ;
    }
    
    if ((trans_size * num_of_trans) > SPARTAN_BOARD_BUFFER_SIZE) {
        printf("\nError: Size of write transfers exceeds the buffer size!\n") ;
        return 0 ;
    }

    if (((starting_offset/4) + (trans_size * num_of_trans)) > SPARTAN_BOARD_BUFFER_SIZE) {
        printf("\nError: Specified number of writes from specified offset will exceede Target buffer size!\n") ;
        return 0 ;
    }

    if (pattern > MAX_PATTERN) {
        printf("\nError: Invalid pattern selected!\n") ;
        return 0 ;
    }
            
    sp_target_write(num_of_trans, trans_size, starting_offset / 4, pattern) ;

    return 0 ;
}

int cmd_target_chk (char *command_str) { 
    unsigned int num_of_trans ;
    unsigned int trans_size ;
    unsigned int pattern ;
    unsigned int starting_offset ;

    if (sscanf(command_str, "%s %x %u %u %u", unused_str, &starting_offset, &num_of_trans, &trans_size, &pattern) != 5) {
        printf("\nError: Wrong command, parameter or number of parameters.\n") ;
        return -1 ;
    }
    
    if ((trans_size * num_of_trans) > SPARTAN_BOARD_BUFFER_SIZE) {
        printf("\nError: Size of write transfers exceeds the buffer size!\n") ;
        return 0 ;
    }

    if (((starting_offset/4) + (trans_size * num_of_trans)) > SPARTAN_BOARD_BUFFER_SIZE) {
        printf("\nError: Specified number of writes from specified offset will cross Target buffer boundary!\n") ;
        return 0 ;
    }

    if (pattern > MAX_PATTERN) {
        printf("\nError: Invalid pattern selected!\n") ;
        return 0 ;
    }

    sp_target_check_data(num_of_trans, trans_size, starting_offset / 4, pattern) ;

    return 0 ;
} 

int  cmd_target_slide_window_test (void) {
    unsigned int i, j ;
    unsigned int base ;

    
/*    for ( i = 1 ; i <= SPARTAN_BOARD_BUFFER_SIZE ; ++i ) {
        for ( j = 0 ; j + i <= SPARTAN_BOARD_BUFFER_SIZE ; ++j) {

            guint_random_seed = guint_random_seed + 1 ;

            // clear on board buffer
            sp_target_write(1, SPARTAN_BOARD_BUFFER_SIZE, 0x0, ALL_ZEROS) ;

            sp_target_write(1, i, j, PSEUDO_RANDOM) ;

            // if j > 0 check the buffer before written data
            if (j) {
                sp_target_check_data(1, j, 0x0, ALL_ZEROS) ;
            }

            // if write didn't finish at the buffer boundary - check the data after written data
            if ((j + i) < SPARTAN_BOARD_BUFFER_SIZE) {
                sp_target_check_data(1, (SPARTAN_BOARD_BUFFER_SIZE - j - i), j + i, ALL_ZEROS) ;
            }

            // check the written data
            sp_target_check_data(1, i, j, PSEUDO_RANDOM) ;
        }
    }

    // clear the board buffer
    sp_target_write(1, SPARTAN_BOARD_BUFFER_SIZE, 0x0, ALL_ZEROS) ;    
    
    for ( i = 1 ; i <= SPARTAN_BOARD_BUFFER_SIZE ; ++i) {

        // reset random seed
        guint_random_seed = 1 ;
    
        for (j = 0 ; ((j + 1) * i) <= SPARTAN_BOARD_BUFFER_SIZE ; ++j) {
            sp_target_write(1, i, (j * i), PSEUDO_RANDOM) ;
            guint_random_seed = guint_random_seed + 1 ;
        }

        // check if there is any room left in the buffer
        if ((j * i) != SPARTAN_BOARD_BUFFER_SIZE) {
            // write the remainder of the data to the onboard buffer
            sp_target_write(1, SPARTAN_BOARD_BUFFER_SIZE - (j * i), (j * i), PSEUDO_RANDOM) ;
        }

        // now check the written data - read transactions the same as write transactions
        // reset random seed
        guint_random_seed = 1 ;

        for (j = 0 ; ((j + 1) * i) <= SPARTAN_BOARD_BUFFER_SIZE ; ++j) {
            sp_target_check_data(1, i, (j * i), PSEUDO_RANDOM) ;
            guint_random_seed = guint_random_seed + 1 ;
        }

        // check the end of buffer
        if ((j * i) != SPARTAN_BOARD_BUFFER_SIZE) {
            // check the remainder of the data in the onboard buffer
            sp_target_check_data(1, SPARTAN_BOARD_BUFFER_SIZE - (j * i), (j * i), PSEUDO_RANDOM) ;
        }
    }
    
*/

/*    // fill system buffer
    master_buffer_fill(PSEUDO_RANDOM) ;

    // instruct the master to fill the onboard buffer with reads!
    sp_master_read(1, SPARTAN_BOARD_BUFFER_SIZE, 0x0) ;

    // check the data in on board buffer
    sp_target_check_data(1, SPARTAN_BOARD_BUFFER_SIZE, 0x0, PSEUDO_RANDOM) ; 
    
    // clear the master buffer
    master_buffer_fill(ALL_ZEROS) ;

    // perform one whole board buffer write through master, to setup all registers
    sp_master_write(1, SPARTAN_BOARD_BUFFER_SIZE, 0x0) ;

    // check the data in buffer
    sp_master_check_data(SPARTAN_BOARD_BUFFER_SIZE, 0x0, PSEUDO_RANDOM) ;

    // if system buffer is larget than board buffer, check the data in the remainder of the system buffer
    if (SPARTAN_BOARD_BUFFER_SIZE < SYS_BUFFER_SIZE)
        sp_master_check_data(SYS_BUFFER_SIZE - SPARTAN_BOARD_BUFFER_SIZE, SPARTAN_BOARD_BUFFER_SIZE * 4, ALL_ZEROS) ;

    ++guint_random_seed ;

    for (i = 1 ; i <= 10000000 ; ++i) {
        master_buffer_fill(ALL_ZEROS) ;
        
        sp_target_write(1, SPARTAN_BOARD_BUFFER_SIZE, 0x0, PSEUDO_RANDOM) ;

        // instruct master to write the data out
        sp_seek(MASTER_TRANS_COUNT_OFFSET) ;
        sp_write(0x1) ;

        ++guint_random_seed ;

        // do another write through target
        sp_target_write(1, SPARTAN_BOARD_BUFFER_SIZE, 0x0, PSEUDO_RANDOM) ;

        --guint_random_seed ;
        // check the previous data written by master
        sp_master_check_data(SPARTAN_BOARD_BUFFER_SIZE, 0x0, PSEUDO_RANDOM) ;
        
        // if system buffer is larget than board buffer, check the data in the remainder of the system buffer
        if (SPARTAN_BOARD_BUFFER_SIZE < SYS_BUFFER_SIZE)
            sp_master_check_data(SYS_BUFFER_SIZE - SPARTAN_BOARD_BUFFER_SIZE, SPARTAN_BOARD_BUFFER_SIZE * 4, ALL_ZEROS) ;
        
        ++guint_random_seed ;
    }
*/
  
    // setup the slave registers
    ioctl(spartan_fd, SPARTAN_IOC_CURBASE, &base) ;
    if (!base) {
        printf("Error: Couldn't get target image base address!") ;
        return 0 ;
    }
    
    if (sp_seek(TARGET_TEST_START_ADR_OFFSET)) {
        printf("Error: Seek failed!") ;
        return 0 ;
    }

    if (sp_write(base)) {
        printf("Error: Write to register failed!") ;
        return 0 ;
    }

    if (sp_seek(TARGET_TEST_START_DATA_OFFSET)) {
        printf("Error: Seek failed!") ;
        return 0 ;
    }

    if (sp_write(sp_get_first_val(WALKING_ZEROS))) {
        printf("Error: Write to register failed!") ;
        return 0 ;
    }
        

    for (i = 1 ; i <= 200000 ; ++i) {
        // setup the target test size register
        if (sp_seek(TARGET_TEST_SIZE_OFFSET)) {
            printf("Error: Seek failed!") ;
            return 0 ;
        }

        if (i > 1) {
            if (sp_write(SPARTAN_BOARD_BUFFER_SIZE)) {
                printf("Error: Write to register failed!") ;
                return 0 ;
            }
        } else {
            if (sp_write(SPARTAN_BOARD_BUFFER_SIZE + 1)) {
                printf("Error: Write to register failed!") ;
                return 0 ;
            }
        }

        if (sp_target_write(1, SPARTAN_BOARD_BUFFER_SIZE, 0x0, WALKING_ZEROS)) {
            printf("Error: Write through target failed!") ;
            return 0 ;
        }

        if (i < 2) {
            if (sp_target_write(1, 1, 0x8, WALKING_ONES)) {
                printf("Error: Write failed!") ;
                return 0 ;
            }
        }

        // previously the error was produced intentionally - now check if the error status is still set
        if (i == 2) {
            if (sp_seek(TARGET_TEST_ERR_REP_OFFSET)) {
                printf("Error: Seek failed!") ;
                return 0 ;
            }

            if (sp_read(&base)) {
                printf("Error: Read failed!") ;
                return 0 ;
            }

            if (base != 3) {
                printf("Error: Value in the error status register not as expected!") ;
                return 0 ;
            }

            if (sp_seek(TARGET_TEST_ERR_REP_OFFSET)) {
                printf("Error: Seek failed!") ;
                return 0 ;
            }
  
            if (sp_write(0xFFFFFFFF)) {
                printf("Error: Write failed!") ;
                return 0 ;
            }
        }
    }
    

    if (sp_seek(TARGET_TEST_ERR_REP_OFFSET)) {
        printf("Error: Seek failed!") ;
        return 0 ;
    }

    if (sp_read(&base)) {
        printf("Error: read failed!") ;
        return 0 ;
    }

    if (base) {
        printf("Error: Test application detected an error!") ;
        
        if (sp_seek(TARGET_TEST_ERR_REP_OFFSET)) {
            printf("Error: Seek failed!") ;
            return 0 ;
        }
        
        if (sp_write(0)) {
            printf("Error: Write to register failed!") ;
            return 0 ;
        }
        
        return 0 ;
    }
    return 0 ;
}

int cmd_master_slide_window_test (void) {
    unsigned int i, j ;

/*    for (i = 1 ; i <= SPARTAN_BOARD_BUFFER_SIZE ; ++i) {
        for (j = 0 ; j + i <= SYS_BUFFER_SIZE ; ++j ) {
            guint_random_seed = guint_random_seed + 1 ;

            // fill the system memory buffer with random data
            master_buffer_fill(PSEUDO_RANDOM) ;

            // clear the on board buffer
            sp_target_write(1, SPARTAN_BOARD_BUFFER_SIZE, 0x0, ALL_ZEROS) ;

            if (sp_master_read((j % 2) ? 1 : SPARTAN_BOARD_BUFFER_SIZE, (j % 2) ? SPARTAN_BOARD_BUFFER_SIZE : 1, 0x0))
                return 0 ;

            // all of the master reads are finished
            // clear the system buffer
            master_buffer_fill(ALL_ZEROS) ;

            if (sp_master_write(1, i, j * 4))
                return 0 ;

            // write is done - check the data
            sp_master_check_data(i, j * 4, PSEUDO_RANDOM) ;

            if (j) {
                sp_master_check_data(j, 0, ALL_ZEROS) ;
            }

            if ( j + i < SYS_BUFFER_SIZE) {
                sp_master_check_data(SYS_BUFFER_SIZE - i - j, (i + j) * 4, ALL_ZEROS) ;
            }
        }
    }
*/
    sp_target_write(1, SPARTAN_BOARD_BUFFER_SIZE, 0x0, WALKING_ONES) ;
    sp_target_check_data(1, SPARTAN_BOARD_BUFFER_SIZE, 0x0, WALKING_ONES) ;
    master_buffer_fill(ALL_ZEROS) ;
    sp_master_write(SYS_BUFFER_SIZE / SPARTAN_BOARD_BUFFER_SIZE, SPARTAN_BOARD_BUFFER_SIZE, 0x0) ;
    sp_master_check_data(SYS_BUFFER_SIZE, 0x0, WALKING_ONES) ;

    // clear the master transaction counters
    if (sp_seek(MASTER_NUM_OF_WB_OFFSET)) {
        printf("\nError: Seek error!\n") ;
        return 0 ;
    }

    if (sp_write(0xFFFFFFFF)) {
        printf("\nError: Write to register failed\n") ;
        return 0 ;
    }

    if (sp_seek(MASTER_NUM_OF_WB_OFFSET)) {
        printf("\nError: Seek error!\n") ;
        return 0 ;
    }

    if (sp_read(&i)) {
        printf("\nError: Read from register failed\n") ;
        return 0 ;
    }

    if (i != 0) {
        printf("\nError: Transaction counter clear operation not OK!\n") ;
        return 0 ;
    }

    if (sp_seek(MASTER_NUM_OF_PCI_OFFSET)) {
        printf("\nError: Seek error!\n") ;
        return 0 ;
    }

    if (sp_read(&j)) {
        printf("\nError: Read from register failed\n") ;
        return 0 ;
    }

    if (j != 0) {
        printf("\nError: Transaction counter clear operation not OK!\n") ;
        return 0 ;
    }

        

//    if (SPARTAN_BOARD_BUFFER_SIZE < SYS_BUFFER_SIZE)
//        sp_master_check_data(SYS_BUFFER_SIZE - SPARTAN_BOARD_BUFFER_SIZE, SPARTAN_BOARD_BUFFER_SIZE * 4, ALL_ZEROS) ;

    for (i = 1 ; i <= 1 ; i = ++i) {

        if (i == 1) {
            if (sp_seek(0)) {
                printf("\nError: Seek error!\n") ;
                return 0 ;
            }

            if (sp_write(sp_get_first_val(WALKING_ZEROS))) {
                printf("\nError: Write to register failed!\n") ;
                return 0 ;
            }
        }
        
        if (sp_seek(MASTER_TRANS_COUNT_OFFSET)) {
            printf("\nError: Seek error!\n") ;
            return 0 ;
        }
        
        if (sp_read(&j)) {
            printf("\nError: Read from master number of transactions failed!\n") ;
            return 0 ;
        }

        if (j == 0) {

            if (sp_seek(MASTER_TEST_DATA_ERROR_OFFSET)) {
                printf("\nError: Seek failed!\n") ;
                return 0 ;
            }

            if (sp_read(&j)) {
                printf("\nError: Read from register failed!\n") ;
                return 0 ;
            }

            if (i == 1) {
                printf("\nNote: The following error is produced intentionally, to test software/hardware functionality!\n") ;
            }
            
            if (j) {
                printf("\nError: Test application detected an error in the data sequence on the PCI Master side of the bridge!\n") ;
            }
            
            if (sp_seek(MASTER_TEST_START_DATA_OFFSET)) {
                printf("\nError: Seek failed!\n") ;
                return 0 ;
            }

            if (sp_write(sp_get_first_val(WALKING_ONES))) {
                printf("\nError: Write to register failed!\n") ;
                return 0 ;
            }

            if (sp_seek(MASTER_TEST_SIZE_OFFSET)) {
                printf("\nError: Seek failed!\n") ;
                return 0 ;
            }

            if (sp_write(SYS_BUFFER_SIZE)) {
                printf("\nError: Write to register failed!\n") ;
                return 0 ;
            }
            
            if (sp_seek(MASTER_TRANS_COUNT_OFFSET)) {
                printf("\nError: Seek error!\n") ;
                return 0 ;
            }

            if (sp_write(SYS_BUFFER_SIZE / SPARTAN_BOARD_BUFFER_SIZE)) {
                printf("\nError: Unable to write master number of transactions register!\n") ;
                return 0 ;
            }
        }
                    
        if (i == 1) {
            printf("\nNote: The following two errors are produced intentionally, to test software/hardware functionality!\n") ;

            if (sp_seek(0)) {
                printf("\nError: Seek error!\n") ;
                return 0 ;
            }

            if (sp_write(sp_get_first_val(WALKING_ONES))) {
                printf("\nError: Write to register failed!\n") ;
                return 0 ;
            }            
        }
        
        for (j = 1 ; j <= (SYS_BUFFER_SIZE / SPARTAN_BOARD_BUFFER_SIZE) * 2 ; ++j) {
            sp_master_check_data(SYS_BUFFER_SIZE, 0x0, WALKING_ONES) ;
            printf("juhu") ;
        }
        
//        if (SPARTAN_BOARD_BUFFER_SIZE < SYS_BUFFER_SIZE)
//            sp_master_check_data(SYS_BUFFER_SIZE - SPARTAN_BOARD_BUFFER_SIZE, SPARTAN_BOARD_BUFFER_SIZE * 4, ALL_ZEROS) ;

//        master_buffer_fill(ALL_ZEROS) ;
    }

    j = 0 ;

    // read and clear the master transaction counters
    if (sp_seek(MASTER_NUM_OF_WB_OFFSET)) {
        printf("\nError: Seek error!\n") ;
        return 0 ;
    }

    if (sp_read(&j)) {
        printf("\nError: Read from register failed!\n") ;
        return 0 ;
    }

    if (j != ((i-1)*SYS_BUFFER_SIZE)) {
        printf("\nError: Number of WISHBONE transactions unexpected!\n") ;
        printf("Expected %u, actual %u\n", (i-1)*SYS_BUFFER_SIZE, j) ;
    } else {
        printf("\nNote: %u WISHBONE Slave write transfers reported succesfull!\n", j) ;
    }

    if (sp_seek(MASTER_NUM_OF_PCI_OFFSET)) {
        printf("\nError: Seek error!\n") ;
        return 0 ;
    }

    j = 0 ;

    if (sp_read(&j)) {
        printf("\nError: Read from register failed\n") ;
        return 0 ;
    }

    if (j != ((i-1)*SYS_BUFFER_SIZE)) {
        printf("\nError: Number of PCI transactions unexpected!\n") ;
        printf("Expected %u, actual %u\n", (i-1)*SYS_BUFFER_SIZE, j) ;
    } else {
        printf("Note: %u PCI Master write transfers reported succesfull!\n") ;
    }
    
    // clear the counters
/*    if (sp_seek(MASTER_NUM_OF_WB_OFFSET)) {
        printf("\nError: Seek error!\n") ;
        return 0 ;
    }

    if (sp_write(0xFFFFFFFF)) {
        printf("\nError: Write to register failed!\n") ;
        return 0 ;
    }
*/    
    
    // perform a read and write tests with variable size and number of transactions.
    // i represents transaction size, j represents number of transactions
/*    for (i = 1 ; i <= SPARTAN_BOARD_BUFFER_SIZE ; ++i) {
        for (j = 1 ; j * i <= SPARTAN_BOARD_BUFFER_SIZE ; ++j) {

            guint_random_seed = guint_random_seed + 1 ;

            // clear the onboard buffer
            sp_target_write(1, SPARTAN_BOARD_BUFFER_SIZE, 0x0, (i % 2) ? ALL_ZEROS : ALL_ONES) ;

            master_buffer_fill(PSEUDO_RANDOM) ;

            if ( sp_master_read( j, i, ( SPARTAN_BOARD_BUFFER_SIZE - i * j ) * 4) ) return 0 ;

            // check the data in system buffer by writing it through pci master
            master_buffer_fill((i % 2) ? ALL_ONES : ALL_ZEROS) ;

            if ( sp_master_write( 1, SPARTAN_BOARD_BUFFER_SIZE, 0x0)) return 0 ;

            // check the data that was not read in on lower offsets
            if (i*j < SPARTAN_BOARD_BUFFER_SIZE) {
                // check the data in the begining of the buffer, which was not read
                if (sp_master_check_data(SPARTAN_BOARD_BUFFER_SIZE - i * j, 0x0, (i % 2) ? ALL_ZEROS : ALL_ONES)) {
                    printf("\nError during Master read test detected!\n") ;
                    printf("Read test properties: number of transactions %d, transaction sizes %d\n", j, i) ;
                    printf("Checking the data in onboard buffer\n") ;
                    sp_target_check_data(1, SPARTAN_BOARD_BUFFER_SIZE - i * j, 0x0, (i % 2) ? ALL_ZEROS : ALL_ONES) ;
                    printf("Check done!\n") ;
                }
            }

            // check the data that was read
            if (sp_master_check_data(i*j, ( SPARTAN_BOARD_BUFFER_SIZE - ( i * j ) ) * 4, PSEUDO_RANDOM)) {
                printf("\nError during Master read test detected!\n") ;
                printf("Read test properties: number of transactions %d, transaction sizes %d\n", j, i) ;
                printf("Checking the data in onboard buffer\n") ;
                sp_target_check_data(1, i*j, SPARTAN_BOARD_BUFFER_SIZE - i * j, PSEUDO_RANDOM ) ;
                printf("Check done!\n") ;
            }
            
        }
    }
*/
    return 0 ;
}

int sp_master_do(unsigned int num_of_transactions, unsigned int transaction_size, unsigned int starting_offset, unsigned int opcode) {
    unsigned int base ;
    unsigned int transactions_left ;
    unsigned int deadlock_cnt ;
    unsigned int wait ;

    ioctl(spartan_fd, SPARTAN_IOC_VIDEO_BASE, &base) ;

    if (sp_seek(MASTER_ADDR_REG_OFFSET)) {
        printf("\nError: Seek error!\n") ;
        return 1 ;
    }

    if (sp_write(base + starting_offset)) {
        printf("\nError: Unable to write master address register!\n") ;
        return 1;
    }

    if (sp_seek(MASTER_OP_CODE_OFFSET)) {
        printf("\nError: Seek error!\n") ;
        return 1 ;
    }

    if (sp_write(opcode)) {
        printf("\nError: Unable to write master opcode register!\n") ;
        return 1 ;
    }

    if (sp_seek(MASTER_TRANS_SIZE_OFFSET)) {
        printf("\nError: Seek error!\n") ;
        return 1 ;
    }

    if (sp_write(transaction_size)) {
        printf("\nError: Unable to write master transaction size register!\n") ;
        return 1 ;
    }

    if (sp_seek(MASTER_TRANS_COUNT_OFFSET)) {
        printf("\nError: Seek error!\n") ;
        return 1 ;
    }

    if (sp_write(num_of_transactions)) {
        printf("\nError: Unable to write master number of transactions register!\n") ;
        return 1 ;
    }

    transactions_left = num_of_transactions ;
    deadlock_cnt      = 0 ;
    while (transactions_left && (deadlock_cnt < 100)) {

        // suspend the polling of remaining transactions, until minimum required time has passed, or for small writes for 1 us.
        for (wait = 0 ; wait < (transactions_left * transaction_size * 100) ; ++wait) ;
        
        if (sp_seek(MASTER_TRANS_COUNT_OFFSET)) {
            printf("\nError: Seek error!\n") ;
            return 1 ;
        }

        if (sp_read(&transactions_left)) {
            printf("\nError: Read failed!\n") ;
            return 1 ;
        }

        ++deadlock_cnt ;
    }

    if (deadlock_cnt == 0x00200000)  {
        printf("\nError: The requested master operation is not beeing processed. Is at least one wb image enabled?\n") ;
        return 1 ;
    }
    return 0 ;
}
