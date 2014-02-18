bits 64
default rel

%define LC_SEGMENT_64 0x19
%define LC_THREAD 0x4
%define LC_UNIXTHREAD 0x5
%define X86_THREAD_STATE64 4
%define X86_EXCEPTION_STATE64_COUNT 42

struc mach_header_64
    mh_magic: resd 1
    mh_cputype: resd 1
    mh_cpusubtype: resd 1
    mh_filetype: resd 1
    mh_lc_n: resd 1
    mh_cmdsize: resd 1
    mh_flags: resd 1
    mh_reserved: resd 1
endstruc

struc segment_command_64
    sg_magic:    resd 1
    sg_size:     resd 1
    sg_segname:  resb 16
    sg_vmaddr:   resq 1
    sg_vmsize:   resq 1
    sg_fileoff:  resq 1
    sg_filesize: resq 1
    sg_maxprot:  resd 1
    sg_initprot: resd 1
    sg_nsects:   resd 1
    sg_flags:    resd 1
endstruc

struc section_command_64
    sc_sectname: resb 16
    sc_segname: resb 16
    sc_vmaddr: resq 1
    sc_size: resq 1
    sc_offset: resd 1 ; offset from $$
    sc_alignment: resd 1  ; as an exponent of 2
    sc_reloff: resd 1 ; first relocation entry offset
    sc_nreloc: resd 1 ; number of relocation entries (usually 0)
    sc_flags: resd 1 ; usually 0x80000400
    sc_reserved1: resd 1 ; usually 0
    sc_reserved2: resd 1 ; usually 0
    resd 1 ; padding??
endstruc

struc initial_state
    i_rax: resq 1
    i_rbx: resq 1
    i_rcx: resq 1
    i_rdx: resq 1
    i_rdi: resq 1
    i_rsi: resq 1
    i_rbp: resq 1
    i_rsp: resq 1
    i_r8: resq 1
    i_r9: resq 1
    i_r10: resq 1
    i_r11: resq 1
    i_r12: resq 1
    i_r13: resq 1
    i_r14: resq 1
    i_r15: resq 1
    i_rip: resq 1
    i_rflags: resq 1
    i_cs: resq 1
    i_fs: resq 1
    i_gs: resq 1
endstruc
