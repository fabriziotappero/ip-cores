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
#include <endian.h>
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
      .devname = "p4p1"
    },
    {
      .mac = {0xde, 0xad, 0xba, 0xbe, 0xbe,0xe1},
      .devname = "p4p1"
    },
    {
      .mac = {0xde, 0xad, 0xba, 0xbe, 0xbe,0xe2},
      .devname = "p4p1"
    }
   };
  int i,j;
  int res;
  int blen[3];
  uint64_t data[3] = {0,0,0};
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
  //Connect devices
  gettimeofday(&tv, NULL);
  tstart=tv.tv_sec+1.0e-6*tv.tv_usec;
  stop=tv.tv_sec+300;
  for(i=0;i<=2;i++) {
    if(active[i]) {
       res = ioctl(frs[i],L3_V1_IOC_GETMAC,&sl[i]);
       printf("Result of get for slave %d : %d\n",i,res);
       }
  }
  //Send user command
  for(i=0;i<=2;i++) {
    if(active[i]) {
       int j;
       struct l3_v1_usercmd uc;
       uc.cmd=0x0112;
       uc.arg=0x56789abc;
       uc.timeout=2;
       uc.nr_of_retries=20;
       res = ioctl(frs[i],L3_V1_IOC_USERCMD,&uc);
       printf("Result of usercmd for slave %d : %d\n",i,res);
       for(j=0;j<12;j++) {
         printf("%2.2x",(int)(uc.resp[j]));
         }
       printf("\n");
       }
  }
  for(i=0;i<=2;i++) {
    res = ioctl(frs[i],L3_V1_IOC_FREEMAC,0);
    munmap(v[i],blen[i]);
    close(frs[i]);
  }
  
}
