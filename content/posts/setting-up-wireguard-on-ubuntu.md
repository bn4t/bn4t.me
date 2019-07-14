---
title: "Setting up Wireguard on Ubuntu"
date: 2018-12-05
tags: ["wireguard","vpn","ubuntu"]
draft: false
---



## Intro

> WireGuard is an extremely simple yet fast and modern VPN that utilizes state-of-the-art cryptography. It aims to be faster, simpler, leaner, and more useful than IPSec, while avoiding the massive headache. It intends to be considerably more performant than OpenVPN. WireGuard is designed as a general purpose VPN for running on embedded interfaces and super computers alike, fit for many different circumstances. Initially released for the Linux kernel, it is now cross-platform and widely deployable. It is currently under heavy development, but already it might be regarded as the most secure, easiest to use, and simplest VPN solution in the industry.
>
> Source: https://wireguard.com

Since there didn't seem many [Wireguard](https://wireguard.com) tutorials on the internet, I thought I'd create one myself.

This is a tutorial on how to set up a Wireguard VPN on Ubuntu.



### Add PPA

To install the Wireguard packages we need to first add the Wireguard PPA. This is the official Wireguard PPA and can be [found on the Wireguard website](https://www.wireguard.com/install/). These packages need to be installed on the server and client.

Since Wireguard uses a kernel module we also need to install the `linux-headers` package.

````
sudo add-apt-repository ppa:wireguard/wireguard
sudo apt-get update
sudo apt-get install wireguard-dkms wireguard-tools linux-headers-$(uname -r)
````

### Generate the server keys

To generate the keys for the wireguard server execute following command on your server host in the `/etc/wireguard/` directory:

````
sudo wg genkey | sudo tee privatekey | sudo wg pubkey > publickey
````

This will create two files:

A file called `privatekey` with the private key of the server and a file called `publickey` with the respective publickey.


### Generate the Wireguard server config

Next we will create the config for the Wireguard server.

For this we create a file called `wg0.conf` in the `/etc/wireguard/` directory. Typically this is the config file of the virtual Wireguard interface called `wg0`.

This config file looks like this:

````
[Interface]
# The address and CIDR of the virtual interface wg0
Address = 10.0.0.1/24

# Replace this with the private key found in /etc/wireguard/privatekey
PrivateKey = <insert server_private_key>

# Add firewall forwarding and NAT rules when the wireguard interface starts
PostUp = iptables -A FORWARD -i wg0 -j ACCEPT; iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE

# Remove firewall forwarding and NAT rules when the wireguard interface stops
PostDown = iptables -D FORWARD -i wg0 -j ACCEPT; iptables -t nat -D POSTROUTING -o eth0 -j MASQUERADE

# This is the listen port of the wireguard server. Can be any port you wish.
ListenPort = 5555
````


### Generate the Wireguard client config

For this step you need to have Wireguard installed on your client. For Ubuntu you can follow the installation steps from above. Instructions for other platforms can be found on [the official Wireguard Website](https://www.wireguard.com/install/).

On the client we execute following command in the `/etc/wireguard/` directory to generate the client's private and public key.

````
sudo wg genkey | sudo tee privatekey | sudo wg pubkey > publickey
```` 

Now we need to create a config file in the `/etc/wireguard/` directory called `wg0.conf`. Make sure you do this on the client. 

This config file looks like this:

````
[Interface]
# The address and CIDR of the virtual interface wg0
Address = 10.0.0.2/32

# Replace this with the private key found in /etc/wireguard/privatekey
PrivateKey = <insert client_private_key>

[Peer]
# Insert the public key found on the server in the /etc/wireguard/publickey file
PublicKey = <insert server_public_key>

# Address and port of the server
Endpoint = <insert server_address>:5555

# Define an IP range to route through the Wireguard tunnel. 
# The 0.0.0.0/0 range tunnels all ipv4 traffic through wireguard
AllowedIPs = 0.0.0.0/0
````


### Start the VPN tunnel

Before we can start the VPN tunnel we need to add following section to the `/etc/wireguard/wg0.conf` file on the Wireguard server:

````
[Peer]
# The client's public key. Found in the /etc/wireguard/publickey file on the client
PublicKey = <insert client_public_key>

# Define which IPs that the client is allowed to be in the virtual network
AllowedIPs = 10.0.0.2/32
````


#### Enable IP forwarding on the server


To enable IP forwarding and make it persistent we need to edit the `/etc/sysctl.conf` file and set following line:

````
net.ipv4.ip_forward=1
````

To apply this configuration we need to execute:

````
sudo sysctl -p
````

This makes sure that the configuration persists after a reboot.


#### Configure firewall rules on the server

To enable allow wireguard connections we need to allow port `5555` in the firewall:

````
sudo ufw allow 5555
````


#### Enable the Wireguard Interfaces

To enable the Wireguard interfaces we need to execute on both the client and the server following command:

````
sudo wg-quick up wg0
````


We can check the state of the VPN connection by executing `sudo wg`.


## Wrapping up

There are some points when using Wireguard that should be noted. 
The VPN connection will remain persistent across networks. Unless you specifically bring the interface down or shutdown the computer, you will always be on the VPN.

To enable the Wireguard interfaces automatically on boot you can execute following command (recommended on the server):
````
sudo systemctl enable wg-quick@wg0
````

You should now have a secure VPN connection in place. You can confirm this by checking your IP with services such as https://ip.bn4t.me.

If you want to disconnect from the VPN you have to disable the Wireguard interface.
````
sudo wg-quick down wg0
````
---

Links that have been useful while creating this post:

- https://wireguard.com
- https://www.ckn.io/blog/2017/11/14/wireguard-vpn-typical-setup/

