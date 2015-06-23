
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
#include <glib.h>
#include "shared.h"
#include "connectk.h"

int load_moves_list(const char *filename)
{
        GIOChannel *ioc;
        GIOStatus status;
        GError *error = NULL;
        gchar *line = NULL;
        gsize len, term;
        int size = 0;

        ioc = g_io_channel_new_file(filename, "r", &error);
        if (!ioc) {
                g_warning("Failed to open file '%s' for reading: %s", filename,
                          error->message);
                return 0;
        }

        connect_k = 0;
        place_p = 0;
        start_q = 0;

        /* Read the first non-blank line */
        do {
                g_free(line);
                status = g_io_channel_read_line(ioc, &line, &len, &term,
                                                &error);
                if (error) {
                        g_warning("Error reading from file '%s': %s",
                                  filename, error->message);
                        return 0;
                }
                if (!line)
                        continue;
                line[term] = 0;
                g_strchug(line);
        } while(status == G_IO_STATUS_NORMAL && *line == 0);

        /* Read "size k p q" header */
        if (g_ascii_isdigit(*line)) {
                size = g_ascii_strtoull(line, &line, 10);
                g_strchug(line);
                connect_k = g_ascii_strtoull(line, &line, 10);
                g_strchug(line);
                place_p = g_ascii_strtoull(line, &line, 10);
                g_strchug(line);
                start_q = g_ascii_strtoull(line, &line, 10);
                g_strchug(line);
                /* Game victor is skipped */
        }

        /* Default to connect-6 */
        if (!size)
                size = 19;
        if (!connect_k)
                connect_k = 6;
        if (!place_p)
                place_p = 2;
        if (!start_q)
                start_q = 1;
        new_game(size);

        /* Read moves list in Ba1 format */
        while (g_io_channel_read_line(ioc, &line, &len, &term, &error) ==
               G_IO_STATUS_NORMAL) {
                BCOORD x, y;

                if (!line)
                        continue;
                line[term] = 0;
                g_strchug(line);
                string_to_bcoords(line, &x, &y);
                make_move(x, y);
                g_free(line);
        }

        g_io_channel_unref(ioc);
        return 1;
}

int save_moves_list(const char *filename)
{
        GIOChannel *ioc;
        GError *error = NULL;
        Board *last_b;
        PIECE winner = PIECE_NONE;
        int i;
        char *buf;

        ioc = g_io_channel_new_file(filename, "w", &error);
        if (!ioc) {
                g_warning("Failed to open file '%s' for writing: %s", filename,
                          error->message);
                return 0;
        }

        /* Find the winner */
        last_b = board_at(move_last);
        if (last_b && last_b->won)
                winner = last_b->turn;

        buf = va("%d %d %d %d %d\n", board_size, connect_k, place_p, start_q,
                 winner);
        g_io_channel_write_chars(ioc, buf, -1, NULL, &error);
        if (error) {
                g_warning("Error writing to file '%s': %s",
                          filename, error->message);
                return 0;
        }
        for (i = 0; i < move_last; i++) {
                Board *b;

                b = board_at(i);
                if (b->won)
                        break;
                buf = va("%s\n", bcoords_to_string(b->move_x, b->move_y));
                g_io_channel_write_chars(ioc, buf, -1, NULL, &error);
                if (error) {
                        g_warning("Error writing to file '%s': %s",
                                  filename, error->message);
                        return 0;
                }
        }
        g_io_channel_unref(ioc);
        return 1;
}
