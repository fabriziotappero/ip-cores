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
#include <pthread.h>

int frs[3]={-1,-1,-1};
int active[3]={0,0,0};
int leave[3]={0,0,0};
pthread_t ucmd_thread;
double tend=0.0;
#define nic0 "eth0"

void * user_cmd_thread(void * a1)
{
  uint16_t cmd;
  int i;
  int res;
  struct timeval tv;
  double tstart=0.0;
  sleep(2);
  for(i=0;i<=2;i++) {
    if(active[i]) {
      res = ioctl(frs[i],L3_V1_IOC_STARTMAC,NULL);
      printf("Result of startmac for slave %d : %d\n",i,res);
    }
  }
  gettimeofday(&tv, NULL);
  tstart=tv.tv_sec+1.0e-6*tv.tv_usec;
  //Send three commands to each slave
  //Waiting 10 seconds
  for(cmd=0x112; cmd<=0x114; cmd++) {
    sleep(10);
    //Send user command
    for(i=0;i<=2;i++) {
      if(active[i]) {
	int j;
	struct l3_v1_usercmd uc;
	uc.cmd=cmd;
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
  }
  //Wait for 500 seconds
  sleep(500);
  for(i=0;i<=2;i++) {
    if(active[i]) {
      res = ioctl(frs[i],L3_V1_IOC_STOPMAC,NULL);
      printf("Result of usercmd for slave %d : %d\n",i,res);
    }
  }
  gettimeofday(&tv, NULL);
  tend=tv.tv_sec+1.0e-6*tv.tv_usec;
  tend=tend-tstart;
}
       
void main(int argc, char * argv[])
{
  struct l3_v1_buf_pointers bp;
  struct l3_v1_slave sl[3] = {
    {
      .mac = {0xde, 0xad, 0xba, 0xbe, 0xbe,0xef},
      .devname = nic0
    },
    {
      .mac = {0xde, 0xad, 0xba, 0xbe, 0xbe,0xe1},
      .devname = nic0
    },
    {
      .mac = {0xde, 0xad, 0xba, 0xbe, 0xbe,0xe2},
      .devname = nic0
    }
  };
  int i,j;
  int res;
  int blen[3];
  uint64_t data[3] = {0,0,0};
  long long total_len[3]={0,0,0};
  unsigned char * v[3];
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
  //Connect to appropriate FPGAs
  for(i=0;i<=2;i++) {
    if(active[i]) {
      res = ioctl(frs[i],L3_V1_IOC_GETMAC,&sl[i]);
      printf("Result of get for slave %d : %d\n",i,res);
      if(res<0) {
        printf("I couldn't bind Ethernet device %s\n",sl[i].devname);
        exit(1);
      }
    } else {
      leave[i]=1;
    }
  }
  //Send FADE reset command, so that FADE core is in predictable state
  for(i=0;i<=2;i++) {
    if(active[i]) {
      int j;
      for(j=0;j<3;j++) {
        res = ioctl(frs[i],L3_V1_IOC_RESETMAC,&sl[i]);
        if(res<0) {
          printf("I couldn't RESET Ethernet device %d\n",i);
          exit(1);
        }
      }
    } else {
      leave[i]=1;
    }
  }
  //Start the second thread, which uses user commands
  pthread_create(&ucmd_thread, NULL, user_cmd_thread, NULL);
  int first_served=0;
  do{
    struct pollfd pfd[3];
    int ptr=0;
    int len=0;
    int pres;
    for(i=0;i<3;i++) {
      pfd[i].fd = active[i] ? frs[i] : -1;
      pfd[i].events = POLLIN;
      pfd[i].revents = 0;
    }
    //Wait for data using "poll"
    pres = poll(pfd,3,1000);
    if(pres<0) {
      perror("Error in poll:");
      exit(1);
    }
    first_served = (first_served+1) %3; //Rotate priority of slaves
    for(j=0;j<3;j++) {
      i=(j+first_served) % 3;
      if(pfd[i].revents) {
        int ofs=0;
        len = ioctl(frs[i],L3_V1_IOC_READPTRS,&bp);
	if(bp.eof) leave[i]=1;
        //OK. The data are read, let's analyze them
        while (bp.head != bp.tail)  {
  	  uint64_t c;
	  c = be64toh(*(uint64_t *)(v[i]+bp.tail));
	  bp.tail=(bp.tail+8) & (blen[i]-1); //Adjust tail pointer modulo blen[i]
	  if (__builtin_expect((c != data[i]), 0)) {
	    printf("Error! received: %llx expected: %llx position: %8.8x\n",c,data[i],total_len[i]+ofs);
	    exit(1);
	  }
	  data[i] += 0x1234567809abcdefL;
          ofs++;
        }
        total_len[i] += len;    
        //printf("i=%d len=%d total=%lld head:%d tail: %d revents=%d eof=%d\n",i,len,total_len[i],bp.head, bp.tail,pfd[i].revents,(int)bp.eof);
        ioctl(frs[i],L3_V1_IOC_WRITEPTRS,len);
      }
    }
    fflush(stdout);    
  } while ((leave[0] && leave[1] && leave[2]) == 0);
  pthread_join(ucmd_thread, NULL); 
  for(i=0;i<=2;i++) {
    if(active[i]) {
      res = ioctl(frs[i],L3_V1_IOC_FREEMAC,0);
    }
    munmap(v[i],blen[i]);
    close(frs[i]);
  }
  fprintf(stderr,"act0:%d act1:%d act2:%d\n",active[0],active[1],active[2]);
  for(i=0;i<3;i++) {
    fprintf(stderr,"total data %d=%lld time=%g throughput=%g [Mb/s]\n",i,total_len[i], tend, total_len[i]/tend*8.0);
  }
}
