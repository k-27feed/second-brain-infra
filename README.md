# Second Brain Infrastructure

This repository contains the infrastructure as code (IaC) for the Second Brain application, using Terraform to provision and manage AWS resources.

## Architecture

The Second Brain application is deployed on AWS with the following components:

- **API**: Node.js application running on EC2 instances
- **Database**: MongoDB database for storing user data
- **Networking**: VPC, subnets, security groups, and other networking components

## Prerequisites

- [Terraform](https://www.terraform.io/downloads.html) (v1.5.7 or later)
- [AWS CLI](https://aws.amazon.com/cli/) configured with appropriate credentials
- [Git](https://git-scm.com/downloads)

## Getting Started

1. Clone this repository:
   ```
   git clone https://github.com/k-27feed/second-brain-infra.git
   cd second-brain-infra
   ```

2. Initialize Terraform:
   ```
   cd terraform
   terraform init
   ```

3. Plan the infrastructure changes:
   ```
   terraform plan -var="db_password=your_secure_password"
   ```

4. Apply the changes:
   ```
   terraform apply -var="db_password=your_secure_password"
   ```

## CI/CD Workflows

This repository includes GitHub Actions workflows for continuous integration and deployment:

- **Terraform Workflow**: Validates, plans, and applies Terraform changes
- **API Workflow**: Builds, tests, and deploys the API to AWS

## Directory Structure

```
second-brain-infra/
├── .github/
│   └── workflows/       # GitHub Actions workflows
├── terraform/
│   ├── main.tf          # Main Terraform configuration
│   ├── variables.tf     # Input variables
│   ├── outputs.tf       # Output values
│   └── modules/         # Reusable Terraform modules
│       ├── api/         # API module
│       ├── database/    # Database module
│       └── networking/  # Networking module
└── README.md            # This file
```

## Contributing

1. Create a new branch for your changes
2. Make your changes and commit them
3. Push your branch and create a pull request
4. Wait for the CI/CD pipeline to validate your changes
5. Request a review from a team member

## License

This project is licensed under the MIT License - see the LICENSE file for details. 