# ShotKube 

A cloud-native deployment and provisioning project for the [Moonshot](https://github.com/ASCN-UM/moonshot) application. Designed with scalability, automation, and observability in mind, this project uses Kubernetes, Ansible, Docker, and Google Cloud to manage deployment pipelines, handle infrastructure provisioning, and execute performance tests in real-world scenarios.

![k8s](https://github.com/user-attachments/assets/43a61a4f-0d53-4c84-b66d-ab9753573eca)

---

## 📌 Overview

- Automate the provisioning and deployment of a multilayer application
- Ensure service availability, scalability, and fault tolerance
- Monitor system performance using real workloads and metrics
- Use modern tools such as Kubernetes, Prometheus, Grafana, Docker, and GCP

---

## 🚀 Deployment

To automate the deployment and testing process on Google Kubernetes Engine (GKE), use the following Ansible playbooks:

---

### 🛠️ Create and Destroy GKE Cluster

```
ansible-playbook -i inventory/gcp.yml gke-cluster-create.yml
# To destroy the cluster
ansible-playbook -i inventory/gcp.yml gke-cluster-destroy.yml
```
----

### 📦 Deploy and Undeploy Moonshot

```
ansible-playbook -i inventory/gcp.yml moonshot-deploy.yml
# To undeploy the application
ansible-playbook -i inventory/gcp.yml moonshot-undeploy.yml
```

---

### 🔬 Run Load Tests

```
ansible-playbook -i inventory/gcp.yml load-test.yml
```

---

### ✅ Execute All Tests (Deployment + Load Testing + Monitoring)

```
ansible-playbook -i inventory/gcp.yml test-all.yml
```

---

## 📊 Metrics

Monitoring plays a crucial role in assessing the health, performance, and resilience of the Moonshot system. This project uses Prometheus to collect metrics and Grafana to visualize them via dashboards.

### Pod-Level Metrics

- **CPU & Memory Usage:** Tracks resource consumption to detect saturation and trigger HPA scaling
- **Network Throughput:** Monitors incoming/outgoing data for bottlenecks and bandwidth usage
- **Storage Usage:** Observes ephemeral and persistent volume usage, ensuring there's no disk exhaustion

| **Metric**     | **Graphic**                      | 
|---------------|----------------------------------|
| **CPU usage**                    | ![pod_cpu](https://github.com/user-attachments/assets/1e16f253-4293-4978-8e78-1beb8a8b131a)                |
| **Memory usage**                 | ![pod_memory](https://github.com/user-attachments/assets/46a9ec2c-12e4-440c-91e4-7ed7706a3538)             |
| **Volume usage**                 | ![pod_volume](https://github.com/user-attachments/assets/11b363c1-fe8f-4fd9-9ba0-205519e83b29)             |
| **Ephemeral storage usage**      | ![pod_ephemeral_storage](https://github.com/user-attachments/assets/58e740eb-e807-420c-abf6-6af3e2993e0e)  |
| **Transmission throughput**      | ![pod_bytes_transmitted](https://github.com/user-attachments/assets/6242b85b-64dc-4865-8cc4-baa03eb93975)  |
| **Reception throughput**         | ![pod_bytes_received](https://github.com/user-attachments/assets/ab88e53c-cd26-45b8-bd58-a6167b8084c0)     |

### Node-Level Metrics

- **Resource Distribution:** Ensures that load is balanced across the Kubernetes nodes
- **CPU & RAM:** Helps determine whether the nodes are over or under-utilized, which informs autoscaling needs

| **Metric**     | **Graphic**                      | 
|---------------|----------------------------------|
| **CPU usage**                    | ![vm_cpu](https://github.com/user-attachments/assets/265829d8-25bc-47a9-ae8c-c47a9e4b66a5)                |
| **Memory usage**                 | ![vm_memory](https://github.com/user-attachments/assets/bf6cf08f-4767-4ac5-ba21-d0ac88b609f9)             |

### Client-Side Metrics (via k6 / JMeter)

- **Request Duration:** Measures latency and responsiveness of the application under different loads
- **Request Rate:** Indicates throughput capacity of the system
- **Failed Requests:** Alerts on system failures and backend unavailability during stress tests

| **Metric**     | **Graphic**                      | 
|---------------|----------------------------------|
| **HTTP overview**              | ![test_2_http_overview](https://github.com/user-attachments/assets/ba509b04-b7f1-4b7c-bbb8-76b5d629eaee)          |
| **HTTP request duration**      | ![test_2_http_request_duration](https://github.com/user-attachments/assets/50173a6c-8963-40d6-96ff-970183ce4a8d)  |
| **HTTP request receiving**     | ![test_2_http_request_receiving](https://github.com/user-attachments/assets/95903e89-2819-4245-813d-730f7e871477) |

### Workload Testing

- **Simple Workload:** Simulates 300 virtual users hitting /api/health to test autoscaling of the application server
- **Complex Workload:** Simulates 20 users performing login and certificate creation, stressing the database and I/O
