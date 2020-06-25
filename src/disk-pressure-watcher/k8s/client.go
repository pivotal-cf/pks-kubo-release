package k8s

import (
	"context"
	"errors"
	v1 "k8s.io/api/core/v1"
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
	"k8s.io/client-go/kubernetes"
	_ "k8s.io/client-go/plugin/pkg/client/auth/oidc"
	"k8s.io/client-go/tools/clientcmd"
)

type KubeClient interface {
	GetNodes() (*v1.NodeList, error)
}

func CreateKubeClient(kubeconfig string) (KubeClient, error) {
	// use the current context in kubeConfig
	config, err := clientcmd.BuildConfigFromFlags("", kubeconfig)
	if err != nil {
		return nil, err
	}

	// create the clientSet
	clientSet, err := kubernetes.NewForConfig(config)
	if err != nil {
		return nil, err
	}

	return &MyClient{
		k8sClient: clientSet,
	}, nil
}

type MyClient struct {
	k8sClient *kubernetes.Clientset
}

func (clientSet *MyClient) GetNodes() (*v1.NodeList, error) {

	if clientSet == nil {
		return nil, errors.New("called GetNodes() on a nil clientSet")
	}

	nodes, err := clientSet.k8sClient.CoreV1().Nodes().List(context.Background(), metav1.ListOptions{})
	return nodes, err
}
