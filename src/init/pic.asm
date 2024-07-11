init_pic:
  mov al, 0x11
  out 0x20, al
  mov al, 0x11
  out 0xA0, al

  mov al, 0x20
  out 0x21, al
  mov al, 0x28
  out 0xA1, al

  mov al, 4
  out 0x21, al
  mov al, 2
  out 0xA1, al

  mov al, 1
  out 0x21, al
  mov al, 1
  out 0xA1, al

rtc_poll:
  mov al, 0x0A
  out 0x70, al
  in al, 0x71
  test al, 0x80 ; read data
  jne rtc_poll
  mov al, 0x0A
  out 0x70, al
  mov al, 001001b ; 768 KHZ
  out 0x71, al
  mov al, 0x0B
  out 0x70, al
  in al, 0x71
  push rax
  mov al, 0x0B
  out 0x70, al
  pop rax
  bts ax, 6
  out 0x71, al

  in al, 0x21
  mov al, 11111001b
  out 0x21, al
  in al, 0xA1
  mov al, 11111110b
  out 0xA1, al

  sti

  mov al, 0x0C
  out 0x70, al
  in al, 0x71

  mov al, 0x36
  out 0x43, al
  mov al, 0x3C
  out 0x40, al
  mov al, 0x00
  out 0x40, al

  mov rbx, [p_Counter_RTC]
  add rbx, 2

check:
  mov rax, [p_Counter_RTC]
  cmp rax, rbx
  je check
  ret
