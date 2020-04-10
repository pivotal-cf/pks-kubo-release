package etcd_test

import (
	"fmt"
	"tests/test_helpers"

	. "github.com/onsi/ginkgo"
	. "github.com/onsi/gomega"
)

const v2PermissionsErrorMessage = "Insufficient credentials"
const v3PermissionsErrorMessage = "etcdserver: permission denied"

var _ = Describe("Etcd cert on worker", func() {
	var (
		directory string
	)
	Context("for v2", func() {
		Context("For directorys under /coreos.com/network/", func() {
			BeforeEach(func() {
				directory = "/coreos.com/network/"
			})

			AfterEach(func() {
				for _, vm := range workers {
					args := []string{"rm", fmt.Sprintf("%s%s", directory, vm.ID)}
					value := test_helpers.RunEtcdCommandFromMasterWithFullPrivilege(2, deploymentName, master.ID, args...)
					Expect(value).NotTo(ContainSubstring(v2PermissionsErrorMessage))
				}
			})

			It("should have read access ", func() {
				args := []string{"ls", directory}
				for _, vm := range workers {
					value := test_helpers.RunEtcdCommandFromWorker(2, deploymentName, vm.ID, args...)
					Expect(value).NotTo(ContainSubstring(v2PermissionsErrorMessage))
				}

			})

			It("should have write access", func() {
				for _, vm := range workers {
					args := []string{"set", fmt.Sprintf("%s%s", directory, vm.ID), vm.ID}
					value := test_helpers.RunEtcdCommandFromWorker(2, deploymentName, vm.ID, args...)
					Expect(value).NotTo(ContainSubstring(v2PermissionsErrorMessage))
				}

			})
		})

		Context("For directorys under /", func() {
			BeforeEach(func() {
				directory = "/"
			})

			AfterEach(func() {
				for _, vm := range workers {
					args := []string{"rm", fmt.Sprintf("%s%s", directory, vm.ID)}
					value := test_helpers.RunEtcdCommandFromMasterWithFullPrivilege(2, deploymentName, master.ID, args...)
					Expect(value).NotTo(ContainSubstring(v2PermissionsErrorMessage))
				}
			})

			It("should not have read access", func() {
				for _, vm := range workers {
					args := []string{"ls", directory}
					value := test_helpers.RunEtcdCommandFromWorker(2, deploymentName, vm.ID, args...)
					Expect(value).To(ContainSubstring(v2PermissionsErrorMessage))
				}
			})

			It("should not have write access", func() {
				for _, vm := range workers {
					args := []string{"set", fmt.Sprintf("%s%s", directory, vm.ID), vm.ID}
					value := test_helpers.RunEtcdCommandFromWorker(2, deploymentName, vm.ID, args...)
					Expect(value).To(ContainSubstring(v2PermissionsErrorMessage))
				}
			})
		})
	})

	Context("for v3", func() {
		// this is different from v2 because the flannel user is not set up in v2 space, so there should not be any access
		Context("For directories under /coreos.com/network/", func() {
			BeforeEach(func() {
				directory = "/coreos.com/network/"
			})

			AfterEach(func() {
				for _, vm := range workers {
					args := []string{"del", fmt.Sprintf("%s%s", directory, vm.ID)}
					value := test_helpers.RunEtcdCommandFromMasterWithFullPrivilege(3, deploymentName, master.ID, args...)
					Expect(value).NotTo(ContainSubstring(v3PermissionsErrorMessage))
				}
			})

			It("should not have read access ", func() {
				args := []string{"get", "--prefix", directory, "--limit", "2"}
				for _, vm := range workers {
					value := test_helpers.RunEtcdCommandFromWorker(3, deploymentName, vm.ID, args...)
					Expect(value).To(ContainSubstring(v3PermissionsErrorMessage))
				}

			})

			It("should not have write access", func() {
				for _, vm := range workers {
					args := []string{"put", fmt.Sprintf("%s%s", directory, vm.ID), vm.ID}
					value := test_helpers.RunEtcdCommandFromWorker(3, deploymentName, vm.ID, args...)
					Expect(value).To(ContainSubstring(v3PermissionsErrorMessage))
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
					value := test_helpers.RunEtcdCommandFromMasterWithFullPrivilege(3, deploymentName, master.ID, args...)
					Expect(value).NotTo(ContainSubstring(v3PermissionsErrorMessage))
				}
			})

			It("should not have read access", func() {
				for _, vm := range workers {
					args := []string{"get", "--prefix", directory, "--limit", "2"}
					value := test_helpers.RunEtcdCommandFromWorker(3, deploymentName, vm.ID, args...)
					Expect(value).To(ContainSubstring(v3PermissionsErrorMessage))
				}
			})

			It("should not have write access", func() {
				for _, vm := range workers {
					args := []string{"put", fmt.Sprintf("%s%s", directory, vm.ID), vm.ID}
					value := test_helpers.RunEtcdCommandFromWorker(3, deploymentName, vm.ID, args...)
					Expect(value).To(ContainSubstring(v3PermissionsErrorMessage))
				}
			})
		})
	})
})
