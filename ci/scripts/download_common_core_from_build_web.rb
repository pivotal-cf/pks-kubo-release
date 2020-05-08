#!/usr/bin/env ruby

# First to confluence https://confluence.eng.vmware.com/display/TKG/TKG+Core+v1.17.x
# Second go to build web, then deliverables and download the tar ball e.g.vmware-kubernetes-v1.17.5+vmware.1.tar.gz

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

staging_dir = execute_system_call("mktemp -d")

container_images = [
    "kube-proxy-v1.17.5_vmware.1.tar.gz",
    "kube-apiserver-v1.17.5_vmware.1.tar.gz",
    "kube-scheduler-v1.17.5_vmware.1.tar.gz",
    "kube-controller-manager-v1.17.5_vmware.1.tar.gz",
]

binaries = [
    "kubelet-linux-v1.17.5+vmware.1.gz",
    "kubectl-linux-v1.17.5+vmware.1.gz"
]

container_images.each do |file|
  extract_binaries_from_container_images(file, staging_dir)
end

binaries.each do |file|
  execute_system_call"cp #{file} #{staging_dir}"
  execute_system_call"gunzip #{staging_dir}/#{file}"
end