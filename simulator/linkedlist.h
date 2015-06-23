/*
 * Copyright (c) 2007 The Akuma Project
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to
 * deal in the Software without restriction, including without limitation the
 * rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
 * sell copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
 * IN THE SOFTWARE.
 *
 * $Id: linkedlist.h 107 2007-05-13 17:01:30Z eirik $
 */

#ifndef _LINKEDLIST_H_
#define _LINKEDLIST_H_

struct llist_node {
	struct llist_node *next;
	void *obj;
};
typedef struct llist_node *llist_node_t;

struct llist_head {
	llist_node_t head, tail;
};
typedef struct llist_head *llist_t;


llist_t llist_make(void);
int llist_add_tail(llist_t, void *);
int llist_add_head(llist_t, void *);
int llist_add_pos(llist_t, void *, int);
void llist_removen(int);
void llist_remove(void *);
void llist_destroy(llist_t);
void *llist_pop(llist_t);
int llist_empty(llist_t);
int llist_insert_list_head(llist_t, llist_t);
void *llist_getobj(llist_node_t);
void *llist_getelem(llist_t, int);
int llist_size(llist_t);
llist_t llist_copy(llist_t);
void llist_remove_elem(llist_t, int);
int llist_insert_list(llist_t, llist_t, int);




#define LLIST_FOREACH(_head, _node) \
	for (_node = (_head)->head; \
	     (_node); \
	     (_node) = (_node)->next)

#endif /* _LINKEDLIST_H_ */
