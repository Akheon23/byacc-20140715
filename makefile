# $Id: makefile.in,v 1.23 2014/04/09 12:15:52 tom Exp $
#
# UNIX template-makefile for Berkeley Yacc

THIS		= yacc

#### Start of system configuration section. ####

srcdir 		= .


CC		= arm-linux-androideabi-gcc

INSTALL		= ./install-sh -c
INSTALL_PROGRAM	= ${INSTALL}
INSTALL_DATA	= ${INSTALL} -m 644
transform	= s,x,x,

DEFINES		=
EXTRA_CFLAGS	= 
CPPFLAGS	= -I. -I$(srcdir) $(DEFINES) -DHAVE_CONFIG_H -DYYPATCH=`cat $(srcdir)/VERSION` -Os -s -pie  -D_XOPEN_SOURCE=500
CFLAGS		= -Os -s -pie $(CPPFLAGS) $(EXTRA_CFLAGS)

LDFLAGS		= 
LIBS		= 

AWK		= awk
CTAGS		= 
ETAGS		= 
LINT		= 
LINTFLAGS	= 

prefix		= /usr/local
exec_prefix	= ${prefix}

datarootdir	= ${prefix}/share
bindir		= $(DESTDIR)${exec_prefix}/bin
mandir		= $(DESTDIR)${datarootdir}/man/man1
manext		= 1

testdir		= $(srcdir)/test

SKELETON	= yaccpar
x		= 
o		= .o

#### End of system configuration section. ####

SHELL		= /bin/sh
MAKE=make

H_FILES = \
	defs.h

C_FILES = \
	closure.c \
	error.c \
	graph.c \
	lalr.c \
	lr0.c \
	main.c \
	mkpar.c \
	mstring.c \
	output.c \
	reader.c \
	$(SKELETON).c \
	symtab.c \
	verbose.c \
	warshall.c

OBJS	= \
	closure$o \
	error$o \
	graph$o \
	lalr$o \
	lr0$o \
	main$o \
	mkpar$o \
	mstring$o \
	output$o \
	reader$o \
	$(SKELETON)$o \
	symtab$o \
	verbose$o \
	warshall$o

YACCPAR	= \
	btyaccpar.c \
	yaccpar.c

TRANSFORM_BIN = sed 's/$x$$//'       |sed '$(transform)'|sed 's/$$/$x/'
TRANSFORM_MAN = sed 's/$(manext)$$//'|sed '$(transform)'|sed 's/$$/$(manext)/'

actual_bin = `echo $(THIS)$x        | $(TRANSFORM_BIN)`
actual_man = `echo $(THIS).$(manext)| $(TRANSFORM_MAN)`

all : $(THIS)$x

install: all installdirs
	$(INSTALL_PROGRAM) $(THIS)$x $(bindir)/$(actual_bin)
	- $(INSTALL_DATA) $(srcdir)/$(THIS).1 $(mandir)/$(actual_man)

installdirs:
	mkdir -p $(bindir)
	- mkdir -p $(mandir)

uninstall:
	- rm -f $(bindir)/$(actual_bin)
	- rm -f $(mandir)/$(actual_man)

################################################################################
.SUFFIXES : .c $o .i .skel

.c$o:
	
	$(CC) -c $(CFLAGS) $<

.c.i :
	
	$(CPP) -C $(CPPFLAGS) $*.c >$@

.skel.c :
	$(AWK) -f $(srcdir)/skel2c $*.skel > $@

################################################################################

$(THIS)$x : $(OBJS)
	$(CC) $(LDFLAGS) $(CFLAGS) -o $@ $(OBJS) $(LIBS)

mostlyclean :
	- rm -f core .nfs* *$o *.bak *.BAK *.out

clean :: mostlyclean
	- rm -f $(THIS)$x

distclean :: clean
	- rm -f config.log config.cache config.status config.h makefile
	- rm -f $(testdir)/yacc/test-* $(testdir)/btyacc/test-*

realclean :: distclean
	- rm -f tags TAGS

sources : $(YACCPAR)

maintainer-clean :: realclean
	rm -f $(YACCPAR)

################################################################################
check:	$(THIS)$x
	$(SHELL) $(testdir)/run_test.sh $(testdir)

check_make: $(THIS)$x
	$(SHELL) $(testdir)/run_make.sh $(testdir)

check_lint:
	$(SHELL) $(testdir)/run_lint.sh $(testdir)
################################################################################
tags: $(H_FILES) $(C_FILES) 
	$(CTAGS) $(C_FILES) $(H_FILES)

lint: $(C_FILES) 
	$(LINT) $(LINTFLAGS) $(CPPFLAGS) $(C_FILES)

#TAGS: $(H_FILES) $(C_FILES) 
#	$(ETAGS) $(C_FILES) $(H_FILES)

depend:
	makedepend -- $(CPPFLAGS) -- $(C_FILES)

$(OBJS) : defs.h makefile

main$o \
$(SKELETON)$o : VERSION

# DO NOT DELETE THIS LINE -- make depend depends on it.
################################################################################
.SUFFIXES : .html .1 .man .ps .pdf .txt

.1.html :
	GROFF_NO_SGR=stupid $(SHELL) -c "tbl $*.1 | groff -P -o0 -Iyacc,1_ -Thtml -man" >$@

.1.ps :
	$(SHELL) -c "tbl $*.1 | groff -man" >$@

.1.txt :
	GROFF_NO_SGR=stupid $(SHELL) -c "tbl $*.1 | nroff -Tascii -man | col -bx" >$@

.ps.pdf :
	ps2pdf $*.ps

################################################################################
docs-yacc \
docs :: yacc.html \
	yacc.pdf \
	yacc.ps \
	yacc.txt

clean \
docs-clean ::
	rm -f yacc.html yacc.pdf yacc.ps yacc.txt

yacc.html : yacc.\1
yacc.pdf : yacc.ps
yacc.ps : yacc.\1
yacc.txt : yacc.\1
