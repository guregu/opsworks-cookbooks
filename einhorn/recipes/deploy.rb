include_recipe 'deploy'

chef_gem 'toml-rb' do
  version "1.1.2"
end
require 'toml-rb'

node[:deploy].each do |application, deploy|
  opsworks_deploy_dir do
    user deploy[:user]
    group deploy[:group]
    path deploy[:deploy_to]
  end

  opsworks_deploy do
    deploy_data deploy
    app application
  end

  shared_dir = "#{deploy[:deploy_to]}/shared"

  # generate config
  # TODO: move this to its own recipe
  if deploy[:app_config]
  	toml_data = TomlRB.dump(deploy[:app_config])
  	file "#{shared_dir}/config/config.toml" do
  		group deploy[:group]
  		owner deploy[:user]
  		mode '0644'
  		content toml_data
  	end
  else
  	Chef::Log.warn("[einhorn] no config")
  end

  execute "einhorn #{application} restart" do
  	command "#{shared_dir}/scripts/einhorn restart"
  end
end
