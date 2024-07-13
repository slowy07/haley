%define DAP_SECTORS 64
%define DAP_STARTSECTOR 2562160
%define DAP_ADDRESS 0x8000
%define DAP_SEGMENT 0x0000

; resolution 800x800
Horizontal_Resolution equ 800
Vertical_Resolution equ 800

BITS 16
org 0x7C00
entry:
  jmp bootcode
  nop

dq 0
dw 0
db 0
dw 0
db 0
dw 0
dw 0
db 0
dw 0
dw 0
dw 0
dd 0
dd 0

dd 0
dw 0
dw 0
dd 0
dw 0
dw 0
dq 0
dd 0
db 0
db 0
db 0
dd 0
times 11 db 0
dq 0

bootcode:
  cli
  cld
  xor eax, eax
  mov ss, ax
  mov es, ax
  mov ds, ax
  mov sp, 0x7C00
  sti
  mov [DriveNumber], dl

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
  cmp eax, edx
  jne nomemmap
  test ebx, ebx
  je nomemmap
  jmp jmpin

nomemmap:

