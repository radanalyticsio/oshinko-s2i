package main

import (
	"errors"
	"os"
	"fmt"
	"regexp"
	"strings"
	"time"

	strfmt "github.com/go-openapi/strfmt"
	httptransport "github.com/go-openapi/runtime/client"
	oclient "github.com/redhatanalytics/oshinko-rest/client"
	"github.com/redhatanalytics/oshinko-rest/client/clusters"
	"github.com/redhatanalytics/oshinko-rest/models"
)

func getCluster(client *oclient.OshinkoRest, name string) (*clusters.FindSingleClusterOK, error) {
	p := clusters.NewFindSingleClusterParams().WithName(name)
	cl, err := client.Clusters.FindSingleCluster(p)
	return cl, err
}


func clusterExists(client *oclient.OshinkoRest, name string) (*models.ClusterModel, error) {
	cl, err := getCluster(client, name)
	if err != nil || cl.Payload.Cluster == nil {
		return nil, err
	}
	return cl.Payload.Cluster, nil
}

func createCluster(client *oclient.OshinkoRest, name string) (*models.ClusterModel, error) {

	var res *models.ClusterModel
	res = nil

	c := models.NewCluster{}
	m := int64(1)
	w := int64(3)
	c.MasterCount = &m
	c.WorkerCount = &w
	c.Name = &name
	params := clusters.NewCreateClusterParams().WithCluster(&c)
	cl, err := client.Clusters.CreateCluster(params)
	if err == nil && cl != nil {
		res = cl.Payload.Cluster
	}

	// Wait for pods to be there
	var i, maxwait int
	maxwait = 120
	for i = 0; i < maxwait; i++ {
		if err != nil || res == nil {
			return nil, err
		}
		if int64(len(res.Pods)) != m + w {
			time.Sleep(time.Second * 1)
		} else {
			break
		}
		res, err = clusterExists(client, name)
		if err != nil {
			return res, err
		}
	}
	if i == maxwait {
		return nil, errors.New("Timed out waiting for pods")
	}
        return res, err
}

func getServer(args []string) string {
	if len(args) > 1 {
		return args[1]
	}

	// Look in the environment for an oshinko rest service
	// All env vars are in the form key=value
	hostip, hostenv, server := "", "", ""
	envars := os.Environ()
	for _, val := range envars {
		tokens := strings.Split(val, "=")
		match, _ := regexp.MatchString("^OSHINKO_REST.*_SERVICE_HOST$", tokens[0])
		if match {
			// We need the specific prefix in case there is more than
			// one rest service because we need to find the matching port
			idx := strings.Index(tokens[0], "_SERVICE_HOST")
			hostenv = tokens[0][0:idx]
			hostip = tokens[1]
			break
		}
	}
	if hostenv != "" {
		portEnv := hostenv + "_SERVICE_PORT"
		for _, val := range envars {
			// Since these are env vars, presence of '=" is guaranteed
			tokens := strings.Split(val, "=")
			if tokens[0] == portEnv {
				server = hostip + ":" + tokens[1]
				break
			}
		}
	}
	return server
}


func main() {

	// Toss the invocation name
	args := os.Args[1:]

	server := getServer(args)

	transport := httptransport.New(server, "/", []string{"http"})
	c := oclient.New(transport, strfmt.Default)

        cl, err := clusterExists(c, args[0])
	if err != nil {
		fmt.Println(err)
	} else if cl == nil {
		fmt.Println("creating")
		cl, err = createCluster(c, args[0])
		if err != nil {
			fmt.Println(err)
		}
	} else {
		fmt.Println("exists")
	}
	if cl != nil {
		fmt.Println(*cl.MasterURL)
		os.Exit(0)
	}
	os.Exit(-1)
}