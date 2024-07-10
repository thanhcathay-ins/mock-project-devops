# Technologies used in project
- Gitea
- Jenkins
- Bastion host
- Prometheus
- Grafana
- MongoDB

# Devops

Application URL: `http://IP:30007/hero`

API for Prometheus: `http://IP:30007/actuator/prometheus`

# Application (EC2 Private)

## Grafana: http://IP:3000

 - Username: admin

 - Password: pass

## Prometheus: http://IP:9090
## Jenkins: name load blancer:8080
## MongoDB: IP:27017
 - Username: root
 - Password: root123

# Application (EC2 Public)
- Gitea : http://IP:3000

# Install
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

