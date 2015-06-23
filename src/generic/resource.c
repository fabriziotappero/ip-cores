/*
 * Initialize system resource management.
 *
 * Copyright (C) 2009 Bahadir Balban
 */
#include <l4/generic/capability.h>
#include <l4/generic/cap-types.h>
#include <l4/generic/container.h>
#include <l4/generic/resource.h>
#include <l4/generic/bootmem.h>
#include <l4/generic/platform.h>
#include <l4/lib/math.h>
#include <l4/lib/memcache.h>
#include INC_GLUE(memory.h)
#include INC_GLUE(mapping.h)
#include INC_ARCH(linker.h)
#include INC_PLAT(platform.h)
#include <l4/api/errno.h>

struct kernel_resources kernel_resources;

pgd_table_t *alloc_pgd(void)
{
	return mem_cache_zalloc(kernel_resources.pgd_cache);
}

pmd_table_t *alloc_pmd(void)
{
	struct capability *cap;

	if (!(cap = capability_find_by_rtype(current,
					     CAP_RTYPE_MAPPOOL)))
		return 0;

	if (capability_consume(cap, 1) < 0)
		return 0;

	return mem_cache_zalloc(kernel_resources.pmd_cache);
}

struct address_space *alloc_space(void)
{
	struct capability *cap;

	if (!(cap = capability_find_by_rtype(current,
					     CAP_RTYPE_SPACEPOOL)))
		return 0;

	if (capability_consume(cap, 1) < 0)
		return 0;

	return mem_cache_zalloc(kernel_resources.space_cache);
}

struct ktcb *alloc_ktcb_use_capability(struct capability *cap)
{
	if (capability_consume(cap, 1) < 0)
		return 0;

	return mem_cache_zalloc(kernel_resources.ktcb_cache);
}

struct ktcb *alloc_ktcb(void)
{
	struct capability *cap;

	if (!(cap = capability_find_by_rtype(current,
					     CAP_RTYPE_THREADPOOL)))
		return 0;

	if (capability_consume(cap, 1) < 0)
		return 0;

	return mem_cache_zalloc(kernel_resources.ktcb_cache);
}

/*
 * This version is boot-time only and it has no
 * capability checking. Imagine the case where the
 * initial capabilities are created and there is no
 * capability to check this allocation.
 */
struct capability *boot_alloc_capability(void)
{
	return mem_cache_zalloc(kernel_resources.cap_cache);
}

struct capability *alloc_capability(void)
{
	struct capability *cap;

	if (!(cap = capability_find_by_rtype(current,
					     CAP_RTYPE_CAPPOOL)))
		return 0;

	if (capability_consume(cap, 1) < 0)
		return 0;

	return mem_cache_zalloc(kernel_resources.cap_cache);
}

struct container *alloc_container(void)
{
	return mem_cache_zalloc(kernel_resources.cont_cache);
}

struct mutex_queue *alloc_user_mutex(void)
{
	struct capability *cap;

	if (!(cap = capability_find_by_rtype(current,
					     CAP_RTYPE_MUTEXPOOL)))
		return 0;

	if (capability_consume(cap, 1) < 0)
		return 0;

	return mem_cache_zalloc(kernel_resources.mutex_cache);
}

void free_pgd(void *addr)
{
	BUG_ON(mem_cache_free(kernel_resources.pgd_cache, addr) < 0);
}

void free_pmd(void *addr)
{
	struct capability *cap;

	BUG_ON(!(cap = capability_find_by_rtype(current,
						CAP_RTYPE_MAPPOOL)));
	capability_free(cap, 1);

	BUG_ON(mem_cache_free(kernel_resources.pmd_cache, addr) < 0);
}

void free_space(void *addr, struct ktcb *task)
{
	struct capability *cap;

	BUG_ON(!(cap = capability_find_by_rtype(task,
						CAP_RTYPE_SPACEPOOL)));
	capability_free(cap, 1);

	BUG_ON(mem_cache_free(kernel_resources.space_cache, addr) < 0);
}


/*
 * Account it to pager, but if it doesn't exist,
 * to current idle task
 */
void free_ktcb(void *addr, struct ktcb *acc_task)
{
	struct capability *cap;

	/* Account it to task's pager if it exists */
	BUG_ON(!(cap = capability_find_by_rtype(acc_task,
						CAP_RTYPE_THREADPOOL)));
	capability_free(cap, 1);

	BUG_ON(mem_cache_free(kernel_resources.ktcb_cache, addr) < 0);
}

void free_capability(void *addr)
{
	struct capability *cap;

	BUG_ON(!(cap = capability_find_by_rtype(current,
						CAP_RTYPE_CAPPOOL)));
	capability_free(cap, 1);

	BUG_ON(mem_cache_free(kernel_resources.cap_cache, addr) < 0);
}

void free_container(void *addr)
{
	BUG_ON(mem_cache_free(kernel_resources.cont_cache, addr) < 0);
}

void free_user_mutex(void *addr)
{
	struct capability *cap;

	BUG_ON(!(cap = capability_find_by_rtype(current,
						CAP_RTYPE_MUTEXPOOL)));
	capability_free(cap, 1);

	BUG_ON(mem_cache_free(kernel_resources.mutex_cache, addr) < 0);
}

/*
 * This splits a capability, splitter region must be in
 * the *middle* of original capability
 */
int memcap_split(struct capability *cap, struct cap_list *cap_list,
		 const unsigned long start,
		 const unsigned long end)
{
	struct capability *new;

	/* Allocate a capability first */
	new = alloc_bootmem(sizeof(*new), 0);

	/*
	 * Some sanity checks to show that splitter range does end up
	 * producing two smaller caps.
	 */
	BUG_ON(cap->start >= start || cap->end <= end);

	/* Update new and original caps */
	new->end = cap->end;
	new->start = end;
	cap->end = start;
	new->access = cap->access;

	/* Add new one next to original cap */
	cap_list_insert(new, cap_list);

	return 0;
}

/* This shrinks the cap from *one* end only, either start or end */
int memcap_shrink(struct capability *cap, struct cap_list *cap_list,
		  const unsigned long start, const unsigned long end)
{
	/* Shrink from the end */
	if (cap->start < start) {
		BUG_ON(start >= cap->end);
		cap->end = start;

	/* Shrink from the beginning */
	} else if (cap->end > end) {
		BUG_ON(end <= cap->start);
		cap->start = end;
	} else
		BUG();

	return 0;
}

/*
 * Given a single memory cap (that definitely overlaps) removes
 * the portion of pfns specified by start/end.
 */
int memcap_unmap_range(struct capability *cap,
		       struct cap_list *cap_list,
		       const unsigned long start,
		       const unsigned long end)
{
	/* Split needed? */
	if (cap->start < start && cap->end > end)
		return memcap_split(cap, cap_list, start, end);
	/* Shrink needed? */
	else if (((cap->start >= start) && (cap->end > end))
	    	   || ((cap->start < start) && (cap->end <= end)))
		return memcap_shrink(cap, cap_list, start, end);
	/* Destroy needed? */
	else if ((cap->start >= start) && (cap->end <= end))
		/* Simply unlink it */
		list_remove(&cap->list);
	else
		BUG();

	return 0;
}

/*
 * Unmaps given memory range from the list of capabilities
 * by either shrinking, splitting or destroying the
 * intersecting capability. Similar to do_munmap()
 */
int memcap_unmap(struct cap_list *used_list,
		 struct cap_list *cap_list,
		 const unsigned long unmap_start,
		 const unsigned long unmap_end)
{
	struct capability *cap, *n;
	int ret;

	/*
	 * If a used list was supplied, check that the
	 * range does not intersect with the used list.
	 * This is an optional sanity check.
	 */
	if (used_list) {
		list_foreach_removable_struct(cap, n,
					      &used_list->caps,
					      list) {
			if (set_intersection(unmap_start, unmap_end,
					     cap->start, cap->end)) {
				ret = -EPERM;
				goto out_err;
			}
		}
	}

	list_foreach_removable_struct(cap, n, &cap_list->caps, list) {
		/* Check for intersection */
		if (set_intersection(unmap_start, unmap_end,
				     cap->start, cap->end)) {
			if ((ret = memcap_unmap_range(cap, cap_list,
						      unmap_start,
						      unmap_end))) {
				goto out_err;
			}
			return 0;
		}
	}
	ret = -EEXIST;

out_err:
	if (ret == -ENOMEM)
		printk("%s: FATAL: Insufficient boot memory "
		       "to split capability\n", __KERNELNAME__);
	else if (ret == -EPERM)
		printk("%s: FATAL: %s memory capability range "
		       "overlaps with an already used range. "
		       "start=0x%lx, end=0x%lx\n", __KERNELNAME__,
		       cap_type(cap) == CAP_TYPE_MAP_VIRTMEM ?
		       "Virtual" : "Physical",
		       __pfn_to_addr(cap->start),
		       __pfn_to_addr(cap->end));
	else if (ret == -EEXIST)
		printk("%s: FATAL: %s memory capability range "
		       "does not match with any available free range. "
		       "start=0x%lx, end=0x%lx\n", __KERNELNAME__,
		       cap_type(cap) == CAP_TYPE_MAP_VIRTMEM ?
		       "Virtual" : "Physical",
		       __pfn_to_addr(cap->start),
		       __pfn_to_addr(cap->end));
	BUG();
}

/*
 * Finds a device memory capability and deletes it from
 * the available device capabilities list
 */
int memcap_request_device(struct cap_list *cap_list,
			  struct cap_info *devcap)
{
	struct capability *cap, *n;

	list_foreach_removable_struct(cap, n, &cap_list->caps, list) {
		if (cap->start == devcap->start &&
		     cap->end == devcap->end &&
		     cap_is_devmem(cap)) {
			/* Unlink only. This is boot memory */
			list_remove(&cap->list);
			return 0;
		}
	}
	printk("%s: FATAL: Device memory requested "
	       "does not match any available device "
	       "capabilities start=0x%lx, end=0x%lx "
	       "attr=0x%x\n", __KERNELNAME__,
	       __pfn_to_addr(devcap->start),
	       __pfn_to_addr(devcap->end), devcap->attr);
	BUG();
}
/*
 * TODO: Evaluate if access bits are needed and add new cap ranges
 * only if their access bits match.
 *
 * Maps a memory range as a capability to a list of capabilities either by
 * merging the given range to an existing capability or creating a new one.
 */
int memcap_map(struct cap_list *cap_list,
	       const unsigned long map_start,
	       const unsigned long map_end)
{
	struct capability *cap, *n;

	list_foreach_removable_struct(cap, n, &cap_list->caps, list) {
		if (cap->start == map_end) {
			cap->start = map_start;
			return 0;
		} else if(cap->end == map_start) {
			cap->end = map_end;
			return 0;
		}
	}

	/* No capability could be extended, we create a new one */
	cap = alloc_capability();
	cap->start = map_start;
	cap->end = map_end;
	link_init(&cap->list);
	cap_list_insert(cap, cap_list);

	return 0;
}

/* Delete all boot memory and add it to physical memory pool. */
int free_boot_memory(struct kernel_resources *kres)
{
	struct container *c;
	unsigned long pfn_start =
		__pfn(virt_to_phys(_start_init));
	unsigned long pfn_end =
		__pfn(page_align_up(virt_to_phys(_end_init)));
	unsigned long init_pfns = pfn_end - pfn_start;

	/* Trim kernel used memory cap */
	memcap_unmap(0, &kres->physmem_used, pfn_start, pfn_end);

	/* Add it to unused physical memory */
	memcap_map(&kres->physmem_free, pfn_start, pfn_end);

	/* Remove the init memory from the page tables */
	for (unsigned long i = pfn_start; i < pfn_end; i++)
		remove_mapping(phys_to_virt(__pfn_to_addr(i)));

	/* Reset pointers that will remain in system as precaution */
	list_foreach_struct(c, &kres->containers.list, list)
		c->pager = 0;

	printk("%s: Freed %lu KB init memory, "
	       "of which %lu KB was used.\n",
	       __KERNELNAME__, init_pfns * 4,
	       (init_pfns -
		__pfn(page_align_up(bootmem_free_pages()))) * 4);

	return 0;
}

/*
 * Initializes kernel caplists, and sets up total of physical
 * and virtual memory as single capabilities of the kernel.
 * They will then get split into caps of different lengths
 * during the traversal of container capabilities, and memcache
 * allocations.
 */
void init_kernel_resources(struct kernel_resources *kres)
{
	struct capability *physmem, *virtmem, *kernel_area;

	/* Initialize system id pools */
	kres->space_ids.nwords = SYSTEM_IDS_MAX;
	kres->ktcb_ids.nwords = SYSTEM_IDS_MAX;
	kres->resource_ids.nwords = SYSTEM_IDS_MAX;
	kres->container_ids.nwords = SYSTEM_IDS_MAX;
	kres->mutex_ids.nwords = SYSTEM_IDS_MAX;
	kres->capability_ids.nwords = SYSTEM_IDS_MAX;

	/* Initialize container head */
	container_head_init(&kres->containers);

	/* Initialize kernel capability lists */
	cap_list_init(&kres->physmem_used);
	cap_list_init(&kres->physmem_free);
	cap_list_init(&kres->virtmem_used);
	cap_list_init(&kres->virtmem_free);
	cap_list_init(&kres->devmem_used);
	cap_list_init(&kres->devmem_free);
	cap_list_init(&kres->non_memory_caps);

	/* Set up total physical memory as single capability */
	physmem = alloc_bootmem(sizeof(*physmem), 0);
	physmem->start = __pfn(PLATFORM_PHYS_MEM_START);
	physmem->end = __pfn(PLATFORM_PHYS_MEM_END);
	link_init(&physmem->list);
	cap_list_insert(physmem, &kres->physmem_free);

	/* Set up total virtual memory as single capability */
	virtmem = alloc_bootmem(sizeof(*virtmem), 0);
	virtmem->start = __pfn(VIRT_MEM_START);
	virtmem->end = __pfn(VIRT_MEM_END);
	link_init(&virtmem->list);
	cap_list_insert(virtmem, &kres->virtmem_free);

	/* Set up kernel used area as a single capability */
	kernel_area = alloc_bootmem(sizeof(*physmem), 0);
	kernel_area->start = __pfn(virt_to_phys(_start_kernel));
	kernel_area->end = __pfn(virt_to_phys(_end_kernel));
	link_init(&kernel_area->list);
	cap_list_insert(kernel_area, &kres->physmem_used);

	/* Unmap kernel used area from free physical memory capabilities */
	memcap_unmap(0, &kres->physmem_free, kernel_area->start,
		     kernel_area->end);

	/* Set up platform-specific device capabilities */
	platform_setup_device_caps(kres);

	/* TODO:
	 * Add all virtual memory areas used by the kernel
	 * e.g. kernel virtual area, syscall page, kip page,
	 * vectors page, timer, sysctl and uart device pages
	 */
}


/*
 * Copies cinfo structures to real capabilities for each pager.
 */
int copy_pager_info(struct pager *pager, struct pager_info *pinfo)
{
	struct capability *cap;
	struct cap_info *cap_info;

	pager->start_address = pinfo->start_address;
	pager->start_lma = __pfn_to_addr(pinfo->pager_lma);
	pager->start_vma = __pfn_to_addr(pinfo->pager_vma);
	pager->memsize = __pfn_to_addr(pinfo->pager_size);
	pager->rw_sections_start = pinfo->rw_sections_start;
	pager->rw_sections_end = pinfo->rw_sections_end;
	pager->rx_sections_start = pinfo->rx_sections_start;
	pager->rx_sections_end = pinfo->rx_sections_end;

	/* Copy all cinfo structures into real capabilities */
	for (int i = 0; i < pinfo->ncaps; i++) {
		cap = boot_capability_create();

		cap_info = &pinfo->caps[i];

		cap->resid = cap_info->target;
		cap->type = cap_info->type;
		cap->access = cap_info->access;
		cap->start = cap_info->start;
		cap->end = cap_info->end;
		cap->size = cap_info->size;
		cap->attr = cap_info->attr;
		cap->irq = cap_info->irq;

		cap_list_insert(cap, &pager->cap_list);
	}

	/*
 	 * Check if pager has enough resources to create its caps:
	 *
	 * Find pager's capability capability, check its
	 * current use count and initialize it
	 */
	cap = cap_list_find_by_rtype(&pager->cap_list,
				     CAP_RTYPE_CAPPOOL);

	/* Verify that we did not excess allocated */
	if (!cap || cap->size < pinfo->ncaps) {
		printk("FATAL: Pager needs more capabilities "
		       "than allocated for initialization.\n");
			BUG();
	}

	/*
	 * Initialize used count. The rest of the spending
	 * checks on this cap will be done in the cap syscall
	 */
	cap->used = pinfo->ncaps;

	return 0;
}

/*
 * Copies container info from a given compact container descriptor to
 * a real container
 */
int copy_container_info(struct container *c, struct container_info *cinfo)
{
	strncpy(c->name, cinfo->name, CONFIG_CONTAINER_NAMESIZE);
	c->npagers = cinfo->npagers;

	/* Copy capabilities */
	for (int i = 0; i < c->npagers; i++)
		copy_pager_info(&c->pager[i], &cinfo->pager[i]);

	return 0;
}

/*
 * Copy boot-time allocated kernel capabilities to ones that
 * are allocated from the capability memcache
 */
void copy_boot_capabilities(struct cap_list *caplist)
{
	struct capability *bootcap, *n, *realcap;

	/* For every bootmem-allocated capability */
	list_foreach_removable_struct(bootcap, n,
				      &caplist->caps,
				      list) {
		/* Create new one from capability cache */
		realcap = capability_create();

		/* Copy all fields except id to real */
		realcap->owner = bootcap->owner;
		realcap->resid = bootcap->resid;
		realcap->type = bootcap->type;
		realcap->access = bootcap->access;
		realcap->start = bootcap->start;
		realcap->end = bootcap->end;
		realcap->size = bootcap->size;
		realcap->attr = bootcap->attr;
		realcap->irq = bootcap->irq;

		/* Unlink boot one */
		list_remove(&bootcap->list);

		/* Add real one to head */
		list_insert(&realcap->list,
			    &caplist->caps);
	}
}

/*
 * Creates capabilities allocated with a real id, and from the
 * capability cache, in place of ones allocated at boot-time.
 */
void setup_kernel_resources(struct boot_resources *bootres,
			    struct kernel_resources *kres)
{
	struct capability *cap;
	struct container *container;
	//pgd_table_t *current_pgd;

	/* First initialize the list of non-memory capabilities */
	cap = boot_capability_create();
	cap->type = CAP_TYPE_QUANTITY | CAP_RTYPE_MAPPOOL;
	cap->size = bootres->nkpmds;
	cap->owner = kres->cid;
	cap_list_insert(cap, &kres->non_memory_caps);

	cap = boot_capability_create();
	cap->type = CAP_TYPE_QUANTITY | CAP_RTYPE_SPACEPOOL;
	cap->size = bootres->nkpgds;
	cap->owner = kres->cid;
	cap_list_insert(cap, &kres->non_memory_caps);

	cap = boot_capability_create();
	cap->type = CAP_TYPE_QUANTITY | CAP_RTYPE_CAPPOOL;
	cap->size = bootres->nkcaps;
	cap->owner = kres->cid;
	cap->used = 3;
	cap_list_insert(cap, &kres->non_memory_caps);

	/* Set up dummy current cap-list for below functions to use */
	cap_list_move(&current->cap_list, &kres->non_memory_caps);

	copy_boot_capabilities(&kres->physmem_used);
	copy_boot_capabilities(&kres->physmem_free);
	copy_boot_capabilities(&kres->virtmem_used);
	copy_boot_capabilities(&kres->virtmem_free);
	copy_boot_capabilities(&kres->devmem_used);
	copy_boot_capabilities(&kres->devmem_free);

	/*
	 * Move to real page tables, accounted by
	 * pgds and pmds provided from the caches
	 *
	 * We do not want to delay this too much,
	 * since we want to avoid allocating an uncertain
	 * amount of memory from the boot allocators.
	 */
	// current_pgd = arch_realloc_page_tables();

	/* Move it back */
	cap_list_move(&kres->non_memory_caps, &current->cap_list);


	/*
	 * Setting up ids used internally.
	 *
	 * See how many containers we have. Assign next
	 * unused container id for kernel resources
	 */
	kres->cid = id_get(&kres->container_ids, bootres->nconts + 1);
	// kres->cid = id_get(&kres->container_ids, 0); // Gets id 0

	/*
	 * Assign thread and space ids to current which will later
	 * become the idle task
	 */
	current->tid = id_new(&kres->ktcb_ids);
	current->space->spid = id_new(&kres->space_ids);

	/*
	 * Init per-cpu zombie lists
	 */
	for (int i = 0; i < CONFIG_NCPU; i++)
		init_ktcb_list(&per_cpu_byid(kres->zombie_list, i));

	/*
	 * Create real containers from compile-time created
	 * cinfo structures
	 */
	for (int i = 0; i < bootres->nconts; i++) {
		/* Allocate & init container */
		container = container_create();

		/* Fill in its information */
		copy_container_info(container, &cinfo[i]);

		/* Add it to kernel resources list */
		kres_insert_container(container, kres);
	}

	/* Initialize pagers */
	container_init_pagers(kres);
}

/*
 * Given a structure size and numbers, it initializes a memory cache
 * using free memory available from free kernel memory capabilities.
 */
struct mem_cache *init_resource_cache(int nstruct, int struct_size,
				      struct kernel_resources *kres,
				      int aligned)
{
	struct capability *cap;
	unsigned long bufsize;

	/* In all unused physical memory regions */
	list_foreach_struct(cap, &kres->physmem_free.caps, list) {
		/* Get buffer size needed for cache */
		bufsize = mem_cache_bufsize((void *)__pfn_to_addr(cap->start),
					    struct_size, nstruct,
					    aligned);
		/*
		 * Check if memcap region size is enough to cover
		 * resource allocation
		 */
		if (__pfn_to_addr(cap->end - cap->start) >= bufsize) {
			unsigned long virtual =
				phys_to_virt(__pfn_to_addr(cap->start));
			/*
			 * Map the buffer as boot mapping if pmd caches
			 * are not initialized
			 */
			if (!kres->pmd_cache) {
				add_boot_mapping(__pfn_to_addr(cap->start),
						 virtual,
						 page_align_up(bufsize),
						 MAP_KERN_RW);
			} else {
				add_mapping_pgd(__pfn_to_addr(cap->start),
						virtual, page_align_up(bufsize),
						MAP_KERN_RW, &init_pgd);
			}
			/* Unmap area from memcap */
			memcap_unmap_range(cap, &kres->physmem_free,
					   cap->start, cap->start +
					   __pfn(page_align_up((bufsize))));

			/* TODO: Manipulate memcaps for virtual range??? */

			/* Initialize the cache */
			return mem_cache_init((void *)virtual, bufsize,
					      struct_size, aligned);
		}
	}
	return 0;
}

/*
 * TODO: Initialize ID cache
 *
 * Given a kernel resources and the set of boot resources required,
 * initializes all memory caches for allocations. Once caches are
 * initialized, earlier boot allocations are migrated to caches.
 */
void init_resource_allocators(struct boot_resources *bootres,
			      struct kernel_resources *kres)
{
	/*
	 * An extra space reserved for kernel
	 * in case all containers quit
	 */
	bootres->nspaces++;
	bootres->nkpgds++;

	/* Initialise PGD cache */
	kres->pgd_cache =
		init_resource_cache(bootres->nspaces,
				    PGD_SIZE, kres, 1);

	/* Initialise struct address_space cache */
	kres->space_cache =
		init_resource_cache(bootres->nspaces,
				    sizeof(struct address_space),
				    kres, 0);

	/* Initialise ktcb cache */
	kres->ktcb_cache =
		init_resource_cache(bootres->nthreads,
				    PAGE_SIZE, kres, 1);

	/* Initialise umutex cache */
	kres->mutex_cache =
		init_resource_cache(bootres->nmutex,
				    sizeof(struct mutex_queue),
				    kres, 0);
	/* Initialise container cache */
	kres->cont_cache =
		init_resource_cache(bootres->nconts,
				    sizeof(struct container),
				    kres, 0);

	/*
	 * Add all caps used by the kernel
	 * Two extra in case more memcaps get split after
	 * cap cache init below. Three extra for quantitative
	 * kernel caps for pmds, pgds, caps.
	 */
	bootres->nkcaps += kres->virtmem_used.ncaps +
			   kres->virtmem_free.ncaps +
			   kres->physmem_used.ncaps +
			   kres->physmem_free.ncaps +
			   kres->devmem_free.ncaps  +
			   kres->devmem_used.ncaps  + 2 + 3;

	/* Add that to all cap count */
	bootres->ncaps += bootres->nkcaps;

	/* Initialise capability cache */
	kres->cap_cache =
		init_resource_cache(bootres->ncaps,
				    sizeof(struct capability),
				    kres, 0);

	/* Count boot pmds used so far and add them */
	bootres->nkpmds += pgd_count_boot_pmds();

	/*
	 * Calculate maximum possible pmds that may be used
	 * during this pmd cache initialization and add them.
	 */
	bootres->nkpmds += ((bootres->npmds * PMD_SIZE) / PMD_MAP_SIZE);
	if (!is_aligned(bootres->npmds * PMD_SIZE,
			PMD_MAP_SIZE))
		bootres->nkpmds++;

	/* Add kernel pmds to all pmd count */
	bootres->npmds += bootres->nkpmds;

	/* Initialise PMD cache */
	kres->pmd_cache =
		init_resource_cache(bootres->npmds,
				    PMD_SIZE, kres, 1);
}

/*
 * Do all system accounting for a given capability info
 * structure that belongs to a container, such as
 * count its resource requirements, remove its portion
 * from global kernel resource capabilities etc.
 */
int process_cap_info(struct cap_info *cap,
		     struct boot_resources *bootres,
		     struct kernel_resources *kres)
{
	int ret = 0;

	switch (cap_rtype(cap)) {
	case CAP_RTYPE_THREADPOOL:
		bootres->nthreads += cap->size;
		break;

	case CAP_RTYPE_SPACEPOOL:
		bootres->nspaces += cap->size;
		break;

	case CAP_RTYPE_MUTEXPOOL:
		bootres->nmutex += cap->size;
		break;

	case CAP_RTYPE_MAPPOOL:
		/* Speficies how many pmds can be mapped */
		bootres->npmds += cap->size;
		break;

	case CAP_RTYPE_CAPPOOL:
		/* Specifies how many new caps can be created */
		bootres->ncaps += cap->size;
		break;
	}

	if (cap_type(cap) == CAP_TYPE_MAP_VIRTMEM) {
		memcap_unmap(&kres->virtmem_used,
			     &kres->virtmem_free,
			     cap->start, cap->end);
	} else if (cap_type(cap) == CAP_TYPE_MAP_PHYSMEM) {
		if (!cap_is_devmem(cap))
			memcap_unmap(&kres->physmem_used,
				     &kres->physmem_free,
				     cap->start, cap->end);
		else /* Delete device from free list */
			memcap_request_device(&kres->devmem_free, cap);
	}

	return ret;
}

/*
 * Initializes the kernel resources by describing both virtual
 * and physical memory. Then traverses cap_info structures
 * to figure out resource requirements of containers.
 */
int setup_boot_resources(struct boot_resources *bootres,
			 struct kernel_resources *kres)
{
	struct cap_info *cap;

	init_kernel_resources(kres);

	/* Number of containers known at compile-time */
	bootres->nconts = CONFIG_CONTAINERS;

	/* Traverse all containers */
	for (int i = 0; i < bootres->nconts; i++) {
		/* Traverse all pagers */
		for (int j = 0; j < cinfo[i].npagers; j++) {
			int ncaps = cinfo[i].pager[j].ncaps;

			/* Count all capabilities */
			bootres->ncaps += ncaps;

			/* Count all resources */
			for (int k = 0; k < ncaps; k++) {
				cap = &cinfo[i].pager[j].caps[k];
				process_cap_info(cap, bootres, kres);
			}
		}
	}

	return 0;
}

/*
 * Initializes all system resources and handling of those
 * resources. First descriptions are done by allocating from
 * boot memory, once memory caches are initialized, boot
 * memory allocations are migrated over to caches.
 */
int init_system_resources(struct kernel_resources *kres)
{
	struct boot_resources bootres;

	memset(&bootres, 0, sizeof(bootres));

	setup_boot_resources(&bootres, kres);

	init_resource_allocators(&bootres, kres);

	setup_kernel_resources(&bootres, kres);

	return 0;
}

