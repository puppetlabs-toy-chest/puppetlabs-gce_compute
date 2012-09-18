# Puppet Google Compute Resources

## Overview

This module contains native types that can be used to manage the creation
and destruction of objects in Google Compute Engine [GCE](http://cloud.google.com/products/compute-engine.html) as Puppet Resources.

It provides the following resource types:
* gce_instance - Virtual machine instances that can be assigned roles.
* gce_disk     - Persistent disks that can be attached to instances.
* gce_firewall - Firewalls that allow certain kinds of traffic to your instances.
* gce_network  - Networks that routes internal traffic between virtual machine instances. Firewalls and instances are associated with networks.

These types allow users to describe application stacks in google compute using
Puppet's DSL. This provides the following benefits:

- Users can express application deployments as text that can be version controlled.
- Teams can share and collaborate on application deployments described using Puppet's DSL.
- Users can take advantage of the composition aspects of the Puppet DSL to
  create reusable and extendable abstraction layers on top of multi-node deployment descriptions.
- Allows Puppet to support ongoing management of application stacks created in GCE.

## Usage

### Configure gcutil

In order to use these resources, you will need to
[signup](https://developers.google.com/compute/docs/signup)
 for a Google Compute account: (note, GCE is currently only allowing restricted BETA access)

You will also need to designate one machine to be your Puppet Device Agent.
This machine will be responsible for provisioning objects into Google Compute using its API
and will be used to store your credentials for Google Compute.

On your Puppet Device Agent, [install and authenticate](https://developers.google.com/compute/docs/gcutil_setup) gcutil.

The authentication process should generate this credential file: ~/.gcutil_auth.

Next, create your device.conf file on the Agent.

The default location for this file can be discovered by running the command:

    puppet apply --configprint deviceconfig

(this is usually /etc/puppet/device.conf)

The device.conf file is used to map multiple certificate names to google compute projects.

Each section header in this file is the name of the certificate that is associated with a specified set of credentials and project identifier.
The element type should be set to 'gce' and the url should contain both the
path to the credentials file appended to the name of the project in the format below:

    #/etc/puppet/device.conf
    [my_project1]
      type gce
      url [credential_file]:project_id

The example below show how multiple certificate names can be used to represent multiple projects in GCE.

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

Run puppet apply on this manifest

    puppet apply --certname certname1 manifests/site.pp

and wait for your instances to be provisioned using GCE.

### Classifying resources

These resources support not only the ability to create virual machine instances as resources, but
also the ability to use Puppet to classify those instances.

The classification is currently only supported by running puppet apply during the bootstrapping process
of the created instances.

Classification is specified with the following gce_instance parameter:

* modules - List of modules that should be installed from the [forge](http://forge.puppetlabs.com/).

    modules => ['puppetlabs-mysql', 'puppetlabs-apache']

* module_repos - Modules that should be installed from github. Accepts a hash where the keys point to
github repos and the value indicates the directory in /etc/puppet where the module will be installed.

    module_repos => { 'git://github.com/puppetlabs/puppetlabs-mysql' => 'mysql'}

* classes - Hash of classes from our downloaded content that should be applied. The key of this hash is
the name of a class to apply and the value is a hash of parameters that should be set for that class.

    classes => { 'mysql' => { 'config_hash' => { 'bind_address' => '0.0.0.0' } }

* block_for_startup_script - Whether the resource should block until its startup sctipt has completed.
* startup_script_timeout - Amount of time to wait before timing out when blocking for a startup script.

### Implementation of classification

Classification is implemented by using metaparameters to pass information to created instances.

The following flag is used to pass the contents of the local file puppet-community.sh as the startup-script
metadata to our managed instance. This metadata key is automatically downloaded from all google compute instances
and started as a part of the bootstrapping process. This flag is set if module, module_repos, or classes are set.

    --metadata_from_file=startup-script:./files/puppet-community.sh

The script downloads the following metadata from the instance in order to bootstrap it:
* puppet_modules - set when the modules attribute is specified.
* puppet_classes - set when the classes attribute is specified.
* puppet_repos   - set when the module_repos attribute is specified.

### Data Lookups

The solution implements the ability to look up internal and external ip addresses for the classification of instances.

In order to retrieve the external or internal ip address of a different instance, the following syntax can be used from the
classes parameter:

    Gce_instance[database][internal_ip_address]

This is interpreted by the resource to mean it should retrieve the value of the internal_ip_address property
from the database resource of Gce_instance. This syntax only supports retrieving external_ip_address and
internal_ip_address from Gce_instance resources that are applied as part of the same catalog.

It is also possible to lookup an instances of our own $internal_ip_address or $external_ip_address.
This value is retrieved from the bootstrap script.

### Example

A full example can be located in the manifest: tests/example.pp
