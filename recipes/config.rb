group node['foreman']['group'] do
  members node['foreman']['group_users'] if node['foreman']['group_users']
end

user node['foreman']['user'] do
  shell '/bin/bash'
  group node['foreman']['group']
  supports manage_home: node['foreman']['manage_home']
  home node['foreman']['user_home']
end

directory node['foreman']['config_path']

template ::File.join(node['foreman']['config_path'], 'settings.yaml') do
  group node['foreman']['group']
  source 'settings_foreman.yaml.erb'
end

template ::File.join(node['foreman']['config_path'], 'database.yml') do
  group node['foreman']['group']
  source 'database.yml.erb'
  variables real_adapter: node['foreman']['db']['real_adapter']
end

template ::File.join(node['foreman-proxy']['config_path'], 'settings.yml') do
  group node['foreman']['group']
  source 'settings_foreman-proxy.yml.erb'
end

template node['foreman']['config']['init'] do
  source node['foreman']['config']['init_tpl']
end

if node['foreman']['passenger']['install']
  directory "#{node['apache']['conf_dir']}/05-foreman.d" do
    owner 'root'
    group 'root'
    mode '0644'
  end

  template "#{node['apache']['dir']}/mods-available/passenger_extra.conf" do
    source 'passenger.conf.erb'
  end

  # @TODO Foreman SSL
  web_app 'foreman' do
    server_name node['foreman']['server_name']
    server_aliases ['foreman']
    docroot "#{node['foreman']['path']}/public"
    directory_options %w(SymLinksIfOwnerMatch)
    cookbook 'foreman'
    notifies 'service[apache2]', :restart, :delayed
  end
end
