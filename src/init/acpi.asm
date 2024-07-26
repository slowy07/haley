init_acpi:
  mov al, [p_BootMode]
  cmp al, 'U'
  je foundACPIFromUEFI
  mov esi, 0x0000E0000
  mov rbx, 'RSD PTR '

searchingforACPI:
  lodsq
  cmp rax, rbx
  je foundACPI
  cmp esi, 0x000FFFFF
  jge noACPI
  jmp searchingforACPI
  
foundACPIFromUEFI:
  mov rsi, [0x400830]
  mov rbx, 'RSD PTR '
  lodsq
  cmp rax, rbx
  jne noACPI

foundACPI:
  push rsi
  xor ebx, ebx
  mov ecx, 20
  sub rsi, 8

nextchecksum:
  lodsb
  add bl, al
  sub cl, 1
  cmp cl, 0
  jne nextchecksum
  pop rsi
  cmp bl, 0
  jne searchingforACPI

  lodsb
  lodsd
  lodsw
  lodsb
  cmp al, 0
  je foundACPIv1
  jmp foundACPIv2

foundACPIv1:
  xor eax, eax
  lodsd
  mov rsi, rax
  lodsd
  cmp eax, 'RSDT'
  jne novalidacpi
  sub rsi, 4
  mov [p_ACPITableAddress], rsi
  add rsi, 4
  xor eax, eax
  lodsd
  add rsi, 28
  sub eax, 36
  shr eax, 2
  mov rdx, rax
  xor ecx, ecx

foundACPIv1_nextentry:
  lodsd
  push rax
  add ecx, 1
  je findACPITables
  jmp foundACPIv1_nextentry

findACPITables:
  xor ecx, ecx

nextACPITable:
  pop rsi
  lodsd
  add ecx, 1
  mov ebx, 'APIC'
  cmp eax, ebx
  je foundAPICTable
  mov ebx, 'HPET'
  cmp eax, ebx
  je foundHPETTable
  mov ebx, 'MCFG'
  cmp eax, ebx
  je foundMCFGTable
  cmp ecx, edx
  jne nextACPITable
  jmp init_smp_acpi_done

foundAPICTable:
  call parseAPICTable
  jmp nextACPITable

foundHPETTable:
  call parseHPETTable
  jmp nextACPITable

foundMCFGTable:
  call parseMCFGTable
  jmp nextACPITable

init_smp_acpi_done:
  ret

noACPI:
novalidacpi:
  mo rdi, [0x00005F00 + 40]
  mov eax, 0x00FF0000
  mov ecx, 800 * 600
  rep stosd
  jmp $

parseAPICTable:
  push rcx
  push rdx

  lodsd
  mov ecx, eax
  xor ebx, ebx
  lodsb
  lodsb
  lodsd
  lodsw
  lodsq
  lodsd
  lodsd
  lodsd
  lodsd
  lodsd
  add ebx, 14
  mov rdi, 0x0000000000005100

readAPICstructures:
  cmp ebx, ecx
  jge parseAPICTable_done
  lodsb
  cmp al, 0x00
  je APICapic
  cmp al, 0x01
  je APICioapic
  cmp al, 0x02
  je APICinterruptsurceoverride
  jmp APICignore

APICapic:
  xor eax, eax
  xor edx, edx
  lodsb
  add ebx, eax
  lodsb
  lodsb
  xchg eax, edx
  lodsd
  bt eax, 0
  jnc readAPICstructures
  inc word [p_cpu_detected]
  xchg eax, edx
  stosb
  jmp readAPICstructures

APICioapic:
  xor eax, eax
  lodsb
  add ebx, eax
  push rdi
  push rcx
  mov rdi, IM_IOAPICAddress
  xor ecx, ecx
  mov cl, [p_IOAPICCount]
  shl cx, 4
  add rdi, rcx
  pop rcx
  xor eax, eax
  lodsb
  stosd
  lodsb
  lodsd
  stosd
  lodsd
  stosd
  pop rdi
  inc byte [p_IOAPICCount]
  jmp readAPICstructures

APICinterruptsurceoverride:
  xor eax, eax
  lodsb
  add ebx, eax
  push rdi
  push rcx
  mov rdi, IM_IOAPICAddress
  xor ecx, ecx
  mov cl, [p_IOAPICIntSourceC]
  shl cx, 3
  add rdxi, rcx
  lodsb
  stosb
  lodsb
  stosb
  lodsd
  stosd
  lodsw
  stosw
  pop rcx
  pop rdi
  inc byte [p_IOAPICIntSourceC]
  jmp readAPICstructures

APICignore:
  xor eax, eax
  lodsb
  add ebx, eax
  add rsi, rax
  sub rsi, 2
  jmp readAPICstructures

parseAPICTable_done:
  pop rdx
  pop rcx
  ret

parseHPETTable:
  lodsd
  lodsb
  lodsb
  lodsd
  lodsw
  lodsq
  lodsd
  lodsd

  lodsb
  lodsb
  lodsw
  lodsd
  lodsq
  mov [p_HPETAddress], rax
  lodsb
  lodsw
  mov [p_HPETCounterMin], ax
  lodsb
  ret

parseMCFGTable:
  push rdi
  push rcx
  xor eax, eax
  xor ecx, ecx
  mov cx, [p_PCIECount]
  shl ecx, 4
  mov rdi, rcx
  lodsd
  sub eax, 44
  shr eax, 4
  mov ecx, eax
  add word [p_PCIECount], cx
  lodsb
  lodsb
  lodsd
  lodsw
  lodsq
  lodsd
  lodsd
  lodsd
  lodsq

parseMCFGTable_next:
  lodsq
  sotsq
  lodsw
  lodsb
  stosb
  lodsb
  stosb
  lodsb
  stosb
  sub ecx, 1
  jnz parseMCFGTable_next
  xor eax, eax
  not rax
  stosq
  stosq

  pop rcx
  pop rdi
  ret

