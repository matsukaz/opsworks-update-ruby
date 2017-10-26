ruby_version = node[:ruby][:update_version]
bundler_version = node[:ruby][:update_bundler_version]

package "readline-devel" do
  retries 3
  retry_delay 5
end

git "/usr/local/rbenv" do
  repository "git://github.com/sstephenson/rbenv.git"
  reference "master"
  action :sync
end

%w{/usr/local/rbenv/shims /usr/local/rbenv/versions}.each do |dir|
  directory dir do
  action :create
  end
end

git "/usr/local/ruby-build" do
  repository "git://github.com/sstephenson/ruby-build.git"
  reference "master"
  action :sync
end

bash "install_ruby_build" do
  cwd  "/usr/local/ruby-build"
  code "./install.sh"
  action :run
end
template "rbenv.sh" do
  path "/etc/profile.d/rbenv.sh"
  owner "root"
  group "root"
  mode "0644"
  source "rbenv.sh.erb"
end

bash "rbenv install" do
  code   "source /etc/profile.d/rbenv.sh; CONFIGURE_OPTS=\"--disable-install-rdoc\" rbenv install -v #{ruby_version}"
  action :run
  not_if { ::File.exists?("/usr/local/rbenv/versions/#{ruby_version}") }
end

bash "rbenv rehash" do
    code   "source /etc/profile.d/rbenv.sh; rbenv rehash"
    action :run
end

bash "rbenv global" do
    code   "source /etc/profile.d/rbenv.sh; rbenv global #{ruby_version}"
    action :run
end

bash "bundler install" do
  code   "source /etc/profile.d/rbenv.sh; gem install bundler -v #{bundler_version}"
  action :run
end

%w{bundle bundler rake gem ruby}.each do |target|
  bash "replace #{target}" do
    code   "mv /usr/local/bin/#{target} /usr/local/bin/#{target}_system;cp /usr/local/rbenv/shims/#{target} /usr/local/bin/#{target}"
    action :run
    only_if { ::File.exists?("/usr/local/rbenv/shims/#{target}") }
  end
end

