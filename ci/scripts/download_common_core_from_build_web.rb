#!/usr/bin/env ruby

# Make a directory to contain just the downloads
# First to confluence https://confluence.eng.vmware.com/display/TKG/TKG+Core+v1.17.x
# Second go to build web, then deliverables and download the tar ball e.g.vmware-kubernetes-v1.17.5+vmware.1.tar.gz

# cd into directory containing just these downloads
# ruby ~/workspace/pks-kubernetes-release/ci/scripts/download_common_core_from_build_web.rb

require 'fileutils'

def execute_system_call(command)
  puts command
  result = `#{command}`
  puts "...returned #{result}"
  result.strip
end

def extract_binaries_from_container_images(filename, destination_dir)
  puts
  puts "Processing #{filename}"

  remove_extension = filename.split(".tar.gz")[0] # filename = "kube-proxy-v1.17.5_vmware.1.tar.gz"

  parts = remove_extension.split("-v") # filename = "kube-proxy-v1.17.5_vmware.1"
  component = parts[0] # "kube-proxy"
  version_tag = "v" + parts[1] # "v1.17.5_vmware.1"

  command = "docker load -i #{filename}"
  execute_system_call command

  command = "docker image ls --filter 'reference=registry.tkg.vmware.run/#{component}:#{version_tag}' --format '{{.ID}}'"
  image_id = execute_system_call command

  command = "docker create #{image_id}"
  container_id = execute_system_call command

  command = "docker cp #{container_id}:/usr/local/bin/#{component} #{destination_dir}/#{component}"
  execute_system_call command
end

def create_shasum_file(filename, shasumfile)
  result = execute_system_call "shasum #{filename}"
  shasum = result.split(" ")[0]
  File.write(shasumfile, shasum)
end

def create_tarball(staging_dir)
  new_tarfile = "#{staging_dir}/kubernetes-binary-v1.17.5+vmware.1.tar.gz"
  new_shasum_file = "#{staging_dir}/kubernetes-binary-v1.17.5+vmware.1.tar.gz.sha256"

  execute_system_call "tar -czvf #{new_tarfile} -C #{staging_dir} kubernetes-v1.17.5+vmware.1"
  create_shasum_file(new_tarfile, new_shasum_file)
end

def add_blob(binary_name, release_dir, binary_dir, kubernetes_version)
  blob_name = execute_system_call("cd #{release_dir}; bosh blobs --column path | grep '#{binary_name}\\s$' | xargs")
  execute_system_call("cd #{release_dir}; bosh remove-blob '#{blob_name}'")
  execute_system_call("cd #{release_dir}; bosh add-blob '#{binary_dir}/#{binary_name}' 'common-core-kubernetes-#{kubernetes_version}/#{binary_name}'")
end


kubernetes_version = "1.17.5+vmware.1"
release_dir = "/Users/pivotal/workspace/pks-kubernetes-release"

# staging_dir = execute_system_call("mktemp -d")
staging_dir = "/tmp/common-core-1.17.5"


output_dir = staging_dir + "/kubernetes-v1.17.5+vmware.1/"
binary_dir = output_dir + "bin/linux/amd64/"
FileUtils.mkdir_p binary_dir

container_images = [
    "kube-proxy-v1.17.5_vmware.1.tar.gz",
    "kube-apiserver-v1.17.5_vmware.1.tar.gz",
    "kube-scheduler-v1.17.5_vmware.1.tar.gz",
    "kube-controller-manager-v1.17.5_vmware.1.tar.gz",
]

container_binaries = [
    "kube-proxy",
    "kube-apiserver",
    "kube-scheduler",
    "kube-controller-manager",
]

binaries = [
    "kubelet",
    "kubectl"
]

Dir.chdir "#{release_dir}" do
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

container_images.each do |file|
  extract_binaries_from_container_images(file, binary_dir)
end

binaries.each do |binary|
  file = binary + "linux-v1.17.5+vmware.1.gz" #     "kubelet-linux-v1.17.5+vmware.1.gz",
  initial_executable = file.split(".gz")[0] # kubectl-linux-v1.17.5+vmware.1.gz => kubectl-linux-v1.17.5+vmware.1
  final_executable = file.split("-linux")[0] # kubectl-linux-v1.17.5+vmware.1.gz => kubectl
  execute_system_call"cp #{file} #{binary_dir}"
  execute_system_call"gunzip #{binary_dir}/#{file}"
  execute_system_call"mv #{binary_dir}/#{initial_executable} #{binary_dir}/#{final_executable}"
  execute_system_call"chmod +x #{binary_dir}/#{final_executable}"
end

create_tarball(staging_dir)

container_binaries.each do |binary|
  add_blob(binary, release_dir, binary_dir, kubernetes_version)
end

binaries.each do |binary|
  add_blob(binary, release_dir, binary_dir, kubernetes_version)
end

execute_system_call("cd #{release_dir}; bosh upload-blobs")
