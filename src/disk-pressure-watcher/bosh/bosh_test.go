package bosh_test

import (
	"disk-pressure-watcher/bosh"
	"disk-pressure-watcher/structs"
	"fmt"
	"github.com/pkg/errors"
	"strconv"
	"strings"
	"sync"
	"testing"
	"time"
)

type resultsHolder struct {
	waitGroup sync.WaitGroup
	mutex sync.Mutex
	errands []*structs.ErrandParameters
}

func (rh *resultsHolder) alwaysSucceed(errand *structs.ErrandParameters) error {
	rh.mutex.Lock()
	rh.errands = append(rh.errands, errand)
	rh.mutex.Unlock()
	rh.waitGroup.Done()
	return nil
}

func (rh *resultsHolder) retryEven(errand *structs.ErrandParameters) error {
	nodeNum := strings.Trim(string(errand.HostName), "node")
	counter, _ := strconv.Atoi(nodeNum)
	rh.mutex.Lock()
	defer func() {
		rh.mutex.Unlock()
		rh.waitGroup.Done()
	}()
	if counter % 2 == 0 && errand.NumAttempts == 0 {
		return errors.New("Retry me!")
	}
	rh.errands = append(rh.errands, errand)
	return nil
}

func (rh *resultsHolder) rejectSeven(errand *structs.ErrandParameters) error {
	nodeNum := strings.Trim(string(errand.HostName), "node")
	counter, _ := strconv.Atoi(nodeNum)
	rh.mutex.Lock()
	defer func() {
		rh.mutex.Unlock()
		rh.waitGroup.Done()
	}()
	if counter == 7 {
		return errors.New("Retry me!")
	}
	rh.errands = append(rh.errands, errand)
	return nil
}

func (rh *resultsHolder) wasProcessed(name structs.HostName, deployment structs.Deployment) bool {
	for _, errand := range rh.errands {
		if errand.HostName == name && errand.Deployment == deployment {
			return true
		}
	}

	return false
}

func generateErrand(index int) *structs.ErrandParameters {
	return &structs.ErrandParameters{
		HostName: structs.HostName(fmt.Sprintf("node%d", index)),
		Deployment: structs.Deployment("deployment"),
	}
}

func waitTimeout(wg *sync.WaitGroup, timeout time.Duration) bool {
	c := make(chan struct{})
	go func() {
		defer close(c)
		wg.Wait()
	}()
	select {
	case <-c:
		return false // completed normally
	case <-time.After(timeout):
		return true // timed out
	}
}

func Test_WorkerPool(t *testing.T) {
	resultsHolder := &resultsHolder{}
	pool := bosh.StartWorkerPool(2, 100, resultsHolder.alwaysSucceed)

	for index := 1; index < 20; index++ {
		resultsHolder.waitGroup.Add(1)
		pool <- generateErrand(index)
	}

	close(pool)

	if waitTimeout(&resultsHolder.waitGroup, time.Second) {
		t.Errorf("Did not complete processing errands in 1 second")
	}

	for index := 1; index < 20; index++ {
		errand := generateErrand(index)
		if !resultsHolder.wasProcessed(errand.HostName, errand.Deployment) {
			t.Errorf("Errand %+v was not processed", errand)
		}
	}
}

func Test_WorkerPool_Retry(t *testing.T) {
	resultsHolder := &resultsHolder{}
	pool := bosh.StartWorkerPool(2, 100, resultsHolder.retryEven)

	for index := 1; index < 20; index++ {
		delta := 1 + ((index + 1) % 2)
		errand := generateErrand(index)
		resultsHolder.waitGroup.Add(delta)
		pool <- errand
	}

	defer close(pool)

	if waitTimeout(&resultsHolder.waitGroup, time.Second) {
		t.Errorf("Did not complete processing errands in 1 second")
	}

	for index := 1; index < 20; index++ {
		errand := generateErrand(index)
		if !resultsHolder.wasProcessed(errand.HostName, errand.Deployment) {
			t.Errorf("Errand %+v was not processed", errand)
		}
	}
}

func Test_WorkerPool_Retry_Delay(t *testing.T) {
	t.Skipf("Not yet implemented")
}

func Test_WorkerPool_Max_Retry_Attempts(t *testing.T) {
	resultsHolder := &resultsHolder{}
	pool := bosh.StartWorkerPool(2, 100, resultsHolder.rejectSeven)

	for index := 1; index < 20; index++ {
		if index != 7 {
			resultsHolder.waitGroup.Add(1)
		} else {
			// TODO make this a var for max retry attempts
			resultsHolder.waitGroup.Add(5)
		}
		pool <- generateErrand(index)
	}

	defer close(pool)

	if waitTimeout(&resultsHolder.waitGroup, time.Second) {
		t.Errorf("Did not complete processing errands in 1 second")
	}

	for index := 1; index < 20; index++ {
		errand := generateErrand(index)
		expected := index != 7
		if resultsHolder.wasProcessed(errand.HostName, errand.Deployment) != expected{
			t.Errorf("Errand %+v was not processed", errand)
		}
	}
}

func Test_WorkerPool_Backing_Data_Structure(t *testing.T) {
	t.Skipf("Not yet implemented")
}
