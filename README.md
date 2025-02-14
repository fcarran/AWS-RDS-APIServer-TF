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

# Finding your seat 💺
With infrastructure established in AWS, we need to test connectivity via allowed protocols and ports. In this test scenario, only connections via port 5432 are allowed (PostgreSQL). We could easily open up additional connectivity methods by altering our security groups, but for the sake of speed, we'll keep connections defined as our TF configuration specifies. 

While an initial connection attempt could confirm we have connectivity to a database from outside of AWS, further confirmation via a log in is always appreciated. Hence, the `connectionAPI.py` script.
This script starts with a borrowed function from AWS' Secret Manager, providing us access to the password needed to authenticate against our database. As a future enhancement would be to set the database password as an ENV VAR, or additionally, and preferred for longevity, provisioned via TF.

The script also makes use of Flask, in an attempt to make this script into a service/API that would be called and containerized (as defined by the Dockerfile and requirements.txt).
With the usage of Flask, we can now make use of a continuous stream of status messages as we either make changes to our script (debug) and if an authentication attempt fails, we will see why.
![Python_App](https://github.com/user-attachments/assets/9f9c8c45-79a2-48be-bbaf-d3b886865b3c)

Through the Flask app's provided localhost endpoint, we can then confirm a successful connection and authentication attempt:
![Stutus200](https://github.com/user-attachments/assets/c9150d5e-d635-4ef4-902c-9b62fee7591f)

# Future Enhancements 🔬
- In an a production environment, I'd setup an AWS ECS service to host and deploy the API service/container, rather than a local Docker install. 
- Change database connection hostname to a variable/fetch from TF
- Pass DB password as a variable or provision via SSM and pull from AWS
- Add better documentation/docstrings to python script
- Add health checks to python script via doctests
- Add logging library for better outputs from Flask app/python script
