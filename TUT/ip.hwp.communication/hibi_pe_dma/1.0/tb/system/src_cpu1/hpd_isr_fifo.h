/*
 *
 *   Fifo for saving interrupt information, header
 *
 *   Lasse Lehtonen
 *
 */

#ifndef HPD_ISR_FIFO_HH
#define HPD_ISR_FIFO_HH

// Tells what caused N2H2 to interrupt
typedef enum {RX_READY, RX_UNKNOWN, TX_IGNORED} Hpd_isr_type;


// Item stored in fifo
typedef struct Hpd_isr_info Hpd_isr_info;
typedef struct Hpd_isr_info
{  
  Hpd_isr_type isr_type;
  union {
    int  rx_channel;
    int  dst_address;
  };

  Hpd_isr_info* next;
};


typedef struct
{
  Hpd_isr_info*   root;
  volatile int    size;

} Hpd_isr_fifo;

//                             used fifo           item to store
void          hpd_isr_fifo_push(Hpd_isr_fifo* fifo, Hpd_isr_info* item);
Hpd_isr_info* hpd_isr_fifo_pop(Hpd_isr_fifo* fifo);
int           hpd_isr_fifo_size(Hpd_isr_fifo* fifo);
// Creates new fifo
Hpd_isr_fifo* hpd_isr_fifo_create();

#endif
