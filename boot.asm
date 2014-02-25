bits 16
org 0x7c00
_boot_start:

  ; The cli instruction disables maskable external interrupts.
  cli

  ; Fetch Control Register 0, set bit 0 to 1 (Protection Enable bit)
  ; This basically enables 32-bit mode
  mov eax, cr0
  or al, 1
  mov cr0, eax

  ; Now we have to jump into the 32-bit zone. The 0x08 is a 386-style segment
  ; descriptor, which theoretically references the Global Descriptor Table,
  ; though in this bare-bones bootloader we haven't even bothered to set that
  ; up yet and it works anyway.
  jmp 0x08:_32_bits

bits 32
_32_bits:
  
  ; Now we're going to set up the page tables for 64-bit mode.
  ; Since this is a minimal example, we're just going to set up a single page.
  ; The 64-bit page table uses four levels of paging,
  ;    PML4E table => PDPTE table => PDE table => PTE table => physical addr
  ; You don't have to use all of them, but you have to use at least the first
  ; three. So we're going to set up PML4E, PDPTE, and PDE tables here, each
  ; with a single entry.
%define PML4E_ADDR 0x8000
%define PDPTE_ADDR 0x9000
%define PDE_ADDR 0xa000
  ; Set up PML4 entry, which will point to PDPT entry.
  mov dword eax, PDPTE_ADDR
  ; The low 12 bits of the PML4E entry are zeroed out when it's dereferenced,
  ; and used to encode metadata instead. Here we're setting the Present and
  ; Read/Write bits. You might also want to set the User bit, if you want a
  ; page to remain accessible in user-mode code.
  or dword eax, 0b011  ; Would be 0b111 to set User bit also
  mov dword [PML4E_ADDR], eax
  ; Although we're in 32-bit mode, the table entry is 64 bits. We can just zero
  ; out the upper bits in this case.
  mov dword [PML4E_ADDR+4], 0
  ; Set up PDPT entry, which will point to PD entry.
  mov dword eax, PDE_ADDR
  or dword eax, 0b011
  mov dword [PDPTE_ADDR], eax
  mov dword [PDPTE_ADDR+4], 0
  ; Set up PD entry, which will point to the first 2MB page (0).  But we
  ; need to set three bits this time, Present, Read/Write and Page Size (to
  ; indicate that this is the last level of paging in use).
  mov dword [PDE_ADDR], 0b10000011
  mov dword [PDE_ADDR+4], 0
  
  ; Enable PGE and PAE bits of CR4 to get 64-bit paging available.
  mov eax, 0b10100000
  mov cr4, eax

  ; Set master (PML4) page table in CR3.
  mov eax, PML4E_ADDR
  mov cr3, eax

  ; Set IA-32e Mode Enable (read: 64-bit mode enable) in the "model-specific
  ; register" (MSR) called Extended Features Enable (EFER).
  mov ecx, 0xc0000080
  rdmsr ; takes ecx as argument, deposits contents of MSR into eax
  or eax, 0b100000000
  wrmsr ; exactly the reverse of rdmsr

  ; Enable PG flag of CR0 to actually turn on paging.
  mov eax, cr0
  or eax, 0x80000000
  mov cr0, eax

  ; Load Global Descriptor Table (outdated access control, but needs to be set)
  lgdt [gdt_hdr]

  ; Jump into 64-bit zone.
  jmp 0x08:_64_bits

bits 64
_64_bits:
; Our first order of business is to load the next sector.
  mov edi, 0x10000          ; This seems like a nice address.
  mov edx, 0x1f2            ; ATA command ports start here.  
  mov al, 1                 ; We're going to read one sector.
  out dx, al                ; Send this argument to the command port.
  inc edx                   ; Next port is the low bits of the logical block.
  mov al, 1                 ; We're going to read LBA#1, the second block.
  out dx, al
  inc edx                   ; Next port is bits 8-15 of the logical block.
  mov al, 0
  out dx, al
  inc edx                   ; Next is bits 16-23 of the logical block.
  out dx, al
  inc edx                   ; Then we have bits 24-27, and some mode flags.
  mov al, 0b11100000        ; Bit 6 is particularly important, flagging LBA mode
  out dx, al
  inc edx                   ; Finally, we must send the command...
  mov al, 0x20              ; 0x20, "Read with retry."
  out dx, al
ata_wait_loop:
  in al, dx                 ; Get drive status
  test al, 8                ; check readiness
  jz ata_wait_loop
  
  mov rcx, 512 / 2          ; 512 bytes, read one word at a time...
  mov rdx, 0x1f0            ;   from ports 0x1f0 and 0x1f1.
  rep insw

  jmp 0x10000

; Global descriptor table entry format
; See Intel 64 Software Developers' Manual, Vol. 3A, Figure 3-8
; or http://en.wikipedia.org/wiki/Global_Descriptor_Table
%macro GDT_ENTRY 4
  ; %1 is base address, %2 is segment limit, %3 is flags, %4 is type.
  dw %2 & 0xffff
  dw %1 & 0xffff
  db (%1 >> 16) & 0xff
  db %4 | ((%3 << 4) & 0xf0)
  db (%3 & 0xf0) | ((%2 >> 16) & 0x0f)
  db %1 >> 24
%endmacro
%define EXECUTE_READ 0b1010
%define READ_WRITE 0b0010
%define RING0 0b10101001 ; Flags set: Granularity, 64-bit, Present, S; Ring=00
                   ; Note: Ring is determined by bits 1 and 2 (the only "00")

; Global descriptor table (loaded by lgdt instruction)
gdt_hdr:
  dw gdt_end - gdt - 1
  dd gdt
gdt:
  GDT_ENTRY 0, 0, 0, 0
  GDT_ENTRY 0, 0xffffff, RING0, EXECUTE_READ
  GDT_ENTRY 0, 0xffffff, RING0, READ_WRITE
  ; You'd want to have entries for other rings here, if you were using them.
gdt_end:

; Very important - mark the sector as bootable.
times 512 - 2 - ($ - $$) db 0 ; zero-pad the 512-byte sector to the last 2 bytes
dw 0xaa55 ; Magic "boot signature"
