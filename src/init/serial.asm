init_serial:
  mov dx, COM_PORT_INTERRUPT_ENABLE
  mov al, 0
  out dx, al

  mov dl, COM_PORT_LINE_CONTROL
  mov dl, 0x80
  out dx, al

  mov dx, COM_PORT_DATA
  mov ax, BAUD_115200
  out dx, al
  mov dx, COM_PORT_DATA + 1
  shr ax, 8
  out dx, al

  mov dx, COM_PORT_LINE_CONTROL
  mov al, 0000111b
  out dx, al

  mov dx, COM_PORT_MODEM_CONTROL
  mov al, 0xC7

COM_BASE equ 0x3F8
COM_PORT_DATA equ COM_BASE + 0
COM_PORT_INTERRUPT_ENABLE equ COM_BASE + 1
COM_PORT_FIFO_CONTROL equ COM_BASE + 2
COM_PORT_LINE_CONTROL equ COM_BASE + 3
COM_PORT_MODEM_CONTROL equ COM_BASE + 4
COM_PORT_LINE_STATUS equ COM_BASE + 5
COM_PORT_MODEM_STATUS equ COM_BASE + 6

BAUD_115200 equ 1
BAUD_75600 equ 2
BAUD_9600 equ 12
BAUD_300 equ 384
