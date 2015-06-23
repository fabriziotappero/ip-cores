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
#include "ui.h"

/* A container for all Error Windows.
   Used by 'void drawErrorWindow(Message *errmsg)'. */
static Window wError = {
   {25, 12, 50, 5},
   {RED, BLACK},
   "FATAL ERROR",
   1,
   NULL
};

/******************************************************************************
 * Pattern Functions                                                          *
 ******************************************************************************/

/* Print a single character multiple times. */
void putnc(const uchar c, uchar n) {
   for(uchar i=0; i++ < n; putc(c));
}

/* Print character l once. Print character c  multiple times. Print r once. */
void putlrnc(const uchar l, const uchar c, const uchar r, uchar n) {
   putc(l); putnc(c, n-2); putc(r);
}

/******************************************************************************
 * Windows                                                                    *
 ******************************************************************************/
/* Draws a Window. */
void drawWindow(Window *win) {

   uchar rb = win->box.x + win->box.w - 1;     // Right border position.
   uchar lb = win->box.y + win->box.h - 1;     // Lower border position.

   setcolor(win->col.fg, win->col.bg);

   // Print upper horizontal border.
   gotoxy(win->box.x, win->box.y);
   putlrnc(
      DOUBLE_UPPER_LEFT,
      DOUBLE_HORIZONTAL,
      DOUBLE_UPPER_RIGHT,
      win->box.w
   );

   // Draw vertical left and right border.
   gotoxy(win->box.x, win->box.y + 1);
   putlrnc(DOUBLE_VERTICAL, ' ', DOUBLE_VERTICAL, win->box.w);

   // Draw the title.
   gotoxy(win->box.x + 2, win->box.y + 1); puts(win->title);

   // Print divider between header and contents plane.
   gotoxy(win->box.x, win->box.y + 2);
   putlrnc(
      DOUBLE_DOUBLE_T_LEFT,
      DOUBLE_HORIZONTAL,
      DOUBLE_DOUBLE_T_RIGHT,
      win->box.w
   );

   // Print vertical left and right border.
   for(uchar i = win->box.y + 3; i < lb; i++) {
      gotoxy(win->box.x, i);
      putc(DOUBLE_VERTICAL);
      gotoxy(rb, i);
      putc(DOUBLE_VERTICAL);
   }

   // Print lower horizontal border.
   gotoxy(win->box.x, lb);
   putlrnc(
      DOUBLE_LOWER_LEFT,
      DOUBLE_HORIZONTAL,
      DOUBLE_LOWER_RIGHT,
      win->box.w
   );

   // Draw contents components.
   drawComponents(win);

   setcolor(WHITE, BLACK);
}

/* Draw all the contents of the Window 'win'. */
void drawComponents(Window *win) {

   WindowItem *item;

   for(uchar i = 0; i < win->itemc; i++) {

      item = (WindowItem *) win->itemv[i];

      switch(item->id) {
         case ID_MESSAGE:
            drawMessage(win, (Message *) item);
            break;
         case ID_MENU:
            drawMenu(win, (Menu *) item);
            break;
         case ID_PROGRESS_BAR:
            drawProgressBar(win, (ProgressBar *) item);
            break;
         default:
            break;
      }
   }
}

/* Prints an Error Message Window. The window is always 'wError' defined in this
   file. The function set the Boxes width and x-axis according to the message
   length. The message should not exceed 96 characters. */
void drawErrorWindow(Message *errmsg) {

   uchar w = strlen(errmsg->msg) + 4;

   // Clean screen. we only want to display the errror message.
   cls();

   // Adjust the Error Box size according to message size.
   wError.box.w = w;
   wError.box.x = (100 - w) / 2;
   wError.itemv[0] = errmsg;

   drawWindow(&wError);
}


/******************************************************************************
 * Message                                                                    *
 ******************************************************************************/
/* Draws a simple text message.
   Or override an existing Message, by setting the same relativ position of the
   new Message 'msg' like the old message. */
void drawMessage(Window *win, Message *msg) {

   uint len = strlen(msg->msg);
   uint width = win->box.w - len - msg->pos.x;

   gotoxy(win->box.x + msg->pos.x + 1, win->box.y + msg->pos.y + 3);
   putc(' '); puts(msg->msg); putnc(' ', width - 3);
}


/******************************************************************************
 * Progress Bar                                                               *
 ******************************************************************************/
/* Draws a Progress Bar element.
   The value 'ProgressBar.val' must be between 0 and 63. The Window should be
   therefor 68 wide. */
void drawProgressBar(Window *win, ProgressBar *bar) {

   //uint width = win->box.w - bar->pos.x - 3;
   //uint factor = div( mul(bar->val, width), bar->max );

   gotoxy(win->box.x + bar->pos.x + 2, win->box.y + bar->pos.y + 3);

   // for(uint i=0; i < width; i++) {
      // if(i <= factor)
         // putc(SQUARE_BOX);
      // else
         // putc(' ');
   // }

   putnc(SQUARE_BOX, bar->val);
   putnc(' ', 64 - bar->val);
}


/******************************************************************************
 * Menus                                                                      *
 ******************************************************************************/
/* Redraw the Menu by selecting the next element of the MenuItems and set
   'menu.index' acordingly.
   If the current selected MenuItem is 'menu.itemv[menu.itemc-1]' the next
   MenuItem will be 'menu.itemv[0]'. */
void menuKeyDown(Window *win, Menu *menu) {

   if(menu->index == menu->itemc - 1)
      menu->index = 0;
   else
      menu->index++;

   drawMenu(win, menu);
}

/* Redraw the Menu by selecting the previous element of the MenuItems and set
   'menu.index' acordingly.
   If the current selected MenuItem is 'menu.itemv[0]' the next MenuItem will be
   'menu.itemv[menu.itemc-1]'. */
void menuKeyUp(Window *win, Menu *menu) {

   if(menu->index == 0)
      menu->index = menu->itemc - 1;
   else
      menu->index--;

   drawMenu(win, menu);
}

/* Draws a vertical menu. */
void drawMenu(Window *win, Menu *menu) {

   MenuItem *item;
   cursor pos;
   uint len;
   uint width;

   pos.x = win->box.x + menu->pos.x + 1;
   pos.y = win->box.y + menu->pos.y + 3;
   width = win->box.w - menu->pos.x;

   for(uchar idx = 0; idx < menu->itemc; idx++) {

      gotoxy(pos.x, pos.y + idx);

      item = menu->itemv[idx];
      len = strlen(item->name);

      if(menu->index == idx) {

         // Invert color scheme for selected items.
         setcolor(win->col.bg, win->col.fg);

         putc(VERTICAL_BLOCK_LEFT);
         puts(item->name); putnc(' ', width - len - 4);
         putc(VERTICAL_BLOCK_RIGHT);

         // Reset color options to default.
         setcolor(win->col.fg, win->col.bg);
      }
      else {
         putc(' '); puts(item->name); putnc(' ', width - len - 3);
      }
   }
}

