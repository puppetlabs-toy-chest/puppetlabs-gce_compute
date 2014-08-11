#!/bin/bash
# this script can be used in combination with the gce types to install
# puppet and classify the provisioned instances

RESULTS_FILE='/tmp/puppet_bootstrap_output'
PUPPET_DIR='/etc/puppetlabs/puppet'

function check_exit_status() {
  if [ ! -f $RESULTS_FILE ]; then
    echo '1' > $RESULTS_FILE
  fi
}

trap check_exit_status INT TERM EXIT

if [ ! -d $PUPPET_DIR ]; then
   mkdir -p $PUPPET_DIR
fi

# Produce attributes for the csr based on instance metadata
MD="http://metadata/computeMetadata/v1/instance"
cat > $PUPPET_DIR/csr_attributes.yaml <<END
custom_attributes:
  pp_instance_id: $(curl -fs -H "Metadata-Flavor: Google" $MD/zone)
  1.3.6.1.4.1.34380.1.2.1: $(curl -fs -H "Metadata-Flavor: Google" $MD/attributes/puppet_instancename)
extension_requests:
  pp_uuid: $(curl -fs -H "Metadata-Flavor: Google" $MD/id)
END

chmod 600 $PUPPET_DIR/csr_attributes.yaml
chown pe-puppet.pe-puppet $PUPPET_DIR/csr_attributes.yaml

# Install the PE Agent via the PE Master's package-based installer
PUPPET_PE_MASTER=$(curl -fs -H "Metadata-Flavor: Google" $MD/attributes/pe_master)
curl -k https://$PUPPET_PE_MASTER:8140/packages/current/install.bash | bash
echo $? > $RESULTS_FILE

echo "Puppet installation finished!"
exit 0
