---
title: "Full page caching with Cloudflare"
date: 2018-09-06
tags: ["cloudflare","caching"]
draft: true
---

## Full page caching with Cloudflare

One great feature of Cloudflare (among others) is their caching. This feature allows you to cache static assets (like pictures) on their edge servers.

When using a static html/css w 


### Troubles

As always there are certain problems when setting up something new.

In my case it was Netlify's CD which caused me some trouble. While compiling the hugo website locally worked fine the compilation on Netlify gave me a weird error.

````
ERROR: 2018/06/04 10:52:06 general.go:212: Error while rendering taxonomy terms for tag: template: theme/_default/terms.html:7:14: executing "theme/_default/terms.html" at <.Paginator>: error calling Paginator: unsupported type in paginate, got <nil>
````

Thankfully after a bit of research and try & error I found out that Netlify appearantly doesn't use the latest hugo version by default.

However the hugo version Netlify uses is adjustable using an environement variable which can be set in the web interface. Setting the version variable to the one I use locally finally solved the error.

---
Website Repository: https://gitlab.com/bn4t/bn4t.me

---

### Update

Later on I switched to Gitlab pages for automatic deployment, just because it's simpler and everything is in the same place. 
I also put cloudflare in front of my Website to enable their cdn and caching, which signifficantly decreased the loading time of the page (especially the caching).
