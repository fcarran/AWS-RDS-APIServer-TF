# Project Summary
Using TF, provision infrastructure (RDS) within a cloud provider (AWS) and confirming it's availability via an API service that has been containerized 🐳

# Setting the table 🍽️
Any and all infrastructure is provisioned via Terraform blocks, checked in and managed in Git. This allows for infrastructure changes to abstracted away from manual intervention, preventing small mistakes. There is also an added benefit of quick recovery in the event of disaster. Infrastructure is provisioned within AWS, and executed via credentials and settings set during awscli configuration in `~/.aws`.

The core component provisioning our database can be seen in this block:
![RDS_Provision](https://github.com/user-attachments/assets/7375e889-6f8e-4c80-9d53-273e84cff88a)
![AWS-RDS](https://github.com/user-attachments/assets/e0100343-0389-4aae-a551-e6bb44cc365a)

There are references to other components the database will need, like password generation, cloud provider settings such as VPC, subnet, security groups, that can be found throughout the rds definition file.

The environment layout can be illustrated as the following:
<img width="878" alt="env-view" src="https://github.com/user-attachments/assets/12d167bc-618e-46fe-a780-cd584cda03e9" />

Network access to the newly provisioned instance is also defined via Terraform configuration file, but for testing purposes, will be left open to access only via port 5432.
