#
# Cookbook Name:: foreman
# Recipe:: default
#
# Copyright (C) 2013 YOUR_NAME
#
# All rights reserved - Do Not Redistribute
#

include_recipe 'foreman::repo' if node['foreman']['use_repo']

%w(foreman foreman-libvirt foreman-proxy).each do |pack|
  package pack
end
