/******************************************************************************
 * void - Bootloader Version 0.2.2                                            *
 ******************************************************************************
 * Copyright (C)2011  Mathias Hörtnagl <mathias.hoertnagl@gmail.com>          *
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
#include "ui.h"

#ifndef _VIEW_H
#define _VIEW_H

/******************************************************************************
 * Error Messages                                                             *
 ******************************************************************************/
Message errFlashNotReady = {
   ID_MESSAGE,
   {0,0},
   "Flash is not ready, although it should be."
};

Message errFlashState = {
   ID_MESSAGE,
   {0,0},
   "Flash is in an errorous state. Please restart."
};

Message errErrorFlashSize = {
   ID_MESSAGE,
   {0,0},
   "Image size exceeds available flash memory."
};

Message errErrorFlashLocked = {
   ID_MESSAGE,
   {0,0},
   "Flash block is locked."
};

Message errErrorFlashWrite = {
   ID_MESSAGE,
   {0,0},
   "Could not write to flash."
};

Message errErrorFlashErase = {
   ID_MESSAGE,
   {0,0},
   "Could not erase flash block."
};

/******************************************************************************
 * Upload View                                                                *
 ******************************************************************************/
Message msgUploadErase = {
   ID_MESSAGE,
   {0,0},
   "Erasing flash contents ..."
};

Message msgUploadWait = {
   ID_MESSAGE,
   {0,0},
   "Waiting for incoming transmission ..."
};

Message msgUploadWrite = {
   ID_MESSAGE,
   {0,0},
   "Uploading data ..."
};

ProgressBar pbUpload = {
   ID_PROGRESS_BAR,
   {0,1},
   0
};

Window wUpload = {
   {16, 12, 68, 6},
   {WHITE, BLACK},
   "Image Upload",
   2,
   {&msgUploadWait, &pbUpload}
};


/******************************************************************************
 * DDR Upload View                                                            *
 ******************************************************************************/
Message msgUploadDDR = {
   ID_MESSAGE,
   {0,0},
   "Loading DDR ..."
}; 
 
Window wDDRUpload = {
   {16, 12, 68, 6},
   {WHITE, BLACK},
   "DDR Load",
   2,
   {&msgUploadDDR, &pbUpload}
};

/******************************************************************************
 * Memory View                                                                *
 ******************************************************************************/
Window wFlashMemory = {
   {1, 1, 98, 15},
   {YELLOW, BLACK},
   "Flash Memory",
   0,
   NULL
};

Window wDDRMemory = {
   {1, 17, 98, 15},
   {YELLOW, BLACK},
   "DDR Memory",
   0,
   NULL
};


/******************************************************************************
 * Boot View                                                                  *
 ******************************************************************************/
#define OPTION_UPLOAD    0
#define OPTION_MEMORY    1
#define OPTION_START     2

MenuItem menuUpload = {
   "Upload image ..."
};

MenuItem menuMemory = {
   "View memory contents ..."
};

MenuItem menuStart = {
   "Start ..."
};

Menu menu = {
   ID_MENU,
   {0,0},
   OPTION_UPLOAD,
   3,
   { &menuUpload, &menuMemory, &menuStart }
};

Window wBoot = {
   {25, 12, 50, 7},
   {WHITE, BLACK},
   "void Bootloader v0.2.2",
   1,
   { &menu }
};

#endif