package bosh

import (
	"disk-pressure-watcher/structs"
	"fmt"
	"log"
	"os/exec"
	"sync"
	"time"
)

type RetryConfig struct {
	MaxRetries int
	RetryDelay time.Duration
}

type workKey struct {
	structs.HostName
	structs.Deployment
}

type workState struct {
	mutex sync.RWMutex
	state map[workKey]bool
}

func DefaultRetryConfig() RetryConfig{
	return RetryConfig{
		MaxRetries: 5,
		RetryDelay: time.Second * 10,
	}
}

func retry(queue chan *structs.ErrandParameters, errand *structs.ErrandParameters, retryConfig *RetryConfig) {
	errand.NumAttempts++
	if errand.NumAttempts < retryConfig.MaxRetries {
		go func(){
			select {
			case <- time.After(retryConfig.RetryDelay):
			}
			queue <- errand
		}()
	}
}

func worker(errands chan *structs.ErrandParameters, method func(*structs.ErrandParameters) error, retryConfig *RetryConfig, state workState) {
	for errand := range errands {
		err := method(errand)
		if err != nil {
			log.Printf("Retrying %+v due to %s\n", errand, err)
			retry(errands, errand, retryConfig)
		} else {
			log.Printf("Successfully processed %+v\n", errand)
			state.mutex.Lock()
			delete(state.state, workKey{errand.HostName, errand.Deployment})
			state.mutex.Unlock()
		}
	}
	log.Println("Closing worker")
}

func enqueueController(queue <-chan *structs.ErrandParameters, errands chan<- *structs.ErrandParameters, state workState) {
	for errand := range queue {
		key := workKey{errand.HostName, errand.Deployment}
		state.mutex.RLock()
		if _, ok := state.state[key]; ok {
			log.Printf("Skipping %+v as it is already in queue", errand)
		} else {
			state.state[key] = true
			errands <- errand
		}
		state.mutex.RUnlock()
	}
}

func StartWorkerPool(numWorkers, maxBuffer int, method func(*structs.ErrandParameters) error, retryConfig RetryConfig) chan *structs.ErrandParameters {
	state := workState{
		mutex: sync.RWMutex{},
		state: make(map[workKey]bool),
	}
	queue := make(chan *structs.ErrandParameters, maxBuffer)
	errands := make(chan *structs.ErrandParameters, maxBuffer)
	go enqueueController(queue, errands, state)
	for index := 0; index < numWorkers; index++ {
		go worker(errands, method, &retryConfig, state)
	}
	return queue
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
