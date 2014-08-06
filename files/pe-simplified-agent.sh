#!/bin/bash
# this script can be used in combination with the gce types to install
# puppet and classify the provisioned instances

RESULTS_FILE='/tmp/puppet_bootstrap_output'

function check_exit_status() {
  if [ ! -f $RESULTS_FILE ]; then
    echo '1' > $RESULTS_FILE
  fi
}

trap check_exit_status INT TERM EXIT

MD="http://metadata/computeMetadata/v1/instance"
PUPPET_PE_MASTER=$(curl -fs -H "Metadata-Flavor: Google" $MD/attributes/pe_master)

curl -k https://$PUPPET_PE_MASTER:8140/packages/current/install.bash | bash

echo $? > $RESULTS_FILE
echo "Puppet installation finished!"
exit 0
