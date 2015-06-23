/*
 *
 *   Fifo for saving interrupt information, implementation
 *
 *   Lasse Lehtonen
 *
 */



#include "n2h_isr_fifo.h"

#include <sys/alt_irq.h>
#include <stdlib.h>


// Store item to last place, called only from ISR
void n2h_isr_fifo_push(N2H_isr_fifo* fifo, N2H_isr_info* item)
{  
  N2H_isr_info* temp = fifo->root;

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
N2H_isr_info* n2h_isr_fifo_pop (N2H_isr_fifo* fifo)
{
  N2H_isr_info* temp;
  
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

int n2h_isr_fifo_size(N2H_isr_fifo* fifo)
{
  return fifo->size;
}

N2H_isr_fifo* n2h_isr_fifo_create()
{
  //Allocate space for new and initialize data
  N2H_isr_fifo* fifo = (N2H_isr_fifo*) malloc(sizeof(N2H_isr_fifo));  
  fifo->root = NULL;
  fifo->size = 0;
  return fifo;
}

