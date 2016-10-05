# GNU Make project makefile autogenerated by Premake
ifndef config
  config=debug
endif

ifndef verbose
  SILENT = @
endif

ifndef CC
  CC = gcc
endif

ifndef CXX
  CXX = g++
endif

ifndef AR
  AR = ar
endif

ifeq ($(config),debug)
  OBJDIR     = obj/Debug/tess2
  TARGETDIR  = .
  TARGET     = $(TARGETDIR)/libtess2.a
  DEFINES   += -DDEBUG
  INCLUDES  += -I../Include -I../Source
  CPPFLAGS  += -MMD -MP $(DEFINES) $(INCLUDES)
  CFLAGS    += $(CPPFLAGS) $(ARCH) -g -Wall
  CXXFLAGS  += $(CFLAGS)
  LDFLAGS   +=
  LIBS      +=
  RESFLAGS  += $(DEFINES) $(INCLUDES)
  LDDEPS    +=
  LINKCMD    = $(AR) -rcs $(TARGET) $(OBJECTS)
  define PREBUILDCMDS
  endef
  define PRELINKCMDS
  endef
  define POSTBUILDCMDS
  endef
endif

ifeq ($(config),release)
  OBJDIR     = obj/Release/tess2
  TARGETDIR  = .
  TARGET     = $(TARGETDIR)/libtess2.a
  DEFINES   += -DNDEBUG
  INCLUDES  += -I../Include -I../Source
  CPPFLAGS  += -MMD -MP $(DEFINES) $(INCLUDES)
  CFLAGS    += $(CPPFLAGS) $(ARCH) -O2 -Wall
  CXXFLAGS  += $(CFLAGS)
  LDFLAGS   += -s
  LIBS      +=
  RESFLAGS  += $(DEFINES) $(INCLUDES)
  LDDEPS    +=
  LINKCMD    = $(AR) -rcs $(TARGET) $(OBJECTS)
  define PREBUILDCMDS
  endef
  define PRELINKCMDS
  endef
  define POSTBUILDCMDS
  endef
endif

ifeq ($(config),debug64)
  OBJDIR     = obj/x64/Debug/tess2
  TARGETDIR  = .
  TARGET     = $(TARGETDIR)/libtess2.a
  DEFINES   += -DDEBUG
  INCLUDES  += -I../Include -I../Source
  CPPFLAGS  += -MMD -MP $(DEFINES) $(INCLUDES)
  CFLAGS    += $(CPPFLAGS) $(ARCH) -g -Wall -m64
  CXXFLAGS  += $(CFLAGS)
  LDFLAGS   += -m64 -L/usr/lib64
  LIBS      +=
  RESFLAGS  += $(DEFINES) $(INCLUDES)
  LDDEPS    +=
  LINKCMD    = $(AR) -rcs $(TARGET) $(OBJECTS)
  define PREBUILDCMDS
  endef
  define PRELINKCMDS
  endef
  define POSTBUILDCMDS
  endef
endif

ifeq ($(config),release64)
  OBJDIR     = obj/x64/Release/tess2
  TARGETDIR  = .
  TARGET     = $(TARGETDIR)/libtess2.a
  DEFINES   += -DNDEBUG
  INCLUDES  += -I../Include -I../Source
  CPPFLAGS  += -MMD -MP $(DEFINES) $(INCLUDES)
  CFLAGS    += $(CPPFLAGS) $(ARCH) -O2 -Wall -m64
  CXXFLAGS  += $(CFLAGS)
  LDFLAGS   += -s -m64 -L/usr/lib64
  LIBS      +=
  RESFLAGS  += $(DEFINES) $(INCLUDES)
  LDDEPS    +=
  LINKCMD    = $(AR) -rcs $(TARGET) $(OBJECTS)
  define PREBUILDCMDS
  endef
  define PRELINKCMDS
  endef
  define POSTBUILDCMDS
  endef
endif

ifeq ($(config),debug32)
  OBJDIR     = obj/x32/Debug/tess2
  TARGETDIR  = .
  TARGET     = $(TARGETDIR)/libtess2.a
  DEFINES   += -DDEBUG
  INCLUDES  += -I../Include -I../Source
  CPPFLAGS  += -MMD -MP $(DEFINES) $(INCLUDES)
  CFLAGS    += $(CPPFLAGS) $(ARCH) -g -Wall -m32
  CXXFLAGS  += $(CFLAGS)
  LDFLAGS   += -m32 -L/usr/lib32
  LIBS      +=
  RESFLAGS  += $(DEFINES) $(INCLUDES)
  LDDEPS    +=
  LINKCMD    = $(AR) -rcs $(TARGET) $(OBJECTS)
  define PREBUILDCMDS
  endef
  define PRELINKCMDS
  endef
  define POSTBUILDCMDS
  endef
endif

ifeq ($(config),release32)
  OBJDIR     = obj/x32/Release/tess2
  TARGETDIR  = .
  TARGET     = $(TARGETDIR)/libtess2.a
  DEFINES   += -DNDEBUG
  INCLUDES  += -I../Include -I../Source
  CPPFLAGS  += -MMD -MP $(DEFINES) $(INCLUDES)
  CFLAGS    += $(CPPFLAGS) $(ARCH) -O2 -Wall -m32
  CXXFLAGS  += $(CFLAGS)
  LDFLAGS   += -s -m32 -L/usr/lib32
  LIBS      +=
  RESFLAGS  += $(DEFINES) $(INCLUDES)
  LDDEPS    +=
  LINKCMD    = $(AR) -rcs $(TARGET) $(OBJECTS)
  define PREBUILDCMDS
  endef
  define PRELINKCMDS
  endef
  define POSTBUILDCMDS
  endef
endif

OBJECTS := \
	$(OBJDIR)/dict.o \
	$(OBJDIR)/priorityq.o \
	$(OBJDIR)/geom.o \
	$(OBJDIR)/mesh.o \
	$(OBJDIR)/sweep.o \
	$(OBJDIR)/bucketalloc.o \
	$(OBJDIR)/tess.o \

RESOURCES := \

SHELLTYPE := msdos
ifeq (,$(ComSpec)$(COMSPEC))
  SHELLTYPE := posix
endif
ifeq (/bin,$(findstring /bin,$(SHELL)))
  SHELLTYPE := posix
endif

.PHONY: clean prebuild prelink

all: $(TARGETDIR) $(OBJDIR) prebuild prelink $(TARGET)
	@:

$(TARGET): $(GCH) $(OBJECTS) $(LDDEPS) $(RESOURCES)
	@echo Linking tess2
	$(SILENT) $(LINKCMD)
	$(POSTBUILDCMDS)

$(TARGETDIR):
	@echo Creating $(TARGETDIR)
ifeq (posix,$(SHELLTYPE))
	$(SILENT) mkdir -p $(TARGETDIR)
else
	$(SILENT) mkdir $(subst /,\\,$(TARGETDIR))
endif

$(OBJDIR):
	@echo Creating $(OBJDIR)
ifeq (posix,$(SHELLTYPE))
	$(SILENT) mkdir -p $(OBJDIR)
else
	$(SILENT) mkdir $(subst /,\\,$(OBJDIR))
endif

clean:
	@echo Cleaning tess2
ifeq (posix,$(SHELLTYPE))
	$(SILENT) rm -f  $(TARGET)
	$(SILENT) rm -rf $(OBJDIR)
else
	$(SILENT) if exist $(subst /,\\,$(TARGET)) del $(subst /,\\,$(TARGET))
	$(SILENT) if exist $(subst /,\\,$(OBJDIR)) rmdir /s /q $(subst /,\\,$(OBJDIR))
endif

prebuild:
	$(PREBUILDCMDS)

prelink:
	$(PRELINKCMDS)

ifneq (,$(PCH))
$(GCH): $(PCH)
	@echo $(notdir $<)
	-$(SILENT) cp $< $(OBJDIR)
	$(SILENT) $(CC) $(CFLAGS) -o "$@" -c "$<"
endif

$(OBJDIR)/dict.o: ../Source/dict.c
	@echo $(notdir $<)
	@echo From $$PWD
	ls $<
	mkdir $(OBJDIR)
	$(SILENT) $(CC) $(CFLAGS) -o "$@" -c "$<"
$(OBJDIR)/priorityq.o: ../Source/priorityq.c
	@echo $(notdir $<)
	$(SILENT) $(CC) $(CFLAGS) -o "$@" -c "$<"
$(OBJDIR)/geom.o: ../Source/geom.c
	@echo $(notdir $<)
	$(SILENT) $(CC) $(CFLAGS) -o "$@" -c "$<"
$(OBJDIR)/mesh.o: ../Source/mesh.c
	@echo $(notdir $<)
	$(SILENT) $(CC) $(CFLAGS) -o "$@" -c "$<"
$(OBJDIR)/sweep.o: ../Source/sweep.c
	@echo $(notdir $<)
	$(SILENT) $(CC) $(CFLAGS) -o "$@" -c "$<"
$(OBJDIR)/bucketalloc.o: ../Source/bucketalloc.c
	@echo $(notdir $<)
	$(SILENT) $(CC) $(CFLAGS) -o "$@" -c "$<"
$(OBJDIR)/tess.o: ../Source/tess.c
	@echo $(notdir $<)
	$(SILENT) $(CC) $(CFLAGS) -o "$@" -c "$<"

-include $(OBJECTS:%.o=%.d)
