BITS 64
ORG 0x00008000
HALEY64SIZE equ 4096

start:
  jmp bootmode
  nop
  db 0x36, 0x34
