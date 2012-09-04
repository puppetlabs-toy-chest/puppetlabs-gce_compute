# Puppet Google Compute Resources

## Overview

This module contains native types that can be used to manage the creation
and destruction of objects in google compute as Puppet Resources.

It provides the following resource types:
* gce_instance - can be used to create machine instances.
* gce_disk     - can be used to create persistent disks that can be attached to instances.
* gce_firewall - can be used to create firewall rules.
* gce_network  - can be used to create networks.

These types allow users to describe application stacks in google compute using
Puppet's DSL. This provides the following benefits:

- Allows users to express application deployments as text that can be version controlled.
- Allows users to share Puppet manifests that describe app deployments in Google Compute.
- Allows users to take advantage of the composition aspects of the Puppet DSL to
  create reusasble and extendable abstraction layers on top of multi-node deployment descriptions.

These resources have also been implemented as Puppet Network Devices
- Allows Puppet Agent's to act as proxies for google compute
- Allows users to store google compute credentials on local agents (ensuring that the
credentials will not be exposed as part of the catalog)

## Usage

### Configure gcutil

In order to use these resources, you will need to
[signup](https://developers.google.com/compute/docs/signup)
 for a Google Compute account:

You will also need to designate one machine to be your Puppet Device Agent.
This machine will be responsible for interacting with the Google Compute APIs
and will be used to store your credentials for Google Compute.

On your Puppet Device Agent, [install and authenticate](https://developers.google.com/compute/docs/gcutil_setup) gcutil.

You should generate a credential file as a part of this process: ~/.gcutil_auth.

Next, create your device.conf file on the Device Agent.

The default location for this file can be discovered by running the command:

    puppet apply --configprint deviceconfig

(this is usually /etc/puppet/device.conf)

The device.conf file is used to map multiple certificate names to google compute projects.

Each section header in this file is the name of the certificate to use.
The element type should be set to 'gce' and the url should contain both the
path to the credentials file appended to the name of the project.

    #/etc/puppet/device.conf
    [certname1]
      type gce
      url [~/gcutil_auth]:group:my_project1
    [certname2]
      type gce
      url [~/gcutil_auth]:group:my_project2

### Specify Resources

Now create a Puppet manifest that describes the google compute
resources that you wish to manage:

    # manifests/site.pp
    gce_network { 'mynetwork':
      ensure      => present,
      description => 'new_network',
      range       => '10.1.0.0/16',
    }
    gce_disk { 'mydisk':
      ensure      => present,
      description => 'small test disk',
      size_gb     => '2',
    }
    gce_firewall { 'mysshfirewall':
      ensure      => present,
      description => 'allows incoming ssh connections',
      network     => 'mynetwork',
      allowed     => 'tcp:22',
    }
    gce_instance { 'instance1':
      ensure      => present,
      description => 'a test VM',
      disk        => 'mydisk',
      network     => 'mynetwork',
      tags        => [test, 'one']
    }

### Profit!

This manifest can be applied by running either puppet apply or puppet device on the
Puppet Device Agent.

Puppet apply can be used if the code describing the resources to create in google compute
is on the Puppet Device Agent:

    puppet apply --certname certname1 ~/manifests/app_deploy.pp

Puppet Device can be used if the manifest resides on a central Puppet Master:

    puppet device --certname certname1 --server master
