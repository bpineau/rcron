# @configure_input@

YACC = @YACC@ -d
bin_PROGRAMS = rcron
rcron_SOURCES = rcron.c rcron_conf.h rcron_conf-parser.y rcron_conf-lexer.l
man_MANS = rcron.8
CLEANFILES = rcron_conf-lexer.c rcron_conf-parser.c rcron_conf-parser.h
AM_CPPFLAGS = -DDEFCONF=\""$(sysconfdir)/rcron/rcron.conf"\" 
#EXTRA_DIST = configfile read_config_yy.h

