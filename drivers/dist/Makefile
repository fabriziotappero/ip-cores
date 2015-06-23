scarts-drivers_version=1.0.0

SCARTS_DRIVERS_URI="svn+ssh://trac.ecs.tuwien.ac.at/ecs/repo/svn/projects/scarts/trunk/drivers"

all: scarts-drivers

scarts-drivers: 
	rm -rf $@-${$@_version}
	svn export ${SCARTS_DRIVERS_URI}/src $@-${$@_version}/src
	svn export ${SCARTS_DRIVERS_URI}/Makefile $@-${$@_version}/Makefile
	tar -czf $@-${$@_version}.tar.gz $@-${$@_version}

clean:
	rm -rf *.tar.gz scarts-*

