CC ?= gcc
CFLAGS = -Wall -Werror -pedantic --std=c99 -O2
VERSION = 0.5
PREFIX = /usr/local
MANPREFIX = ${PREFIX}/share/man

hkd: hkd.c

debug:
	gcc -Wall -O0 -g hkd.c -o hkd_debug

install: hkd
	mkdir -p ${DESTDIR}${PREFIX}/bin
	cp -f hkd ${DESTDIR}${PREFIX}/bin
	chmod 755 ${DESTDIR}${PREFIX}/bin/hkd
	mkdir -p ${DESTDIR}${MANPREFIX}/man1
	sed "s/VERSION/${VERSION}/g" < hkd.1 > ${DESTDIR}${MANPREFIX}/man1/hkd.1
	chmod 644 ${DESTDIR}${MANPREFIX}/man1/hkd.1

uninstall:
	rm -f ${DESTDIR}${PREFIX}/bin/hkd\
		${DESTDIR}${MANPREFIX}/man1/hkd.1

clean:
	rm -f *.o hkd hkd_debug
