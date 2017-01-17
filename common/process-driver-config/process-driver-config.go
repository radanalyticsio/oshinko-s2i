package main

import (
	"fmt"
	"os"
        "encoding/json"
	"io/ioutil"
	"path/filepath"
)

func main() {
	args := os.Args[1:]
	if len(args) != 1 {
		fmt.Println("error, missing argument")
		os.Exit(-1)
	}
	bytes, err := ioutil.ReadFile(args[0])
	if err != nil {
		fmt.Println(err.Error())
		os.Exit(-1)
	}
	var data map[string]interface{}
	err = json.Unmarshal(bytes, &data)
	if err != nil {
		fmt.Println(err.Error())
		os.Exit(-1)
	}

	if val, ok := data["data"]; ok {
		configs, ok := val.(map[string]interface{})
		if !ok {
			fmt.Println("configmap data is not a set of key/value pairs")
			os.Exit(-1)
		}
		directory := os.Getenv("SPARK_HOME")
		if directory != "" {
			directory = filepath.Join(directory, "conf")
		}
		for k, v := range configs {
			txt, ok := v.(string)
			if ok {
				file, err := os.Create(filepath.Join(directory, k))
				if err == nil {
					fmt.Printf("Writing %s\n", filepath.Join(directory, k))
					file.WriteString(txt)
				} else {
					fmt.Println(err.Error())
					fmt.Printf("Could not write %s\n", filepath.Join(directory, k))
				}
			}
		}
	}
}
