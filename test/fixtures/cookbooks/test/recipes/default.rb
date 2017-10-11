include_recipe "packman::default"

packer_builder 'azure_test' do
  options(
    'name' => 'azure_test',
    'type' => 'azure-arm',
    'ssh_username' => 'azure',
    'capture_container_name' => 'vhds',
    'capture_name_prefix' => 'application-directory',
    'client_id' => '0831b578-8ab6-40b9-a581-9a880a94aab1',
    'client_secret' => 'P@ssw0rd!',
    'subscription_id' => '1C2B75C1-74A5-472A-A729-7F8CEFC477F9',
    'resource_group_name' => 'myResourceGroup',
    'image_publisher'=> 'Canonical',
    'image_offer' => 'UbuntuServer',
    'image_sku' => '14.04.5-LTS',
    'storage_account' => 'myimages',
    'os_type' => 'Linux',
    'location' => 'East US',
    'vm_size' => 'Standard_A2'
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
  action        :create
  validate_only true
end
