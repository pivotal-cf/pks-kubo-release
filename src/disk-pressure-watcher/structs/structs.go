package structs


type HostName string
type Deployment string

type NodeInfo struct {
	HostName
	Deployment
	HasDiskPressure bool
}

type ErrandParameters struct {
	HostName
	Deployment
	NumAttempts int
}
