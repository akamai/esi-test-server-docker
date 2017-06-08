VERSION := $(shell ls akamai-ets_*.tar.gz | grep -Eo "([[:digit:]]\.?)+")
REPO = ""
NAME = akamai-ets

.FORCE:

all: build test dist

# Add repo here if/once one is determined
build: .FORCE  ## Build the docker image
	git clone https://github.com/newscorpaus/akamai-ets.git
	cd akamai-ets; git checkout 4d3cf03
	docker build -f Dockerfile -t ${NAME}:${VERSION} -t ${NAME}:latest --no-cache .

test: 
	pushd dockerimage-tests && rake && popd

dist: build
	docker save ${NAME} -o ${NAME}.${VERSION}.dockerimage.tar
	gzip -f ${NAME}.${VERSION}.dockerimage.tar
