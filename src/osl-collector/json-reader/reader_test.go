package json_reader

import "testing"

func TestMyFunction(t *testing.T) {
	myFuncRetVal := MyFunction()
	if !myFuncRetVal {
		t.Errorf("oh no!")
	}
}
