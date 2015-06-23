#include "hpi_defs.h"
#include "hpi_functions.h"


//#define outw(a,b)	WRITE_REGISTER_USHORT( (unsigned short *)b, ((unsigned short)a) )
//#define inw(b)		READ_REGISTER_USHORT( (unsigned short *)b)

inline void kill_time(int num) {
  int i;

  for(i=0; i<num; i++) {
    asm("nop");
  }
}


USHORT
inw( PUSHORT b )
{
    return (*(volatile PUSHORT const)b);
}

VOID
outw(USHORT  a, PUSHORT b)
{
    *(volatile PUSHORT const)b = a;
}



/*
 *  FUNCTION: lcd_hpi_write_word
 *
 *  PARAMETERS:
 *    chip_addr       - Offset Address of the ASIC
 *    value           - Value to write
 *    cy_private_data - Private data structure pointer
 *
 *  DESCRIPTION:
 *    This function writes to hpi
 *
 *  RETURNS: 
 *    LCD_SUCCESS         - Success
 *    LCD_ERROR           - Failure
 */
void lcd_hpi_write_word(unsigned short chip_addr,
                        unsigned short value)
{
  outw (chip_addr, (USHORT*)(HPI_ADDR_ADDR + HPI_BASE));

  //  kill_time(5000);

  //  printf("\nwrite_word: writing %x to %x\n", chip_addr, (USHORT*)(HPI_ADDR_ADDR + HPI_BASE));
  outw (value, (USHORT*)(HPI_DATA_ADDR + HPI_BASE));
  //  printf("write_word: writing %x to %x\n", value, (USHORT*)(HPI_DATA_ADDR + HPI_BASE));
}

unsigned short lcd_hpi_read_status() {
  USHORT value;

  value = inw((USHORT*)(HPI_STAT_ADDR + HPI_BASE));
  return(value);
}


void lcd_hpi_write_mailbox(unsigned short value) {
  outw (value, (USHORT*)(HPI_MBX_ADDR + HPI_BASE));
}


unsigned short lcd_hpi_read_mailbox() {
    unsigned short value;

    value = inw((USHORT*)(HPI_MBX_ADDR + HPI_BASE));
    return(value);
}



/*
 *  FUNCTION: lcd_hpi_read_word
 *
 *  PARAMETERS:
 *    chip_addr       - Offset Address of the ASIC
 *    cy_private_data - Private data structure pointer
 *
 *  DESCRIPTION:
 *    This function reads from hpi
 *
 *  RETURNS: 
 *    LCD_SUCCESS         - Success
 *    LCD_ERROR           - Failure
 */
unsigned short lcd_hpi_read_word(unsigned short chip_addr)
{
    unsigned short value;


    outw (chip_addr, (USHORT*)(HPI_ADDR_ADDR + HPI_BASE));

    //    kill_time(5000);
    //    printf("\nread_word: writing %x to %x\n", chip_addr, (USHORT*)(HPI_ADDR_ADDR + HPI_BASE));
    value = inw((USHORT*)(HPI_DATA_ADDR + HPI_BASE));
    //    printf("read_word: reading %x from %x\n", value, (USHORT*)(HPI_DATA_ADDR + HPI_BASE));

    return(value);
}

void lcd_hpi_write_words(unsigned short chip_addr,
                         unsigned short *data,
                         int num_words)
{
    int i;

    outw (chip_addr, (PUSHORT)(HPI_ADDR_ADDR + HPI_BASE));

    for (i=0; i<num_words; i++) {
        outw (*data++, (PUSHORT)(HPI_DATA_ADDR + HPI_BASE));
    }
}

/*
 *  FUNCTION: lcd_hpi_read_words
 *
 *  PARAMETERS:
 *    chip_addr       - Offset Address of the ASIC
 *    data            - data pointer
 *    num_words       - Length
 *    cy_private_data - Private data structure pointer
 *
 *  DESCRIPTION:
 *    This function reads words from hpi
 *
 *  RETURNS: 
 *    LCD_SUCCESS         - Success
 *    LCD_ERROR           - Failure
 */
void lcd_hpi_read_words(unsigned short chip_addr,
                        unsigned short *data,
                        int num_words)
{
    int i;

    outw (chip_addr, (PUSHORT)(HPI_ADDR_ADDR + HPI_BASE));
    for (i=0; i<num_words; i++) {
        *data++ = inw ((PUSHORT)(HPI_DATA_ADDR + HPI_BASE));
    }
}

