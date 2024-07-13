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
  jmp jmpin

e820lp:
  mov eax, 0xe820
  mov [rs:di + 20], dword 1
  mov ecx, 24
  int 0x15
  jc memmapend
  mov edx, 0x0534D4150

jmpin:
  jcxz skipent
  cmp cl, 20
  jbe notext
  test byte [es:di + 20], 1
  je skipent

notext:
  mov ecx, [es:di + 8]
  test ecx, ecx
  jne goodent
  mov ecx, [es:di + 12]
  jecxz skipent

goodent:
  inc bp
  add di, 32

skipent:
  test ebx, ebx
  jne e820lp

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

msg_Load db "PXE ", 0
msg_OK db "OK", 0
msg_SigFail db "- Bad Sig!", 0

times 510-$+$$ db 0

sign dw 0xAA55
times 1024-$+$$ db 0

VBEModeInfoBlock: equ 0x5F00

VBEModeInfoBlock.ModeAttributes equ VBEModeInfoBlock + 0
VBEModeInfoBlock.PhysBasePtr equ VBEModeInfoBlock + 40
VBEModeInfoBlock.Reserved1 equ VBEModeInfoBlock + 44
VBEModeInfoBlock.Reserved2 equ VBEModeInfoBlock + 48
