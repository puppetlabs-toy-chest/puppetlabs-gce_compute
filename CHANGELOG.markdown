##2014-09-26 - Release 0.5.0

Version 0.5.0 adds the ability to autosign certificates in a trusted fashion, between a PE master and the Google Cloud Platform API. See the README for more details which was also improved in this version. 

##2014-05-27 - Release 0.4.0

This release adds new targetpool functionality, makes it easier to manage the project key, fixes a number of small bugs, and improves the documentation.

####Features
- Prefer user-specified boot disk if present.
- Add `add_compute_key_to_project` to manage SSH key.
- Add `region`, `session_affinity`, `backup_pool`, and `failover_ratio` for targetpool resources.

####Bugfixes
- Remove prep_master function from puppet-enterprise.sh.
- Fix instance blocking on startup script.
- Further fixes for GCE v1.
- Rewrite the README.
- Adds on_host_maintenance instructions.
- Hack around failure when metadata param absent.

####Known Bugs
* No known bugs

### 20131210 v0.3.0
 * Updated for GCE v1 (General Availability) and Cloud SDK
 * Remove tested support for older gcutil versions running against beta APIs
 * Matt Bookman contributions for puppet_master, puppet_service, on_host_maintenance

### 20131105 v0.2.0
 * Updated for gcutil-1.10.0 (v1beta16)
 * Fixes #18 submited by @jhoblitt
 * Fixes #17 v1beta16 with help from Matt Bookman

### 20130814 v0.1.0
 * Updated for gcutil-1.8.3 (v1beta15)
 * Added GCE Load-Balancer support
 * Added custom manifest support

### 20130513 v0.0.2
 * Updated for gcutil-1.7.2 (v1beta14)

### 20120920 v0.0.1
 * Initial release by @bodepd
