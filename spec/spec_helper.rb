require "chefspec"
require "webmock/rspec"

::LOG_LEVEL = :fatal
::REDHAT_OPTS = {
    :platform  => "redhat",
    :log_level => ::LOG_LEVEL
}
::UBUNTU_OPTS = {
    :platform  => "ubuntu",
    :version   => "12.04",
    :log_level => ::LOG_LEVEL
}

def keystone_stubs
  ::Chef::Recipe.any_instance.stub(:db_password).and_return String.new
  ::Chef::Recipe.any_instance.stub(:secret).and_return String.new
  ::Chef::Recipe.any_instance.stub(:search).with(:node, 'chef_environment:_default AND roles:infra-caching').
    and_return([{'memcached' => { 'listen' => '10.1.1.1'}}])
end
