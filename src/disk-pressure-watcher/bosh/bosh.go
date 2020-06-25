package bosh

import (
	"disk-pressure-watcher/structs"
	"fmt"
	"log"
	"os/exec"
	"time"
)

func retry(queue chan *structs.ErrandParameters, errand *structs.ErrandParameters, retryDelay time.Duration) {
	errand.NumAttempts++
	if errand.NumAttempts < 5 {
		go func(){
			select {
			case <- time.After(retryDelay):
			}
			queue <- errand
		}()
	}
}

func worker(errands chan *structs.ErrandParameters, method func(*structs.ErrandParameters) error, retryDelay time.Duration) {
	for errand := range errands {
		err := method(errand)
		if err != nil {
			log.Printf("Retrying %+v due to %s\n", errand, err)
			retry(errands, errand, retryDelay)
		} else {
			log.Printf("Successfully processed %+v\n", errand)
		}
	}
	log.Println("Closing worker")
}

func StartWorkerPool(numWorkers, maxBuffer int, method func(*structs.ErrandParameters) error, retryDelay time.Duration) chan *structs.ErrandParameters {
	errands := make(chan *structs.ErrandParameters, maxBuffer)
	for index := 0; index < numWorkers; index++ {
		go worker(errands, method, retryDelay)
	}
	return errands
}

func runMe(command *exec.Cmd) error {
	log.Printf("Running %+v\n", command.String())
	outputBytes, err := command.CombinedOutput()
	if err != nil {
		log.Printf("Error running command: %+v\n%s\n", err, string(outputBytes))
	} else {
		log.Printf("Successfully ran:\n%s\n", string(outputBytes))
	}
	return err
}

func RunErrand(parameters *structs.ErrandParameters) error{
	deployment := string(parameters.Deployment)
	instance := fmt.Sprintf("worker/%s", string(parameters.HostName))
	cmd := exec.Command("bosh", "run-errand", "-d", deployment, "load-images", "--instance", instance)
	return runMe(cmd)
}
