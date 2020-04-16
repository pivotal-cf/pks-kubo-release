package test_helpers

import (
	"fmt"
	"os/exec"
	"strings"

	. "github.com/onsi/ginkgo"
	. "github.com/onsi/gomega"
	"github.com/onsi/gomega/gexec"
)

const EtcdHostname = "master-0.etcd.cfcr.internal"

func RunEtcdCommandFromWorker(etcdVersion int, deployment, workerID string, args ...string) string {
	// to test manually, this is the combined base command:
	// /var/vcap/packages/etcdctl/etcdctl --endpoints https://master-0.etcd.cfcr.internal:2379 --cert /var/vcap/jobs/flanneld/config/etcd-client.crt --key /var/vcap/jobs/flanneld/config/etcd-client.key --cacert /var/vcap/jobs/flanneld/config/etcd-ca.crt
	remoteArgs := []string{
		fmt.Sprintf("ETCDCTL_API=%d", etcdVersion),
		"/var/vcap/packages/etcdctl/etcdctl",
		fmt.Sprintf("--endpoints https://%s:2379", EtcdHostname),
		getCertFlag(etcdVersion), "/var/vcap/jobs/flanneld/config/etcd-client.crt",
		getKeyFlag(etcdVersion), "/var/vcap/jobs/flanneld/config/etcd-client.key",
		getCacertFlag(etcdVersion), "/var/vcap/jobs/flanneld/config/etcd-ca.crt",
	}
	remoteArgs = append(remoteArgs, args...)
	s := RunSSHWithDeployment(deployment, "worker/"+workerID, fmt.Sprintf("sudo su -c '%s'", strings.Join(remoteArgs, " ")))
	Eventually(s, "20s", "1s").Should(gexec.Exit())
	ss := string(s.Out.Contents())
	return ss
}

func RunEtcdCommandFromMasterWithFullPrivilege(etcdVersion int, deployment, masterID string, args ...string) string {
	// to test manually, this is the combined base command:
	// /var/vcap/packages/etcdctl/etcdctl --endpoints https://master-0.etcd.cfcr.internal:2379 --cert /var/vcap/jobs/etcd/config/etcdctl.crt --key /var/vcap/jobs/etcd/config/etcdctl.key --cacert /var/vcap/jobs/etcd/config/etcdctl-ca.crt
	remoteArgs := []string{
		fmt.Sprintf("ETCDCTL_API=%d", etcdVersion),
		"/var/vcap/packages/etcdctl/etcdctl",
		fmt.Sprintf("--endpoints https://%s:2379", EtcdHostname),
		getCertFlag(etcdVersion), "/var/vcap/jobs/etcd/config/etcdctl-root.crt",
		getKeyFlag(etcdVersion), "/var/vcap/jobs/etcd/config/etcdctl-root.key",
		getCacertFlag(etcdVersion), "/var/vcap/jobs/etcd/config/etcdctl-ca.crt",
	}
	remoteArgs = append(remoteArgs, args...)
	s := RunSSHWithDeployment(deployment, "master/"+masterID, fmt.Sprintf("sudo su -c '%s'", strings.Join(remoteArgs, " ")))
	Eventually(s, "20s", "1s").Should(gexec.Exit())
	ss := string(s.Out.Contents())
	return ss
}

func RunSSHWithDeployment(deploymentName, instance string, args ...string) *gexec.Session {
	nargs := []string{"-d", deploymentName, "ssh", "--opts=-q",
		instance,
	}
	nargs = append(nargs, args...)

	return RunCommand("bosh", nargs...)
}

func RunCommand(cmd string, args ...string) *gexec.Session {
	c1 := exec.Command(cmd, args...)
	session, err := gexec.Start(c1, GinkgoWriter, GinkgoWriter)
	Expect(err).NotTo(HaveOccurred())

	return session
}

func getCertFlag(etcdVersion int) string {
	if etcdVersion == 2 {
		return "--cert-file"
	} else {
		return "--cert"
	}
}

func getKeyFlag(etcdVersion int) string {
	if etcdVersion == 2 {
		return "--key-file"
	} else {
		return "--key"
	}
}

func getCacertFlag(etcdVersion int) string {
	if etcdVersion == 2 {
		return "--ca-file"
	} else {
		return "--cacert"
	}
}