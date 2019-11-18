# frozen_string_literal: true

require 'rspec'
require 'spec_helper'
require 'yaml'

describe 'flag_generation_tests' do

  let(:link_spec) do
    {
      'kube-apiserver' => {
        'address' => 'fake.kube-api-address',
        'instances' => []
      },
      'kube-common-config' => {
          'instances' => [],
          'properties' => {
              'tls-cipher-suites' => 'TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256,TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384'
          }
      },
      'etcd' => {
        'address' => 'fake-etcd-address',
        'properties' => { 'etcd' => { 'advertise_urls_dns_suffix' => 'dns-suffix' } },
        'instances' => [
          {
            'name' => 'etcd',
            'index' => 0,
            'address' => 'fake-etcd-address-0'
          },
          {
            'name' => 'etcd',
            'index' => 1,
            'address' => 'fake-etcd-address-1'
          }
        ]
      }
    }
  end

  k8s_args = {
    'k8s-args' => {
      'hash': {
        'key1' => 'value1',
        'key2' => 'value2'
      },
      'array' => [ 'value1', 'value2' ],
      'true' => true,
      'false' => false,
      'string' => "value",
      'flagNil' => nil,
      'colonSuffix' => "value:"
    }
  }

  k8s_args_with_tls_cipher_suites = {
    'k8s-args' => {
      'tls-cipher-suites' => 'TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256'
    }
  }

  def test_bpm(template)
    yaml = YAML.safe_load(template)
    expect(yaml['processes'][0]['args']).to include('--hash=key1=value1,key2=value2')
    expect(yaml['processes'][0]['args']).to include('--array=value1,value2')
    expect(yaml['processes'][0]['args']).to include('--true=true')
    expect(yaml['processes'][0]['args']).to include('--false=false')
    expect(yaml['processes'][0]['args']).to include('--string=value')
    expect(yaml['processes'][0]['args']).to include('--flagNil')
    expect(yaml['processes'][0]['args']).to include('--colonSuffix=value:')
  end

  def test_ctl(template)
    expect(template).to include('--hash=key1=value1,key2=value2')
    expect(template).to include('--array=value1,value2')
    expect(template).to include('--true=true')
    expect(template).to include('--false=false')
    expect(template).to include('--string=value')
    expect(template).to include('--flagNil')
    expect(template).to include('--colonSuffix=value:')
  end

  context 'kube-controller-manager' do
    it 'passes through args correctly' do
      kube_controller_manager = compiled_template(
        'kube-controller-manager',
        'config/bpm.yml',
        k8s_args,
        link_spec)

      test_bpm(kube_controller_manager)
    end

    it 'rejects tls-cipher-suites in k8s_args' do
      expect {
        compiled_template(
          'kube-controller-manager',
          'config/bpm.yml',
          k8s_args_with_tls_cipher_suites,
          link_spec)
      }.to raise_error.with_message(/do not set tls-cipher-suites in k8s-args/)
    end
  end

  context 'kube-apiserver' do
    it 'passes through args correctly' do
      kube_apiserver = compiled_template(
        'kube-apiserver',
        'config/bpm.yml',
        k8s_args,
        link_spec)

      test_bpm(kube_apiserver)
    end

    it 'rejects tls-cipher-suites in k8s_args' do
      expect {
        compiled_template(
          'kube-apiserver',
          'config/bpm.yml',
          k8s_args_with_tls_cipher_suites,
          link_spec)
      }.to raise_error.with_message(/do not set tls-cipher-suites in k8s-args/)
    end
  end

  context 'kubelet' do
    it 'passes through args correctly' do
      kubelet = compiled_template(
        'kubelet',
        'bin/kubelet_ctl',
        k8s_args,
        link_spec)

      test_ctl(kubelet)
    end

    it 'rejects tls-cipher-suites in k8s_args' do
      expect {
        compiled_template(
          'kubelet',
          'bin/kubelet_ctl',
          k8s_args_with_tls_cipher_suites,
          link_spec)
      }.to raise_error.with_message(/do not set tls-cipher-suites in k8s-args/)
    end
  end

  context 'kube-proxy' do
    it 'passes through args correctly' do
      kube_proxy = compiled_template(
        'kube-proxy',
        'bin/kube_proxy_ctl',
        k8s_args)

      test_ctl(kube_proxy)
    end
  end

  context 'kube-scheduler' do
    it 'passes through args correctly' do
      kube_scheduler = compiled_template(
        'kube-scheduler',
        'config/bpm.yml',
        k8s_args,
        link_spec)

      test_bpm(kube_scheduler)
    end

    it 'rejects tls-cipher-suites in k8s_args' do
      expect {
        compiled_template(
          'kube-scheduler',
          'config/bpm.yml',
          k8s_args_with_tls_cipher_suites,
          link_spec)
      }.to raise_error.with_message(/do not set tls-cipher-suites in k8s-args/)
    end
  end
end
