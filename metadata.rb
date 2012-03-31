maintainer        "Erik Hollensbe"
maintainer_email  "erik+chef@hollensbe.org"
license           "Apache 2.0"
description       "Maintain applications running the unicorn server software"
long_description  IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version           "0.1.0"

recipe "unicorn::default",
  "Installs the unicorn_rack service and any applications definitions for the host"

%w{ debian ubuntu }.each do |os|
  supports os
end
