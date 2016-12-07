#Cmyster's Openstack TripleO Installer

An assortment of bash scripts that I used to prepare and install Openstack using TripleO. I added and combined them all to this script to install with one command. Though I am a Redhat employee, this has nothing to do with how Redhat are installing Openstack. All of the work here is for my personal experimentation and you should not infer that any of it as related to my work at Redhat.

It is a side project of mine because I needed some flexibility and did not want to keep adjusting things manually and for something as simple and as straight forward as installing Openstack and other solutions, though better in many aspects, were much "heavier" then a bunch of scripts.

This script is installing everything on virtual machines so you need a pretty strong hardware to pull it off on a single server. At work I use one with 128GB RAM and 24 cores to install an HA (High Availability).

##Requirements:
This script uses internal links to internal Redhat resources. *It will not work outside of Redhat's internal network.*

A pretty strong server. At a bare minimum:

1 Undercloud VM    - 16GB RAM, 4 vCPUs

1 Controller node - 12GB RAM, 2 vCPUs

1 Compute node     -  8GB RAM, 2 vCPUs _installation only, more needed for testing_

##Where to start?

[This is the first place to read about TripleO installations.](http://docs.openstack.org/developer/tripleo-docs/)

Then there is the `conf` file where all the configurations are kept with a short explanation on each option.

##How to run?

Change to the folder, go over the `conf` file as installing will not work OOB, and change what you need.

Go over `run` and see the order in which things are executed. You can play around with the order, remove bits or add exit points but note that most steps (still) rely on previous ones.

Run `./run`. A log file will be created in `./logs` and a work directory at `/tmp/codi`.

If you want to chnage a parameter on the fly, you can do something like 'controller_NUM=4 ./run' to overwrite the default number of controllers deployed.

##Known issues

Deploying ceph nodes does not work with default templates.
