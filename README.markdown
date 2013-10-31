# Puppet Google Compute Resources

## Overview

This module contains native types that can be used to manage the creation
and destruction of objects in Google Compute Engine
[GCE](http://cloud.google.com/products/compute-engine.html) as Puppet
Resources.

It provides the following resource types:
* gce_instance - Virtual machine instances that can be assigned roles.
* gce_disk     - Persistent disks that can be attached to instances.
* gce_firewall - Firewall rules that specify the traffic to your instances.
* gce_network  - Networks that routes internal traffic between virtual machine
  instances. Firewalls and instances are associated with networks.
* gce_forwardingrule  - Load balancer forwarding rules.
* gce_httphealthcheck  - Load balancer HTTP health checking.
* gce_targetpool  - Load balancer collection of instances.
* gce_targetpoolhealthcheck  - Assignment of a health-check to a targetpool.
* gce_targetpoolinstance  - Assignment of an instance to a targetpool.

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

## Usage

### Configure gcutil

In order to use these resources, you will need to
[signup](https://developers.google.com/compute/docs/signup)
 for a Google Compute account.

You will also need to designate one machine to be your Puppet Device Agent.
This machine will be responsible for provisioning objects into Google Compute
using its `gcutil` command-line utility and will be used to store your
credentials for Google Compute Engine.

On your Puppet Device Agent, [install and
authenticate gcutil](https://developers.google.com/compute/docs/gcutil_setup).
Note that this module was last updated to use gcutil-1.10.0 which uses the
v1beta16 version of GCE's public API.

The authentication process should generate this credential file:
`~/.gcutil_auth`.

Next, create your `device.conf` file on the Agent.  The default location for
this file can be discovered by running the command (typically
`/etc/puppet/device.conf`):

    puppet apply --configprint deviceconfig

The `device.conf` file is used to map multiple certificate names to Google
Compute projects.

Each section header in this file is the name of the certificate that is
associated with a specified set of credentials and project identifier.
The element type should be set to 'gce' and the url should contain both the
path to the credentials file appended to the name of the project in the format
below.  If your Agent is itself running on a Google Compute Engine instance,
you can specify `/dev/null` as your credential_file.

    #/etc/puppet/device.conf
    [my_project1]
      type gce
      url [credential_file]:project_id

The example below show how multiple certificate names can be used to represent
multiple projects in GCE.

    #/etc/puppet/device.conf
    [certname1]
      type gce
      url [~/.gcutil_auth]:group:my_project1
    [certname2]
      type gce
      url [~/.gcutil_auth]:group:my_project2

### Creating GCE Resources

Now create a Puppet manifest that describes the google compute resources that
you wish to manage.  The example below creates a 2GB persistent disk, two
instances in different zones within the same region, a firewall rule on the
`default` network, and sets up load-balancing between the two instances.
Note the use of the Puppet `require` directive to ensure resource dependencies
have been created in the proper order.

    # manifests/site.pp
    gce_disk { 'puppet-disk':
        ensure      => present,
        description => 'small data disk',
        size_gb     => '2',
        zone        => 'us-central1-a',
    }
    gce_firewall { 'allow-http':
        ensure      => present,
        network     => 'default',
        description => 'allows incoming HTTP connections',
        allowed     => 'tcp:80',
    }
    gce_instance { 'www1-sd':
        ensure       => present,
        description  => 'web server',
        disk         => 'puppet-disk',
        machine_type => 'n1-standard-1',
        zone         => 'us-central1-a',
        network      => 'default',
        image        => 'projects/debian-cloud/global/images/debian-7-wheezy-v20130926',
        tags         => ['web']
        manifest      => 'class apache ($version = "latest") {
          package {"apache2":
            ensure => $version, # Using the class parameter from above
          }
          file {"/var/www/index.html":
            ensure  => present,
            content => "<html>\n<body>\n\t<h2>Hi, this is $gce_external_ip.</h2>\n</body>\n</html>\n",
            require => Package["apache2"],
          }
          service {"apache2":
            ensure => running,
            enable => true,
            require => File["/var/www/index.html"],
          }
        }
        include apache'
    }
    gce_instance { 'www2-pd':
        ensure       => present,
        description  => 'web server',
        machine_type => 'n1-standard-1',
        zone         => 'us-central1-b',
        network      => 'default',
        image        => 'projects/debian-cloud/global/images/debian-7-wheezy-v20130926',
        persistent_boot_disk => 'true',
        tags         => ['web']
        manifest      => 'class apache ($version = "latest") {
          package {"apache2":
            ensure => $version, # Using the class parameter from above
          }
          file {"/var/www/index.html":
            ensure  => present,
            content => "<html>\n<body>\n\t<h2>Hi, this is $gce_external_ip.</h2>\n</body>\n</html>\n",
            require => Package["apache2"],
          }
          service {"apache2":
            ensure => running,
            enable => true,
            require => File["/var/www/index.html"],
          }
        }
        include apache'
    }
    gce_httphealthcheck { 'basic-http':
        ensure       => present,
        require      => Gce_instance['www1-sd', 'www2-pd'],
        description  => 'basic http health check',
    }
    gce_targetpool { 'www-pool':
        ensure       => present,
        require      => Gce_httphealthcheck['basic-http'],
        health_checks => 'basic-http',
        instances    => 'us-central1-a/www1-sd,us-central1-b/www2-pd',
        region       => 'us-central1',
    }
    gce_forwardingrule { 'www-rule':
        ensure       => present,
        require      => Gce_targetpool['www-pool'],
        description  => 'Forward HTTP to web instances',
        port_range   => '80',
        region       => 'us-central1',
        target       => 'www-pool',
    }

Run puppet apply on this manifest

    puppet apply --certname certname1 manifests/site.pp

and wait for your GCE resources to be provisioned.  The above example
can be found in `tests/all-up.pp` along with the script to destroy the
environment in `tests/all-down.pp`.

#### Service Account Scopes

Note that if your GCE instances will need access to other Google Cloud
services (e.g.
[Google Cloud Storage](https://cloud.google.com/products/cloud-storage),
[Google BigQuery](https://cloud.google.com/products/big-query), etc.) then you
can specify access with the `--service_account_scopes`.  For more information
about Service Account scopes, see
[this page](https://developers.google.com/compute/docs/authentication).

#### Persistent Disks and Instances

By default, if you delete an instance that has a persistent boot disk, the
disk will *not* be deleted unless you explicitly delete it.  When you
create an instance, the module will first check to see if there is a
pre-existing persistent disk with the same name as the instance and attempt
to use that as the instances boot disk.

### Classifying resources

These resources support not only the ability to create virtual machine
instances as resources, but also the ability to use Puppet to classify those
instances.

The classification is currently only supported by running `puppet apply`
during the bootstrapping process of the created instances and can be done
with the `enc_classes` parameter that utilizes
[External Node Classifiers](http://docs.puppetlabs.com/guides/external_nodes.html)
or by passing in the contents of a manifest file with the `manifest` parameter.
If *both* parameters are specified, both will be applied to the instance with
ENC first followed by the manifest file.

Classification is specified with the following gce_instance parameters:

* modules - List of modules that should be installed from the
  [forge](http://forge.puppetlabs.com/).

  ```modules => ['puppetlabs-mysql', 'puppetlabs-apache']```

* module_repos - Modules that should be installed from github. Accepts a hash
  where the keys point to github repos and the value indicates the directory
  in `/etc/puppet` where the module will be installed.

 ``` module_repos => {'git://github.com/puppetlabs/puppetlabs-mysql' => 'mysql'}```

* enc_classes - Hash of classes from our downloaded content that should be
  applied using External Node Classifers. The key of this hash is the name of
  a class to apply and the value is a hash of parameters that should be set
  for that class.

  ```enc_classes => {'mysql' => {'config_hash' => {'bind_address' => '0.0.0.0' }}}```

* manifest - A string to pass in as a local manifest file and applied during
  the bootstrap process.  See the example manifest files in `tests/*.pp`
  for examples on specifying full manifests.
* block_for_startup_script - Whether the resource should block until its
  startup sctipt has completed.
* startup_script_timeout - Amount of time to wait before timing out when
  blocking for a startup script.

### Implementation of classification

Classification is implemented by using metaparameters to pass information to
created instances.

The following flag is used to pass the contents of the local file
`puppet-community.sh` as the startup-script metadata to our managed instance.
This metadata key is automatically downloaded from all google compute
instances and started as a part of the bootstrapping process. This flag is set
if module, module_repos, or classes are set.

    --metadata_from_file=startup-script:./files/puppet-community.sh

The script downloads the following metadata from the instance in order to
bootstrap it:
* puppet_modules  - set when the modules attribute is specified.
* puppet_classes  - set when the ENC classes attribute is specified.
* puppet_manifest - set when the manifest attribute is specified.
* puppet_repos    - set when the module_repos attribute is specified.

### Data Lookups

The solution implements the ability to look up internal and external IP
addresses for the classification of instances.

In order to retrieve the external or internal IP address of a different
instance, the following syntax can be used from the classes parameter:

    Gce_instance[database][internal_ip_address]

This is interpreted by the resource to mean it should retrieve the value of
the `internal_ip_address` property from the database resource of
`Gce_instance`.  This syntax only supports retrieving `external_ip_address`
and `internal_ip_address` from `Gce_instance` resources that are applied as
part of the same catalog.

It is also possible to lookup an instances of our own `$internal_ip_address`
or `$external_ip_address`.  This value is retrieved from the bootstrap script.

### Destroy GCE Resources

To use the example above, the following manifest could be used to teardown
the environment.  Not all parameters need be supplied when removing
resources.  Note that in the example, one of the instances, `www2-pd`,
was created with a `persistent_boot_disk`.  In the example below, we
ensure that this boot disk is also destroyed.

    # manifests/site.pp
    gce_disk { 'puppet-disk':
        ensure      => absent,
        zone        => 'us-central1-a',
    }
    gce_disk { 'www2-pd':
        ensure      => absent,
        zone        => 'us-central1-b',
    }
    gce_firewall { 'allow-http':
        ensure      => absent,
    }
    gce_instance { 'www1-sd':
        ensure       => absent,
        zone         => 'us-central1-a',
    }
    gce_instance { 'www2-pd':
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

    # tear them down in the proper order
    Gce_instance["www1-sd", "www2-pd"] -> Gce_disk["www2-pd", "puppet-disk"]
    Gce_forwardingrule["www-rule"] -> Gce_targetpool["www-pool"]
    Gce_targetpool["www-pool"] -> Gce_httphealthcheck["basic-http"]

### Examples

The examples above and others can be found in `tests/*.pp`.

### TODO

Not all GCE features have been implemented.  Currently, the module is missing
support for:

* Routes
* Snapshots

### Development

These are some condensed *raw* notes on how the module was developed and
tested.  Mostly, it's the output of my `history` with a few annotations.  I
spun up a GCE instance through the console, and the logged into it via `gcutil
ssh`.

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

## Testing

The following platforms and software versions were tested.  In all cases,
the sample manifests in the `tests` directory were used to verify full
functionality.

Note that when testing with various versions of `gcutil`, you simply need
to make sure the version you want to use resolves in your PATH over other
installed versions.

 * Debian-7 (wheezy) puppet package (v2.7.23 that uses ruby1.8.7)
   * gcutil 1.8.4 (v1beta15)
   * gcutil 1.10.0 (v1beta16)

