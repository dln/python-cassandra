VERSION   = 0.6.3

SRCDIR    = cassandra
GENDIR    = tmp
SCRIPTDIR = scripts
INTERFACE = https://svn.apache.org/repos/asf/cassandra/trunk/interface/cassandra.thrift

egg: bdist_egg

all: setup.py $(SRCDIR) $(SCRIPTDIR)/Cassandra-remote

bdist bdist_egg bdist_rpm install register sdist test: all
	python setup.py $@

setup.py: setup.py.in
	sed "s/__VERSION__/'${VERSION}'/" <$^ >$@

$(SRCDIR): $(GENDIR)/gen-py
	mkdir -p $@
	cp -R $^/$(SRCDIR)/* $@

$(SCRIPTDIR)/Cassandra-remote: $(SRCDIR)/Cassandra-remote
	mkdir -p $(SCRIPTDIR)
	sed -e s/'import Cassandra'/'from cassandra import Cassandra'/ \
		-e s/'from ttypes import '/'from cassandra.ttypes import '/ \
		< $^ > $@
	chmod --reference $^ $@

$(GENDIR)/gen-py: cassandra.thrift
	-mkdir -p $(GENDIR)
	thrift -o $(GENDIR) -gen py:new_style=True  $^

update:
	@echo "Updating to: $(shell svn info $(INTERFACE) | grep ^Last\ Changed\ Rev | cut -d: -f2)"
	svn cat $(INTERFACE) > $(shell basename $(INTERFACE))

clean:
	rm -rf $(GENDIR) $(SRCDIR) $(SCRIPTDIR) gen-* build dist *.egg-info setup.py

