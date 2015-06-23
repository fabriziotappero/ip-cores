/*
 *
 *   Fifo for saving interrupt information, header
 *
 *   Lasse Lehtonen
 *
 */

#ifndef N2H_ISR_FIFO_HH
#define N2H_ISR_FIFO_HH

// Tells what caused N2H2 to interrupt
typedef enum {RX_READY, RX_UNKNOWN, TX_IGNORED} N2H_isr_type;


// Item stored in fifo
typedef struct N2H_isr_info N2H_isr_info;
typedef struct N2H_isr_info
{  
  N2H_isr_type isr_type;
  union {
    int  rx_channel;
    int  dst_address;
  };

  N2H_isr_info* next;
};


typedef struct
{
  N2H_isr_info*   root;
  volatile int    size;

} N2H_isr_fifo;

//                             used fifo           item to store
void          n2h_isr_fifo_push(N2H_isr_fifo* fifo, N2H_isr_info* item);
N2H_isr_info* n2h_isr_fifo_pop(N2H_isr_fifo* fifo);
int           n2h_isr_fifo_size(N2H_isr_fifo* fifo);
// Creates new fifo
N2H_isr_fifo* n2h_isr_fifo_create();

#endif
