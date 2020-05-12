#!/usr/bin/env ruby

# Make a directory to contain just the downloads
# First to confluence https://confluence.eng.vmware.com/display/TKG/TKG+Core+v1.17.x
# Second go to build web, then deliverables and download the tar ball e.g.vmware-kubernetes-v1.17.5+vmware.1.tar.gz

# cd into directory containing just these downloads
# ruby ~/workspace/pks-kubernetes-release/ci/scripts/download_common_core_from_build_web.rb

require 'fileutils'

module PksKubernetesRelease
  class DownloadFromBuildWeb
    def self.run(kubernetes_version, bora_number, container_images, binaries, staging_dir)
      flatten = kubernetes_version.sub("+", "_")

      container_images.each do |image|
        url = "http://build-squid.eng.vmware.com/build/mts/release/bora-#{bora_number}/publish/lin64/kscom_release/vmware-kubernetes-v#{kubernetes_version}/kubernetes-v#{kubernetes_version}/images/#{image}-v#{flatten}.tar.gz"
        execute_system_call ("wget #{url} --directory-prefix #{staging_dir}")
      end

      binaries.each do |binary|
        url = "http://build-squid.eng.vmware.com/build/mts/release/bora-#{bora_number}/publish/lin64/kscom_release/vmware-kubernetes-v#{kubernetes_version}/kubernetes-v#{kubernetes_version}/executables/#{binary}-linux-v#{kubernetes_version}.gz"
        execute_system_call ("wget #{url} --directory-prefix #{staging_dir}")
      end
    end
  end

  class ExtractBinariesFromDockerImage
    def self.run(kubernetes_version, container_image, staging_dir, destination_dir)
      puts
      puts "Processing #{container_image}"

      version_tag = "v" + kubernetes_version.sub("+", "_")
      filename = container_image + "-" + version_tag + ".tar.gz"  # "kube-proxy-v1.17.5_vmware.1.tar.gz",

      command = "docker load -i #{staging_dir}/#{filename}"
      execute_system_call command

      command = "docker image ls --filter 'reference=registry.tkg.vmware.run/#{container_image}:#{version_tag}' --format '{{.ID}}'"
      image_id = execute_system_call command

      command = "docker create #{image_id}"
      container_id = execute_system_call command

      command = "docker cp #{container_id}:/usr/local/bin/#{container_image} #{destination_dir}/#{container_image}"
      execute_system_call command
    end
  end
end

def execute_system_call(command)
  puts command
  result = `#{command}`
  puts "...returned #{result}"
  result.strip
end

def add_blob(binary_name, release_dir, binary_dir, kubernetes_version)
  Dir.chdir release_dir do
    blob_name = execute_system_call("bosh blobs --column path | grep '#{binary_name}\\s$' | xargs")
    execute_system_call("bosh remove-blob '#{blob_name}'")
    execute_system_call("bosh add-blob '#{binary_dir}/#{binary_name}' 'common-core-kubernetes-#{kubernetes_version}/#{binary_name}'")
  end
end

# bora_number = "16143127"
# kubernetes_version = "1.16.9+vmware.1"

bora_number = "16162671"
kubernetes_version = "1.18.1+vmware.1"


release_dir = "/Users/pivotal/workspace/pks-kubernetes-release"

staging_dir = execute_system_call("mktemp -d")

output_dir = staging_dir + "/kubernetes-v#{kubernetes_version}/"
binary_dir = output_dir + "bin/linux/amd64/"
FileUtils.mkdir_p binary_dir

container_images = [
    "kube-proxy",
    "kube-apiserver",
    "kube-scheduler",
    "kube-controller-manager",
]

binaries = [
    "kubelet",
    "kubectl"
]

Dir.chdir release_dir do
  existing_k8s_spec = execute_system_call "bosh blobs --column path | grep '#{binaries[0]}' | grep -o -E 'kubernetes-([0-9]+\.)+[0-9]+'"
  existing_k8s_version = execute_system_call "echo '#{existing_k8s_spec}' | grep -o -E '([0-9]+\.)+[0-9]+'"

  if existing_k8s_version == kubernetes_version
    puts "Kubernetes version already up-to-date."
    exit
  end

  Dir.chdir "packages/kubernetes" do
    execute_system_call "sed -E -i -e 's/KUBERNETES_VERSION=\"([0-9]+\.)+[0-9]+\"/KUBERNETES_VERSION=\"#{kubernetes_version}\"/' packaging"
    execute_system_call "sed -E -i -e s/#{existing_k8s_spec}/kubernetes-#{kubernetes_version}/ spec"
  end
end

PksKubernetesRelease::DownloadFromBuildWeb.run(kubernetes_version, bora_number, container_images, binaries, staging_dir)

container_images.each do |image|
  PksKubernetesRelease::ExtractBinariesFromDockerImage.run(kubernetes_version, image, staging_dir, binary_dir)
end

binaries.each do |binary|
  file = binary + "-linux-v#{kubernetes_version}.gz" # "kubelet-linux-v1.17.5+vmware.1.gz",
  initial_executable = file.split(".gz")[0] # kubectl-linux-v1.17.5+vmware.1.gz => kubectl-linux-v1.17.5+vmware.1
  final_executable = file.split("-linux")[0] # kubectl-linux-v1.17.5+vmware.1.gz => kubectl
  execute_system_call "cp #{staging_dir}/#{file} #{binary_dir}"
  execute_system_call "gunzip #{binary_dir}/#{file}"
  execute_system_call "mv #{binary_dir}/#{initial_executable} #{binary_dir}/#{final_executable}"
  execute_system_call "chmod +x #{binary_dir}/#{final_executable}"
end

container_images.each do |binary|
  add_blob(binary, release_dir, binary_dir, kubernetes_version)
end

binaries.each do |binary|
  add_blob(binary, release_dir, binary_dir, kubernetes_version)
end

execute_system_call("cd #{release_dir}; bosh upload-blobs")
