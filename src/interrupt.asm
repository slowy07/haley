exception_gate:
exception_gate_halt:
  cli
  hlt
  jmp exception_gate_halt

interrupt_gate:
  iretq

align 16
timer:
  push rax
  add qword [p_Counter_Timer], 1
  mov al,0x20
  out 0x20, al
  pop rax
  iretq

align 16
keyboard:
  push rdi
  push rax

  xor eax, eax
  in al, 0x60
  test al, 0x80
  jnz keyboard_done

keyboard_done:
  mov al, 0x20
  out 0x20, al
  pop rax
  pop rdi
  iretq

cascade:
  push rax
  mov al, 0x20
  out 0x20, al
  pop rax
  iretq

align 16
rtc:
  push rdi
  push rax

  add qword [p_Counter_RTC], 1
  mov al, 0x0C
  out 0x70, al
  in al, 0x71

  mov al, 0x20
  out 0xA0, al
  out 0x20, al

  pop rax
  pop rdi
  iretq

align 16
spurious:
  iretq

exception_gate_00:
  mov al, 0x00
  jmp exception_gate_main

exception_gate_01:
  mov al, 0x01
  jmp exception_gate_main

exception_gate_02: 
  mov al, 0x02
  jmp exception_gate_main

exception_gate_03:
  mov al, 0x03
  jmp exception_gate_main

exception_gate_04:
	mov al, 0x04
	jmp exception_gate_main

exception_gate_05:
	mov al, 0x05
	jmp exception_gate_main

exception_gate_06:
	mov al, 0x06
	jmp exception_gate_main

exception_gate_07:
	mov al, 0x07
	jmp exception_gate_main

exception_gate_08:
	mov al, 0x08
	jmp exception_gate_main

exception_gate_09:
	mov al, 0x09
	jmp exception_gate_main

exception_gate_10:
	mov al, 0x0A
	jmp exception_gate_main

exception_gate_11:
	mov al, 0x0B
	jmp exception_gate_main

exception_gate_12:
	mov al, 0x0C
	jmp exception_gate_main

exception_gate_13:
	mov al, 0x0D
	jmp exception_gate_main

exception_gate_14:
	mov al, 0x0E
	jmp exception_gate_main

exception_gate_15:
	mov al, 0x0F
	jmp exception_gate_main

exception_gate_16:
	mov al, 0x10
	jmp exception_gate_main

exception_gate_17:
  mov al, 0x11
	jmp exception_gate_main

exception_gate_18:
	mov al, 0x12
	jmp exception_gate_main

exception_gate_19:
	mov al, 0x13
	jmp exception_gate_main

exception_gate_main:
  mov rsi, message_error
  call debug_msh

  mov rdi, [0x00005F00]
  mov rcx, [0x00005F08]
  shr rcx, 2
  mov eax, 0x00FF0000
  rep stosd

exception_gate_main_hang:
  hlt
  jmp exception_gate_main_hang

create_gate:
  push rdi
  push rax

  shl rdi, 4
  stosw
  shr rax, 16
  add rdi, 4
  stosw
  shr rax, 16
  stosd

  pop rax
  pop rdi
  ret
