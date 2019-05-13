---
title: "Setting up a Lightning Node using docker and connect to it with ZeusLN"
date: 2019-05-13
tags: ["bitcoin","lnd","docker"]
draft: true
---

Lightning is a layer 2 for bitcoin which allows instant transactions. [LND](https://github.com/lightningnetwork/lnd) is a lightning network implementation written in go.

This blog post shows how to set up a dockerized lightning node and how to use it with ZeusLN[https://zeusln.app).

ZeusLn is an app to interact with LND.

## Docker Setup

To run LND and bitcoind (which we use as a backend for LND) dockerized we first need Dockerfiles.

I created two Dockerfiles which you can use to build images for LND and bitcoind.


#### bitcoind Dockerfile

````
FROM alpine:latest

RUN apk update && apk upgrade && apk add bitcoin sudo && \
	mkdir -p /var/lib/bitcoin && \
	mkdir -p /etc/bitcoin

# cli arguments from https://en.bitcoin.it/wiki/Running_Bitcoin
ENTRYPOINT chown -R bitcoin /var/lib/bitcoin && \
			chown -R bitcoin /etc/bitcoin && \
			sudo -u bitcoin bitcoind -conf=/etc/bitcoin/bitcoin.conf -datadir=/var/lib/bitcoin
````

In this Dockerfile we install bitcoind from the alpine repositories and set the data and config directory. 



#### LND Dockerfile

````
FROM golang

RUN go get -d github.com/lightningnetwork/lnd
RUN go get -d github.com/LN-Zap/lndconnect && cd $GOPATH/src/github.com/LN-Zap/lndconnect && make
WORKDIR $GOPATH/src/github.com/lightningnetwork/lnd
RUN make && make install

ENTRYPOINT lnd
````

This Dockerfile compiles the latest version of LND and lndconnect. Lndconnect is a utility to make it easier to connect ZeusLN to our LND node.


Build these two docker images and tag the accordingly.







