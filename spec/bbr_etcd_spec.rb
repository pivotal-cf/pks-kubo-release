require 'bosh/template/test'
require 'open3'

describe 'bbr-etcd job' do
  let(:release_dir) { File.join(File.dirname(__FILE__), '../..') }
  let(:release) { Bosh::Template::Test::ReleaseDir.new(release_dir) }
  let(:job) { release.job('bbr-etcd') }

  describe 'backup' do
    let(:backup_template) { job.template('bin/bbr/backup') }

    it 'succeeds when bbr.backup_one_restore_all is set to true' do
      expect { backup_template.render({"bbr"=> {"backup_one_restore_all" => true}}) }.not_to(raise_error)
    end

    it 'raises an error when bbr.backup_one_restore_all is set to false' do
      expect { backup_template.render({}) }.to(raise_error(RuntimeError, 'bbr.backup_one_restore_all property must be set to true in the manifest!'))
    end
  end

  describe 'metadata' do
    let(:metadata_template) { job.template('bin/bbr/metadata') }
    let(:metadata_script) { metadata_template.render({}) }
    let(:metadata_cmd) { "bash -c '#{metadata_script}'" }

    it 'fails when called with an old version of bbr that does not export BBR_VERSION' do
      _, error_str, status = Open3.capture3(metadata_cmd)
      expect(status.success?).not_to eq(true)
      expect(error_str).to include('Error: BBR_VERSION is not set, please ensure you are using the latest version of bbr')
    end

    it 'fails to run when bbr major version set to string' do
        _, stderr_str, status = Open3.capture3({'BBR_VERSION' => 'foo.bar.baz'}, metadata_cmd)
        expect(status.success?).not_to eq(true)
        expect(stderr_str).to include('Error: BBR version must be a valid semVer')
    end

    it 'fails to run when bbr minor version set to string' do
      _, stderr_str, status = Open3.capture3({'BBR_VERSION' => '1.bar.baz'}, metadata_cmd)
        expect(status.success?).not_to eq(true)
        expect(stderr_str).to include('Error: BBR version must be a valid semVer')
    end

    it 'returns error if the bbr_version is less than 1.5.0' do
      _, stderr_str, status = Open3.capture3({'BBR_VERSION' => '1.4.0'}, metadata_cmd)
      expect(status.success?).not_to eq(true)
      expect(stderr_str).to include('Error: BBR version must be 1.5.0 or greater')
    end

    it 'succesfully runs if the bbr_version is 1.5.0' do
        stdout_str, _, status = Open3.capture3({'BBR_VERSION' => '1.5.0'}, metadata_cmd)
        expect(status.success?).to eq(true)
        expect(stdout_str).to include('---')
    end

    it 'succesfully runs if the bbr_version is greater than 1.5.0' do
        stdout_str, _, status = Open3.capture3({'BBR_VERSION' => '2.3.4'}, metadata_cmd)
        expect(status.success?).to eq(true)
        expect(stdout_str).to include('---')
    end
  end
end


