package generator_test

import (
	"encoding/json"
	"fmt"
	"io/ioutil"
	"os"
	"path/filepath"

	. "github.com/onsi/ginkgo"
	. "github.com/onsi/gomega"

	"file-generator/generator"
)

type TestPathGenerator struct{
	DirName string
}

func (t TestPathGenerator) Generate(name string) string {
	os.Mkdir(filepath.Join(t.DirName, name), os.ModePerm)
	return filepath.Join(t.DirName, name)
}

var _ = Describe("File Generator", func() {

	var (
		pathGenerator  generator.PathGenerator
		configFileContent map[string]string
		configFilePath string
		jobName        string

		fileGenPath string
	)

	const (
		encryptionConfig = `---
apiVersion: apiserver.config.k8s.io/v1
kind: EncryptionConfiguration
resources:
  - resources:
	- secrets
	providers:
	- aescbc:
	    keys:
	    - name: key1
	      secret: apBJ4DK47ClZI/P7ETvouFlsZsXLLtEmr8mpzah0VWU=
	- identity: {}
`

		encodedEncryptionConfig = "LS0tCmFwaVZlcnNpb246IGFwaXNlcnZlci5jb25maWcuazhzLmlvL3YxCmtpbmQ6IEVuY3J5cHRpb25Db25maWd1cmF0aW9uCnJlc291cmNlczoKICAtIHJlc291cmNlczoKCS0gc2VjcmV0cwoJcHJvdmlkZXJzOgoJLSBhZXNjYmM6CgkgICAga2V5czoKCSAgICAtIG5hbWU6IGtleTEKCSAgICAgIHNlY3JldDogYXBCSjRESzQ3Q2xaSS9QN0VUdm91RmxzWnNYTEx0RW1yOG1wemFoMFZXVT0KCS0gaWRlbnRpdHk6IHt9Cg=="
		encodedOidcCertificate = "LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSUMrekNDQWVPZ0F3SUJBZ0lVRGsvQnk5QnJHdlliWkluY2hXd2lyYmpTTi9Vd0RRWUpLb1pJaHZjTkFRRUwKQlFBd0RURUxNQWtHQTFVRUF4TUNZMkV3SGhjTk1qQXdNVEUxTURNME9UQXpXaGNOTWpRd01URTFNRE0wT1RBegpXakFOTVFzd0NRWURWUVFERXdKallUQ0NBU0l3RFFZSktvWklodmNOQVFFQkJRQURnZ0VQQURDQ0FRb0NnZ0VCCkFMUjlWNDlzNmpuODdXN1JCVUhPS2lPdkRsRWxvZXBaMzR6V2pmMjBId2lpTjdVdWJrM2Ztbk45RnF4VGtXMDgKV21uNUJMUVU5cjZBSnlBaS9jUHc0OFhWdEJjSEp5ZGtWb0lsNllJazEzNTlPQk42NUIrSFhXNXhMUjdYUVR2ZAp6SU41WHI2NGU2NmVIUEpZVmJLaXZlQ3JRTzBRc2lKaDBRWCtIYWV4TCtFZ0szbVJCSXk2NVlJMmh5NS9CUGplCno0RzkzRUpCU3lXeE13WjJvYXlkdHdGZFZ3ZEl5aDE5QldaSDhHMnBtMllDVFJXZmhEUTJiQnV1UHpLT1UvM3YKb0drT05CbE9wN0ZVd1pzRkhhSS9CQWo4dzBVRk44ZzlrOThlMEpjZUc4TkNmMllSNVQ5R2xLcEQ5d0dTQnRLYQp5Q1JZNVlIemJpYU9LRThiWWg3TWtQa0NBd0VBQWFOVE1GRXdIUVlEVlIwT0JCWUVGRlhJV1BvL25ieDJnWHR3CkhleDcxY2RIdHhXM01COEdBMVVkSXdRWU1CYUFGRlhJV1BvL25ieDJnWHR3SGV4NzFjZEh0eFczTUE4R0ExVWQKRXdFQi93UUZNQU1CQWY4d0RRWUpLb1pJaHZjTkFRRUxCUUFEZ2dFQkFKb0lERGs5UmRMMnh6YWxFWklFR1FreApqbUp3YXFsTzZqazBQUnZ2VzdFQjZyOW0zaThaM1J6VFZCcU5JZGUwT25kU0k1WTg1VjlXaXh5emVITlRhWUlWCis0VGh2RkFFYlhaNnBUQjMxcVJnbk0weURtTmhaRE9oL2crSEpXcitGRWpUZ0FxQ0dObEVaWnhDYWs1TkRtd3YKVXhSRDIvTlFGMVJJR1ZZbzBRbzIxUVRIWnp5dlVFQklJZS95eDlJZEdXRVljT1Y4cE5WcmFLRUs5V3FZUXArWgpmcGtMamVmUDZYYkVPamtsbHdlYTN5eGtSc1JISU5qcWZySW9sc3ZScUZQZ0RNZkIzTVJxQk95UkxvNS9VNnlVClEzVGdmeUdjei9kQktBbUN2QlA5ZGkzSVVRTWJLQkV2SzN2VHM0UGRFUUpqdmlGZnY4cks1dGphK3Z4MS9rND0KLS0tLS1FTkQgQ0VSVElGSUNBVEUtLS0tLQoK"
	)

	generateFileWithContent := func() string {
		bytes, err := json.Marshal(configFileContent)
		Expect(err).ToNot(HaveOccurred())
		text := string(bytes)

		f, err := ioutil.TempFile("", "")
		Expect(err).ToNot(HaveOccurred())
		defer f.Close()
		_, err = fmt.Fprint(f, text)
		return f.Name()
	}

	generateFiles := func() (string, error) {
		configFilePath = generateFileWithContent()
		gen := generator.NewFileGenerator(configFilePath, jobName, pathGenerator)
		err := gen.Generate()
		return fileGenPath, err
	}

	BeforeEach(func() {
		jobName = "kube-apiserver"
		configFileContent = make(map[string]string)
		configFileContent["encryption-provider-config"] = encodedEncryptionConfig

		fileGenPath, _ = ioutil.TempDir("","")
		pathGenerator = TestPathGenerator{
			DirName: fileGenPath,
		}
	})

	Context("successfully creates config files on the disk", func() {

		It("generates an encryption-config file on the disk", func() {
			dirPath, err := generateFiles()
			Expect(err).NotTo(HaveOccurred())

			generatedFilePath := filepath.Join(dirPath, jobName, "encryption-provider-config")
			Expect(generatedFilePath).To(BeAnExistingFile())
		})

		It("generates a config files on the disk", func() {
			configFileContent["oidc-ca-file"] = encodedOidcCertificate
			dirPath, err := generateFiles()
			Expect(err).NotTo(HaveOccurred())

			for _, flag := range []string{"encryption-provider-config", "oidc-ca-file"} {
				generatedFilePath := filepath.Join(dirPath, jobName, flag)
				Expect(generatedFilePath).To(BeAnExistingFile())
			}
		})
	})

	Context("file decoding",func() {

		It("decodes and creates the config file successfully", func() {
			dirPath, err := generateFiles()
			Expect(err).NotTo(HaveOccurred())

			generatedFilePath := filepath.Join(dirPath, jobName, "encryption-provider-config")
			Expect(generatedFilePath).To(BeAnExistingFile())

			decodedContent, err := ioutil.ReadFile(generatedFilePath)
			Expect(err).NotTo(HaveOccurred())
			Expect(string(decodedContent)).To(Equal(encryptionConfig))
		})

		It("throws a user-friendly error if encoded content is incorrect", func() {
			configFileContent["encryption-provider-config"] = "incorrectly-encoded-content"
			_, err := generateFiles()
			Expect(err).To(HaveOccurred())
			Expect(err.Error()).To(MatchRegexp("expected input format, base64 not met.*"))
		})
	})

	Context("empty input file", func() {

		It("does not throw an error", func() {
			configFileContent = map[string]string{}
			_, err := generateFiles()
			Expect(err).NotTo(HaveOccurred())
		})
	})

	Context("program is idempotent", func() {

		It("does not throw an error when run twice", func() {
			configFileContent["oidc-ca-file"] = encodedOidcCertificate
			dirPath, err := generateFiles()
			Expect(err).NotTo(HaveOccurred())

			for _, flag := range []string{"encryption-provider-config", "oidc-ca-file"} {
				generatedFilePath := filepath.Join(dirPath, jobName, flag)
				Expect(generatedFilePath).To(BeAnExistingFile())
			}

			_, err = generateFiles()
			Expect(err).NotTo(HaveOccurred())
		})
	})
})
