; 
; Copyright 2013 Jeff Bush
; 
; Licensed under the Apache License, Version 2.0 (the "License");
; you may not use this file except in compliance with the License.
; You may obtain a copy of the License at
; 
;     http://www.apache.org/licenses/LICENSE-2.0
; 
; Unless required by applicable law or agreed to in writing, software
; distributed under the License is distributed on an "AS IS" BASIS,
; WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
; See the License for the specific language governing permissions and
; limitations under the License.
; 

					.text
					.globl _start
					.align 4
					.type _start,@function
_start:				
					; Set up stack
					getcr s0, 0			; get my strand ID
					shl s0, s0, 14		; 16k bytes per stack
					load.32 sp, stacks_base
					sub.i sp, sp, s0	; Compute stack address

					; Only thread 0 does initialization.  Skip for 
					; other threads.
					btrue s0, skip_init

					; Call global initializers
					sub.i sp, sp, 64
					load.32 s0, init_array_start
					store.32 s0, 60(sp)
init_loop:			load.32 s0, 60(sp)
					load.32 s1, init_array_end
					seteq.i s2, s0, s1
					btrue s2, init_done
					load.32 s2, (s0)
					add.i s0, s0, 4
					store.32 s0, 60(sp)
					call s2
					goto init_loop
init_done:			add.i sp, sp, 64


					; Start all threads
					move s0, 15
					setcr s0, 30

skip_init:

					call main
					setcr s0, 29		; Stop thread
done:				goto done

stacks_base:		.word 0x100000
init_array_start:	.word __init_array_start
init_array_end:		.word __init_array_end
