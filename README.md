# Azure-Terraform

Used Terraform to deploy an Azure dev environment including a Linux VM with Docker loaded, NIC, public IP and SSH key pair for remote access. Created remote SSH scripts for Windows and Linux and used variables with conditionals to determine which script to use based on client's OS. 

Used this video from FreeCodeCamp.org as a guide
https://www.youtube.com/watch?v=V53AHWun17s

To run
Terraform apply -auto-approve

VM creds
U: adminuser

ssh -i ~/.ssh/id_rsa adminuser@[public ip]

