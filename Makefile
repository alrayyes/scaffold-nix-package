# The thing package.nix actually builds. Any real project already has its
# own build system; this Makefile stands in for one so the derivation has
# something concrete to invoke rather than a stub. Delete it, along with
# src/, once you're pointing package.nix at a real build.

PREFIX ?= /usr/local

CC ?= cc
CFLAGS ?= -O2 -Wall -Wextra

example: src/main.c
	$(CC) $(CFLAGS) -o example src/main.c

.PHONY: install
install: example
	install -Dm755 example $(DESTDIR)$(PREFIX)/bin/example

.PHONY: clean
clean:
	rm -f example
