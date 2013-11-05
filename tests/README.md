# Sample Manifests

These are a few sample manifests to create Google Compute Engine resources
and also tear them down again.

* up-pe3-wheezy.pp - Spin up a new GCE instance and install a few puppet
  modules.  To verify that the test was completely successful, SSH into
  the new machine and verify that the puppet modules were successfully
  installed.

  ```
  $ gcutil ssh pe3-wheezy --zone=us-central1-a
  $ sudo puppet module list
  /etc/puppet/modules
  |--- puppetlabs-apache (v0.9.0)
  |--- puppetlabs-mysql (v2.0.1)
  |--- puppetlabs-stdlib (v4.1.0)
  +--- puppetlabs-concat (v0.2.0)
  $ sudo cat /etc/puppet/nodes/*.yaml
  --- 
    classes: 
      "mysql::server": 
        config_hash: 
          bind_address: "127.0.0.1"
      apache: 
      "mysql::python": 
  ```
* down-pe3-wheezy.pp - This will delete the test instance.

* all-up.pp - This manifest will create a couple of GCE instances, persistent
  disk, a firewall rule to allow TCP port 80 traffic, and create a load
  balancer.  Apache will be installed on the GCE instances along with a custom
  index.html page.  You can verify that this has worked by looking up the
  assigned load-balancer IP address by checking the forwarding rule in the
  Google Cloud Console.  A quick test with `curl` should show that the
  test completed.  You should see both public IP's for your GCE instances.

  ```
  $ while true; do curl -s http://FORWARDING_RULE_IP; sleep .5; done
  <html>
  <body>
        <h2>Hi, this is 108.59.85.116.</h2>
  </body>
  </html>
  <html>
  <body>
        <h2>Hi, this is 108.59.85.116.</h2>
  </body>
  </html>
  <html>
  <body>
        <h2>Hi, this is 108.59.86.227.</h2>
  </body>
  </html>
  ...
  ```

* all-down.pp - This manifest will destroy all GCE resources created with
  the `all-up.pp` manifest file.

