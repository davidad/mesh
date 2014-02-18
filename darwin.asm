%include "darwin/mach-o64_defs.asm"
%include "darwin/mach-o64_header.asm"
%include "darwin/macros.nasm"
;%include "_start.asm"
_start:
    hlt
%include "darwin/mach-o64_footer.asm"
