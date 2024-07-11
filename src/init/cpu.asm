init_cpu:
  mov rax, cr0
  btr rax, 29
  bts rax, 30
  mov cr0, rax

  wbinvd

  mov rax, cr3
  mov cr3, rax

  mov ecx, IA32_MTRRCAP
  rdmsr

  mov ecx, IA32_MTRR_DEF_TYPE
  rdmsr
  btc eax, 11
  btc eax, 10
  wrmsr

  mov ecx, IA32_MTRR_DEF_TYPE
  rdmsr
  bts eax, 11
  wrmsr

  mov rax, cr3
  mov cr3, rax

  wbinvd

  mov rax, cr0
  btr rax, 29
  btr rax, 30
  mov cr0, rax

  mov rax, cr0
  bts rax, 1
  btr rax, 2
  mov cr0, rax

  finit

  mov eax, 1
  cpuid
  bt ecx, 28
  jnc avx_not_supported

avx_supported:
  mov rax, cr4
  bts rax, 18
  mov cr4, rax
  mov rcx, 0
  xgetbv
  bts rax, 0
  bts rax, 1
  bts rax, 2
  xsetbv

avx_not_supported:
  mov ecx, APIC_TPR
  mov eax, 0x00000020
  call apic_write
  mov ecx, APIC_LVT_PERF
  mov eax, 0x00010000
  call apic_write
  mov ecx, APIC_LDR
  xor eax, eax
  call apic_write
  mov ecx, APIC_DFR
  not eax
  call apic_write
  mov ecx, APIC_LVT_LINT0
  mov eax, 0x00008700
  call apic_write
  mov ecx, APIC_LVT_LINT1
  mov eax, 0x00000400
  call apic_write
  mov ecx, APIC_LVT_ERR
  mov eax, 0x00010000
  call apic_write
  mov ecx, APIC_SPURIOUS
  mov eax, 0x000001FF
  call apic_write

  loc inc word [p_cpu_activated]
  mov ecx, APIC_ID
  call apic_read
  shr rax, 24
  mov rdi, 0x00005700
  add rdi, rax
  mov al, 1
  stosb

  ret

apic_read:
  push rsi
  mov rsi, [p_LocalAPICAddress]
  add rsi, rcx
  lodsd
  pop rsi
  ret

apic_write:
  push rdi
  mov rdi, [p_LocalAPICAddress]
  add rdi, rcx
  stosd
  pop rdi
  ret

APIC_ID equ 0x020
APIC_VER equ 0x030
APIC_TPR equ 0x080
APIC_APR equ 0x090
APIC_EOI equ 0x0B0
APIC_RRD equ 0x0C0
APIC_LDR equ 0x0D0
APIC_DFR equ 0x0E0
APIC_SPURIOUS equ 0x0F0
APIC_ISR equ 0x100
APIC_TMR equ 0x180
APIC_IRR equ 0x200
APIC_ESR equ 0x280
APIC_ICRL equ 0x300
APIC_LVT_TMR equ 0x310
APIC_LVT_TSR equ 0x320
APIC_LVT_PERF equ 0x330
APIC_LVT_LINT0 equ 0x340
APIC_LVT_LINT1 equ 0x350
APIC_LVT_ERR equ 0x370
APIC_TMRINITCNT equ 0x380
APIC_TRMCURRCNT equ 0x390
APIC_TMRDIV equ 0x3E0

IA32_APIC_BASE equ 0x01B
IA32_MTRRCAP equ 0x0FE
IA32_MISC_ENABLE equ 0x1A0
IA32_MTRR_PHYSBASE0 equ 0x200
IA32_MTRR_PHYSMASK0	equ 0x201
IA32_MTRR_PHYSBASE1	equ 0x202
IA32_MTRR_PHYSMASK1	equ 0x203
IA32_MTRR_DEF_TYPE	equ 0x2FF

