package etcd_test

import (
	"fmt"
	"tests/test_helpers"

	. "github.com/onsi/ginkgo"
	. "github.com/onsi/gomega"
)

var _ = Describe("Etcd cert on worker", func() {
	var (
		directory string
	)

	Context("For directories under /coreos.com/network/", func() {
		BeforeEach(func() {
			directory = "/coreos.com/network/"
		})

		AfterEach(func() {
			for _, vm := range workers {
				args := []string{"del", fmt.Sprintf("%s%s", directory, vm.ID)}
				value := test_helpers.RunEtcdCommandFromMasterWithFullPrivilege(deploymentName, master.ID, args...)
				Expect(value).NotTo(ContainSubstring("Insufficient credentials"))
			}
		})

		It("should have read access ", func() {
			args := []string{"get", "--prefix", directory}
			for _, vm := range workers {
				value := test_helpers.RunEtcdCommandFromWorker(deploymentName, vm.ID, args...)
				Expect(value).NotTo(ContainSubstring("Insufficient credentials"))
			}

		})

		It("should have write access", func() {
			for _, vm := range workers {
				args := []string{"put", fmt.Sprintf("%s%s", directory, vm.ID), vm.ID}
				value := test_helpers.RunEtcdCommandFromWorker(deploymentName, vm.ID, args...)
				Expect(value).NotTo(ContainSubstring("Insufficient credentials"))
			}

		})
	})

	Context("For directories under /", func() {
		BeforeEach(func() {
			directory = "/"
		})

		AfterEach(func() {
			for _, vm := range workers {
				args := []string{"del", fmt.Sprintf("%s%s", directory, vm.ID)}
				value := test_helpers.RunEtcdCommandFromMasterWithFullPrivilege(deploymentName, master.ID, args...)
				Expect(value).NotTo(ContainSubstring("Insufficient credentials"))
			}
		})

		It("should not have read access", func() {
			for _, vm := range workers {
				args := []string{"get", "--prefix", directory}
				value := test_helpers.RunEtcdCommandFromWorker(deploymentName, vm.ID, args...)
				Expect(value).To(ContainSubstring("Insufficient credentials"))
			}
		})

		It("should not have write access", func() {
			for _, vm := range workers {
				args := []string{"put", fmt.Sprintf("%s%s", directory, vm.ID), vm.ID}
				value := test_helpers.RunEtcdCommandFromWorker(deploymentName, vm.ID, args...)
				Expect(value).To(ContainSubstring("Insufficient credentials"))
			}
		})
	})
})
