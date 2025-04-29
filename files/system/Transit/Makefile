PAM_CFLAGS := $(shell pkg-config --cflags libpam)
PAM_LIBS := $(shell pkg-config --libs libpam)
PAM_MODULE_DIR := $(shell pkg-config --variable=moduledir libpam)
ifeq ($(strip $(PAM_MODULE_DIR)),)
    ARCH := $(shell uname -m)
    ifeq ($(ARCH),x86_64)
        PAM_MODULE_DIR := /lib64/security
    else
        PAM_MODULE_DIR := /lib/security
    endif
endif

TARGET = pam_transit.so
SOURCE = pam_transit.c
CC = gcc
CFLAGS = -shared -fPIC $(PAM_CFLAGS)
LDFLAGS = $(PAM_LIBS)

.PHONY: all install clean

all: $(TARGET)

$(TARGET): $(SOURCE)
	$(CC) $(CFLAGS) $(SOURCE) -o $(TARGET) $(LDFLAGS)

install: all
	install -Dm755 $(TARGET) $(PAM_MODULE_DIR)/$(TARGET)

clean:
	rm -f $(TARGET)