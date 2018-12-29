---
title: "Icanhaz toolset in PHP"
date: 2018-12-29
tags: ["icanhaz","php","caddy"]
draft: false
---


## Intro

I recently got around the create a PHP version of the Icanhaz toolset (icanhazip.com,...).

The only service that's missing is the traceroute service, because of php limitations.

## Services

- [ip.bn4t.me](https://ip.bn4t.me) - Returns your IP address
- [ptr.bn4t.me](https://ptr.bn4t.me) - Returns your hostname
- [epoch.bn4t.me](https://epoch.bn4t.me) - Returns the current Unix timestamp

All services are available through `http` and `https`.

## Source

The source to these services can be found [on my Gitlab](https://git.bn4t.me/root/icanhaz-php).

