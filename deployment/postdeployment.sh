#!/bin/bash

echo "Build path: $1"

namespace="framework"

while true; do
    sleep 5
    reportingPodname=`kubectl get pods -n $namespace --field-selector=status.phase=Running | grep "reporting"|awk '{print $1}'`
    if [ -z "$reportingPodname" ]; then 
        echo "waiting for reporting pod"
    else 
        echo "reporting pod is found: $reportingPodname"
        break 
    fi
done

# JMETER REPORTING
echo "Create InfluxDB database"
kubectl exec -i $reportingPodname -n $namespace -- influx -execute 'CREATE DATABASE jmeter'
#Step into the docker/reporter/config folder and execute the following command:
echo "Copy InfluxDB json"
kubectl cp $1/docker/reporter/config/influxdb-datasource.json $namespace/$reportingPodname:/tmp/datasource.json -c reporter
kubectl exec -i $reportingPodname -n $namespace -- /bin/bash -c 'until [[ $(curl "http://admin:admin@localhost:3000/api/datasources" -X POST -H "Content-Type: application/json;charset=UTF-8" --data-binary @/tmp/datasource.json) ]]; do sleep 5; done'
echo "Copy Grafana json"
kubectl cp $1/docker/reporter/config/jmeterDash.json $namespace/$reportingPodname:/tmp/jmeterDash.json -c reporter
kubectl exec -i $reportingPodname -n $namespace -- curl 'http://admin:admin@localhost:3000/api/dashboards/db' -X POST -H 'Content-Type: application/json;charset=UTF-8' --data-binary '@/tmp/jmeterDash.json'

# JMETER K6 LOGS
echo "Create InfluxDB database for K6"
kubectl exec -i $reportingPodname -n $namespace -- influx -execute 'CREATE DATABASE k6db'
echo "Copy InfluxDB json"
kubectl cp $1/docker/reporter/config/influxdb-datasource-k6db.json $namespace/$reportingPodname:/tmp/datasourcek6db.json -c reporter
kubectl exec -i $reportingPodname -n $namespace -- /bin/bash -c 'until [[ $(curl "http://admin:admin@localhost:3000/api/datasources" -X POST -H "Content-Type: application/json;charset=UTF-8" --data-binary @/tmp/datasourcek6db.json) ]]; do sleep 5; done'
echo "Copy Grafana dashboard of K6"
kubectl cp $1/k6/grafana/k6-load-testing-model.json $namespace/$reportingPodname:/tmp/k6.json -c reporter
kubectl exec -i $reportingPodname -n $namespace -- curl 'http://admin:admin@localhost:3000/api/dashboards/db' -X POST -H 'Content-Type: application/json;charset=UTF-8' --data-binary '@/tmp/k6.json'
