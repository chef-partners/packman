module PackmanCookbook
  module Helpers
    def run_state
      node.run_state['packman'] ||= {}
    end

    def add_variable(key, value)
      run_state['packer_variables'] ||= []
      run_state['packer_variables'] << { key => value }
    end

    def add_post_processor(type, options)
      run_state['packer_post_processors'] ||= []
      run_state['packer_post_processors'] << { type => options }
    end

    def add_builder(name, options)
      run_state['packer_builders'] ||= []
      run_state['packer_builders'] << { name => options }
    end

    def add_provisioner
      validate_type!
      provisioner = { 'type' => new_resource.type }

      provisioner['override'] = new_resource.overide if new_resource.override
      provisioner['pause_before'] = new_resource.pause_before if new_resource.pause_before
      provisioner['only'] = new_resource.only if new_resource.only
      provisioner['except'] = new_resource.except if new_resource.except
      provisioner['binary'] = true if new_resource.binary

      case new_resource.type
      when 'file'
        add_file_provisioner(provisioner)
      when 'shell'
        add_shell_provisioner(provisioner)
      when 'local-shell'
        add_local_shell_provisioner(provisioner)
      end

      run_state['packer_provisioners'] ||= []
      run_state['packer_provisioners'] << provisioner
    end

    def add_file_provisioner(provisioner)
      if new_resource.direction == 'upload'
        provisioner['source'] = render_template(new_resource.source, new_resource.variables)
      else
        provisioner['direction'] = 'download'
        provisioner['source'] = new_resource.source
      end
      provisioner['destination'] = new_resource.destination
    end

    def add_shell_provisioner(provisioner)
      if new_resource.inline
        provisioner['inline'] = [new_resource.command]
        provisioner['inline_shebang'] = new_resource.inline_shebang if new_resource.inline_shebang
      else
        provisioner['script'] = render_template(new_resource.source, new_resource.variables)
      end
      provisioner['environment_vars'] = format_env_vars(new_resource.environment_vars) if new_resource.environment_vars
      provisioner['start_retry_timeout'] = new_resource.start_retry_timeout if new_resource.start_retry_timeout
      provisioner['skip_clean'] = new_resource.skip_clean if new_resource.skip_clean
      provisioner['execute_command'] = new_resource.execute_command if new_resource.execute_command
    end

    def add_local_shell_provisioner(provisioner)
      provisioner['command'] =
        if new_resource.command
          new_resource.command
        else
          # Use the name attribute as the command
          new_resource.destination
        end
      provisioner['execute_command'] = new_resource.execute_command if new_resource.execute_command
    end

    def validate_type!
      return if %w(shell local-shell file).include?(new_resource.type)
      Chef::Application.fatal!("Invalid Packman type: '#{new_resource.type}' declared")
    end

    def render_template(template_source, template_variables)
      require 'tempfile'
      template_file = Tempfile.new(template_source)

      template template_file.path do
        source template_source
        cookbook template_cookbook
        variables template_variables
        action :create
      end

      # When Ruby exits it will delete all Tempfiles but we're good citizens
      # so we'll explicitly unlink and delete them later.
      run_state['temp_files'] ||= []
      run_state['temp_files'] << template_file

      file.path
    end

    def format_env_vars(vars)
      vars.is_a?(Hash) ? vars.map { |k, v| "#{k}=#{v}" } : vars
    end

    def create_packer_template
      require 'tempfile'
      require 'json'

      template = {}
      template['variables'] = run_state['packer_variables'] if run_state['packer_variables']
      template['builders'] = run_state['packer_builders'] if run_state['packer_builders']
      template['provisioners'] = run_state['packer_provisioners'] if run_state['packer_provisioners']
      template['post-processors'] = run_state['packer_post_processors'] if run_state['packer_post_processors']

      template_file = Tempfile.new('template.json')

      file template_file.path do
        content JSON.pretty_generate(template)
      end

      run_state['packer_template'] = template_file
      run_state['temp_files'] ||= []
      run_state['temp_files'] << template_file
    end

    def run_packer
      # TODO: support for packer binary location
      command = ['packer build']
      command << '-debug' if new_resource.debug
      command << '-machine-readable' if new_resource.machine_readable
      command << "-parallel=#{new_resource.parallel}"
      command << "-except=#{new_resource.except.join(',')}" if new_resource.except
      command << "-only=#{new_resource.only.join(',')}" if new_resource.only
      command << run_state['packer_template'].path

      execute command.join(' ')
    end

    def cleanup
      run_state['temp_files'].each do |f|
        f.unlink
        f.close
      end
    end

    def template_cookbook
      new_resource.cookbook.nil? ? new_resource.cookbook_name.to_s : new_resource.cookbook
    end
  end
end
