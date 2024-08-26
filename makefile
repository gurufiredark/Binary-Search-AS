all:
	as -32 main.s -o main.o
	ld -m elf_i386 main.o -lc -dynamic-linker /lib/ld-linux.so.2 -o main