# Cmyster's Openstack TripleO Installer

An assortment of bash scripts that I used to prepare and install OpenStack 
using TripleO. I added and combined them all to this script to install with 
one command. Though I am a Redhat employee this has nothing to do with how 
Redhat are installing OpenStack. All of the work here is for my personal 
experimentation and you should not infer that any of it is related to my work 
at Redhat.

It is a side project of mine because I needed some flexibility and did not 
want to keep adjusting things manually. Also for something as simple and as 
straight forward as installing OpenStack, I wanted to use something easy for 
me to maintain. Though better tools exist, with more functionality and a 
large community support, they are much heavier, most of the functionality is 
useless to me and changes are far less frequent.

This script is installing everything on virtual machines so you need a pretty
strong hardware to pull it off on a single server. I use one with 256 RAM and
40 threads to install an HA (High Availability) environment.

## Requirements:
This script uses links to internal Redhat resources. *It will not
work outside of Redhat's internal network.*

A pretty strong server. At a bare minimum:

1 Undercloud VM    - 16GB RAM, 4 vCPUs, 22GB disk space.

1 Controller node - 12GB RAM, 2 vCPUs, 12GB disk space.

1 Compute node     -  8GB RAM, 2 vCPUs, 12GB disk space.  _installation only,
more of each resource is needed for launching VMs_

## Where to start?

[This is the first place to read about TripleO installations.](http://docs.openstack.org/developer/tripleo-docs/)

Then there is the `conf` file where all the configurations are kept with a
short explanation on each option.

## How to run?

Change to the folder, go over the `conf` file as installation will not work 
OOB, and change what you need.

Go over `run` and see the order in which things are executed. You can play
around with the order, remove bits or add exit points but note that most
steps (still) rely on previous ones.

Run `./run`. A log file will be created in `./logs` and a work directory at
`/tmp/coti`.

If you want to change a parameter on the fly, you can do something like 
'controller_NUM=4 ./run' to overwrite the default number of controllers
deployed.
