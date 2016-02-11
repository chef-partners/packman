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
    class PackerTemplate < Chef::Resource::LWRPBase
      resource_name :packer_template

      actions :create, :run
      default_action :create

      property :parallel, kind_of: [TrueClass, FalseClass], default: true
      property :machine_readable, kind_of: [TrueClass, FalseClass], default: false
      property :debug, kind_of: [TrueClass, FalseClass], default: false
      property :except, kind_of: Array
      property :only, kind_of: Array
    end
  end
end
