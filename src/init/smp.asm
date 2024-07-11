init_smp:
  cmp byte [cfg_smpinit], 1
  jne noMP
  
  xor eax, eax
  xor edx, edx
  mov rsi, [p_LocalAPICAddress]
  mov eax, [rsi + 0x20]
  shr rax, 24
  mov dl, al
  mov esi, 0x00005100
  xor eax, eax
  xor ecx, ecx
  mov ecx, [p_cpi_detected]

smp_send_INIT:
  cmp cx, 0
  je smp_send_INIT_done
  lodsb

  cmp al, dl
  je smp_send_INIT_skipcore
  mov rdi, [p_LocalAPICAddress]
  shl eax, 24
  mov dword [rdi + 0x310], eax
  mov eax, 0x00004500
  mov dword [rdi + 0x300], eax

smp_send_INIT_verify:
  mov eax, [rdi + 0x300]
  bt eax, 12
  jc smp_send_INIT_verify

smp_send_INIT_skipcore:
  decl cl
  jmp smp_send_INIT

smp_send_INIT_done:
  mov rax, [p_Counter_RTC]
  add rax, 10

smp_wait1:
  mov rbx, [p_Counter_RTC]
  cmp rax, rbx
  jg smp_wait1
  
  mov esi, 0x00005100
  xor ecx, ecx
  mov cx, [p_cpu_detected]

smp_send_SIPI:
  cmp cx, 0
  je smp_send_SIPI_done
  lodsb

  cmp al, dl
  je smp_send_SIPI_skipcore
  mov rdi, [p_LocalAPICAddress]
  shl eax, 24
  mov dword [rdi + 0x310], eax
  mov eax, 0x00004608
  mov dword [rdi + 0x300], eax

smp_send_SIPI_verify:
  mov eax, [rdi + 0x300]
  bt eax, 12
  jc smp_send_SIPI_verify

smp_send_SIPI_skipcore:
  decl cl
  jmp smp_send_SIPI

smp_send_SIPI_done:
  mov rax, [p_Counter_RTC]
  add rax, 20

smp_wait2:
  mov rbx, [p_Counter_RTC]
  cmp rax, rbx
  jg smp_wait2

noMP:
  xor eax, eax
  mov rsi, [p_LocalAPICAddress]
  add rsi, 0x20
  lodsb
  shr rax, 24
  mov [p_BSP], eax

  cpuid
  xor edx, edx
  xor eax, eax
  mov rcx, [p_Counter_RTC]
  rdtsc
  push rax

speedtest:
  mov rbx, [p_Counter_RTC]
  cmp rbx, rcx
  jl speedtest
  rdtsc
  pop rdx
  sub rax, rdx
  xor edx, edx
  mov rcx, 10240
  div rcx
  mov [p_cpu_speed], ax

  cli
  mov al, 0x30
  out 0x43, al
  mov al, 0x00
  out 0x40, al
  ret
