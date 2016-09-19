package main

import (
	"errors"
	"os"
	"flag"
	"fmt"
	"regexp"
	"strings"
	"time"

	strfmt "github.com/go-openapi/strfmt"
	httptransport "github.com/go-openapi/runtime/client"
	oclient "github.com/radanalyticsio/oshinko-rest/client"
	"github.com/radanalyticsio/oshinko-rest/client/clusters"
	"github.com/radanalyticsio/oshinko-rest/models"
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

func deleteCluster(client *oclient.OshinkoRest, name string) (error) {
	params := clusters.NewDeleteSingleClusterParams().WithName(name)
	_, err := client.Clusters.DeleteSingleCluster(params)
	return err
}

func getServer() *string {

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
	return &server
}


func main() {

	server := flag.String("server", "", "host:port of the oshinko rest service " +
                              "(optional, normally the service can be determined from the pod environment")
	create := flag.Bool("create", false, "create the specified cluster if it does not already exist")
	delete := flag.Bool("delete", false, "delete the specified cluster")
	flag.Parse()
	if *create && *delete {
		fmt.Println("The -delete flag and -create flag are mutually exclusive")
		os.Exit(-1)
	}
	name := flag.Arg(0)
	if *server == "" {
		server = getServer()
	}

	transport := httptransport.New(*server, "/", []string{"http"})
	c := oclient.New(transport, strfmt.Default)

        cl, err := clusterExists(c, name)
	if err != nil {
		// If it was a 404 ignore it
		if strings.Index(err.Error(), "404") == -1 {
			fmt.Println(err)
			os.Exit(-1)
		}
	}

	if *delete {
		if cl != nil {
			fmt.Println("deleting")
			err := deleteCluster(c, name)
			if err != nil {
				fmt.Println(err)
				os.Exit(-1)
			}
		} else {
			fmt.Println("does not exist")
		}
		os.Exit(0)
	} else {
		if cl != nil {
			fmt.Println("exists")
		} else if *create {
			fmt.Println("creating")
			cl, err = createCluster(c, name)
			if err != nil {
				fmt.Println(err)
			}
		} else {
			fmt.Println("does not exist")
		}
		if cl != nil {
			fmt.Println(*cl.WorkerCount)
			fmt.Println(*cl.MasterURL)
			fmt.Println(*cl.MasterWebURL)
		}
		os.Exit(0)
	}
}
