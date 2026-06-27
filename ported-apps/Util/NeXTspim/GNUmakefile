include $(GNUSTEP_MAKEFILES)/common.make

APP_NAME = NeXTspim

NeXTspim_OBJC_FILES = \
	BreakpointsPanel.m \
	CodeView.m \
	ConsoleText.m \
	ConsoleView.m \
	ContinuePanel.m \
	KeyQueue.m \
	NeXTspim_main.m \
	PrefsPanel.m \
	RunLoop.m \
	SPIMInterface.m \
	StatsWindow.m \
	TextView.m

NeXTspim_C_FILES = \
	data.c \
	inst.c \
	lex.yy.c \
	mem.c \
	mips-syscall.c \
	read-aout.c \
	run.c \
	spim-utils.c \
	sym-tbl.c \
	y.tab.c

NeXTspim_RESOURCE_FILES = \
	trap.handler \
	spim.tiff \
	Documentation

NeXTspim_APPLICATION_ICON = spim.tiff

NeXTspim_CPPFLAGS = -D_DARWIN_C_SOURCE -D_DEFAULT_SOURCE
NeXTspim_CFLAGS = \
	-Wall \
	-Wno-parentheses \
	-Wno-format \
	-Wno-pointer-sign \
	-Wno-unused-variable \
	-Wno-unused-function \
	-Wno-implicit-function-declaration \
	-Wno-int-conversion \
	-fcommon \
	-std=gnu89

NeXTspim_OBJCFLAGS = \
	-Wall \
	-Wno-parentheses \
	-Wno-format \
	-Wno-pointer-sign \
	-Wno-unused-variable \
	-Wno-unused-function \
	-Wno-implicit-function-declaration \
	-Wno-int-conversion \
	-fcommon \
	-fobjc-exceptions

include $(GNUSTEP_MAKEFILES)/application.make

.PHONY: run

run: all
	./NeXTspim.app/NeXTspim
