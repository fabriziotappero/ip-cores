/*
 * Any link-related marking variable that gets updated at runtime is listed here
 *
 * Copyright (C) 2007 Bahadir Balban
 */

/* The first free address after the last image loaded in physical memory */
unsigned long __svc_images_end;

/* The new boundaries of page tables after they're relocated */
unsigned long __pt_start;
unsigned long __pt_end;
