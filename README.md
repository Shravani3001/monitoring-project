# EC2 Monitoring Project using Prometheus & Grafana

## Project Goal

To set up real-time system monitoring of EC2 instances on AWS using **Prometheus**, **Grafana**, and **Node Exporter**, all provisioned using **Terraform**.  

---

## Tools & Technologies Used

| Tool | Purpose |
|------|---------|
| **Terraform** | Infrastructure provisioning (VPC, EC2, SGs, Key Pair) |
| **AWS EC2** | Hosts the monitoring stack and target application |
| **Prometheus** | Scrapes and stores metrics from servers |
| **Grafana** | Visualizes metrics with dashboards |
| **Node Exporter** | Exports system-level metrics (CPU, RAM, Disk) |

---

## What’s Being Monitored?

- **Monitoring Server** (self-monitoring)
- **App Server** (monitored by Prometheus remotely using Node Exporter)

---

## Terraform Setup

1. **Launches 2 EC2 Instances:**
   - `monitoring_server` → Public, runs Prometheus + Grafana + Node Exporter
   - `app_server` → Public, runs Node Exporter

2. **Creates:**
   - A custom VPC, Subnet, Internet Gateway, Route Table
   - Security Groups with required inbound ports:
     - `22` (SSH)
     - `9090` (Prometheus)
     - `3000` (Grafana)
     - `9100` (Node Exporter)

3. **Outputs:**
   - Public IP of monitoring server
   - Private & Public IP of app server

---

## Pre-Requisites

- Basic understanding of:
  - Terraform (providers, resources, outputs)
  - EC2 concepts: SSH, Public/Private IPs, Key Pairs
  - Linux shell and systemd
  - Prometheus and Grafana usage (basic UI navigation)

---

## Project Overview: Simple Explanation
This project is built to monitor the performance of EC2 servers using popular DevOps monitoring tools: Prometheus and Grafana, deployed with Terraform.

- **We launch two EC2 instances:**

Monitoring Server:
This acts like a monitoring control center. It runs:

Prometheus: To scrape metrics from servers.

Grafana: To visualize those metrics with beautiful dashboards.

Node Exporter: To let Prometheus monitor the monitoring server itself.

App Server:
This simulates a real application server. It runs:

Node Exporter: So that Prometheus can scrape system-level metrics like CPU, RAM, disk, etc.

- **How it works together:**
Node Exporter runs on both servers and exposes system metrics on port 9100.
Prometheus is configured to pull (scrape) metrics from both servers.
Grafana connects to Prometheus and shows charts, graphs, and dashboards.
You view the dashboards from your local browser via the monitoring server’s public IP and port 3000.

## Steps to Run the Project

### ✅ 1. Clone the Repo

```bash
git clone https://github.com/Shravani3001/monitoring-project.git
cd monitoring-project
✅ 2. Generate SSH Key Pair
bash
Copy
Edit
ssh-keygen -t rsa -b 4096 -f monitoring-key
This generates monitoring-key and monitoring-key.pub
Use the public key in Terraform.

✅ 3. Deploy Infrastructure
bash
Copy
Edit
terraform init
terraform apply
Note the IP addresses from the output.

✅ 4. SSH into Monitoring Server
bash
Copy
Edit
ssh -i ./monitoring-key ubuntu@<monitoring_server_public_ip>
✅ 5. Install Prometheus, Grafana, and Node Exporter
- **1. Create a dedicated Prometheus user**
bash
Copy
Edit
sudo useradd --no-create-home --shell /bin/false prometheus
- **2. Create directories for Prometheus**
bash
Copy
Edit
sudo mkdir /etc/prometheus
sudo mkdir /var/lib/prometheus
- **3. Download Prometheus**
bash
Copy
Edit
cd /tmp
curl -LO https://github.com/prometheus/prometheus/releases/download/v2.51.2/prometheus-2.51.2.linux-amd64.tar.gz
- **4. Extract and move binaries**
bash
Copy
Edit
tar xvf prometheus-2.51.2.linux-amd64.tar.gz
cd prometheus-2.51.2.linux-amd64

sudo cp prometheus /usr/local/bin/
sudo cp promtool /usr/local/bin/

sudo cp -r consoles /etc/prometheus
sudo cp -r console_libraries /etc/prometheus
sudo cp prometheus.yml /etc/prometheus
- **5. Set permissions**
bash
Copy
Edit
sudo chown -R prometheus:prometheus /etc/prometheus
sudo chown prometheus:prometheus /usr/local/bin/prometheus
sudo chown prometheus:prometheus /usr/local/bin/promtool
sudo chown -R prometheus:prometheus /var/lib/prometheus
- **6. Create systemd service for Prometheus**
bash
Copy
Edit
sudo nano /etc/systemd/system/prometheus.service
Paste this in:

ini
Copy
Edit
[Unit]
Description=Prometheus
Wants=network-online.target
After=network-online.target

[Service]
User=prometheus
Group=prometheus
Type=simple
ExecStart=/usr/local/bin/prometheus \
  --config.file=/etc/prometheus/prometheus.yml \
  --storage.tsdb.path=/var/lib/prometheus/ \
  --web.console.templates=/etc/prometheus/consoles \
  --web.console.libraries=/etc/prometheus/console_libraries

[Install]
WantedBy=multi-user.target
- **7. Start Prometheus**
bash
Copy
Edit
sudo systemctl daemon-reexec
sudo systemctl daemon-reload
sudo systemctl start prometheus
sudo systemctl enable prometheus
- **8. Check if Prometheus is running**
bash
Copy
Edit
sudo systemctl status prometheus
If status is active (running) ✅, open your browser and check if Prometheus is installed, running, and reachable:

cpp
Copy
Edit
http://<monitoring_server_public_ip>:9090

✅ 6. Install Grafana on the Monitoring Server

Step 1: Install Grafana (Latest)
bash
Copy
Edit
sudo apt-get install -y software-properties-common
sudo add-apt-repository "deb https://packages.grafana.com/oss/deb stable main"
wget -q -O - https://packages.grafana.com/gpg.key | sudo apt-key add -
sudo apt-get update
sudo apt-get install grafana -y
Step 2: Start and Enable Grafana
bash
Copy
Edit
sudo systemctl start grafana-server
sudo systemctl enable grafana-server
Step 3: Check if Grafana is Running
bash
Copy
Edit
sudo systemctl status grafana-server
You should see active (running).

Step 4: Open Grafana in Browser
In your browser, go to:

cpp
Copy
Edit
http://<monitoring_server_public_ip>:3000

Default Login:

Username: admin

Password: admin

You’ll be prompted to change the password after first login.

✅ 7. Install Node Exporter on Both Instances

Step 1: Install Node Exporter on the Monitoring Server
1.1 Download Node Exporter
bash
Copy
Edit
cd /tmp
curl -LO https://github.com/prometheus/node_exporter/releases/download/v1.8.0/node_exporter-1.8.0.linux-amd64.tar.gz
1.2 Extract & Move Binary
bash
Copy
Edit
tar xvf node_exporter-1.8.0.linux-amd64.tar.gz
sudo cp node_exporter-1.8.0.linux-amd64/node_exporter /usr/local/bin/
1.3 Create a Node Exporter user
bash
Copy
Edit
sudo useradd -rs /bin/false node_exporter
1.4 Create a systemd service
bash
Copy
Edit
sudo nano /etc/systemd/system/node_exporter.service
Paste this:

ini
Copy
Edit
[Unit]
Description=Node Exporter
After=network.target

[Service]
User=node_exporter
ExecStart=/usr/local/bin/node_exporter

[Install]
WantedBy=default.target
1.5 Start and Enable Node Exporter
bash
Copy
Edit
sudo systemctl daemon-reload
sudo systemctl start node_exporter
sudo systemctl enable node_exporter
1.6 Verify it’s working
Run:

bash
Copy
Edit
curl http://localhost:9100/metrics
✅ If you see a long list of metrics — it’s working!

Also test from browser (optional):

arduino
Copy
Edit
http://<monitoring_server_public_ip>:9100/metrics

Step 2: Install Node Exporter on the App Server

2.1: SSH into the App Server
Use the app server’s public IP from your Terraform output:

bash
Copy
Edit
ssh -i ./monitoring-key ubuntu@<app_server_public_ip>

2.2: Install Node Exporter on App Server
- **Download Node Exporter**
bash
Copy
Edit
cd /tmp
curl -LO https://github.com/prometheus/node_exporter/releases/download/v1.8.0/node_exporter-1.8.0.linux-amd64.tar.gz
- **Extract and move binary**
bash
Copy
Edit
tar xvf node_exporter-1.8.0.linux-amd64.tar.gz
sudo cp node_exporter-1.8.0.linux-amd64/node_exporter /usr/local/bin/
- **Create Node Exporter user**
bash
Copy
Edit
sudo useradd -rs /bin/false node_exporter
- **Create systemd service**
bash
Copy
Edit
sudo nano /etc/systemd/system/node_exporter.service
Paste this into the file:

ini
Copy
Edit
[Unit]
Description=Node Exporter
After=network.target

[Service]
User=node_exporter
ExecStart=/usr/local/bin/node_exporter

[Install]
WantedBy=default.target
Save and exit (Ctrl+O, Enter, Ctrl+X).

- **Start and enable Node Exporter**
bash
Copy
Edit
sudo systemctl daemon-reload
sudo systemctl start node_exporter
sudo systemctl enable node_exporter
- **Confirm it's running**
bash
Copy
Edit
curl http://localhost:9100/metrics
You should see a long list of metrics ✅

✅ 8. Connect App Server to Prometheus

- **Go back to Monitoring Server and edit prometheus.yml**
bash
Copy
Edit
sudo nano /etc/prometheus/prometheus.yml
Find the existing scrape_configs block (for Prometheus itself), and add another job below it like this:

yaml
Copy
Edit
scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']

  - job_name: 'app-server'
    static_configs:
      - targets: ['10.0.1.12:9100']
⬆️ Replace 10.0.1.12 with your actual app server private IP.

- **Restart Prometheus**
bash
Copy
Edit
sudo systemctl restart prometheus
- **Verify in Browser**
Go to:

arduino
Copy
Edit
http://<monitoring_server_public_ip>:9090/targets
You should see:

localhost:9090 (up)

10.0.X.X:9100 (up)

If both are UP, your Prometheus is successfully monitoring both servers! 

✅ 9. Visualize Metrics in Grafana

- **Add Prometheus as a Data Source in Grafana**
Open Grafana in your browser:
http://<monitoring_server_public_ip>:3000

Open "Data Sources"

Click “Add data source”

Choose “Prometheus” from the list.

In the URL field, enter:

arduino
Copy
Edit
http://localhost:9090
Scroll down and click “Save & Test”

✅ You should see Data source is working.

- **Import a Prebuilt Node Exporter Dashboard**
Open “Import”

In the Import via Grafana.com field, enter this dashboard ID:

yaml
Copy
Edit
1860
This is a very popular Node Exporter dashboard.

Click Load

Choose your Prometheus data source (the one you just added)

Click Import

You’ll now see a full system metrics dashboard!







