ifndef VPATH
SRCDIR = .
else
SRCDIR = $(VPATH)
endif

EXTENSION    = pgfincore
EXTVERSION   = $(shell grep default_version $(SRCDIR)/$(EXTENSION).control | \
               sed -e "s/default_version[[:space:]]*=[[:space:]]*'\([^']*\)'/\1/")

MODULES      = $(EXTENSION)
DATA         = sql/pgfincore.sql sql/uninstall_pgfincore.sql
DOCS         = doc/README.$(EXTENSION).rst

PG_CONFIG    = pg_config

PG91         = $(shell $(PG_CONFIG) --version | grep -qE "8\.|9\.0" && echo no || echo yes)

ifeq ($(PG91),yes)
all: pgfincore--$(EXTVERSION).sql

pgfincore--$(EXTVERSION).sql: sql/pgfincore.sql
	cp $< $@

DATA        = pgfincore--unpackaged--$(EXTVERSION).sql pgfincore--$(EXTVERSION).sql
EXTRA_CLEAN = sql/$(EXTENSION)--$(EXTVERSION).sql
endif

PGXS := $(shell $(PG_CONFIG) --pgxs)
include $(PGXS)

deb:
	dh clean
	make -f debian/rules orig
	debuild -us -uc -sa
