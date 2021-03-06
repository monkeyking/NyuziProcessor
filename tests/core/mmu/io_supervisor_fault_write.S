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

#include "mmu_test_common.h"

//
// Ensure writing to an supervisor I/O page while in user mode faults.
// Similar to data_supervisor_fault_write, but to an I/O mapped page, which is
// treated differently in hardware.
// (I/O pages are those mapped from 0xffff0000-0xffffffff, which are uncached
// and use a separate peripheral bus)
// XXX does not check that the I/O address wasn't written, just that it faults.
// Should add this.
//
                .globl _start
_start:         mmu_fault_test (TT_SUPERVISOR_ACCESS | TRAP_CAUSE_STORE | TRAP_CAUSE_DCACHE), store_32, 0x2350, itlb_entries, dtlb_entries, FLAG_MMU_EN
                call pass_test

itlb_entries:   .long 0x00001000, 0x00001000 | TLB_PRESENT | TLB_EXECUTABLE
                .long 0xffffffff, 0xffffffff

dtlb_entries:   .long 0x00001000, 0x00001000 | TLB_PRESENT
                .long 0x00002000, 0xffff0000 | TLB_PRESENT | TLB_SUPERVISOR
                .long 0xffff0000, 0xffff0000 | TLB_PRESENT | TLB_WRITABLE    // I/O area
                .long 0xffffffff, 0xffffffff
