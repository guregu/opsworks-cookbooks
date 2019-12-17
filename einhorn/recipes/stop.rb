node[:deploy].each do |application, deploy|
  # if deploy[:application_type] != 'go'
  #   Chef::Log.debug("Skipping einhorn::go application #{application} as it is not an Rails app")
  #   next
  # end

  execute "stop einhorn" do
    command "#{deploy[:deploy_to]}/shared/scripts/einhorn stop"
    only_if do
      File.exists?("#{deploy[:deploy_to]}/shared/scripts/einhorn")
    end
  end
end
