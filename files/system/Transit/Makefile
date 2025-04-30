CC=gcc
CFLAGS=-fPIC -Wall -Werror -O2
LDFLAGS=-shared
LIBS=-lpam

all: pam_transit.so

pam_transit.so: pam_transit.c
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $< $(LIBS)

install: pam_transit.so
	install -Dm755 pam_transit.so /lib/security/