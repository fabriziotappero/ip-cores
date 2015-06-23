#include <gendc.h>

int
main (argc, argv)
     int argc;
     char **argv;
{
  
  int size_kb = 64;
  int nr_sets = 2;
  int size_tline = 4;
  data_cache *c = gendc_create(size_kb,nr_sets,size_tline);
  unsigned int data;

  if (c) {    
    gendc_read(c,0x10000,&data);
    gendc_write(c,0x10004,1);
    gendc_read(c,0x10000,&data);
    gendc_read(c,0x10004,&data);
    gendc_read(c,0x20000,&data);
    gendc_read(c,0x20004,&data);
   }     
        
   
  return 0;
}

