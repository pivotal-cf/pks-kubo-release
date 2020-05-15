# frozen_string_literal: true

require 'rspec'
require 'spec_helper'

describe 'kubelet pre-stop' do
  let(:test_context) do
    mock_dir = '/tmp/store-custom-labels-taints-mock'
    FileUtils.mkdir(mock_dir)

    store_custom_labels_taints_file = mock_dir + '/store-custom-labels-taints-mock'
    label_file = mock_dir + "/labels"
    taint_file = mock_dir + "/taints"

    File.open(label_file, 'w', 0o600)
    File.open(taint_file, 'w', 0o600)

    {
      'mock_dir' => mock_dir,
      'store_custom_labels_taints_file' => store_custom_labels_taints_file,
      'label_file' => label_file,
      'taint_file' => taint_file,
    }

  end
  after(:each) do
    FileUtils.remove_dir(test_context['mock_dir'], true)
  end

  it 'gets labels for current node, put labels with prefix into local file' do
    label_content = <<-EOF
echo '{
  "apiVersion": "v1",
  "items": [
    {
      "metadata": {
        "labels": {
          "tkgi-a/a": "a",
          "tkgi-b/b": "",
          "c.c/c": "c"
        }
      }
    }
  ]
}'
EOF

    # mock out kubectl because this code path will try to use it.
    kubectl_mock_file = test_context['mock_dir'] + '/kubectl'
    File.open(kubectl_mock_file, 'w', 0o777) do |f|
      f.write(label_content)
    end

    rendered_store_custom_labels_taints = compiled_template('kubelet', 'bin/store-custom-labels-taints', {}, {}, {}, nil, nil, nil)
    call_function(rendered_store_custom_labels_taints, test_context['store_custom_labels_taints_file'], 'JQ_PATH=/usr/bin/jq CUSTOM_LABEL_PATH='+test_context['label_file']+' CUSTOM_TAINT_PATH='+test_context['taint_file'], "store_custom_labels_taints")

    File.open(test_context['label_file'], "r") do |f|
      file_content = f.read
      expect(file_content).to include('tkgi-a/a=a')
      expect(file_content).to include('tkgi-b/b=')
      expect(file_content).not_to include('c.c/c=c')
    end
  end

  it 'gets labels and taints for current node, put labels and  taints with prefix into local file' do
    label_content = <<-EOF
echo '{
  "apiVersion": "v1",
  "items": [
    {
      "metadata": {
        "labels": {
          "tkgi-a/a": "a",
          "tkgi-b/b": "",
          "c.c/c": "c"
        }
      },
      "spec": {
        "taints": [
          {
            "effect": "NoSchedule",
            "key": "key1",
            "value": "value1"
          },
          {
            "effect": "NoSchedule",
            "key": "tkgi-a",
            "value": "value1"
          }
        ]
      }
    }
  ]
}'
EOF
    # mock out kubectl because this code path will try to use it.
    kubectl_mock_file = test_context['mock_dir'] + '/kubectl'
    File.open(kubectl_mock_file, 'w', 0o777) do |f|
      f.write(label_content)
    end

    rendered_store_custom_labels_taints = compiled_template('kubelet', 'bin/store-custom-labels-taints', {}, {}, {}, nil, nil, nil)
    out = call_function(rendered_store_custom_labels_taints, test_context['store_custom_labels_taints_file'], 'JQ_PATH=/usr/bin/jq CUSTOM_LABEL_PATH='+test_context['label_file']+' CUSTOM_TAINT_PATH='+test_context['taint_file'], "store_custom_labels_taints")

    File.open(test_context['label_file'], "r") do |f|
      file_content = f.read
      expect(file_content).to include('tkgi-a/a=a')
      expect(file_content).to include('tkgi-b/b=')
      expect(file_content).not_to include('c.c/c=c')
    end

    File.open(test_context['taint_file'], "r") do |f|
      file_content = f.read
      expect(file_content).to include('tkgi-a=value1:NoSchedule')
      expect(file_content).not_to include('key1=value1:NoSchedule')
    end
  end
end
