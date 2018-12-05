---
title: "Setting up Wireguard on Ubuntu"
date: 2018-12-05
tags: ["wireguard","vpn","ubuntu"]
draft: true
---

## Intro

Since there didn't seem many [Wireguard](https://wireguard.com) tutorials on the internet, I thought I'd create one myself.

This is a tutorial on how to set up a Wireguard VPN on Ubuntu.

### Add PPA

To install the Wireguard packages we need to first add the Wireguard PPA. This is the official Wireguard PPA and can be [found on the Wireguard website](https://www.wireguard.com/install/). These packages need to be installed on the server and client.

Since Wireguard uses a kernel module we also need to install the `linux-headers` package.

````
sudo add-apt-repository ppa:wireguard/wireguard
apt-get update
apt-get install wireguard-dkms wireguard-tools linux-headers-$(uname -r)

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
Address = 10.200.200.1/24                   # The address and CIDR of the virtual interface wg0
PrivateKey = <insert server_private_key>    # Replace this with the private key found in /etc/wireguard/privatekey
ListenPort = 5555                           # This is the listen port of the wireguard server. Can be any port you wish.
````


### Generate the Wireguard client config

For this step you need to have Wireguard installed on your client. For Ubuntu you can follow the installation steps from above. Instructions for other platforms can be found on [the official Wireguard Website](https://www.wireguard.com/install/).

Next we execute following command in the `/etc/wireguard/` directory to generate the client's private and public key.

````
sudo wg genkey | sudo tee privatekey | sudo wg pubkey > publickey
```` 

Now we need to create a config file in the `/etc/wireguard/` directory called `wg0.conf`. Make sure you do this on the client. 

This config file looks like this:

````
[Interface]
Address = 10.200.200.2/32                   # The address and CIDR of the virtual interface wg0
PrivateKey = <insert client_private_key>    # Replace this with the private key found in /etc/wireguard/privatekey

[Peer]
PublicKey = <insert server_public_key>      # Insert the public key found on the server in the /etc/wireguard/publickey file
Endpoint = <insert server_address>:5555     # Address and port of the server
AllowedIPs = 0.0.0.0/0                      # Define an IP range to route through the Wireguard tunnel. 0.0.0.0/0 tunnels all ipv4 traffic through wireguard
````


### Start the VPN tunnel

Before we can start the VPN tunnel we need to add following section to the `/etc/wireguard/wg0.conf` file on the Wireguard server:

````
[Peer]
PublicKey = <insert client_public_key>      # the client's public key. Found in the /etc/wireguard/publickey file on the client
AllowedIPs = 10.200.200.2/32                # Define which IPs that the client is allowed to be in the virtual network
````


### Enable IP forwarding on the server

To enable IP forwarding on the server we need to edit the `/etc/sysctl.conf` file and set following line:

````
net.ipv4.ip_forward=1
````

To make this configuration change permanent we need to execute following commands:

````
sysctl -p
echo 1 > /proc/sys/net/ipv4/ip_forward
````


### Configure firewall rules on the server

We need to set up a few firewall rules to manage our VPN traffic.


Track VPN connection

````
sudo iptables -A INPUT -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
sudo iptables -A FORWARD -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
````


Allowing incoming VPN traffic on the listening port

````
iptables -A INPUT -p udp -m udp --dport 5555 -m conntrack --ctstate NEW -j ACCEPT
````


Allow forwarding of packets that stay in the VPN tunnel

````
iptables -A FORWARD -i wg0 -o wg0 -m conntrack --ctstate NEW -j ACCEPT
````


Set up masquerading for VPN packets so they have the server's source address

````
iptables -t nat -A POSTROUTING -s 10.200.200.0/24 -o eth0 -j MASQUERADE
````


To make these IPtable rules persistent we need to install the `iptables-persistent` package and enable it on boot.

````
sudo apt-get install iptables-persistent && systemctl enable netfilter-persistent && netfilter-persistent save
````



#### Enable the Wireguard Interfaces

To enable the Wireguard interfaces we need to execute on both the client and the server following command:

````
sudo wg-quick up wg0
````

We can check the state of the VPN connection by executing `sudo wg`.

