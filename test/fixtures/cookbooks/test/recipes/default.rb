packer_variable 'azure_publish_settings' do
  value '{{env `AZURE_PUBLISH_SETTINGS`}}'

  action :create
end

packer_builder 'azure_test' do
  options(
    'name' => 'test',
    'type' => 'azure',
    'ssh_username' => 'azure',
    'publish_settings_path' => '{{user `azure_publish_settings`}}',
    'subscription_name' => 'Example Subscription',
    'storage_account' => 'myimages',
    'storage_account_container' => 'vhds',
    'os_type' => 'Linux',
    'os_image_label' => 'Ubuntu Server 14.04 LTS',
    'location' => 'East US',
    'instance_size' => 'Large',
    'user_image_label' => 'Packman_Example_{{timestamp}}'
  )

  action :create
end

packer_provisioner '/tmp/testfile' do
  type 'file'
  source 'testfile.erb'
  variables(
    eat: 'veggies',
    drink: 'booch',
    play: 'music'
  )
  only %w(azure_test)

  action :create
end

packer_provisioner '/tmp/test_script.sh' do
  type 'shell'
  source 'test_script.sh.erb'
  variables message: 'all day'

  action :create
end

packer_template 'packer' do
  action :create
end
