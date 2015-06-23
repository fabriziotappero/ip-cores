#!/usr/bin/env python
# timing_diagram.py, Joris van Rantwijk, Jul 2010.

"""
Generate timing diagrams for SpaceWire Light manual.
"""

from pyx import *

riseWidth = 0.15
clockWidth = 1.0
lowLevel = 0
highLevel = 0.5
midLevel = 0.25

def drawGrid(x, y1, y2, tstart, nclk):

    for i in xrange(nclk):
        x0 = x + clockWidth * (tstart + i)
        c.stroke(path.line(x0, y1, x0, y2), [ style.linewidth.Thin, color.gray(0.5) ])

def drawSignal(x, y, events):

    for i in xrange(len(events)-1):
        (t, v) = events[i]
        (tnext, vnext) = events[i+1]

        firstevt = (i == 0)
        lastevt  = (i == len(events) - 2)

        x0 = x + clockWidth * t
        x1 = x + clockWidth * t + 0.5 * riseWidth
        x2 = x + clockWidth * tnext - 0.5 * riseWidth
        x3 = x + clockWidth * tnext

        # fill
        if v.lower() == 'x':
            p = path.path(path.moveto(x1, y + lowLevel))
            if not firstevt:
                p.append(path.lineto(x0, y + midLevel))
            p.append(path.lineto(x1, y + highLevel))
            p.append(path.lineto(x2, y + highLevel))
            if not lastevt:
                p.append(path.lineto(x3, y + midLevel))
            p.append(path.lineto(x2, y + lowLevel))
            p.append(path.lineto(x1, y + lowLevel))
            c.fill(p, [ color.gray(0.5) ])

        lineStyle = [ ]
        if v.lower() != 'x':
            lineStyle.append(style.linewidth.Thick)

        # draw low part of signal
        if v.lower() in '0vx':
            p = path.path()
            if firstevt:
                p.append(path.moveto(x1, y + lowLevel))
            else:
                p.append(path.moveto(x0, y + midLevel))
                p.append(path.lineto(x1, y + lowLevel))
            p.append(path.lineto(x2, y + lowLevel))
            if not lastevt:
                p.append(path.lineto(x3, y + midLevel))
            c.stroke(p, lineStyle)

        # draw high part of signal
        if v.lower() in '1vx':
            p = path.path()
            if firstevt:
                p.append(path.moveto(x1, y + highLevel))
            else:
                p.append(path.moveto(x0, y + midLevel))
                p.append(path.lineto(x1, y + highLevel))
            p.append(path.lineto(x2, y + highLevel))
            if not lastevt:
                p.append(path.lineto(x3, y + midLevel))
            c.stroke(p, lineStyle)

        # draw center part of signal
        if v.lower() == 'z':
            p = path.path()
            if firstevt:
                p.append(path.moveto(x1, y + midLevel))
            else:
                p.append(path.moveto(x0, y + midLevel))
            if lastevt:
                p.append(path.lineto(x2, y + midLevel))
            else:
                p.append(path.lineto(x3, y + midLevel))
            c.stroke(p, lineStyle)


th = 0.3 # an appearance of "hold time" in diagram
xstart = 1.2

text.set(mode='latex')

#### Read timing

c = canvas.canvas()

drawGrid(xstart, 0.9, 5.5, 1, 9)

c.text(0, 5, '\\textsf{\\textbf{CLK}}')
drawSignal(xstart, 5,
  [ (0.5+i/2.0, str(i%2)) for i in range(20) ])

c.text(0, 4, '\\textsf{\\textbf{RXVALID}}')
drawSignal(xstart, 4,
  [ (0.5, '0'), (2+th, '1'), (7+th, '0'), (10, '') ])

c.text(0, 3, '\\textsf{\\textbf{RXFLAG}}')
drawSignal(xstart, 3,
  [ (0.5, 'x'), (2+th, 'v'), (4+th, 'v'), (6+th, 'v'), (7+th, 'x'), (10, '') ])

c.text(0, 2, '\\textsf{\\textbf{RXDATA}}')
drawSignal(xstart, 2,
  [ (0.5, 'x'), (2+th, 'v'), (4+th, 'v'), (6+th, 'v'), (7+th, 'x'), (10, '') ])

c.text(0, 1, '\\textsf{\\textbf{RXREAD}}')
drawSignal(xstart, 1,
  [ (0.5, '0'), (3+th, '1'), (4+th, '0'), (5+th, '1'), (8+th, '0'), (10, '') ])

c.stroke(path.line(xstart+4*clockWidth, 0.4, xstart+4*clockWidth, 0.8), [ deco.arrow() ])
c.stroke(path.line(xstart+6*clockWidth, 0.4, xstart+6*clockWidth, 0.8), [ deco.arrow() ])
c.stroke(path.line(xstart+7*clockWidth, 0.4, xstart+7*clockWidth, 0.8), [ deco.arrow() ])

c.writeEPSfile('timing_read.eps')

#### Write timing

c = canvas.canvas()

drawGrid(xstart, 0.9, 5.5, 1, 9)

c.text(0, 5, '\\textsf{\\textbf{CLK}}')
drawSignal(xstart, 5,
  [ (0.5+i/2.0, str(i%2)) for i in range(20) ])

c.text(0, 4, '\\textsf{\\textbf{TXRDY}}')
drawSignal(xstart, 4,
  [ (0.5, '1'), (5+th, '0'), (6+th, '1'), (9+th, '0'), (10, '') ])

c.text(0, 3, '\\textsf{\\textbf{TXWRITE}}')
drawSignal(xstart, 3,
  [ (0.5, '0'), (2+th, '1'), (3+th, '0'), (4+th, '1'), (8+th, '0'), (10, '') ])

c.text(0, 2, '\\textsf{\\textbf{TXFLAG}}')
drawSignal(xstart, 2,
  [ (0.5, 'x'), (2+th, 'v'), (3+th, 'x'), (4+th, 'v'), (5+th, 'v'),
    (7+th, 'v'), (8+th, 'x'), (10, '') ])

c.text(0, 1, '\\textsf{\\textbf{TXDATA}}')
drawSignal(xstart, 1,
  [ (0.5, 'x'), (2+th, 'v'), (3+th, 'x'), (4+th, 'v'), (5+th, 'v'),
    (7+th, 'v'), (8+th, 'x'), (10, '') ])

c.stroke(path.line(xstart+3*clockWidth, 0.4, xstart+3*clockWidth, 0.8), [ deco.arrow() ])
c.stroke(path.line(xstart+5*clockWidth, 0.4, xstart+5*clockWidth, 0.8), [ deco.arrow() ])
c.stroke(path.line(xstart+7*clockWidth, 0.4, xstart+7*clockWidth, 0.8), [ deco.arrow() ])
c.stroke(path.line(xstart+8*clockWidth, 0.4, xstart+8*clockWidth, 0.8), [ deco.arrow() ])

c.writeEPSfile('timing_write.eps')

#### Time codes

c = canvas.canvas()

xstart = 1.4

drawGrid(xstart, 0, 6.5, 1, 9)

c.text(0, 6, '\\textsf{\\textbf{CLK}}')
drawSignal(xstart, 6,
  [ (0.5+i/2.0, str(i%2)) for i in range(20) ])

c.text(0, 5, '\\textsf{\\textbf{TICK\_OUT}}')
drawSignal(xstart, 5,
  [ (0.5, '0'), (2+th, '1'), (3+th, '0'), (5+th, '1'), (6+th, '0'), (10, '') ])

c.text(0, 4, '\\textsf{\\textbf{CTRL\_OUT}}')
drawSignal(xstart, 4, [ (0.5, 'x'), (2+th, 'v'), (5+th, 'v'), (10, '') ])

c.text(0, 3, '\\textsf{\\textbf{TIME\_OUT}}')
drawSignal(xstart, 3, [ (0.5, 'x'), (2+th, 'v'), (5+th, 'v'), (10, '') ])

c.text(0, 2, '\\textsf{\\textbf{TICK\_IN}}')
drawSignal(xstart, 2, [ (0.5, '0'), (7+th, '1'), (8+th, '0'), (10, '') ])

c.text(0, 1, '\\textsf{\\textbf{CTRL\_IN}}')
drawSignal(xstart, 1, [ (0.5, 'x'), (7+th, 'v'), (8+th, 'x'), (10, '') ])

c.text(0, 0, '\\textsf{\\textbf{TIME\_IN}}')
drawSignal(xstart, 0, [ (0.5, 'x'), (7+th, 'v'), (8+th, 'x'), (10, '') ])

c.writeEPSfile('timing_timecode.eps')

#### Link status

c = canvas.canvas()

clockWidth = 0.8
xstart = 1.6

c.text(0, 5, '\\textsf{\\textbf{LINKSTART}}')
drawSignal(xstart, 5, [ (1, '0'), (2, '1'), (10, '0'), (19, '') ])

c.text(0, 4, '\\textsf{\\textbf{STARTED}}')
drawSignal(xstart, 4, [ (1, '0'), (4, '1'), (6, '0'), (19, '') ])

c.text(0, 3, '\\textsf{\\textbf{CONNECTING}}')
drawSignal(xstart, 3, [ (1, '0'), (6, '1'), (8, '0'), (19, '') ])

c.text(0, 2, '\\textsf{\\textbf{RUNNING}}')
drawSignal(xstart, 2, [ (1, '0'), (8, '1'), (16, '0'), (19, '') ])

c.text(0, 1, '\\textsf{\\textbf{ERRPAR}}')
drawSignal(xstart, 1, [ (1, '0'), (15.5, '1'), (16.5, '0'), (19, '') ])

c.stroke(path.line(xstart+6*clockWidth, 4.8, xstart+6*clockWidth, 2.6), [ style.linewidth.Thin ])
c.stroke(path.line(xstart+8*clockWidth, 3.8, xstart+8*clockWidth, 1.6), [ style.linewidth.Thin ])

c.writeEPSfile('timing_link.eps')

