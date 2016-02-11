# Packer Manager Cookbook

The `packman` cookbook provide resources for building a packer template comprised
of one or many packer variables, builders, provisioners or post processors.  The
primary motivation behind this is support for dynamic provisioners.  If you're
managing several different images it can quickly become cumbersome to manage
all of the provisioner files and scripts.

An example recipe that uses the resources to build a single image on azure would
look something like

```ruby
packer_variable 'azure_publish_settings' do
  value '{{env `AZURE_PUBLISH_SETTINGS`}}'

  action :create
end

packer_builder 'azure_example' do
  options(
    'name' => 'azure_example',
    'type' => 'azure',
    'ssh_username' => 'azure',
    'publish_settings_path' =>  '{{user `azure_publish_settings`}}',
    'subscription_name' =>  'Example Subscription',
    'storage_account' =>  'myimages',
    'storage_account_container' =>  'vhds',
    'os_type' =>  'Linux',
    'os_image_label' => 'Ubuntu Server 14.04 LTS',
    'location' => 'East US',
    'instance_size' =>  'Large',
    'user_image_label' => "Packman_Example_{{timestamp}}"
  )

  action :create
end

packer_provisioner '/etc/my.cfg' do
  type 'file'
  source 'my.cfg.erb'
  destination '/etc/my.cfg'
  variables(
    something: 25,
    another_thing: 'fixed'
  )
  only %w(azure_example)

  action :create
end

packer_provisioner 'example_setup.sh' do
  type 'shell'
  source 'example_setup.sh.erb'

  action :create
end

packer_template 'azure-example' do
  action [:create, :run]
end
```

## Resources

### packer_template

The `packer_template` resource is responsible for building the packer JSON template
and running packer.  It will compose the template from data in the `node.run_state` that
is populated by the _preceeding_ packer resources.

Since it is uses previously defined packer resources it should be last in the `run_list`.

### packer_variable

`packer_variable` just create a key/value pair in the packer template.

```ruby
packer_variable 'foo' do
  value 'bar'
end
```

=>

```json
{
  "variables": {
    "foo": "bar"
  }
}
```

### packer_builder
`packer_builder` takes a hash of options that correspond to a packer builder.

```ruby
packer_builder 'azureExample' do
  options(
    'name' => name,
    'type' => 'azure',
    'ssh_username' => 'azure',
    'publish_settings_path' =>  '{{user `azure_publish_settings`}}',
    'subscription_name' =>  'Partner Engineering',
    'storage_account' =>  'ampimages',
    'storage_account_container' =>  'images',
    'os_type' =>  'Linux',
    'os_image_label' => 'Ubuntu Server 14.04 LTS',
    'location' => 'East US',
    'instance_size' =>  'Large',
    'user_image_label' => "Chef_AIO_Example_{{timestamp}}"
  )

  action :create
end
```

=>

```json
{
  "builders": [
  {
    "name": "azureExample",
    "type": "azure",
    "ssh_username": "azure",
    "publish_settings_path":  "{{user `azure_publish_settings`}}",
    "subscription_name":  "Partner Engineering",
    "storage_account":  "ampimages",
    "storage_account_container":  "images",
    "os_type":  "Linux",
    "os_image_label": "Ubuntu Server 14.04 LTS",
    "location": "East US",
    "instance_size":  "Large",
    "user_image_label": "Chef_AIO_Example_{{timestamp}}"
  }
  ]
}
```

### packer_provisioner
`packer_provisioner` is the resource that makes using chef as an abstraction worth
while.  It allows us to dynamically create provisioner resources so that we don't
have to maintain several versions of almost identical files.  We get to use templates!

I propose that we limit provisioner type support to `file` and `script` in the
beginning.  Each provisioner file/script that is rendered will use a system
temporary file and will be reaped after the `packer_template` resource has
finished running packer.

```ruby
packer_provisioner '/etc/chef-marketplace/marketplace.rb'
  type 'file'
  source 'marketplace.rb.erb'
  variables(
    license_count: 25,
    license_type: 'fixed'
  )
  only %w(azureExample)

  action :create
end
```

=>

```json
{
  "provisioners": [
  {
    "type": "file",
    "source": "/var/folders/x2/t63_5xr50dn5j32nwn0wjb2w0000gp/T/d20160208-5303-1xqdxzf/marketplace.rb",
    "destination": "/etc/marketplace.rb",
    "only": [ "azureExample" ]
  }
  ]
}
```

### packer_post_processor

We won't initially require any post processors as far as I know.  Theoretical
support would look something like:

```ruby
packer_post_processor 'compress' do
  options(
    'output' => 'archive.tar.lz4'
  )

  action :create
end
```

=>

```json
{
  "postprocessor": [
  {
    "type": "compress",
    "output": "archive.tar.lz4",
  }
  ]
}
```
