require 'spec_helper'
 
 

provider_class = Puppet::Type.type(:gce_instance).provider(:fog)

# Default values provided by puppet for this type
defaults = {:disks => [], :startup_script_timeout => 420, :modules => [],
  :module_repos => '', :async_create => false, :async_destroy => false}

describe provider_class do

  context '#get_project_ssh_keys' do
    # Reset project_ssh_keys class instance variable for each test
    before(:each) do
      provider_class.instance_variable_set(:@project_ssh_keys, nil)
    end

    it 'returns common project ssh keys from fog' do
      project_name = 'test-project-9000'
      ssh_key ='username:ssh-rsa sshkeymagicstuff/goeshere ' \
        'username@some.host.name.com'
      fog = stub('fog')
      project = stub('project')
      project_data = double('project_data')
      project_data_hash = {'items' => [{'key' => 'foo', 'value' => 'bar'},
        {'key' => 'sshKeys', 'value' => ssh_key}], 'kind' => 'compute#metadata'}
          
      expect(fog).to receive(:projects).and_return(project)
      expect(fog).to receive(:project).and_return(project_name)
      expect(project).to receive(:get).and_return(project_data)
      expect(project_data).to receive(:common_instance_metadata).twice.and_return(
        project_data_hash)

      provider_class.superclass.class_variable_set(:@@connection, fog)
      expect(provider_class.get_project_ssh_keys).to eq ssh_key
    end

    it 'returns an empty string if there are no project ssh keys' do
      project_name = 'test-project-9000'
      fog = stub('fog')
      project = stub('project')
      project_data = double('project_data')
      project_data_hash = {'items' => [{'key' => 'foo', 'value' => 'bar'}],
        'kind' => 'compute#metadata'}
          
      expect(fog).to receive(:projects).and_return(project)
      expect(fog).to receive(:project).and_return(project_name)
      expect(project).to receive(:get).and_return(project_data)
      expect(project_data).to receive(:common_instance_metadata).twice.and_return(
        project_data_hash)

      provider_class.superclass.class_variable_set(:@@connection, fog)
      expect(provider_class.get_project_ssh_keys).to eq ''
    end

    it 'caches project ssh keys even if no keys are found' do
      project_name = 'test-project-9000'
      fog = stub('fog')
      project = stub('project')
      project_data = double('project_data')
      project_data_hash = {'items' => [{'key' => 'foo', 'value' => 'bar'}],
        'kind' => 'compute#metadata'}
          
      expect(fog).to receive(:projects).once.and_return(project)
      expect(fog).to receive(:project).once.and_return(project_name)
      expect(project).to receive(:get).once.and_return(project_data)
      expect(project_data).to receive(:common_instance_metadata).twice.and_return(
        project_data_hash)

      provider_class.superclass.class_variable_set(:@@connection, fog)
      expect(provider_class.project_ssh_keys).to eq ''
      expect(provider_class.project_ssh_keys).to eq ''
    end

    it 'caches project ssh keys' do
      project_name = 'test-project-9000'
      ssh_key ='username:ssh-rsa sshkeymagicstuff/goeshere ' \
        'username@some.host.name.com'
      fog = stub('fog')
      project = stub('project')
      project_data = double('project_data')
      project_data_hash = {'items' => [{'key' => 'foo', 'value' => 'bar'},
        {'key' => 'sshKeys', 'value' => ssh_key}], 'kind' => 'compute#metadata'}
          
      expect(fog).to receive(:projects).once.and_return(project)
      expect(fog).to receive(:project).once.and_return(project_name)
      expect(project).to receive(:get).once.and_return(project_data)
      expect(project_data).to receive(:common_instance_metadata).twice.and_return(
        project_data_hash)

      provider_class.superclass.class_variable_set(:@@connection, fog)
      expect(provider_class.project_ssh_keys).to eq ssh_key
      expect(provider_class.project_ssh_keys).to eq ssh_key
    end
  end

  context '#init_create' do
    let(:provider) { provider_class.new({:name => 'test-instance'})}

    before(:all) do
      provider_class.instance_variable_set(:@project_ssh_keys, nil)
      provider_class.superclass.class_variable_set(:@@resource_cache,
                                  {:gce_disk => {'test-disk-1' => 'test-disk-1',
                                    'test-disk-2' => 'test-disk-2'}})
    end

    it 'merges disk and disks' do
      # Not checking ssh keys so make it '' here to avoid retrieving them
      provider_class.instance_variable_set(:@project_ssh_keys, '')
      provider.resource = defaults.merge({:disk => 'test-disk-1',
                                         :disks => ['test-disk-2']})
      provider.init_create
      # Array order doesn't matter, no boot disk specified
      expect(provider.resource[:disks]).to match_array ['test-disk-1',
                                                       'test-disk-2']
    end

    
    it 'merges disk and disks with the boot disk first when boot disk is ' \
      'in disk' do
      # Not checking ssh keys so make it '' here to avoid retrieving them
      provider_class.instance_variable_set(:@project_ssh_keys, '')
      provider.resource = defaults.merge({:disk => 'test-disk-1,boot',
                                         :disks => ['test-disk-2']})
      provider.init_create
      expect(provider.resource[:disks]).to eq ['test-disk-1', 'test-disk-2']
    end

    it 'merges disk and disks with the boot disk first when boot disk is ' \
      'in disks' do
      # Not checking ssh keys so make it '' here to avoid retrieving them
      provider_class.instance_variable_set(:@project_ssh_keys, '')
      provider.resource = defaults.merge({:disk => 'test-disk-1',
                                         :disks => ['test-disk-2,boot']})
      provider.init_create
      expect(provider.resource[:disks]).to eq ['test-disk-2', 'test-disk-1']
    end

    it 'strips whitespace from disk / boot string' do
      # Not checking ssh keys so make it '' here to avoid retrieving them
      provider_class.instance_variable_set(:@project_ssh_keys, '')
      provider.resource = defaults.merge({:disk => 'test-disk-1',
                                         :disks => ['test-disk-2, boot']})
      provider.init_create
      expect(provider.resource[:disks]).to eq ['test-disk-2', 'test-disk-1']
    end

    it 'correctly merges disk and disks when disks == []' do
      # Not checking ssh keys so make it '' here to avoid retrieving them
      provider_class.instance_variable_set(:@project_ssh_keys, '')
      provider.resource = defaults.merge({:disk => 'test-disk-1,boot'})
      provider.init_create
      expect(provider.resource[:disks]).to eq ['test-disk-1']
    end

    it 'correctly merges disk and disks when disk == nil' do
      # Not checking ssh keys so make it '' here to avoid retrieving them
      provider_class.instance_variable_set(:@project_ssh_keys, '')
      provider.resource = defaults.merge({:disk => nil,
                                         :disks => ['test-disk-1,boot']})
      provider.init_create
      expect(provider.resource[:disks]).to eq ['test-disk-1']
    end

    it 'raises an error if a disk is not found in the cache' do
      # Not checking ssh keys so make it '' here to avoid retrieving them
      provider_class.instance_variable_set(:@project_ssh_keys, '')
      provider.resource = defaults.merge({:disks => ['mary,boot']})
      expect {provider.init_create}.to raise_error(Puppet::Error,
                                                /Unable to find disk with name/)
    end

    it 'ignores project ssh keys when authorized_ssh_keys is set' do
      ssh_user = 'user1'
      ssh_key ='ssh-rsa sshkeymagicstuff/goeshere ' \
        'username@some.host.name.com'
      provider_class.instance_variable_set(:@project_ssh_keys,
                                           'username:ssh-rsa sshstuff/here ' \
                                           'user2@some.host.name.com')
      provider.resource = defaults.merge({:authorized_ssh_keys => {ssh_user => ssh_key}})
      provider.init_create
      expect(provider.resource[:metadata][:sshKeys]).to eq \
        "#{ssh_user}:#{ssh_key}"
    end

    it 'adds project ssh keys when present and no authorized ssh keys given' do
      ssh_auth = 'username:ssh-rsa sshstuff/here user2@some.host.name.com'
      provider_class.instance_variable_set(:@project_ssh_keys, ssh_auth)
      provider.resource = defaults
      provider.init_create
      expect(provider.resource[:metadata][:sshKeys]).to eq ssh_auth
    end

    it 'correctly concatenates multiple authorized ssh keys' do
      ssh_user = 'user1'
      ssh_user3 = 'user4'
      ssh_key ='ssh-rsa sshkeymagicstuff/goeshere ' \
        'username@some.host.name.com'
      ssh_key3 ='ssh-rsa moresshkeymagicstuff/goeshere ' \
        'username@some.host.name.com'
      provider_class.instance_variable_set(:@project_ssh_keys,
                                           'username:ssh-rsa sshstuff/here ' \
                                           'user2@some.host.name.com')
      provider.resource = defaults.merge({:authorized_ssh_keys => {ssh_user => ssh_key,
                                         ssh_user3 => ssh_key3}})
      provider.init_create
      expect(provider.resource[:metadata][:sshKeys]).to eq \
        "#{ssh_user}:#{ssh_key}\n#{ssh_user3}:#{ssh_key3}"
    end

    it 'ignores puppet startup scripts if a different file is given' do
      # Not checking ssh keys so make it '' here to avoid retrieving them
      provider_class.instance_variable_set(:@project_ssh_keys, '')
      script = File.open(File.expand_path(File.join(File.dirname(__FILE__),
                                                    '..', '..', 'files',
                                                    'puppet-enterprise.sh')),
                         'r').read
      provider.resource = defaults.merge({:startupscript => 'puppet-enterprise.sh'})
      provider.init_create
      expect(provider.resource[:metadata]['startup-script']).to eq script
                                                        
                                                        
    end

    it 'uses the default startup script if no script is specified' do
      # Not checking ssh keys so make it '' here to avoid retrieving them
      provider_class.instance_variable_set(:@project_ssh_keys, '')
      script = File.open(File.expand_path(File.join(File.dirname(__FILE__),
                                                    '..', '..', 'files',
                                                    'puppet-community.sh')),
                         'r').read
      provider.resource = defaults.merge({:puppet_master => 'master.c.test-project-9000.internal'})
      provider.init_create
      expect(provider.resource[:metadata]['startup-script']).to eq script
    end

    it 'correctly sets puppet master in metadata hash when puppet master is '\
      'specified' do
      # Not checking ssh keys so make it '' here to avoid retrieving them
      provider_class.instance_variable_set(:@project_ssh_keys, '')
      provider.resource = defaults.merge({:puppet_master => 'master.c.test-project-9000.internal'})
      provider.init_create
      expect(provider.resource[:metadata][:puppet_master]).to eq \
        'master.c.test-project-9000.internal'
    end

    it 'correctly sets puppet master in metadata hash when puppet master is '\
      'not specified' do
      # Not checking ssh keys so make it '' here to avoid retrieving them
      provider_class.instance_variable_set(:@project_ssh_keys, '')
      provider.resource = defaults
      provider.init_create
      expect(provider.resource[:metadata][:puppet_master]).to eq :puppet
    end

    it 'correctly sets puppet service to present in metadata' do
      # Not checking ssh keys so make it '' here to avoid retrieving them
      provider_class.instance_variable_set(:@project_ssh_keys, '')
      provider.resource = defaults.merge({:puppet_service => 'present'})
      provider.init_create
      expect(provider.resource[:metadata][:puppet_service]).to eq 'present'
    end

    it 'correctly sets puppet service to absent in metadata' do
      # Not checking ssh keys so make it '' here to avoid retrieving them
      provider_class.instance_variable_set(:@project_ssh_keys, '')
      provider.resource = defaults.merge({:puppet_service => 'absent'})
      provider.init_create
      expect(provider.resource[:metadata][:puppet_service]).to eq 'absent'
    end
  end

end
