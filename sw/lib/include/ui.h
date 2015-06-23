/******************************************************************************
 * User Interface                                                             *
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
//#include "stddef.h"
#include "stdio.h"
#include "stdlib.h"

#ifndef _UI_H
#define _UI_H

/******************************************************************************
 * Box Drawing Constants                                                      *
 ******************************************************************************/
#define DOUBLE_UPPER_RIGHT       0xbb
#define DOUBLE_UPPER_LEFT        0xc9
#define DOUBLE_LOWER_RIGHT       0xbc
#define DOUBLE_LOWER_LEFT        0xc8
#define DOUBLE_HORIZONTAL        0xcd
#define DOUBLE_VERTICAL          0xba

#define DOUBLE_DOUBLE_T_LEFT     0xcc
#define DOUBLE_DOUBLE_T_RIGHT    0xb9

#define VERTICAL_BLOCK_LEFT      0xdd
#define VERTICAL_BLOCK_RIGHT     0xde


/******************************************************************************
 * Various Character Constants                                                *
 ******************************************************************************/
#define FULL_BOX                 0xdb
#define SQUARE_BOX               0xfe



/******************************************************************************
 * Window                                                                     *
 ******************************************************************************/
/* Window component identification integers. */
#define ID_MESSAGE         0x00
#define ID_MENU            0x01
#define ID_PROGRESS_BAR    0x02

/* Super class for all Window components. Each component struct contains this
   three variables at the beginning.
   The location struct 'pos' is the relative position of the item within a
   Window. */
typedef struct _WindowItem {
   uchar id;
   cursor pos;
} WindowItem;

/* Represents a Contents Box. Origin is top lefft corner. */
typedef struct _Box {
   uchar x;
   uchar y;
   uchar w;                            // Width (+ 2 for borders).
   uchar h;                            // Height (+ 2 for borders).
} Box;

/* A Window is a Box with a double line border and a Window title. The fore-
   ground and background colors can be specified.
   The array itemv[] contains pointers to contents elements such as Messages,
   Menus or ProgessBars. The integer itemc is the size of this array and must be
   set manually by the programmer. */
typedef struct _Window {
   Box box;                            // Spatial dimensions.
   color col;
   uchar *title;                       // Window title.
   uchar itemc;                        // Number of contetnts objects.
   void *itemv[];                      // Contents objects of the window.
} Window;


/******************************************************************************
 * Message                                                                    *
 ******************************************************************************/
/* A simple text string.
   For a Message, 'id' must be 'ID_MESSAGE'. */
typedef struct _Message {
   uchar id;
   cursor pos;
   uchar *msg;
} Message;


/******************************************************************************
 * Progress Bar                                                               *
 ******************************************************************************/
/* A simple progress bar.
   For a Message, 'id' must be 'ID_PROGRESS_BAR'. */
typedef struct _ProgressBar {
   uchar id;
   cursor pos;
   // uint max;
   uint val;
} ProgressBar;


/******************************************************************************
 * Menu                                                                       *
 ******************************************************************************/
typedef struct _MenuItem {
   uchar *name;
} MenuItem;

/* A vertical menu, where 'itemv[]' is a array of MenuItems and 'itemc' its
   size. The member 'index' inidactes the current selected MenuItem, where 0
   menas the first entry of the Menu.
   For a Message, 'id' must be 'ID_MENU'. */
typedef struct _Menu {
   uchar id;
   cursor pos;
   uchar index;
   uchar itemc;
   MenuItem *itemv[];
} Menu;



/******************************************************************************
 * Windows                                                                    *
 ******************************************************************************/
/* Draws a Window. */
extern void drawWindow(Window *win);

/* Prints an Error Message Window. The window is always 'wError' defined in this
   file. The function set the Boxes width and x-axis according to the message
   length. The message should not exceed 96 characters. */
extern void drawErrorWindow(Message *errmsg);


/******************************************************************************
 * Message                                                                    *
 ******************************************************************************/
/* Draws a simple text message.
   Or override an existing Message, by setting the same relativ position of the
   new Message 'msg' like the old message. */
extern void drawMessage(Window *win, Message *msg);


/******************************************************************************
 * Progress Bar                                                               *
 ******************************************************************************/
/* Draws a Progress Bar element.
   The value 'ProgressBar.val' must be between 0 and 63. The Window should be
   therefor 68 wide. */
extern void drawProgressBar(Window *win, ProgressBar *bar);


/******************************************************************************
 * Menus                                                                      *
 ******************************************************************************/
/* Redraw the Menu by selecting the next element of the MenuItems and set
   'menu.index' acordingly.
   If the current selected MenuItem is 'menu.itemv[menu.itemc-1]' the next
   MenuItem will be 'menu.itemv[0]'. */
extern void menuKeyDown(Window *win, Menu *menu);

/* Redraw the Menu by selecting the previous element of the MenuItems and set
   'menu.index' acordingly.
   If the current selected MenuItem is 'menu.itemv[0]' the next MenuItem will be
   'menu.itemv[menu.itemc-1]'. */
extern void menuKeyUp(Window *win, Menu *menu);

#endif