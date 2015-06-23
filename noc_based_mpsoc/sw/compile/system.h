#ifndef SYSTEM_H
	#define SYSTEM_H
	//define base addresses	
	#define RAM_BASE			0x00000000
	#define	NOC_BASE			0x40000000	
	#define	GPIO_BASE			0x41000000
	#define EXT_INT_BASE			0x42000000
	#define TIMER_BASE			0x43000000
	#define INT_CTRL_BASE			0x44000000	
	
	//GPIO
	#define GPIO_ADDR_TYPE_START		5
	#define GPIO_ADDR_PORT_WIDTH		5
	#define GPIO_ADDR_REG_WIDTH		5


	#define GPIO_IO_TYPE_NUM		0
	#define GPIO_I_TYPE_NUM			4
	#define GPIO_O_TYPE_NUM			8

	#define GPIO_DIR_REG			0
	#define GPIO_WRITE_REG			4
	#define GPIO_READ_REG			8

	
	#define GPIO_TYPE_LOC_START		(GPIO_ADDR_REG_WIDTH + GPIO_ADDR_PORT_WIDTH)
	#define GPIO_PORT_LOC_START		(GPIO_ADDR_REG_WIDTH+2)

	
	#define	GPIO_IO_BASE			(GPIO_BASE  + (GPIO_IO_TYPE_NUM		<<	GPIO_TYPE_LOC_START))
	#define GPIO_I_BASE			(GPIO_BASE  + (GPIO_I_TYPE_NUM		<<	GPIO_TYPE_LOC_START))
	#define GPIO_O_BASE			(GPIO_BASE  + (GPIO_O_TYPE_NUM		<<	GPIO_TYPE_LOC_START))

	#define gpio_io_dir_reg(port_num)	(*((volatile unsigned int *)  (GPIO_IO_BASE+(port_num << GPIO_PORT_LOC_START)+GPIO_DIR_REG)))
	#define gpio_io_wr_reg(port_num)	(*((volatile unsigned int *)  (GPIO_IO_BASE+(port_num << GPIO_PORT_LOC_START)+GPIO_WRITE_REG)))
	#define gpio_io_rd_reg(port_num)	(*((volatile unsigned int *)  (GPIO_IO_BASE+(port_num << GPIO_PORT_LOC_START)+GPIO_READ_REG)))	
	#define gpio_o_wr_reg(port_num)		(*((volatile unsigned int *)  (GPIO_O_BASE+(port_num << GPIO_PORT_LOC_START)+GPIO_WRITE_REG))) 
	#define gpio_i_rd_reg(port_num)		(*((volatile unsigned int *)  (GPIO_I_BASE+(port_num << GPIO_PORT_LOC_START)+GPIO_READ_REG)))		

	#define gpio_io_dir(port_num,val)	gpio_io_dir_reg(port_num)=val
	#define gpio_io_wr(port_num,val)	gpio_io_wr_reg(port_num)=val
	#define gpio_o_wr(port_num,val)		gpio_o_wr_reg(port_num)=val

	//EXT_INT
	#define EXT_INT_GER	   		(*((volatile unsigned int *) (EXT_INT_BASE	)))
	#define EXT_INT_IER_RISE		(*((volatile unsigned int *) (EXT_INT_BASE+4	)))
	#define EXT_INT_IER_FALL		(*((volatile unsigned int *) (EXT_INT_BASE+8	)))
	#define EXT_INT_ISR 			(*((volatile unsigned int *) (EXT_INT_BASE+12	)))
	#define EXT_INT_RD   			(*((volatile unsigned int *) (EXT_INT_BASE+16	)))
	
	
	

	//TIMER
	
	#define TCSR0	   			(*((volatile unsigned int *) (TIMER_BASE	)))
		
/*
//timer control register
TCSR0
bit
6-3	:	clk_dev_ctrl
3	:	timer_isr
2	:	rst_on_cmp_value
1	:	int_enble_on_cmp_value
0	:	timer enable 
*/	
	#define TLR0	   			(*((volatile unsigned int *) (TIMER_BASE+4	)))
	#define TCMP0	   			(*((volatile unsigned int *) (TIMER_BASE+8	)))
	
	#define TIMER_EN			(1 << 0)
	#define TIMER_INT_EN			(1 << 1)
	#define TIMER_RST_ON_CMP		(1 << 2)
	

	//INT CONTROLLER

	#define INTC_MER			(*((volatile unsigned int *) (INT_CTRL_BASE	)))
	#define INTC_IER			(*((volatile unsigned int *) (INT_CTRL_BASE+4	)))
	#define INTC_IAR			(*((volatile unsigned int *) (INT_CTRL_BASE+8	)))
	#define INTC_IPR			(*((volatile unsigned int *) (INT_CTRL_BASE+12	)))
	
	#define NI_INT				(1 << 0)
	#define TIMER_INT			(1 << 1)
	#define EXT_INT				(1 << 2)
	
	//SHARED RAM 
	#define RAM_X 				2
	#define RAM_Y				2
	#define RAM_ADDR 			core_addr(RAM_X, RAM_Y) 	


	//NOC 
	#define X_Y_ADDR_WIDTH_IN_HDR		4
	#define NI_PTR_WIDTH			19
	#define	NI_PCK_SIZE_WIDTH		13

	#define	NIC_WR_DONE_LOC			(1<<0)
	#define	NIC_RD_DONE_LOC			(1<<1)
	#define NIC_RD_OVR_ERR_LOC		(1<<2)
	#define	NIC_RD_NPCK_ERR_LOC		(1<<3)
	#define	NIC_HAS_PCK_LOC			(1<<4)
	#define	NIC_ISR				(1<<5)
		

	#define NIC_RD			   	(*((volatile unsigned int *) (NOC_BASE	)))
	#define NIC_WR			   	(*((volatile unsigned int *) (NOC_BASE+4)))
	#define NIC_ST	   			(*((volatile unsigned int *) (NOC_BASE+8)))

	

	#define core_addr(DES_X, DES_Y)		((DES_X << X_Y_ADDR_WIDTH_IN_HDR) + DES_Y)<<(32-3-(2*X_Y_ADDR_WIDTH_IN_HDR))	
	
	#define wait_for_sending_pck()		while (!(NIC_ST & NIC_WR_DONE_LOC))
	#define wait_for_reading_pck()		while (!(NIC_ST & NIC_RD_DONE_LOC))

	#define wait_for_getting_pck()		while (!(NIC_ST & NIC_HAS_PCK_LOC))

/*****************************************
void  send_pck (unsigned int * pck_buffer, unsigned int data_size);
sending a packet through NoC network;
(unsigned int des_x,unsigned int des_y : destination core address;
unsigned int * pck_buffer : the buffer which hold the packet; The data must start from buff[1];
unsigned int data_size     : the size of data which wanted to be sent out in word = packet_size-1;
unsigned int flags   : (ack_flag <<1) | wr_flag; must be set just for ram only

****************************************/
	inline void  send_pck (unsigned int des_x,unsigned int des_y,unsigned int * pck_buffer, unsigned int data_size, unsigned int flags){
		pck_buffer [0]		= 	core_addr(des_x, des_y) | flags ;
		NIC_WR = (unsigned int) (& pck_buffer [0]) + (data_size<<NI_PTR_WIDTH);
		wait_for_sending_pck();

	}

/*******************************************
void  save_pck	(unsigned int * pck_buffer, unsigned int buffer_size);
save a received packet on pck_buffer
unsigned int * pck_buffer: the buffer for storing the packet; The read data start from buff[1]; 
********************************************/
	inline void  save_pck	(unsigned int * pck_buffer, unsigned int buffer_size){
		NIC_RD = (unsigned int) (& pck_buffer [0]) + (buffer_size<<NI_PTR_WIDTH);
		wait_for_reading_pck();
	}
	

/**************************
void write_on_ram_with_ack(unsigned int * buffer, unsigned int start_address,unsigned int size);
write a block of data on shared ram. The command wait until the ack packet is received.  
unsigned int * buffer : the buffer which holding the write data. The write packet start from buff[2];
unsigned int start_address : the shared ram start address which the write packet is going to be written; 
unsigned int size: the size of packet in word
**************************/
void write_on_ram_with_ack(unsigned int * buffer, unsigned int start_address,unsigned int size){
	unsigned int ack_buff[3];	
	buffer[1] = start_address;	
	send_pck (RAM_X,RAM_Y,buffer,size+1,0x3);	//send write request packet
	wait_for_getting_pck();		//wait for ack paket from sdram
	save_pck (ack_buff,3);
}

/**************************
void write_on_ram_no_ack(unsigned int * buffer, unsigned int start_address,unsigned int size);
write a block of data on shared ram. The command wait until the write packet is sent out from ni.  
unsigned int * buffer : the buffer which holding the write data. The write packet start from buff[2];
unsigned int start_address : the shared ram start address which the write packet is going to be written; 
unsigned int size: the size of write data in word
**************************/
void write_on_ram_no_ack(unsigned int * buffer, unsigned int start_address,unsigned int size){
	buffer[1] = start_address;
	send_pck (RAM_X,RAM_Y,buffer,size+1,0x1);	//send write request packet
	
}

/**************************
void read_from_ram(unsigned int * buffer,unsigned int start_address,unsigned int size );
read a block of data from shared ram. The command wait until the read packet is saved on buffer.  
unsigned int * buffer : the buffer for storing the read data. The read data start from buff[1];
unsigned int start_address : the shared ram start address of read data in word; 
unsigned int size: the size of read data in word
**************************/


void read_from_ram(unsigned int * buffer,unsigned int start_address,unsigned int size ){
	buffer[1] = start_address;
	buffer[2] = size;
	send_pck (RAM_X,RAM_Y,buffer,2,0x00);
	wait_for_getting_pck();
	save_pck (buffer,size+1);
}




#endif
