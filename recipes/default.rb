require 'yajl'

gem_package "sys-proctable" do
  action :install
end

cookbook_file "/etc/init.d/unicorn_rack" do
  source 'unicorn_rack'
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
    "bin"         => x['bin']
  }
end

search('applications', "hosts:#{node.name}").each(&filter_proc)
node["applications"].each(&filter_proc)

file "/etc/default/unicorn.json" do
  content Yajl.dump(host_applications, :pretty => true)
  mode 00640
  owner "root"
  group "root"
  notifies :restart, "service[unicorn_rack]"
end
