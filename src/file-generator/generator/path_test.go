package generator_test

import (
	. "github.com/onsi/ginkgo"
	. "github.com/onsi/gomega"

	. "file-generator/generator"
)

var _ = Describe("Path Generator", func() {

	var (
		pathGenerator  PathGenerator
		jobName        string
	)

	BeforeEach(func() {
		jobName = "blah"
		pathGenerator = JobFilePathGenerator{}
	})

	It("generates the path where config files should be created", func() {
		jobFilePath := pathGenerator.Generate(jobName)
		Expect(jobFilePath).To(Equal("/var/vcap/jobs/blah/config"))
	})
})
