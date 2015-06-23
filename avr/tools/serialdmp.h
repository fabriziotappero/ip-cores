
#define BAUDRATE B9600
#define DEVICE "/dev/ttyS0"

void getdata(char* data, unsigned char length);

/* Setup device
 */
int serialinit();
void serialuninit();
