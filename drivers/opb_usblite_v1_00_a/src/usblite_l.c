/*
--
--    opb_usblite - opb_uartlite replacement
--
--    opb_usblite is using components from Rudolf Usselmann see
--    http://www.opencores.org/cores/usb_phy/
--    and Joris van Rantwijk see http://www.xs4all.nl/~rjoris/fpga/usb.html
--
--    Copyright (C) 2010 Ake Rehnman
--
--    This program is free software: you can redistribute it and/or modify
--    it under the terms of the GNU Lesser General Public License as published by
--    the Free Software Foundation, either version 3 of the License, or
--    (at your option) any later version.
--
--    This program is distributed in the hope that it will be useful,
--    but WITHOUT ANY WARRANTY; without even the implied warranty of
--    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--    GNU Lesser General Public License for more details.
--
--    You should have received a copy of the GNU Lesser General Public License
--    along with this program.  If not, see <http://www.gnu.org/licenses/>.
--
*/
#include "usblite_l.h"

/******************************************************************************/
void usblite_SendByte(unsigned int base, unsigned char data)
{
    while (usblite_mIsTransmitFull(base));

    usblite_out32(base + XUL_TX_FIFO_OFFSET, data);
}


/****************************************************************************/
unsigned char usblite_RecvByte(unsigned int base)
{
    while (usblite_mIsReceiveEmpty(base));

    return (unsigned char)usblite_in32(base + XUL_RX_FIFO_OFFSET);
}

