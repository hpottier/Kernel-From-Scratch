MBALIGN  equ  1 << 0
MEMINFO  equ  1 << 1
MBFLAGS  equ  MBALIGN | MEMINFO
MAGIC    equ  0x1BADB002
CHECKSUM equ -(MAGIC + MBFLAGS)
 
section .multiboot
align 4
	dd MAGIC
	dd MBFLAGS
	dd CHECKSUM
 
section .bss
align 16
stack_bottom:
resb 16384
stack_top:
 
section .text
global _start_kfs:function (_start_kfs.end - _start_kfs)
_start_kfs:
	mov esp, stack_top
 
	extern kfs_main
	call kfs_main
 
	cli
.hang:	hlt
	jmp .hang
.end:
