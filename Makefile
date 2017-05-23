VERSION := $(shell ls akamai-ets_*.tar.gz | grep -Eo "([[:digit:]]\.?)+")
REPO = ""
NAME = akamai-ets

.FORCE:

all: dist

# Add repo here if/once one is determined
build: .FORCE  ## Build the docker image
	docker build -f Dockerfile -t ${NAME}:${VERSION} -t ${NAME}:latest --no-cache .

dist: build
	docker save ${NAME} -o ${NAME}.${VERSION}.dockerimage.tar
	gzip -f ${NAME}.${VERSION}.dockerimage.tar