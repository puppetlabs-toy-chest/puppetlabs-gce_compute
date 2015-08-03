#Puppet for Google Compute Engine

##Table of Contents

1. [Overview](#overview)
1. [Setup](#setup)
1. [Quick Start with Puppet Enterprise](#quick-start-with-puppet-enterprise)
1. [Usage](#usage)
1. [Development](#development)
1. [Migrating from v0](#migrating-from-v0)

##Overview

The gce_compute module provides everything you need to manage compute instances, disk storage and network interfaces in Google Compute Engine in Puppet's declarative DSL. It will even provision and configure Puppet Enterprise or Puppet Open Source during instance creation.

It should work on any system that supports Google's [Cloud SDK](https://developers.google.com/cloud/sdk/#System_Requirements) but it has not been tested on Windows.

##Setup

In order to use this module, you will need to
[signup](https://developers.google.com/compute/docs/signup)
for a Google Cloud Platform account and enable Google Compute Engine.

### Setup a host with Google Cloud SDK

You will need to designate one machine to be your host.
This machine will be responsible for provisioning objects into Google Compute
using the `gcloud compute` command-line utility that is bundled as part of the Cloud
SDK.

You may either use a virtual machine inside of your Google Cloud project as your host, or you may use a machine outside of the project.

#### Setup a host inside of your Google Cloud project

If you would like to use a virtual machine inside of your project as your host, setup is simple.  Create the instance manually, either on the [Developers Console](https://console.developers.google.com/) or via the `gcloud` command-line interface, making sure to enable the `compute-rw` scope for your instance.

- In the Developers Console, create an instance via `Compute > Compute Engine > VM instances > New instance`, show the security options, and select "Read Write" under `Project Access > Compute`.
- In `gcloud`, just use `gcloud compute instances create` with the `--scopes compute-rw` flag.

Once you've setup your instance with the `compute-rw` scope, you don't need do anything else: `gcloud` comes preinstalled on the VM, and the instance is able to read and write resources within its project.

#### Setup a host outside of your Google Cloud project

If you would like to use a machine outside of your project as your host, you'll need to [install and authenticate gcloud](https://cloud.google.com/sdk/).

### Install Puppet and this module

You'll now want to [install Puppet](https://docs.puppetlabs.com/guides/install_puppet/pre_install.html) on your host.  Once you've installed Puppet, do

```bash
$ puppet module install puppetlabs-gce_compute
```

At this point, you should be ready to go!

## Quick Start with Puppet Enterprise

These instructions assume you have installed and configured the Google Cloud
SDK and Puppet from the previous step.

[Puppet Enterprise](http://puppetlabs.com/download-puppet-enterprise) is free to evaluate on up to 10 nodes and is installed for you as part of these examples.

### Bring up a GCE instance that will auto-install the PE Master

One of the easiest ways to take advantage of this module is to build a single
instance in Google Compute Engine to serve as your Puppet Enterprise master and
console. After going through the [setup](#setup), copy the the manifest in `examples/puppet_enterprise/up.pp`, to your host, and run

```bash
$ puppet apply up.pp
```

The install may take up to ten minutes but the master instance should be up
within a minute or two.  The manifest is configured to wait until all of the
startup scripts are finished running.

*As of right now, the `puppet-test-enterprise-agent-instance` doesn't properly
connect to the master.*

#### Use the future parser to build many more instances.

You can do something like this, in `agent.pp`:

```puppet
$a = ['1','2','3','4','5','6','7','8']
each( $a ) |$value|{

  gce_instance { "sample-agent-${value}":
    ensure                   => present,
    zone                     => 'us-central1-f',
    startup_script           => 'pe-simplified-agent.sh',
    block_for_startup_script => true,
    metadata                 => {
      'pe_role'    => 'agent',
      'pe_master'  => 'puppet-test-enterprise-master-instance',
      'pe_version' => '3.3.1',
    }
  }
```

```bash
$ puppet apply agent.pp --parser future
```

## Usage

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

### Service Account Scopes

Note that if your GCE instances will need access to other Google Cloud
services (e.g.
[Google Cloud Storage](https://cloud.google.com/products/cloud-storage),
[Google BigQuery](https://cloud.google.com/products/big-query), etc.) then you
can specify access with the `scopes` attribute. For more information
about Service Account scopes, see
[this page](https://developers.google.com/compute/docs/authentication).

The PE Quick Start example assigns the Master a compute-ro service scope which
allows it to query metadata about other instances within the GCE project. This
information is used for automatic certificate signing.

### Automatic Certificate Signing

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

- Within the host resources, assign the `pe-simplified-agent.sh` startup script.

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

### Enable/Disable Live Instance Migration

Your Compute Engine instances, by default, will enable live migration.  In
the event that Google needs to perform a datacenter maintenance, your instance
will be automatically migrated to a new location without visible impact.
This feature can be disabled by setting `maintenance_policy` to `TERMINATE`.

### Classifying resources

In addition to creating instances with `gce_instance`, you may pass additional parameters to configure and classify the instance. The work is done during instance creation by a bootstrap script. The module includes a scripts to configure both open source Puppet and Puppet Enterprise.

In the `gce_instance` resource, you may provide the following parameter to choose a startup script. You can use any executable script that's located in the gce_compute modules files directory and can be interpreted by the OS that GCE provisions.

```puppet
   startupscript => 'puppet-community.sh'
   startupscript => 'puppet-enterprise.sh'
   startupscript => 'script_to_use.sh'
```

The classification is currently only supported by running `puppet apply`
during the bootstrapping process of the created instances
by passing in the contents of a manifest file with the `manifest` parameter.

Classification is specified with the following `gce_instance` parameters:

* `puppet_master` - Hostname of the puppet master instance that the
  agent instance must be able to resolve. If this parameter is specified, then it is used as the `server` parameter in
`puppet.conf`.
* `puppet_service` - `absent` or `present`; if this parameter is specified, then the puppet service is automatically started
on the managed instance and set to restart on boot (in `/etc/default/puppet`).
* `puppet_manifest` - A string containing an inline manifest which is applied during
  the bootstrap process. _**Note**: this manifest cannot cannot contain the string "-zz-",
  as it is being used as a field delimiter for the underlying `--metadata` argument._
* `puppet_modules` - List of modules that should be installed from the
  [forge](http://forge.puppetlabs.com/).
* `puppet_module_repos` - Modules that should be installed from GitHub. Accepts a hash
  where the keys indicates the module directory where the module should be installed and the value points to the GitHub repo.

If you would like Puppet to wait until the startup script has completed running, you may use the
following parameters:

* `block_for_startup_script` - Whether the resource should block until its
  startup sctipt has completed.
* `startup_script_timeout` - Amount of time to wait before timing out when
  blocking for a startup script.

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

##Development

To setup a development environment, follow the [Setup](#setup) instructions above, up until

```bash
$ puppet module install puppetlabs-gce_compute
```

Instead, clone this repository, `cd` into the repository, then do

```bash
$ rake install
```

If you're going to be doing any kind of modifications, I highly recommend using [rbenv](https://github.com/sstephenson/rbenv), [ruby-build](https://github.com/sstephenson/ruby-build), (don't forget the [dependencies](https://github.com/sstephenson/ruby-build/wiki#suggested-build-environment)!) and [bundler](http://bundler.io/).

###Testing

This module has unit and live integration, (acceptance,) tests.  The whole test suite takes about 20 minutes, and can be run using
```bash
$ rake spec
```

Unit tests live in `spec/unit`, and include tests for types and providers, and can be run with
```bash
$ rake spec:unit
```

Live integration tests live in `spec/integration`, and will actually spin up and tear down live resources in your GCP environment.  Integration
tests can be run with
```bash
$ rake spec:integration
```

Integration tests use the system puppet and modules, so, in preparation for running, Rake will automatically install the current version
of the module.  If you would like to run an individual test file, you must reinstall the module manually, for example:
```bash
$ rake install && rspec spec/integration/puppet/puppet_community_spec.rb
```
If integration tests fail, they'll leave resources lying around in you project.  To cleanup, you can remove them altogether:
```bash
$ rake spec:integration:clean
```
or individually, for example:
```bash
$ rake install && puppet apply examples/puppet_community/down.pp
```

## Migrating from v0

In rewriting this module since v0, types have changed to be as consistent with `gcloud` as possible, which causes some breaking changes in the types.  Below are notes about what attributes have changed name, (and to what,) what attributes are no longer supported, and also the manifest syntax changes.

(This attempts to be a complete list, but may not be.  If you have questions, ask, or file a bug.)

### gce_disk

- `size_gb` is now `size`;
- `source_image` is now `image`; and
- `wait_until_complete` is no longer supported—all commands wait until they are complete.

### gce_firewallrule

This resource used to be called gce_firewall.

- `allowed` is now `allow`, and takes an array of strings rather than a comma-separated string;
- `allowed_ip_sources` is now `source_ranges`, and takes an array of strings rather than a comma-separated string; and
- `allowed_tag_sources` is now `source_tags`, and takes an array of strings rather than a comma-separated string.

### gce_forwardingrule

- `ip` is now `address`, and takes the name of an address resource;
- `protocol` is now `ip_protocol`; and
- `target` is now `target_pool`.

### gce_httphealthcheck

- `check_interval_sec` is now `check_interval`;
- `check_timeout_sec` is now `timeout`;

### gce_instance

- `authorized_ssh_keys` is no longer supported, (read more at [Connecting to an instance using ssh](https://cloud.google.com/compute/docs/instances/#sshing));
- `disk` is now `boot_disk`, and if no `boot_disk` is specified, a disk will be automatically provisioned, and will be set to auto-destroy when the instance is deleted;
- `external_ip_address` is now `address`, and takes the name of an address resource;
- `internal_ip_address` was read-only, and is no longer supported;
- `on_host_maintenance` is now `maintenance_policy`;
- `service_account` and `service_account_scopes` are now both reflected in `scopes`, and `scopes` takes an array of strings, (see `examples/gce_instance/up.pp` for an example);
- `add_compute_key_to_project` is no longer supported, (read more at [Connecting to an instance using ssh](https://cloud.google.com/compute/docs/instances/#sshing));
- `use_compute_key` is no longer supported, (read more at [Connecting to an instance using ssh](https://cloud.google.com/compute/docs/instances/#sshing));
- `enc_classes` is no longer supported;
- `manifest` is now `puppet_manifest`;
- `modules` is now `puppet_modules`, and the metadata is space-separated rather than comma-separated; and
- `module_repos` is now `puppet_module_repos`, is now stored in `puppet_module_repos` metadata, instead of `puppet_repos`, and that metadata is space-separated rather than comma-separated.

See `examples/puppet_community/up.pp` for an example of how to use the Puppet attributes: `puppet_master`, `puppet_service`, `puppet_manifest`, `puppet_modules`, and `puppet_module_repos`.

### gce_network

- `gateway` was read-only, and is no longer supported.

### gce_targetpool

- `health_checks` is now `health_check`.
- `instances` now takes a hash, of zones and lists of instances, (see `examples/gce_targetpool/up.pp` for an example).

### gce_targetpoolhealthcheck & gce_targetpoolinstance

Both of these types are now reflected in `gce_targetpool`, (see `examples/gce_targetpool/up.pp` for an example).
