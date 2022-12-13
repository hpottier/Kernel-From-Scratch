NAME	=	kfs.bin
NISO	=	kfs.iso
SRCS	=	boot.asm kernel.asm
OBJS	=	$(SRCS:.asm=.o)
LDSCRPT	=	linker.ld

all	:	$(NAME) $(NISO)

$(NAME)	:	$(OBJS)
		ld -m elf_i386 -T $(LDSCRPT) -o $(NAME) $(OBJS)

$(NISO)	:	$(NAME)
		mkdir -p isodir/boot/grub
		cp $(NAME) isodir/boot/$(NAME)
		cp grub.cfg isodir/boot/grub/grub.cfg
		grub-mkrescue -o $(NISO) isodir

%.o	:	%.asm
		nasm -felf32 $< -o $@

clean	:
		rm -f $(OBJS)
		rm -rf isodir

fclean	:	clean
		rm -f $(NAME)
		rm -f $(NISO)

re	:	fclean all

.PHONY	:	all clean fclean re
