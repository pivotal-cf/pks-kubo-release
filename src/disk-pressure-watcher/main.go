package main

import (
	"disk-pressure-watcher/bosh"
	"disk-pressure-watcher/core"
	"disk-pressure-watcher/k8s"
	"flag"
	"os"
	"path/filepath"
	"time"
)

// get all nodes
// if diskpressure {
// add to list
// else if in list{
// run errand & remove from list
// }

/*
 ideas for expansion:
    * outer main loop wrap in smoething so we can handle errors instead of panicking
    * should the inner app state be saved anywhere?
    * if something goes in/out of diskpressure too fast, how will we catch it?
    * do we want a catch-all to run the errand every <time period> ?  what is the UX of this?
    * can we check docker caches for the images locally?
 */

func main() {
	var kubeconfig *string
	if home := homeDir(); home != "" {
		kubeconfig = flag.String("kubeconfig", filepath.Join(home, ".kube", "config"), "(optional) absolute path to the kubeconfig file")
	} else {
		kubeconfig = flag.String("kubeconfig", "", "absolute path to the kubeconfig file")
	}
	flag.Parse()

	clientset, err := k8s.CreateKubeClient(*kubeconfig)
	if err != nil {
		panic(err.Error())
	}
	errandChannel := bosh.StartWorkerPool(2, 100, bosh.RunErrand)

	for {
		watcher := core.GenerateWatcher()
		// TODO TODO TODO
		// Handle the error and nil case here better
		commands, _ := watcher.GenErrands(clientset)
		for _, command := range commands {
			errandChannel <- command
		}

		time.Sleep(5 * time.Second)
	}
}

func homeDir() string {
	if h := os.Getenv("HOME"); h != "" {
		return h
	}
	return os.Getenv("USERPROFILE") // windows
}
