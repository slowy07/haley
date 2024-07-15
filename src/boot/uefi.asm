BITS 64
ORG 0x00400000
%define u(x) __utf16__(x)
  
START:
PE:
HEADER:
DOS_HEADERS:
DOS_SIGNATURE: db 'MZ', 0x00, 0x00
DOS_HEADERS: times 60-($-HEADER) db 0
SIGNATURE_POINTER: dd PE_SIGNATURE - START
DS_STUB: times 64 db 0
PE_HEADER:
PE_SIGNATURE: db 'PE', 0x00, 0x00
MACHINE_TYPE: dw 0x8664
NUMBER_OF_SECTIONS: dw 2
CREATED_DATE_TIME: dd 1670698099
SYMBOL_TABLE_POINTER: dd 0
NUMBER_OF_SYMBOLS: dd 0
OHEADER_SIZE: dw O_HEADER_END - O_HEADER
CHARACTERISTIC: dw 0x222E

O_HEADER:
MAGIC_NUMBER: dw 0x020B
MAJOR_LINKER_VERSION: db 0
MINOR_LINKER_VERSION: db 0
SIZE_OF_CODE: dd CODE_END - CODE
INITIALIZED_DATA_SIZE: dd DATA_END - DATA
UNINITIALIZED_DATA_SIZE: dd 0x00
ENTRY_POINT_ADDRESS: dd EntryPoint - START
BASE_OF_CODE_ADDRESS: dd CODE - START
IMAGE_BASE: dq 0x400000
SECTION_ALIGNMENT: dd 0x1000
FILE_ALIGNMENT: dd 0x1000
MAJOR_OS_VERSION: dw 0
MINOR_OS_VERSION: dw 0
MAJOR_IMAGE_VERSION: dw 0
MINOR_IMAGE_VERSION: dw 0
MAJOR_SUBSYS_VERSION: dw 0
MINOR_SUBSYS_VERSION: dw 0
WIN32_VERSION_VALUE: dw 0
IMAGE_SIZE: dd END - START
HEADERS_SIZE: dd HEADER_END - HEADER
CHECKSUM: dw 0
SUBSYSTEM: dw 10
DLL_CHARACTERISTICS: dw 0
STACK_RESERVE_SIZE: dq 0x200000
STACK_COMMIT_SIZE: dq 0x1000
HEAP_RESERVE_SIZE: dq 0x200000
HEAP_COMMIT_SIZE: dq 0x1000
LOADER_FLAGS: dd 0x00
NUMBER_OF_RVA_AND_SIZES: dd 0x00
O_HEADER_END:

SECTION_HEADERS:
SECTION_CODE:
  .name db ".text", 0x00, 0x00, 0x00
  .virtual_size dd CODE_END - CODE
  .size_address dd CODE - START
  .size_of_raw_data dd CODE_END - CODE
  .pointer_to_raw_data dd CODE - START
  .pointer_to_relocations dd 0
  .pointer_to_line_numbers dd 0
  .number_of_relocations dw 0
  .number_of_line_numbers dw 0
  .characteristic dd 0x70000020

SECTION_DATA:
  .name db ".data", 0x00, 0x00, 0x00, 0x00
  .virtual_size dd DATA_END - DATA
  .virtual_address dd DATA - START
  .size_of_raw_data dd DATA_END - DATA
  .pointer_to_raw_data dd DATA - START
  .pointer_to_relocations dd 0
  .pointer_to_line_numbers dd 0
  .number_of_relocations dw 0
  .number_of_line_numbers dw 0
  .characteristic dd 0xD0000040

HEADER_END:
  align 16

CODE:
EntryPoint:
  mov [EFI_IMAGE_HANDLE], rcx
  mov [EFI_SYSTEM_TABLE], rdx
  mov [EFI_RETURN], rsp
  sub sp, 6*8+8

  mov rax, [EFI_SYSTEM_TABLE]
  mov rax, [rax + EFI_SYSTEM_TABLE_BOOTSERVICES]
  mov [BS], rax
  mov rax, [EFI_SYSTEM_TABLE]
  mov rax, [rax + EFI_SYSTEM_TABLE_RUNTIMESERVICES]
  mov [RTS], rax
  mov rax, [EFI_SYSTEM_TABLE]
  mov rax, [rax + EFI_SYSTEM_TABLE_CONFIGURATION_TABLE]
  mov [CONFIG], rax
  mov rax, [EFI_SYSTEM_TABLE]
  mov rax, [rax + EFI_SYSTEM_TABLE_CONOUT]
  mov [OUTPUT], rax
  

  mov rcx, [OUTPUT]
  mov rdx, 0x07
  call [rcx + EFI_SIMPLE_TEXT_OUTPUT_PROTOCOL_SET_ATTRIBUTE]
  
  mov rcx, [OUTPUT]
  call [rcx + EFI_SIMPLE_TEXT_OUTPUT_PROTOCOL_CLEAR_SCREEN]

  mov rcx, [OUTPUT]
  lea rdx, [msg_uefi]
  call [rcx + EFI_SIMPLE_TEXT_OUTPUT_PROTOCOL_OUTPUTSTRING]

  mov rax, [EFI_SYSTEM_TABLE]
  mov rcx, [rax + EFI_SYSTEM_TABLE_NUMBEROFENTRIES]
  shl rcx, 3
  mov rsi, [CONFIG]

nextentry:
  dec rcx
  cmp rcx, 0
  je error
  mov rdx, [ACPI_TABLE_GUID]
  lodsq
  cmp rax, rdx
  jne nextentry
  mov rdx, [ACPI_TABLE_GUID + 8]
  lodsq
  cmp rax, rdx
  jne nextentry
  mov [ACPI], rax

  mov rcx, EFI_GRAPHICS_OUTPUT_PROTOCOL_GUID
  mov rdx, 0
  mov r8, VIDEO
  mov rax, [BS]
  mov rax, [rax + EFI_BOOT_SERVICES_LOCATEPROTOCOL]
  call rax
  cmp rax, EFI_SUCCESS
  jne error

  mov rcx, [VIDEO]
  add rcx, EFI_GRAPHICS_OUTPUT_PROTOCOL_MODE
  mov rcx, [rcx]
  mov rax, [rcx + 24]
  mv [FB], rax
  mov rax, [rcx + 32]
  mov [FBS], rax
  mov rcx, [rcx + 8]
  
  mov eax, [rcx + 4]
  mov [HR], rax
  mov eax, [rcx + 8]
  mov [VR], rax
  mov eax, [rcx + 32]
  mv [PPSL], rax

  mov rsi, PAYLOAD
  mov rdi, 0x8000
  mov rcx, 61440
  rep movsb
  mov ax, [0x8006]
  cmp ax, 0x3436
  jne sig_fail

get_memmap:
  mov rcx, [OUTPUT]
  lea rdx, [msg_OK]
  call [rcx + EFI_SIMPLE_TEXT_OUTPUT_PROTOCOL_OUTPUTSTRING]
  
  lea rcx, [memmapsize]
  mov rdx, [memmap]
  lea r8, [memmapkey]
  lea r9, [memmapdescsize]
  lea r10, [memmapdescver]
  mov [rsp+32], r10
  mov rax, [BS]
  call [rax + EFI_BOOT_SERVICES_GETMEMORYMAP]
  cmp al, EFI_BUFFER_TOO_SMALL
  je get_memmap
  cmp rax, EFI_SUCCESS
  jne exitfailure
  
  mov rcx, [EFI_IMAGE_HANDLE]
  mov rdx, [memmapkey]
  mov rax, [BS]
  call [rax + EFI_BOOT_SERVICE_EXITBOOTSERVICES]
  cmp rax, EFI_SUCCESS
  jne get_memmap

  cli

  mv rdi, 0x00005F00
  mov rax, [FB]
  stosq
  mov rax, [FBS]
  stosq
  mov rax, [HR]
  stosw
  mov rax, [VR]
  stosw
  mov rax, [PPSL]
  mv rax, [memmap]
  stosq
  mov rax, [memmapsize]
  stosq
  mov rax, [memmapkey]
  stosq
  mov rax, [memmapdescsize]
  stosq
  mov rax, [memmapdescver]
  stosq

  ; setting screen to black before jumpe to haley kernel
  mov rdi, [FB]
  mov eax, 0x00000000
  mov rcx, [FBS]
  shr rcx, 2
  rep stosd

  ; clear register
  xor eax, eax
  xor ecx, ecx
  xor edx, edx
  xor ebx, ebx
  mov rsp, 0x8000
  xor ebp, ebp
  xor esi, esi
  xor edi, edi
  xor r8, r8
  xor r9, r9
  xor r10, r10
  xor r11, r11
  xor r12, r12
  xor r13, r13
  xor r14, r14
  xor r15, r15
  
  mov bl, 'U'
  jmp 0x8000

exitfailure:
  mov rdi, [FB]
  mov eax, 0x00FF0000
  mov rcx, [FBS]
  shr rcx, 2
  rep stosd

error:
  mov rcx, [OUTPUT]
  lead rdx, [msg_error]
  call [rcx + EFI_SIMPLE_TEXT_OUTPUT_PROTOCOL_OUTPUTSTRING]
  jmp halt

sig_fail:
  mov rcx, [OUTPUT]
  lea rdx, [msg_SigFaile]
  call [rcx + EFI_SIMPLE_TEXT_OUTPUT_PROTOCOL_OUTPUTSTRING]
halt:
  halt
  jmp halt

EFI_SUCCESS equ 0
EFI_LOAD_ERROR equ 1
EFI_INVALID_PARAMETER equ 2
EFI_UNSUPPORTED equ 3
EFI_BAD_BUFFER_SIZE equ 4
EFI_BUFFER_TOO_SMALL equ 5
EFI_NOT_READY equ 6
EFI_DEVICE_ERROR equ 7
EFI_WRITE_PROTECTED equ 8
EFI_OUT_RESOURCES equ 9
EFI_VOLUME_CORRUPTED equ 10
EFI_VOLUME_FULL equ 11
EFI_NO_MEDIA equ 12
EFI_MEDIA_CHANGED equ 13
EFI_NOT_FOUND equ 14

EFI_RUNTIME_SERVICE_RESETSYSTEM equ 104

EFI_SIMPLE_TEXT_OUTPUT_PROTOCOL_OUTPUTSTRING equ 8
EFI_SIMPLE_TEXT_OUTPUT_PROTOCOL_SET_ATTRIBUTE equ 40
EFI_SIMPLE_TEXT_OUTPUT_PROTOCOL_CLEAR_SCREEN equ 48
