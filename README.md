# 🐍 Flask on AWS EC2 (Terraform Automated)

![AWS](https://img.shields.io/badge/AWS-EC2-orange?logo=amazon-aws)
![Terraform](https://img.shields.io/badge/Terraform-v1.6+-purple?logo=terraform)
![Flask](https://img.shields.io/badge/Flask-3.0-black?logo=flask)
![Python](https://img.shields.io/badge/Python-3.9+-blue?logo=python)

A fully automated **Flask web application** deployed on **AWS EC2** using **Terraform**.

---

## 🧩 Project Overview

This project demonstrates a production-style deployment pipeline:

* Custom **VPC** with subnet and routing setup
* **EC2 instance** running Flask + Gunicorn + Nginx
* **Terraform** for complete IaC automation
* **Systemd** service for auto-start Flask app

🔗 **Live Demo (after deploy):** `http://<EC2_PUBLIC_IP>`

---

## 🏗️ Architecture

```
User → Internet → AWS EC2 (Nginx → Flask → Gunicorn)
              ↑
           VPC + Security Groups + Elastic IP
```

**Flow:**
Browser → Nginx (Port 80) → Flask App (Port 5000) → JSON Response

---

## 📂 Project Structure

```
terraform-ec2-flask-app/
├── main.tf              # Terraform infra code
├── variables.tf
├── outputs.tf
├── terraform.tfvars
├── app/
│   ├── app.py           # Flask app
│   └── requirements.txt
└── scripts/
    └── user-data.sh     # EC2 startup automation
```

---

## 🖼️ Working Screenshots

* **Web UI:** Flask app homepage with system info
* **Health Endpoint:** `/health` → `{ "status": "healthy" }`

---

## ⚙️ Commands to Deploy

### 1️⃣ Initialize & Validate

```bash
terraform init
terraform validate
```

### 2️⃣ Plan & Apply Infrastructure

```bash
terraform plan
terraform apply -auto-approve
```

### 3️⃣ Get Outputs

```bash
terraform output
```

### 4️⃣ Access App

```bash
# Get public URL
terraform output -raw website_url

# Test endpoints
curl $(terraform output -raw website_url)/health
```

---

## 💻 SSH Access

```bash
ssh -i flask-ec2-key.pem ec2-user@$(terraform output -raw instance_public_ip)
```

Check logs and status:

```bash
sudo systemctl status flask-app
sudo journalctl -u flask-app -f
sudo systemctl status nginx
```

---

## 🧹 Cleanup

```bash
terraform destroy -auto-approve
rm -f flask-ec2-key.pem
```

---

## 👨‍💻 Author

**Riddhesh Ramesh Sutar**
GitHub: [@RiddheshRameshSutar](https://github.com/RiddheshRameshSutar)
LinkedIn: [RiddheshRameshSutar](https://linkedin.com/in/sutarriddhesh22)

---

