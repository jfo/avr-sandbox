ldi r16, 0xFF
out 0x0b, r16
loop:
nop
jmp loop
