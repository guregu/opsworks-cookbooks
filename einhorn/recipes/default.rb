#
# Cookbook Name:: einhorn
# Recipe:: default
#

gem_package 'einhorn' do
  options '--no-user-install'
end

node[:deploy].each do |application, deploy|
  deploy = node[:deploy][application]
  shared_dir = "#{deploy[:deploy_to]}/shared"

  opsworks_deploy_user do
    deploy_data deploy
  end

  opsworks_deploy_dir do
    user deploy[:user]
    group deploy[:group]
    path deploy[:deploy_to]
  end

  %w(logs config pids sockets scripts).each do |name|
    directory "#{shared_dir}/#{name}" do
      group deploy[:group]
      owner deploy[:user]
      mode '0775'
      recursive true
      action :create
    end
  end

  template "#{shared_dir}/scripts/einhorn" do
    source "einhorn.sh.erb"
    group deploy[:group]
    owner deploy[:user]
    mode '0775'
    variables(:application => application, :deploy => deploy)
  end

  service "einhorn_#{application}" do
    init_command "#{shared_dir}/scripts/einhorn"
    supports :restart => true, :start => true, :stop => true, :reload => true
    action :nothing
  end

end
