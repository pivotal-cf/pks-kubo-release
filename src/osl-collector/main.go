package main

import (
	"fmt"
	"os"
	"osl-collector/commands/collect"
	"osl-collector/commands/osm"
	"syscall"
)

func main() {
	allowedCommands := []string{"collect", "osm"}
	sampleCommands := `
./osl-collector -h collect
./osl-collector -folder /var/vcap/packages -outputFile osl_output.json collect
./osl-collector -h osm
`

	command := os.Args[len(os.Args)-1]
	switch command {
	case "collect":
		collect.Collect(collect.GatherFlags())
	case "osm":
		osm.Osm(osm.GatherFlags())
	default:
		fmt.Printf("Invalid command %s.  Please use one of: %+v.\n\nSample commmands:\n%s",
			command,
			allowedCommands,
			sampleCommands,
		)
		syscall.Exit(1)
	}
}
