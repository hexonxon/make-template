#
# Top-level makefile
#

# Do not use make's built-in rules and variables
MAKEFLAGS += -rR

# Delete targets of failed rules by default
.DELETE_ON_ERROR:

# Remove quiet modifier if V is defined to anything except 0
Q := @
ifneq ($(filter-out 0,$(V)),)
  Q :=
endif

CC := clang
CFLAGS := -Wall --std=c11

CXX := clang++
CXXFLAGS := -Wall --std=c++11

ifdef $(BUILD_DEBUG)
	CCOMMONFLAGS += -Og -ggdb3
else
	CCOMMONFLAGS += -O2
endif

CFLAGS += $(CCOMMONFLAGS)
CXXFLAGS += $(CCOMMONFLAGS)

RMDIR := rm -rf

srcdir := src
objdir := obj

all:

#
# Target gathering
#

objs :=

# Find all rules.mk files to include as list of subdirs
find-subdirs = $(patsubst $(srcdir)/%/rules.mk,%,$(shell find $(srcdir) -mindepth 2 -name rules.mk))

# Expand per-subdir include body
define include-subdir
  srcdir-m := $(srcdir)/$1
  objdir-m := $(objdir)/$1
  include $$(srcdir-m)/rules.mk
  objs += $$(patsubst %.o,$$(objdir-m)/%.o,$$(objs-m))
endef

# Include rules.mk for root folder
$(eval $(call include-subdir))

# Walk the subfolders and include rules.mk from each
$(foreach subdir,$(sort $(call find-subdirs)),\
  $(eval $(call include-subdir,$(subdir))))

.PHONY: all
all: $(objs)

.PHONY: clean
clean:
	$(Q) $(RMDIR) $(objdir)

.PHONY: show-vars
show-vars:
	# $(call find-subdirs)
	# $(objs)

$(objdir)/%.o: $(srcdir)/%.c
	$(Q) $(CC) $(CFLAGS) -c -o $@ $<

$(objdir)/%.o: $(srcdir)/%.cpp
	$(Q) $(CXX) $(CXXFLAGS) -c -o $@ $<

#
# Dependency generation
#

ifneq ($(filter-out clean show-vars,$(or $(MAKECMDGOALS),all)),)
  $(shell mkdir -p $(dir $(objs)))
  include $(subst .o,.d,$(objs))
endif

# Accepts a compiler command line to generate a .d file and patches it with correct object paths
# We want to transform compiler-generated "src.o: ..." into "$(objdir)/src.o $(objdir)/src.d: ..."
define gen-dep-target
  $1 > $@.$$$$ && sed 's,$(*F).o\s*:,$(objdir)/$*.o $@:,g' < $@.$$$$ > $@; rm -f $@.$$$$
endef

$(objdir)/%.d: $(srcdir)/%.c
	$(Q) $(call gen-dep-target,$(CC) -M $(CFLAGS) $<)

$(objdir)/%.d: $(srcdir)/%.cpp
	$(Q) $(call gen-dep-target,$(CXX) -M $(CXXFLAGS) $<)
