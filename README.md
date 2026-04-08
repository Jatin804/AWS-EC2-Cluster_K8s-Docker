# AWS CI-CD Pipeline for Flask Web App on Kubernetes

![Build Status](https://img.shields.io/badge/build-passing-brightgreen)
![Platform](https://img.shields.io/badge/platform-AWS-orange)
![Kubernetes](https://img.shields.io/badge/kubernetes-EC2%20Self--Managed-blue)

<center> Its a complete end-to-end Continuous Integration and Continuous Deployment (CI/CD) pipeline project for a Flask web application. This project automates code quality checks, artifact management, containerization, and deployment using jenkins. This is fully deployed and managed within AWS cloud and automated using jenkins pipeline. </center>


---

## 🏗️ Architecture & Pipeline Flow

When a user pushes a code to the repository, the following pipeline is triggered automatically:

1. **SCM Checkout:** Jenkins pulls the latest code.
2. **Unit Testing:** Runs Python/Flask unit tests.
3. **Code Quality Analysis:** SonarQube scans the code for bugs, vulnerabilities, and code smells.
4. **Build & Containerize:** A Docker image of the Flask app is built, every time when new code is deployed and pulled.
5. **Artifact Storage:** The Docker image is pushed to the Nexus Repository Manager.
6. **Deployment:** Jenkins deploys the updated container to the Kubernetes cluster (EC2 Master + Worker nodes).

### Tech Stack
* **Cloud Provider:** AWS (EC2 instances for infrastructure), VPC, and more
* **Application Framework:** Python / Flask
* **Containerization:** Docker
* **Orchestration:** Kubernetes (Self-managed: 1 Master Node and 'n' no. of Worker Nodes)
* **CI/CD Server:** Jenkins - in seprate instance
* **Code Quality:** SonarQube - in seprate instance
* **Artifact Repository:** Sonatype Nexus - in seprate instance

---

## ⚙️ Prerequisites

Before triggering the pipeline or deploying the infrastructure, ensure you have the following:

* An active **AWS Account** with and IAM user.
* **AWS CLI** configured locally with appropriate IAM permissions.
* **kubectl** installed for Kubernetes cluster management.
* **Git** installed locally.

---

## 🛠️ Infrastructure Setup

### 1. Servers (AWS EC2)
You will need to provision the following EC2 instances (Ubuntu/Amazon Linux 2 recommended):
* **Jenkins Server:** (t2.medium / t2.large) - Requires Java and Docker installed.
* **SonarQube Server:** (t2.medium) - Requires Java and PostgreSQL (optional).
* **Nexus Server:** (t2.medium) - Requires Java and Docker installed.
* **Kubernetes Master Node:** (t2.medium / t2.large) - will be Initialized using `kubeadm`.
* **Kubernetes Worker Node(s):** (t2.medium / t2.large) - Joined to the Master node.

### 2. Tool Configuration
* **Jenkins:** * Install plugins: *Git, Docker Pipeline, SonarQube Scanner, Nexus Artifact Uploader, Kubernetes CLI, JDK*.
  * Configure credentials for AWS, Nexus, Docker Registry, and Kubeconfig.
* **SonarQube:**
  * Generate an authentication token for Jenkins.
  * Setup Webhooks to send the Quality Gate status back to Jenkins.
* **Nexus:**
  * Create a Docker Hosted Repository to store the application images.
  * Expose the repository on a specific port.

---

## 🚀 Pipeline Configuration (`Jenkinsfile`)

The pipeline is defined declaratively. Ensure your `Jenkinsfile` is at the root of your repository. 

**Key Stages:**
* `Checkout`: Fetches the main branch.
* `SonarQube Analysis`: Runs `sonar-scanner`. Fails pipeline if Quality Gate fails.
* `Build Image`: Runs `docker build -t flask-app:${BUILD_NUMBER} .`
* `Push to Nexus`: Authenticates with Nexus and pushes the tagged image.
* `Deploy to K8s`: Uses `kubectl apply` with the updated image tag to roll out the new deployment.

---

## ☸️ Kubernetes Deployment

The Kubernetes manifests are located in the `k8s/` directory.

* `deployment.yaml`: Defines the ReplicaSet, Pod template, and the Nexus container image reference.
* `service.yaml`: Exposes the Flask application to the external network (NodePort or LoadBalancer).

**Manual Deployment (for testing):**
```bash
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml