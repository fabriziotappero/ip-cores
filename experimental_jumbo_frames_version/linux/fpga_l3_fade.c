/*
 * fpga_l3_fade - driver for L3 communication protocol with FPGA based system
 * Copyright (C) 2012 by Wojciech M. Zabolotny
 * Institute of Electronic Systems, Warsaw University of Technology
 *
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; either version 2 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program; if not, write to the Free Software
 *  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 */

#include <linux/module.h>
#include <linux/kernel.h>
#include <asm/uaccess.h>

MODULE_LICENSE("GPL v2");
//#define FADE_DEBUG 1
#include <linux/device.h>
#include <linux/netdevice.h>
#include <linux/fs.h>
#include <linux/cdev.h>
#include <linux/poll.h>
#include <linux/mm.h>
#include <asm/io.h>
#include <linux/wait.h>
#include <linux/sched.h>
#include <asm/uaccess.h>  /* for put_user */
#include <linux/mutex.h>

#include "fpga_l3_fade.h"

#define SUCCESS 0
#define DEVICE_NAME "fpga_l3_fade"


/* Length of the user header in the packet
 * The following fields are BEFORE the user header
 * SRC+TGT - 12 bytes : source & destination
 * 0xFADE - 2 bytes : protocol ID
 * 
 * Fields which belong to the user header:
 * 0x0100 - 2 bytes : protocol version - offset 0
 * For DATA - to PC
 * 0xA5A5 - 2 bytes : data ID 0 - offset 2
 * retry number - 2 bytes - offset 4
 * packet number - 4 bytes - offset 6
 * transm_delay - 4 bytes - offset 10
 * cmd_response - 12 bytes - offset 14
 * 
 * Total: 26 bytes!
 * If the packet contains "flushed" buffer,
 * then data ID is 0xA5A6, and the last word
 * contains number of transmitted words.

 * For command response
 * 0xA55A : cmd_resp ID 2 bytes - offset 2
 * 0x0000 : filler - 2 bytes - offset 4
 * cmd_response - 12 bytes offset 6
 */
#define USER_HDR_LEN 26

/* Number of bytes of user data in a packet */
#define LOG2_USER_LEN 13
#define USER_LEN (1<<LOG2_USER_LEN) 
#define PAYL_LEN ( USER_HDR_LEN + USER_LEN )

/* Number of packets in window - this number depends on amount of RAM
 * in the FPGA - Packets in a widnow must fit in the FPGA RAM
 * Should be power of two! */
#define PKTS_IN_WINDOW (1<<4)
#define PKTS_IN_WINDOW_MASK (PKTS_IN_WINDOW-1)

/* Capacity of kernel buffer (mmapped into user space) measured in
 * number of windows - should be equal to power of two, to simplify
 * the modulo operation (replacing it by binary AND) */
#define WINDOWS_IN_BUFFER (1<<8)

#define MY_BUF_LEN (WINDOWS_IN_BUFFER * PKTS_IN_WINDOW * USER_LEN)
#define MY_BUF_LEN_MASK (MY_BUF_LEN-1)


/* Length of the acknowledment packet and command packets */
#define MY_ACK_LEN 64

/* Number of bytes to be copied from data packet to ack packet 
 * It covers: retry_number, packet_number and transm_delay - 10 bytes
 */
#define MY_ACK_COPIED 10

/* The Ethernet type of our packet. This is NOT OFFICIALLY REGISTERED type,
 * however our protocol is:
 * 1. experimental,
 * 2. supposed to be used only in private networks
 */
#define MY_PROTO_ID 0xfade
#define MY_PROTO_VER 0x0100

static int max_slaves = 4;
module_param(max_slaves,int,0);
MODULE_PARM_DESC(max_slaves,"Maximum number of slave FPGA devices serviced by the system.");

static int proto_registered = 0; //Was the protocol registred? Should be deregistered at exit?

DEFINE_RWLOCK(slave_table_lock); //Used to protect table of slaves

/* Structure used to store offset of two currently serviced sets in the data buffer */
struct pkt_map {
  int num;
  int offset;
};

typedef struct
{
  // fields related to the circular buffer
  volatile int head;
  volatile int tail;
  rwlock_t ptrs_lock; //Used to protect the head and tail pointers

  unsigned char * buffer;
  struct mutex usercmd_lock;
  uint16_t cmd_code;
  uint16_t cmd_seq;
  uint8_t cmd_ack;
  uint8_t cmd_resp[12];
  rwlock_t pkts_rwlock; //Protects the pkts table and last_pkt
  uint32_t last_nack_pkt; /* Number of the last not acknowledged packet. This is also the number
			     of the first packet in the current transmission window */
  uint32_t pkts[PKTS_IN_WINDOW]; /* This array stores numbers of the last received packets in the
				  * transmission window. It is used to avoid unnecessary copying of duplicated
				  * packets into the receiver buffer */
  rwlock_t flags_lock; //Protects other fields of the slave_data struct
  uint32_t last_pkt_num; /* Number of the last "flushed" packet */
  uint32_t last_pkt_len; /* Number of words in the last "flushed" packet */
  char err_flag;
  char stopped_flag; /* Flag informing, that transmission has been already terminated */
  char eof_flag; /* Flag informing, that all packets are delivered after transmission is terminated */
  char active;
  char is_open;
  int rx_wakeup_thr;
  unsigned char mac[ETH_ALEN];
  struct net_device * dev;
} slave_data;

/* Auxiliary inline functions */
static inline uint16_t get_be_u16(char * buf)
{
  return be16_to_cpu(*(uint16_t *)buf);
}

static inline uint32_t get_be_u32(char * buf)
{
  return be32_to_cpu(*(uint32_t *)buf);
}

static inline uint64_t get_be_u64(char * buf)
{
  return be64_to_cpu(*(uint64_t *)buf);
}

static inline void put_skb_u16(struct sk_buff * skb, uint16_t val)
{
  void * data = skb_put(skb,sizeof(val));
  * (uint16_t *) data = cpu_to_be16(val); 
}

static inline void put_skb_u32(struct sk_buff * skb, uint32_t val)
{
  void * data = skb_put(skb,sizeof(val));
  * (uint32_t *) data = cpu_to_be32(val); 
}

static inline void put_skb_u64(struct sk_buff * skb, uint64_t val)
{
  void * data = skb_put(skb,sizeof(val));
  * (uint64_t *) data = cpu_to_be64(val); 
}

static slave_data * slave_table = NULL;

static int my_proto_rcv(struct sk_buff * skb, struct net_device * dev, struct packet_type * pt,
			struct net_device * orig_dev);

static struct packet_type my_proto_pt __read_mostly = {
  .type = cpu_to_be16(MY_PROTO_ID),
  .dev = NULL,
  .func = my_proto_rcv,
};

// Prototypes of functions defined in module
void cleanup_my_proto1( void );
int init_my_proto1( void );
static int my_proto1_open(struct inode *inode, struct file *file);
static int my_proto1_release(struct inode *inode, struct file *file);
static long my_proto1_ioctl (struct file *filp,  unsigned int cmd, unsigned long arg);
int my_proto1_mmap(struct file *filp, struct vm_area_struct *vma);
unsigned int my_proto1_poll(struct file *filp,poll_table *wait);

//Wait queue for user application
DECLARE_WAIT_QUEUE_HEAD (read_queue);
//Wait queue for user commands
DECLARE_WAIT_QUEUE_HEAD (usercmd_queue);
dev_t my_dev=0;
struct cdev * my_cdev = NULL;
static struct class *class_my_proto = NULL;

struct file_operations Fops = {
  .owner = THIS_MODULE,
  .open=my_proto1_open,
  .release=my_proto1_release,  /* a.k.a. close */
  .poll = my_proto1_poll,
  .unlocked_ioctl=my_proto1_ioctl,
  .mmap=my_proto1_mmap
};


/* Function used to send the user command and wait for confirmation */
static inline
long send_cmd(slave_data * sd, uint16_t cmd, uint32_t arg, void * resp, int nof_retries, int timeout)
{
  long result = -ETIMEDOUT;
  //First check, if the Ethernet device is claimed, otherwise return an error
  if(sd->dev==NULL) return -ENODEV;
  //Each slave may perform only one user command, so first check, if no other thread
  //attempts to send the command
  if ( mutex_trylock(&sd->usercmd_lock)==0) return -EBUSY;
  //Mutex acquired, we can proceed
  //First allocate the sequence number for the command
  sd->cmd_seq += 1;
  sd->cmd_code = cmd;
  sd->cmd_ack = 1; //Mark, that we are waiting for response
  //Now in the loop we send the packet, requesting execution of the command
  //and then we wait for response with timeout
  while(nof_retries--) {
    //Send the packet 
    struct sk_buff *newskb = NULL;
    uint8_t * my_data = NULL;
    newskb = alloc_skb(LL_RESERVED_SPACE(sd->dev)+MY_ACK_LEN, GFP_KERNEL);
    skb_reserve(newskb,LL_RESERVED_SPACE(sd->dev));
    skb_reset_network_header(newskb);
    newskb->dev = sd->dev;
    newskb->protocol = htons(MY_PROTO_ID);
    //Build the MAC header for the new packet
    // Here http://lxr.free-electrons.com/source/net/ipv4/arp.c?v=3.17#L608 it is shown how to build a packet!
    if (dev_hard_header(newskb,sd->dev,MY_PROTO_ID,&sd->mac,sd->dev->dev_addr,MY_ACK_LEN+ETH_HLEN) < 0)
      {
        mutex_unlock(&sd->usercmd_lock);
	kfree_skb(newskb);
	return -EINVAL;
      }
    //Put the protocol version id to the packet
    put_skb_u16(newskb,MY_PROTO_VER);
    //Put the command code
    put_skb_u16(newskb,cmd);
    //Put the sequence number
    put_skb_u16(newskb,sd->cmd_seq);
    //Put the argument
    put_skb_u32(newskb,arg);
    //Fill the packet
    my_data = skb_put(newskb,MY_ACK_LEN-10);
    memset(my_data,0xa5,MY_ACK_LEN-10);
    dev_queue_xmit(newskb);
    //Sleep with short timeout, waiting for response
    if(wait_event_interruptible_timeout(usercmd_queue,sd->cmd_ack==2,timeout)) {
      //Response received
      //If target buffer provided, copy data to the userspace buffer
      if(resp) memcpy(resp,sd->cmd_resp,12);
      result = SUCCESS;
      break; //exit loop
    }
  }
  //We don't wait for response any more
  sd->cmd_ack = 0;
  mutex_unlock(&sd->usercmd_lock);
  return result;
}
/* Function used to send RESET command (without confirmation, as
the core is reinitialized and can't send confirmation) */
static inline
long send_reset(slave_data * sd)
{
  struct sk_buff *newskb = NULL;
  uint8_t * my_data = NULL;
  //First check, if the Ethernet device is claimed, otherwise return an error
  if(sd->dev==NULL) return -ENODEV;
  //Each slave may perform only one user command, so first check, if no other thread
  //attempts to send the command
  if ( mutex_trylock(&sd->usercmd_lock)==0) return -EBUSY;
  //Mutex acquired, we can proceed
  //First allocate the sequence number for the command
  sd->cmd_seq = 0;
  sd->cmd_code = FCMD_RESET;
  sd->cmd_ack = 0; //We don't wait for response
  //Send the packet 
  newskb = alloc_skb(LL_RESERVED_SPACE(sd->dev)+MY_ACK_LEN, GFP_KERNEL);
  skb_reserve(newskb,LL_RESERVED_SPACE(sd->dev));
  skb_reset_network_header(newskb);
  newskb->dev = sd->dev;
  newskb->protocol = htons(MY_PROTO_ID);
  //Build the MAC header for the new packet
  // Here http://lxr.free-electrons.com/source/net/ipv4/arp.c?v=3.17#L608 it is shown how to build a packet!
  if (dev_hard_header(newskb,sd->dev,MY_PROTO_ID,&sd->mac,sd->dev->dev_addr,MY_ACK_LEN+ETH_HLEN) < 0)
    {
      mutex_unlock(&sd->usercmd_lock);
      kfree_skb(newskb);
      return -EINVAL;
    }
  //Put the protocol version id to the packet
  put_skb_u16(newskb,MY_PROTO_VER);
  //Put the command code
  put_skb_u16(newskb,sd->cmd_code);
  //Put the sequence number
  put_skb_u16(newskb,sd->cmd_seq);
  //Put the argument
  put_skb_u32(newskb,0);
  //Fill the packet
  my_data = skb_put(newskb,MY_ACK_LEN-10);
  memset(my_data,0xa5,MY_ACK_LEN-10);
  dev_queue_xmit(newskb);
  mutex_unlock(&sd->usercmd_lock);
  return SUCCESS;
}

/* Function free_mac may be safely called even if the MAC was not taken
   it checks sd->active to detect such situation 
*/
static inline
long free_mac(slave_data *sd) {
  write_lock_bh(&slave_table_lock);
  if(sd->active) {
    /* Clear the MAC address */
    sd->active = 0;
    memset(&sd->mac,0,ETH_ALEN);
    write_unlock_bh(&slave_table_lock);
    /* Now send the "stop transmission" packet to the slave */
    /* Find the net device */
    if (!sd->dev) return -ENODEV;
    dev_put(sd->dev);
    sd->dev=NULL;
  } else {
    write_unlock_bh(&slave_table_lock);
  }
  return SUCCESS;
}

static long my_proto1_ioctl (struct file *filp,
			     unsigned int cmd, unsigned long arg)
{
  slave_data * sd = filp->private_data;
  if (_IOC_TYPE(cmd) != L3_V1_IOC_MAGIC) {
    return -EINVAL;
  }
  switch (cmd) {
  case L3_V1_IOC_SETWAKEUP:
    if (arg > MY_BUF_LEN/2)
      return -EINVAL; //Don't allow to set too high read threshold!
    write_lock_bh(&sd->flags_lock);
    sd->rx_wakeup_thr = arg;
    write_unlock_bh(&sd->flags_lock);
    return 0;
  case L3_V1_IOC_GETBUFLEN:
    /* Inform the user application about the length of the buffer */
    return MY_BUF_LEN;
  case L3_V1_IOC_READPTRS:
    {
      void * res = (void *) arg;
      long res2;
      struct l3_v1_buf_pointers bp;
      if (!access_ok(VERIFY_WRITE,res,sizeof(bp))) {
	return -EFAULT;
      } else {
	read_lock_bh(&sd->ptrs_lock);
	bp.head=sd->head;
	bp.tail=sd->tail;
	bp.eof=sd->eof_flag;
	read_unlock_bh(&sd->ptrs_lock);
	res2 = __copy_to_user(res,&bp,sizeof(bp));
        if(res2)
	  return -EFAULT;
	if (sd->err_flag)
	  return -EIO; /* In this case user must him/herself
			  calculate the number of available bytes */
	else
	  return (bp.head-bp.tail) & MY_BUF_LEN_MASK;
	/* Return the number of available bytes */
      }
    }
  case L3_V1_IOC_WRITEPTRS:
    /* Update the read pointer
     * The argument contains information about the number of bytes
     * consumed by the application
     */
    {
      int rptr;
      int wptr;
      int available_data;
      //We need to check if the amount of consumed data is correct
      write_lock_bh(&sd->ptrs_lock);
      wptr = sd->head;
      rptr = sd->tail;
      available_data = (wptr - rptr) & MY_BUF_LEN_MASK;
      if (arg>available_data)
	{
	  write_unlock_bh(&sd->ptrs_lock);
	  return -EINVAL;
	}
      //If the number of consumed bytes is correct, update the number of bytes
      sd->tail = (rptr + arg) & MY_BUF_LEN_MASK;
      write_unlock_bh(&sd->ptrs_lock);
      return SUCCESS;
    }
  case L3_V1_IOC_STARTMAC: //Open the slave
    {
      sd->stopped_flag = 0;
      sd->eof_flag = 0;
      //We just send a request to start transmission and wait for confirmation
      return send_cmd(sd,FCMD_START,0,NULL,100,2);
    }
  case L3_V1_IOC_STOPMAC: //Close the slave and reset it to stop transmission immediately
    {
      return send_cmd(sd,FCMD_STOP,0,NULL,100,2);
    }
  case L3_V1_IOC_RESETMAC: //Reset MAC so, that it stops transmission immediately
    {
      return send_reset(sd);
    }
  case L3_V1_IOC_GETMAC: //Open the slave
    {
      void * source = (void *) arg;
      struct l3_v1_slave sl;
      struct net_device *dev = NULL;
      long res2;
      if (!access_ok(VERIFY_READ,source,sizeof(sl))) {
	return -EFAULT;
      }
      /* First deactivate the slave to avoid situation where data are modified
       * while slave is active */
      if (sd->active) sd->active = 0;
      //Set the numbers of stored packets to MAX
      write_lock_bh(&sd->pkts_rwlock);
      memset(&sd->pkts,0xff,sizeof(sd->pkts));
      sd->last_nack_pkt=0;
      write_unlock_bh(&sd->pkts_rwlock);
      //Copy arguments from the user space
      res2 = __copy_from_user(&sl,source,sizeof(sl));
      if(res2) {
	return -EFAULT;
      }
      write_lock_bh(&slave_table_lock);
      /* Copy the MAC address */
      memcpy(&sd->mac,sl.mac,ETH_ALEN);
      sd->active = 1;
      write_unlock_bh(&slave_table_lock);
      /* Find the net device */
      sl.devname[IFNAMSIZ-1]=0; // Protect against incorrect device name
      if (sd->dev) {
	//Maybe there was no STOPMAC call after previous STARTMAC?
	dev_put(sd->dev);
	sd->dev=NULL;
      }
      dev = dev_get_by_name(&init_net,sl.devname);
      if (!dev) return -ENODEV;
      sd->dev = dev;
      return SUCCESS;
    }
  case L3_V1_IOC_FREEMAC: //Close the slave and reset it to stop transmission immediately
    {
      free_mac(sd);
      return SUCCESS;
    }
  case L3_V1_IOC_USERCMD: //Perform the user command
    {
      void * source = (void *) arg;
      long result = -EINVAL;
      struct l3_v1_usercmd ucmd;
      //First copy command data
      result = __copy_from_user(&ucmd,source,sizeof(ucmd));
      if(result) {
	return -EFAULT;
      }
      //Now we check if the command is valid user command
      if(ucmd.cmd < 0x0100) return -EINVAL;
      result = send_cmd(sd,ucmd.cmd, ucmd.arg, ucmd.resp, ucmd.nr_of_retries,ucmd.timeout);
      if(result<0) return result;
      result = __copy_to_user(source,&ucmd,sizeof(ucmd));
      return result;
    }
  }
  return -EINVAL;
}
/*
  Implementation of the poll method
*/
unsigned int my_proto1_poll(struct file *filp,poll_table *wait)
{
  unsigned int mask =0;
  slave_data * sd = filp->private_data;
  unsigned int data_available;
  poll_wait(filp,&read_queue,wait);
  read_lock_bh(&sd->ptrs_lock);
  data_available = (sd->head - sd->tail) & MY_BUF_LEN_MASK;
  if (data_available >= sd->rx_wakeup_thr) mask |= POLLIN |POLLRDNORM;
  if (sd->eof_flag) {
    if(data_available) mask |= POLLIN | POLLRDNORM;
    else mask |= POLLHUP;
  }
#ifdef FADE_DEBUG
  printk(KERN_INFO "poll head: %d tail: %d data: %d prog: %d.\n",sd->head,sd->tail,data_available,sd->rx_wakeup_thr);
#endif
  //Check if the error occured
  if (sd->err_flag) mask |= POLLERR;
  read_unlock_bh(&sd->ptrs_lock);
  return mask;
}

/* Module initialization  */
int init_my_proto1( void )
{
  int res;
  int i;
  /* Create the device class for udev */
  class_my_proto = class_create(THIS_MODULE, "my_proto");
  if (IS_ERR(class_my_proto)) {
    printk(KERN_ERR "Error creating my_proto class.\n");
    res=PTR_ERR(class_my_proto);
    goto err1;
  }
  /* Allocate the device number */
  res=alloc_chrdev_region(&my_dev, 0, max_slaves, DEVICE_NAME);
  if (res) {
    printk (KERN_ERR "Alocation of the device number for %s failed\n",
	    DEVICE_NAME);
    goto err1;
  };
  /* Allocate the character device structure */
  my_cdev = cdev_alloc( );
  if (my_cdev == NULL) {
    printk (KERN_ERR "Allocation of cdev for %s failed\n",
	    DEVICE_NAME);
    goto err1;
  }
  my_cdev->ops = &Fops;
  my_cdev->owner = THIS_MODULE;
  /* Add the character device to the system */
  res=cdev_add(my_cdev, my_dev, max_slaves);
  if (res) {
    printk (KERN_ERR "Registration of the device number for %s failed\n",
	    DEVICE_NAME);
    goto err1;
  };
  /* Create our devices in the system */
  for (i=0;i<max_slaves;i++) {
    device_create(class_my_proto,NULL,MKDEV(MAJOR(my_dev),MINOR(my_dev)+i),NULL,"l3_fpga%d",i);
  }
  printk (KERN_ERR "%s The major device number is %d.\n",
	  "Registration is a success.",
	  MAJOR(my_dev));
  //Prepare the table of slaves
  slave_table = kzalloc(sizeof(slave_data)*max_slaves, GFP_KERNEL);
  if (!slave_table) return -ENOMEM;
  for (i=0;i<max_slaves;i++) {
    /* Perform initialization, which should be done only once, when the module
     * is loaded. Other actions may be needed, when the transmission from 
     * particular slave is started. This will be done in IOCTL STARTMAC
     */
    slave_data * sd = &slave_table[i];
    sd->active=0; //Entry not used
    sd->dev=NULL;
    rwlock_init(&sd->pkts_rwlock);
    rwlock_init(&sd->ptrs_lock);
    rwlock_init(&sd->flags_lock);
    mutex_init(&sd->usercmd_lock);
  }
  //Install our protocol sniffer
  dev_add_pack(&my_proto_pt);
  proto_registered = 1;
  return SUCCESS;
 err1:
  /* In case of error free all allocated resources */
  cleanup_my_proto1();
  return res;
}

module_init(init_my_proto1);

/* Clean-up when removing the module */
void cleanup_my_proto1( void )
{
  /* Unregister the protocol sniffer */
  if (proto_registered) dev_remove_pack(&my_proto_pt);
  /* Free the slave table */
  if (slave_table) {
    int i;
    for (i=0;i<max_slaves;i++) {
      if (slave_table[i].buffer) {
	vfree(slave_table[i].buffer);
	slave_table[i].buffer = NULL;
      }
      if (slave_table[i].dev) {
	dev_put(slave_table[i].dev);
	slave_table[i].dev=NULL;
      }
      if (slave_table[i].active) {
	slave_table[i].active = 0;
      }
    }
    kfree(slave_table);
    slave_table=NULL;
  }
  /* Remove device from the class */
  if (my_dev && class_my_proto) {
    int i;
    for (i=0;i<max_slaves;i++) {
      device_destroy(class_my_proto,MKDEV(MAJOR(my_dev),MINOR(my_dev)+i));
    }
  }
  /* Deregister device */
  if (my_cdev) cdev_del(my_cdev);
  my_cdev=NULL;
  /* Free the device number */
  unregister_chrdev_region(my_dev, max_slaves);
  /* Deregister class */
  if (class_my_proto) {
    class_destroy(class_my_proto);
    class_my_proto=NULL;
  }

}
module_exit(cleanup_my_proto1);
/*
  Function, which receives my packet, copies the data and acknowledges the packet
  as soon as possible...
  I've tried to allow this function to handle multiple packets in parallel
  in the SMP system, however I've used rwlocks for that.
  Probably it should be improved, according to the last tendency to avoid
  rwlocks in the kernel...
*/

static int my_proto_rcv(struct sk_buff * skb, struct net_device * dev, struct packet_type * pt,
			struct net_device * orig_dev)
{
  struct sk_buff *newskb = NULL;
  struct ethhdr * rcv_hdr = NULL;
  //unsigned int head;
  //unsigned int tail;
  int is_duplicate = 0;
  int res;
  uint32_t packet_number;
  int ns; //Number of slave
  slave_data * sd = NULL;
  int32_t pkt_dist;
  char * my_data = NULL;
  unsigned char tmp_buf[USER_HDR_LEN];
  char ack_packet = 0; //Should we acknowledge the packet?
  uint32_t pkt_pos, needed_space, buf_free;
  //Extract the MAC header from the received packet
  rcv_hdr=eth_hdr(skb);
  //First we try to identify the sender so we search the table of active slaves
  //The table is protected during the search, so it should not be changed
#ifdef FADE_DEBUG
  printk("snd: %2.2x:%2.2x:%2.2x:%2.2x:%2.2x:%2.2x\n",(int)rcv_hdr->h_source[0],
	 (int)rcv_hdr->h_source[1],(int)rcv_hdr->h_source[2],(int)rcv_hdr->h_source[3],
	 (int)rcv_hdr->h_source[4],(int)rcv_hdr->h_source[5]);
#endif
  read_lock_bh(&slave_table_lock);
  for (ns=0;ns<max_slaves;ns++) {
#ifdef FADE_DEBUG
    printk("slv: %2.2x:%2.2x:%2.2x:%2.2x:%2.2x:%2.2x  act: %d\n",
	   (int)slave_table[ns].mac[0],(int)slave_table[ns].mac[1],(int)slave_table[ns].mac[2],
	   (int)slave_table[ns].mac[3],(int)slave_table[ns].mac[4],(int)slave_table[ns].mac[5],
	   (int)slave_table[ns].active);
#endif
    if (
	slave_table[ns].active!=0 &&
	memcmp(slave_table[ns].mac,rcv_hdr->h_source, sizeof(slave_table[0].mac))==0
	) break;
  }
  read_unlock_bh(&slave_table_lock);
  //Now we know which slave sent us the packet (ns<max_slaves) or that
  //the packet came from an unknown slave (ns==max_slaves)
  if (unlikely(ns==max_slaves)) {
    printk(KERN_WARNING " Received packet from incorrect slave!\n");
    //Sender is not opened, so ignore the packet, and send
    //to the sender request to stop the transmission immediately
    newskb = alloc_skb(LL_RESERVED_SPACE(dev)+MY_ACK_LEN, GFP_ATOMIC);
    skb_reserve(newskb,LL_RESERVED_SPACE(dev));
    skb_reset_network_header(newskb);
    newskb->dev = dev;
    newskb->protocol = htons(MY_PROTO_ID);
    //Build the MAC header for the new packet
    // Here http://lxr.free-electrons.com/source/net/ipv4/arp.c?v=3.17#L608 it is shown how to build a packet!
    if (dev_hard_header(newskb,dev,MY_PROTO_ID,&rcv_hdr->h_source,&rcv_hdr->h_dest,MY_ACK_LEN+ETH_HLEN) < 0)
      goto error;
    //Put the protocol version id to the packet
    put_skb_u16(newskb,MY_PROTO_VER);
    //Put the "restart" command to the packet, which should force it to stop transmission
    //immediately
    put_skb_u16(newskb,FCMD_RESET);
    my_data = skb_put(newskb,MY_ACK_LEN - 4);
    memset(my_data,0xa5,MY_ACK_LEN - 4);
    dev_queue_xmit(newskb);
    kfree_skb(skb);
    return NET_RX_DROP;
  }
  sd = &slave_table[ns]; //To speed up access to the data describing state of the slave
#ifdef FADE_DEBUG
  printk(KERN_INFO " Received packet!\n");
#endif
  //Now we should analyze the origin and meaning of the packet
  //To avoid problems with scattered packets, we copy initial part of data to the buffer
  //using the skb_copy_bits
  skb_copy_bits(skb,0,tmp_buf,USER_HDR_LEN);
  /* We extract the information from the user header
   * First we check if this is correct version of the protocol */
  if (unlikely(get_be_u16(&tmp_buf[0]) != MY_PROTO_VER)) goto wrong_pkt_type_error;
  if (unlikely(get_be_u16(&tmp_buf[2]) == 0xa55a)) {
    //This is a command response packet
    printk(KERN_INFO " received command response packet");
    if(sd->cmd_ack==1) {
      //We are waiting for response
      printk(KERN_INFO "we were waiting for command response packet");
      if ((get_be_u16(&tmp_buf[6]) == sd->cmd_code) &&
	  (get_be_u16(&tmp_buf[8]) == sd->cmd_seq)){
	//This is a response for the right command
	//copy the response to the slave data
	printk(KERN_INFO "It was response for the right command");
	memcpy(&sd->cmd_resp,&tmp_buf[6],12);
	sd->cmd_ack=2;
	//Wake up the waiting process
	wake_up_interruptible(&usercmd_queue);
      }
    }
    kfree_skb(skb);
    return NET_RX_SUCCESS;
  }
  if (unlikely((get_be_u16(&tmp_buf[2]) != 0xa5a5) &&
	       (get_be_u16(&tmp_buf[2]) != 0xa5a6))
      ) {
    //This is not a data packet
    goto wrong_pkt_type_error;
  }
  /* Now we handle the data packet 
     PLEASE NOTE, THAT THIS MUST TIGHTLY CORRESPOND
     TO YOUR FPGA IMPLEMENTATION! */
  //Check, if we need to read a command response
  if(sd->cmd_ack==1) {
    //We are waiting for response
    if ((get_be_u16(&tmp_buf[14]) == sd->cmd_code) &&
	(get_be_u16(&tmp_buf[16]) == sd->cmd_seq)) {
      //This is a response for the right command
      //copy the response to the slave data
      memcpy(&sd->cmd_resp,&tmp_buf[14],12);
      sd->cmd_ack=2;
      //Wake up the waiting process
      wake_up_interruptible(&usercmd_queue);
    }
  }
  packet_number = get_be_u32(&tmp_buf[6]);
#ifdef FADE_DEBUG
  printk(KERN_INFO "pkt=%d\n",(int)packet_number);
#endif
  /* To know if this is a new packet, we compare the packet number
   * in the received packet with the number of the last unconfirmed packet,
   * calculating the difference between those two numbers: */
  read_lock_bh(&sd->pkts_rwlock);
  pkt_dist=(int32_t) packet_number - (int32_t) sd->last_nack_pkt;
  //Check if this packet was received before
  is_duplicate=(sd->pkts[packet_number & PKTS_IN_WINDOW_MASK] == packet_number) ? 1 : 0;
  read_unlock_bh(&sd->pkts_rwlock);
  if (unlikely((pkt_dist<0) || (pkt_dist>=PKTS_IN_WINDOW))) {
    //This is a "too old" packet, or packet "from the future", which should not be transimtted
    //by the FPGA
    if (pkt_dist<0) {
      // This is a packet which was already confirmed, but probably ACK was lost
#ifdef FADE_DEBUG
      printk(KERN_INFO "Packet already confirmed: pkt=%d expect=%d last=%d\n",packet_number, sd->pkts[packet_number], sd->last_nack_pkt);
#endif
      ack_packet = 1;
      goto confirm;
    } else {
      /* This is a packet with too high set number (packet "from the future"
       * it my be a symptom of serious communication problem! */
      printk(KERN_ERR "Packet from the future! number: %d last_confirmed: %d\n", packet_number, sd->last_nack_pkt);
      goto error2;
    }
  }
  //If we get there, it means, that:
  //   pkt_dist >= 0 and pkt_dist < PKTS_IN_WINDOW
  // So this is an expected data packet.
  if(is_duplicate) {
    //Packet already confirmed, probably the ACK was lost, so simply generate the ACK
    ack_packet = 1;
    goto confirm;
  }
  //Packet not confirmed yet. Confirm it only after all processing is successfully completed
  pkt_pos=(packet_number<<LOG2_USER_LEN) & MY_BUF_LEN_MASK;
  //We must be sure, that the pointers do not change during this check
  read_lock_bh(&sd->ptrs_lock);
  //Calculate free space needed to copy the packet
  needed_space = (pkt_pos+USER_LEN-1-(sd->head)) & MY_BUF_LEN_MASK;
  //Calculate the amount of free space in the buffer
  buf_free = (sd->tail - sd->head -1 ) & MY_BUF_LEN_MASK;
#ifdef FADE_DEBUG
  printk(KERN_INFO "packet_nr: %d Free buffer: %d needed space: %d head=%d last_nack=%d\n",
	 packet_number, needed_space, buf_free, sd->head, sd->last_nack_pkt);
#endif
  read_unlock_bh(&sd->ptrs_lock);
  if (unlikely( buf_free <= needed_space )) goto error2; //No place for copying, drop the packet
  // Check the length of the package
  if (unlikely(skb->len != PAYL_LEN)) {
    printk(KERN_ERR "Error! Length of data should be %d but is %d!\n",PAYL_LEN, skb->len);
    sd->err_flag |= FADE_ERR_INCORRECT_LENGTH;
    goto error2;
  }
  // We can safely copy all the packet to the buffer:
  res = skb_copy_bits(skb,USER_HDR_LEN,&(sd->buffer[pkt_pos]),USER_LEN);
#ifdef FADE_DEBUG
  printk(KERN_INFO " skb_copy_bits: %d", res);
#endif
  if (res<0) goto error2; //Unsuccessfull copying
  //Packet was copied, so note, that we should confirm it
  ack_packet=1;
  /* When packet is copied, we can check if this is the last "flushed" packet */
  if (get_be_u16(&tmp_buf[2])==0xa5a6) {
    //Flushed packet, store its number and length (should it be protected with spinlock?)
    sd->last_pkt_num = packet_number;
    //Copy the length, truncating it from 64 bits
    sd->last_pkt_len = (uint32_t) * (uint64_t *) &(sd->buffer[pkt_pos+USER_LEN-sizeof(uint64_t)]);
    //We have received the "flushed" buffer, mark that transmission is stopped
    sd->stopped_flag = 1;
    //printk(KERN_INFO "set stopped flag");
  }
  /* We modify the number of the copied packet in the pkts array, to avoid
   * unnecessary copying if we receive a duplicate
   * To modify the pkts table, we must close pkts_rwlock for writing */
  write_lock_bh(&sd->pkts_rwlock);
  sd->pkts[packet_number & PKTS_IN_WINDOW_MASK]= packet_number;
  if (packet_number == sd->last_nack_pkt) {
    /* If our packet was the last, which prevented shifting of the head pointer,
     * we can try now to move the head pointer.
     * We browse the pkts table, looking for the first packet with incorrect number 
     * i.e. the packet which was not received and not confimed yet
     */
    uint32_t chk_packet_num = packet_number+1;
    uint32_t count=0;
    while (++count < PKTS_IN_WINDOW) {
      if (sd->pkts[(sd->last_nack_pkt + count) & PKTS_IN_WINDOW_MASK] != chk_packet_num) break; //Packet not confirmed
      chk_packet_num++;
    }
    sd->last_nack_pkt += count;
    write_unlock_bh(&sd->pkts_rwlock);
    /* Now we can move the head position */
    if(likely((sd->stopped_flag == 0) || 
	      ((uint32_t)(sd->last_nack_pkt-1) != sd->last_pkt_num))) {
      //Normal packet, set head right after the last serviced packet
      write_lock_bh(&sd->ptrs_lock);
      sd->head = (sd->last_nack_pkt*USER_LEN) & MY_BUF_LEN_MASK;
      //Now try to wake up the reading process
      if (((sd->head - sd->tail) & MY_BUF_LEN_MASK) >= sd->rx_wakeup_thr)
	wake_up_interruptible(&read_queue);
    } else {
      //Flushed packet, set head right after the end of the packet
      write_lock_bh(&sd->ptrs_lock);
      sd->head = ((sd->last_nack_pkt-1)*USER_LEN+sd->last_pkt_len) & MY_BUF_LEN_MASK;
      //We have consumed the last, "flushed" buffer, so now we can set the eof flag
      sd-> eof_flag = 1;
      //printk(KERN_ALERT "set eof flag!");
      //And we wake up the reading process
      wake_up_interruptible(&read_queue);
    } //if - stopped_flag
    write_unlock_bh(&sd->ptrs_lock);
  } else { // if - last_nack_pkt 
    write_unlock_bh(&sd->pkts_rwlock);
  }
 confirm:
  //Send the confirmation if required
  if (likely(ack_packet)) {
    newskb = alloc_skb(LL_RESERVED_SPACE(dev)+MY_ACK_LEN, GFP_ATOMIC);
    skb_reserve(newskb,LL_RESERVED_SPACE(dev));
    skb_reset_network_header(newskb);
    newskb->dev = dev;
    newskb->protocol = htons(MY_PROTO_ID);
    //Build the MAC header for the new packet
    // Here http://lxr.free-electrons.com/source/net/ipv4/arp.c?v=3.17#L608 it is shown how to build a packet!
    if (dev_hard_header(newskb,dev,MY_PROTO_ID,&rcv_hdr->h_source,&rcv_hdr->h_dest,MY_ACK_LEN+ETH_HLEN) < 0)
      goto error;
    //Put the protocol version id to the packet
    put_skb_u16(newskb,MY_PROTO_VER);
    //Put the "ACKNOWLEDGE" type
    put_skb_u16(newskb,FCMD_ACK);
    //Copy the begining of the received packet to the acknowledge packet
    my_data = skb_put(newskb,MY_ACK_COPIED);
    res = skb_copy_bits(skb,4,my_data,MY_ACK_COPIED);
    my_data = skb_put(newskb,MY_ACK_LEN -MY_ACK_COPIED-4);
    memset(my_data,0xa5,MY_ACK_LEN - MY_ACK_COPIED-4);
#ifdef FADE_DEBUG
    printk(KERN_INFO " skb_nh: %x, skb_dt: %x, skb_nh2: %x, skb_t: %x\n tail: %d head: %d\n",skb_network_header(newskb),newskb->data,
	   newskb->network_header,newskb->tail, sd->tail, sd->head) ;
#endif
    dev_queue_xmit(newskb);
  }
  kfree_skb(skb);
  return NET_RX_SUCCESS;
 wrong_pkt_type_error:
  //This code should be called with sd initialized,
  //but to avoid kernel panic, check if sd was set
  if(sd) {
    write_lock_bh(&sd->flags_lock);
    sd->err_flag |= FADE_ERR_INCORRECT_PACKET_TYPE;
    write_unlock_bh(&sd->flags_lock);
  } else {
    printk(KERN_ERR "FADE: wrong_pkt_type_error called with null sd");
  }
 error:
  if (newskb) kfree_skb(newskb);
 error2:
  if (skb) kfree_skb(skb);
  return NET_RX_DROP;
}

/*
  Implementation of the "device open" function
*/
static int my_proto1_open(struct inode *inode,
			  struct file *file)
{
  int i;
  slave_data * sd = NULL;
  unsigned long flags;
  i=iminor(inode)-MINOR(my_dev);
  if (i >= max_slaves) {
    printk(KERN_WARNING "Trying to access %s slave with too high minor number: %d\n",
	   DEVICE_NAME, i);
    return -ENODEV;
  }
  read_lock_irqsave(&slave_table_lock,flags);
  sd = &slave_table[i];
  //Each device may be opened only once!
  if (sd->is_open) {
    read_unlock_irqrestore(&slave_table_lock,flags);
    return -EBUSY;
  }
  //Prepare slave_table for operation
  read_unlock_irqrestore(&slave_table_lock,flags);
  sd->buffer = vmalloc_user(MY_BUF_LEN);
  if (!sd->buffer) return -ENOMEM;
  //Set the MAC address to 0
  memset(sd->mac,0,sizeof(sd->mac));
  sd->head = 0;
  sd->tail = 0;
  sd->eof_flag = 0;
  sd->stopped_flag = 0;
  sd->err_flag = 0;
  sd->last_nack_pkt = 0;
  sd->rx_wakeup_thr = 1;
  sd->active = 0;
  sd->cmd_seq = 0;
  sd->is_open = 1;
  file->private_data=sd;
  return SUCCESS;
}


static int my_proto1_release(struct inode *inode,
			     struct file *file)
{
  slave_data * sd = file->private_data;
  //#ifdef FADE_DEBUG
  printk (KERN_INFO "device_release(%p,%p)\n", inode, file);
  //#endif
  //Release resources associated with servicing of the particular device
  if (sd) {
    if (sd->is_open) {
      sd->is_open = 0; //It can be dangerous! Before freeing the buffer, we must be sure, that
      //no our packet is being processed!
      printk (KERN_INFO "freed MAC\n");
      free_mac(sd); //It also sets sd->active to 0!
      if (sd->buffer) {
	printk (KERN_INFO "freed buffer\n");
	vfree(sd->buffer);
	sd->buffer = NULL;
      }
    }
  }
  return SUCCESS;
}

/* Memory mapping */
void my_proto1_vma_open (struct vm_area_struct * area)
{  }

void my_proto1_vma_close (struct vm_area_struct * area)
{  }

static struct vm_operations_struct my_proto1_vm_ops = {
  my_proto1_vma_open,
  my_proto1_vma_close,
};

/*
  mmap method implementation
*/
int my_proto1_mmap(struct file *filp,
		   struct vm_area_struct *vma)
{
  slave_data * sd = filp->private_data;
  unsigned long vsize = vma->vm_end - vma->vm_start;
  unsigned long psize = MY_BUF_LEN;
  if (vsize>psize)
    return -EINVAL;
  remap_vmalloc_range(vma,sd->buffer, 0);
  if (vma->vm_ops)
    return -EINVAL; //It should never happen...
  vma->vm_ops = &my_proto1_vm_ops;
  my_proto1_vma_open(vma); //No open(vma) was called, we have called it ourselves
  return 0;
}

