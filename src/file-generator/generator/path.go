package generator

import "fmt"

// PathGenerator generates the path where config files need to be created
type PathGenerator interface {
	Generate(jobName string) string
}

type JobFilePathGenerator struct{}

func (j JobFilePathGenerator) Generate(jobName string) string {
	return fmt.Sprintf("/var/vcap/jobs/%s/config", jobName)
}
