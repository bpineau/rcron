
# foreign tells automake to ignore missing "GNU mandatory files"
# (like "AUTHORS", "NEWS" & co).
AUTOMAKE_OPTIONS = foreign

SUBDIRS = src

realclean: distclean
	-rm -f $(am__CONFIG_DISTCLEAN_FILES)
	-rm -rf $(top_srcdir)/autom4te.cache
	-rm -f Makefile

