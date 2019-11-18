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

  context 'horizontal pod autoscaling' do
    it 'sets the properties' do
      rendered_kube_controller_manager_bpm_yml = compiled_template(
        'kube-controller-manager',
        'config/bpm.yml',
        {
          'k8s-args' => {
            'horizontal-pod-autoscaler-downscale-delay' => '2m0s',
            'horizontal-pod-autoscaler-upscale-delay' => '2m0s',
            'horizontal-pod-autoscaler-sync-period' => '40s',
            'horizontal-pod-autoscaler-tolerance' => '0.2',
            'horizontal-pod-autoscaler-use-rest-clients' => false
          }
        },
        links = link_spec
      )

      bpm_yml = YAML.safe_load(rendered_kube_controller_manager_bpm_yml)
      expect(bpm_yml['processes'][0]['args']).to include('--horizontal-pod-autoscaler-downscale-delay=2m0s')
      expect(bpm_yml['processes'][0]['args']).to include('--horizontal-pod-autoscaler-upscale-delay=2m0s')
      expect(bpm_yml['processes'][0]['args']).to include('--horizontal-pod-autoscaler-sync-period=40s')
      expect(bpm_yml['processes'][0]['args']).to include('--horizontal-pod-autoscaler-tolerance=0.2')
      expect(bpm_yml['processes'][0]['args']).to include('--horizontal-pod-autoscaler-use-rest-clients=false')
    end
  end

  it 'has default tls-cipher-suites' do
    kube_controller_manager = compiled_template(
      'kube-controller-manager',
      'config/bpm.yml',
      {},
      link_spec)

    bpm_yml = YAML.safe_load(kube_controller_manager)
    expect(bpm_yml['processes'][0]['args']).to include('--tls-cipher-suites=TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256,TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384')
  end

  it 'rejects invalid tls-cipher-suites' do
    new_link = link_spec.clone
    new_link["kube-apiserver"]["properties"]["tls-cipher-suites"] = 'INVALID_CIPHER'
    expect {
      compiled_template(
      'kube-apiserver',
      'config/bpm.yml',
      {},
      links = link_spec)
    }.to raise_error(/invalid tls-cipher-suites \(INVALID_CIPHER\)/)
  end

  it 'has no http proxy when no proxy is defined' do
    rendered_kube_controller_manager_bpm_yml = compiled_template(
      'kube-controller-manager',
      'config/bpm.yml',
      {},
      links = link_spec)

    bpm_yml = YAML.safe_load(rendered_kube_controller_manager_bpm_yml)
    expect(bpm_yml['processes'][0]['env']).to be_nil
  end

  it 'sets http_proxy when an http proxy is defined' do
    rendered_kube_controller_manager_bpm_yml = compiled_template(
      'kube-controller-manager',
      'config/bpm.yml',
      {'http_proxy' => 'proxy.example.com:8090'},
      links = link_spec
    )

    bpm_yml = YAML.safe_load(rendered_kube_controller_manager_bpm_yml)
    expect(bpm_yml['processes'][0]['env']['http_proxy']).to eq('proxy.example.com:8090')
    expect(bpm_yml['processes'][0]['env']['HTTP_PROXY']).to eq('proxy.example.com:8090')
  end

  it 'sets https_proxy when an https proxy is defined' do
    rendered_kube_controller_manager_bpm_yml = compiled_template(
      'kube-controller-manager',
      'config/bpm.yml',
      {'https_proxy' => 'proxy.example.com:8100'},
      links = link_spec
    )

    bpm_yml = YAML.safe_load(rendered_kube_controller_manager_bpm_yml)
    expect(bpm_yml['processes'][0]['env']['https_proxy']).to eq('proxy.example.com:8100')
    expect(bpm_yml['processes'][0]['env']['HTTPS_PROXY']).to eq('proxy.example.com:8100')
  end

  it 'sets no_proxy when no proxy property is set' do
    rendered_kube_controller_manager_bpm_yml = compiled_template(
      'kube-controller-manager',
      'config/bpm.yml',
      {'no_proxy' => 'noproxy.example.com,noproxy.example.net'},
      links = link_spec
    )

    bpm_yml = YAML.safe_load(rendered_kube_controller_manager_bpm_yml)
    expect(bpm_yml['processes'][0]['env']['no_proxy']).to eq('noproxy.example.com,noproxy.example.net')
    expect(bpm_yml['processes'][0]['env']['NO_PROXY']).to eq('noproxy.example.com,noproxy.example.net')
  end
end
