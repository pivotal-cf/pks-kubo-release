package generator

import (
	"encoding/base64"
	"encoding/json"
	"fmt"
	"io/ioutil"
	"os"
	"path/filepath"
)

// FileGenerator ...
type FileGenerator struct {
	InputConfigFile   string
	JobName           string
	FilePathGenerator PathGenerator
}

func NewFileGenerator(configFilePath, jobName string, generator PathGenerator) FileGenerator {
	return FileGenerator{
		InputConfigFile:   configFilePath,
		JobName:           jobName,
		FilePathGenerator: generator,
	}
}

func (f FileGenerator) parse() (map[string]string, error) {
	jsonFile, err := os.Open(f.InputConfigFile)
	if err != nil {
		return nil, err
	}
	defer jsonFile.Close()

	byteValue, err := ioutil.ReadAll(jsonFile)
	if err != nil {
		return nil, err
	}

	var flagContentMap map[string]string
	json.Unmarshal(byteValue, &flagContentMap)

	return flagContentMap, nil
}

func (f FileGenerator) writeToDisk(flag, content string) error {
	decodedContent, err := base64.StdEncoding.DecodeString(content)
	if err != nil {
		return fmt.Errorf("expected input format, base64 not met: %s", err)
	}

	flagConfigFile := filepath.Join(f.FilePathGenerator.Generate(f.JobName), flag)
	if err := ioutil.WriteFile(flagConfigFile, decodedContent, 0666); err != nil {
		return err
	}

	return nil
}

func (f FileGenerator) Generate() error {
	flagContentMap, err := f.parse()
	if err != nil {
		return err
	}
	for flag, content := range flagContentMap {
		err = f.writeToDisk(flag, content)
		if err != nil {
			return err
		}
	}
	return nil
}
