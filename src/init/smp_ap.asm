BITS 16

init_smp_ap:
set_A20_ap:
  in al, 0x64
  test al, 0x02
  jnz set_A20_ap
  mov al, 0xD1
  out 0x64, al

check_A20_ap:
  in al, 0x64
  test al, 0x02
  jnz check_A20_ap
  mov al, 0xDF
  out 0x060, al

  lgdt [cs:GDTR32]
  mov eax, cr0
  or al, 1
  mov cr0, eax
  jmp 8:startap32

align 16

BITS 32
startap32:
  mov eax, 16
  mov ds, ax
  mov es, ax
  mov fs, ax
  mov gs, ax
  mob ss, ax
  xor eax, eax
	xor ebx, ebx
	xor ecx, ecx
	xor edx, edx
	xor esi, esi
	xor edi, edi
	xor ebp, ebp
  mov esp, 0x7000

  lgdt [GDTR64]
  
  mov eax, cr4
  or eax, 0x0000000B0
  mov cr4, eax

  mov eax, 0x00002008
  mov cr3, eax

  mov ecx, 0xC0000080
  rdmsr
  or eax, 0x00000101
  wrmsr
  
  mov eax, cr0
  or eax, 0x80000000
  mov cr0, eax

  jmp SYS64_CODE_SEL:startap64

align 16

BITS 64
startap64:
  xor eax, eax
  xor ebx, ebx
  xor ecx, ecx
  xor edx, edx
  xor esi, esi
  xor edi, edi
  xor ebp, ebp
  xor esp, esp
  xor r8, r8
  xor r9, r9

  xor r10, r10
	xor r11, r11
	xor r12, r12
	xor r13, r13
	xor r14, r14
	xor r15, r15

  mov ax, 0x10
  mov ds, ax
  mov es, ax
  mov ss, ax
  mov fs, ax
  mov gs, ax

  mov rsi, [p_LocalAPICAddress]
  add rsi, 0x20
  lodsd
  shr rax, 24
  shl rax, 10
  add rax, 0x0000000000090000
  mov rsp, rax

  lgdt [GDTR64]
  lidt [IDTR64]

  call init_cpu
  sti
align 16

ap_sleep:
  hlt
  jmp ap_sleep
