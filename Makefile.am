bin_PROGRAMS = memcached memcached-debug internal_tests

common_SOURCES = memcached.h slabs.c slabs.h items.c items.h \
    assoc.c assoc.h stats.c stats.h \
    util.c util.h \
    memcached_dtrace.h thread.c globals.c

memcached_SOURCES = memcached.c $(common_SOURCES)
memcached_debug_SOURCES = $(memcached_SOURCES)
memcached_CPPFLAGS = -DNDEBUG
memcached_LDADD = @DTRACE_OBJ@ @DAEMON_OBJ@ 
memcached_debug_LDADD = @DTRACE_DEBUG_OBJ@ @DAEMON_OBJ@
memcached_DEPENDENCIES = @DTRACE_OBJ@ @DAEMON_OBJ@
memcached_debug_DEPENDENCIES = @DTRACE_DEBUG_OBJ@ @DAEMON_OBJ@

internal_tests_SOURCES = internal_tests.c $(common_SOURCES)

memcached_dtrace.h:
	${DTRACE} -h -s memcached_dtrace.d 
	sed -e s,_DTRACE_VERSION,ENABLE_DTRACE,g memcached_dtrace.h | \
            tr '\t' ' ' | grep -v unistd.h > memcached_dtrace.tmp
	mv memcached_dtrace.tmp memcached_dtrace.h

memcached_dtrace.o: $(memcached_OBJECTS)
	$(DTRACE) $(DTRACEFLAGS) -G -o memcached_dtrace.o -s ${srcdir}/memcached_dtrace.d $(memcached_OBJECTS)

memcached_debug_dtrace.o: $(memcached_debug_OBJECTS)
	$(DTRACE) $(DTRACEFLAGS) -G -o memcached_debug_dtrace.o -s ${srcdir}/memcached_dtrace.d $(memcached_debug_OBJECTS)

SUBDIRS = doc
DIST_DIRS = scripts
EXTRA_DIST = doc scripts TODO t memcached.spec daemon.c memcached_dtrace.d

test:	memcached-debug internal_tests
	./internal_tests && prove $(srcdir)/t

dist-hook:
	rm -rf $(distdir)/doc/.svn/
	rm -rf $(distdir)/scripts/.svn/
	rm -rf $(distdir)/t/.svn/
	rm -rf $(distdir)/t/lib/.svn/
