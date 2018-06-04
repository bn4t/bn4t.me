---
title: "Creating a new website"
date: 2018-06-04
tags: ["hugo","web","netlify"]
draft: false
---

## Creating a new website

Finally, after delaying it for a long time, I did it. I finally updated my website!

In contrast to my old website I took a way cleaner approach. Instead of messing around with pure html and css (which I'm not really good at) I went and invested some time looking into [hugo](https://gohugo.io).

[Hugo](https://gohugo.io) is a fantastic tool to create static Websites. Thanks to the extensive amount of available tmeplates it's easy to create a good looking static site in minutes.

Combined with Netlify's CD (on which this website runs) it is very comfortable to host a hugo website.


### Troubles

As always there are certain problems when setting up something new.

In my case it was Netlify's CD which cuased me some trouble. While compiling the hugo website locally worked fine the compilation on Netlify gave me a weird error.

````
ERROR: 2018/06/04 10:52:06 general.go:212: Error while rendering taxonomy terms for tag: template: theme/_default/terms.html:7:14: executing "theme/_default/terms.html" at <.Paginator>: error calling Paginator: unsupported type in paginate, got <nil>
````

Thankfully after a bit of research and try & error I found out that Netlify appearantly doesn't use the latest hugo version by default.

Fortunately however the hugo version Netlify uses is adjustable using an environement variable which can be set in the web interface. Setting the version variable to the on I use locally finally solved the error.
