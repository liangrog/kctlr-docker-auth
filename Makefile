# Makefile for ecm build and cross-compiling

APPNAME=kctlr-docker-auth
IMAGE_NAME=liangrog/kctlr-docker-auth

DOCKERFILE=Dockerfile

VERSION_TAG=`git describe 2>/dev/null | cut -f 1 -d '-' 2>/dev/null`
COMMIT_HASH=`git rev-parse --short=8 HEAD 2>/dev/null`
BUILD_TIME=`date +%FT%T%z`
LDFLAGS=-ldflags "-s -w \
    -X main.CommitHash=${COMMIT_HASH} \
    -X main.BuildTime=${BUILD_TIME} \
    -X main.Tag=${VERSION_TAG}"

all: fast

clean:
	go clean
	rm ./${APPNAME} || true
	rm -rf ./target || true

docker_binary:
	# Build static binary and disable cgo dependancy
	CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o $(APPNAME) ${LDFLAGS} .

docker_build:
	docker build . -f $(DOCKERFILE) -t $(IMAGE_NAME) --no-cache 

fast:
	go build -o ${APPNAME} ${LDFLAGS}

linux:
	GOOS=linux GOARCH=386 go build ${LDFLAGS} -o ./target/linux_386/${APPNAME}
	GOOS=linux GOARCH=amd64 go build ${LDFLAGS} -o ./target/linux_amd64/${APPNAME}

darwin:
	GOOS=darwin GOARCH=386 go build ${LDFLAGS} -o ./target/darwin_386/${APPNAME}
	GOOS=darwin GOARCH=amd64 go build ${LDFLAGS} -o ./target/darwin_amd64/${APPNAME}

windows:
	GOOS=windows GOARCH=386 go build ${LDFLAGS} -o ./target/windows_386/${APPNAME}.exe
	GOOS=windows GOARCH=amd64 go build ${LDFLAGS} -o ./target/windows_amd64/${APPNAME}.exe

build: clean linux darwin windows

docker: clean docker_binary docker_build
