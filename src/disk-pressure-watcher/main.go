package main

import (
	"context"
	"flag"
	"fmt"
	v1 "k8s.io/api/core/v1"
	"os"
	"path/filepath"
	"time"

	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
	"k8s.io/client-go/kubernetes"
	"k8s.io/client-go/tools/clientcmd"
)

func main() {
	var kubeconfig *string
	if home := homeDir(); home != "" {
		kubeconfig = flag.String("kubeconfig", filepath.Join(home, ".kube", "config"), "(optional) absolute path to the kubeconfig file")
	} else {
		kubeconfig = flag.String("kubeconfig", "", "absolute path to the kubeconfig file")
	}
	flag.Parse()

	// use the current context in kubeconfig
	config, err := clientcmd.BuildConfigFromFlags("", *kubeconfig)
	if err != nil {
		panic(err.Error())
	}

	// create the clientset
	clientset, err := kubernetes.NewForConfig(config)
	if err != nil {
		panic(err.Error())
	}

	//myIP := getIP()

	for {
		nodes, err := clientset.CoreV1().Nodes().List(context.Background(), metav1.ListOptions{
		})
		if err != nil {
			panic(err.Error())
		}

		message := GetLoadImageMessage(nodes.Items)
		fmt.Printf("Triggering message: %+v\n", message)

		time.Sleep(10 * time.Second)
	}
}

type LoadImageMessage struct {
	DeploymentName string
	Instances []string
}

func findDiskPressure(node *v1.Node) *v1.NodeCondition {
	for _, condition := range node.Status.Conditions {
		if condition.Type == "DiskPressure" {
			return &condition
		}
	}
	return nil
}

func GetLoadImageMessage(nodes []v1.Node) *LoadImageMessage {
	affected := make([]*v1.Node, 0)
	for _, node := range nodes {
		condition := findDiskPressure(&node)
		if condition.Status == "True" {
			affected = append(affected, &node)
		}
	}

	if len(affected) != 0 {
		deploymentName := affected[0].Labels["pks-system/cluster.uuid"]
		instances := make([]string, 0)
		for _, node := range affected {
			instances = append(instances, node.Labels["bosh.id"])
		}
		ret := &LoadImageMessage{
			DeploymentName: deploymentName,
			Instances: instances,
		}
		return ret
	}
	return nil
}

func getIP() string {
	// ifconfig eth0 | grep "inet" | cut -d ':' -f 2 | cut -d ' ' -f 1
	return "10.0.10.5"
}

func homeDir() string {
	if h := os.Getenv("HOME"); h != "" {
		return h
	}
	return os.Getenv("USERPROFILE") // windows
}
