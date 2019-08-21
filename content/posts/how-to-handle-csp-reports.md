---
title: "How to handle CSP reports"
date: 2019-08-21
tags: ["csp","security","web"]
draft: false
---
> Content Security Policy (CSP) is an added layer of security that helps mitigate certain types of attacks, like Cross Site Scripting  and data injection attacks. 

CSP is a pretty powerful tool that defines what content on your Website is allowed to be parsed/executed. 
On top of that it is relatively easy and relatively low risk (compared to HSTS or HKPK) to deploy, since the browser doesn't cache content security policies.

If writing your own CSP sounds too complicated there are also many [useful](https://report-uri.com/home/generate) [CSP](https://www.cspisawesome.com/) [generators](https://toolstud.io/network/csp.php).

---

CSP has a feature called violation reporting. 

This feature reports browser detected CSP violations to a defined endpoint.
A CSP violation report is a HTTP POST request with a JSON payload.


The JSON payload looks like this:

````json
{

 "csp-report": {

   "document-uri": "https://example.com/login",

   "referrer": "https://example.com",

   "blocked-uri": "https://evil-script.com/bad.js",

   "violated-directive": "script-src https://cdn.example.com",

   "original-policy": "default-src 'none'; script-src https://cdn.example.com; style-src 'self'; report-uri https://example.com/csp-reports"

 }

}
````

It contains following fields:

- `document-uri` --> The URI at which the violation occurred
- `referrer` --> The HTTP referrer if available
- `blocked-uri` --> the URI which got blocked by the Content Security Policy
- `violated-directive` --> The part of the CSP which got violated
- `original-policy` --> The full Content Security Policy sent by the web server



Ideally such CSP reports are somehow handled and don't go straight to /dev/null.

A common practice is to parse the JSON payload and send an email with the report to site admins email.

For my personal websites this is also how I handle CSP reports. To parse the report and send out the received report by mail I [created a neat little go app](https://git.bn4t.me/bn4t/csp-handler). Feel free to use it, if it fits your needs. 



## Things to keep in mind

Something important to keep in mind when sending received CSP reports by mail is that anyone can send a CSP report.
Even if no violation occurred. 

This could lead to spam since a CSP report is nothing but a simple HTTP POST request.

An easy solution to this is to set up a (per IP) rate limit. Since CSP violations aren't the norm to happen, it makes sense to set a low rate limit.
