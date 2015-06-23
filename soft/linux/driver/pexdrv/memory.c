
#include <linux/kernel.h>
#define __NO_VERSION__
#include <linux/module.h>
#include <linux/types.h>
#include <linux/ioport.h>
#include <linux/pci.h>
#include <linux/pagemap.h>
#include <linux/interrupt.h>
#include <linux/proc_fs.h>
#include <asm/io.h>

#include "memory.h"
#include "pexmodule.h"

//--------------------------------------------------------------------

int lock_pages( void *va, u32 size )
{
    struct page *start_page_addr = virt_to_page(va);
    int i = 0;

    for (i=0; i < (size >> PAGE_CACHE_SHIFT); i++) {
        SetPageReserved(start_page_addr+i);
        //dbg_msg(dbg_trace, "%s(): page_addr[%d] = 0x%x\n", __FUNCTION__, i, (int)(start_page_addr+i));
    }

    return i;
}

//--------------------------------------------------------------------

int unlock_pages( void *va, u32 size )
{
    struct page *start_page_addr = virt_to_page(va);
    int i = 0;

    for (i=0; i < (size >> PAGE_CACHE_SHIFT); i++) {
        ClearPageReserved(start_page_addr+i);
        //dbg_msg(dbg_trace, "%s(): page_addr[%d] = 0x%x\n", __FUNCTION__, i, (int)(start_page_addr+i));
    }

    return i;
}

//--------------------------------------------------------------------

//--------------------------------------------------------------------
/*
static int copy_memory_descriptors(unsigned long arg, struct memory_descriptor *md, struct memory_block **mb)
{
    struct memory_block *mblocks = NULL;
    int error = 0;
    //int i = 0;

    if(copy_from_user((void*)md, (void*)arg, sizeof(struct memory_descriptor))) {
        err_msg(err_trace, "%s(): Error copy memory descriptor from user space\n", __FUNCTION__);
        error = -EINVAL;
        goto do_exit;
    }

    dbg_msg(dbg_trace, "%s(): md.total_blocks = %zd\n", __FUNCTION__, md->total_blocks );
    dbg_msg(dbg_trace, "%s(): md.blocks = %p\n", __FUNCTION__, md->blocks );

    mblocks = kzalloc(md->total_blocks*sizeof(struct memory_block), GFP_KERNEL);
    if(!mblocks) {
        err_msg(err_trace, "%s(): Error allocate memory for memory descriptors\n", __FUNCTION__);
        error = -ENOMEM;
        goto do_exit;
    }

    if(copy_from_user((void*)mblocks, (void*)md->blocks, md->total_blocks*sizeof(struct memory_block))) {
        err_msg(err_trace, "%s(): Error copy memory blocks from user space\n", __FUNCTION__);
        error = -EINVAL;
        goto do_free_mem;
    }

    //for(i=0; i<md->total_blocks; i++) {
    //    dbg_msg(dbg_trace, "%s(): mb[%d].size = 0x%x\n", __FUNCTION__, i, mblocks[i].size );
    //}

    *mb = mblocks;

    return 0;

do_free_mem:
    kfree(mb);

do_exit:
    return error;
}
*/
//-----------------------------------------------------------------------------

int lock_user_pages(unsigned long addr, int size)
{
    //int res = 0;
    //res = get_user_pages(current, current->mm, unsigned long start, int nr_pages, int write, int force,
    //                     struct page **pages, struct vm_area_struct **vmas);
    return -1;
}

//-----------------------------------------------------------------------------

void* allocate_memory_block(struct pex_device *brd, size_t block_size, dma_addr_t *dma_addr)
{
    struct mem_t *m = NULL;
    void *cpu_addr = NULL;
    dma_addr_t dma_handle = {0};
    int locked = 0;

    spin_lock(&brd->m_MemListLock);

    m = (struct mem_t*)kzalloc(sizeof(struct mem_t), GFP_KERNEL);
    if(!m) {
        err_msg(err_trace, "%s(): Error allocate memory for mem_t descriptor\n", __FUNCTION__);
        goto do_exit;
    }

    cpu_addr = dma_alloc_coherent(&brd->m_pci->dev, block_size, &dma_handle, GFP_KERNEL);
    if(!cpu_addr) {
        err_msg(err_trace, "%s(): Error allocate physical memory block.\n", __FUNCTION__);
        goto do_free_mem;
    }

    *dma_addr = dma_handle;
    m->dma_handle = dma_handle;
    m->cpu_addr = cpu_addr;
    m->size = block_size;

    locked = lock_pages(m->cpu_addr, m->size);

    list_add_tail(&m->list, &brd->m_MemList);

    atomic_inc(&brd->m_MemListCount);

    dbg_msg(dbg_trace, "%s(): %d: PA = 0x%zx, VA = %p, SZ = 0x%zx, PAGES = %d\n",
            __FUNCTION__, atomic_read(&brd->m_MemListCount), (size_t)m->dma_handle, m->cpu_addr, m->size, locked );

    spin_unlock(&brd->m_MemListLock);

    return cpu_addr;

do_free_mem:
    kfree(m);

do_exit:
    spin_unlock(&brd->m_MemListLock);

    return NULL;
}

//--------------------------------------------------------------------

int free_memory_block(struct pex_device *brd, struct memory_block mb)
{
    struct list_head *pos, *n;
    struct mem_t *m = NULL;
    int unlocked = 0;

    spin_lock(&brd->m_MemListLock);

    list_for_each_safe(pos, n, &brd->m_MemList) {

        m = list_entry(pos, struct mem_t, list);

        if(m->dma_handle != mb.phys)
            continue;

        unlocked = unlock_pages(m->cpu_addr, m->size);

        dma_free_coherent(&brd->m_pci->dev, m->size, m->cpu_addr, m->dma_handle);

        dbg_msg(dbg_trace, "%s(): %d: PA = 0x%zx, VA = %p, SZ = 0x%zx, PAGES = %d\n",
                __FUNCTION__, atomic_read(&brd->m_MemListCount), (size_t)m->dma_handle, m->cpu_addr, m->size, unlocked );

        list_del(pos);

        atomic_dec(&brd->m_MemListCount);

        kfree(m);
    }

    spin_unlock(&brd->m_MemListLock);

    return 0;
}

//--------------------------------------------------------------------

