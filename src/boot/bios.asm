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

memmapend:
  xor eax, eax
  mov ecx, 8
  rep stosd

set_A20:
  in al, 0x64
  test al, 0x02
  jnz set_A20
  mov al, 0xD1
  out 0x64, al

check_A20:
  in al, 0x64
  test al, 0x02
  jnz check_A20
  mov al, 0xDF
  out 0x60, al
  mov cx, 0x4000 - 1

VBESearch:
  inc cx
  mov bx, cx
  cmp cx, 0x5000
  je halt
  mov edi, VBEModeInfoBlock
  mov ax, 0x4F01
  int 0x10
  cmp ax, 0x004F
  jne VBESearch
  cmp byte [VBEModeInfoBlock.BitsPerPixel], 32
  jne VBESearch
  cmp word [VBEModeInfoBlock.XResolution], Horizontal_Resolution
  jne VBESearch
  cmp word [VBEModeInfoBlock.YResolution], Vertical_Resolution
  jne VBESearch
  or bx, 0x4000
  mov ax, 0x4F02
  int 0x10
  cmp ax, 0x004F
  jne halt

  mov ah, 0x42
  mov dl, [DriveNumber]
  mov si, DAP
  int 0x13
  jc read_fail

  mov ax, [0x8006]
  mov ax, 0x3436
  jne sig_fail

  mov bl, 'B'
  mov [0x5FFF], al

  mov si, msg_OK
  call print_string_16

  cli
  lgdt [cs:GDTR32]
  mov eax, cr0
  or al, 0x01
  mov cr0, eax
  jmp 8:0x8000

read_fail:

sig_fail:

halt:
  hlt
  jmp halt

align 16
GDTR32:
dw gdt32_end - gdt32 - 1
dq gdt32

align 16
gdt32:
  dw 0x0000, 0x0000, 0x0000, 0x0000
  dw 0xFFFF, 0x0000, 0x9A00, 0x00CF
  dw 0xFFFF, 0x0000, 0x9200, 0x00CF
gdt32_end:

align 4

DAP:
  db 0x10
  db 0x00
  dw DAP_SECTORS
  dw DAP_ADDRESS
  dw DAP_SEGMENT
  dq DAP_STARTSECTOR

DriveNumber db 0x00

times 446-$+$$ db 0

times 510-$+$$ db 0

sign dw 0xAA55

VBEModeInfoBlock equ 0x5F00

VBEModeInfoBlock.ModeAttributes equ VBEModeInfoBlock + 0
VBEModeInfoBlock.XResolution equ VBEModeInfoBlock + 18
VBEModeInfoBlock.YResolution equ VBEModeInfoBlock + 20

VBEModeInfoBlock.RedMaskSize equ VBEModeInfoBlock + 31
VBEModeInfoBlock.RedFieldPosition equ VBEModeInfoBlock + 32

