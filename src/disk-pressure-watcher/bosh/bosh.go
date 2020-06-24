package bosh

import (
	"disk-pressure-watcher/structs"
	"fmt"
	"os/exec"
)

func runMe(command *exec.Cmd) {
	fmt.Printf("Running %+v\n", command.String())
	outputBytes, err := command.CombinedOutput()
	if err != nil {
		fmt.Printf("Error running command: %+v\n%s\n", err, string(outputBytes))
	} else {
		fmt.Printf("Successfully ran:\n%s\n", string(outputBytes))
	}
}

func RunErrand(parameters *structs.ErrandParameters) {
	deployment := string(parameters.Deployment)
	instance := fmt.Sprintf("worker/%s", string(parameters.HostName))
	cmd := exec.Command("bosh", "run-errand", "-d", deployment, "load-images", "--instance", instance)
	go runMe(cmd)
}
