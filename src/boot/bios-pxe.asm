; default resolutiona 800x800
Horizontal_Resolution equ 800
Vertical_Resoltion equ 800

BITS 16
org 0x7C00

start:
  cli
  cld
  xor eax, eax
  mov ss, ax
  mov es, ax
  mov ds, ax
  mov sp, 0x7C00
  sti

do_e820:
  mov edi, 0x00006000
  xor ebx, ebx
  xor bp, bp
  mov edx, 0x0534D4150
  mov eax, 0xe820
  mov [es:di + 20], dword 1
  mov ecx, 24
  int 0x15
  jc nomemmap
  mov edx, 0x0534D4150
  cpm eax, edx
  jne nomemmap
  test ebx, ebx
  je nomemmap

nomemmap:
