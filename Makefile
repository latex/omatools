# OmaTools Makefile
# Compilador e Linker para binários nativos em Assembly x86_64

AS = as
LD = ld
ASFLAGS = --64
LDFLAGS = -s

all: bin/oma-test

bin/oma-test: src/test.s
	@mkdir -p bin
	$(AS) $(ASFLAGS) src/test.s -o bin/test.o
	$(LD) $(LDFLAGS) bin/test.o -o bin/oma-test
	@rm bin/test.o
	@echo "Build concluído: bin/oma-test"

clean:
	rm -rf bin/
