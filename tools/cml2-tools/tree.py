# tree.py -- highly optimized tkinter tree control
# by Charles E. "Gene" Cash (gcash@magicnet.net)
#
# 98/12/02 CEC started
# 99/??/?? CEC release to comp.lang.python.announce
# Trimmed for CML2 by ESR, December 2001 (cut-paste support removed).
import os, string
from Tkinter import *

# this is initialized later, after Tkinter is started
open_icon=None

# tree node helper class
class Node:
    # initialization creates node, draws it, and binds mouseclicks
    def __init__(self, parent, name, id, myclosed_icon, myopen_icon, x, y,
                 parentwidget):
        self.parent=parent		# immediate parent node
        self.name=name			# name displayed on the label
        self.id=id			# internal id used to manipulate things
        self.open_icon=myopen_icon	# bitmaps to be displayed
        self.closed_icon=myclosed_icon
        self.widget=parentwidget	# tree widget we belong to
        self.subnodes=[]		# our list of child nodes
        self.spinlock=0			# cheap mutex spinlock
        self.open_flag=0		# closed to start with
        # draw horizontal connecting lines
        if self.widget.lineflag:
            self.line=self.widget.create_line(x-self.widget.distx, y, x, y)
        # draw approprate image
        if self.open_flag:
            self.symbol=self.widget.create_image(x, y, image=self.open_icon)
        else:
            self.symbol=self.widget.create_image(x, y, image=self.closed_icon)
        # add label
        self.label=self.widget.create_text(x+self.widget.textoff, y, 
                                           text=self.name, justify='left',
                                           anchor='w' )
        # single-click to expand/collapse
        self.widget.tag_bind(self.symbol, '<1>', self.click)
        self.widget.tag_bind(self.label, '<1>', self.click) # njr
        # call customization hook
        if self.widget.init_hook:
            self.widget.init_hook(self)

#    def __repr__(self):
#        return 'Node: %s  Parent: %s  (%d children)' % \
#               (self.name, self.parent.name, len(self.subnodes))
    
    # recursively delete subtree & clean up cyclic references
    def _delete(self):
        for i in self.subnodes:
            if i.open_flag and i.subnodes:
                # delete vertical connecting line
                if self.widget.lineflag:
                    self.widget.delete(i.tree)
            # delete node's subtree, if any
            i._delete()
            # the following unbinding hassle is because tkinter
            # keeps a callback reference for each binding
            # so if we want things GC'd...
            for j in (i.symbol, i.label):
                for k in self.widget.tag_bind(j):
                    self.widget.tag_unbind(j, k)
                try:
                    for k in self.widget._tagcommands.get(j, []):
                        self.widget.deletecommand(k)
                        self.widget._tagcommands[j].remove(k)
                except: # XXX not needed in >= 1.6?
                    pass
            # delete widgets from canvas
            self.widget.delete(i.symbol, i.label)
            if self.widget.lineflag:
                self.widget.delete(i.line)
            # break cyclic reference
            i.parent=None
        # move cursor if it's in deleted subtree
        if self.widget.pos in self.subnodes:
            self.widget.move_cursor(self)
        # now subnodes will be properly garbage collected
        self.subnodes=[]

    # move everything below current icon, to make room for subtree
    # using the magic of item tags
    def _tagmove(self, dist):
        # mark everything below current node as movable
        bbox1=self.widget.bbox(self.widget.root.symbol, self.label)
        bbox2=self.widget.bbox('all')
        self.widget.dtag('move')
        self.widget.addtag('move', 'overlapping', 
                           bbox2[0], bbox1[3], bbox2[2], bbox2[3])
        # untag cursor & node so they don't get moved too
        # this has to be done under Tk on X11
        self.widget.dtag(self.widget.cursor_box, 'move')
        self.widget.dtag(self.symbol, 'move')
        self.widget.dtag(self.label, 'move')
        # now do the move of all the tagged objects
        self.widget.move('move', 0, dist)
        # fix up connecting lines
        if self.widget.lineflag:
            n=self
            while n:
                if len(n.subnodes):
                    # position of current icon
                    x1, y1=self.widget.coords(n.symbol)
                    # position of last node in subtree
                    x2, y2=self.widget.coords(n.subnodes[-1:][0].symbol)
                    self.widget.coords(n.tree, x1, y1, x1, y2)
                n=n.parent

    # return list of subnodes that are expanded (not including self)
    # only includes unique leaf nodes (e.g. /home and /home/root won't
    # both be included) so expand() doesn't get called unnecessarily
    # thank $DEITY for Dr. Dutton's Data Structures classes at UCF!
    def expanded(self):
        # push initial node into stack
        stack=[(self, (self.id,))]
        list=[]
        while stack:
            # pop from stack
            p, i=stack[-1:][0]
            del stack[-1:]
            # flag to discard non-unique sub paths
            flag=1
            # check all children
            for n in p.subnodes:
                # if expanded, push onto stack
                if n.open_flag:
                    flag=0
                    stack.append((n, i+(n.id,)))
            # if we reached end of path, add to list
            if flag:
                list.append(i[1:])
        return list

    # get full name, including names of all parents
    def full_id(self):
        if self.parent:
            return self.parent.full_id()+(self.id,)
        else:
            return (self.id,)

    # expanding/collapsing folders
    def toggle_state(self, state=None):
        if self.widget.toggle_init_hook:
            self.widget.toggle_init_hook(self)
        if not self.open_icon:
            return			# not an expandable folder
        if state == None:
            state = not self.open_flag  # toggle to other state
        else:
            # are we already in the state we want to be?
            if (not state) == (not self.open_flag):
                return
        # not re-entrant
        # acquire mutex
        while self.spinlock:
            pass
        self.spinlock=1
        # call customization hook
        if self.widget.before_hook:
            self.widget.before_hook(self)
        # if we're closed, expand & draw our subtrees
        if not self.open_flag:
            self.open_flag=1
            self.widget.itemconfig(self.symbol, image=self.open_icon)
            # get contents of subdirectory or whatever
            contents=self.widget.get_contents(self)
            # move stuff to make room
            self._tagmove(self.widget.disty*len(contents))
            # now draw subtree
            self.subnodes=[]
            # get current position of icon
            x, y=self.widget.coords(self.symbol)
            yp=y
            for i in contents:
                # add new subnodes, they'll draw themselves
                yp=yp+self.widget.disty
                self.subnodes.append(Node(self, i[0], i[1], i[2], i[3],
                                          x+self.widget.distx, yp,
                                          self.widget))
            # the vertical line spanning the subtree
            if self.subnodes and self.widget.lineflag:
                self.tree=self.widget.create_line(x, y,
                                     x, y+self.widget.disty*len(self.subnodes))
                self.widget.lower(self.tree, self.symbol)
        # if we're open, collapse and delete subtrees
        elif self.open_flag:
            self.open_flag=0
            self.widget.itemconfig(self.symbol, image=self.closed_icon)
            # if we have any children
            if self.subnodes:
                # recursively delete subtree icons
                self._delete()
                # delete vertical line
                if self.widget.lineflag:
                    self.widget.delete(self.tree)
                # find next (vertically-speaking) node
                n=self
                while n.parent:
                    # position of next sibling in parent's list
                    i=n.parent.subnodes.index(n)+1
                    if i < len(n.parent.subnodes):
                        n=n.parent.subnodes[i]
                        break
                    n=n.parent
                if n.parent:
                    # move everything up so that distance to next subnode is
                    # correct
                    x1, y1=self.widget.coords(self.symbol)
                    x2, y2=self.widget.coords(n.symbol)
                    dist=y2-y1-self.widget.disty
                    self._tagmove(-dist)
        # update scroll region for new size
        x1, y1, x2, y2=self.widget.bbox('all')
        self.widget.configure(scrollregion=(x1, y1, x2+5, y2+5))
        # call customization hook
        if self.widget.after_hook:
            print 'calling after_hook'
            self.widget.after_hook(self)
        # release mutex
        self.spinlock=0

    # expand this subnode
    # doesn't have to exist, it expands what part of the path DOES exist
    def expand(self, dirs):
        # if collapsed, then expand
        self.toggle_state(1)
        # find next subnode
        if dirs:
            for n in self.subnodes:
                if n.id == dirs[0]:
                    return n.expand(dirs[1:])
            print "Can't find path %s in %s" % (dirs, self.id)
            print "- Available subnodes: %s" % map(lambda n: n.id, self.subnodes)
        return self
    
    # handle mouse clicks by moving cursor and toggling folder state
    def click(self, dummy):
        self.widget.move_cursor(self)
        self.toggle_state()

    # return next lower visible node
    def next(self):
        n=self
        if n.subnodes:
            # if you can go right, do so
            return n.subnodes[0]
        while n.parent:
            # move to next sibling
            i=n.parent.subnodes.index(n)+1
            if i < len(n.parent.subnodes):
                return n.parent.subnodes[i]
            # if no siblings, move to parent's sibling
            n=n.parent
        # we're at bottom
        return self
    
    # return next higher visible node
    def prev(self):
        n=self
        if n.parent:
            # move to previous sibling
            i=n.parent.subnodes.index(n)-1
            if i >= 0:
                # move to last child
                n=n.parent.subnodes[i]
                while n.subnodes:
                    n=n.subnodes[-1]
            else:
                # punt if there's no previous sibling
                if n.parent:
                    n=n.parent
        return n

class Tree(Canvas):
    def __init__(self, master, rootname, rootlabel=None, openicon=None,
                 shuticon=None, getcontents=None, init=None,
                 toggle_init=None,before=None, after=None, cut=None, paste=None,
                 distx=15, disty=15, textoff=10, lineflag=1, **kw_args):
        global open_icon, shut_icon, file_icon,yes_icon,no_icon
        # pass args to superclass
        apply(Canvas.__init__, (self, master), kw_args)
        # try creating an image, work around Tkinter bug
        # ('global' should do it, but it doesn't)
        if open_icon is not None:
            try:
                item = self.create_image(0,0,image=open_icon)
                self.delete(item)
            except:
                print "recreating Tree PhotoImages"
                open_icon = None # need to recreate PhotoImages
        # default images (BASE64-encoded GIF files)
        # we have to delay initialization until Tk starts up or PhotoImage()
        # complains (otherwise I'd just put it up top)
        if open_icon == None:
            open_icon=PhotoImage(
                data='R0lGODlhEAANAKIAAAAAAMDAwICAgP//////ADAwMAAAAAAA' \
                'ACH5BAEAAAEALAAAAAAQAA0AAAM6GCrM+jCIQamIbw6ybXNSx3GVB' \
                'YRiygnA534Eq5UlO8jUqLYsquuy0+SXap1CxBHr+HoBjoGndDpNAAA7')
            shut_icon=PhotoImage(
                data='R0lGODlhDwANAKIAAAAAAMDAwICAgP//////ADAwMAAAAAAA' \
                'ACH5BAEAAAEALAAAAAAPAA0AAAMyGCHM+lAMMoeAT9Jtm5NDKI4Wo' \
                'FXcJphhipanq7Kvu8b1dLc5tcuom2foAQQAyKRSmQAAOw==')
            file_icon=PhotoImage(
                data='R0lGODlhCwAOAJEAAAAAAICAgP///8DAwCH5BAEAAAMALAAA' \
                'AAALAA4AAAIphA+jA+JuVgtUtMQePJlWCgSN9oSTV5lkKQpo2q5W+' \
                'wbzuJrIHgw1WgAAOw==')
            yes_icon=PhotoImage(
                data='R0lGODlhDAAPAKEAAP////9FRAAAAP///yH5BAEKAAMALAAA' \
                'AAAMAA8AAAIrhI8zyKAWUARCQGnqPVODuXlg0FkQ+WUmUzYpZYKv9'\
                '5Eg7VZKxffC7usVAAA7')
            no_icon=PhotoImage(
                data='R0lGODlhDAAPAKEAAP///wAAAERe/////yH+FUNyZWF0ZWQgd' \
            '2l0aCBUaGUgR0lNUAAh+QQBCgADACwAAAAADAAPAAACLISPM8i' \
            'gjUIAolILpDB70zxxnieJBxl6n1FiGLiuW4tgJcSGuKRI/h/oAX8FADs=')
        # function to return subnodes (not very much use w/o this)
        if not getcontents:
            raise ValueError, 'must have "get_contents" function'
        self.get_contents=getcontents
        # horizontal distance that subtrees are indented
        self.distx=distx
        # vertical distance between rows
        self.disty=disty
        # how far to offset text label
        self.textoff=textoff
        # called after new node initialization
        self.init_hook=init
        # called right after toggle state 
        self.toggle_init_hook=toggle_init
        # called just before subtree expand/collapse
        self.before_hook=before
        # called just after subtree expand/collapse
        self.after_hook=after
        # flag to display lines
        self.lineflag=lineflag
        # create root node to get the ball rolling
        if openicon:
            oi = openicon
        else:
            oi = open_icon
        if shuticon:
            si = shuticon
        else:
            si = shut_icon
        if rootlabel:
            self.root=Node(None, rootlabel, rootname, si, oi, 11, 11, self)
        else:
            self.root=Node(None, rootname, rootname, si, oi, 11, 11, self)
        # configure for scrollbar(s)
        x1, y1, x2, y2=self.bbox('all') 
        self.configure(scrollregion=(x1, y1, x2+5, y2+5))
        # add a cursor
        self.cursor_box=self.create_rectangle(0, 0, 0, 0)
        self.move_cursor(self.root)
        # make it easy to point to control
        self.bind('<Enter>', self.mousefocus)
        # bindings similar to those used by Microsoft tree control
        # page-up/page-down
        self.bind('<Next>', self.pagedown)
        self.bind('<Prior>', self.pageup)
        # arrow-up/arrow-down
        self.bind('<Down>', self.next)
        self.bind('<Up>', self.prev)
        # arrow-left/arrow-right
        self.bind('<Left>', self.ascend)
        # (hold this down and you expand the entire tree)
        self.bind('<Right>', self.descend)
        # home/end
        self.bind('<Home>', self.first)
        self.bind('<End>', self.last)
        # space bar
        self.bind('<Key-space>', self.toggle)

    # scroll (in a series of nudges) so items are visible
    def see(self, *items):
        x1, y1, x2, y2=apply(self.bbox, items)
        while x2 > self.canvasx(0)+self.winfo_width():
            old=self.canvasx(0)
            self.xview('scroll', 1, 'units')
            # avoid endless loop if we can't scroll
            if old == self.canvasx(0):
                break
        while y2 > self.canvasy(0)+self.winfo_height():
            old=self.canvasy(0)
            self.yview('scroll', 1, 'units')
            if old == self.canvasy(0):
                break
        # done in this order to ensure upper-left of object is visible
        while x1 < self.canvasx(0):
            old=self.canvasx(0)
            self.xview('scroll', -1, 'units')
            if old == self.canvasx(0):
                break
        while y1 < self.canvasy(0):
            old=self.canvasy(0)
            self.yview('scroll', -1, 'units')
            if old == self.canvasy(0):
                break
            
    # move cursor to node
    def move_cursor(self, node):
        self.pos=node
        x1, y1, x2, y2=self.bbox(node.symbol, node.label)
        self.coords(self.cursor_box, x1-1, y1-1, x2+1, y2+1)
        self.see(node.symbol, node.label)

    # expand given path
    # note that the convention used in this program to identify a
    # particular node is to give a tuple listing it's id and parent ids
    # so you probably want to use os.path.split() a lot
    def expand(self, path):
        return self.root.expand(path[1:])

    # soak up event argument when moused-over
    # could've used lambda but didn't...
    def mousefocus(self, event):
        self.focus_set()
        
    # open/close subtree
    def toggle(self, event=None):
        self.pos.toggle_state()

    # move to next lower visible node
    def next(self, event=None):
        self.move_cursor(self.pos.next())
            
    # move to next higher visible node
    def prev(self, event=None):
        self.move_cursor(self.pos.prev())

    # move to immediate parent
    def ascend(self, event=None):
        if self.pos.parent:
            # move to parent
            self.move_cursor(self.pos.parent)

    # move right, expanding as we go
    def descend(self, event=None):
        self.pos.toggle_state(1)
        if self.pos.subnodes:
            # move to first subnode
            self.move_cursor(self.pos.subnodes[0])
        else:
            # if no subnodes, move to next sibling
            self.next()

    # go to root
    def first(self, event=None):
        # move to root node
        self.move_cursor(self.root)

    # go to last visible node
    def last(self, event=None):
        # move to bottom-most node
        n=self.root
        while n.subnodes:
            n=n.subnodes[-1]
        self.move_cursor(n)

    # previous page
    def pageup(self, event=None):
        n=self.pos
        j=self.winfo_height()/self.disty
        for i in range(j-3):
            n=n.prev()
        self.yview('scroll', -1, 'pages')
        self.move_cursor(n)

    # next page
    def pagedown(self, event=None):
        n=self.pos
        j=self.winfo_height()/self.disty
        for i in range(j-3):
            n=n.next()
        self.yview('scroll', 1, 'pages')
        self.move_cursor(n)

# End
