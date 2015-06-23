#! /usr/bin/env python2.6
# -*- mode: python; coding: utf-8; -*-
import os, sys, shelve, shutil, re
from projpaths import *
from lib import *
from caps import *
from string import Template

cap_strings = { 'ipc' : \
'''
\t\t\t[${idx}] = {
\t\t\t\t.target = ${cid},
\t\t\t\t.type = CAP_TYPE_IPC | ${target_rtype},
\t\t\t\t.access = CAP_IPC_SEND | CAP_IPC_RECV
\t\t\t\t          | CAP_IPC_FULL | CAP_IPC_SHORT
\t\t\t\t          | CAP_IPC_EXTENDED | CAP_CHANGEABLE
\t\t\t\t          | CAP_REPLICABLE | CAP_TRANSFERABLE,
\t\t\t\t.start = 0, .end = 0, .size = 0,
\t\t\t},
'''
, 'tctrl' : \
'''
\t\t\t[${idx}] = {
\t\t\t\t.target = ${cid},
\t\t\t\t.type = CAP_TYPE_TCTRL | ${target_rtype},
\t\t\t\t.access = CAP_TCTRL_CREATE | CAP_TCTRL_DESTROY
\t\t\t\t          | CAP_TCTRL_SUSPEND | CAP_TCTRL_RUN
\t\t\t\t          | CAP_TCTRL_RECYCLE | CAP_TCTRL_WAIT
\t\t\t\t          | CAP_CHANGEABLE | CAP_REPLICABLE
\t\t\t\t          | CAP_TRANSFERABLE,
\t\t\t\t.start = 0, .end = 0, .size = 0,
\t\t\t},
'''
, 'irqctrl' : \
'''
\t\t\t[${idx}] = {
\t\t\t\t.target = ${cid},
\t\t\t\t.type = CAP_TYPE_IRQCTRL | ${target_rtype},
\t\t\t\t.access = CAP_IRQCTRL_REGISTER | CAP_IRQCTRL_WAIT
\t\t\t\t          | CAP_CHANGEABLE | CAP_REPLICABLE
\t\t\t\t          | CAP_TRANSFERABLE,
\t\t\t\t.start = 0, .end = 0, .size = 0,
\t\t\t},
'''
, 'exregs' : \
'''
\t\t\t[${idx}] = {
\t\t\t\t.target = ${cid},
\t\t\t\t.type = CAP_TYPE_EXREGS | ${target_rtype},
\t\t\t\t.access = CAP_EXREGS_RW_PAGER
\t\t\t\t          | CAP_EXREGS_RW_UTCB | CAP_EXREGS_RW_SP
\t\t\t\t          | CAP_EXREGS_RW_PC | CAP_EXREGS_RW_REGS
\t\t\t\t          | CAP_CHANGEABLE | CAP_REPLICABLE | CAP_TRANSFERABLE,
\t\t\t\t.start = 0, .end = 0, .size = 0,
\t\t\t},
'''
, 'capctrl' : \
'''
\t\t\t[${idx}] = {
\t\t\t\t.target = ${cid},
\t\t\t\t.type = CAP_TYPE_CAP | ${target_rtype},
\t\t\t\t.access = CAP_CAP_GRANT | CAP_CAP_READ
\t\t\t\t          | CAP_CAP_SHARE | CAP_CAP_REPLICATE
\t\t\t\t          | CAP_CAP_MODIFY
\t\t\t\t| CAP_CAP_READ | CAP_CAP_SHARE,
\t\t\t\t.start = 0, .end = 0, .size = 0,
\t\t\t},
'''
, 'umutex' : \
'''
\t\t\t[${idx}] = {
\t\t\t\t.target = ${cid},
\t\t\t\t.type = CAP_TYPE_UMUTEX | CAP_RTYPE_CONTAINER,
\t\t\t\t.access = CAP_UMUTEX_LOCK | CAP_UMUTEX_UNLOCK,
\t\t\t\t.start = 0, .end = 0, .size = 0,
\t\t\t},
'''
, 'threadpool' : \
'''
\t\t\t[${idx}] = {
\t\t\t\t.target = ${cid},
\t\t\t\t.type = CAP_TYPE_QUANTITY
\t\t\t\t	  | CAP_RTYPE_THREADPOOL,
\t\t\t\t.access = CAP_CHANGEABLE | CAP_TRANSFERABLE,
\t\t\t\t.start = 0, .end = 0,
\t\t\t\t.size = ${size},
\t\t\t},
'''
, 'spacepool' : \
'''
\t\t\t[${idx}] = {
\t\t\t\t.target = ${cid},
\t\t\t\t.type = CAP_TYPE_QUANTITY | CAP_RTYPE_SPACEPOOL,
\t\t\t\t.access = CAP_CHANGEABLE | CAP_TRANSFERABLE,
\t\t\t\t.start = 0, .end = 0,
\t\t\t\t.size = ${size},
\t\t\t},
'''
, 'cpupool' : \
'''
\t\t\t[${idx}] = {
\t\t\t\t.target = ${cid},
\t\t\t\t.type = CAP_TYPE_QUANTITY | CAP_RTYPE_CPUPOOL,
\t\t\t\t.access = 0, .start = 0, .end = 0,
\t\t\t\t.size = ${size} /* Percentage */,
\t\t\t},
'''
, 'mutexpool' : \
'''
\t\t\t[${idx}] = {
\t\t\t\t.target = ${cid},
\t\t\t\t.type = CAP_TYPE_QUANTITY | CAP_RTYPE_MUTEXPOOL,
\t\t\t\t.access = CAP_CHANGEABLE | CAP_TRANSFERABLE,
\t\t\t\t.start = 0, .end = 0,
\t\t\t\t.size = ${size},
\t\t\t},
'''
, 'mappool' : \
'''
\t\t\t[${idx}] = {
\t\t\t\t/* For pmd accounting */
\t\t\t\t.target = ${cid},
\t\t\t\t.type = CAP_TYPE_QUANTITY | CAP_RTYPE_MAPPOOL,
\t\t\t\t.access = CAP_CHANGEABLE | CAP_TRANSFERABLE,
\t\t\t\t.start = 0, .end = 0,
\t\t\t\t/* Function of mem regions, nthreads etc. */
\t\t\t\t.size = ${size},
\t\t\t},
'''
, 'cappool' : \
'''
\t\t\t[${idx}] = {
\t\t\t\t/* For cap spliting, creating, etc. */
\t\t\t\t.target = ${cid},
\t\t\t\t.type = CAP_TYPE_QUANTITY | CAP_RTYPE_CAPPOOL,
\t\t\t\t.access = CAP_CHANGEABLE | CAP_TRANSFERABLE,
\t\t\t\t.start = 0, .end = 0,
\t\t\t\t/* This may be existing caps X 2 etc. */
\t\t\t\t.size = ${size},
\t\t\t},
'''
, 'device' : \
'''
\t\t\t[${idx}] = {
\t\t\t\t/* For device selection */
\t\t\t\t.target = ${cid},
\t\t\t\t.type = CAP_TYPE_MAP_PHYSMEM | CAP_RTYPE_CONTAINER,
\t\t\t\t.access = CAP_MAP_READ | CAP_MAP_WRITE | CAP_MAP_EXEC |
\t\t\t\t\tCAP_MAP_CACHED | CAP_MAP_UNCACHED | CAP_MAP_UNMAP |
\t\t\t\t\tCAP_IRQCTRL_REGISTER,
\t\t\t\t.start = __pfn(PLATFORM_${devname}_BASE),
\t\t\t\t.end = __pfn(PLATFORM_${devname}_BASE + PLATFORM_${devname}_SIZE),
\t\t\t\t.size = PLATFORM_${devname}_SIZE >> 12,
\t\t\t\t.attr = (CAP_DEVTYPE_${devtype} & CAP_DEVTYPE_MASK)
\t\t\t\t\t| ((${devnum} << CAP_DEVNUM_SHIFT) & CAP_DEVNUM_MASK),
\t\t\t\t.irq = IRQ_${devname},
\t\t\t},
'''
}

#
# These are carefully crafted functions, touch with care.
#
def prepare_custom_capability(cont, param, val):
    if 'TYPE' in param:
        capkey, captype, rest = param.split('_', 2)
        capkey = capkey.lower()
        captype = captype.lower()
        cont.caps[capkey] = cap_strings[captype]
    elif 'TARGET' in param:
        target_parts = param.split('_', 2)
        if len(target_parts) == 2:
            capkey = target_parts[0].lower()
            templ = Template(cont.caps[capkey])
            cont.caps[capkey] = templ.safe_substitute(cid = val)
        elif len(target_parts) == 3:
            capkey = target_parts[0].lower()
            ttype = target_parts[2]
            templ = Template(cont.caps[capkey])

            # On current container, provide correct rtype and current containerid.
            # Else we leave container id to user-supplied value
            if ttype == 'CURRENT_CONTAINER':
                cont.caps[capkey] = templ.safe_substitute(target_rtype = 'CAP_RTYPE_CONTAINER',
                                                          cid = cont.id)
            elif ttype == 'CURRENT_PAGER_SPACE':
                cont.caps[capkey] = templ.safe_substitute(target_rtype = 'CAP_RTYPE_SPACE',
                                                          cid = cont.id)
            elif ttype == 'ANOTHER_CONTAINER':
                cont.caps[capkey] = templ.safe_substitute(target_rtype = 'CAP_RTYPE_CONTAINER')
            elif ttype == 'ANOTHER_PAGER':
                cont.caps[capkey] = templ.safe_substitute(target_rtype = 'CAP_RTYPE_THREAD')
    elif 'DEVICE' in param:
        # Extract all fields
        unused, device_name, rest = param.split('_', 2)
        capkey = device_name.lower()
        cont.caps[capkey] = cap_strings['device']
        templ = Template(cont.caps[capkey])
        device_id = device_name[-1:]
        device_type = device_name[:-1]

        # Fill in all blanks
        cont.caps[capkey] = \
            templ.safe_substitute(cid = cont.id,
                                  devname = device_name,
                                  devnum = device_id,
                                  devtype = device_type)

    else: # Ignore custom_use symbol
        return
    # print capkey
    # print cont.caps[capkey]

def prepare_typed_capability(cont, param, val):
    captype, params = param.split('_', 1)
    captype = captype.lower()

    # USE makes us assign the initial cap string with blank fields
    if 'USE' in params:
        cont.caps[captype] = cap_strings[captype]

        # Prepare string template from capability type
        templ = Template(cont.caps[captype])

        # If it is a pool, amend current container id as default
        if captype[-len('pool'):] == 'pool':
            cont.caps[captype] = templ.safe_substitute(cid = cont.id)

    # Fill in the blank size field
    elif 'SIZE' in params:
        # Get reference to capability string template
        templ = Template(cont.caps[captype])
        cont.caps[captype] = templ.safe_substitute(size = val)

    # Fill in capability target type and target id fields
    elif 'TARGET' in params:
        # Get reference to capability string template
        templ = Template(cont.caps[captype])

        # Two types of strings are expected here: TARGET or TARGET_TARGETTYPE
        # If TARGET, the corresponding value is in val
        target_parts = params.split('_', 1)

        # Target type
        if len(target_parts) == 2:
            ttype = target_parts[1]

            # On current container, provide correct rtype and current containerid.
            # Else we leave container id to user-supplied value
            if ttype == 'CURRENT_CONTAINER':
                cont.caps[captype] = templ.safe_substitute(target_rtype = 'CAP_RTYPE_CONTAINER',
                                                           cid = cont.id)
            elif ttype == 'CURRENT_PAGER_SPACE':
                cont.caps[captype] = templ.safe_substitute(target_rtype = 'CAP_RTYPE_SPACE',
                                                           cid = cont.id)
            elif ttype == 'ANOTHER_CONTAINER':
                cont.caps[captype] = templ.safe_substitute(target_rtype = 'CAP_RTYPE_CONTAINER')
            elif ttype == 'ANOTHER_PAGER':
                cont.caps[captype] = templ.safe_substitute(target_rtype = 'CAP_RTYPE_THREAD')

        # Get target value supplied by user in val
        else:
            cont.caps[captype] = templ.safe_substitute(cid = val)

        #print captype
        #print cont.caps[captype]

def prepare_capability(cont, param, val):
    if 'CUSTOM' in param or 'DEVICE' in param:
        prepare_custom_capability(cont, param, val)
    else:
        prepare_typed_capability(cont, param, val)

