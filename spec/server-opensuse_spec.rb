# encoding: UTF-8
#

require_relative 'spec_helper'

describe 'openstack-identity::server' do
  before { identity_stubs }
  describe 'suse' do
    before do
      @chef_run = ::ChefSpec::Runner.new ::OPENSUSE_OPTS
      @chef_run.converge 'openstack-identity::server'
    end

    it 'converges when configured to use sqlite db backend' do
      chef_run = ::ChefSpec::Runner.new ::OPENSUSE_OPTS
      node = chef_run.node
      node.set['openstack']['db']['identity']['service_type'] = 'sqlite'
      chef_run.converge 'openstack-identity::server'
    end

    it 'installs mysql python packages' do
      expect(@chef_run).to install_package 'python-mysql'
    end

    it 'installs postgresql python packages if explicitly told' do
      chef_run = ::ChefSpec::Runner.new ::OPENSUSE_OPTS do |n|
        n.set['openstack']['db']['identity']['service_type'] = 'postgresql'
      end
      chef_run.converge 'openstack-identity::server'

      expect(chef_run).to install_package 'python-psycopg2'
    end

    it 'installs memcache python packages' do
      expect(@chef_run).to install_package 'python-python-memcached'
    end

    it 'installs keystone packages' do
      expect(@chef_run).to upgrade_package 'openstack-keystone'
    end

    it 'starts keystone on boot' do
      expect(@chef_run).to enable_service('openstack-keystone')
    end

    describe '/etc/keystone' do
      before do
        @dir = @chef_run.directory '/etc/keystone'
      end

      it 'has proper owner' do
        expect(@dir.owner).to eq('openstack-keystone')
        expect(@dir.group).to eq('openstack-keystone')
      end
    end

    describe '/etc/keystone/ssl' do
      before do
        chef_run = ::ChefSpec::Runner.new(::OPENSUSE_OPTS) do |n|
          n.set['openstack']['auth']['strategy'] = 'pki'
        end
        chef_run.converge 'openstack-identity::server'
        @dir = chef_run.directory '/etc/keystone/ssl'
      end

      it 'has proper owner' do
        expect(@dir.owner).to eq('openstack-keystone')
        expect(@dir.group).to eq('openstack-keystone')
      end
    end

    it 'deletes keystone.db' do
      expect(@chef_run).to delete_file '/var/lib/keystone/keystone.db'
    end

    describe 'keystone.conf' do
      before do
        @template = @chef_run.template '/etc/keystone/keystone.conf'
      end

      it 'has proper owner' do
        expect(@template.owner).to eq('openstack-keystone')
        expect(@template.group).to eq('openstack-keystone')
      end

      it 'template contents' do
        pending 'TODO: implement'
      end
    end

    describe 'default_catalog.templates' do
      before do
        chef_run = ::ChefSpec::Runner.new(::OPENSUSE_OPTS) do |n|
          n.set['openstack']['identity']['catalog']['backend'] = 'templated'
        end
        chef_run.converge 'openstack-identity::server'
        @template = chef_run.template(
          '/etc/keystone/default_catalog.templates')
      end

      it 'has proper owner' do
        expect(@template.owner).to eq('openstack-keystone')
        expect(@template.group).to eq('openstack-keystone')
      end

      it 'template contents' do
        pending 'TODO: implement'
      end
    end
  end
end
