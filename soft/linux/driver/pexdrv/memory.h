
#ifndef _MEMORY_H_
#define _MEMORY_H_

//-----------------------------------------------------------------------------

struct address_t {

    size_t physical_address;
    void  *virtual_address;
    size_t size;

};

//-----------------------------------------------------------------------------

struct mem_t {

    struct list_head list;
    dma_addr_t dma_handle;
    void  *cpu_addr;
    size_t size;

};

//-----------------------------------------------------------------------------

struct dma_channel {
    int                     m_Number;
    int                     m_Use;
    struct pci_dev         *m_pci;
    spinlock_t              m_MemListLock;
    atomic_t                m_MemListCount;
    struct list_head        m_MemList;
    struct mem_t            m_MemStub;
};

//-----------------------------------------------------------------------------
struct pex_device;
struct memory_block;
//-----------------------------------------------------------------------------

int lock_pages( void *va, u32 size );
int unlock_pages( void *va, u32 size );
void* allocate_memory_block(struct pex_device *brd, size_t block_size, dma_addr_t *dma_addr);
int free_memory_block(struct pex_device *brd, struct memory_block mb);

//--------------------------------------------------------------------

#endif //_MEMORY_H_
