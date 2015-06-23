/*
 * load_ihex.h
 *
 *  Created on: Feb 15, 2011
 *      Author: hutch
 */

#ifndef LOAD_IHEX_H
#define LOAD_IHEX_H

#include <stdint.h>

int load_ihex (char *filename, uint8_t *buffer, int max);

#endif

