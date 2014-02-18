org 0x1000
mach_header:
    istruc mach_header_64
        at mh_magic, dd 0xfeedfacf     ; uint32_t magic (64-bit)
        at mh_cputype, dd 0x01000007   ; cputype (x86_64)
        at mh_cpusubtype, dd 3         ; cpusubtype (x86_64_all)
        at mh_filetype, dd 2           ; filetype (demand paged executable, MH_EXECUTE)
        at mh_lc_n, dd 2               ; number of load commands in the file
        at mh_cmdsize, dd lc_end - load_commands  ; size of commands
        at mh_flags, dd 0x01           ; flags: !MH_TWOLEVEL | !MH_DYLDLINK | MH_NOUNDEFS
        at mh_reserved, dd 0           ; reserved
    iend

load_commands:
lc0:
    istruc segment_command_64
        at sg_magic, dd LC_SEGMENT_64
        at sg_size, dd lc0_end - lc0
        at sg_segname, db 'A segment.'
        at sg_vmaddr, dq 0x1000
        at sg_vmsize, dq 0x1000
        at sg_fileoff, dq 0
        at sg_filesize, dq filesize
        at sg_maxprot, dd 7
        at sg_initprot, dd 7
        at sg_nsects, dd 1
        at sg_flags, dd 0
    iend
        istruc section_command_64
            at sc_sectname, db 'A section.'
            at sc_segname, db 'A segment.'
            at sc_vmaddr, dq _start
            at sc_size, dq codesize
            at sc_offset, dd _start - mach_header
            at sc_flags, dd 0x80000400
        iend
lc0_end:
lc1:
    dd LC_UNIXTHREAD
    dd lc1_end - lc1
    dd X86_THREAD_STATE64
    dd X86_EXCEPTION_STATE64_COUNT
    istruc initial_state
        at i_rsp, dq 0x1f00
        at i_rip, dq _start
    iend
lc1_end:
lc_end:
align 4
