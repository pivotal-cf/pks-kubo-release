package core

import (
	"errors"
	"disk-pressure-watcher/k8s"
	"disk-pressure-watcher/structs"
	v1 "k8s.io/api/core/v1"
)

type Watcher interface {
	GenErrands(clientset k8s.KubeClient) ([]*structs.ErrandParameters, error)
}

type watcherImpl struct {
	internalState map[structs.HostName]bool
}

func GenerateWatcher() Watcher {
	internalState := make(map[structs.HostName]bool)
	return &watcherImpl{
		internalState: internalState,
	}
}

func (w *watcherImpl) GenErrands(clientset k8s.KubeClient) ([]*structs.ErrandParameters, error) {
	if clientset == nil {
		return nil, errors.New("Called GenErrands() with a nil cientset.")
	}

	nodes, err := clientset.GetNodes()
	if err != nil {
		return nil, err
	}

	info := GenerateNodeInfo(nodes)
	ret := make([]*structs.ErrandParameters, 0)

	for _, nodeInfo := range info {
		if nodeInfo.HasDiskPressure {
			w.internalState[nodeInfo.HostName] = true
		} else if val, ok := w.internalState[nodeInfo.HostName]; ok {
			if val {
				//generate errand
				ret = append(ret, &structs.ErrandParameters{
					HostName: nodeInfo.HostName,
					Deployment: nodeInfo.Deployment,
				})
				w.internalState[nodeInfo.HostName] = false
			}
		}
	}

	return ret, nil
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
