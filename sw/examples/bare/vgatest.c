

/* VGA defines */
#define VMEM           0x01f00000

#define VGA_BASEADDR   0x97000000

#define VGA_CTRL       0x000
#define VGA_STAT       0x004
#define VGA_HTIM       0x008
#define VGA_VTIM       0x00c
#define VGA_HVLEN      0x010
#define VGA_VBARA      0x014 /* Adress to Video Base Register A */
#define VGA_VBARB      0x018 /* Adress to Video Base Register B */
#define VGA_PALETTE    0x800

#define VGA_CTRL_VEN   0x00000001 /* Video Enable */
#define VGA_CTRL_HIE   0x00000002 /* HSync Interrupt Enable */
#define VGA_CTRL_PC    0x00000800 /* 8-bit Pseudo Color Enable*/
#define VGA_CTRL_CD8   0x00000000 /* Color Depth 8 */
#define VGA_CTRL_CD16  0x00000200 /* Color Depth 16 */
#define VGA_CTRL_CD24  0x00000400 /* Color Depth 24 */
#define VGA_CTRL_CD32  0x00000600 /* Color Depth 32 */
#define VGA_CTRL_VBL1  0x00000000 /* Burst Length 1 */
#define VGA_CTRL_VBL2  0x00000080 /* Burst Length 2 */
#define VGA_CTRL_VBL4  0x00000100 /* Burst Length 4 */
#define VGA_CTRL_VBL8  0x00000180 /* Burst Length 8 */

#define GFX_BASEADDR   0xB8000000

#define GFX_CTRL       0x000
#define GFX_STATUS     0x004
#define GFX_PIXEL0     0x008
#define GFX_PIXEL1     0x00c
#define GFX_COLOR      0x010
#define GFX_TARGET_BASE 0x014
#define GFX_TARGET_SIZE 0x018

/* Register access macros */
#define REG8(add) *((volatile unsigned char *)(add))
#define REG16(add) *((volatile unsigned short *)(add))
#define REG32(add) *((volatile unsigned long *)(add))

void Set640x480_60(void)
{
	// Set horizontal timing register
	REG32(VGA_BASEADDR+VGA_HTIM) = ((96 - 1) << 24) |
		      ((48 - 1) << 16) |
		      (640 - 1);
	// Set vertical timing register
	REG32(VGA_BASEADDR+VGA_VTIM) = ((2 - 1) << 24) |
		      ((31 - 1) << 16) |
		      (480 - 1);
	// Set total vertical and horizontal lenghts
	REG32(VGA_BASEADDR+VGA_HVLEN) = ((800 - 1) << 16) | (525 - 1);

	REG32(GFX_BASEADDR+GFX_TARGET_SIZE) = (640 << 16) | 480;
}

void Set800x600_60(void)
{
	// Set horizontal timing register
	REG32(VGA_BASEADDR+VGA_HTIM) = ((128 - 1) << 24) |
		      ((88 - 1) << 16) |
		      (800 - 1);
	// Set vertical timing register
	REG32(VGA_BASEADDR+VGA_VTIM) = ((4 - 1) << 24) |
		      ((23 - 1) << 16) |
		      (600 - 1);
	// Set total vertical and horizontal lenghts
	REG32(VGA_BASEADDR+VGA_HVLEN) = ((1056 - 1) << 16) | (628 - 1);

	REG32(GFX_BASEADDR+GFX_TARGET_SIZE) = (800 << 16) | 600;
}

void Set1024x768_60(void)
{
	// Set horizontal timing register
	REG32(VGA_BASEADDR+VGA_HTIM) = ((136 - 1) << 24) |
		      ((160 - 1) << 16) |
		      (1024 - 1);
	// Set vertical timing register
	REG32(VGA_BASEADDR+VGA_VTIM) = ((6 - 1) << 24) |
		      ((29 - 1) << 16) |
		      (768 - 1);
	// Set total vertical and horizontal lenghts
	REG32(VGA_BASEADDR+VGA_HVLEN) = ((1344 - 1) << 16) | (806 - 1);

	REG32(GFX_BASEADDR+GFX_TARGET_SIZE) = (1024 << 16) || 768;
}

void drawPixel(int x, int y, int color);

int main(void)
{
	// Reset VGA first
	REG32(VGA_BASEADDR+VGA_CTRL) = 0;
	
	// Set video mode
	Set640x480_60();
//	Set800x600_60();

	// Set color depth (start with 8bit grayscale!)
//	 | VGA_CTRL_PC;
//	 | VGA_CTRL_CD16;
//	 | VGA_CTRL_CD24;
//	 | VGA_CTRL_CD32;
	
	// Set base address for Video Base Register A
	REG32(VGA_BASEADDR+VGA_VBARA) = VMEM;

	// Set base address for Video Base Register B
	REG32(VGA_BASEADDR+VGA_VBARB) = VMEM;

	REG32(GFX_BASEADDR+GFX_TARGET_BASE) = VMEM;

	// Activate VGA
	REG32(VGA_BASEADDR+VGA_CTRL) = VGA_CTRL_VEN | VGA_CTRL_VBL8 | VGA_CTRL_CD16;
	REG32(GFX_BASEADDR+GFX_CTRL) = 6; // 16 bit cd


//	int z;	for(z=64000; z<100000; z+=4)
//	{
//	REG32(z) = 0x00ff00ff;
//	}

	// Write something to VGA
	int x, y;
	for(y=100; y<200; ++y)
	{
		for(x=50; x<100; x++)
		{
			int addr = (y*320 + x)*4;
			REG32(VMEM+addr) = 0xff00ff00;
		}
	}


	for(y=200; y<300; ++y)
		for(x=200; x<300; x+=2)
			drawPixel(x,y,0xf800f800);

	while(1);

	return 0;
}

void drawPixel(int x, int y, int color)
{
	REG32(GFX_BASEADDR+GFX_PIXEL0) = (x << 16) | y;
	REG32(GFX_BASEADDR+GFX_COLOR) = color;
	REG32(GFX_BASEADDR+GFX_CTRL) |= 1;
	REG32(GFX_BASEADDR+GFX_CTRL) &= ~1;
}
