# frozen_string_literal: true

require 'rspec'
require 'spec_helper'
require 'yaml'

describe 'kube_controller_manager' do
  let(:link_spec) do
    {
      'kube-apiserver' => {
        'instances' => [],
        'properties' => {
          'tls-cipher-suites' => 'TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256,TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384'
        }
      },
      'etcd' => {
        'properties' => { },
        'instances' => [ ]
      }
    }
  end

  it 'has no default setting for tls-cipher-suites' do
    kube_scheduler = compiled_template(
      'kube-scheduler',
      'config/bpm.yml',
      {},
      link_spec)

    bpm_yml = YAML.safe_load(kube_scheduler)
    expect(bpm_yml['processes'][0]['args']).not_to include('--tls-cipher-suites=TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256,TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384')
  end

  it 'rejects any k8s_args setting for tls-cipher-suites' do
    expect {
      compiled_template(
      'kube-scheduler',
      'config/bpm.yml',
      {'k8s-args' => { 'tls-cipher-suites' => 'foobar'}},
      link_spec)
    }.to raise_error(/tls-cipher-suites cannot be changed/)
  end
end
