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

# 编译选项中指定 -pthread 会附加一个宏定义 -D_REENTRANT ，该宏会导致 libc 
# 头文件选择那些thread-safe的实现；链接选项中指定 -pthread 则同 -lpthread 一样，
# 只表示链接 POSIX thread 库。由于 libc 用于适应 thread-safe 的宏定义可能变化，
# 因此在编译和链接时都使用 -pthread 选项而不是传统的 -lpthread 能够保持向后兼容，
# 并提高命令行的一致性。

LDFLAGS := -lrt -ldl -pthread 
# LDLIBS  := /usr/local/lib/libmxml.a -lmxml 

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


