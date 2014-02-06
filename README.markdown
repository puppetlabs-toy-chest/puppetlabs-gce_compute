#Puppet for Google Compute Engine

####Table of Contents

1. [Overview](#overview)
2. [Module Description - What the module does and why it is useful](#module-description)
3. [Setup - The basics of getting started with gce_compute](#setup)
    * [What [gce_compute] affects](#what-gce_compute-affects)
    * [Setup requirements](#setup-requirements)
    * [Beginning with gce_compute](#beginning-with-gce_compute)
4. [Usage - Configuration options and additional functionality](#usage)
5. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
5. [Limitations - OS compatibility, etc.](#limitations)
6. [Development - Guide for contributing to the module](#development)

##Overview

The gce_compute module provides everything you need to manage compute instances, disk storage and network interfaces in Google Compute Engine in Puppet's declarative DSL. It will even provision and configure Puppet Enterprise or Puppet Open Source during instance creation.

It should work on any system that supports Google's [Cloud SDK](https://developers.google.com/cloud/sdk/#System_Requirements) but it has not been tested on Windows.

##Module Description

The gce_compute module provides the following resource types:

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

	
###Beginning with gce_compute	

One of the easiest ways to take advantage of this module is to build a single instance in Google Compute Engine to serve as your Puppet Enterprise master and console. After going through the [setup](#setup), save the following resource to a file (like gce.pp) and run `puppet apply gce.pp`. 

```puppet
gce_instance { 'pe-master':
    ensure       => present,
    description  => 'A Puppet Enterprise Master and Console',
    machine_type => 'n1-standard-1',
    zone         => 'us-central1-a',
    network      => 'default',
    image        => 'projects/centos-cloud/global/images/centos-6-v20131120',
    tags         => ['puppet', 'master'],
    startupscript        => 'puppet-enterprise.sh',
	  metadata             => {
	    'pe_role'          => 'master',
	    'pe_version'       => '3.1.0',
	    'pe_consoleadmin'  => 'admin@example.com',
	    'pe_consolepwd'    => 'puppetize',
	  },
}
```




##Usage

Now create a Puppet manifest that describes the google compute resources that
you wish to manage. The example below creates a 2GB persistent disk, two
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
    gce_instance { 'www1':
        ensure       => present,
        description  => 'web server',
        disk         => 'puppet-disk',
        machine_type => 'n1-standard-1',
        zone         => 'us-central1-a',
        puppet_master => 'master-blaster',
        puppet_service => present,
        on_host_maintenance => 'migrate',
        network      => 'default',
        image        => 'projects/debian-cloud/global/images/debian-7-wheezy-v20131120',
        tags         => ['web'],
        manifest     => 'class apache ($version = "latest") {
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
        include apache',
    }
    gce_instance { 'www2':
        ensure       => present,
        description  => 'web server',
        machine_type => 'n1-standard-1',
        zone         => 'us-central1-b',
        puppet_master => 'master-blaster',
        puppet_service => present,
        on_host_maintenance => 'migrate',
        network      => 'default',
        image        => 'projects/debian-cloud/global/images/debian-7-wheezy-v20131120',
        tags         => ['web'],
        manifest     => 'class apache ($version = "latest") {
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
        include apache',
    }
    gce_httphealthcheck { 'basic-http':
        ensure       => present,
        require      => Gce_instance['www1', 'www2'],
        description  => 'basic http health check',
    }
    gce_targetpool { 'www-pool':
        ensure       => present,
        require      => Gce_httphealthcheck['basic-http'],
        health_checks => 'basic-http',
        instances    => 'us-central1-a/www1,us-central1-b/www2',
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

Run `puppet apply` on this manifest

    puppet apply --certname certname1 manifests/site.pp

and wait for your GCE resources to be provisioned. The above example
can be found in `tests/all-up.pp` along with the script to destroy the
environment in `tests/all-down.pp`.

##Reference

#### Service Account Scopes

Note that if your GCE instances will need access to other Google Cloud
services (e.g.
[Google Cloud Storage](https://cloud.google.com/products/cloud-storage),
[Google BigQuery](https://cloud.google.com/products/big-query), etc.) then you
can specify access with the `--service_account_scopes`. For more information
about Service Account scopes, see
[this page](https://developers.google.com/compute/docs/authentication).

#### Persistent Disks and Instances

When an instance is created, the module will first check to see if there is a
pre-existing persistent disk with the same name as the instance and attempt to
use that as the instance's boot disk. If no such disk exists, a new persistent
disk will be created.

When you delete an instance, the persistent disk will *not* be deleted. This
provides the default behavior of persisting your data between instance
termination and re-creation. If you truly want to delete a persistent disk,
you must do so explicitly with it's own type-block and ensure=absent attribute.

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

Classification is specified with the following gce_instance parameters:

* modules - List of modules that should be installed from the
  [forge](http://forge.puppetlabs.com/).

  ```modules => ['puppetlabs-mysql', 'puppetlabs-apache']```

* module_repos - Modules that should be installed from github. Accepts a hash
  where the keys indicates the directory where the module should be installed and the value points to the GitHub repo.

 ``` module_repos => { 'mysql' => 'git://github.com/puppetlabs/puppetlabs-mysql' }```

* enc_classes - Hash of classes from our downloaded content that should be
  applied using External Node Classifers. The key of this hash is the name of
  a class to apply and the value is a hash of parameters that should be set
  for that class.

  ```enc_classes => {'mysql' => {'config_hash' => {'bind_address' => '0.0.0.0' }}}```

* manifest - A string to pass in as a local manifest file and applied during
  the bootstrap process. See the example manifest files in `tests/*.pp`
  for examples on specifying full manifests.
* block_for_startup_script - Whether the resource should block until its
  startup sctipt has completed.
* startup_script_timeout - Amount of time to wait before timing out when
  blocking for a startup script.

### Puppet Master and Service specification

The solution allows specification of a puppet master instance with the
gce_instance parameter:

* puppet_master - Hostname of the puppet master instance that the
  agent instance must be able to resolve.

  ```puppet_master => 'puppet'```

If this parameter is specified, then it is used as the `server` parameter in
`puppet.conf`. If unspecified, the default of `puppet` is used.
This parameter may be explicitly set to an empty string for a masterless instance.

The solution allows specification of whether to start the puppet agent service
with the gce_instance parameter:

* puppet_service - `absent` or `present` (default `absent`)

  ```puppet_service => present```

If this parameter is specified, then the puppet service is automatically started
on the managed instance and set to restart on boot (in `/etc/default/puppet`).

### Puppet Enterprise

If you choose `startupscript => 'puppet-enterprise.sh'`, you can provide data needed for the [PE installer answer file](http://docs.puppetlabs.com/pe/latest/install_answer_file_reference.html) in the `metadata` parameter. 
The following example specifies the PE version and PE Console login details.

   metadata             => {
	   'pe_role'          => 'master',
	   'pe_version'       => '3.1.0',
	   'pe_consoleadmin'  => 'admin@example.com',
	   'pe_consolepwd'    => 'puppetize',
   },
   
   This example will provision a PE Agent and will point it to your PE master.
   
   metadata             => {
      'pe_role'          => 'agent',
      'pe_master'        => "[gce_instance_namevar].c.[gce_projectid].internal",
      'pe_version'       => '3.1.0',
   },

### Implementation of classification

In addition to creating instances with `gce_instance`, you may pass additional parameters to configure and classify the instance. The work is done during instance creation by a bootstrap script. The module includes a script to configure open source Puppet and another script for Puppet Enterprise.

In the gce_instance resource, you may provide the following parameter to choose a startup script. You can use any executable script that's located in the gce_compute modules files directory and can be interpreted by the OS GCE provisisions. 

   startupscript => 'script_to_use.sh'
   startupscript => 'puppet-community.sh'
   startupscript => 'puppet-enterprise.sh'
   
You can pass additional parameters to `gce_instance` resources to influence the behavior of these startup scripts. Both included scripts are capable of installing Puppet, classifying into a Dashboard/Console ENC, and installing modules. See the `gce_instance` reference (above) for more details.

Common Parameters.

* puppet\_modules  - set when the modules attribute is specified.
* puppet\_classes  - set when the ENC classes attribute is specified.
* puppet\_manifest - set when the manifest attribute is specified.
* puppet\_repos    - set when the module\_repos attribute is specified.
* puppet\_master   - set when the puppet\_master attribute is specified.
* puppet\_service  - set when the puppet\_service attribute is specified.

### Data Lookups

The solution implements the ability to look up internal and external IP
addresses for the classification of instances.

In order to retrieve the external or internal IP address of a different
instance, the following syntax can be used from the classes parameter:

    Gce_instance[database][internal_ip_address]

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

##Limitations

It should work on any system that supports Google's [Cloud SDK](https://developers.google.com/cloud/sdk/#System_Requirements) but it has not been tested on Windows.

##Development

These are some condensed *raw* notes on how the module was developed and
tested. Mostly, it's the output of my `history` with a few annotations. I
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
 
    Testing   
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
