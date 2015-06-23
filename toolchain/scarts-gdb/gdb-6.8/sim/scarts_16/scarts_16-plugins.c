/* SCARTS (16-bit) target-dependent code for the GNU simulator.
   Copyright 1996, 1997, 1998, 1999, 2000, 2001, 2002, 2003
   Free Software Foundation, Inc.
   Contributed by Martin Walter <mwalter@opencores.org>

   This file is part of the GNU simulators.

   This program is free software; you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation; either version 3 of the License, or
   (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program.  If not, see <http://www.gnu.org/licenses/>.  */


#include <dirent.h>
#include <dlfcn.h>
#include <pwd.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/types.h>
#include "modules.h"
#include "scarts_16-plugins.h"

/* Macros for preprocessor macro stringification. */
#define STRINGIFY(x) #x
#define TOSTRING(x) STRINGIFY(x)

#define SCARTS_TOOLCHAIN_LIB_SIM_DIR_STR TOSTRING(SCARTS_TOOLCHAIN_LIB_SIM_DIR)

int              num_plugins;
static scarts_plugin_t  plugins[SCARTS_MAX_PLUGINS];

static int              filter_plugin (const struct dirent *entry);
static scarts_plugin_t *load_plugin   (char *name);

static int
filter_plugin (const struct dirent *entry)
{
  char *p;
  int result;

  result = 0;

  /* Check if '.so' is contained in the entry's name. */
  p = strstr (entry->d_name, ".so");
  if (p != NULL)
  {
    /* Check if '.so' terminates the entry's name. */
    if (*(p + 3) == '\0')
      result = 1;
  }

  return result;
}

static scarts_plugin_t*
load_plugin (char *name)
{
  char path[SCARTS_MAX_PLUGIN_PATH_LEN + 1];
  uint16_t addr, size;
  scarts_plugin_t *plugin;

  plugin = &plugins[num_plugins];

  if (num_plugins >= SCARTS_MAX_PLUGINS - 1)
  {
    fprintf (stderr, "Please recompile GDB with increased SCARTS_MAX_PLUGINS.\n");
    return NULL;
  }

  strncpy (path, SCARTS_TOOLCHAIN_LIB_SIM_DIR_STR, SCARTS_MAX_PLUGIN_PATH_LEN - (9 + SCARTS_MAX_PLUGIN_NAME_LEN));
  strcat (path, "/scarts_16/");
  strncat (path, name, SCARTS_MAX_PLUGIN_NAME_LEN);

  plugin->handle = dlopen (path, RTLD_LAZY);
  if (!plugin->handle)
  {
    fprintf (stderr, "Unable to open object file %s\n", path);
    return NULL;
  }

  strncpy (plugin->name, name, SCARTS_MAX_PLUGIN_NAME_LEN);

  dlerror();

  *(void **) (&plugin->get_mem) = dlsym (plugin->handle, "get_mem");
  if (dlerror() != NULL)
  {
    fprintf (stderr, "Unable to find symbol '%s' in object file %s\n", "get_mem", path);
    return NULL;
  }

  *(void **) (&plugin->get_mem_map) = dlsym (plugin->handle, "get_mem_map");
  if (dlerror() != NULL)
  {
    fprintf (stderr, "Unable to find symbol '%s' in object file %s\n", "get_mem_map", path);
    return NULL;
  }

  *(void **) (&plugin->get_status) = dlsym (plugin->handle, "get_status");
  if (dlerror() != NULL)
    plugin->get_status = NULL;

  *(void **) (&plugin->mem_read) = dlsym (plugin->handle, "mem_read");
  if (dlerror() != NULL)
  {
    fprintf (stderr, "Unable to find symbol '%s' in object file %s\n", "mem_read", path);
    return NULL;
  }

  *(void **) (&plugin->mem_write) = dlsym (plugin->handle, "mem_write");
  if (dlerror() != NULL)
  {
    fprintf (stderr, "Unable to find symbol '%s' in object file %s\n", "mem_write", path);
    return NULL;
  }

  *(void **) (&plugin->reset) = dlsym (plugin->handle, "reset");
  if (dlerror() != NULL)
  {
    fprintf (stderr, "Unable to find symbol '%s' in object file %s\n", "reset", path);
    return NULL;
  }

  *(void **) (&plugin->set_codemem_read_fptr) = dlsym (plugin->handle, "set_codemem_read_fptr");
  if (dlerror() != NULL)
    plugin->set_codemem_read_fptr = NULL;

  *(void **) (&plugin->set_codemem_write_fptr) = dlsym (plugin->handle, "set_codemem_write_fptr");
  if (dlerror() != NULL)
    plugin->set_codemem_write_fptr = NULL;

  *(void **) (&plugin->set_datamem_read_fptr) = dlsym (plugin->handle, "set_datamem_read_fptr");
  if (dlerror() != NULL)
    plugin->set_datamem_read_fptr = NULL;

  *(void **) (&plugin->set_datamem_write_fptr) = dlsym (plugin->handle, "set_datamem_write_fptr");
  if (dlerror() != NULL)
    plugin->set_datamem_write_fptr = NULL;

  *(void **) (&plugin->tick) = dlsym (plugin->handle, "tick");
  if (dlerror() != NULL)
  {
    fprintf (stderr, "Unable to find symbol '%s' in object file %s\n", "tick", path);
    return NULL;
  }

  /* Check if the plugin is connected to an interrupt line. */
  plugin->int_num = -1;
  if (plugin->get_status != NULL)
  {
    int path_len = strlen (path);

    strcat (path, ".int");
    FILE* fint = fopen (path, "r");
    if (fint != NULL)
    {
      if (fscanf (fint, "%d", &(plugin->int_num)) == EOF || plugin->int_num > SCARTS_MAX_INTERRUPT_NUM)
        plugin->int_num = -1;

      fclose (fint);
    }

    /* Remove the '.int' extension before printing any messages. */
    path[path_len] = '\0';
  }

  /* Get the start address and size (bytes) of the plugin. */
  (*plugin->get_mem_map) (&addr, &size);
  
  if (plugin->int_num != -1) 
    fprintf (stdout, "Plugin: %s, Address: 0x%X - %X, Interrupt: %d\n", path, addr, addr + size - 1, plugin->int_num);
  else
    fprintf (stdout, "Plugin: %s, Address: 0x%X - %X\n", path, addr, addr + size - 1);

  ++num_plugins;
  return plugin;
}

scarts_plugin_t*
scarts_get_plugin (uint16_t addr)
{
  int i;
  uint16_t start, size;

  for (i = 0; i < num_plugins; ++i)
  {
    (*plugins[i].get_mem_map) (&start, &size);

    if (addr >= start && addr < start + size)
      return &plugins[i];
  }

  return NULL;
}

void
scarts_load_plugins (void)
{
  char path[SCARTS_MAX_PLUGIN_PATH_LEN + 1];
  int n;
  struct dirent **entries;

  num_plugins = 0;

  strncpy (path, SCARTS_TOOLCHAIN_LIB_SIM_DIR_STR, SCARTS_MAX_PLUGIN_PATH_LEN - (8 + SCARTS_MAX_PLUGIN_NAME_LEN));
  strcat (path, "/scarts_16");

  fprintf (stdout, "Scanning for plugins in %s\n", path);
  n = scandir (path, &entries, filter_plugin, alphasort);
  if (n >= 0)
  {
    while (n--)
    {
      load_plugin (entries[n]->d_name);
      free (entries[n]);
    }

    free (entries);
  }
  else
    fprintf (stderr, "Unable to scan directory %s\n", path);
}

void
scarts_reset_plugins (void)
{
  int i;

  for (i = 0; i < num_plugins; ++i)
    plugins[i].reset ();
}

void
scarts_tick_plugins (uint16_t *pc)
{
  int i;

  for (i = 0; i < num_plugins; ++i)
    plugins[i].tick (*pc);
}

int
scarts_get_plugin_int_request (void)
{
  int i;
  scarts_plugin_t *plugin;

  for (i = 0; i < num_plugins; ++i)
  {
    plugin = &plugins[i];

    if (plugin->int_num != -1)
    {
      /* Check if a plugin requested an interrupt. */
      if (plugin->get_status != NULL && (*plugin->get_status() & (1 << PROC_CTRL_STATUS_INT)))
        return plugin->int_num;
    }
  }

  return -1;
}
