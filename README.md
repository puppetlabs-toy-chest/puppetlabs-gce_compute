# gce_compute

#### Table of Contents

1. [Overview](#overview)
2. [Module Description - What the module does and why it is useful](#module-description)
3. [Setup - The basics of getting started with fog_compute](#setup)
4. [Usage - Configuration options and additional functionality](#usage)
    * [Setting up authorization](#setting-up-authorization)
    * [Making a manifest](#making-a-manifest)
6. [Development - Guide for contributing to the module](#development)

## Overview

NOTE: This is just a temporary 'getting started' README for internal review.

The fog compute module provides everything you need to manage compute instances, disk storage and network interfaces in Google Compute Engine in Puppet's declarative DSL. It will even provision and configure Puppet Enterprise or Puppet Open Source during instance creation. 

## Module Description

The gce_compute module provides the following resource types:

* `gce_instance` - Virtual machine instances that can be assigned roles.
* `gce_disk`     - Persistent disks that can be attached to instances.
* `gce_firewall` - Firewall rules that specify the traffic to your instances.
* `gce_network`  - Networks that route internal traffic between virtual machine
  instances. Firewalls and instances are associated with networks.
* `gce_forwardingrule`  - Load balancer forwarding rules.
* `gce_httphealthcheck`  - Load balancer HTTP health checking.
* `gce_targetpool` - Load balancer collection of instances.
* `gce_targetpoolhealthcheck`  - Assignment of a health-check to a targetpool.

These types allow users to describe application stacks in Google Compute
Engine using Puppet's DSL. This provides the following benefits:

* Users can express application deployments as text that can be version
  controlled.
* Teams can share and collaborate on application deployments described using
  Puppet's DSL.
* Users can take advantage of the composition aspects of the Puppet DSL to
  create reusable and extendable abstraction layers on top of multi-node
  deployment descriptions.
* Allows Puppet to support ongoing management of application stacks created in
  GCE.

## Setup
In order to use this module, you will need to
[signup](https://developers.google.com/compute/docs/signup)
 for a Google Cloud Platform account and enable Google Compute Engine.

The instance to be used as the master must have read/write enabled for compute engine. Add the `--service_account_scopes=compute-rw` flag to the gcutil command when creating the instance or select 'Read Write' under the Compute Project Access when creating the instance through the Developers Console (you may neet to 'show advanced options' to see this field).
It is not possible to give an existing instance read/write for compute, so be careful to complete this step correctly.

Follow the [documentation](http://docs.puppetlabs.com/guides/install_puppet/install_debian_ubuntu.html) to install Puppet on the node.

For quick testing on Debian Wheezy, try the following:

1. `wget https://apt.puppetlabs.com/puppetlabs-release-wheezy.deb`
1. `sudo dpkg -i puppetlabs-release-wheezy.deb`
1. `sudo apt-get update && sudo apt-get upgrade -y`
1. `sudo apt-get install puppetmaster -y`

For [Fog](fog.io/compute/) on Debian Wheezy install build-essential and ruby-dev with:

1. `sudo apt-get build-essential ruby-dev -y`

Install ruby gems `fog` and `google-api-client` with:

1. `sudo gem install google-api-client --no-rdoc --no-ri`
1. `sudo gem install fog --no-rdoc --no-ri`

In order to use this repo as a Puppet module, create a symlink to Puppet's
`modules` directory to your local copy of this git repo:

1. `cd ~`
1. `git clone https://github.com/GoogleCloudPlatform/gce_compute_fog gce_compute`
1. `sudo ln -s ~/gce_compute /etc/puppet/modules/gce_compute`

## Usage

### Setting up authorization

#### Auth with temporary tokens (recommended)

This method requires a master with compute read/write permissions and will
only work if your master is running in Google Compute Engine.  This auth
method will retrieve an `authorization token` from GCE's internal metadata
service.

Create type called `gce_auth` with the name as the project id in your manifest. Your resource should look something like:
```
gce_auth { 'project-id':
}
```

#### Auth using client email and key file

If your master resides outside of Compute Engine, you will need to use a
Service Account.

1. Create a [GCE service account](https://developers.google.com/compute/docs/faq#howdoicreate). 
2. Push the key file downloaded from step one to your master VM.
3. Create a `gce_auth` resource in your manifest file that inculdes the client email and the absolute path to the key file. 
```
gce_auth { 'project-id':
   client_email => <client email>
   key_file     => </path/to/keyfile>
}
```

#### For legacy manifest files (deprecated)

The `--certname` option for `puppet apply` and `device.conf` can still be used *only if the master VM has compute read/write permissions*.

### Making a manifest

Once authentication is set up, the only thing left to do is make a manifest file.

A simple manifest that creates 2 VMs is shown below.
```
gce_auth { 'project-id':
}

gce_disk { 'instance-1-disk':
  ensure          => present,
  source_image    => debian-7,
  size_gb         => 10,
  zone            => us-central1-a,
}

gce_instance { 'instance-1':
  ensure          => present,
  zone            => us-central1-a,
  disks           => ['instance-1-disk,boot'],  
  machine_type    => n1-standard-1,
  puppet_master   => "$fqdn",
  puppet_service  => present,
  network         => 'default',
}

gce_disk { 'instance-2-disk':
  ensure          => present,
  source_image    => debian-7,
  size_gb         => 10,
  zone            => us-central1-a,
}

gce_instance { 'instance-2':
  ensure          => present,
  zone            => us-central1-a,
  disks           => ['instance-2-disk,boot'],  
  machine_type    => n1-standard-1,
  puppet_master   => "$fqdn",
  puppet_service  => present,
  network         => 'default',
}
```
Once you have a manifest, use `sudo puppet apply </path/to/manifest>` to create or destroy GCE resources

To use the examples provided in this repository change the *project-id* defined in the `gce_auth` type to the project you will be using.

## Troubleshooting

* Ensure that nokogiri bundled with fog has all required dependencies. For example, Debian Wheezy requires `build-essential` and `ruby-dev`
* Temporary authentication tokens time out after an hour, so if a single manifest takes longer to apply, use a service account email and key file for authentication.
* If you see an error saying you have insufficient permissions, check the [Developers Console](https://console.developers.google.com/) to make sure that your puppet master has compute read / write permissions.
* If you see warning that *templatedir is deprecated*, you may comment out the `templatedir` entry in `/etc/puppet/puppet.conf`.
* For legacy manifest files where the `gce_auth` resource is not added, an additional parameter is required for each resource: `provider => 'gcutil'`
