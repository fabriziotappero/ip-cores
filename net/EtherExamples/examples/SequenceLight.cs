/******************************************************************************
 * ETHERLAB - FPGA To C# To LABVIEW Bridge                                    *
 ******************************************************************************
 *                                                                            *
 * Copyright (C)2012  Mathias Hörtnagl <mathias.hoertnagl@gmail.com>          *
 *                                                                            *
 * This program is free software: you can redistribute it and/or modify       *
 * it under the terms of the GNU General Public License as published by       *
 * the Free Software Foundation, either version 3 of the License, or          *
 * (at your option) any later version.                                        *
 *                                                                            *
 * This program is distributed in the hope that it will be useful,            *
 * but WITHOUT ANY WARRANTY; without even the implied warranty of             *
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the              *
 * GNU General Public License for more details.                               *
 *                                                                            *
 * You should have received a copy of the GNU General Public License          *
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.      *
 ******************************************************************************/
using System;
using System.Threading;

namespace EtherLab.Examples
{
    /// <summary>
    /// Demonstartes sample usage of EtherLab. Controlls a sequence
    /// light with an EtherLab connection.
    /// </summary>
    class SequenceLight
    {
        static void Main(string[] args)
        {
            /** 
             * Create a new instance of EtherSocket with default 
             * destination MAC. The first parameter identifies the
             * network device to select.
             */
            EtherSocket es = new EtherSocket(0, "00:1f:16:01:95:a5");

            // Indicates, wich LED is on. 
            byte run = 0x01;
            // The current states of the 4 switches.
            ushort switches;

            while (true)
            {   
                // Update channel H (LED).
                es.update(EChannel.CHANNEL_H, run);
                // Send the updated LED data.
                es.send();

                // Read the switch states.
                switches = es.read(EChannel.CHANNEL_H);
                // If rightmost switch is on, rotate right, else left.
                run = set(switches, 0) ? ror(run, 1) : rol(run, 1);

                // Wait, to see the sequence light show happen.
                Thread.Sleep(500);
            }
        }

        /// <summary>
        /// Checks, if bit is set.
        /// </summary>
        /// <param name="val">The bit field.</param>
        /// <param name="bit">The bit to check.</param>
        /// <returns>True, if bit is set.</returns>
        public static Boolean set(ushort val, int bit)
        {
            return (val & (1 << bit)) != 0;
        }

        /// <summary>
        /// Bitwise rotate left.
        /// </summary>
        /// <param name="val">The bit field.</param>
        /// <param name="sh">The number of bits to rotate.</param>
        /// <returns>Left rotated bit field.</returns>
        public static byte rol(byte val, int sh)
        {
            return (byte)(val<<sh | val >> (8 - sh));
        }

        /// <summary>
        /// Bitwise rotate right.
        /// </summary>
        /// <param name="val">The bit field.</param>
        /// <param name="sh">The number of bits to rotate.</param>
        /// <returns>Right rotated bit field.</returns>
        public static byte ror(byte val, int sh)
        {
            return (byte)(val >> sh | val << (8 - sh));
        }
    }
}