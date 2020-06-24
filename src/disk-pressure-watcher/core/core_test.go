package core_test

import (
	"disk-pressure-watcher/core"
	"disk-pressure-watcher/structs"
	v1 "k8s.io/api/core/v1"
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
	"testing"
)

func Test_GenerateNodeInfo_Nil(t *testing.T) {
	info := core.GenerateNodeInfo(nil)

	if info != nil {
		t.Errorf("Should have returned nil for nil input, but got %+v instead", info)
	}
}

func Test_GenerateNodeInfo_EmptyNodeList(t *testing.T) {
	testData := &v1.NodeList{
		Items: []v1.Node{},
	}
	info := core.GenerateNodeInfo(testData)

	if info == nil {
		t.Error("Should not have received nil for empty node list")
	}
	if len(info) != 0 {
		t.Errorf("Should have received zero elements back, but got %d", len(info))
	}
}

func generateTestNode(status v1.ConditionStatus, deploymentName, vmID string) v1.Node {
	labels := make(map[string]string)
	labels["bosh.id"] = vmID
	labels["pks-system/cluster.uuid"] = deploymentName
	return v1.Node{
		Status: v1.NodeStatus{
			Conditions:      []v1.NodeCondition{
				{
					Type:   "DiskPressure",
					Status: status,
				},
			},
		},
		ObjectMeta: metav1.ObjectMeta{
			Labels: labels,
		},
	}
}

func Test_GenerateNodeInfo_HappyCase(t *testing.T) {
	testData := &v1.NodeList{
		Items: []v1.Node{
			generateTestNode("True", "deployment", "node1"),
			generateTestNode("False", "deployment", "node2"),
		},
	}

	info := core.GenerateNodeInfo(testData)

	if info == nil {
		t.Error("Should not have received nil")
		return
	}

	if len(info) != 2 {
		t.Errorf("Should have returned NodeInfo for every node, but got %d instead", len(info))
	}

	node1 := core.NodeInfoArray(info).FindHost("node1")
	node2 := core.NodeInfoArray(info).FindHost("node2")

	if node1 == nil || node1.HostName != "node1" || !node1.HasDiskPressure || node1.Deployment != "deployment" {
		t.Errorf("Wrong node1 returned, should have had hostname node1, deployment deployment, and no diskpressure, but found %+v", node1)
	}
	if node2 == nil || node2.HostName != "node2" || node2.HasDiskPressure || node2.Deployment != "deployment" {
		t.Errorf("Wrong node2 returned, should have had hostname node2, deployment deployment, and diskpressure, but found %+v", node2)
	}
}

func testFindHostData() core.NodeInfoArray {
	return []*structs.NodeInfo{
		{
			HostName:        "validHost",
			HasDiskPressure: false,
		},
		{
			HostName:"pressuredHost",
			HasDiskPressure: true,
		},
	}
}

func Test_FindHost_NilInfo(t *testing.T) {
	var testData core.NodeInfoArray = nil

	searchResult := testData.FindHost("validHost")

	if searchResult != nil {
		t.Errorf("Should have found nil but found %+v", searchResult)
	}
}

func Test_FindHost_WrongHost(t *testing.T) {
	testData := testFindHostData()

	searchResult := testData.FindHost("invalidHost")

	if searchResult != nil {
		t.Errorf("Should not have found a host, but found %+v", searchResult)
	}
}

func Test_FindHost_ValidHost(t *testing.T) {
	testData := testFindHostData()

	searchResult := testData.FindHost("validHost")

	if searchResult == nil {
		t.Error("Should have found validHost")
		return
	}

	if searchResult.HostName != "validHost" {
		t.Errorf("Wrong hostname: %s", searchResult.HostName)
	}
	if searchResult.HasDiskPressure {
		t.Error("Host found should not have disk pressure")
	}
}

func Test_FindHost_PressuredHost(t *testing.T) {
	testData := testFindHostData()

	searchResult := testData.FindHost("pressuredHost")

	if searchResult == nil {
		t.Error("Should have found pressuredHost")
		return
	}

	if searchResult.HostName != "pressuredHost" {
		t.Errorf("Wrong hostname: %s", searchResult.HostName)
	}
	if !searchResult.HasDiskPressure {
		t.Error("Host found should have disk pressure")
	}
}

func Test_GenErrands_Nil(t *testing.T) {
	watcher := core.GenerateWatcher()
	errands, err := watcher.GenErrands(nil)
	if errands != nil {
		t.Error("Should have received a nil return value when calling GenErrands with a nil clientSet.")
	}
	if err == nil {
		t.Error("Should have received a meaningful error message when calling GenErrands with a nil clientSet.")
	}
}

type mockClientSet struct {
	mockData *v1.NodeList
}

func (clientset *mockClientSet) GetNodes() (*v1.NodeList, error) {
	return clientset.mockData, nil
}

func (clientset *mockClientSet) setMockReturnValue (nodes ...v1.Node) {
	clientset.mockData = &v1.NodeList{
		Items: nodes,
	}
}

func Test_GenErrands_NoNodesUnderPressure(t *testing.T) {
	clientset := &mockClientSet{}
	watcher := core.GenerateWatcher()

	clientset.setMockReturnValue(generateTestNode("False", "deployment", "node1"), generateTestNode("False", "deployment", "node2"))
	errands, err := watcher.GenErrands(clientset)

	expect_no_errands(errands, err, t)
}

func expect_errands_and_no_error(errands []*structs.ErrandParameters, err error, t *testing.T) {
	if errands == nil {
		t.Error("Received a nil return value for errands when a non-nil value was expected.")
	}
	if err != nil {
		t.Errorf("Received a non-nil return value for err when a nil value was expected. err received was: %+v", err)
	}
}

func expect_no_errands(errands []*structs.ErrandParameters, err error, t *testing.T) {
	expect_errands_and_no_error(errands, err, t)
	if len(errands) != 0 {
		t.Errorf("Expected an empty array for errands, but instead received %d items.", len(errands))
	}
}

func expect_one_errand(errands []*structs.ErrandParameters, err error, hostname structs.HostName, deployment structs.Deployment, t *testing.T) {
	expect_errands_and_no_error(errands, err, t);
	if len(errands) != 1 {
		t.Errorf("Expected exactly one errand to be returned, instead got %d", len(errands))
		return
	}
	if errands[0].HostName != hostname || errands[0].Deployment != deployment {
		t.Errorf("Expected errand to be about '%s' in deployment '%s' but got: %+v", hostname, deployment, errands[0])
	}
}

func Test_GenErrands_OneNodeUnderPressure(t *testing.T) {
	clientset := &mockClientSet{}
	watcher := core.GenerateWatcher()

	clientset.setMockReturnValue(generateTestNode("True", "deployment", "node1"), generateTestNode("False", "deployment", "node2"))
	errands, err := watcher.GenErrands(clientset)

	expect_no_errands(errands, err, t)

	clientset.setMockReturnValue(generateTestNode("False", "deployment", "node1"), generateTestNode("False", "deployment", "node2"))
	errands, err = watcher.GenErrands(clientset)

	expect_one_errand(errands, err, "node1", "deployment", t)

	errands, err = watcher.GenErrands(clientset)
	expect_no_errands(errands, err, t)
}

func Test_GenErrands_AlternatingDiskPressure(t *testing.T) {
	clientset := &mockClientSet{}
	watcher := core.GenerateWatcher()

	clientset.setMockReturnValue(generateTestNode("True", "deployment", "node1"), generateTestNode("False", "deployment", "node2"))
	errands, err := watcher.GenErrands(clientset)

	expect_no_errands(errands, err, t)

	clientset.setMockReturnValue(generateTestNode("False", "deployment", "node1"), generateTestNode("True", "deployment", "node2"))
	errands, err = watcher.GenErrands(clientset)
	expect_one_errand(errands, err, "node1", "deployment", t)

	clientset.setMockReturnValue(generateTestNode("False", "deployment", "node1"), generateTestNode("False", "deployment", "node2"))
	errands, err = watcher.GenErrands(clientset)
	expect_one_errand(errands, err, "node2", "deployment", t)
}

func Test_GenErrands_TwoNodesUnderPressure(t *testing.T) {
	clientset := &mockClientSet{}
	watcher := core.GenerateWatcher()

	clientset.setMockReturnValue(generateTestNode("True", "deployment", "node1"), generateTestNode("True", "deployment", "node2"))
	errands, err := watcher.GenErrands(clientset)

	expect_no_errands(errands, err, t)

	clientset.setMockReturnValue(generateTestNode("False", "deployment", "node1"), generateTestNode("False", "deployment", "node2"))
	errands, err = watcher.GenErrands(clientset)

	expect_errands_and_no_error(errands, err, t);
	if len(errands) != 2 {
		t.Errorf("Expected exactly two errands to be returned, instead got %d", len(errands))
		return
	}
	// TODO TODO TODO
	// make this not order specific
	if errands[0].HostName != "node1" || errands[0].Deployment != "deployment" {
		t.Errorf("Expected errand to be about node1 in deployment 'deployment' but got: %+v", errands[0])
	}
	if errands[1].HostName != "node2" || errands[1].Deployment != "deployment" {
		t.Errorf("Expected errand to be about 'node2' in deployment 'deployment' but got: %+v", errands[1])
	}
}

func Test_GenErrands_OneNodeExtendedDiskPressure(t *testing.T) {
	clientset := &mockClientSet{}
	watcher := core.GenerateWatcher()

	clientset.setMockReturnValue(generateTestNode("True", "deployment", "node1"), generateTestNode("True", "deployment", "node2"))
	errands, err := watcher.GenErrands(clientset)

	expect_no_errands(errands, err, t)

	clientset.setMockReturnValue(generateTestNode("False", "deployment", "node1"), generateTestNode("True", "deployment", "node2"))
	errands, err = watcher.GenErrands(clientset)

	expect_one_errand(errands, err, "node1", "deployment", t)

	clientset.setMockReturnValue(generateTestNode("False", "deployment", "node1"), generateTestNode("False", "deployment", "node2"))
	errands, err = watcher.GenErrands(clientset)

	expect_one_errand(errands, err, "node2", "deployment", t)
}
