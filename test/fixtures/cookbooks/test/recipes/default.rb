packer_variable 'azure_publish_settings' do
  value '{{env `AZURE_PUBLISH_SETTINGS`}}'

  action :create
end

packer_builder 'azure_test' do
  options(
    'name' => 'azure_test',
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
    'user_image_label' => 'Azure_Test_{{timestamp}}'
  )

  action :create
end

packer_builder 'aws_test' do
  options(
    'type' => 'amazon-ebs',
    'access_key' => '2o38172387',
    'secret_key' => '243912731o2',
    'region' => 'us-east-1',
    'source_ami' => 'ami-356c465f',
    'instance_type' => 't2.large',
    'ssh_username' => 'ec2-user',
    'ami_name' => 'Aws_Test'
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

packer_provisioner '/tmp/testfile2' do
  type 'file'
  source 'testfile.erb'
  variables(
    eat: 'burritos',
    drink: 'beer',
    play: 'in_the_rain'
  )
  except %w(azure_test)

  action :create
end

packer_provisioner '/tmp/test_script.sh' do
  type 'shell'
  source 'test_script.sh.erb'
  variables message: 'all day'
  only %w(aws_test)

  action :create
end

packer_provisioner 'echo "errry day"' do
  type 'shell'
  inline true
  except %w(aws_test)

  action :create
end

packer_template 'packer' do
  action :create
end
