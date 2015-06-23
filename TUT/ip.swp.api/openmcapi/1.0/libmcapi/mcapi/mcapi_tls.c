/*
 * Copyright (c) 2010, Mentor Graphics Corporation
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 * 1. Redistributions of source code must retain the above copyright notice,
 *    this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright notice,
 *    this list of conditions and the following disclaimer in the documentation
 *    and/or other materials provided with the distribution.
 * 3. Neither the name of the <ORGANIZATION> nor the names of its contributors
 *    may be used to endorse or promote products derived from this software
 *    without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
 * LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 * POSSIBILITY OF SUCH DAMAGE.
 */



#include <openmcapi.h>

/*************************************************************************
*
*   FUNCTION
*
*       mcapi_get64
*
*   DESCRIPTION
*
*       This function takes a memory area and an offset into the area. At
*       this offset, 64bits will be read and returned in the target
*       hardware byte order.
*
*   INPUTS
*
*       unsigned char *ptr      Pointer to the start of the memory area.
*       unsigned int  offset    Offset into memory area to get the 64bits
*                               from.
*
*   OUTPUTS
*
*       unsigned long           The 64bits that were read.
*
************************************************************************/
unsigned long long mcapi_get64(unsigned char *ptr, unsigned int offset)
{
    unsigned char *p = ptr + offset;

    return ((unsigned long long)p[0] << 56) +
           ((unsigned long long)p[1] << 48) +
           ((unsigned long long)p[2] << 40) +
           ((unsigned long long)p[3] << 32) +
           ((unsigned long long)p[4] << 24) +
           ((unsigned long long)p[5] << 16) +
           ((unsigned long long)p[6] << 8) +
            (unsigned long long)p[7];

}

/*************************************************************************
*
*   FUNCTION
*
*       mcapi_put64
*
*   DESCRIPTION
*
*       This function takes a memory area and an offset into the area. At
*       this offset, 64bits will be written in network byte order.
*
*   INPUTS
*
*       unsigned char *ptr      Pointer to the start of the memory area.
*       unsigned int  offset    Offset into memory area to get the 64bits
*                               from.
*       unsigned long value     64bits to be written to memory
*
*   OUTPUTS
*
*       None
*
*************************************************************************/
void mcapi_put64(unsigned char *ptr, unsigned int offset, unsigned long long value)
{
    unsigned char *p = ptr + offset;

    *p++ = (unsigned char)(value >> 56);
    *p++ = (unsigned char)(value >> 48);
    *p++ = (unsigned char)(value >> 40);
    *p++ = (unsigned char)(value >> 32);
    *p++ = (unsigned char)(value >> 24);
    *p++ = (unsigned char)(value >> 16);
    *p++ = (unsigned char)(value >> 8);
    *p = (unsigned char)value;

}

/*************************************************************************
*
*   FUNCTION
*
*       mcapi_get32
*
*   DESCRIPTION
*
*       This function takes a memory area and an offset into the area. At
*       this offset, 32bits will be read and returned in the target
*       hardware byte order.
*
*   INPUTS
*
*       unsigned char *ptr      Pointer to the start of the memory area.
*       unsigned int  offset    Offset into memory area to get the 32bits
*                               from.
*
*   OUTPUTS
*
*       unsigned long           The 32bits that were read.
*
************************************************************************/
unsigned long mcapi_get32(unsigned char *ptr, unsigned int offset)
{
    unsigned char *p = ptr + offset;

    return ((unsigned long)p[0] << 24) +
           ((unsigned long)p[1] << 16) +
           ((unsigned long)p[2] << 8) +
            (unsigned long)p[3];

}

/*************************************************************************
*
*   FUNCTION
*
*       mcapi_put32
*
*   DESCRIPTION
*
*       This function takes a memory area and an offset into the area. At
*       this offset, 32bits will be written in network byte order.
*
*   INPUTS
*
*       unsigned char *ptr      Pointer to the start of the memory area.
*       unsigned int  offset    Offset into memory area to get the 32bits
*                               from.
*       unsigned long value     32bits to be written to memory
*
*   OUTPUTS
*
*       None
*
*************************************************************************/
void mcapi_put32(unsigned char *ptr, unsigned int offset, unsigned long value)
{
    unsigned char *p = ptr + offset;

    *p++ = (unsigned char)(value >> 24);
    *p++ = (unsigned char)(value >> 16);
    *p++ = (unsigned char)(value >> 8);
    *p = (unsigned char)value;

}

/*************************************************************************
*
*   FUNCTION
*
*       mcapi_get16
*
*   DESCRIPTION
*
*       This function takes a memory area and an offset into the area. At
*       this offset, 16bits will be read and returned in the target
*       hardware byte order.
*
*   INPUTS
*
*       unsigned char *ptr      Pointer to the start of the memory area.
*       unsigned int  offset    Offset into memory area to get the 32bits
*                               from.
*
*   OUTPUTS
*
*       unsigned short           The 16bits that were read.
*
************************************************************************/
unsigned short mcapi_get16(unsigned char *ptr, unsigned int offset)
{
    unsigned char *p = ptr + offset;

    return (unsigned short)((p[0] << 8) + p[1]);

}

/*************************************************************************
*
*   FUNCTION
*
*       mcapi_put16
*
*   DESCRIPTION
*
*       This function takes a memory area and an offset into the area. At
*       this offset, 16bits will be written in network byte order.
*
*   INPUTS
*
*       unsigned char *ptr      Pointer to the start of the memory area.
*       unsigned int  offset    Offset into memory area to get the 32bits
*                               from.
*       unsigned short value    16bits to be written to memory
*
*   OUTPUTS
*
*       None
*
************************************************************************/
void mcapi_put16(unsigned char *ptr, unsigned int offset, unsigned short value)
{
    unsigned char *p = ptr + offset;

    *p++ = (unsigned char)(value >> 8);
    *p = (unsigned char)value;

}
