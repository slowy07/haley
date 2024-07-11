message_haley64: db 10, 'Haley ', 0
message_ok: db 'OK', 10, 0
message_error: db 'Error', 10, 0

cfg_init: db 1

InfoMap: equ 0x0000000000005000
IM_PCIE: equ 0x0000000000005400
IM_IOAPICAddress: equ 0x0000000000005600
IM_IOAPICIntSource: equ 0x0000000000005700
SystemVariables: equ 0x0000000000005800
VBEModeInfoBlock: equ 0x0000000000005F00

P_ACPITableAddress: equ SystemVariables + 0x00
P_LocalAPICAddress: equ SystemVariables + 0x10
P_Counter_Timer: equ SystemVariables + 0x18
P_Counter_RTC: equ SystemVariables + 0x20
P_HPETAddress: equ SystemVariables + 0x28

P_BSP: equ SystemVariables + 0x80
P_mem_account: equ SystemVariables + 0x84

p_cpu_speed: equ SystemVariables + 0x100
p_cpu_activated: equ SystemVariables + 0x102
p_cpu_detected: equ SystemVariables + 0x104
p_PCIECount: equ SystemVariables + 0x106
p_HPETCounterMin: equ SystemVariables + 0x108

p_IOAPICCount: equ SystemVariables + 0x180
p_BootMode: equ SystemVariables + 0x181
p_IOAPICIntSourceC: equ SystemVariables + 0x182
p_x2APIC: equ SystemVariables + 0x183

align 16
GDTR32:
  dw gdt32_end - gdt32 - 1
  dq gdt32

align 16
gdt32:
  dq 0x0000000000000000
  dq 0x00CF9A000000FFFF
  dq 0x00CF92000000FFFF

gdt32_end:
  
align 16
tGDTR64:
  dw gdt64_end - gdt64 - 1
  dq gdt64

align 16
GDTR64:
  dw gdt64_end - gdt64 - 1
  dq 0x0000000000001000

gdt64:
  SYS64_NULL_SEL equ $-gdt64
  dq 0x0000000000000000
  STS64_CODE_SEL equ $-gdt64
  dq 0x00209A0000000000
  SYS64_DATA_SEL equ $-gdt64
  dq 0x0000920000000000
gdt64_end:

IDTR64:
  dw 256 * 16 - 1
  dq 0x0000000000000000
