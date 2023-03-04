# Introduction
Execute [K6](https://k6.io)-based tests (load, performance and end-to-end) on Azure Kubernetes Service [AKS](https://azure.microsoft.com/en-us/products/kubernetes-service)

---
> [!TIP]
> Scripts are only for demonstrating purposes.


# Architecture 
## Microsoft Azure Services
![Architecture diagram](/media/AzureArch.jpg)
## JMeter Deployment
![Architecture diagram](/media/K6Operator.jpg)

# Getting Started

If you have already an AKS cluster or you would like to provision one from Azure Landing Zone Accelerator (https://azure.github.io/AKS-Construction/) then you should proceed directly with the [2. Manual Installation](#2-manual-installation)

## **1. Installation process**

- User Azure DevOps pipelines to deploy the cluster, build the docker images and install the test framework in fully automated way
    - [deploy-test-framework-JMeter-BICEP](.pipelines/deploy-test-framework-JMeter-BICEP.yml) deploys the AKS cluster, builds and push the images, installs cert-manager and deploys the helm chart on the cluster in one step
    - [deploy-test-framework-JMeter](.pipelines/deploy-test-framework-JMeter.yml) deploys the AKS cluster, builds and push the images, installs cert-manager and deploys the helm chart on the cluster in one step (these pipelines are identical except for the IaC scripts)

## 2. Manual Installation
- Use the ARM template or Bicep template available under the arm and bicep folder to deploy your AKS cluster manually:
    - [Deploy.sh](/bicep/deploy.sh) deploys an AKS cluster based on the pre-defined parameters to your subscription
    - Similar approach can be used to deploy the ARM template if needed
- Deployment script also creates an Azure Managed Grafana Service. In order to grant access to your account or AAD group, you need to query the AAD object id and pass it over a parameter to the deployment script
- Execute [installcertmanager.sh](/deployment/installcertmanager.sh) to install SSL cert management for Application Gateway Ingress Controller
- Execute [deploy_test_framework.sh](/deployment/deploy_test_framework.sh) to deploy the HELM chart containing JMeter, Grafana and InfluxDB
- Execute [postdeployment.sh](/deployment/postdeployment.sh) to install 

## 3. Software dependencies

- Not applicable


## 4. Use-case: K6-based load testing
JMeter uses a master-slave topology to spread test execution among slave nodes:
![Controller-worker](architecture/controller-workers.png)

You can embrace JMeter's master-slave architecture to distribute test script to several JMeter slave pods. Pods are provisioned on demand by just increasing the replicaset of slave deployment:

```bash
#Set replica numbers
kubectl scale --replicas=${{parameters.NumberOfReplicas}} deployment/jmeter-slaves -n ${{variables.namespace}}
kubectl rollout status deployment/jmeter-slaves -n ${{variables.namespace}}
```

Final dashboard with some loads against https://test-api.k6.io/public/crocodiles/  

![Grafana Dashboard K6 Load Testing](media/K6LoadTestingResult.jpg)

To execute tests please have a look at the [start_test.sh](/shell_scripts/start_test.sh)


# **Contribute**
Please feel free to reuse these samples. If you think, there are better approaches to accomplish these jobs, please share with us.
