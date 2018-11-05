I'm experimenting with avr assembly and a teensy 2, which has an atmega32u4 chip in it

My make command:

```
default: build
	avr-as -mmcu=atmega32u4 -c src/thing.s -o build/thing.o
	objcopy -O ihex build/thing.o build/thing.hex
```

(the makefile in the repo has local lib paths hardcoded in it right now, this
is just a scratchpad repo.)


Then I load it:

```
sudo teensy-loader-cli --mcu=TEENSY2 build/$1.hex -w -v
```

This all seems to work fine.

On my chip, `0x0b` is the address for DDRD (data direction port D) and the LED
is attached to the 6th bit, so writing `0xff` to it marks the LED as output and
current flows to it, turning it on.

```asm
ldi r16, 0xFF
out 0x0b, r16
````

This flashes the light for just an instant, I assume for the amount of time it
takes to get through the instructions and then the program shuts off because
there's nothing else to do.

I would think that this would run the loop indefinitely:

```asm
ldi r16, 0xFF
out 0x0b, r16
loop:
rjmp loop
````

But it does not, it just flashes again.

Curiously, this works, meaning the PortD6 is pulled up and the LED stays on:

```asm
ldi r16, 0xFF
out 0x0b, r16
loop:
jmp loop
```

_But_, when I disassemble both of them, I find something unexpected.

```
 avr-objdump --prefix-addresses -m avr5 -D build/thing.hex -s
```

The `rjmp` that doesn't work seems to be "jumping" to the very next instruction,
so the behavior is like it's not there at all:


```
build/thing.hex:     file format ihex

Contents of section .sec1:
 0000 0fef0bb9 00c0                        ......          

Disassembly of section .sec1:
0x00000000 ldi	r16, 0xFF	; 255
0x00000002 out	0x0b, r16	; 11
0x00000004 rjmp	.+0      	;  0x00000006
```

and the plain `jmp` instruction seems to be also ignoring the label I've given
to it and jumping back to 0:

```
build/thing.hex:     file format ihex

Contents of section .sec1:
 0000 0fef0bb9 0c940000                    ........        

Disassembly of section .sec1:
0x00000000 ldi	r16, 0xFF	; 255
0x00000002 out	0x0b, r16	; 11
0x00000004 jmp	0	;  0x00000000
```

This effectively makes it loop at least, so the light does stay on in that
case, but this behavior baffles me.

This is the simplest example I could come up with. Am I using these
instructions incorrectly? It doesn't change if I add a `nop` after loop. Is the
assembler "optimizing" this or something? I just want to understand why I'm not
seeing the addresses I expect being passed to `jmp` and `rjmp`. I'm going by
the syntax I'm seeing on http://avrbeginners.net/
