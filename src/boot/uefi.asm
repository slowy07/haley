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
