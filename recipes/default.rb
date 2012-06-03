require 'yajl'

user 'rails' do
  shell "/bin/bash"
  action :create
end

cookbook_file "/etc/init.d/unicorn_rack" do
  source 'unicorn_rack.sh'
  mode 00750
  owner "root"
  group "root"
end

service "unicorn_rack" do
  supports [:restart, :reload]
  action :enable
end

host_applications = { }

filter_proc = proc do |x|
  host_applications[x['path']] = {
    "config_path" => x['config_path'],
    "bin"         => x['bin'],
    "user"        => x['user'] || 'rails'
  }
end

search('applications', "hosts:#{node.name}").each(&filter_proc)
node["applications"].each(&filter_proc)

file "/etc/default/unicorn.json" do
  action :delete
end

awk_friendly_mess = 
  host_applications.keys.map do |key| 
    ha = host_applications[key]
    "#{key}:#{ha["config_path"]}:#{ha["bin"]}:#{ha["user"]}"
  end.join("\n")

file '/etc/unicorn.conf' do
  content awk_friendly_mess
  mode 00640
  owner "root"
  group "root"
  notifies :restart, "service[unicorn_rack]"
end
