bits 64
org 0x10000

  mov rdi, 0xb8000 ; This is the beginning of "video memory."
  mov rdx, rdi     ; We'll save that value for later, too.
  mov rcx, 80*25   ; This is how many characters are on the screen.
  mov ax, 0x7400   ; Video memory uses 2 bytes per character. The high byte
                   ; determines foreground and background colors. See also
; http://en.wikipedia.org/wiki/List_of_8-bit_computer_hardware_palettes#CGA
                   ; In this case, we're setting red-on-gray (MIT colors!)
  rep stosw        ; Copies whatever is in ax to [rdi], rcx times.

  mov rdi, rdx       ; Restore rdi to the beginning of video memory.
  mov rsi, hello     ; Point rsi ("source" of string instructions) at string.
  mov rbx, hello_end ; Put end of string in rbx for comparison purposes.
hello_loop:
  movsb              ; Moves a byte from [rsi] to [rdi], increments rsi and rdi.
  inc rdi            ; Increment rdi again to skip over the color-control byte.
  cmp rsi, rbx       ; Check if we've reached the end of the string.
  jne hello_loop     ; If not, loop.
  hlt                ; If so, halt.

hello:
  db "Hello, stage 2!"
hello_end:
