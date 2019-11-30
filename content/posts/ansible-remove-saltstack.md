---
title: "Ansible: Remove Saltstack"
date: 2019-11-30
tags: ["ansible","playbook","saltstack"]
draft: false
---
I recently migrated my infrastructure from [Saltstack](https://www.saltstack.com/) to [Ansible](https://www.ansible.com/).

To reason for this switch was relatively simple: I really liked that Ansible was agentless compared to Saltstack where you need a master and agents. 

Another reason was that I find Ansible playbooks a lot easier to write and maintain than Saltstack states.

To get my playbook skills going I decided to uninstall salt by using a playbook. 

The playbook I wrote is below available for anyone free to use. It uninstalls the `salt-*` packages, removes the Saltstack APT list and cleans up all the config, log and cache directories. It should run on all debian based distros.

**Warning:** This playbook also deletes the `/srv/salt` directory. Make sure you have it backed up before running the playbook.

````yaml
---
- hosts: all
  remote_user: root
  tasks:
    - name: remove salt packages
      apt:
        name: salt-*
        purge: yes
        state: absent

    - name: delete config files
      file:
        state: absent
        path: "/etc/salt/"

    - name: delete log files
      file:
        state: absent
        path: "/var/log/salt/"

    - name: delete cache files
      file:
        state: absent
        path: "/var/cache/salt/"

    - name: delete salt apt list
      file:
        state: absent
        path: "/etc/apt/sources.list.d/saltstack.list"

    - name: delete salt state files
      file:
        state: absent
        path: "/srv/salt/"

    - name: update apt cache
      apt:
        update_cache: yes
````