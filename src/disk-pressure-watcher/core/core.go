package core

import (
	"disk-pressure-watcher/k8s"
	"disk-pressure-watcher/structs"
	v1 "k8s.io/api/core/v1"
)

type Watcher interface {
	DoStuff(clientset k8s.KubeClient) []*structs.ErrandParameters
}

type watcherImpl struct {
	internalState map[structs.HostName]string
}

func GenerateWatcher() Watcher {
	internalState := make(map[structs.HostName]string)
	return &watcherImpl{
		internalState: internalState,
	}
}

func (w *watcherImpl) DoStuff(clientset k8s.KubeClient) []*structs.ErrandParameters {
	nodes, err := clientset.GetNodes()
	if err != nil {
		panic(err.Error())
	}

	info := GenerateNodeInfo(nodes)
	ret := make([]*structs.ErrandParameters, 0)
	for _, nodeInfo := range info {
		ret = append(ret, &structs.ErrandParameters{
			HostName:   nodeInfo.HostName,
			Deployment: nodeInfo.Deployment,
		})
	}

	return ret
}

func findDiskPressure(node *v1.Node) *v1.NodeCondition {
	for _, condition := range node.Status.Conditions {
		if condition.Type == "DiskPressure" {
			return &condition
		}
	}
	return nil
}

func GenerateNodeInfo(nodeList *v1.NodeList) []*structs.NodeInfo {
	if nodeList == nil {
		return nil
	}
	var ret = make([]*structs.NodeInfo, 0)
	for _, node := range nodeList.Items {
		condition := findDiskPressure(&node)
		info := &structs.NodeInfo{
			HostName:        structs.HostName(node.Labels["bosh.id"]),
			Deployment: structs.Deployment(node.Labels["pks-system/cluster.uuid"]),
			HasDiskPressure: v1.ConditionTrue == condition.Status,
		}
		ret = append(ret, info)
	}
	return ret
}

type NodeInfoArray []*structs.NodeInfo

func (info NodeInfoArray) FindHost(host structs.HostName) *structs.NodeInfo {
	if info == nil {
		return nil
	}
	for _, node := range info {
		if node.HostName == host {
			return node
		}
	}
	return nil
}
