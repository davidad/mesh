BITS 64
    org    0x00400000    ; Program load offset
 
; 64-bit ELF header
ehdr:
    ; ELF Magic + 2 (64-bit), 1 (LSB), 1 (ELF ver. 1), 0 (ABI ver.)
    db 0x7F, "ELF", 2, 1, 1, 0       ; e_ident
    times 8 db 0                     ; reserved (zeroes)
 
    dw 2              ; e_type:      Executable file
    dw 0x3e           ; e_machine:   x64
    dd 1              ; e_version:   current version
    dq _start         ; e_entry:     program entry address (0x78)
    dq phdr - $$      ; e_phoff      program header offset (0x40)
    dq 0              ; e_shoff      no section headers
    dd 0              ; e_flags      no flags
    dw ehdrsize       ; e_ehsize:    ELF header size (0x40)
    dw phdrsize       ; e_phentsize: program header size (0x38)
    dw 1              ; e_phnum:     one program header
    dw 0              ; e_shentsize
    dw 0              ; e_shnum
    dw 0              ; e_shstrndx
 
ehdrsize equ $ - ehdr
 
; 64-bit ELF program header
phdr:
    dd 1              ; p_type:    loadable segment
    dd 5              ; p_flags    read and execute
    dq 0              ; p_offset
    dq $$             ; p_vaddr:    start of the current section
    dq $$             ; p_paddr:    "        "
    dq filesize       ; p_filesz
    dq filesize       ; p_memsz
    dq 0x200000       ; p_align:    2^11=200000 = section alignment
 
; program header size
phdrsize equ $ - phdr
