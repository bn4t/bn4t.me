---
title: "Coredns: Enable dnssec"
date: 2019-12-15
tags: ["coredns","dns","dnssec","security"]
draft: false
---
I recently got around to finally enable dnssec on the fly signing in my CoreDNS setup.

Since the process to set this up isn't very good documented I thought I'd write a short blog post about it.

# Steps

## 0. Only for docker

Make sure you have a directory for the dnssec keys mounted in your container.

## 1. Generate the dnssec key

To generate the dnssec key you need to have `bind9utils` installed. 

Use following command to generate a new key:

````
dnssec-keygen -a ECDSAP256SHA256 example.com
````

## 2. Distribute the key to all coredns instances

This took me a while to figure out since it doesn't seem to be documented anywhere.
If you run a multi instance CoreDNS setup (e.g. master-slave) the key needs to be distributed to all instances.

Zone transfer doesn't handle this for you.

## 3. Configure CoreDNS

Add a `dnssec` config option to the chosen zone configuration. 
The `key file` option specifies the path where the key lies. You don't need to specify the file extension for the key.

Example:

````
example.org {
    dnssec {
        key file /var/coredns/dnssec/Kexample.org.+013+45330
    }
    whoami
}
````

This needs to be done on all your CoreDNS instances. 
Then restart CoreDNS and make sure there are no errors in the logs.


## 4. Registrar setup

The next step is to create a DS record at your domain registrar.

To get the DS record you need to set use `dnssec-dsfromkey`.

Example:

````
dnssec-dsfromkey Kexample.org.+013+45330
````

The response should look somewhat like this:

````
# format: 
# <domain> IN DS <tag> <algorithm> <digest type> <digest>

example.com. IN DS 60323 13 1 3F4DE2555510AAFDD03E14F0F3C49F6DFB599844
example.com. IN DS 60323 13 2 CB4D7ED047B5875D87EEA31C823129DB68F628F4D2E0A784BC5FCFE1FCF4E266
````

Choose the second record with the longer digest (SHA256). The other one uses SHA1 which is no longer deemed secure.

After setting the record it can take up to 1-2 days for it to appear in the DNS. However usually it doesn't take longer than 30 minutes.

## 5. Check if everything works

To check if everything is set up correctly you can use an online dnssec check tool like [the one from Verisign](https://dnssec-debugger.verisignlabs.com/)

If everything works: Congratulations! Your domain now supports dnssec.
