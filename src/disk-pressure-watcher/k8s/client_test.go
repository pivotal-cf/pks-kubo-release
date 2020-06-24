package k8s_test

import (
	"disk-pressure-watcher/k8s"
	"testing"
)

func Test_GetNodes_Nil(t *testing.T) {
	var clientSet *k8s.MyClient;
	nodes, err := clientSet.GetNodes()
	if nodes != nil {
		t.Error("Should have received nil back when calling GetNodes() with a nil clientSet.")
	}
	if err == nil {
		t.Error("Should have gotten a meaningful error message when calling GetNodes() with a nil clientSet.")
	}
}
