---
title: "Setting up a Lightning Node using docker and connecting to it with ZeusLN"
date: 2019-06-13
tags: ["bitcoin","lnd","docker","zeusln"]
draft: false
---

Lightning is a layer 2 for bitcoin which allows unfairly cheap and incredibly fast bitcoin transactions. [LND](https://github.com/lightningnetwork/lnd) is a lightning network implementation written in go.

This blog post shows how to set up a dockerized lightning node and how to use it with [ZeusLN](https://zeusln.app).
ZeusLN is an app to interact with LND.

## Docker Setup

To run LND and bitcoind (which we use as a backend for LND) dockerized we first need Dockerfiles.
I created two Dockerfiles which you can use to build images for LND and bitcoind.


### bitcoind Dockerfile

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



### LND Dockerfile

````
FROM golang:latest

RUN go get -d github.com/lightningnetwork/lnd
RUN go get -d github.com/LN-Zap/lndconnect && cd $GOPATH/src/github.com/LN-Zap/lndconnect && make
WORKDIR $GOPATH/src/github.com/lightningnetwork/lnd
RUN make && make install

ENTRYPOINT lnd
````

This Dockerfile compiles the latest version of LND and lndconnect. Lndconnect is a utility to make it easier to connect ZeusLN to our LND node.

Build these two docker images and tag them accordingly.

````
docker build -f Dockerfile.bitcoind -t tutorial/bitcoind . && docker build -f Dockerfile.lnd -t tutorial/lnd .
````


### Compose File

The compose file consists of the two services `bitcoind` and `lnd`.

For bitcoind we'll expose port `8333` so other nodes can connect to it. This isn't nessecary but helps strengthen the bitcoin network.

LND needs two ports exposed. 
For ZeusLN to be able to connect to our node we need to expose port `8080`. Port `9735` needs to be exposed so other nodes can connect to our node. Opening this port is only needed if you want other nodes to be able to open channels to yours.

Bitcoind has two volumes defined: one for the config and one for the blockdata. 
LND only requires one volume for the config.

````
version: "2.2"

services:
  bitcoin:
    image: tutorial/bitcoind
    restart: always
    volumes:
      - ./data/bitcoind/blockdata:/var/lib/bitcoin
      - ./data/bitcoind/conf:/etc/bitcoin
    ports:
      - "8333:8333"

  lnd:
    image: tutorial/lnd
    restart: always
    volumes:
      - ./data/lnd:/root/.lnd
    ports:
      - "8080:8080"
      - "9735:9735"
````


Save the compose file from above as `docker-compose.yml` and spin it up using `docker-compose up -d`.


### Configure bitcoind

Before we let bitcoind sync we want to create a config file. Open `data/bitcoind/conf/bitcoin.conf` with your favorite editor and enter following config options:

````
rpcport=8332
rpcallowip=0.0.0.0/0
rpcbind=0.0.0.0
rpcuser=lnd
rpcpassword=chooseyourownpassword
server=1
rest=1
zmqpubrawblock=tcp://0.0.0.0:28332
zmqpubrawtx=tcp://0.0.0.0:28333
txindex=1
dbcache=50
````
We chose a small dbcache on purpose so that when we execute `docker-compose down` which results in the bitcoind container not writing the cached blocks to disk, it won't take long to replay the cached blocks (See: https://bitcoin.stackexchange.com/questions/55368/what-does-replaying-blocks-mean).

The option `txindex=1` isn't nessecary but it increases the performance of LND.

Restart the bitcoin container and let it sync overnight.

----

### Configure LND

Next we configure LND. Open `data/lnd/lnd.conf` with your favorite editor and enter following config options:

````
[Application Options]

; The directory that lnd stores all wallet, chain, and channel related data
; within The default is ~/.lnd/data on POSIX OSes, $LOCALAPPDATA/Lnd/data on
; Windows, ~/Library/Application Support/Lnd/data on Mac OS, and $home/lnd/data
; on Plan9.  Environment variables are expanded so they may be used.  NOTE:
; Windows environment variables are typically %VARIABLE%, but they must be
; accessed with $VARIABLE here.  Also, ~ is expanded to $LOCALAPPDATA on Windows.
datadir=~/.lnd/data

; The directory that logs are stored in. The logs are auto-rotated by default.
; Rotated logs are compressed in place.
logdir=~/.lnd/logs

; Path to TLS certificate for lnd's RPC and REST services.
tlscertpath=~/.lnd/tls.cert

; Path to TLS private key for lnd's RPC and REST services.
tlskeypath=~/.lnd/tls.key

; minmum channel size in satoshis
minchansize=20000


; Specify the interfaces to listen on for p2p connections.  One listen
; address per line.
listen=0.0.0.0:9735


; Adds an extra ip to the generated certificate
; (old tls files must be deleted if changed)
tlsextraip=YOUR_EXTERNAL_IP


; Specify the interfaces to listen on for gRPC connections.  One listen
; address per line.
rpclisten=0.0.0.0:10009

; Specify the interfaces to listen on for REST connections.  One listen
; address per line.
restlisten=0.0.0.0:8080



; Adding an external IP will advertise your node to the network. This signals
; that your node is available to accept incoming channels. If you don't wish to
; advertise your node, this value doesn't need to be set. Unless specified
; (with host:port notation), the default port (9735) will be added to the
; address.
externalip=YOUR_EXTERNAL_IP



; Debug logging level.
; Valid levels are {trace, debug, info, warn, error, critical}
; You may also specify <subsystem>=<level>,<subsystem2>=<level>,... to set
; log level for individual subsystems.  Use lncli debuglevel --show to list
; available subsystems.
debuglevel=info

; The maximum number of incoming pending channels permitted per peer.
maxpendingchannels=5

; The alias your node will use, which can be up to 32 UTF-8 characters in
; length.
alias=RecklessNode⚡


[Bitcoin]

; If the Bitcoin chain should be active. Atm, only a single chain can be
; active.
bitcoin.active=1

bitcoin.mainnet=1

; Use the bitcoind back-end
bitcoin.node=bitcoind

; The default number of confirmations a channel must have before it's considered
; open. We'll require any incoming channel requests to wait this many
; confirmations before we consider the channel active.
bitcoin.defaultchanconfs=3


[Bitcoind]

; The host that your local bitcoind daemon is listening on. By default, this
; setting is assumed to be localhost with the default port for the current
; network.
bitcoind.rpchost=bitcoin

; Username for RPC connections to bitcoind. By default, lnd will attempt to
; automatically obtain the credentials, so this likely won't need to be set
; (other than for a remote bitcoind instance).
bitcoind.rpcuser=lnd

; Password for RPC connections to bitcoind. By default, lnd will attempt to
; automatically obtain the credentials, so this likely won't need to be set
; (other than for a remote bitcoind instance).
bitcoind.rpcpass=chooseyourownpassword

; ZMQ socket which sends rawblock and rawtx notifications from bitcoind. By
; default, lnd will attempt to automatically obtain this information, so this
; likely won't need to be set (other than for a remote bitcoind instance).
bitcoind.zmqpubrawblock=tcp://bitcoin:28332
bitcoind.zmqpubrawtx=tcp://bitcoin:28333

````

This config tells LND to use our bitcoind instance as backend.

**Make sure you edit alle the `YOUR_EXTERNAL_IP` values.**

Restart your LND conatiner to apply the configuration.

Execute `lncli create` to create a new wallet. This is the wallet LND will be using.
You’ll be asked to input and confirm a wallet password, which must be longer than 8 characters.
You also have the option to add a passphrase to your cipher seed.

Be sure to save the password in a password manager or similar. This password is needed to access the bitcoins in LNDs wallet.

### Connect using ZeusLN

Next we'll connect to our node using ZeusLN.
Make sure your LND wallet is unlocked by running `lncli unlock`.

Now execute in the LND container `lndconnect -p 8080` to generate a QR code which you can scan from the ZeusLN app.

Alternatively if the QR code isn't readable you can use `lndconnect -p 8080 -j` to generate an URL instead of a QR code. Paste this URL into an external QR code creator (make sure it doesn't send the data to a server; this URL contains the key to your LND node!) and scan it from the ZeusLN app.


---

Let me know if anything in this tutorial was unclear or if there are any mistakes:

- Matrix: [@bn4t:matrix.bn4t.me](https://matrix.to/#/@bn4t:matrix.bn4t.me)
- Email: me at bn4t.me







