remote_file node['packman']['zipfile']['path'] do
  source node['packman']['zipfile']['href']
  checksum node['packman']['zipfile']['checksum']
end

package 'unzip'

execute "unzip #{node['packman']['zipfile']['path']} -d #{node['packman']['bin_dir']}" do
  creates node['packman']['binary_path']
end

remote_file node['packman']['azure']['binary_path'] do
  mode '0755'
  source node['packman']['azure']['href']
  checksum node['packman']['azure']['checksum']
end
