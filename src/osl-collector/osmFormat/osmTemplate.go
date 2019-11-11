package osmFormat

import (
	"bytes"
	"log"
	"osl-collector/core/oslStructs"
	"osl-collector/core/osmStructs"
	"text/template"
)

const DefaultRepository = "Other"
const DefaultLocalPath = "/tmp/osl/"

/**
Expected output:
other:autoconf:2.69.0:
  name: autoconf
  version: 2.69.0
  repository: other
  license: GPL2.0
  other-distribution: /tmp/osl/autoconf-2.69.tar.gz
  url: http://ftp.gnu.org/gnu/autoconf/autoconf-2.69.tar.gz
other:automake:1.15.0:
  name: automake
  version: 1.15.0
  repository: Other
  license: GPL2.0
  other-distribution: /tmp/osl/automake-1.15.tar.gz
  url: https://ftp.gnu.org/gnu/automake/automake-1.15.tar.gz
 */
func GenerateYml(packages []oslStructs.OSLPackage) string {
	const localPath = DefaultLocalPath
	const repository = DefaultRepository

	const yamlTemplate = `other:{{.Name}}:{{.Version}}:
  name: {{.Name}}
  version: {{.Version}}
  repository: {{.Repository}}
  license: {{.License}}
  other-distribution: {{.LocalPath}}{{.Filename}}
  url: {{.Url}}
`

	elements := make([]osmStructs.OSMElement, len(packages))
	for index, element := range packages {
		elements[index] = osmStructs.FromOSLPackage(element, repository, localPath)
	}

	executableTemplate := template.Must(template.New("osmTemplate").Parse(yamlTemplate))

	var buf bytes.Buffer
	for _, element := range elements {
		err := executableTemplate.Execute(&buf, element)
		if err != nil {
			log.Fatal("executing template:", err)
		}
	}

	return buf.String()
}
