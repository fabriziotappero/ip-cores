struct i2c_type
{
    unsigned char address;
    unsigned char pointer;
    unsigned short data;
};

struct i2c_mode
{
    unsigned char read_write;
    unsigned char byte_word;
    unsigned char ptr_set;
};

typedef struct i2c_type i2c_type;
typedef struct i2c_mode i2c_mode;



void i2c_init(void);
void i2c_irq(void);

i2c_type * i2c_get(void);                           //return pointer to first non read received data

void i2c_set_ack_lvl(int ack_lvl, int final_ack_lvl);
int i2c_trans(i2c_mode * mode, i2c_type * data);   //return (-1) or length (still processing previous) or asserted

#define I2C_BUF_LEN		10
#define I2C_PRESC_LO		0x00
#define I2C_PRESC_HI		0x01

#define I2C_CTR			0x02

#define I2C_TXR			0x03
#define I2C_RXR			0x03

#define I2C_CR			0x04
#define I2C_SR			0x04

//BITS
#define I2C_CTR_EN		0x80
#define I2C_CTR_IRQ_EN		0x40

#define I2C_TXR_ADR		0xFE
#define I2C_TXR_W		0x00
#define I2C_TXR_R		0x01

#define I2C_CR_STA		0x80
#define I2C_CR_STO		0x40
#define I2C_CR_RD		0x20
#define I2C_CR_WR		0x10
#define I2C_CR_ACK		0x00
#define I2C_CR_NACK		0x08
#define I2C_CR_CLR_IRQ		0x01

#define I2C_SR_R_ACK		0x80
#define I2C_SR_BUSY		0x40
#define I2C_SR_ARB_LOST		0x20
#define I2C_SR_TX_BUSY		0x02
#define I2C_SR_IRQ_FLAG		0x01
