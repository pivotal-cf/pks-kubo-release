# frozen_string_literal: true

require 'rspec'
require 'spec_helper'
require 'yaml'

describe 'apply-specs' do
  let(:links) do
    {
      'kube-apiserver' => {
        'instances' => [],
        'properties' => {
          'admin-username' => 'meatloaf',
          'admin-password' => 'madagascar-TEST',
          'port' => '2034'
        }
      }
    }
  end

  let(:rendered_kubeconfig) do
    YAML.safe_load(compiled_template('apply-specs', 'config/kubeconfig', {}, links))
  end

  let(:kubeconfig_user) { rendered_kubeconfig['users'][0] }

  it 'uses the admin name from the kube-apiserver link' do
    expect(rendered_kubeconfig['contexts'][0]['context']['user']).to eq('meatloaf')
    expect(kubeconfig_user['name']).to eq('meatloaf')
  end

  it 'uses the token from the kube-apiserver link' do
    expect(kubeconfig_user['user']['token']).to eq('madagascar-TEST')
  end

  it 'constructs the URL using the kube-apiserver link' do
    expect(rendered_kubeconfig['clusters'][0]['cluster']['server']).to eq('https://master.cfcr.internal:8443')
  end

  let(:link_spec) { {} }
  let(:default_properties) do
    {
      'addons' => ["metrics-server"],
      'admin-password' => '1234'
    }
  end
  let(:rendered_deploy_specs) do
    compiled_template('apply-specs', 'bin/deploy-specs', default_properties, link_spec)
  end

  let(:rendered_errand_run) do
    compiled_template('apply-specs', 'bin/run', default_properties, link_spec)
  end

  it 'sets the post-deploy timeout to 1200 by default' do
    expect(rendered_errand_run).to include('TIMEOUT=1200')
  end

  context 'when errand run timeout is re-configured' do
    let(:default_properties) do
      {
        'addons' => ["metrics-server"],
        'admin-password' => '1234',
        'timeout-sec' => '1122'
      }
    end

    it 'overrides the default timeout' do
      expect(rendered_errand_run).to include('TIMEOUT=1122')
    end
  end

  it 'does not apply the standard storage class by default' do
    expect(rendered_deploy_specs).to_not include('apply_spec "storage-class-gce.yml"')
  end

  context 'on GCE' do
    let(:link_spec) do
      {
        'cloud-provider' => {
          'instances' => [],
          'properties' => {
            'cloud-provider' => {
              'type' => 'gce'
            }
          }
        }
      }
    end

    it 'applies the standard storage class' do
      expect(rendered_deploy_specs).to include('apply_spec "storage-class-gce.yml"')
    end
  end

  context 'on non-GCE' do
    let(:link_spec) do
      {
        'cloud-provider' => {
          'instances' => [],
          'properties' => {
            'cloud-provider' => {
              'type' => 'anything'
            }
          }
        }
      }
    end

    it 'does not apply the standard storage class' do
      expect(rendered_deploy_specs).to_not include('apply_spec "storage-class-gce.yml"')
    end
  end

  context 'on unspecified cloud-provider' do
    let(:link_spec) do
      {
        'cloud-provider' => {
          'instances' => [],
          'properties' => {}
        }
      }
    end

    it 'does not apply the standard storage class' do
      expect(rendered_deploy_specs).to_not include('apply_spec "storage-class-gce.yml"')
    end
  end

  context 'when addons are configured' do
    let(:default_properties) do
      {
        'addons' => ['metrics-server']
      }
    end

    it 'deploys only specified addons' do
      rendered = rendered_deploy_specs
      expect(rendered).to match(/apply_spec "metrics-server\/"/)
    end

    it 'does not deploy unspecified addons' do
      rendered = rendered_deploy_specs
      expect(rendered).to_not match(/apply_spec "coredns.yml"/)
      expect(rendered).to_not match(/apply_spec "i-should-not-be-here.yml"/)
    end
  end

  context 'when addons are misconfigured' do
    let(:default_properties) do
      {
        'addons' => ['crap']
      }
    end

    it 'deploys throws a templating error' do
      expect {rendered_deploy_specs}.to raise_error(RuntimeError, "crap is not a supported addon")
    end
  end

  # TODO: figure out how to use json files for GCR auth if necessary
  context 'when using private authenticated harbor registry' do
    let(:manifest_properties) do
      {
          :private_registry => {
              :server => "gcr.io/cf-pks-bosh-lifecycle-main",
              :username => 'admin',
              :password => 'password',
              :email => "user@domain.com"
          },
          :addons => ['coredns']
      }
    end

    let(:coredns_yml) do
      YAML.safe_load(compiled_template('apply-specs', 'specs/coredns.yml', manifest_properties, {}))
    end

    let(:deploy_specs) do
      compiled_template('apply-specs', 'bin/deploy-specs', manifest_properties, {})
    end

    it 'contains imagePullSecrets' do
      expect(coredns_yml['spec']['template']['spec']['imagePullSecrets']).to eq([{"name"=>"regcred"}])
    end

    it 'refers to private registry name in the container image' do
      expect(coredns_yml['spec']['template']['spec']['containers'][0]['image']).to include("gcr.io/cf-pks-bosh-lifecycle-main/")
    end

    it 'creates a docker registry secret' do
      expect(deploy_specs).to include('kubectl create secret docker-registry regcred --docker-server=gcr.io/cf-pks-bosh-lifecycle-main --docker-username=admin --docker-password="password" --docker-email=user@domain.com -n kube-system')
    end
  end

  context 'when using private unauthenticated registry' do
    let(:manifest_properties) do
      {
          :private_registry => {
              :server => "gcr.io/cf-pks-bosh-lifecycle-main",
          },
          :addons => ['coredns']
      }
    end

    let(:coredns_yml) do
      YAML.safe_load(compiled_template('apply-specs', 'specs/coredns.yml', manifest_properties, {}))
    end

    let(:deploy_specs) do
      compiled_template('apply-specs', 'bin/deploy-specs', manifest_properties, {})
    end

    it 'does not contain imagePullSecrets' do
      expect(coredns_yml['spec']['template']['spec']['imagePullSecrets']).to be(nil)
    end

    it 'refers to private registry name in the container image' do
      expect(coredns_yml['spec']['template']['spec']['containers'][0]['image']).to include("gcr.io/cf-pks-bosh-lifecycle-main/")
    end

    it 'should not create a docker registry secret' do
      expect(deploy_specs).not_to include('kubectl create secret docker-registry')
    end
  end

  context 'when not using private registry' do
    let(:coredns_yml) do
      YAML.safe_load(compiled_template('apply-specs', 'specs/coredns.yml', {}, {}))
    end

    let(:deploy_specs) do
      compiled_template('apply-specs', 'bin/deploy-specs', {:addons=>['coredns']}, {})
    end

    it 'does not contain imagePullSecrets' do
      expect(coredns_yml['spec']['template']['spec']['imagePullSecrets']).to be(nil)
    end

    it 'does not refer to private registry name in the container image' do
      expect(coredns_yml['spec']['template']['spec']['containers'][0]['image']).not_to include("gcr.io/cf-pks-bosh-lifecycle-main/")
    end

    it 'should not create a docker registry secret' do
      expect(deploy_specs).not_to include('kubectl create secret docker-registry')
    end
  end
end
