//
// Copyright 2016 Jeff Bush
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

#include "kernel_heap.h"
#include "libc.h"
#include "slab.h"

void *slab_alloc(struct slab_allocator *sa)
{
    void *object = 0;
    int old_flags;

    old_flags = disable_interrupts();
    acquire_spinlock(&sa->lock);
    if (sa->free_list)
    {
        // Grab freed object
        object = sa->free_list;
        sa->free_list = *((void**) object);
    }
    else
    {
        // If there is no wilderness, or the slab is full, create a new
        // wilderness slab
        if (sa->wilderness_slab == 0
                || sa->wilderness_offset + sa->object_size > sa->slab_size)
        {
            sa->wilderness_slab = kmalloc(sa->slab_size);
            sa->wilderness_offset = 0;
        }

        object = (void*)((char*) sa->wilderness_slab + sa->wilderness_offset);
        sa->wilderness_offset += sa->object_size;
    }

    release_spinlock(&sa->lock);
    restore_interrupts(old_flags);

    return object;
}

void slab_free(struct slab_allocator *sa, void *object)
{
    int old_flags;

    old_flags = disable_interrupts();
    acquire_spinlock(&sa->lock);
    *((void**) object) = sa->free_list;
    sa->free_list = object;
    release_spinlock(&sa->lock);
    restore_interrupts(old_flags);
}
