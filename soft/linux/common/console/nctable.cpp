
#include <stdio.h>
#include <stdarg.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <fcntl.h>
#include <ncurses.h>
#include <signal.h>
#include <vector>

#ifndef __NCTABLE_H__
#include "nctable.h"
#endif

//-----------------------------------------------------------------------------

void table::init()
{
    initscr();
    cbreak();
    noecho();
    keypad(stdscr, TRUE);
    nonl();
}

//-----------------------------------------------------------------------------

table::table(int cell_width, int cell_height)
{
    init();

    m_row = 0;
    m_colomn = 0;
    m_CW = cell_width;
    m_CH = cell_height;
    m_table.clear();

    getmaxyx(stdscr,m_maxH,m_maxW);

    m_W0 = m_maxW/2;
    m_H0 = m_maxH/2;

    m_header.w = NULL;
    m_header.X0 = m_header.Y0 = m_header.W = m_header.H = 0;
    m_status.clear();
    //m_status.w = NULL;
    //m_status.X0 = m_status.Y0 = m_status.W = m_status.H = 0;
}

//-----------------------------------------------------------------------------

table::table(int colomn_number, int cell_width, int cell_height)
{
    init();

    m_row = 0;
    m_colomn = colomn_number;
    m_CW = cell_width;
    m_CH = cell_height;
    m_table.clear();

    getmaxyx(stdscr,m_maxH,m_maxW);

    m_W0 = m_maxW/2;
    m_H0 = m_maxH/2;

    m_header.w = NULL;
    m_header.X0 = m_header.Y0 = m_header.W = m_header.H = 0;
    m_status.clear();
    //m_status.w = NULL;
    //m_status.X0 = m_status.Y0 = m_status.W = m_status.H = 0;
}

//-----------------------------------------------------------------------------

table::table(int row, int col, int cell_width, int cell_height)
{
    init();

    m_row = row;
    m_colomn = col;
    m_CW = cell_width;
    m_CH = cell_height;

    getmaxyx(stdscr,m_maxH,m_maxW);

    m_W0 = m_maxW/2;
    m_H0 = m_maxH/2;

    m_header.w = NULL;
    m_header.X0 = m_header.Y0 = m_header.W = m_header.H = 0;
    m_status.clear();
    //m_status.w = NULL;
    //m_status.X0 = m_status.Y0 = m_status.W = m_status.H = 0;

    create_table(row, col);
}

//-----------------------------------------------------------------------------

table::~table()
{
    clear_table();
    clear_header();
    clear_status();
    endwin();
}

//-----------------------------------------------------------------------------

void table::clear_table()
{
    for(unsigned i=0; i<m_table.size(); i++) {
        row_t row = m_table.at(i);
        for(unsigned j=0; j<row.w.size(); j++) {
            WINDOW *w = row.w.at(j);
            delwin(w);
        }
        row.w.clear();
    }
    m_table.clear();
}

//-----------------------------------------------------------------------------

int table::create_table(int nrow, int ncol)
{
    clear_table();

    int dX = m_CW * ncol/2;
    int dY = m_CH * nrow/2;

    for(int row = 0; row < nrow; row++) {

        int x0 = m_W0 - dX;
        int y0 = m_H0 + m_CH * row - dY;

        row_t new_row;

        new_row.X0 = x0;
        new_row.Y0 = y0;

        for(int col = 0; col < ncol; col++) {

            int xn = x0 + m_CW * col;
            int yn = y0;

            WINDOW *w = newwin(m_CH, m_CW, yn, xn);
            if(!w)
                break;
            box(w, 0 , 0);
            wrefresh(w);
            new_row.w.push_back(w);
        }

        m_table.push_back(new_row);
    }

    return m_table.size();
}

//-----------------------------------------------------------------------------

int table::add_row()
{
    int x0 = 0;
    int y0 = 0;

    if(m_table.size()) {

        x0 = m_W0 - m_CW * m_colomn/2;
        y0 = m_H0 - m_H0/2 + m_CH * m_table.size();

    } else {

        x0 = m_W0 - m_CW * m_colomn/2;
        y0 = m_H0 - m_H0/2;
    }

    row_t new_row;

    new_row.X0 = x0;
    new_row.Y0 = y0;

    for(int col = 0; col < m_colomn; col++) {

        int xn = x0 + m_CW * col;
        int yn = y0;

        WINDOW *w = newwin(m_CH, m_CW, yn, xn);
        if(!w)
            break;
            box(w, 0 , 0);
            wrefresh(w);
            new_row.w.push_back(w);
    }

    m_table.push_back(new_row);

    return m_table.size();
}

//-----------------------------------------------------------------------------

int table::set_cell_text(unsigned nrow, unsigned ncol, const char *fmt, ...)
{
    if(nrow >= m_table.size())
        return -1;

    row_t& row = m_table.at(nrow);

    if(ncol >= row.w.size())
        return -2;

    WINDOW *w = row.w.at(ncol);

    if(!w)
        return -3;

    va_list argptr;
    va_start(argptr, fmt);
    char msg[256];
    vsprintf(msg, fmt, argptr);
    wmove(w, m_CH/2, m_CW/2-strlen(msg)/2);
    wprintw(w, "%s", msg);
    wrefresh(w);

    return 0;
}

//-----------------------------------------------------------------------------

bool table::create_header()
{
    if(m_header.w)
        return true;

    if(m_table.empty())
        return false;

    row_t row0 = m_table.at(0);

    m_header.X0 = row0.X0;
    m_header.Y0 = row0.Y0-m_CH;

    m_header.H = m_CH;
    m_header.W = m_CW*row0.w.size();

    WINDOW *w = newwin(m_header.H, m_header.W, m_header.Y0, m_header.X0);
    if(!w) {
        return false;
    }

    m_header.w = w;
    box(w, 0 , 0);

    wrefresh(w);

    return true;
}

//-----------------------------------------------------------------------------

bool table::create_status()
{
    if(m_table.empty())
        return false;

    struct header_t status_bar;

    if(m_status.empty()) {

        row_t rowN = m_table.at(m_table.size()-1);

        status_bar.X0 = rowN.X0;
        status_bar.Y0 = rowN.Y0+m_CH;

        status_bar.H = m_CH;
        status_bar.W = m_CW*rowN.w.size();

    } else {

        struct header_t last_bar = m_status.at(m_status.size()-1);

        status_bar.X0 = last_bar.X0;
        status_bar.Y0 = last_bar.Y0+m_CH;

        status_bar.H = m_CH;
        status_bar.W = last_bar.W;
    }

    WINDOW *w = newwin(status_bar.H, status_bar.W, status_bar.Y0, status_bar.X0);
    if(!w) {
        return false;
    }

    status_bar.w = w;
    box(status_bar.w, 0 , 0);
    wrefresh(w);

    m_status.push_back(status_bar);

    return true;
}

//-----------------------------------------------------------------------------

int table::set_header_text(const char *fmt, ...)
{
    if(!m_header.w)
        return -1;

    va_list argptr;
    va_start(argptr, fmt);
    char msg[256];
    vsprintf(msg, fmt, argptr);
    wmove(m_header.w, m_header.H/2, m_header.W/2-strlen(msg)/2);
    wprintw(m_header.w, "%s", msg);
    wrefresh(m_header.w);

    return 0;
}

//-----------------------------------------------------------------------------

int table::set_status_text(unsigned id, const char *fmt, ...)
{
    if(id >= m_status.size())
        return -1;

    struct header_t status_bar = m_status.at(id);
    if(!status_bar.w)
        return -1;

    va_list argptr;
    va_start(argptr, fmt);
    char msg[256];
    vsprintf(msg, fmt, argptr);
    wmove(status_bar.w, status_bar.H/2, status_bar.W/2-strlen(msg)/2);
    wprintw(status_bar.w, "%s", msg);
    wrefresh(status_bar.w);

    return 0;
}

//-----------------------------------------------------------------------------

void table::clear_status()
{
    for(unsigned i=0; i<m_status.size(); i++) {
        struct header_t status_bar = m_status.at(i);
        if(status_bar.w) {
            delwin(status_bar.w);
            status_bar.w = NULL;
        }
    }
    m_status.clear();
}

//-----------------------------------------------------------------------------

void table::clear_header()
{
    if(m_header.w) {
        delwin(m_header.w);
        m_header.w = NULL;
    }
}

//-----------------------------------------------------------------------------

//-----------------------------------------------------------------------------
