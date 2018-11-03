default:
	avr-gcc -mmcu=atmega32u4 -L /nix/store/45kzrjhbv3p08p0izs4qdkvw3jdmznh2-arduino-1.8.5/share/arduino/hardware/tools/avr/avr/lib/avr5/ -c src/light.s -o build/light.o
	objcopy -O ihex build/light.o build/light.hex
	sudo teensy-loader-cli --mcu=TEENSY2 build/light.hex  -w -v

clean:
	rm -r build
