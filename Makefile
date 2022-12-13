NAME	=	kfs.bin
SRCS	=	boot.asm kernel.asm
OBJS	=	$(SRCS:.asm=.o)
LDSCRPT	=	linker.ld

all	:	$(NAME)

$(NAME)	:	$(OBJS)
		ld -m elf_i386 -T $(LDSCRPT) -o $(NAME) $(OBJS)

%.o	:	%.asm
		nasm -felf32 $< -o $@

clean	:
		rm -f $(OBJS)

fclean	:	clean
		rm -f $(NAME)

re	:	fclean all

.PHONY	:	all clean fclean re
