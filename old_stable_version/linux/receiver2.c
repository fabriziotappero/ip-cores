/*
 * fpga_l3_fade - driver for L3 communication protocol with FPGA based system
 * Copyright (C) 2012 by Wojciech M. Zabolotny
 * Institute of Electronic Systems, Warsaw University of Technology
 *
 *  This code is PUBLIC DOMAIN
 */

#include<termios.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <sys/mman.h>
#include <sys/ioctl.h>
#include <fcntl.h>
#include <poll.h>
#include <unistd.h>
#include <stdio.h>
#include <strings.h>
#include <stdlib.h>
#include <stdint.h>

#include <sys/socket.h>
#include <linux/serial.h>
#include <sched.h>
#include "fpga_l3_fade.h"
#include <sys/time.h>

       
void main(int argc, char * argv[])
{
  int active[3]={0,0,0};
  struct l3_v1_buf_pointers bp;
  struct l3_v1_slave sl[3] = {
    {
      .mac = {0xde, 0xad, 0xba, 0xbe, 0xbe,0xef},
      .devname = "eth0"
    },
    {
      .mac = {0xde, 0xad, 0xba, 0xbe, 0xbe,0xe1},
      .devname = "eth0"
    },
    {
      .mac = {0xde, 0xad, 0xba, 0xbe, 0xbe,0xe2},
      .devname = "eth0"
    }
   };
  int i,j;
  int res;
  int blen[3];
  uint32_t data[3] = {0,0,0};
  long long total_len[3]={0,0,0};
  unsigned char * v[3];
  int frs[3]={-1,-1,-1};
  struct timeval tv;
  double tstart=0.0 , tend=0.0;
  int stop;
  struct sched_param s;
  s.sched_priority = 90;
  //Read active channels
  for(i=1;i<argc;i++) {
    int n = atoi(argv[i]);
    if ((n>=0) && (n<=2))
      active[n]=1;
  }  
  printf("sched=%d\n",sched_setscheduler(0,SCHED_RR,&s));
  //Prepare all slaves to work
  for(i=0;i<3;i++) {
    char devname[30];
    sprintf(devname,"/dev/l3_fpga%d",i);
    frs[i]=open(devname,O_RDONLY);
    if(frs[i]<0) {
      printf("I can't open device %s\b",devname);
      perror("");
      exit(1);
    }
    //Get the length of the buffer
    blen[i] = ioctl(frs[i],L3_V1_IOC_GETBUFLEN,NULL);
    //Set the wakeup threshold
    res=ioctl(frs[i],L3_V1_IOC_SETWAKEUP,2000000);
    printf("length of buffer: %d, result of set wakeup: %d\n",blen[i],res); 
    v[i]=(unsigned char *)mmap(0,blen[i],PROT_READ,MAP_PRIVATE,frs[i],0);
    if(!v[i]) {
      printf("mmap for device %s failed\n",devname);
      exit(1);
    }
  }
  //Start the transmission
  gettimeofday(&tv, NULL);
  tstart=tv.tv_sec+1.0e-6*tv.tv_usec;
  stop=tv.tv_sec+300;
  for(i=0;i<=2;i++) {
    if(active[i]) {
       res = ioctl(frs[i],L3_V1_IOC_STARTMAC,&sl[i]);
       printf("Result of start for slave %d : %d\n",i,res);
       }
  }
  int first_served=0;
  do{
    struct pollfd pfd[3] = {{.fd = frs[0], .events = POLLIN, .revents = 0},
                            {.fd = frs[1], .events = POLLIN, .revents = 0},
                            {.fd = frs[2], .events = POLLIN, .revents = 0},
                           };
    int ptr=0;
    int len=0;
    int pres;
    //Wait for data using "poll"
    pres = poll(pfd,3,-1);
    if(pres<0) {
      perror("Error in poll:");
      exit(1);
    }
    first_served = (first_served+1) %3; //Rotate priority of slaves
    for(j=0;j<3;j++) {
      i=(j+first_served) % 3;
      if(pfd[i].revents) {
        len = ioctl(frs[i],L3_V1_IOC_READPTRS,&bp);
        total_len[i] += len;    
        printf("i=%d len=%d total=%lld head:%d tail: %d\n",i,len,total_len[i],bp.head, bp.tail);
        //OK. The data are read, let's analyze them
        while (bp.head != bp.tail)  {
  	  uint32_t c;
	  c = *(uint32_t *)(v[i]+bp.tail);
  	  c = ntohl(c);
	  bp.tail=(bp.tail+4) & (blen[i]-1); //Adjust tail pointer modulo blen[i]-1
	  if (__builtin_expect((c != data[i]), 0)) {
	    printf("Error! received: %8.8x expected: %8.8x \n",c,data[i]);
	    exit(1);
	  }
	  data[i] ++;
        }
        ioctl(frs[i],L3_V1_IOC_WRITEPTRS,len);
      }
    }
    fflush(stdout);
    gettimeofday(&tv, NULL);
    if(tv.tv_sec > stop) {
      tend=tv.tv_sec+1.0e-6*tv.tv_usec;
      break;
    }
  } while (1);
  tend=tend-tstart;
  fprintf(stderr,"act0:%d act1:%d act2:%d\n",active[0],active[1],active[2]);
  for(i=0;i<3;i++) {
     fprintf(stderr,"total data %d=%lld time=%g throughput=%g [Mb/s]\n",i,total_len[i], tend, total_len[i]/tend*8.0);
  }
  for(i=0;i<=2;i++) {
    res = ioctl(frs[i],L3_V1_IOC_STOPMAC,0);
    munmap(v[i],blen[i]);
    close(frs[i]);
  }
  
}
