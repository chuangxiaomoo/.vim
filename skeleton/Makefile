#CROSS_COMPILE=arm_v5t_le-
# ~/.vim/skeleton/Makefile
# include ~/bin/.m1doc/make_var_debug

CC := $(CROSS_COMPILE)gcc
XX := $(CROSS_COMPILE)g++

SRCS := $(wildcard *.c)
EXEC := $(SRCS:%.c=%)
COBJS := $(SRCS:%.c=%.o)

CPPSRCS := $(wildcard *.cpp)
EXECPP := $(CPPSRCS:%.cpp=%)
CPPOBJS := $(CPPSRCS:%.cpp=%.oo)

INCLUDE := -I. -I/usr/local/include/
CFLAGS 	:= -g -Wall $(INCLUDE)
CPPFLAGS:= $(CFLAGS)
LDFLAGS := -lrt -ldl -lmxml -lpthread 
# LDLIBS  := /usr/local/lib/libmxml.a

all: $(EXEC) $(EXECPP)

$(EXEC) $(EXECPP): %:%.o
	$(CC) -o $@ $@.o $(LDLIBS)  $(LDFLAGS)

run r:

# $(COBJS) $(CPPOBJS)
clean c:
	rm -f a.out $(EXEC) $(EXECPP) 

%.o:%.c
	$(CC) -o $@ -c $< $(CFLAGS)

%.i:%.c
	@echo "----------compile $@------"
	$(CC) -o $@ -E $< $(CFLAGS)

%.ii:%.cpp
	@echo "----------compile $@------"
	$(CC) -o $@ -E $< $(CFLAGS)


.PHONY: all a clean c run r


