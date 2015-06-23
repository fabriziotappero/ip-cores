/*
 * =====================================================================================
 *
 *       Filename:  csa_test.c
 *
 *    Description:  the csa test file
 *
 *        Version:  1.0
 *        Created:  04/16/2009 08:06:34 PM
 *       Revision:  none
 *       Compiler:  gcc
 *
 *         Author:  mengxipeng@gmail.com
 *
 * =====================================================================================
 */



#include <memory.h>
#include <stdlib.h>
#include "misc.h"
#include "imgdev.h"

unsigned char buf[512];

int main()
{
        int i;
        if(img_dev_open()<0)
        {
                DEBUG_LINE("can not open image device");
                return -1; 
        }
        
        for(i=0;i<100;i++)
        {
                int n;
                DEBUG_LINE("i=%d",i);
                n=256-i; 
                img_read_img((unsigned char*)buf,sizeof buf);
                sleep(1);
        }
        img_dev_close();
        return 0;
}

