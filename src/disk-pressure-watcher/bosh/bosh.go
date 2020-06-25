package bosh

import (
	"disk-pressure-watcher/structs"
	"fmt"
	"os/exec"
)

func worker(errands chan *structs.ErrandParameters, method func(*structs.ErrandParameters) error) {
	for errand := range errands {
		err := method(errand)
		if err != nil {
			fmt.Printf("Retrying %+v due to %s\n", errand, err)
			errand.NumAttempts++
			if errand.NumAttempts < 5 {
				errands <- errand
			}
		} else {
			fmt.Printf("Successfully processed %+v\n", errand)
		}
	}
	fmt.Println("Closing worker")
}

func StartWorkerPool(numWorkers, maxBuffer int, method func(*structs.ErrandParameters) error) chan *structs.ErrandParameters {
	errands := make(chan *structs.ErrandParameters, maxBuffer)
	for index := 0; index < numWorkers; index++ {
		go worker(errands, method)
	}
	return errands
}

func runMe(command *exec.Cmd) error {
	fmt.Printf("Running %+v\n", command.String())
	outputBytes, err := command.CombinedOutput()
	if err != nil {
		fmt.Printf("Error running command: %+v\n%s\n", err, string(outputBytes))
	} else {
		fmt.Printf("Successfully ran:\n%s\n", string(outputBytes))
	}
	return err
}

func RunErrand(parameters *structs.ErrandParameters) error{
	deployment := string(parameters.Deployment)
	instance := fmt.Sprintf("worker/%s", string(parameters.HostName))
	cmd := exec.Command("bosh", "run-errand", "-d", deployment, "load-images", "--instance", instance)
	return runMe(cmd)
}
