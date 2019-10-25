---
title: "Re-enable single server mode in Drone CI"
date: 2019-10-25
tags: ["drone","continous integration"]
draft: false
---

## Re-enable single server mode in Drone CI

Drone CI comes since version [1.5.0](https://discourse.drone.io/t/1-5-0-release-notes/5797) with multi-server mode (in which builds are processed by external CI runners) activated by default.

This can be problematic if you're used to drone running in single server mode.
If single-server mode isn't explicitly disabled and no runners are configured it just causes your builds to be stuck with a `pending` status.

It took me quite a while to figure why drone suddenly stopped processing builds (to be fair I updated without reading the changelog).

Luckily there is an easy solution to re-enable single-server mode.

Just add the environment variable `DRONE_AGENTS_DISABLED=true` to your drone instance and it should process builds again like it did before.