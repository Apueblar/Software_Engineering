# ☁️ Cloud Programming — Exam Study Guide
> Lectures 1–10 | Wrocław University of Science and Technology (W04IST-SI0826G)

---

## 📋 Table of Contents
1. [Cloud Computing Basics](#1-cloud-computing-basics)
2. [Cloud Providers](#2-cloud-providers)
3. [Docker & Containers](#3-docker--containers)
4. [AWS Ecosystem (VPC & Networking)](#4-aws-ecosystem-vpc--networking)
5. [Infrastructure as Code (IaC) — Terraform Basics](#5-infrastructure-as-code-iac--terraform-basics)
6. [Terraform Advanced — Configuration](#6-terraform-advanced--configuration)
7. [AWS Services Overview (XaaS, EC2, S3, RDS)](#7-aws-services-overview-xaas-ec2-s3-rds)
8. [Identity and Access Management (IAM)](#8-identity-and-access-management-iam)
9. [Containers on AWS: ECR and ECS (Part 1)](#9-containers-on-aws-ecr-and-ecs-part-1)
10. [ECS Networking, IAM, and Observability (Part 2)](#10-ecs-networking-iam-and-observability-part-2)
11. [Serverless Computing with AWS Lambda](#11-serverless-computing-with-aws-lambda)
12. [Asynchronous Messaging: SQS, SNS, and EventBridge](#12-asynchronous-messaging-sqs-sns-and-eventbridge)

---

## 1. Cloud Computing Basics

### Definition
Cloud computing is the **on-demand delivery of IT resources over the Internet with pay-as-you-go pricing**. Instead of owning physical hardware, you access computing power, storage, and databases from a cloud provider.

### Why Cloud?
- Scalability (handle traffic spikes)
- Cost efficiency (pay only for what you use)
- Innovation speed
- Flexibility & multiple service offerings

### Types of Cloud

| Type | Description |
|------|-------------|
| **Public Cloud** | Owned and managed by providers (AWS, Azure, GCP). Users don't buy hardware. Maintained by provider. |
| **Private Cloud** | Dedicated to a single organization. Can be managed internally or outsourced. |
| **Hybrid Cloud** | Combines private cloud with public cloud services. Private cloud cannot exist alone — companies access public resources for daily tasks. |

### Key AWS Services (Intro)

**Amazon EC2 (Elastic Cloud Compute)**
- Rent virtual computers to run your own applications
- Scalable, pay per second
- Users control geographic location of instances

**Amazon S3 (Simple Storage Service)**
- Storage via a web service interface
- Stores any type of object up to **5 TB** each
- Objects stored in **buckets**
- Standardized REST and SOAP interfaces, default protocol HTTP

---

## 2. Cloud Providers

### Top 10 Cloud Providers (by regions)

| # | Provider | Regions | Availability Zones |
|---|----------|---------|-------------------|
| 1 | Amazon Web Services (AWS) | 26 | 84 |
| 2 | Microsoft Azure | 60 | 116 |
| 3 | Google Cloud Platform (GCP) | 34 | 103 |
| 4 | Alibaba Cloud | 27 | 84 |
| 5 | Oracle Cloud | 38 | 46 |
| 6 | IBM Cloud (Kyndryl) | 11 | 29 |
| 7 | Tencent Cloud | 21 | 65 |
| 8 | OVHcloud | 13 | 33 |
| 9 | DigitalOcean | 8 | 14 |
| 10 | Linode (Akamai) | 11 | 11 |

**Market share (Q4 2021):** AWS ~33%, Azure ~21%, GCP ~10%, Alibaba ~6%, IBM ~4%

### Price Comparison (2vCPU, 4GB RAM, 80GB SSD / month)

| Provider | Cost/Month | % vs cheapest |
|----------|-----------|---------------|
| Alibaba Cloud | $48.42 | — |
| Google Cloud | $63.38 | 31% |
| Microsoft Azure | $70.05 | 45% |
| AWS | $71.47 | 48% |

### Cloud vs VPS — When to Choose What?

**Choose Cloud when:**
- Extensive tech knowledge; need to customize servers
- Unpredictable traffic spikes
- Growing application needing scalable hosting

**Choose VPS when:**
- Small app with predictable traffic
- Sufficient technical knowledge for VPS management
- Concerned about malicious attacks

---

## 3. Docker & Containers

### What is Docker?
A software platform for **automating deployment, scaling, and management of applications through containerization**. Packages applications with their dependencies into isolated **containers** that run uniformly across any system.

### Docker Key Benefits
- **Portability** — runs consistently across environments (dev laptop → production server)
- **Speed & Flexibility** — containers launch almost instantaneously
- **Application Isolation** — reduces dependency conflicts
- **Resource Optimization** — shares OS kernel, lighter than VMs

### Container vs Virtual Machine

| Feature | Container | Virtual Machine |
|---------|-----------|----------------|
| OS Kernel | Shares host OS kernel | Has its own OS |
| Hardware emulation | No | Yes (via hypervisor) |
| Startup time | Near-instant | Slow |
| Resource usage | Lightweight | Heavy |
| Isolation | Process-level | Full hardware-level |

### Hypervisor Types
- **Type 1 (bare-metal):** Runs directly on hardware (VMware ESXi, Microsoft Hyper-V)
- **Type 2 (hosted):** Runs on host OS (Oracle VirtualBox, VMware Workstation)

### Docker Image
- A read-only template containing **everything needed to run an application** (dependencies, configs, scripts, binaries)
- Consists of **layers**: base OS → runtime (Java/Python) → application
- Built from a **Dockerfile**

### Dockerfile
A plain text file (no extension) containing instructions to build a Docker image.

**Key instructions:**

| Instruction | Purpose |
|------------|---------|
| `FROM` | Specifies the base image |
| `RUN` | Executes commands in a new layer |
| `COPY` / `ADD` | Copies files into the image |
| `WORKDIR` | Sets the working directory |
| `CMD` | Default command when container launches |
| `EXPOSE` | Declares port the container listens on |
| `ENV` | Sets environment variables |

**Base image options:**
- "Bare" OS (Ubuntu, Alpine) — must manually install tools
- Pre-built image (e.g., `node:alpine`) — tools pre-installed, smaller Dockerfile

**.dockerignore** — works like `.gitignore`, excludes files from the image to reduce size

### Docker Image Lifecycle
```
create → [Created] →start→ [Running] →pause→ [Paused]
                ↑                    ←unpause←
              start                  
                ↑         stop↓
            [Stopped] ←rm← [Deleted]
```

### Basic Docker Commands

| Command | Description |
|---------|-------------|
| `docker build PATH\|URL` | Build image from Dockerfile |
| `docker create --name <name> <image>` | Create container (doesn't start it) |
| `docker start <name>` | Start a stopped container |
| `docker run <name>` | Pull image + create + start (combined) |
| `docker pause / unpause <name>` | Freeze/unfreeze all processes in container |
| `docker stop <name>` | Gracefully stop a running container |
| `docker kill <name>` | Immediately stop a container |
| `docker rm <name>` | Remove a stopped container |

### Docker Volumes
- **Persistent data storage** that survives container deletion/restart
- Can be shared between multiple containers
- Commands: `docker volume create`, `docker volume ls`, `docker volume inspect`, `docker volume rm`
- Usage: `docker run -v my_volume:/app/data my_image`

### DockerHub
- Cloud service for **sharing and managing Docker image repositories**
- Official image hub for Docker (public + private repositories)
- Integration with GitHub/Bitbucket for **automatic builds**
- **Image versioning** (tags) for version management and rollbacks

### Docker Compose
- Tool for defining and running **multi-container** Docker applications using YAML files
- Configures services, networks, and volumes in a single file
- **Automatically creates networks** between containers

### Container Management
- **Orchestration** — automated deployment, scaling, state management of multiple containers
- **Tools:** Docker Swarm, Kubernetes, OpenShift, Amazon ECS/AKS/GKE

### Docker Image Optimization
- Use **lightweight base images** (Alpine Linux)
- Prefer **official images** from Docker Hub
- Minimize layer count — chain `RUN` commands with `&&`
- Clean up unnecessary files in the same `RUN` that installs them
- Use **`.dockerignore`** to exclude unneeded files
- Use **multi-stage builds** to separate build and runtime environments
- Install only necessary packages

### Container Security
- Store sensitive data in **environment variables**, not in the image
- `docker run -e "PASSWORD=myPassword" application`

---

## 4. AWS Ecosystem (VPC & Networking)

### VPC (Virtual Private Cloud)
Lets you run AWS resources in a **fully configurable virtual network**.

### Subnets
Divide a VPC into smaller, isolated sections.

| Subnet Type | Hosts |
|------------|-------|
| **Public** | Resources needing Internet access (web servers, load balancers) |
| **Private** | Resources NOT needing direct Internet access (databases, back-end servers) |

**Why use subnets?**
- Network traffic segregation
- Increased security & isolation
- Logical grouping of resources
- Better performance (traffic optimization)
- Compliance with security policies

### Route Tables
Sets of rules (routes) that determine **how network traffic is directed** within VPC.
- Every VPC has a **default route table**
- Each subnet must be associated with a route table
- Enable traffic to: Internet Gateway, NAT Gateway, VPN Gateway, other VPCs (peering)

### Internet Gateway
VPC component that enables **communication between VPC resources and the Internet**.
- Required for public subnets to send/receive Internet traffic
- Works with route tables to define which subnets have Internet access
- **Automatically scalable**, highly available (redundant)

### NAT Gateway
Enables instances in **private subnets to access the Internet** without exposing their private IP addresses.
- Instances can **initiate outbound** connections but **cannot receive inbound** connections from the Internet
- AWS-managed service (handles scaling, management, maintenance automatically)
- Auto-scaled and redundant within an Availability Zone

### Security Groups
Virtual **stateful firewalls** controlling incoming and outgoing traffic to VPC resources.
- Define rules by protocol (TCP/UDP/ICMP), port, and source/destination IP
- **Stateful** — if inbound traffic is allowed, return traffic is automatically allowed
- Assigned to EC2 instances and other resources
- One instance can have **multiple** Security Groups; changes apply **immediately**

### Network ACLs (Access Control Lists)
Additional security layer at the **subnet level**.

| Feature | Security Groups | Network ACLs |
|---------|----------------|--------------|
| Level | Instance | Subnet |
| State | Stateful | Stateless |
| Rules | Allow only | Allow and Deny |
| Rule order | All rules evaluated | Lowest number first |

**Key features:**
- Inbound and Outbound rules
- **Stateless** — separate rules needed for each direction
- Default ACL allows all traffic
- Rules numbered; lowest number processed first

### VPC Peering
Enables **private connection between two different VPCs** (same or different AWS regions).
- Resources in one VPC communicate with the other as if on the same network
- Data stays within AWS infrastructure (no public Internet)
- **Low latency, high throughput**
- Use cases: connecting production/test environments, shared services, distributed databases

### Amazon Direct Connect
Dedicated **private network connection** between on-premises data center and AWS.
- Bypasses public Internet → minimizes latency and fluctuations
- Predictable performance, stable bandwidth
- Lower data transfer costs vs. Internet
- Bandwidth: 50 Mbps to 10 Gbps+

---

## 5. Infrastructure as Code (IaC) — Terraform Basics

### What is IaC?
**Management and sharing of infrastructure through code** instead of manual processes.
- Configuration files describe infrastructure specs
- Same environment created every time (reproducible)
- Supports version control (treat configs like source code)
- Reduces errors and manual configuration

### Terraform
- One of the **most popular IaC tools**
- Uses **HashiCorp Configuration Language (HCL)** or JSON
- Open-source, supports all major cloud platforms
- Multi-cloud (unlike CloudFormation which is AWS-only)

### CloudFormation (AWS-specific IaC)
- Works **only for AWS**, fully integrated
- Uses YAML and JSON
- Offers **rollback** (restore to previous state)
- Competitors: Google Cloud Deployment Manager, Azure Resource Manager

### Terraform Workflow

```
terraform init → terraform plan → terraform apply → terraform destroy
```

### `terraform init`
Initializes a Terraform project:
1. **Downloads providers** — plugin downloads listed in config
2. **Creates `.terraform` directory** — stores provider plugins and temp files
3. **Sets up backend** — configures remote state storage
4. **Initializes state** — creates new state file or connects to existing one

### Terraform State
A **record of the current configuration and properties** of all resources managed by Terraform.
- Maps Terraform config resources to actual cloud resources
- Stored in **`terraform.tfstate`** (JSON format)
- Contains: resource identifiers, resource attributes, dependencies between resources

**Why it matters:**
- Avoids conflicts between team members
- Terraform only changes what's **actually needed** (no full recreation)
- Used to display output values after applying

**Storage options:**
- **Locally** (default) — `terraform.tfstate` in working directory; suitable for individual projects
- **Remotely** (recommended for teams) — AWS S3, Google Cloud Storage, Azure Blob Storage
  - Better access management, security, change history

**Best practices:**
- Never manually edit state files
- Regularly review and back up state files
- Use state **locking** to prevent simultaneous modifications
- Use version management (S3 with versioning)

### `terraform plan`
- Analyzes differences between **current state** and **desired config**
- Generates an **action plan** showing what will be created/modified/deleted
- Does NOT make any changes — preview only
- Benefits: security review, accuracy, documentation of planned changes

### `terraform apply`
- Executes the changes in the infrastructure
- First generates a plan and asks for **user approval**
- After approval: creates, modifies, or deletes resources
- Updates state file upon completion

### `terraform destroy`
- **Removes ALL resources** described in Terraform config that were created by `apply`
- Asks for confirmation before executing
- Updates state file after completion
- Use `-target` flag to destroy specific resources: `terraform destroy -target=aws_instance.my_instance`

**Use cases:** releasing unused infrastructure, cleaning test environments, cost management

> ⚠️ **Caution in production!** Always verify what will be destroyed before confirming.

---

## 6. Terraform Advanced — Configuration

### Configuration Files
- Written in **HCL** (HashiCorp Configuration Language) or JSON
- Have a **`.tf` extension**
- Can be grouped in directories
- Organized into **blocks**

### AMI (Amazon Machine Image)
A **ready-to-use virtual machine image** for quickly launching EC2 instances.
- Contains: OS, server software (pre-configured), settings and configurations
- Different AWS regions may have **different AMI IDs** for the same software

### Key Block Types

#### `resource` Block
Defines resources to be managed by Terraform.
```hcl
resource "aws_instance" "example" {
  ami           = "ami-06dd92ecc74fdfb36"
  instance_type = "t2.micro"
}
```
- `aws_instance` = resource type
- `"example"` = resource name (identifier within project)
- `ami` = Amazon Machine Image ID
- `instance_type` = EC2 instance type

#### `provider` Block
Specifies the cloud service provider Terraform will interact with.
```hcl
provider "aws" {
  region  = "eu-central-1"
  profile = "my-aws-profile"
  version = "~> 2.0"
}
```
- Supported: AWS, Azure, GCP, DigitalOcean, VMware, and many more
- Multiple providers can be used in one project
- Must be initialized with `terraform init`

#### `module` Block
Used to reference reusable, standalone pieces of Terraform code.
```hcl
module "example_ec2_instance" {
  source        = "./modules/ec2_instance"
  instance_type = "t2.micro"
  ami_id        = "ami-0c55b159cbfafe1f0"
}
```

#### `variable` Block
Defines input variables to parametrize configuration.

#### `output` Block
Returns information about created resources.

### Modules
**Reusable containers for Terraform resources** that group related infrastructure into logical units.

**Benefits:**
- Avoid code duplication
- Easier management of complex configurations
- Promote code reusability
- Simplify version control and updates

**Module structure:**
```
web-app/
├── main.tf
├── variables.tf
├── modules/
│   └── child_module/
│       ├── child_module.tf
│       └── variables.tf
```

**How to use:**
- Define by creating a new directory with `.tf` files
- Reference with a `module` block specifying `source` path
- Accept **input parameters** (variables) and return **output values**
- Available publicly in the **Terraform Module Registry**

**Best practices:**
- Document each module (purpose, inputs, outputs)
- Each module = one logical infrastructure part
- Use **versioning** for shared modules

### Variables

**Purpose:** Store values used in multiple places; allow parametrization without changing code.

**Types:** `string`, `number`, `bool`, `list`, `map`, `object`

**Variable block elements:**
```hcl
variable "region" {
  type        = string
  description = "The AWS region where resources will be created"
  default     = "eu-central-1"
  validation {
    condition     = length(var.region) > 0
    error_message = "The region variable must not be empty."
  }
}
```

**Setting variable values (priority order):**
1. `-var` flag on command line
2. `terraform.tfvars` file
3. Environment variables
4. Default value in declaration

**Variable Validation types:**
- Value range (min/max for numbers, allowed strings)
- String format (regex — email, UUID, etc.)
- String length
- List/map content verification

**Advantages:** Flexibility, readability, reusability across modules/projects

### Locals
**Local variables** available only within a specific config file or module.
```hcl
locals {
  common_tags = {
    Owner = "devops team"
  }
}
```

### Locals vs Variables

| Feature | Locals | Variables |
|---------|--------|-----------|
| Scope | Single file/module only | Entire project, passed between modules |
| Modification | Cannot be changed via CLI or `.tfvars` | Can be changed via CLI, `.tfvars`, env vars |
| Default values | Not possible | Possible |
| Validation | Not possible | Possible |
| User interaction | None | Users often provide values |
| Use case | Simplify code, improve readability | Cross-environment configs, user customization |

### Outputs
**Return information about created resources** after applying configuration.
```hcl
output "instance_ip" {
  value       = aws_instance.my_instance.public_ip
  description = "The public IP address of the instance"
  sensitive   = false
}
```

**Output block elements:**
- `value` — the value to return (e.g., IP address, resource ID)
- `description` — human-readable explanation
- `sensitive` — if `true`, value is hidden in logs

**Use cases:** Pass values between modules, display important info after `apply` (IP addresses, IDs)

### Variables and Outputs — Good Practices
- Use **meaningful names** that describe purpose
- **Group** related variables and outputs
- Use for **modularization** (reuse across projects)
- Be **cautious with sensitive data** in outputs

---

## 🔑 Quick Reference — Key Terms

| Term | Definition |
|------|-----------|
| **IaC** | Infrastructure as Code — managing infrastructure via config files |
| **HCL** | HashiCorp Configuration Language — Terraform's config language |
| **AMI** | Amazon Machine Image — pre-built VM image for EC2 |
| **VPC** | Virtual Private Cloud — isolated virtual network in AWS |
| **NAT Gateway** | Allows private subnets to access Internet without exposing IPs |
| **Security Group** | Stateful virtual firewall at instance level |
| **Network ACL** | Stateless firewall at subnet level |
| **VPC Peering** | Private connection between two VPCs |
| **Direct Connect** | Dedicated private connection from on-premises to AWS |
| **Container** | Isolated process sharing host OS kernel |
| **Docker Image** | Read-only template for creating containers |
| **Dockerfile** | Instructions file for building a Docker image |
| **State file** | JSON file tracking all Terraform-managed resources |
| **Terraform Module** | Reusable, parameterizable unit of Terraform config |

---

## ⚡ Exam Quick-Fire Facts

- Terraform uses HCL or **JSON** for config files with **`.tf`** extension
- `terraform init` downloads providers and sets up the `.terraform` directory
- `terraform plan` **does NOT apply changes** — preview only
- `terraform apply` asks for **confirmation** before executing
- `terraform destroy` also asks for **confirmation** and supports `-target` flag
- State file default location: **`terraform.tfstate`** in working directory
- For teams: always use **remote state storage**
- Docker containers share the **host OS kernel** (no hardware emulation)
- `docker run` = `docker create` + `docker start`
- `docker stop` = graceful shutdown; `docker kill` = immediate stop
- S3 can store objects up to **5 TB** each
- Locals **cannot** have default values or validation; Variables **can**
- Security Groups are **stateful**; Network ACLs are **stateless**
- NAT Gateway: private subnets can go **out** to Internet, but not receive **inbound** connections
- Multiple providers can be used in **one** Terraform project

---

---

## 7. AWS Services Overview (XaaS, EC2, S3, RDS)

### XaaS — Anything as a Service
Cloud programming covers any internet-delivered service: **SaaS, DaaS, PaaS, IaaS**, and beyond.

### Service Models Recap

| Model | What it provides | Examples |
|-------|-----------------|---------|
| **IaaS** | Virtual machines, compute, networking, storage | Amazon EC2, Google Compute Engine, Rackspace |
| **PaaS** | Platform for developing custom software | AWS Elastic Beanstalk, Azure AppService, Google App Engine |
| **SaaS** | Third-party managed applications over the Internet | Dropbox, Slack, Spotify, Gmail, Office 365 |

### Amazon EC2 (Elastic Cloud Compute)
- Create, launch, and terminate server instances in the AWS cloud
- Control over **geographic location** (region) of instances
- Pay per second of usage

### AWS Elastic Beanstalk (PaaS)
- Deploys web applications **one abstraction layer above EC2**
- Automatically sets up: EC2 instances, Load Balancer, Auto Scaling Group, Security Group
- **No additional cost** — you pay only for underlying resources

### AWS Infrastructure Concepts

| Concept | Description |
|---------|-------------|
| **Region** | Isolated geographic area; resources are scoped per region |
| **Availability Zone (AZ)** | One or more data centers within a region, connected via low-latency links. Named: `us-east-1a` |
| **Edge Locations** | Low-latency delivery points in major cities for CloudFront, Route 53, WAF, AWS Shield |

### Storage Services

#### Amazon S3 (Simple Storage Service)
- **Object storage** — up to 5 TB per object; stored in **buckets**
- Accessible via REST/SOAP/HTTP
- Objects must be **read/written in full** (no partial updates)
- Supports **multi-instance access** (shared across instances)
- Higher write latency than EBS

#### Amazon EBS (Elastic Block Store)
- **Block storage** — "hard drives for EC2"
- Persists **independently** of instance lifecycle
- Can only be attached to **one EC2 instance at a time**
- Lower latency than S3

#### EBS vs S3

| Feature | EBS | S3 |
|---------|-----|-----|
| Type | Block storage | Object storage |
| Latency | Lower | Higher |
| Access | One EC2 at a time | Multiple instances, HTTP |
| Best for | Databases, filesystems | Shared files, backups, static assets |

### S3 Glacier (Archival Storage)

| Tier | Retrieval | Use Case |
|------|-----------|---------|
| **Instant Retrieval** | Milliseconds | Rarely accessed data needing immediate access (medical images, genomic data) |
| **Flexible Retrieval** | Minutes or 5–12 hrs (free bulk) | Backups, disaster recovery |
| **Deep Archive** | Within 12 hours | Long-term digital media archives (lowest cost) |

### Database Services

#### Amazon RDS (Relational Database Service)
- Managed relational DB supporting: **Aurora** (MySQL/PostgreSQL compatible), MySQL, MariaDB, PostgreSQL, Oracle, SQL Server
- Handles: administration, backups, scaling, encryption automatically

#### Amazon DynamoDB
- **Non-relational** (key-value) database
- Built-in security, backups, multi-region replication, in-memory caching
- Serverless, scales automatically

#### Amazon Redshift
- **Data warehouse** service for fast SQL-based analytics
- Works with structured and semi-structured data

#### RDS vs DB on EC2

| Aspect | RDS | DB on EC2 |
|--------|-----|-----------|
| Administration | Fully managed by AWS | Full manual control |
| Availability | Automatic multi-AZ standby | Manual HA cluster setup |
| Backups | Automated + CloudWatch | Manual, separate monitoring |
| Scalability | Integrated, a few clicks | Manual configuration |
| Security | Encryption at rest and in transit | EBS-level + manual DB encryption |
| Cost | Higher, less operational overhead | Lower cost, more manual work |

---

## 8. Identity and Access Management (IAM)

### Why IAM Matters
A developer given `AdministratorAccess` caused permanent deletion of a production S3 bucket. One scoped IAM policy would have prevented it. **IAM manages authentication (who you are) and authorization (what you may do)** across all AWS resources. It is **deny by default** and **free**.

### Root Account
- **Unrestricted** — cannot be limited by any policy
- Must **never** be used for daily work
- Always: enable MFA, store credentials offline

### IAM Core Entities

| Entity | Description |
|--------|-------------|
| **IAM Users** | Represent a single person or app; zero permissions by default; two credential types: password (console) and access key (CLI/SDK) |
| **IAM Groups** | Named collections of users sharing policies; users can belong to multiple groups; groups **cannot nest** |
| **IAM Roles** | Identity with permissions, not tied to a specific person; no long-term credentials; assumed by trusted entities (EC2, Lambda, cross-account, federated login) |
| **IAM Policies** | JSON documents with `Effect` (Allow/Deny), `Action`, `Resource`, and optional `Condition` |

### IAM Policy Types
1. **Identity-based** — attached to users/groups/roles
2. **Resource-based** — attached to resources (e.g. S3 bucket policies)
3. **Permissions boundaries** — max permissions an entity can have
4. **SCPs (Service Control Policies)** — org-wide restrictions

### Users vs. Roles

| | IAM Users | IAM Roles |
|--|-----------|-----------|
| Credentials | Long-term (password/access key) | Temporary STS tokens (expire 15 min–12 hrs) |
| Tied to | Specific person or app | No specific person |
| Best for | Human console access | Workloads (EC2, Lambda), cross-account |

**Key rule:** Prefer roles for workloads — **never hardcode access keys**.

### AWS STS (Security Token Service)
- Issues **temporary credentials**: Access Key ID + Secret Key + Session Token
- Valid **15 minutes to 12 hours**
- Obtained via `sts:AssumeRole`

### IAM Identity Center (formerly AWS SSO)
- Centralized **SSO** across multiple AWS accounts
- Integrates with external IdPs (Active Directory, Okta, Google)
- Uses **permission sets** built on IAM Roles internally
- **AWS recommends:** Identity Center for humans, IAM Roles for workloads

### IAM Best Practices
- Lock root account + enable MFA
- Grant **least privilege** always
- Use roles for workloads (never embed keys in code)
- Enable MFA for all console users
- Use Identity Center for workforce access
- Regularly remove unused identities
- Audit with **IAM Access Analyzer**

### IAM in Context
| Service | IAM Integration |
|---------|----------------|
| **S3** | Bucket policies + identity policies |
| **RDS** | IAM DB authentication |
| **DynamoDB** | Per-table/per-item policies |
| **Lambda** | Execution role |
| **Elastic Beanstalk** | EC2 instance profile |

---

## 9. Containers on AWS: ECR and ECS (Part 1)

### Amazon ECR (Elastic Container Registry)
- Fully managed **private container registry** integrated with AWS IAM
- Unlike Docker Hub: **private by default**, no pull rate limits within same account/region
- Includes **built-in image scanning**
- Cost: ~$0.10/GB/month

### ECR Image Lifecycle (4 steps)
1. **Build** the image (`docker build`)
2. **Tag** with the ECR repository URI
3. **Authenticate** via `aws ecr get-login-password` (returns a 12-hour IAM token)
4. **Push** to ECR

**Best practice:** Avoid `:latest` in production — use **Git SHA or semantic version tags**. ECR supports **immutable tags** to prevent overwrites.

### ECR Lifecycle Policies
- Automatically expire images by **count or age** (evaluated daily)
- Do **not** protect images currently used by running ECS tasks
- Plan tag exclusions carefully

### ECS (Elastic Container Service) Architecture

**Four nested primitives:**
```
Cluster → Service → Task Definition → Task
```

| Primitive | Description |
|-----------|-------------|
| **Cluster** | Logical grouping of infrastructure |
| **Service** | Maintains desired task count; restarts failures |
| **Task Definition** | Immutable versioned blueprint; each change = new revision |
| **Task** | A running instance of the task definition |

**Rollback** = pointing the service at a previous task definition revision.

### Task Definitions — Per-Container Specs
- Image URI
- CPU (soft reservation) and Memory (hard limit)
- Ports, environment variables
- Secrets (from Secrets Manager)
- Log driver
- Startup ordering via `dependsOn` with conditions: `START`, `HEALTHY`, or `COMPLETE`

### ECS Launch Types

| | **Fargate** | **EC2** |
|--|-------------|---------|
| Management | Serverless (AWS manages) | You manage EC2 instances |
| Billing | Per-task | Per EC2 instance |
| Cold start | ~30–60 seconds | Faster |
| Best for | New workloads, variable load | Steady high-throughput workloads |

**Fargate is the recommended default for new workloads.**

---

## 10. ECS Networking, IAM, and Observability (Part 2)

### The Four Operational Gaps (building on a Spring Boot + Vite frontend on ECS)
1. No public traffic reaching the frontend
2. Backend exposed directly to the internet
3. No monitoring (CPU at 95% for 20 minutes unnoticed)
4. Single task = single point of failure

### 1. Networking Architecture — Two-Tier ECS Deployment

**VPC Layout:**
- **Public subnets** → host the ALB (route: `0.0.0.0/0 → Internet Gateway`)
- **Private subnets** → host frontend AND backend (route: `0.0.0.0/0 → NAT Gateway`, outbound only)
- Internet reaches **only the ALB** — frontend and backend have no inbound internet route by design

**Security Group Design (3 groups):**

| Security Group | Allows |
|---------------|--------|
| `alb-sg` | TCP 80/443 from the internet |
| `frontend-sg` | TCP 3000 from `alb-sg` only |
| `backend-sg` | TCP 5000 from `alb-sg` only |

Using a **security group (not a CIDR)** as source handles IP changes automatically.

### `awsvpc` Networking Mode (required for Fargate)
- Each task gets its own **ENI (Elastic Network Interface)** and private IP
- Security groups assigned directly to the **task**, not an EC2 instance
- A compromised task **cannot reach other tasks** on the same host
- Contrast: non-`awsvpc` mode has all tasks on an EC2 instance sharing one ENI and SG

### 2. Application Load Balancer (ALB)

**Four building blocks:**
1. **Load balancer** — public-facing, spans multiple AZs
2. **Listener** — monitors a port, evaluates rules
3. **Listener rules** — match path/host/header, forward to target groups
4. **Target groups** — pools of task IPs; health checks run continuously

**Routing rules example:**
- Default: `/` → frontend target group
- Priority 10: `/api/*` → backend target group

**Target group type in `awsvpc` mode:** must be `ip` (not `instance`). ECS auto-registers each task's ENI IP.

**HTTP 502 troubleshooting:**
- Check `/api/*` listener rule exists with correct path pattern
- Check backend target group health (at least one healthy target registered)
- Check `backend-sg` allows TCP 5000 from `alb-sg`

**Request trace for `GET /api/users`:**
> DNS → ALB public IP → port 80 listener → `/api/*` rule → healthy backend task IP → Spring Boot port 5000 → response via ALB

### 3. IAM Roles for ECS Tasks

| Role | Used by | When | Typical Permissions |
|------|---------|------|-------------------|
| **Task Execution Role** | ECS agent (AWS infrastructure) | Task launch | Pull from ECR, write CloudWatch logs, read Secrets Manager |
| **Task Role** | Application code inside the container | Runtime | Read S3, query DynamoDB, publish to SQS |

- These **must be kept separate** — agent has no business with DynamoDB; app has no business with `ecr:GetAuthorizationToken`
- Managed policy `AmazonECSTaskExecutionRolePolicy` covers ECR pull + CloudWatch log write
- Task Role: least privilege — scope to exact resource ARN

### 4. CloudWatch for ECS

**Three capabilities:**
- **Metrics** — numeric time-series (CPU%, request count)
- **Logs** — arbitrary text (container stdout)
- **Alarms** — rules that watch one metric and trigger actions

**Container log flow:**
> stdout/stderr → `awslogs` log driver (in task definition) → CloudWatch Logs group `/ecs/<cluster>/<service>` → one stream per task `/ecs/<container>/<task-id>`

**Key Metrics:**

| Metric | Namespace | Measures |
|--------|-----------|---------|
| `CPUUtilization` | AWS/ECS | Avg CPU vs. task reservation (%) |
| `MemoryUtilization` | AWS/ECS | Avg memory vs. task limit (%) |
| `RunningTaskCount` | AWS/ECS | Running tasks in the service |
| `RequestCountPerTarget` | AWS/ApplicationELB | ALB requests per target/min |
| `TargetResponseTime` | AWS/ApplicationELB | P50/P99 response latency |

**Metric Interpretation:**
- CPU consistently >80% → **scale out**
- `RunningTaskCount` drops suddenly → **tasks crashing** (check logs)
- `TargetResponseTime` rising with low CPU → **database bottleneck**

**CloudWatch Alarm States:** `OK`, `ALARM`, `INSUFFICIENT_DATA`
- `INSUFFICIENT_DATA` ≠ OK — a stopped or newly deployed service stays here
- Actions: publish to SNS topic → email, PagerDuty, Lambda, etc.

### 5. ECS Service Auto Scaling

Adjusts **desired task count** (not EC2 instance count). Uses Application Auto Scaling API.

| Policy Type | How it works |
|-------------|-------------|
| **Step Scaling** | Add/remove a fixed count on a CloudWatch Alarm |
| **Target Tracking** | Keep a metric at a target value (recommended, self-calibrating) |

**Setup:** register the ECS service as a scalable target (`--min-capacity`, `--max-capacity`) → attach target-tracking policy.

**Example:** keep average CPU at 75%, scale-out cooldown 60s (add tasks quickly), scale-in cooldown 300s (wait 5 min to avoid thrashing).

**Scale-out flow:**
> Auto Scaling increases `DesiredCount` → ECS launches new Fargate tasks (each gets ENI + private IP) → task IPs registered in ALB target group → ALB routes traffic after health checks pass (~30–60s)

**Scale-in flow:**
> Auto Scaling decreases `DesiredCount` → ECS selects tasks for termination → ALB deregisters IPs (connection draining, in-flight requests finish) → after deregistration delay (default 300s) → tasks stopped

**Control loop:**
> load spike → CPU crosses threshold → Alarm fires → scale-out → new tasks healthy → CPU drops → scale-in cooldown → scale-in fires

---

## 11. Serverless Computing with AWS Lambda

### The Abstraction Ladder
```
Bare Metal → EC2 → ECS Fargate → Lambda
```
Lambda = you manage **only app code**. Mental shift: from "how much capacity do I provision?" → "what should happen when this event fires?"

### AWS Lambda — Key Facts
- **Event-driven** compute service, no servers to manage
- Maximum execution time: **15 minutes** (hard limit — not a suggestion!)
- Stateless handlers
- Managed runtimes: Node.js, Python, Java, .NET, Ruby
- Custom OS-only runtimes: Go, Rust

### Execution Lifecycle
```
Init (cold start) → Invoke → Shutdown
```
- **Cold start:** 100ms–2s (no warm environment available)
- **Warm start:** reuses existing environment (opportunistic — never depend on it!)

### Stateless Design
- **No in-memory state** persists between invocations
- Global variables are **not shared** across concurrent environments
- `/tmp` (up to 10 GB) is per-environment only
- All persistent state must be **external:**
  - DynamoDB → records
  - S3 → files
  - ElastiCache → session cache

### Lambda Function Anatomy

**Handler:** named as `module.function_name`, receives:
- `event` — trigger payload
- `context` — runtime metadata (including `get_remaining_time_in_millis()`)

**Configuration:**

| Parameter | Range / Limit |
|-----------|--------------|
| Memory | 128 MB – 10,240 MB (CPU scales proportionally) |
| Timeout | 1s – 900s (**15 min max, hard limit**) |
| Environment variables | Up to 4 KB total |

**Key insight:** For **CPU-bound** workloads (e.g. image resizing) → increasing memory also increases CPU → reduces execution time and cost. For **I/O-bound** workloads → more memory doesn't help.

### Deployment Options

| Method | Size Limit | Use Case |
|--------|-----------|---------|
| ZIP direct upload | 50 MB | Small functions |
| ZIP via S3 | 250 MB unzipped | Larger packages |
| Container image | 10 GB | Full Docker workflow |

**Lambda Layers:** shared libraries reused across functions without duplicating in every ZIP.

### Event Sources — Three Invocation Models

| Model | Behavior | Used by |
|-------|---------|---------|
| **Synchronous** (`RequestResponse`) | Caller blocks, errors returned directly, caller handles retries | API Gateway, ALB, SDK/CLI |
| **Asynchronous** (`Event`) | Returns HTTP 202 immediately; Lambda retries on failure up to 2×; caller never receives result | S3 events, SNS, EventBridge |
| **Event Source Mapping (polling)** | Lambda polls source; records batched and delivered | SQS, DynamoDB Streams, Kinesis |

**Model selection guide:**

| Use case | Model |
|---------|-------|
| HTTP API endpoint | Synchronous |
| File uploaded to S3 | Asynchronous |
| Process a message queue | Event source mapping |
| Scheduled nightly job | Asynchronous (EventBridge) |
| 20-minute batch job | **Neither** — use ECS/Batch (exceeds 15-min limit!) |

### API Gateway Integration
- Passes a **structured proxy event** to Lambda
- Lambda must return: `statusCode`, `headers`, and `body`
- Proxy integration (default): forwards the full HTTP request as-is

### Security — Two IAM Constructs

| Construct | Controls | Direction |
|-----------|---------|---------|
| **Execution Role** | What Lambda *can do* | Outbound: Lambda → AWS services |
| **Function Policy** | Who *can call* Lambda | Inbound: AWS service → Lambda |

- Execution role starts from `AWSLambdaBasicExecutionRole` (CloudWatch Logs only)
- Function policy is required when caller is another AWS service (API Gateway, S3, EventBridge)

### Lambda in a VPC
- By default Lambda runs **outside your VPC**
- Attach to a VPC to reach: RDS, ElastiCache, internal APIs
- Requires subnet + security group config
- Outbound internet requires a **NAT Gateway** (~$0.045/GB + ~$32/month fixed)
- Cold-start latency penalty from VPC attachment was resolved around 2020 (AWS Hyperplane)

### Pricing Model

| Component | Cost |
|-----------|------|
| Requests | First 1M free/month, then $0.20/million |
| Duration | Memory (GB) × time (s) × $0.0000166667/GB-s (billed per 1ms) |

**Cost comparison example:**
- 1M invocations × 500ms × 512MB ≈ **$4.17** (Lambda)
- Always-on ECS Fargate ≈ **$10.80/month**

**Lambda scales to zero** — spiky/intermittent workloads: Lambda wins. Steady high-throughput: ECS/EC2 wins.

---

## 12. Asynchronous Messaging: SQS, SNS, and EventBridge

### Why Async Messaging?

Synchronous (direct) call chains are fragile: one slow link stalls the entire chain, one crash propagates upstream immediately, and burst traffic hits the callee with no buffer. Dropping a queue between services decouples producer and consumer so neither knows the other, bursts are absorbed, and a consumer crash simply leaves messages waiting until the consumer restarts.

### Amazon SQS — The Work Queue

**Queue model:**
- **Producer** calls `SendMessage` — fire and forget
- **Consumer** calls `ReceiveMessage → process → DeleteMessage`
- Queue persists independently of both endpoints
- Max message size: **256 KB** | Max retention: **14 days**

**Message lifecycle:**
```
SendMessage → [in queue]
ReceiveMessage → [invisible — visibility timeout starts]
DeleteMessage → removed permanently
Timeout/crash → back in queue → retry
```

- **Visibility timeout** — default **30 s**, max **12 h**; set to **6× expected processing time** to avoid false re-deliveries
- No `DeleteMessage` = automatic retry (resilience without retry code)

**Competing consumers (load leveling):**
- Multiple workers pull from the same queue — each gets a different message
- Lambda ESM scales workers automatically with queue depth
- Burst → workers scale up; quiet → scale to zero; **no coordination needed**

**Dead Letter Queue (DLQ):**
- After `maxReceiveCount` retries, SQS routes the message to a DLQ
- DLQ is a regular SQS queue of the **same type** (Standard→Standard, FIFO→FIFO)
- Prevents a *poison message* from looping forever and starving valid work
- Workflow: inspect → fix the bug → redrive back to source queue

**Standard vs FIFO:**

| | Standard | FIFO |
|---|---|---|
| Throughput | Virtually unlimited | 3,000 msg/s |
| Ordering | Best-effort | Strict per message group |
| Delivery | **At-least-once** | **Exactly-once** |
| Queue name | Any | Must end in `.fifo` |

- **Default: Standard** — prefer it unless strict ordering is required
- FIFO throughput ceiling is real — Standard + idempotency beats FIFO for most workloads

---

### Amazon SNS — One Publish, Many Consumers

- **Publisher** sends once to the topic — unaware of subscriber count or type
- Every subscriber gets an **independent copy** — failure in one doesn't affect others
- Supported protocols: SQS, Lambda, HTTP/HTTPS, email, SMS, mobile push

**Subscription filter policies:**
- Default: every subscriber receives every message
- Filter policy: JSON attribute match — subscriber receives only the matching subset
- Defined on the subscription (not the topic) — publisher code unchanged

**Fan-out pattern: SNS → SQS → Lambda** (preferred over SNS → Lambda directly):
- Direct SNS→Lambda: no buffering (burst hits Lambda immediately), retries opaque, DLQ lives on Lambda destination
- **SQS adds**: burst buffer + per-consumer DLQ + visible retry metrics

---

### Amazon EventBridge — The Smart Event Bus

- **Event bus** receives structured JSON events; rules route them to targets
- **Default bus**: all AWS service events arrive here automatically
- **Custom bus**: for your own application events
- Rules match on **any JSON field** — `source`, `detail-type`, `detail.*`

**Content-based routing example:**
```json
{
  "source": ["aws.s3"],
  "detail-type": ["Object Created"],
  "detail": { "bucket": { "name": ["my-uploads-bucket"] } }
}
```

**Scheduled invocation** (replaces manual cron):
```
rate(5 minutes) → Lambda every 5 min
cron(0 8 * * ? *) → Lambda at 08:00 UTC daily
```
- Targets: Lambda, SQS, SNS, Step Functions, API destinations
- Scheduled rules invoke Lambda **asynchronously**

**SNS vs EventBridge:**

| | SNS | EventBridge |
|---|---|---|
| Primary use | Fan-out to queues/HTTP | Content-based routing |
| Routing logic | One attribute filter | Any JSON path |
| Scheduled delivery | No | Yes (rate / cron) |
| SaaS event sources | No | 200+ partners |

- **Heuristic:** SNS for fast broadcast to known subscribers; EventBridge when routing depends on payload content or a schedule
- In practice they layer: EventBridge → SNS topic → SQS queues → Lambda

---

### Lambda as the Glue — SQS Event Source Mapping (ESM)

- ESM owns `ReceiveMessage` and `DeleteMessage` — no polling code in your function
- Batch delivered as `event["Records"]` — a list of messages

**Batch tuning:**

| Parameter | Default | Guidance |
|---|---|---|
| Batch size | 10 | Up to 10,000 — more = fewer invocations |
| Batch window | 0 s | Up to 300 s — accumulate larger batches |
| Max concurrency | Unlimited | Cap to protect downstream DB connections |

- Larger batch → fewer invocations → lower Lambda cost
- **Max concurrency cap** = workers × connections-per-worker ≤ DB `max_connections`

**Partial batch failure (`ReportBatchItemFailures`):**
- Default: one failed message fails the **entire batch** — all retried
- Enable `FunctionResponseTypes = [ReportBatchItemFailures]` on the ESM
- Return only failed message IDs; the rest are deleted automatically

```python
def handler(event, context):
    failures = []
    for record in event["Records"]:
        try:
            process(record["body"])
        except Exception:
            failures.append({"itemIdentifier": record["messageId"]})
    return {"batchItemFailures": failures}
```

---

### At-Least-Once Delivery & Idempotency

- SQS Standard guarantees at-least-once: duplicate deliveries are rare but real
- Network retries mean Lambda **will** eventually receive the same message twice
- **Idempotent handler**: processing the same message twice produces the same outcome

**Concrete fix — conditional write in DynamoDB:**
```python
table.put_item(
    Item={"orderId": order_id, "status": "CONFIRMED"},
    ConditionExpression="attribute_not_exists(orderId)"
)
# Second call with same orderId → ConditionCheckFailedException → catch and ignore
```

- FIFO eliminates SQS-level duplicates, but a Lambda crash *after* the effect still causes a retry

---

### Security: IAM for SQS and SNS

**Two directions of trust:**
- **Execution role** — what Lambda is *allowed to do* outbound (e.g. `sqs:SendMessage`, `sns:Publish`)
- **Queue / topic policy** — who is *allowed to write* inbound to the queue or topic
- Both must be correct — one missing → integration silently fails
- AWS Academy: attach permissions to `LabRole`; custom scoped roles require permission boundaries

**Encryption:**

| | SSE-SQS | SSE-KMS |
|---|---|---|
| Key ownership | AWS-managed | Customer CMK |
| Cost | Free | $1/month + API calls |
| AWS Academy | Available | Restricted — needs `kms:*` |

- In transit: HTTPS endpoint — enforced by default for all AWS SDK calls
- Lab recommendation: **SSE-SQS** — zero extra IAM setup required

---

### Practice Questions — SQS, SNS, EventBridge

**Q1.** A Lambda processes SQS batches of 50 messages. One message per batch is malformed JSON. `ReportBatchItemFailures` is NOT enabled. What happens in production?
> All 50 messages are retried on every batch → valid messages blocked → after `maxReceiveCount`, all 50 (including 49 valid ones) move to the DLQ. **Fix:** enable `ReportBatchItemFailures` and catch exceptions per record.

**Q2.** `ORDER_PLACED` is published to SNS. Two SQS subscriptions exist: one for email, one for inventory. The inventory Lambda crashes. What happens to the email Lambda's copy?
> **Unaffected** — each subscriber queue holds an independent copy. The inventory crash has zero effect on the email queue. This is the core value of fan-out: independent failure domains.

**Q3.** Why is SNS → SQS → Lambda preferred over SNS → Lambda directly?
> SQS adds: (1) burst buffer so Lambda isn't hit with raw spikes, (2) per-consumer DLQ for inspectable failures, (3) visible retry metrics via queue depth.

**Q4.** You need to trigger a Lambda every weekday at 08:00 UTC. Which service handles this?
> **Amazon EventBridge** scheduled rule (`cron(0 8 ? * MON-FRI *)`). SNS has no scheduling capability.

**Q5.** What is the visibility timeout, and how should you set it?
> The window during which a received message is invisible to other consumers while being processed. Set it to **6× the expected processing time** to avoid false re-deliveries where a slow-but-successful consumer causes the message to be retried by another worker.

---

## 🔑 Quick Reference — Key Terms (Complete)

| Term | Definition |
|------|-----------|
| **IaC** | Infrastructure as Code — managing infrastructure via config files |
| **HCL** | HashiCorp Configuration Language — Terraform's config language |
| **AMI** | Amazon Machine Image — pre-built VM image for EC2 |
| **VPC** | Virtual Private Cloud — isolated virtual network in AWS |
| **NAT Gateway** | Allows private subnets to access Internet without exposing IPs |
| **Security Group** | Stateful virtual firewall at instance level |
| **Network ACL** | Stateless firewall at subnet level |
| **VPC Peering** | Private connection between two VPCs |
| **Direct Connect** | Dedicated private connection from on-premises to AWS |
| **Container** | Isolated process sharing host OS kernel |
| **Docker Image** | Read-only template for creating containers |
| **Dockerfile** | Instructions file for building a Docker image |
| **State file** | JSON file tracking all Terraform-managed resources |
| **Terraform Module** | Reusable, parameterizable unit of Terraform config |
| **IAM** | Identity and Access Management — auth/authz for all AWS resources |
| **STS** | Security Token Service — issues temporary credentials |
| **ECR** | Elastic Container Registry — private Docker image registry |
| **ECS** | Elastic Container Service — managed container orchestration |
| **Fargate** | Serverless compute engine for ECS (no EC2 management) |
| **ALB** | Application Load Balancer — HTTP/HTTPS traffic distribution |
| **ENI** | Elastic Network Interface — virtual NIC in a VPC |
| **Lambda** | Serverless, event-driven function compute (max 15 min) |
| **CloudWatch** | AWS monitoring service — metrics, logs, alarms |
| **EBS** | Elastic Block Store — block storage for EC2 |
| **RDS** | Relational Database Service — managed SQL databases |
| **DynamoDB** | Managed NoSQL key-value database |
| **S3 Glacier** | Archival storage with tiered retrieval speeds |
| **Redshift** | Managed data warehouse for analytics |
| **awsvpc** | ECS networking mode giving each task its own ENI |
| **SQS** | Simple Queue Service — managed message queue; decouples producers from consumers; max 256 KB/msg, 14-day retention |
| **SNS** | Simple Notification Service — pub/sub broadcaster; one publish delivers independent copies to all subscribers |
| **EventBridge** | Serverless event bus; routes JSON events via content-based rules; supports schedules and 200+ SaaS sources |
| **ESM** | Event Source Mapping — Lambda polls SQS/Kinesis/DynamoDB Streams; owns `ReceiveMessage` and `DeleteMessage` |
| **DLQ** | Dead Letter Queue — receives messages after `maxReceiveCount` retries; prevents poison messages from blocking a queue |
| **Idempotency** | Processing the same message multiple times produces the same outcome — required for at-least-once delivery |
| **Visibility timeout** | Window during which a received SQS message is invisible to other consumers; default 30 s, max 12 h |
| **Fan-out** | Pattern where SNS delivers one publish to multiple independent SQS queues, each consumed by its own Lambda |

---

## ⚡ Exam Quick-Fire Facts (Complete)

- Terraform uses HCL or **JSON** for config files with **`.tf`** extension
- `terraform init` downloads providers and sets up the `.terraform` directory
- `terraform plan` **does NOT apply changes** — preview only
- `terraform apply` asks for **confirmation** before executing
- `terraform destroy` also asks for **confirmation** and supports `-target` flag
- State file default location: **`terraform.tfstate`** in working directory
- For teams: always use **remote state storage**
- Docker containers share the **host OS kernel** (no hardware emulation)
- `docker run` = `docker create` + `docker start`
- `docker stop` = graceful shutdown; `docker kill` = immediate stop
- S3 can store objects up to **5 TB** each
- Locals **cannot** have default values or validation; Variables **can**
- Security Groups are **stateful**; Network ACLs are **stateless**
- NAT Gateway: private subnets can go **out** to Internet, but not receive **inbound** connections
- Multiple providers can be used in **one** Terraform project
- IAM is **deny by default** and **free**
- Root account: cannot be limited by any policy — **never use for daily work**
- IAM Groups **cannot be nested** (no groups within groups)
- IAM Roles use **temporary** STS credentials (15 min – 12 hrs); Users use **long-term** credentials
- ECR: use Git SHA or semantic version tags — **avoid `:latest` in production**
- ECR supports **immutable tags** to prevent overwrites
- ECS: Cluster → Service → Task Definition → Task (four nested primitives)
- Rollback in ECS = point service at a **previous task definition revision**
- Fargate cold start: **~30–60 seconds**
- Fargate: recommended default for **new workloads**
- `awsvpc` mode: each task gets its **own ENI** — Fargate requires this mode
- ALB target type in `awsvpc` mode: must be **`ip`**, not `instance`
- CloudWatch Alarm states: **OK, ALARM, INSUFFICIENT_DATA** (last ≠ OK!)
- Lambda max execution time: **15 minutes (900 seconds)** — hard limit
- Lambda cold start: **100ms–2s**; warm start reuses environment
- Lambda memory: **128 MB – 10,240 MB** (CPU scales proportionally)
- Lambda timeout: **1s – 900s**
- Lambda `/tmp` storage: up to **10 GB** (per-environment only)
- Lambda pricing: first **1M requests free/month**
- Lambda scales to **zero** — ECS costs the same regardless of traffic
- Asynchronous Lambda invocation retries: up to **2×** on failure
- Lambda in VPC: needs **NAT Gateway** for internet access
- DynamoDB = **key-value** (non-relational); RDS = **relational** (SQL)
- S3 Glacier Deep Archive: retrieval within **12 hours** (lowest cost)
- S3 Glacier Instant Retrieval: **millisecond** access
- SQS Standard delivery: **at-least-once** (duplicates possible) — FIFO: **exactly-once**
- SQS max message size: **256 KB** | max retention: **14 days**
- SQS visibility timeout: default **30 s**, max **12 h** — set to **6× expected processing time**
- SQS FIFO throughput: **3,000 msg/s** — FIFO queue name must end in `.fifo`
- SQS DLQ type must match source: **Standard→Standard, FIFO→FIFO**
- After `maxReceiveCount` retries → message routed to **DLQ**
- SNS: publisher sends once — every subscriber gets an **independent copy**
- SNS→Lambda directly: no buffering, no inspectable DLQ — prefer **SNS→SQS→Lambda**
- EventBridge: default bus = all **AWS service events** auto-arrive; custom bus = your app events
- EventBridge rules match on **any JSON field** (`source`, `detail-type`, `detail.*`)
- EventBridge scheduled rules invoke Lambda **asynchronously**
- `ReportBatchItemFailures`: only listed message IDs return to queue — **rest are deleted**
- Idempotency fix in DynamoDB: `ConditionExpression="attribute_not_exists(orderId)"`
- ESM: no polling code needed — ESM owns `ReceiveMessage` and `DeleteMessage`
- Lambda ESM batch size: default **10**, max **10,000**; batch window: default **0 s**, max **300 s**

