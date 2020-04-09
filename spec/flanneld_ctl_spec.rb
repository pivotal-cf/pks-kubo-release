# frozen_string_literal: true

require 'rspec'
require 'spec_helper'
require 'tempfile'
require 'open3'

describe 'flanneld ctl' do
  let(:link_spec) do
    {
        'flanneld' => {
            'instances' => [],
            'properties' => {
                'cniVersion' => '0.3.1'
            }
        },
        'etcd' => {
            'instances' => []
        }
    }
  end
  let(:properties_spec) do
    {
        'pod-network-cidr' => '0.0.0.0/24',
        'port' => 8443,
        'vni' => 'vni'
    }
  end
  it 'has valid json for cniVersion' do
    flanneld = compiled_template(
        'flanneld',
        'bin/flanneld_ctl',
        properties_spec,
        link_spec)

    expect(flanneld).to include('"cniVersion": "0.3.1",')
  end
  it 'has valid values for networking' do
    flanneld = compiled_template(
        'flanneld',
        'bin/flanneld_ctl',
        properties_spec,
        link_spec)

    expect(flanneld).to include('{"Network":"0.0.0.0/24","Backend":{"Type":"vxlan","Port":8443,"VNI":"vni"}}')
  end
end
