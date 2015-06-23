/*
 *
 *   Fifo for saving interrupt information, implementation
 *
 *   Lasse Lehtonen
 *
 */



#include "hpd_isr_fifo.h"

#include <sys/alt_irq.h>
#include <stdlib.h>


// Store item to last place, called only from ISR
void hpd_isr_fifo_push(Hpd_isr_fifo* fifo, Hpd_isr_info* item)
{  
  Hpd_isr_info* temp = fifo->root;

  item->next = NULL;

  while(temp != NULL && temp->next != NULL)
    {
      temp = temp->next;
    }
  
  if(fifo->size < 1)
    {
      fifo->root = item;
    }
  else
    {
      temp->next = item;
    }

  fifo->size++;
}

// Returns the first item, remember to free its memory!
Hpd_isr_info* hpd_isr_fifo_pop (Hpd_isr_fifo* fifo)
{
  Hpd_isr_info* temp;
  
  // Prevent ISR from messing with fifo
  alt_irq_context cntx = alt_irq_disable_all();  
  {
    if(fifo->size < 1)
      {
	return NULL;
      }
    temp = fifo->root;
    fifo->root = temp->next;
    fifo->size--;
    temp->next = NULL;
  }
  alt_irq_enable_all(cntx);
    
  return temp;
}

int hpd_isr_fifo_size(Hpd_isr_fifo* fifo)
{
  return fifo->size;
}

Hpd_isr_fifo* hpd_isr_fifo_create()
{
  //Allocate space for new and initialize data
  Hpd_isr_fifo* fifo = (Hpd_isr_fifo*) malloc(sizeof(Hpd_isr_fifo));  
  fifo->root = NULL;
  fifo->size = 0;
  return fifo;
}

