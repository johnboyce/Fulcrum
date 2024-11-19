# Fulcrum

**Fulcrum** is an AWS cloud-based project that leverages DynamoDB, ElastiCache (Redis), Lambda, and API Gateway. The infrastructure is built with Terraform and is deployable to multiple AWS regions. GitHub Actions automate the deployment process to ensure efficient and reliable infrastructure management.

---

## Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Directory Structure](#directory-structure)
- [Setup Instructions](#setup-instructions)
    - [Pre-requisites](#pre-requisites)
    - [Getting Started](#getting-started)
- [Deployment](#deployment)
- [Example API Request](#example-api-request)
- [PlantUML Sequence Diagram](#plantuml-sequence-diagram)

---

## Overview

Fulcrum implements a serverless architecture to manage item data with the following schema:
- **itemNumber**: Unique identifier (Primary Key).
- **timestamp**: Time of data entry (Numeric).
- **status**: Current status of the item.
- **description**: Description of the item.

Key AWS services include:
- **DynamoDB**: For persistent data storage.
- **ElastiCache (Redis)**: For caching frequent queries.
- **Lambda**: To handle API calls.
- **API Gateway**: To provide an HTTP interface for Lambda.

---

## Features

- **Multi-region Deployment**: Supports independent infrastructure deployments for multiple AWS regions.
- **GitHub Actions**: Automates deployment workflows.
- **Serverless**: Cost-effective and highly scalable.
- **Fully Terraform-Managed**: Infrastructure-as-Code (IaC).

---

## Directory Structure

```plaintext
Fulcrum/
│
├── region-a/                # Resources for Region A
│   ├── networking/          # VPC and Subnet configuration
│   ├── dynamodb/            # DynamoDB table
│   ├── redis/               # ElastiCache configuration
│   ├── lambda/              # Lambda function and related files
│   ├── api-gateway/         # API Gateway configuration
│
├── region-b/                # Resources for Region B
│   ├── networking/
│   ├── dynamodb/
│   ├── redis/
│   ├── lambda/
│   ├── api-gateway/
│
├── .github/                 # GitHub workflows for CI/CD
│   ├── workflows/
│       ├── deploy-region-a.yml
│       ├── deploy-region-b.yml
│
└── README.md                # Project documentation
