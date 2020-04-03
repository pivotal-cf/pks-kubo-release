# frozen_string_literal: true

require 'rspec'
require 'spec_helper'

describe 'etcd.erb' do
  let(:rendered_template) do
    compiled_template('etcd', 'bin/etcd', {}, {}, {}, 'z1', 'fake-bosh-ip', 'fake-bosh-id')
  end

  it 'includes default cipher-suites' do
    expect(rendered_template).to include('--cipher-suites=TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256,TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384')
  end
end
