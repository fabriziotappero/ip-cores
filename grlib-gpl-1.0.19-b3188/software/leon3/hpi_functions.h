#ifndef HPI_FUNCTIONS_H
#define HPI_FUNCTIONS_H


// do nothing for num loops
inline void kill_time(int num);

// low level read word via HPI
USHORT inw( PUSHORT b );

// low level write word via HPI
VOID outw(USHORT  a, PUSHORT b);


// write a data word to a CY-internal address
void lcd_hpi_write_word(unsigned short chip_addr,
                        unsigned short value);


// read a data word from a CY-internal address
unsigned short lcd_hpi_read_word(unsigned short chip_addr);


// write a given number of words contained in the buffer data
// starting from chip_addr (CY-internal addresses)
void lcd_hpi_write_words(unsigned short chip_addr,
                         unsigned short *data,
                         int num_words);


// read a given number of words starting from chip_addr
// (CY-internal addresses) into a data buffer
void lcd_hpi_read_words(unsigned short chip_addr,
                        unsigned short *data,
                        int num_words);


// write value to HPI mailbox register
void lcd_hpi_write_mailbox(unsigned short value);


// read value from HPI mailbox register
unsigned short lcd_hpi_read_mailbox();


// read value from HPI status register
unsigned short lcd_hpi_read_status();


#endif
