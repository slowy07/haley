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

check_A20:
  in al, 0x64
  test al, 0x02
  jnz check_A20
  mov al, 0xDF
  out 0x60, al

  mov si, msg_load
  call print_string_16
  
  mov edi, VBEModeInfoBlock
  mov ax, 0x4F01

  mov cx, 0x4118
  mov bx, cx
  int 0x10

  cmp ax, 0x004F
  jne halt
  cmp byte [VBEModeInfoBlock.BitsPerPixel], 24
  jne halt
  or bx, 0x4000
  mov ax, 0x4F02
  int 0x10
  cmp ax, 0x004F
  jne halt

  mov ax, [0x8006]
  cmp ax, 0x3436
  jne sig_fail
  
  mov si, msg_OK
  call print_string_16

  mov bl, 'B'

  cli
  lgdt [cs:GDTR32]
  mov eax, cr0
  or al, 0x01
  mov cr0, eax
  jmp 8:0x8000

sig_fail:
  mov si, msg_SigFail
  call print_string_16

halt:
  hlt
  jmp halt

print_string_16:
  pusha
  mov dx, 0

.repeat:
  mov ah, 0x01
  lodsb
  cmp al, 0
  je .done
  int 0x14
  jmp short .repeat

.done:
  popa
  ret

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
VBEModeInfoBlock.WinAttributes equ VBEModeInfoBlock + 2
VBEModeInfoBlock.WinBAttributes equ VBEModeInfoBlock + 3
VBEModeInfoBlock.WinGranularity equ VBEModeInfoBlock + 4
VBEModeInfoBlock.WinSize equ VBEModeInfoBlock + 6
VBEModeInfoBlock.WinASegment equ VBEModeInfoBlock + 8
VBEModeInfoBlock.WinBSegment equ VBEModeInfoBlock + 10
VBEModeInfoBlock.WinFuncPtr equ VBEModeInfoBlock + 12
VBEModeInfoBlock.BytesPerScanline equ VBEModeInfoBlock + 16
VBEModeInfoBlock.XResolution equ VBEModeInfoBlock + 18
VBEModeInfoBlock.PhysBasePtr equ VBEModeInfoBlock + 40
VBEModeInfoBlock.Reserved1 equ VBEModeInfoBlock + 44
VBEModeInfoBlock.Reserved2 equ VBEModeInfoBlock + 48
