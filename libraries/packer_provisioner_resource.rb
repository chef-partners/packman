#
# Author:: Partner Engineering <partnereng@chef.io>
# Copyright (c) 2016, Chef Software, Inc. <legal@chef.io>
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

class Chef
  class Resource
    class PackerProvisioner < Chef::Resource::LWRPBase
      resource_name :packer_provisioner

      actions :create
      default_action :create

      property :type, String
      property :override, Hash
      property :pause_before, String

      # Source template for upload or path for download
      property :source, String
      # Variables to pass the template
      property :variables, Hash
      # Template cookbook
      property :cookbook, String

      # Destination of file/script upload/download
      property :destination, String, name_property: true

      # Builder guards
      property :only, Array
      property :except, Array

      # shell
      property :binary, [true, false], default: false
      property :inline, [true, false], default: false
      property :inline_shebang, String
      property :environment_vars, [Hash, Array]
      property :execute_command, String
      property :start_retry_timeout, String
      property :skip_clean, String

      # local-shell
      property :command, String
      property :execute_command, String

      # file
      property :direction, String, default: 'upload'
    end
  end
end
