


# Architect
![](https://github.com/thanhcathay-ins/mock-project-devops/issues/1#issue-2402784393)
# Devops

Application URL: `http://IP:30007/hero`

API for Prometheus: `http://IP:30007/actuator/prometheus`

# Application (EC2 Private)

Grafana: http://IP:3000

 - Username: admin

 - Password: pass

Prometheus: http://IP:9090

Jenkins: ALB:8080

MongoDB: IP:27017
 - Username: root
 - Password: root123

# Application (EC2 Public)
- Gitea : http://IP:3000

# Install
Clone the project

```bash
  git clone https://github.com/thanhcathay-ins/mock-project-devops.git
```

Go to the project directory

```bash
  cd mock-project-devops
```

## Build Ec2
```
cd ./terraform
terraform init
terraform plan
terraform apply
```

### Build Eks
```
cd ./terraform-eks
terraform init
terraform plan
terraform apply
```

## Run ansible

Edit inventory files by server on AWS

```
ansible-playbook playbook.yml
```

