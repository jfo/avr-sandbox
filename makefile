LIB_SEARCH_PATH=/nix/store/45kzrjhbv3p08p0izs4qdkvw3jdmznh2-arduino-1.8.5/share/arduino/hardware/tools/avr/avr/lib/avr5/

default: build
	avr-as -mmcu=atmega32u4 -c src/thing.s -o build/thing.o
	objcopy -O ihex build/thing.o build/thing.hex

build:
	mkdir build

clean:
	rm -r build
