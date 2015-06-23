/**
   Standard I/O adresses
*/

void outbyte(char c);
char inbyte();

void outbyte(char c)
{
    volatile char *COUT = (char *) 0xFFFFFFC0;
    *COUT = c;
}

char inbyte()
{
    volatile char *CIN = (char *) 0xFFFFFFC0;
    return (char) *CIN;
}
