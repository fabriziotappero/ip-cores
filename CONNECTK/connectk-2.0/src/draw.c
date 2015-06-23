
/*

connectk -- a program to play the connect-k family of games
Copyright (C) 2007 Michael Levin

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

*/

#include "config.h"
#include <gtk/gtk.h>
#include <cairo.h>
#ifndef NO_CAIRO_SVG
#include <cairo-svg.h>
#endif
#include <string.h>
#include <math.h>
#include "shared.h"
#include "connectk.h"

/*
 *      Rendering
 */

typedef unsigned int PCOORD;

static GtkWidget *drawing_area = NULL;
static GdkPixmap *pixmap = NULL;
static cairo_t *cairo = NULL;
static PCOORD board_xo = 0, board_yo = 0;
static BCOORD hover_x, hover_y;
static int tile_size = 1;
static gboolean hover = FALSE, playable = TRUE, do_not_dirty = FALSE;
static AIMoves *marks = NULL;
static double marks_min, marks_max;

// Convert from pixel to board coordinates
static gboolean pcoord_to_bcoord(PCOORD px, PCOORD py, BCOORD *bx, BCOORD *by)
{
        if (px < board_xo + tile_size || py < board_yo + tile_size ||
            px >= drawing_area->allocation.width - board_xo - tile_size ||
            py >= drawing_area->allocation.height - board_yo - tile_size)
                return FALSE;
        *bx = (px - board_xo) / tile_size - 1;
        *by = (py - board_yo) / tile_size - 1;
        return TRUE;
}

// Convert from board to pixel coordinates
static void bcoords_to_pcoords(BCOORD bx, BCOORD by, PCOORD *px, PCOORD *py)
{
        *px = (bx + 1) * tile_size + board_xo;
        *py = (by + 1) * tile_size + board_yo;
}

/* Render a colored piece on the pixmap */
static void draw_piece(BCOORD bx, BCOORD by, PIECE type, double a)
{
        PCOORD px, py;

        bcoords_to_pcoords(bx, by, &px, &py);

        /* Render a black and white piece on the pixmap */
        if (opt_grayscale && type != PIECE_NONE) {
                cairo_arc(cairo, px + tile_size / 2, py + tile_size / 2,
                          tile_size / 2 - 2, 0., G_PI * 2.);
                if (type == PIECE_BLACK)
                        cairo_set_source_rgba(cairo, 0, 0, 0, a);
                else
                        cairo_set_source_rgba(cairo, 1, 1, 1, a);
                cairo_fill_preserve(cairo);
                cairo_set_source_rgba(cairo, 0, 0, 0, a);
                cairo_set_line_width(cairo, 2.);
                cairo_stroke(cairo);
        }

        /* Render a colored piece */
        else if (type != PIECE_NONE) {
                double r, g, b, hr, hg, hb;

                if (type == PIECE_WHITE) {
                        r = 0.90;
                        g = 0.85;
                        b = 0.65;
                } else if(type == PIECE_BLACK) {
                        r = 0.15;
                        g = 0.15;
                        b = 0.20;
                } else
                        return;
                hr = r * 2;
                hg = g * 2;
                hb = b * 2;
                if (hr > 1.) hr = 1.;
                if (hg > 1.) hg = 1.;
                if (hb > 1.) hb = 1.;

                // Draw stone body
                cairo_arc(cairo, px + tile_size / 2, py + tile_size / 2,
                          tile_size / 2 - 2, 0., G_PI * 2.);
                cairo_set_source_rgba(cairo, r, g, b, a);
                cairo_fill_preserve(cairo);
                cairo_set_source_rgba(cairo, r / 2, g / 2, b / 2, a);
                cairo_stroke(cairo);

                // Draw stone highlight
                if (a >= 1.) {
                        cairo_arc(cairo, px + tile_size / 3, py + tile_size / 3,
                                  tile_size / 6, 0., G_PI * 2.);
                        cairo_set_source_rgba(cairo, hr, hg, hb, a);
                        cairo_fill(cairo);
                }
        }
        if (!do_not_dirty)
                gtk_widget_queue_draw_area(drawing_area, px, py, tile_size,
                                           tile_size);
}

// Render a marker if (x, y) is a marker tile
static void draw_marker(BCOORD x, BCOORD y)
{
        PCOORD px, py;

        if (piece_at(board, x, y) != PIECE_NONE)
                return;
        if ((board_size > 9) &&
            (x == 3 || x == board_size - 4 ||
             ((board_size & 1) && x == board_size / 2)) &&
            (y == 3 || y == board_size - 4 ||
             ((board_size & 1) && y == board_size / 2))) {
                bcoords_to_pcoords(x, y, &px, &py);
                cairo_set_source_rgba(cairo, 0., 0., 0., 1.);
                cairo_arc(cairo, px + tile_size / 2, py + tile_size / 2,
                          tile_size / 6, 0., G_PI * 2.);
                cairo_fill(cairo);
        }
}

void clear_last_moves(void)
/* Clear last move markers */
{
        Board *b = board;
        int last_moves = place_p - b->moves_left;

        if (!last_moves)
                last_moves = place_p;
        while (b->parent && last_moves--) {
                b = b->parent;
                draw_tile(b->move_x, b->move_y);
        }
}

void draw_last_moves(void)
/* Draw markers on the last p moves in this turn or the whole last turn */
{
        Board *b = board;
        int last_moves = place_p - b->moves_left;

        if (b->won)
                return;
        if (!last_moves)
                last_moves = place_p;
        cairo_save(cairo);
        while (b->parent && last_moves--) {
                PCOORD px, py;

                b = b->parent;
                bcoords_to_pcoords(b->move_x, b->move_y, &px, &py);
                if (opt_grayscale)
                        cairo_set_source_rgba(cairo, 1.f, 1.f, 1., 1.);
                else
                        cairo_set_source_rgba(cairo, 1.f, 1.f, 0., 1.);
                cairo_rectangle(cairo, px + tile_size / 3., py + tile_size / 3.,
                                tile_size / 3., tile_size / 3.);
                cairo_fill_preserve(cairo);
                cairo_set_source_rgba(cairo, 0.f, 0.f, 0., 1.);
                cairo_stroke(cairo);
                gtk_widget_queue_draw_area(drawing_area, px + tile_size / 3.,
                                           py + tile_size / 3., tile_size / 3.,
                                           tile_size / 3.);
        }
        cairo_restore(cairo);
}

static void draw_mark(AIMove *aim)
/* Draw a mark piece */
{
        PCOORD x, y;
        double r = 1., g = 1., b = 0., weight;

        /* Logarithmic scale */
        weight = aim->weight;
        if (opt_mark_log) {
                if (weight > 0.)
                        weight = log(weight);
                else if (weight < 0.)
                        weight = -log(-weight);
        }

        /* Normalized scale */
        if (opt_mark_norm) {
                weight = (weight - marks_min) / (marks_max - marks_min);
                r = 0.4 + 0.6 * weight;
                g = 0.5 - 0.2 * weight;
                b = 0.6 - 0.4 * weight;
        }

        /* Absolute scale */
        else {
                weight /= marks_max;
                if (weight > 0.)
                        r = 1 - weight;
                else if (weight < 0.)
                        g = 1 + weight;
        }

        /* Grayscale */
        if (opt_grayscale)
                r = g = b = 0.2 + weight * 0.6;

        cairo_save(cairo);
        cairo_set_source_rgba(cairo, r, g, b, 0.67);
        bcoords_to_pcoords(aim->x, aim->y, &x, &y);
        cairo_arc(cairo, x + tile_size / 2, y + tile_size / 2,
                  tile_size / 2, 0., G_PI * 2.);
        cairo_fill(cairo);
        gtk_widget_queue_draw_area(drawing_area, x, y, tile_size, tile_size);
        cairo_restore(cairo);
}

void draw_marks(AIMoves *m, int redraw)
/* Set the marks array to a new list of moves and draw it, if any, otherwise
   clear */
{
        AIMoves *old_marks;
        int i;

        old_marks = marks;
        marks = NULL;
        if (old_marks && old_marks != m) {
                if (redraw)
                        for (i = 0; i < old_marks->len; i++)
                                draw_tile(old_marks->data[i].x,
                                          old_marks->data[i].y);
                aimoves_free(old_marks);
        }
        if (m) {
                marks = m;
                marks_min = AIW_LOSE;
                marks_max = AIW_WIN;

                /* Find maximum weighted move */
                if (opt_mark_norm && marks->len) {
                        AIWEIGHT min, max;

                        aimoves_range(marks, &min, &max);
                        marks_min = min;
                        marks_max = max;
                }

                if (opt_mark_log) {
                        if (marks_min > 0)
                                marks_min = log(marks_min);
                        else if (marks_min < 0)
                                marks_min = -log(-marks_min);
                        if (marks_max > 0)
                                marks_max = log(marks_max);
                        else if (marks_max < 0)
                                marks_max = -log(-marks_max);
                }
                if (redraw)
                        for (i = 0; i < marks->len; i++)
                                draw_mark(marks->data + i);
        }
}

void sum_of_marks(void)
/* Test function to sum up the marked piece weights */
{
        AIWEIGHT total = 0;
        int i;

        if (!marks)
                return;
        for (i = 0; i < marks->len; i++)
                total += marks->data[i].weight;
        g_debug("marks total to %d", total);
}

// Render a tile on the pixmap
void draw_tile(BCOORD bx, BCOORD by)
{
        PCOORD px, py, px_mid, py_mid;
        PIECE piece;
        int i;

        bcoords_to_pcoords(bx, by, &px, &py);
        cairo_save(cairo);

        // Draw tile background
        cairo_rectangle(cairo, px, py, tile_size, tile_size);
        if (opt_grayscale)
                cairo_set_source_rgba(cairo, 1., 1., 1., 1.);
        else
                cairo_set_source_rgba(cairo, 0.9, 0.8, 0.4, 1.);
        cairo_fill(cairo);

        // Draw tile cross
        px_mid = px + tile_size / 2;
        py_mid = py + tile_size / 2;
        cairo_set_line_width(cairo, 1.5);
        cairo_move_to(cairo, px_mid, by ? py : py_mid - 1);
        cairo_line_to(cairo, px_mid,
                      by == board_size - 1 ? py_mid + 1: py + tile_size);
        cairo_move_to(cairo, bx? px : px_mid - 1, py_mid);
        cairo_line_to(cairo, bx == board_size - 1 ? px_mid + 1: px + tile_size,
                      py + tile_size / 2);
        cairo_set_source_rgba(cairo, 0., 0., 0., 1.);
        cairo_stroke(cairo);

        cairo_restore(cairo);

        /* Draw grid marker */
        draw_marker(bx, by);

        /* Draw piece or piece mark */
        piece = piece_at(board, bx, by);
        if (piece == PIECE_NONE && (i = aimoves_find(marks, bx, by)) >= 0)
                draw_mark(marks->data + i);
        else
                draw_piece(bx, by, piece, 1.);
}

/* Print centered text */
static void center_print(double x, double y, const char *str)
{
        cairo_text_extents_t te;
        size_t len;

        len = strlen(str);
        cairo_text_extents(cairo, str, &te);
        cairo_move_to(cairo, x - te.width / 2, y + te.width / len / 2);
        cairo_show_text(cairo, str);
}

void draw_win(void)
/* Draw a line to indicate the winning line on the current board */
{
        PCOORD x1, y1, x2, y2, tmp;

        if (!board->won)
                return;

        bcoords_to_pcoords(board->win_x1, board->win_y1, &x1, &y1);
        bcoords_to_pcoords(board->win_x2, board->win_y2, &x2, &y2);
        cairo_save(cairo);
        cairo_set_source_rgba(cairo, 1., 0., 0., 0.67);
        cairo_set_line_width(cairo, tile_size / 3);
        cairo_set_line_cap(cairo, CAIRO_LINE_CAP_ROUND);
        cairo_move_to(cairo, x1 + tile_size / 2, y1 + tile_size / 2);
        cairo_line_to(cairo, x2 + tile_size / 2, y2 + tile_size / 2);
        cairo_stroke(cairo);
        cairo_restore(cairo);
        if (x2 < x1) {
                tmp = x1;
                x1 = x2;
                x2 = tmp;
        }
        if (y2 < y1) {
                tmp = y1;
                y1 = y2;
                y2 = tmp;
        }
        gtk_widget_queue_draw_area(drawing_area, x1, y1, x2 + tile_size - x1,
                                   y2 + tile_size - y1);
}

void draw_board_sized(int size)
/* Render the backing board pixmap; if size is not set then the board is drawn
   to fit the drawing area */
{
        int x, y, width, height;

        if (!drawing_area && !size)
                return;

        cairo_save(cairo);

        // Calculate visible board range
        if (size)
                width = height = tile_size = size;
        else {
                width = drawing_area->allocation.width;
                height = drawing_area->allocation.height;
        }
        tile_size = width;
        if (tile_size > height)
                tile_size = drawing_area->allocation.height;
        tile_size /= board_size + 2;
        board_xo = (width - tile_size * (board_size + 2)) / 2;
        board_yo = (height - tile_size * (board_size + 2)) / 2;

        // Fill gray boundaries
        cairo_set_source_rgba(cairo, 0.4, 0.4, 0.4, 1.);
        cairo_rectangle(cairo, 0, 0, width, board_yo);
        cairo_fill(cairo);
        cairo_rectangle(cairo, 0, board_yo, board_xo, height - board_yo * 2);
        cairo_fill(cairo);
        cairo_rectangle(cairo, width - board_xo - 1, board_yo, board_xo + 1,
                        height - board_yo * 2);
        cairo_fill(cairo);
        cairo_rectangle(cairo, 0, height - board_yo - 1, width, board_yo + 1);
        cairo_fill(cairo);

        /* Fill label boundaries */
        if (opt_grayscale)
                cairo_set_source_rgba(cairo, 1., 1., 1., 1.);
        else
                cairo_set_source_rgba(cairo, 0.9, 0.8, 0.4, 1.);
        cairo_rectangle(cairo, board_xo, board_yo, width - board_xo * 2,
                        tile_size);
        cairo_fill(cairo);
        cairo_rectangle(cairo, board_xo, board_yo + tile_size, tile_size,
                        height - tile_size * 2 - board_yo * 2);
        cairo_fill(cairo);
        cairo_rectangle(cairo, width - board_xo - tile_size - 1, tile_size,
                        tile_size + 1, height - tile_size - board_yo * 2);
        cairo_fill(cairo);
        cairo_rectangle(cairo, board_xo, height - board_yo - tile_size - 1,
                        width - board_xo * 2, tile_size + 1);
        cairo_fill(cairo);

        /* Set cairo font */
        cairo_select_font_face(cairo, "monospace", CAIRO_FONT_SLANT_NORMAL,
                               CAIRO_FONT_WEIGHT_BOLD);
        cairo_set_font_size(cairo, tile_size / 2);
        cairo_set_source_rgba(cairo, 0., 0., 0., 1.);

        /* Draw horizontal labels */
        for (x = 0; x < board_size; x++)
                center_print(board_xo + (x + 1.5) * tile_size, board_yo +
                             tile_size / 2, bcoord_to_alpha(x));
        for (x = 0; x < board_size; x++)
                center_print(board_xo + (x + 1.5) * tile_size,
                             height - board_yo - tile_size / 2,
                             bcoord_to_alpha(x));

        /* Draw vertical labels */
        for (y = 0; y < board_size; y++)
                center_print(board_xo + tile_size / 2, board_yo + (y + 1.5) *
                             tile_size, va("%d", board_size - y));
        for (y = 0; y < board_size; y++)
                center_print(width - board_xo - tile_size / 2,
                             board_yo + (y + 1.5) * tile_size,
                             va("%d", board_size - y));

        cairo_restore(cairo);
        do_not_dirty = TRUE;

        /* Refresh the marks */
        draw_marks(marks, FALSE);

        // Render board tiles and pieces
        for (y = 0; y < board_size; y++)
                for (x = 0; x < board_size; x++)
                        draw_tile(x, y);

        draw_last_moves();
        draw_win();

        // Draw hover piece
        if (hover)
                draw_piece(hover_x, hover_y, board->turn, 0.5);

        do_not_dirty = FALSE;
        if (!size)
                gtk_widget_queue_draw(drawing_area);
}

static void check_hover(void)
{
        hover = (piece_at(board, hover_x, hover_y) == PIECE_NONE)
                && hover_x < board_size && hover_y < board_size;
}

#ifndef NO_CAIRO_SVG
void draw_screenshot(const char *filename)
/* Save a screenshot file */
{
        cairo_t *old_cairo = cairo;
        cairo_surface_t *surface;
        int size = 512 - 512 % (board_size + 2);

        /* FIXME: 0.5 pixel wide hair lines appear at most sizes */

        surface = cairo_svg_surface_create(filename, size, size);
        cairo = cairo_create(surface);
        draw_board_sized(size);
        cairo_show_page(cairo);
        cairo_destroy(cairo);
        cairo_surface_finish(surface);
        cairo = old_cairo;
        draw_board();
}
#endif

/*
 *      Events
 */

// Create a new backing pixmap of the appropriate size
static gboolean configure_event(GtkWidget *widget, GdkEventConfigure *event)
{
        if (pixmap) {
                g_object_unref(pixmap);
                pixmap = NULL;
        }
        pixmap = gdk_pixmap_new(widget->window, widget->allocation.width,
                                widget->allocation.height, -1);
        if (cairo) {
                cairo_destroy(cairo);
                cairo = NULL;
        }
        cairo = gdk_cairo_create(GDK_DRAWABLE(pixmap));
        cairo_set_line_width(cairo, 1.);
        draw_board();
        return TRUE;
}

// Redraw the drawing area from the backing pixmap
static gboolean expose_event(GtkWidget *widget, GdkEventExpose *event)
{
        gdk_draw_drawable(widget->window,
                          widget->style->fg_gc[GTK_WIDGET_STATE(widget)],
                          pixmap, event->area.x, event->area.y, event->area.x,
                          event->area.y, event->area.width, event->area.height);
        return FALSE;
}

// Mouse button is pressed over drawing area
static gboolean button_press_event(GtkWidget *widget, GdkEventButton *event)
{
        check_hover();
        if (players[board->turn].ai == PLAYER_HUMAN && hover) {
                make_move(hover_x, hover_y);
                hover = FALSE;
        }
        return TRUE;
}

// Mouse leaves drawing area
static gboolean leave_notify_event(GtkWidget *widget, GdkEventCrossing *event,
                                   gpointer user_data)
{
        if (hover) {
                draw_tile(hover_x, hover_y);
                hover = FALSE;
        }
        window_status("");
        return FALSE;
}

// Mouse is moved over drawing area
static gboolean motion_notify_event(GtkWidget *widget, GdkEventMotion *event)
{
        gint x, y;
        GdkModifierType state;
        BCOORD hover_x2, hover_y2;

        if (players[board->turn].ai != PLAYER_HUMAN)
                return FALSE;

        if (event->is_hint)
                gdk_window_get_pointer(event->window, &x, &y, &state);
        else {
                x = event->x;
                y = event->y;
                state = (GdkModifierType)event->state;
        }
        if (!pcoord_to_bcoord(x, y, &hover_x2, &hover_y2)) {
                if (hover) {
                        hover = FALSE;
                        draw_tile(hover_x, hover_y);
                }
                return FALSE;
        }
        if (playable &&
            (!hover || hover_x2 != hover_x || hover_y2 != hover_y)) {
                int i;
                char *mark_str = "";

                if (hover)
                        draw_tile(hover_x, hover_y);
                hover_x = hover_x2;
                hover_y = hover_y2;
                check_hover();
                if (!hover)
                        return TRUE;
                if ((i = aimoves_find(marks, hover_x, hover_y)) >= 0)
                        mark_str = va(" marked as %s",
                                      aiw_to_string(marks->data[i].weight));
                draw_piece(hover_x, hover_y, board->turn, 0.5);
                window_status(va("%s: play at %s/%d,%d (%d move%s left)%s",
                                 piece_to_string(board->turn),
                                 bcoords_to_string(hover_x, hover_y),
                                 hover_x, hover_y, board->moves_left,
                                 board->moves_left == 1 ? "" : "s",
                                 mark_str));
        }

        return TRUE;
}

/*
 *      Initilization and settings
 */

// Enable/disable hover and move reporting
void draw_playable(int yes)
{
        playable = yes;
        if (!yes)
                hover = FALSE;
}

// Create the drawing area control
GtkWidget *draw_init(void)
{
        if (drawing_area)
                return drawing_area;

        drawing_area = gtk_drawing_area_new();
        g_signal_connect(G_OBJECT(drawing_area), "expose-event",
                         G_CALLBACK(expose_event), NULL);
        g_signal_connect(G_OBJECT(drawing_area), "configure-event",
                         G_CALLBACK(configure_event), NULL);
        g_signal_connect(G_OBJECT(drawing_area), "button-press-event",
                         G_CALLBACK(button_press_event), NULL);
        g_signal_connect(G_OBJECT(drawing_area), "motion-notify-event",
                         G_CALLBACK(motion_notify_event), NULL);
        g_signal_connect(G_OBJECT(drawing_area), "leave-notify-event",
                         G_CALLBACK(leave_notify_event), NULL);
        gtk_widget_set_events(drawing_area,
                              GDK_EXPOSURE_MASK |
                              GDK_BUTTON_PRESS_MASK |
                              GDK_BUTTON_RELEASE_MASK |
                              GDK_POINTER_MOTION_MASK |
                              GDK_POINTER_MOTION_HINT_MASK |
                              GDK_LEAVE_NOTIFY_MASK);
        gtk_widget_set_extension_events(drawing_area,
                                        GDK_EXTENSION_EVENTS_CURSOR);
        return drawing_area;
}
