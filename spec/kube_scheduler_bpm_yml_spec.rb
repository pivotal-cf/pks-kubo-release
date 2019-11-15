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

  it 'has default tls-cipher-suites' do
    kube_scheduler = compiled_template(
      'kube-scheduler',
      'config/bpm.yml',
      {},
      link_spec)

    bpm_yml = YAML.safe_load(kube_scheduler)
    expect(bpm_yml['processes'][0]['args']).to include('--tls-cipher-suites=TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256,TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384')
  end
end
