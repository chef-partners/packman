default['packman']['checksums'] = {
  '1.1.0' => 'bd1eddfa114f7e6258ef3419613380297f1b4e438f5bae92f1177150519be934'
}
default['packman']['version'] = '1.1.0'
default['packman']['bin_dir'] = '/usr/local/bin'
default['packman']['binary_path'] = ::File.join(node['packman']['bin_dir'], 'packer')

default['packman']['zipfile']['name'] = "packer_#{node['packman']['version']}_linux_amd64.zip"
default['packman']['zipfile']['checksum'] = node['packman']['checksums'][node['packman']['version']]
default['packman']['zipfile']['href'] =
  "https://releases.hashicorp.com/packer/#{node['packman']['version']}/#{node['packman']['zipfile']['name']}"
default['packman']['zipfile']['path'] =
  ::File.join(Chef::Config[:file_cache_path], node['packman']['zipfile']['name'])

# WIP: we shouldn't be using the azure plugin because it's deprecated in favor of packer's azure-arm builder:
# https://github.com/Azure/packer-azure
# default['packman']['azure']['checksum'] = '226d728bff9385fd5e0c5ff06ff4b06976d51bd9ed4724fe018c6a44d0818b41'
# default['packman']['azure']['href'] = 'https://s3.amazonaws.com/packer-builder-azure/packer-builder-azure'
# default['packman']['azure']['binary_path'] = ::File.join(node['packman']['bin_dir'], 'packer-builder-azure')
