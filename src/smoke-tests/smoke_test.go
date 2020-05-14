package smoke_tests_test

import (
	"fmt"
	"io/ioutil"
	"math/rand"
	"os/exec"
	"text/template"

	. "github.com/onsi/ginkgo"
	. "github.com/onsi/gomega"

	"github.com/onsi/gomega/gbytes"
	"github.com/onsi/gomega/gexec"
)

var letters = []rune("abcdefghi")

func randSeq(n int) string {
	b := make([]rune, n)
	for i := range b {
		b[i] = letters[rand.Intn(len(letters))]
	}
	return string(b)
}

func curlCaller(endpoint string) func() (string, error) {
	return func() (string, error) {
		cmd := exec.Command("curl", endpoint)
		out, err := cmd.CombinedOutput()
		return string(out), err
	}
}

var _ = Describe("Smoke Tests for pks-kubernetes-release", func() {
	Describe("System Components", func() {
		It("should be healthy", func() {
			command := exec.Command("kubectl", "get", "componentstatuses", "-o", "jsonpath={.items[*].conditions[*].type}")
			session, err := gexec.Start(command, GinkgoWriter, GinkgoWriter)

			Eventually(session, "60s").Should(gexec.Exit(0))
			Expect(err).ToNot(HaveOccurred())
			Expect(session.Out).To(gbytes.Say("^(Healthy )+Healthy$"))
		})
	})

	Context("Deployment", func() {
		var deploymentName string

		BeforeEach(func() {
			deploymentName = randSeq(10)

			type DeploymentReplacement struct {
				Deployment string
			}
			replacement := DeploymentReplacement{deploymentName}

			path := getFixturePath("smoke-test-deployment.yml")
			tmpl, err := template.ParseFiles(path)
			Expect(err).ToNot(HaveOccurred())

			f, err := ioutil.TempFile("fixtures", "templated-deployment")
			Expect(err).NotTo(HaveOccurred())
			Expect(tmpl.Execute(f, replacement)).To(Succeed())
			err = f.Close()
			Expect(err).NotTo(HaveOccurred())

			args := []string{"apply", "-f", f.Name()}
			session := k8sRunner.RunKubectlCommand(args...)
			Eventually(session, "60s").Should(gexec.Exit(0))

			exposeArgs := []string{"expose", "deployment", deploymentName, "--port=8080", "--type=NodePort"}
			session = k8sRunner.RunKubectlCommand(exposeArgs...)
			Eventually(session, "120s").Should(gexec.Exit(0))

			watch := k8sRunner.RunKubectlCommand("rollout", "status", "deployment/"+deploymentName, "-w")
			Eventually(watch, "120s").Should(gexec.Exit(0))
		})

		AfterEach(func() {
			session := k8sRunner.RunKubectlCommand("delete", "deployment", deploymentName)
			Eventually(session, "60s").Should(gexec.Exit(0))
		})

		It("shows the pods are healthy", func() {
			args := []string{"get", "pods", "-l", "app=" + deploymentName, "-o", "jsonpath={.items[:].status.phase}"}
			session := k8sRunner.RunKubectlCommand(args...)
			Eventually(session, "60s").Should(gexec.Exit(0))
			Expect(session.Out).To(gbytes.Say("Running"))
		})

		It("allows commands to be executed on a container", func() {
			args := []string{"get", "pods", "-l", "app=" + deploymentName, "-o", "jsonpath={.items[0].metadata.name}"}
			session := k8sRunner.RunKubectlCommand(args...)
			Eventually(session, "15s").Should(gexec.Exit(0))
			podName := string(session.Out.Contents())

			execArgs := []string{"exec", podName, "--", "/simple-server", "hello", "world", "test", "string"}
			execSession := k8sRunner.RunKubectlCommand(execArgs...)
			Eventually(execSession, "60s").Should(gexec.Exit(0))
			Expect(string(execSession.Out.Contents())).To(ContainSubstring("hello world test string"))
		})

		It("allows access to pod logs", func() {
			args := []string{"get", "pods", "-l", "app=" + deploymentName, "-o", "jsonpath={.items[0].metadata.name}"}
			session := k8sRunner.RunKubectlCommand(args...)
			Eventually(session, "15s").Should(gexec.Exit(0))
			podName := string(session.Out.Contents())

			session = k8sRunner.RunKubectlCommand("get", "nodes", "-o", "jsonpath={.items[0].status.addresses[?(@.type == \"InternalIP\")].address}")
			Eventually(session).Should(gexec.Exit(0))
			nodeIP := session.Out.Contents()

			session = k8sRunner.RunKubectlCommand("get", "svc", deploymentName, "-o", "jsonpath={.spec.ports[0].nodePort}")
			Eventually(session).Should(gexec.Exit(0))
			port := session.Out.Contents()

			endpoint := fmt.Sprintf("http://%s:%s", nodeIP, port)
			Eventually(curlCaller(endpoint), "5s").Should(ContainSubstring("Server: simple-server"))

			getLogs := k8sRunner.RunKubectlCommand("logs", podName)
			Eventually(getLogs, "15s").Should(gexec.Exit(0))
			logContent := string(getLogs.Out.Contents())

			Expect(logContent).To(ContainSubstring("curl"))
		})

		Context("Port Forwarding", func() {
			var cmd *gexec.Session
			var port = "57869"

			BeforeEach(func() {
				args := []string{"get", "pods", "-l", "app=" + deploymentName, "-o", "jsonpath={.items[0].metadata.name}"}
				session := k8sRunner.RunKubectlCommand(args...)
				Eventually(session, "15s").Should(gexec.Exit(0))
				podName := string(session.Out.Contents())

				args = []string{"port-forward", podName, port + ":8080"}
				cmd = k8sRunner.RunKubectlCommand(args...)
			})

			AfterEach(func() {
				cmd.Terminate().Wait("15s")
			})

			It("successfully curls the simple-server service", func() {
				Eventually(curlCaller("http://localhost:"+port), "15s").Should(ContainSubstring("Server: simple-server"))
			})
		})
	})
})
