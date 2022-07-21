# SPDX-License-Identifier: Apache-2.0

#
# Work in progress!
# See dockercontroller.go for how Fabric traditionally starts chaincode containers...
# https://github.com/hyperledger/fabric/blob/main/core/container/dockercontroller/dockercontroller.go#L279
#

ARG GO_VER=1.17.5
ARG ALPINE_VER=3.14

FROM golang:${GO_VER}-alpine${ALPINE_VER} as build
RUN apk add --no-cache \
	bash \
	binutils-gold \
  dumb-init \
	gcc \
	git \
	make \
	musl-dev

ADD . $GOPATH/src/github.com/hyperledgendary/conga-nft-contract
WORKDIR $GOPATH/src/github.com/hyperledgendary/conga-nft-contract

RUN go install ./...

FROM golang:${GO_VER}-alpine${ALPINE_VER}

# TODO create non root user for running chaincode?

COPY --from=build /usr/bin/dumb-init /usr/bin/dumb-init
COPY --from=build /go/bin/conga-nft-contract /usr/bin/conga-nft-contract

WORKDIR /var/hyperledgendary/conga-nft-contract
ENTRYPOINT ["/usr/bin/dumb-init", "--"]
CMD ["sh", "-c", "exec /usr/bin/conga-nft-contract -peer.address=$CORE_PEER_ADDRESS"]