#Puppet for Google Compute Engine

####Table of Contents

1. [Overview](#overview)
2. [Module Description - What the module does and why it is useful](#module-description)
3. [Setup - The basics of getting started with gce_compute](#setup)
4. [Quick Start - Get going quickly with Puppet Enterprise trial](#quick-start-with-puppet-enterprise)
4. [Usage - Configuration options and additional functionality](#usage)
5. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
5. [Limitations - OS compatibility, etc.](#limitations)
6. [Development - Guide for contributing to the module](#development)

##Overview

The gce_compute module provides everything you need to manage compute instances, disk storage and network interfaces in Google Compute Engine in Puppet's declarative DSL. It will even provision and configure Puppet Enterprise or Puppet Open Source during instance creation.

It should work on any system that supports Google's [Cloud SDK](https://developers.google.com/cloud/sdk/#System_Requirements) but it has not been tested on Windows.

##Setup

In order to use this module, you will need to
[signup](https://developers.google.com/compute/docs/signup)
 for a Google Cloud Platform account and enable Google Compute Engine.

You will also need to designate one machine to be your Puppet Device Agent.
This machine will be responsible for provisioning objects into Google Compute
using the `gcutil` command-line utility that is now bundled as part of the Cloud
SDK. Follow the setup instructions for the
[Google Cloud SDK](https://developers.google.com/cloud/sdk/) and make sure
to authenticate as instructed.

Next, create your `device.conf` file on the Agent. The default location for
this file can be discovered by running the command (typically
`/etc/puppet/device.conf`):

    puppet apply --configprint deviceconfig

The `device.conf` file is used to map multiple certificate names to Google
Compute projects.

Each section header in this file is the name of the certificate that is
associated with a specified set of credential placeholder path and project
identifier.  The element type should be set to 'gce' and the url should
contain both a file path and the name of the project in the format below:

    #/etc/puppet/device.conf
    [my_project1]
      type gce
      url [/dev/null]:project_id

Note that this version of the gce_compute module sets the file path to
`/dev/null`.  This is a placeholder value that will be used to reference
a credentials file in a newer release of this module.  For now, setting
the value to `/dev/null` is a working solution as long as you have previously
set up Cloud SDK with the `gcloud auth login` command.

### Multiple Projects

You can use multiple cloud projects by making the appropriate entries in your
`device.conf` file and adjusting the Cloud SDK settings.  For each project,
you'll first need to create authorize each project with:

    gcloud config set account ANOTHER_ACCOUNT_NAME
    gcloud auth login

Once all of your projects have been authorized, you can toggle which project
will be used prior to invoking `puppet apply` by using:

    gcloud config set project PROJECT

The example below show how multiple certificate names can be used to represent
multiple projects in GCE.

    #/etc/puppet/device.conf
    [certname1]
      type gce
      url [/dev/null]:group:my_project1
    [certname2]
      type gce
      url [/dev/null]:group:my_project2

## Quick Start with Puppet Enterprise

These instructions assume you have installed and configured the Google Cloud
SDK from the previous step. They also assume you have installed
a [Puppet](http://docs.puppetlabs.com/guides/install_puppet/pre_install.html) or
[Puppet Enterprise](http://docs.puppetlabs.com/pe/latest/install_agents.html)
Agent.

[Puppet Enterprise](http://puppetlabs.com/download-puppet-enterprise) is free to evaluate on up to 10 nodes and is installed for you as part of these examples.

1. Install the Google Compute Engine Puppet module  

    `puppet module install puppetlabs-gce_compute`


2. Bring up a GCE instance that will auto-install the PE Master

One of the easiest ways to take advantage of this module is to build a single instance in Google Compute Engine to serve as your Puppet Enterprise master and console. After going through the [setup](#setup), save the following resource to a file (like `gce.pp`) and run `puppet apply gce.pp`.

  ```puppet
    gce_instance { 'puppet-enterprise-master':
        ensure       => present,
        description  => 'A Puppet Enterprise Master and Console',
        machine_type => 'n1-standard-1',
        zone         => 'us-central1-a',
        network      => 'default',
        image        => 'projects/centos-cloud/global/images/centos-6-v20131120',
        tags         => ['puppet', 'pe-master'],
        startupscript        => 'puppet-enterprise.sh',
        metadata             => {
          'pe_role'          => 'master',
          'pe_version'       => '3.3.1',
          'pe_consoleadmin'  => 'admin@example.com',
          'pe_consolepwd'    => 'puppetize',
        },
        service_account_scopes => ['compute-ro'],
    }
   ```

   The install may take up to ten minutes but the instance should be up within a
   minute or two. You can SSH into it...

   ```
   gcutil ssh puppet-enterprise-master
   ```

   and tail the log until it's finished.

   ```
   sudo tail -f /var/log/messages
   ```

   When finished, you'll see a line like this in your log.

   ```
   puppet-enterprise-master startupscript: Puppet installation finished!
   ```

3. Use Puppet to build an additional instance, automatically connected to your PE Master.

  ```puppet
    gce_instance { 'sample-agent':
      ensure         => present,
      zone           => 'us-central1-a',
      machine_type   => 'g1-small',
      network        => 'default',
      image          => 'projects/centos-cloud/global/images/centos-6-v20131120',
      startupscript  => 'pe-simplified-agent.sh',
      metadata       => {
        'pe_role'    => 'agent',
        'pe_master'  => 'puppet-enterprise-master',
        'pe_version' => '3.3.1',
      },
      tags           => ['puppet', 'pe-agent'],
    }
    ```

    ```
    puppet apply agent.pp
    ```

4. (Optionally) Use the future parser to build many more instances.

    ```puppet
    $a = ['1','2','3','4','5','6','7','8']
    each( $a ) |$value|{

      gce_instance { "sample-agent-${value}":
        ensure         => present,
        zone           => 'us-central1-a',
        machine_type   => 'g1-small',
        network        => 'default',
        image          => 'projects/centos-cloud/global/images/centos-6-v20131120',
        startupscript  => 'pe-simplified-agent.sh',
        metadata       => {
          'pe_role'    => 'agent',
          'pe_master'  => 'puppet-enterprise-master',
          'pe_version' => '3.3.1',
        },
        tags           => ['puppet', 'pe-agent'],
      }

    }
    ```

    ```
    puppet apply agent.pp --parser future
    ```

## A Complete Demo Stack

Google Cloud Platform hosts [a complete demo stack on GitHub](https://github.com/GoogleCloudPlatform/compute-video-demo-puppet). It includes more GCE resources like load balancers and firewall rules.

## Reference

The gce_compute module provides the following resource types:

* `gce_instance` - Virtual machine instances that can be assigned roles.
* `gce_disk`     - Persistent disks that can be attached to instances.
* `gce_firewall` - Firewall rules that specify the traffic to your instances.
* `gce_network`  - Networks that routes internal traffic between virtual machine
  instances. Firewalls and instances are associated with networks.
* `gce_forwardingrule`  - Load balancer forwarding rules.
* `gce_httphealthcheck`  - Load balancer HTTP health checking.
* `gce_targetpool` - Load balancer collection of instances.
* `gce_targetpoolhealthcheck`  - Assignment of a health-check to a targetpool.
* `gce_targetpoolinstance`  - Assignment of an instance to a targetpool.

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

#### Service Account Scopes

Note that if your GCE instances will need access to other Google Cloud
services (e.g.
[Google Cloud Storage](https://cloud.google.com/products/cloud-storage),
[Google BigQuery](https://cloud.google.com/products/big-query), etc.) then you
can specify access with the `--service_account_scopes`. For more information
about Service Account scopes, see
[this page](https://developers.google.com/compute/docs/authentication).

The PE Quick Start example assigns the Master a compute-ro service scope which
allows it to query metadata about other instances within the GCE project. This
information is used for automatic certificate signing.

#### Automatic Certificate Signing

If you plan to host your Puppet master and agents in Google Compute Engine, this
module can take advantage of Google's API and Metadata services to verify and
automatically connect agents to the master so that they can immediately be assigned
work after creation.

To use this capability, you must specify particular properties in your gce_instance resources.

- Within the Puppet Master resource, assign a service account scope that can query GCE metadata.

`service_account_scopes => ['compute-ro'],`

- The Puppet Master resource also needs to install the gce_compute module and configure itself with the provided autosigner class.

  ```puppet
    modules  => ['puppetlabs-gce_compute'],
    manifest => 'include gce_compute::autosign',
    ```

- Within the Puppet Agent resources, assign the `pe-simplified-agent.sh` startup script.

`startupscript  => 'pe-simplified-agent.sh',`

With this configuration, agents will retrieve particular metadata about themselves
from the GCE metadata service and insert them into their certificate signing request.
The Puppet Master will query the metadata service for the same information and ensure
that it matches what the agent claims in its CSR.

__Be careful.__ This configuration trusts that you've protected your Google credentials
and that you trust everyone who has credentials to provision instances inside of
your Google Compute Engine project. So long as this chain remains trustworthy, this
method will reliably connect newly provisioned instances to your PE infrastructure
without interaction.

#### Persistent Disks and Instances

When an instance is created, the module will first check to see if there is a
pre-existing persistent disk with the same name as the instance and attempt to
use that as the instance's boot disk. If no such disk exists, a new persistent
disk will be created.

When you delete an instance, the persistent disk will *not* be deleted. This
provides the default behavior of persisting your data between instance
termination and re-creation. If you truly want to delete a persistent disk,
you must do so explicitly with it's own type-block and `ensure => absent` attribute.

### Enable/Disable Live Instance Migration

Your Compute Engine instances, by default, will enable live migration.  In
the event that Google needs to perform a datacenter maintenance, your instance
will be automatically migrated to a new location without visible impact.
This feature can be disabled by setting `on_host_migration` to `false`.

### Classifying resources

`gce_instance` resources can also contain classification data to be used by the startup scripts described below.

The classification is currently only supported by running `puppet apply`
during the bootstrapping process of the created instances and can be done
with the `enc_classes` parameter that utilizes
[External Node Classifiers](http://docs.puppetlabs.com/guides/external_nodes.html)
or by passing in the contents of a manifest file with the `manifest` parameter.
If *both* parameters are specified, both will be applied to the instance with
ENC first followed by the manifest file.

Classification is specified with the following `gce_instance` parameters:

* `modules` - List of modules that should be installed from the
  [forge](http://forge.puppetlabs.com/).

  ```puppet
    modules => ['puppetlabs-mysql', 'puppetlabs-apache']
  ```

* `module_repos` - Modules that should be installed from github. Accepts a hash
  where the keys indicates the directory where the module should be installed and the value points to the GitHub repo.

  ```puppet
  module_repos => { 'mysql' => 'git://github.com/puppetlabs/puppetlabs-mysql' }
  ```

* `enc_classes` - Hash of classes from our downloaded content that should be
  applied using External Node Classifers. The key of this hash is the name of
  a class to apply and the value is a hash of parameters that should be set
  for that class.

  ```puppet
  enc_classes => {'mysql' => {'config_hash' => {'bind_address' => '0.0.0.0' }}}
  ```

* `manifest` - A string to pass in as a local manifest file and applied during
  the bootstrap process. See the example manifest files in `tests/*.pp`
  for examples on specifying full manifests.
* `block_for_startup_script` - Whether the resource should block until its
  startup sctipt has completed.
* `startup_script_timeout` - Amount of time to wait before timing out when
  blocking for a startup script.

### Puppet Master and Service specification

The solution allows specification of a puppet master instance with the
`gce_instance` parameter:

* `puppet_master` - Hostname of the puppet master instance that the
  agent instance must be able to resolve.

  ```puppet
  puppet_master => 'puppet'
  ```

If this parameter is specified, then it is used as the `server` parameter in
`puppet.conf`. If unspecified, the default of `puppet` is used.
This parameter may be explicitly set to an empty string for a masterless instance.

The solution allows specification of whether to start the puppet agent service
with the `gce_instance` parameter:

* `puppet_service` - `absent` or `present` (default `absent`)

  ```puppet
  puppet_service => present
  ```

If this parameter is specified, then the puppet service is automatically started
on the managed instance and set to restart on boot (in `/etc/default/puppet`).

### Puppet Enterprise

If you choose `startupscript => 'puppet-enterprise.sh'`, you can provide data needed for the [PE installer answer file](http://docs.puppetlabs.com/pe/latest/install_answer_file_reference.html) in the `metadata` parameter.
The following example specifies the PE version and PE Console login details.

```puppet
   metadata             => {
	   'pe_role'          => 'master',
	   'pe_version'       => '3.1.0',
	   'pe_consoleadmin'  => 'admin@example.com',
	   'pe_consolepwd'    => 'puppetize',
   },
```
This example will provision a PE Agent and will point it to your PE master.
```puppet
   metadata             => {
      'pe_role'          => 'agent',
      'pe_master'        => "[gce_instance_namevar].c.[gce_projectid].internal",
      'pe_version'       => '3.1.0',
   },
```

### Implementation of classification

In addition to creating instances with `gce_instance`, you may pass additional parameters to configure and classify the instance. The work is done during instance creation by a bootstrap script. The module includes a script to configure open source Puppet and another script for Puppet Enterprise.

In the `gce_instance` resource, you may provide the following parameter to choose a startup script. You can use any executable script that's located in the gce_compute modules files directory and can be interpreted by the OS GCE provisisions.

```puppet
   startupscript => 'script_to_use.sh'
   startupscript => 'puppet-community.sh'
   startupscript => 'puppet-enterprise.sh'
```

You can pass additional parameters to `gce_instance` resources to influence the behavior of these startup scripts. Both included scripts are capable of installing Puppet, classifying into a Dashboard/Console ENC, and installing modules. See the `gce_instance` reference (above) for more details.

Common Parameters.

* `puppet_modules`  - set when the `modules` attribute is specified.
* `puppet_classes`  - set when the ENC classes attribute is specified.
* `puppet_manifest` - set when the `manifest` attribute is specified.
* `puppet_repos`    - set when the `module_repos` attribute is specified.
* `puppet_master`   - set when the `puppet_master` attribute is specified.
* `puppet_service`  - set when the `puppet_service` attribute is specified.

### Data Lookups

The solution implements the ability to look up internal and external IP
addresses for the classification of instances.

In order to retrieve the external or internal IP address of a different
instance, the following syntax can be used from the classes parameter:

```puppet
    Gce_instance[database][internal_ip_address]
```

This is interpreted by the resource to mean it should retrieve the value of
the `internal_ip_address` property from the database resource of
`Gce_instance`. This syntax only supports retrieving `external_ip_address`
and `internal_ip_address` from `Gce_instance` resources that are applied as
part of the same catalog.

It is also possible to lookup an instances of our own `$internal_ip_address`
or `$external_ip_address`. This value is retrieved from the bootstrap script.

### Destroy GCE Resources

To use the example above, the following manifest could be used to teardown
the environment. Not all parameters need be supplied when removing
resources. Recall that persistent disks are not destroyed when an instance
is destroyed but must be done so explicitly as in the following example:

```puppet
    # manifests/site.pp
    gce_disk { 'puppet-disk':
        ensure      => absent,
        zone        => 'us-central1-a',
    }
    gce_disk { 'www1':
        ensure      => absent,
        zone        => 'us-central1-a',
    }
    gce_disk { 'www2':
        ensure      => absent,
        zone        => 'us-central1-b',
    }
    gce_firewall { 'allow-http':
        ensure      => absent,
    }
    gce_instance { 'www1':
        ensure       => absent,
        zone         => 'us-central1-a',
    }
    gce_instance { 'www2':
        ensure       => absent,
        zone         => 'us-central1-b',
    }
    gce_httphealthcheck { 'basic-http':
        ensure       => absent,
    }
    gce_targetpool { 'www-pool':
        ensure       => absent,
        region       => 'us-central1',
    }
    gce_forwardingrule { 'www-rule':
        ensure       => absent,
        region       => 'us-central1',
    }

    Gce_instance["www1", "www2"] -> Gce_disk["www1", "www2", "puppet-disk"]
    Gce_forwardingrule["www-rule"] -> Gce_targetpool["www-pool"]
    Gce_targetpool["www-pool"] -> Gce_httphealthcheck["basic-http"]
```

##Limitations

It should work on any system that supports Google's [Cloud SDK](https://developers.google.com/cloud/sdk/#System_Requirements) but it has not been tested on Windows.

##Development

These are some condensed *raw* notes on how the module was developed and
tested. Mostly, it's the output of my `history` with a few annotations. I
spun up a GCE instance through the console, and the logged into it via `gcutil
ssh`.

```bash
    #// This block was done with a fresh 'wheezy' and the puppet version included
    #// in the distro's repo (e.g. puppet 2.7.18)
    $ sudo apt-get update && sudo apt-get upgrade -y
    $ sudo apt-get install git puppet -y
    $ git clone https://github.com/puppetlabs/puppetlabs-gce_compute.git
    $ puppet apply --configprint deviceconfig
    $ mkdir -p ~/.puppet/modules
    $ cat <<eof > ~/.puppet/device.conf
      [my_project]
         type gce
         url [/dev/null]:google.com:erjohnso
      eof
    $ ln -s ~/puppetlabs-gce_compute ~/.puppet/modules/
    $ puppet module list
      /home/erjohnso/.puppet/modules
      |___ puppetlabs-gce_compute (???)
    $ puppet apply --certname my_project puppetlabs-gce_compute/tests/up-pe3-wheezy.pp
      notice: /Stage[main]//Gce_instance[pe3-wheezy]/ensure: created
      notice: Finished catalog run in 21.30 seconds
    #// verify that mysql and apache are running, and the node is using puppet3
    $ gcutil ssh pe3-wheezy ' ps ax; puppet --version'
    $ puppet apply --certname my_project tests/down-pe3-wheezy.pp
```

###Testing
 * Debian-7 (wheezy) puppet debian package (v2.7.23 using ruby1.8.7)
   * Cloud SDK's gcutil version 1.12.0
 * Debian-7 (wheezy) puppet open-source (v3.3.2 using ruby1.9.3p194)
   * Cloud SDK's gcutil version 1.12.0
 * Debian-7 (wheezy) Puppet Enterprise v3.1.0 (v3.3.1 using ruby1.9.3p448)
   * Cloud SDK's gcutil version 1.12.0

Puppet Enterprise ships with `facter` and when run will attempt to read the
value from executing `dmidecode` which can only by done by `root` (or sudo).
If you run `puppet apply` as an unprivileged user, you will see permission
denied errors.

##ToDo

Not all GCE features have been implemented. Currently, the module is missing
support for:

* Routes
* Snapshots
