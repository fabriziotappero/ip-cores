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
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace EtherLab
{
    /// <summary>
    /// Available channels A to H.
    /// </summary>
    [Flags]
    public enum EChannel : int
    {
        CHANNEL_A = 0,
        CHANNEL_B = 1,
        CHANNEL_C = 2,
        CHANNEL_D = 3,
        CHANNEL_E = 4,
        CHANNEL_F = 5,
        CHANNEL_G = 6,
        CHANNEL_H = 7
    }
}
