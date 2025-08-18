CC=gcc
CFLAGS=-fPIC -Wall -Werror -O2
LDFLAGS=-shared
LIBS=-lpam
TARGET=pam_transit.so
DESTDIR=/lib64/security

.PHONY: all clean install uninstall

all: $(TARGET)

$(TARGET): pam_transit.c
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $< $(LIBS)

clean:
	rm -f $(TARGET)

install: $(TARGET)
	install -Dm755 $(TARGET) $(DESTDIR)/$(TARGET)

uninstall:
	rm -f $(DESTDIR)/$(TARGET)