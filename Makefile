#
# Top-level makefile
#

# Do not use make's built-in rules and variables
MAKEFLAGS += -rR

CC := clang
CFLAGS := -Wall --std=c11

CXX := clang++
CXXFLAGS := -Wall --std=c++11

RMDIR := rm -rf

srcdir := src
objdir := obj

#
# Target gathering
#

objs :=

# List all subfolders of the first argument
list-subdirs = $(shell find $1 -maxdepth 1 -mindepth 1 -type d -printf '%f ')

# Expand per-subdir include body
define include-subdir
  objdir-$1 = $(objdir)/$1
  srcdir-$1 = $(srcdir)/$1
  include $(srcdir)/$1/rules.mk
  $(shell mkdir -p $(objdir)/$1)
  objs += $$(patsubst %.o,$1/%.o,$$(objs-$1))
endef

# Include rules.mk for root folder
$(eval $(call include-subdir))

# Walk the subfolders and include rules.mk from each
$(foreach subdir,$(sort $(call list-subdirs,$(srcdir))),\
  $(eval $(call include-subdir,$(subdir))))

# Add objdir prefix to accumulated objs
objs := $(patsubst %.o,$(objdir)/%.o,$(objs))

.PHONY: all
.DEFAULT_GOAL := all
all: $(objs)

.PHONY: clean
clean:
	$(RMDIR) $(objdir)

# For debugging
.PHONY: show-vars
show-vars:
	# $(call list-subdirs,$(srcdir))
	# $(objs)

# Default rule for *.c
$(objdir)/%.o: $(srcdir)/%.c
	$(CC) $(CFLAGS) -c -o $@ $<

# Default rule for *.cpp
$(objdir)/%.o: $(srcdir)/%.cpp
	$(CXX) $(CXXFLAGS) -c -o $@ $<

#
# Dependency generation
#

ifneq ($(filter-out clean show-vars,$(or $(MAKECMDGOALS),all)),)
  include $(subst .o,.d,$(objs))
endif

# Accepts a compiler command line to generate a .d file and patches it with correct object paths
# We want to transform compiler-generated "src.o: ..." into "$(objdir)/src.o $(objdir)/src.d: ..."
define gen-dep-target
  $1 > $@.$$$$ && sed 's,$(*F).o\s*:,$(objdir)/$*.o $@:,g' < $@.$$$$ > $@; rm -f $@.$$$$
endef

$(objdir)/%.d: $(srcdir)/%.c
	$(call gen-dep-target,$(CC) -M $(CFLAGS) $<)

$(objdir)/%.d: $(srcdir)/%.cpp
	$(call gen-dep-target,$(CXX) -M $(CXXFLAGS) $<)
