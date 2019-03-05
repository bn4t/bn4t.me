---
title: "TLS 1.3 arrived!"
date: 2019-03-05
tags: ["tls","caddy","web"]
draft: false
---
Feburary 25th [Go 1.12 got released](https://blog.golang.org/go1.12) with opt-in support for TLS 1.3. With the [0.11.5 release](https://github.com/mholt/caddy/releases/tag/v0.11.5) of caddy which builds on Go 1.12, [caddy finally supports TLS 1.3](https://github.com/mholt/caddy/commit/72d0debde6bf01b5fdce0a4f3dc2b35cba28241a).

This also means that this site and (most of) the services I run, now support TLS 1.3.

![This site now supports TLS1.3! Yay!](/img/ssllabs-bn4t-me-tls-1-3.png)


TLS 1.3 is the latest version of the TLS protocol, with many improvements.

These improvements include:

- Mandatory perfect forward secrecy
- Weak hash functions and ciphers got removed
- Dropped support for many insecure or obsolete features including compression, renegotiation, non-AEAD ciphers, non-PFS key exchange, custom DHE groups and more
- And more ([full list](https://www.cloudflare.com/learning-resources/tls-1-3/))

Not only is TLS 1.3 exciting because it improves the security of TLS but it also increases performance greatly.

This is achieved by (1) removing a whole round-trip in the TLS handshake and (2) implementing 0-RTT, a feature that makes it possible to resume a TLS connection, which allows another round-trip to be eliminated (read more about 0-RTT [here](https://blog.cloudflare.com/introducing-0-rtt/)).


To wrap it up TLS 1.3 improves security and is a lot faster than TLS 1.2 which I think is really awesome.



