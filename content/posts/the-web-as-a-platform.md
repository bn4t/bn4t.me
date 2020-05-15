---
title: "The web as a platform"
date: 2020-05-15
tags: ["web","posix","platform"]
draft: false
---
Lately I've been thinking about why the web has evolved from mostly static webpages to SPAs, WebAssembly & co and effectively becoming it's own platform.


### Cross-Platform is hard

I believe the main reason the web is used for so many applications is because it's the easiest way to make something cross-platform.

Unfortunately in the world we live making native applications cross-platform is rather difficult. 
That's why many companies or in general developers choose the web as a platform.

Web browsers have standardized APIs that are available on every platform. This makes it possible to write an application once and use it on every platform that implements those APIs.

### The web as a platform?

One might ask what's so bad about using the web as an application platform. 

The web was not meant to be an application platform[^1] in the same way browsers weren't meant to be an execution environment for programs.
Another, perhaps more practical argument is, that web applications are in general much slower than native applications.

The web becoming a major application platform is also one of the main reasons why browsers are so complex[^2]. 
The complexity of a browser nowadays is comparable to the complexity of an OS.

---

I think this whole situation could be a lot different. Imagine if every major OS was POSIX compliant. 
We would have the same standardized APIs available on every platform. Just like we do now with browsers.

I personally blame microsoft for this whole mess. They are the only major OS that's not POSIX compliant [^3].


[^1]: "The World Wide Web (WWW), commonly known as the Web, is an information system [...]", Source: https://en.wikipedia.org/wiki/World_Wide_Web

[^2]: https://drewdevault.com/2020/03/18/Reckless-limitless-scope.html 

[^3]: Technically Linux is only "mostly posix compliant".

