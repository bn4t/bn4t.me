---
title: "How to setup Mastodon to use Openstack Swift for media storage"
date: 2022-11-19
tags: ["mastodon", "openstack", "devops", "infomaniak"]
draft: false
---

Hey,

It's been a while since I last posted on here.

Well, I'm back with a quick note on how to configure [Mastodon](https://joinmastodon.org) to use Openstack Swift (Openstack's pendant to S3) for media storage.

I recently setup my own mastodon instance ([nerdhut.ch](https://nerdhut.ch)) on Infomaniak's public cloud which runs Openstack.
Installing and setting up Mastodon went all smooth, however configuring it to use Swift took me a bit of time since there's quite a bit of lack of documentation.

Below is my Swift config for Mastodon (you can basically get all the values to fill in, from your openstack RC file):

```env
SWIFT_ENABLED=true
SWIFT_USERNAME=PCU-XXXXXX
SWIFT_PASSWORD=<your openstack user password>
SWIFT_PROJECT_ID=<openstack project id>
SWIFT_AUTH_URL=https://api.pub1.infomaniak.cloud/identity
SWIFT_CONTAINER=<swift container name>
SWIFT_REGION=dc3-a # check in your openstack RC file if this is correct for you
SWIFT_DOMAIN_NAME=default # don't really know what this is for
SWIFT_OBJECT_URL=<public link of the container>
```

If you use a different Openstack deployment than infomaniak's public cloud, you might need to use different settings. 

Also another important detail is to **NOT** set `SWIFT_TENANT` otherwise the Openstack client will fall back to Keystone v2, however Infomaniak's public cloud uses Keystone v3.

Finally, if you want to say hi or follow me on the fediverse, I'm [@benj@nerdhut.ch](https://nerdhut.ch/@benj).
