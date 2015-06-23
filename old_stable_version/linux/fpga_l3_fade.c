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

#include <linux/kernel.h>
#include <linux/module.h>
#include <asm/uaccess.h>

MODULE_LICENSE("GPL v2");

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

#include "fpga_l3_fade.h"

#define SUCCESS 0
#define DEVICE_NAME "fpga_l3_fade"

/* Maximum number of packets' set (the set counter will wrap
 * after this number is reached) should be power of two!*/
#define SET_NUMBER (1<<16)
#define SET_NUMBER_MASK (SET_NUMBER-1)

/* Number of packets in set - this number depends on amount of RAM
 * in the FPGA - all set must fit in the FPGA RAM
 * Should be power of two! */
#define PKTS_IN_SET (1<<5)
#define PKT_IN_SET_MASK (PKTS_IN_SET-1)

/* Capacity of kernel buffer (mmapped into user space) measured in
 * number of sets - should be equal to power of two, to simplify
 * the modulo operation (replacing it by binary AND) */
#define SETS_IN_BUFFER (1<<8)

#define MY_BUF_LEN (SETS_IN_BUFFER * PKTS_IN_SET * 1024)
#define MY_BUF_LEN_MASK (MY_BUF_LEN-1)

/* Length of the user header in the packet -
 * command - 2 bytes
 * set number - 2 bytes,
 * packet number and retry number (not used
 * yet) 2 bytes
 * current inter-packet delay (used to monitor the
 * process of delay adaptation) 4 bytes
 */
#define USER_HDR_LEN 10

/* Number of bytes of user data in a packet */
#define USER_LEN 1024
#define PAYL_LEN ( USER_HDR_LEN + USER_LEN )

/* Length of the acknowledment packet and command packets */
#define MY_ACK_LEN 64

/* Number of bytes to be copied from data packet to ack packet */
#define MY_ACK_COPIED 4

/* The Ethernet type of our packet. This is NOT OFFICIALLY REGISTERED type,
 * however our protocol is:
 * 1. experimental,
 * 2. supposed to be used only in private networks
 */
#define MY_PROTO_ID 0xfade

static int max_slaves = 4;
module_param(max_slaves,int,1);
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

    rwlock_t pkts_rwlock; //Protects the pkts table and last_pkt
    int last_pkt; /* position of the last packet, which is still
		    replaced with the packet from the next set */
    int pkts[PKTS_IN_SET];

    rwlock_t maps_rwlock; //Protects the maps table
    struct pkt_map maps[2];

    rwlock_t flags_lock; //Protects other fields of the slave_data struct
    char err_flag;
    char active;
    char is_open;
    int rx_wakeup_thr;
    unsigned char mac[ETH_ALEN];
    struct net_device * dev;
} slave_data;

/*
 * The array pkts holds the number of set, from which we expect the particulal packet
 * (so we can safely start with this array filled with zeroes).
 * After the packet is sent and acknowledged, we increase the number corresponding
 * to this packet.
 * At each moment this table may be filled with two different values - n, and n+1
 * because we service two consecutive sets
 */
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
        struct l3_v1_buf_pointers bp;
        if (!access_ok(VERIFY_WRITE,res,sizeof(bp))) {
            return -EFAULT;
        } else {
            read_lock_bh(&sd->ptrs_lock);
            bp.head=sd->head;
            bp.tail=sd->tail;
            read_unlock_bh(&sd->ptrs_lock);
            __copy_to_user(res,&bp,sizeof(bp));
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
        void * source = (void *) arg;
        struct l3_v1_slave sl;
        struct sk_buff *newskb = NULL;
        struct net_device *dev = NULL;
        char * my_data = NULL;
        if (!access_ok(VERIFY_READ,source,sizeof(sl))) {
            return -EFAULT;
        }
        /* First deactivate the slave to avoid situation where data are modified
        * while slave is active */
        if (sd->active) sd->active = 0;
        /* Prepare the data structure for reception of packets */
        write_lock_bh(&sd->maps_rwlock);
        sd->maps[0].num = 0;
        sd->maps[0].offset = 0;
        sd->maps[1].num=1;
        sd->maps[1].offset = PKTS_IN_SET*USER_LEN;
        write_unlock_bh(&sd->maps_rwlock);
        write_lock_bh(&sd->pkts_rwlock);
        memset(&sd->pkts,0,sizeof(sd->pkts));
        sd->last_pkt=0;
        write_unlock_bh(&sd->pkts_rwlock);
        __copy_from_user(&sl,source,sizeof(sl));
        write_lock_bh(&slave_table_lock);
        /* Copy the MAC address */
        memcpy(&sd->mac,sl.mac,ETH_ALEN);
        sd->active = 1;
        write_unlock_bh(&slave_table_lock);
        /* Now send the "start transmission" packet to the slave */
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
        newskb = alloc_skb(LL_RESERVED_SPACE(dev)+MY_ACK_LEN, GFP_ATOMIC);
        skb_reserve(newskb,LL_RESERVED_SPACE(dev));
        skb_reset_network_header(newskb);
        newskb->dev = dev;
        newskb->protocol = htons(MY_PROTO_ID);
        //Build the MAC header for the new packet
        // Based on http://lxr.linux.no/#linux+v3.3.4/net/ipv4/arp.c#L586 !
        if (dev_hard_header(newskb,dev,MY_PROTO_ID,&sl.mac,dev->dev_addr,MY_ACK_LEN+ETH_HLEN) < 0) {
            kfree_skb(newskb);
            return -EINVAL;
        }
        //Put the "start" command to the packet
        my_data = skb_put(newskb,2);
        *(my_data++) = 0;
        *(my_data++) = 1;
        my_data = skb_put(newskb,MY_ACK_LEN -2);
        memset(my_data,0xa5,MY_ACK_LEN - 2);
#ifdef FADE_DEBUG
        printk(KERN_INFO "skb_nh: %x, skb_dt: %x, skb_nh2: %x, skb_t: %x\n tail: %d head: %d\n",skb_network_header(newskb),newskb->data,
               newskb->network_header,newskb->tail, sd->tail, sd->head) ;
#endif
        dev_queue_xmit(newskb);
        return SUCCESS;
    }
    case L3_V1_IOC_STOPMAC: //Close the slave and reset it to stop transmission immediately
    {
        struct sk_buff *newskb = NULL;
        char * my_data = NULL;
        write_lock_bh(&slave_table_lock);
        /* Clear the MAC address */
        sd->active = 0;
        memset(&sd->mac,0,ETH_ALEN);
        write_unlock_bh(&slave_table_lock);
        /* Now send the "stop transmission" packet to the slave */
        /* Find the net device */
        if (!sd->dev) return -ENODEV;
        newskb = alloc_skb(LL_RESERVED_SPACE(sd->dev)+MY_ACK_LEN, GFP_ATOMIC);
        skb_reserve(newskb,LL_RESERVED_SPACE(sd->dev));
        skb_reset_network_header(newskb);
        newskb->dev = sd->dev;
        newskb->protocol = htons(MY_PROTO_ID);
        //Build the MAC header for the new packet
        // Based on http://lxr.linux.no/#linux+v3.3.4/net/ipv4/arp.c#L586 !
        if (dev_hard_header(newskb,sd->dev,MY_PROTO_ID,&sd->mac,sd->dev->dev_addr,MY_ACK_LEN+ETH_HLEN) < 0) {
            kfree_skb(newskb);
            return -EINVAL;
        }
        //Put the "stop" command to the packet
        my_data = skb_put(newskb,2);
        *(my_data++) = 0;
        *(my_data++) = 5;
        my_data = skb_put(newskb,MY_ACK_LEN -2);
        memset(my_data,0xa5,MY_ACK_LEN - 2);
#ifdef FADE_DEBUG
        printk(KERN_INFO "skb_nh: %x, skb_dt: %x, skb_nh2: %x, skb_t: %x\n tail: %d head: %d\n",skb_network_header(newskb),newskb->data,
               newskb->network_header,newskb->tail, sd->tail, sd->head) ;
#endif
        dev_queue_xmit(newskb);
        dev_put(sd->dev);
        sd->dev=NULL;
        return SUCCESS;
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
    if (data_available>=sd->rx_wakeup_thr) mask |= POLLIN |POLLRDNORM;
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
        slave_data * sd = &slave_table[i];
        sd->active=0; //Entry not used
        sd->dev=NULL;
        rwlock_init(&sd->maps_rwlock);
        rwlock_init(&sd->pkts_rwlock);
        rwlock_init(&sd->ptrs_lock);
        rwlock_init(&sd->flags_lock);
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
    int res;
    unsigned int set_number;
    unsigned int packet_number;
    int ns; //Number of slave
    slave_data * sd = NULL;
    int set_num_diff;
    unsigned int buf_free = 0;
    char * my_data = NULL;
    unsigned char tmp_buf[USER_HDR_LEN];
    char ack_packet = 0; //Should we acknowledge the packet?
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
        // Here is shown how to build a packet: http://lxr.linux.no/linux+*/net/ipv4/arp.c#L586
        if (dev_hard_header(newskb,dev,MY_PROTO_ID,&rcv_hdr->h_source,&rcv_hdr->h_dest,MY_ACK_LEN+ETH_HLEN) < 0)
            goto error;
        //Put the "restart" command to the packet
        my_data = skb_put(newskb,2);
        *(my_data++) = 0;
        *(my_data++) = 5;
        my_data = skb_put(newskb,MY_ACK_LEN -2);
        memset(my_data,0xa5,MY_ACK_LEN - 2);
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
     * First we check if this is a data packet: */
    if (unlikely((tmp_buf[0] != 0xa5) ||
                 (tmp_buf[1] != 0xa5))) {
        kfree_skb(skb);
        write_lock_bh(&sd->flags_lock);
        sd->err_flag |= FADE_ERR_INCORRECT_PACKET_TYPE;
        write_unlock_bh(&sd->flags_lock);
        return NET_RX_DROP;
    }
    /* Now we check the set number and the packet number:
     PLEASE NOTE, THAT THIS MUST TIGHTLY CORRESPOND
     TO YOUR FPGA IMPLEMENTATION! */
    set_number = (int)tmp_buf[2]*256+tmp_buf[3];
    packet_number = ((int)tmp_buf[4]>>2);
#ifdef FADE_DEBUG
    printk(KERN_INFO "set=%d pkt=%d\n",set_number,packet_number);
#endif
    /* To know if this is a new packet, we compare the set number
    * in the received packet with the expected set number,
    * calculating the difference between those two numbers: */
    read_lock_bh(&sd->pkts_rwlock);
    set_num_diff=(set_number - sd->pkts[packet_number]) & SET_NUMBER_MASK;
    read_unlock_bh(&sd->pkts_rwlock);
    if (likely(set_num_diff==0)) {
        /* This is the expected data packet. */
        int set = -1;
        /* Because we often handle two sets of packets
         simultaneously, we use "set" variable to store the relative set number */
        int needed_space;
        /* We determine the relative set number: 1 or 0 */
        read_lock_bh(&sd->maps_rwlock);
        if (set_number == sd->maps[0].num) set = 0;
        else if (set_number == sd->maps[1].num) set = 1;
        //Set equal to -1 should never happen!
        if (set==-1) {
            printk(KERN_WARNING "Incorrect set number in received packet!\n");
            read_unlock_bh(&sd->maps_rwlock);
            write_lock_bh(&sd->flags_lock);
            sd->err_flag |= FADE_ERR_INCORRECT_SET;
            write_unlock_bh(&sd->flags_lock);
            kfree_skb(skb);
            return NET_RX_DROP;
        }
        /* Now we can calculate how much free space requires this packet
        Amount of space is calculated between the byte after the received packet
        and the byte pointed by the head pointer */
        needed_space = (sd->maps[set].offset + USER_LEN*(packet_number+1) - sd->head) & MY_BUF_LEN_MASK;
        read_unlock_bh(&sd->maps_rwlock); //We stop to use the "maps" table
        read_lock_bh(&sd->ptrs_lock);
        buf_free=( sd->tail - sd->head -1 ) & MY_BUF_LEN_MASK;
#ifdef FADE_DEBUG
        printk(KERN_INFO "Offset: %d packet_nr: %d Free buffer: %d needed space: %d set=%d offset=%d head=%d last=%d\n",
               sd->maps[set].offset, packet_number, buf_free, needed_space,set,sd->maps[set].offset,sd->head,sd->last_pkt);
#endif
        read_unlock_bh(&sd->ptrs_lock);
        if ( buf_free > needed_space ) {
            int ackd_set_nr;
            //Packet fits in the buffer!
            // Length of the payload should be 1024+header???
            if (skb->len != PAYL_LEN) {
                printk(KERN_ERR "Error! Length of data should be %d but is %d!\n",PAYL_LEN, skb->len);
                sd->err_flag |= FADE_ERR_INCORRECT_LENGTH;
                kfree_skb(skb);
                return NET_RX_DROP;
            }
            // We can safely copy all the packet to the buffer:
            // As buffer's boundary never is located in the middle of the packet set,
            // we can simply calculate the begining of the data in the buffer
            // as &sd->buffer[sd->maps[set].offset+USER_LEN*packet_number
            res = skb_copy_bits(skb,USER_HDR_LEN,&sd->buffer[sd->maps[set].offset+USER_LEN*packet_number],USER_LEN);
#ifdef FADE_DEBUG
            printk(KERN_INFO " skb_copy_bits: %d", res);
#endif
            //Packet was copied, so note, that we should confirm it
            if (res>=0) {
                ack_packet=1;
                /* We modify the expected set number for the packet, to modify the
                * pkts table, we must close pkts_rwlock for writing */
                write_lock_bh(&sd->pkts_rwlock);
                ackd_set_nr = (set_number + 1) & SET_NUMBER_MASK;
                sd->pkts[packet_number]= ackd_set_nr;
                if (packet_number == sd->last_pkt) {
                    /* If our packet was the last, which prevented shifting of the head pointer,
                    * we can try now to move the head pointer.
                    * We browse the pkts table, looking for the first uncorfirmed packet.
                    */
                    while ((++(sd->last_pkt)) < PKTS_IN_SET) {
                        if (sd->pkts[sd->last_pkt] != ackd_set_nr) break; //Packet not confirmed
                    }
                    if (sd->last_pkt == PKTS_IN_SET) {
                        /* All packets from the "old" set are received, so we can change
                        * the set_nr
                        */
                        sd->last_pkt = 0;
                        /* Update the maps table. Remove the 0th set, move the 1st to the 0th.
                        * Add the new set as the 1st one */
                        write_lock_bh(&sd->maps_rwlock);
                        memcpy(&sd->maps[0],&sd->maps[1],sizeof(sd->maps[0]));
                        sd->maps[1].num = (sd->maps[1].num + 1) & SET_NUMBER_MASK;
                        sd->maps[1].offset = (sd->maps[1].offset + USER_LEN*PKTS_IN_SET) & MY_BUF_LEN_MASK;
                        write_unlock_bh(&sd->maps_rwlock);
                        /* Now we need to check for confirmed packet from the next set */
                        ackd_set_nr = (ackd_set_nr + 1) & SET_NUMBER_MASK;
                        while (sd->last_pkt <  PKTS_IN_SET) {
                            if (sd->pkts[sd->last_pkt] != ackd_set_nr) break; //Packet not cofirmed
                            else sd->last_pkt++;
                        }
                        write_unlock_bh(&sd->pkts_rwlock);
                    } else {
                        //No need to change packet sets, simply release the lock
                        write_unlock_bh(&sd->pkts_rwlock);
                    }
                    /* Now we can move the head position right after the last serviced packet */
                    write_lock_bh(&sd->ptrs_lock);
                    sd->head = sd->maps[0].offset+sd->last_pkt*USER_LEN;
                    /* When we have moved the head pointer, we can try to wake up the reading processes */
                    wake_up_interruptible(&read_queue);
                    write_unlock_bh(&sd->ptrs_lock);
                } else {
                    // It was not the last packet, no need to move the head pointer
                    write_unlock_bh(&sd->pkts_rwlock);
                }
            }
        }
    } else {
        /* This packet has incorrect set number. If the number is too low, we ignore the packet,
        * but send the confirmation (ack was received too late, or was lost?) */
        if (set_num_diff>(SET_NUMBER/2)) {
            /* In fact it means, that set_num_diff is negative, but we calculate
            * it modulo SET_NUMBER! */
            ack_packet = 1;
#ifdef FADE_DEBUG
            printk(KERN_INFO "Packet already confirmed: pkt=%d set=%d expect=%d last=%d\n",packet_number, set_number, sd->pkts[packet_number], sd->last_pkt);
#endif
        } else {
            /* This is a packet with too high set number (packet "from the future"
            * it my be a symptom of serious communication problem! */
            printk(KERN_ERR "Packet from the future! number: %d expected: %d\n", set_number, sd->pkts[packet_number]);
        }
    }
    //Now send the confirmation
    if (likely(ack_packet)) {
        newskb = alloc_skb(LL_RESERVED_SPACE(dev)+MY_ACK_LEN, GFP_ATOMIC);
        skb_reserve(newskb,LL_RESERVED_SPACE(dev));
        skb_reset_network_header(newskb);
        newskb->dev = dev;
        newskb->protocol = htons(MY_PROTO_ID);
        //Build the MAC header for the new packet
        // Tu http://lxr.linux.no/linux+*/net/ipv4/arp.c#L586 jest pokazane jak zbudować pakiet!
        if (dev_hard_header(newskb,dev,MY_PROTO_ID,&rcv_hdr->h_source,&rcv_hdr->h_dest,MY_ACK_LEN+ETH_HLEN) < 0)
            goto error;
        //Put the "ACKNOWLEDGE" type
        my_data = skb_put(newskb,2);
        *(my_data++) = 0;
        *(my_data++) = 3; //ACK!
        //Copy the begining of the received packet to the acknowledge packet
        my_data = skb_put(newskb,MY_ACK_COPIED);
        res = skb_copy_bits(skb,2,my_data,MY_ACK_COPIED);
        my_data = skb_put(newskb,MY_ACK_LEN -MY_ACK_COPIED-2);
        memset(my_data,0xa5,MY_ACK_LEN - MY_ACK_COPIED-2);
#ifdef FADE_DEBUG
        printk(KERN_INFO " skb_nh: %x, skb_dt: %x, skb_nh2: %x, skb_t: %x\n tail: %d head: %d\n",skb_network_header(newskb),newskb->data,
               newskb->network_header,newskb->tail, sd->tail, sd->head) ;
#endif
        dev_queue_xmit(newskb);
    }
    kfree_skb(skb);
    return NET_RX_SUCCESS;

error:
    if (newskb) kfree_skb(newskb);
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
        return -EBUSY;
        read_unlock_irqrestore(&slave_table_lock,flags);
    }
    //Prepare slave_table for operation
    read_unlock_irqrestore(&slave_table_lock,flags);
    sd->buffer = vmalloc_user(MY_BUF_LEN);
    if (!sd->buffer) return -ENOMEM;
    //Set the MAC address to 0
    memset(sd->mac,0,sizeof(sd->mac));
    sd->head = 0;
    sd->tail = 0;
    sd->err_flag = 0;
    sd->last_pkt = 0;
    sd->rx_wakeup_thr = 1;
    sd->active = 0;
    sd->is_open = 1;
    file->private_data=sd;
    return SUCCESS;
}


static int my_proto1_release(struct inode *inode,
                             struct file *file)
{
    slave_data * sd = file->private_data;
#ifdef FADE_DEBUG
    printk (KERN_INFO "device_release(%p,%p)\n", inode, file);
#endif
    //Release resources associated with servicing of the particular device
    if (sd) {
        if (sd->is_open) {
            sd->is_open = 0; //It can be dangerous! Before freeing the buffer, we must be sure, that
            //no our packet is being processed!
            if (sd->active) {
                sd->active = 0;
            }
            if (sd->buffer) {
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

