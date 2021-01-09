---
title: "On the subtleties of URL parsing"
date: 2021-01-09
tags: ["url","golang","web"]
draft: false
---

A recent side project of me has been to write a scalable crawler which looks for broken resources (links, stylesheets, ...) on a website.
This project is meant to replace an existing crawler written in PHP with a more efficient implementation in golang.

Part of writing a crawler includes parsing URLs on pages. Thankfully golang has the `url.Parse` method which makes this job easy, though there are a couple of caveats to look out.

## Preceding spaces

Interestingly some `<a href="">` tags have a space before the actual URL, which causes the golang URL parser to fail.
My suspicion is that this mostly happens on hand-written html pages.

## Trailing slashes

This is quite a big one since it isn't obvious that a trailing slash can make such a difference when parsing (relative) URLs.

When an URL has a trailing slash and you combine it with a relative URL, the relative URL just gets appended to the original URL behind the slash.

However if there's no such trailing slash, the relative URL replaces the last part of the original URL.

**Example:**

```text
https://example.com/foo/
		--> bar.html	# https://example.com/foo/bar.html

https://example.com/foo
		--> bar.html	# https://example.com/bar.html
```

This can get tricky if a link to a website has *no* trailing slash, however the website redirects the user agent to an URL *with* a trailing slash. 
In such a case it's important to use the redirected URL to parse relative URLs, instead of the original request URL (In golang this would be the `Url` field of the `Request` struct, which is automatically updated on redirects). 
 
