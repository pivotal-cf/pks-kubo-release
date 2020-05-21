#!/bin/bash
set -ex
# TODO: do we need sshuttle for vsphere?
#GCP
pksbinary="pks-linux-amd64-1.9.0-build.61"
tags='name1:val1, name2:val2,name_without_val'
gen_uuid_command="cat /proc/sys/kernel/random/uuid"
pksip="10.0.0.11"
grepexp="'[^ ]*pks-api-deployment-ha/pks_tls'"

# VSPHERE
pksbinary="pks-darwin-amd64-1.9.0-build.61"
tags='name1:val1, name2:val2'
gen_uuid_command="uuidgen"
pksip="10.87.34.147"
grepexp="'[^ ]*pks-api-deployment/pks_tls'"



gsutil cp gs://pipeline-store/1.9.x/$pksbinary .
chmod +x $pksbinary
echo "$pksip pks.pks-api.example.com" | sudo tee -a /etc/hosts > /dev/null
credhub login --client-name ops_manager --client-secret ei5FlnIvdeE4NQ1G-0eeAF1KLMeCnbOI --server 10.87.34.11:8844 --ca-cert '-----BEGIN CERTIFICATE-----
MIIDUTCCAjmgAwIBAgIVAJyaimg/efNzsGxbSQW9FkdFu/2CMA0GCSqGSIb3DQEB
CwUAMB8xCzAJBgNVBAYTAlVTMRAwDgYDVQQKDAdQaXZvdGFsMB4XDTE5MTAzMTE5
MjcwM1oXDTIzMTEwMTE5MjcwM1owHzELMAkGA1UEBhMCVVMxEDAOBgNVBAoMB1Bp
dm90YWwwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQClaGdZIm5bBlb8
lIJnzEi4RW6ySqxNjAK2efn4k19zTS/0UDrTQm7SC6xCpokY8d/096WuXK2zBkFH
JWvoTuVZkdNjaHbyCnye415oygaViLzETsXoThtSPBWTawtfgchM0HUqdpBjZk54
wJ3jx+0XzQ7d9OATg600ieXz9LthRxz/VRWHD+eZVr0I5JvBcbjHjusFnPJiydPX
+GOiUZ203LPTlwowTY+noLLo20Ka9Umnz4yQsuq/Wr4t2TWtxPdt0ziT718iEuFT
aF2eW2Tn0b3wrRhd5TpdGH9Unu0aWHzmF+6V52kO8aAf3nsFVieAbkStTUN4zD6N
4rGsJfH7AgMBAAGjgYMwgYAwHQYDVR0OBBYEFNLgFwPMY/gvIOiVwAGoYQEgVpiC
MB8GA1UdIwQYMBaAFNLgFwPMY/gvIOiVwAGoYQEgVpiCMB0GA1UdJQQWMBQGCCsG
AQUFBwMCBggrBgEFBQcDATAPBgNVHRMBAf8EBTADAQH/MA4GA1UdDwEB/wQEAwIB
BjANBgkqhkiG9w0BAQsFAAOCAQEAc39B30ns7zlKsjMaBYBpk6h6H/w3d0NtJw81
gCvzlN8TLMgdbPAUjD+mtFIStAqG7xwKHNoTev4CbGEy3nPCbxU/DJNL/cLmcbtH
oZaxfpReg4OnuzejyOUQB/mSRMa1HCIhyOteCvWi2nfVvqcF88Wa9bANdodtQnSn
k/fQTYAZsWQjlA7fS3TL0gOMwxEZ0hYcKn0/hPPVfV+BVLr8KFe+Uwa4vSdjJjHU
fGwViJMb/gUIGJ8042T4KqZc4ymh+f7XKyFfmnfruXRJwbsyfuHpNKQK5ArZBJ3l
hQA+6Z7vQQgtVzArM89uvk89z0YKQOwCJ/mHfR3Rhl4Y6GB2/w==
-----END CERTIFICATE-----'
pksCaCertPath=$(credhub find | grep -o '[^ ]*pks-api-deployment/pks_tls')
credhub get -n $pksCaCertPath > /tmp/certs
bosh int /tmp/certs --path /value/ca > /tmp/pksapi.cert
./$pksbinary login -a pks.pks-api.example.com -u alana -p password --ca-cert /tmp/pksapi.cert
PLAN_NAME='Plan 1'
WORKER_INSTANCES=3
NETWORK_PROFILE_NAME=netprof-upgrade

for index in {1..20}
do
  cluster_name="$($gen_uuid_command).internal"
  echo "creating cluster iteration $index"
  cluster=$(./$pksbinary create-cluster "${cluster_name}" -e "${cluster_name}" -p "${PLAN_NAME}" --network-profile $NETWORK_PROFILE_NAME -n "${WORKER_INSTANCES:-1}" --tags "${tags}" --kubernetes-profile "${K8S_PROFILE_NAME}" --json --wait --non-interactive)
  cluster_uuid=$(echo $cluster | jq -r ".uuid")
  export BOSH_DEPLOYMENT="service-instance_${cluster_uuid}"
  echo "running smoke-tests on $cluster ($cluster_uuid)"
  bosh run-errand smoke-tests
  echo "deleting cluster $cluster"
  ./$pksbinary delete-cluster "${cluster_name}" --wait --non-interactive
done
