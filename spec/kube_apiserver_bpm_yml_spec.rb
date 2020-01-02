# frozen_string_literal: true

require 'rspec'
require 'spec_helper'
require 'yaml'

describe 'kube-apiserver' do
  let(:link_spec) do
    {
      'kube-apiserver' => {
        'instances' => [],
        'properties' => {
          'tls-cipher-suites' => 'TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256,TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384'
        }
      },
      'etcd' => {
        'instances' => []
      }
    }
  end

  it 'has default tls-cipher-suites' do
    kube_apiserver = compiled_template(
      'kube-apiserver',
      'config/bpm.yml',
      {},
      link_spec)

    bpm_yml = YAML.safe_load(kube_apiserver)
    expect(bpm_yml['processes'][0]['args']).to include('--tls-cipher-suites=TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256,TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384')
  end

  it 'rejects invalid tls-cipher-suites' do
    # let is executed for each test, so this does not affect other tests
    link_spec["kube-apiserver"]["properties"]["tls-cipher-suites"] = 'INVALID_CIPHER'
    expect {
      compiled_template(
      'kube-apiserver',
      'config/bpm.yml',
      {},
      link_spec)
    }.to raise_error(/Invalid tls-cipher-suites \(INVALID_CIPHER\)/)
  end

  it 'has no http proxy when no proxy is defined' do
    rendered_kube_apiserver_bpm_yml = compiled_template(
      'kube-apiserver',
      'config/bpm.yml',
      {},
      link_spec
    )

    bpm_yml = YAML.safe_load(rendered_kube_apiserver_bpm_yml)
    expect(bpm_yml['processes'][0]['env']).to be_nil
  end

  it 'sets http_proxy when an http proxy is defined' do
    rendered_kube_apiserver_bpm_yml = compiled_template(
      'kube-apiserver',
      'config/bpm.yml',
      {
        'http_proxy' => 'proxy.example.com:8090'
      },
      link_spec
    )

    bpm_yml = YAML.safe_load(rendered_kube_apiserver_bpm_yml)
    expect(bpm_yml['processes'][0]['env']['http_proxy']).to eq('proxy.example.com:8090')
    expect(bpm_yml['processes'][0]['env']['HTTP_PROXY']).to eq('proxy.example.com:8090')
  end

  it 'sets https_proxy when an https proxy is defined' do
    rendered_kube_apiserver_bpm_yml = compiled_template(
      'kube-apiserver',
      'config/bpm.yml',
      {
        'https_proxy' => 'proxy.example.com:8100'
      },
      link_spec
    )

    bpm_yml = YAML.safe_load(rendered_kube_apiserver_bpm_yml)
    expect(bpm_yml['processes'][0]['env']['https_proxy']).to eq('proxy.example.com:8100')
    expect(bpm_yml['processes'][0]['env']['HTTPS_PROXY']).to eq('proxy.example.com:8100')
  end

  it 'sets no_proxy when no proxy property is set' do
    rendered_kube_apiserver_bpm_yml = compiled_template(
      'kube-apiserver',
      'config/bpm.yml',
      {
        'no_proxy' => 'noproxy.example.com,noproxy.example.net'
      },
      link_spec
    )

    bpm_yml = YAML.safe_load(rendered_kube_apiserver_bpm_yml)
    expect(bpm_yml['processes'][0]['env']['no_proxy']).to eq('noproxy.example.com,noproxy.example.net')
    expect(bpm_yml['processes'][0]['env']['NO_PROXY']).to eq('noproxy.example.com,noproxy.example.net')
  end

  it 'sets feature gates if the property is defined' do
    rendered_kube_apiserver_bpm_yml = compiled_template(
      'kube-apiserver',
      'config/bpm.yml',
      {
        'k8s-args' => {
          'feature-gates' => {
            'CustomFeature1' => true,
            'CustomFeature2' => false
          }
        }
      },
      link_spec
    )

    bpm_yml = YAML.safe_load(rendered_kube_apiserver_bpm_yml)
    expect(bpm_yml['processes'][0]['args']).to include('--feature-gates=CustomFeature1=true,CustomFeature2=false')
  end

  it 'set oidc properties' do
    rendered_kube_apiserver_bpm_yml = compiled_template(
      'kube-apiserver',
      'config/bpm.yml',
      {
        'k8s-args' => {
          'oidc-username-prefix' => 'oidc:',
          'oidc-groups-prefix' => 'oidc:'
        }
      },
      link_spec
    )

    bpm_yml = YAML.safe_load(rendered_kube_apiserver_bpm_yml)
    expect(bpm_yml['processes'][0]['args']).to include('--oidc-username-prefix=oidc:')
    expect(bpm_yml['processes'][0]['args']).to include('--oidc-groups-prefix=oidc:')
  end
end
