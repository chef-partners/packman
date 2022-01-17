#
# Author:: Partner Engineering <partnereng@chef.io>
# Copyright:: (c) 2016, Chef Software, Inc. <legal@chef.io>
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

require_relative './helpers'

class Chef
  class Resource
    class PackerPostProcessor < Chef::Resource::LWRPBase
      resource_name :packer_post_processor
      provides :packer_post_processor

      actions :create
      default_action :create

      property :type, kind_of: String, name_property: true
      property :options, kind_of: Hash
    end
  end
end
