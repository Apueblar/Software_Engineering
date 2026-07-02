# IT Applications: Electronic Media in Business and Commerce — Course Summary

## Educational Outcomes (Overview)
- **Knowledge (PEK_W):** e-business problems, web technologies for e-commerce, large public/commercial information systems, information security regulations and cryptographic tools
- **Skills (PEK_U):** specifying complex information systems, designing software with security requirements, implementing and assessing security of commercial web applications
- **Social/Soft skills (PEK_K):** understanding tech's economic/social impact, teamwork in development projects, scheduling/risk management, awareness of IT security risks

## Topic List (14 Lecture Blocks)
1. E-business and enterprise applications — application servers, distributed programming (CORBA)
2. REST — SOA, REST architecture, Python implementation, micro-services, GraphQL
3. Virtualization + Cloud Computing — history, types of virtualization, hypervisors, VMware/Xen, cloud computing
4. Containers and GPU — Docker, docker-compose, GPU access, ONNX
5. Orchestration — Kubernetes, Rancher, CI
6. Basic software security mechanisms — cryptosystems, digests, MAC/HMAC, digital signatures, certificates, AAA
7. Secure network protocols — layered model, SSL/TLS, HTTPS, Apache HTTPS configuration
8. Secure electronic payments — payment cards, SET/3D Secure, WiFi vulnerabilities
9. Economic aspects of security — service vulnerabilities, security policy, risk assessment, security investment
10. IT services management (ITIL) — incident/problem/change management, configuration, knowledge management, KPIs
11–12. SLM, Availability & IT Service Continuity Management — SLA/OLA/UC contracts, availability calculations ("nines"), ITSCM, cold/warm/hot recovery, security vs. safety
13–14. Blockchain and Cryptocurrencies — block structure, Merkle trees, consensus, mining, BTC vs fiat, ICO/DAO, smart contracts, scaling issues

---

## Lecture 1: Enterprise Applications & SOA

### Effective Applications
- Sequential programming: efficient algorithms/data structures
- Multithreading: solves I/O blocking and parallelism, but has synchronization costs (Python historically limited to one core)
- Processes: isolated, limited communication, costly creation
- Asynchronous programming: mimics event processing, single-threaded, solves I/O blocking but needs care to avoid blocking calls

### Distributed Application Problems & Solutions
- **Bottlenecks:** databases, resource limits
- **Solutions:** load balancing, stateless applications, synchronization primitives (semaphores, queues, TCP/IP), good pipeline design

### Enterprise Goals
Reuse, faster time-to-market, lower cost, better quality, portability ("write once, deploy anywhere")

### N-Tier Architecture
Application logic split functionally: presentation logic (web servers) vs. business logic (application servers) vs. data (databases/EIS)

### JavaEE Standard Services
Web Container (JSP, Servlets) + EJB Container, supported by RMI/IIOP, JNDI, JTA, JDBC, JMS, JavaMail, JCA/JMX

### Distributed Programming
- **RMI:** Java-homogeneous remote method invocation via RmiRegistry
- **CORBA:** heterogeneous, language-independent via ORB, IDL, IIOP
- **CORBA problems:** firewall issues, security concerns, binary formats — motivates need for: communication protocol, data exchange format, IDL/interface exchange

### SOA (Service-Oriented Architecture)
- Business functionality grouped into self-contained, reusable **services** with contracts (purpose, interfaces, constraints)
- Services are autonomous, can be independently evolved/scaled
- Enables flexible federated business processes, reuse, aggregation
- Evolutionary step from 3-tier (homogeneous, language-dependent) to SOA (heterogeneous, language-independent, massively distributed)

### Web Services
- W3C definition: software system identified by URI, interfaces described in XML, discoverable, machine-to-machine via XML messages
- Advantages over CORBA/RMI: no firewall issues (HTTP), HTTPS security
- **Protocols:**
  - **UDDI** (registry, now rarely used — IBM/MS/SAP closed public nodes in 2006)
  - **SOAP** (XML message format, stateless)
  - **WSDL** (XML interface description, like a Java interface, used to generate SOAP messages/client code)
- **SOAP structure:** Envelope (required), Header (optional), Body (required), Fault (optional)
- **Pros:** simple deployment, firewall/security friendly, language-independent
- **Cons:** large XML messages, historically "heavy" servers (less true today with JAX-WS)

---

## Lecture 2: REST

### Recap from Lecture 1
RPC needs: communication protocol, data exchange format, IDL — CORBA suffered from security/firewall issues and binary formats

### REST (Representational State Transfer)
- Architectural style (not a standard), based on existing web standards (HTTP)
- Client progresses through resources by following links (state transfer)

### REST Characteristics
- **Client-Server:** clients pull representations
- **Stateless:** each request carries all needed info
- **Uniform interface:** generic HTTP-based access to all resources
- **Layered components:** proxies/caches for performance and security

### Four REST Principles
1. Everything is a **resource** (customers, locations, items)
2. Resources have **names** (URIs/URLs)
3. Resources support simple **verbs** (CRUD ↔ GET/POST/PUT/DELETE)
4. Resources have **representations** (HTML, XML, JSON, binary)

### REST Commands Mapping
SQL SELECT/UPDATE/INSERT/DELETE ↔ HTTP GET/POST/PUT/DELETE ↔ CRUD operations

### XML vs JSON
- JSON: shorter, JavaScript-based, has JSON Schema
- XML: validators/tooling ecosystem, code generators (XML↔objects, XML Schema↔types), higher memory/CPU cost

### SOAP vs REST Summary
| | SOAP | REST |
|---|---|---|
| Protocol | HTTP/HTTPS | HTTP/HTTPS |
| Endpoint | path + SOAP envelope | path, HTTP methods, MIME type |
| Arguments | XML | path, query params, POST body |
| Data format | XML/XML Schema | JSON/anything |
| Interface description | WSDL | none standard, but OpenAPI/Swagger |

### Implementation Frameworks
- Java: JAX-RS
- Python: Flask, CherryPy, aiohttp, FastAPI (examples shown for both JAX-RS resource classes and FastAPI route decorators)

### Problems with Classical REST
- No built-in interface description (WSDL equivalent) → solved partially by Swagger/OpenAPI (JSON Schema-based), but must be manually authored
- Hard to handle nested/linked resources, includes/excludes
- Over-fetching (generic endpoints) or under-fetching (specific endpoints → versioning issues)
- Tight client-server coupling, outdated docs, response ambiguity

### GraphQL
- Originated at Facebook (2012/2015/2018 → GraphQL Foundation)
- Query/manipulation language for APIs — client specifies exactly what data it needs
- Reduces over/under-fetching; supports multiple queries in one request
- Not a database, storage engine, or library; not tied to a language or transport protocol (works over HTTP, WebSockets, etc.)

### Microservices
- Variant of SOA: application as a collection of loosely coupled, fine-grained services with lightweight protocols
- Each service has independent stack and decentralized data (vs. monolith's shared stack/single DB)
- Enables small, autonomous, cross-functional teams per service (vs. functional teams — UI/Server/DBA/Test/Build — in monoliths)
- Architecture commonly fronted by an API Gateway routing REST calls to Account/Inventory/Shipping services, etc.

---

## Instructor Background Note (Context)
- Languages progression: C++ → Java → Python
- Deployment tech timeline: VMware (late 90s), Xen (2013), Docker (2016), Kubernetes (2018), RabbitMQ (2014), NATS (2017)
- Related projects: DESEREC, CLARIN-PL (CTJ), CLARIN-PL-BIZ, PLLuM

---

## Lecture 3: AMQP & Virtualization + Cloud Computing

### Recap: Data Formats
- **XML:** verbose but tooling-rich
- **JSON:** still relatively costly to parse/serialize
- **Protocol Buffers:** binary IDL by Google, 7–10x faster than JSON, compiles to classes (Java, C++, C#, Python)
- **CSV:** simple "other" option

### Beyond Classic HTTP (Server-Initiated Communication)
Classic HTTP is unidirectional (client initiates, server responds). Solutions for server-to-client communication:
- **Polling:** client asks repeatedly
- **Long-polling:** request held open until timeout/response
- **WebSocket:** full-duplex, persistent connection after initial HTTP handshake
- **SSE (Server-Sent Events):** one-way server→client event stream over a persistent connection

### REST Problems (Recap) — Two Categories
1. **Endpoint addressing:** raw IP:port URLs are unmanageable
   - Solutions: central registry, central proxy endpoint, DNS (port issues), one IP per service, or switch to other protocols (e.g., AMQP)
2. **Synchronous HTTP limitations:** default ~30s timeouts, cascading errors, long-running services poorly supported
   - Solutions: asynchronous server APIs (callbacks, e.g., JAX-RS async), WebSockets, AMQP

### AMQP (Advanced Message Queuing Protocol)
- Message-oriented middleware; binary protocol over TCP/IP
- JMS is the corresponding JavaEE API
- Implementations: Storm MQ, Apache ActiveMQ, **RabbitMQ**

### RabbitMQ
- Fast, written in Erlang; acts as a **broker**
- Core concepts: connections, channels, queues
- Multi-language clients: C++, C#, Python, Java, PHP, JS
- Brokers can connect across firewalls/Internet to link distributed clients

### AMQP Communication Model
- **Producer** → publishes message → **Exchange** (in broker)
- Exchange routes message via **bindings** to one or more **queues**
- **Consumer** reads from queue
- Exchange types: **Direct** (exact routing key match), **Topic** (pattern matching, e.g., `eu.de.*`, `us.#`), **Fanout** (broadcast to all bound queues)

### Messaging Patterns
- **Point-to-Point:** producer publishes to a named queue; consumer uses `basic_consume` with a callback (Python `pika` example shown)
- **RPC over AMQP:** client sends request to an `rpc_queue` with `reply_to` (callback queue) and `correlation_id`; server processes and publishes reply to `reply_to` with matching `correlation_id`; client matches replies via correlation ID while polling `process_data_events()`

### gRPC
- Supports classic RPC and streaming RPC
- Multi-language: Java, Go, C, C++, Node.js, Python, Ruby, Objective-C, PHP, C#
- IDL: Protocol Buffers 3 or Flatbuffers
- Transport: **HTTP/2**; Auth via SSL/TLS
- Open source (github.com/grpc)
- Browser compatibility issues (HTTP/2 + binary protobuf) → often fronted by a REST API gateway that talks gRPC to backend services
- Supports both synchronous and asynchronous interaction styles

### HTTP/2 (2015) Key Features
- **Binary framing layer:** messages split into small binary frames, enabling multiplexing without blocking
- **Streaming:** bidirectional full-duplex — client and server can send simultaneously
- **Flow control:** fine-grained buffer/memory management for in-flight messages
- **Header compression (HPACK):** all headers encoded, reducing overhead

---

## Cloud Computing

### Definitions & Context
- **NIST definition:** a model for ubiquitous, on-demand network access to a shared pool of configurable resources (networks, servers, storage, applications, services) that can be rapidly provisioned/released with minimal management effort
- Part of the broader "IT Technology Generations" arc: Central Systems (60s) → Client-Server/PC (80s) → Internet/online business (90s) → Mobile + Cloud + Analytics (today)
- UI paradigm evolution: batch processing → command line → WIMP/Windows → web (HTML5+CSS3+JS)
- Web apps: browser acts as a mini-OS; web pages are executable programs (DNS lookup + HTTP request/response model)

### Data Centers
- Massive, highly automated facilities (much larger than legacy systems), often located near power sources
- High packing density — many applications per machine, isolated via lightweight VMs
- Scheduled for high utilization, but overloads are avoided
- Economies of scale (small vs. large data center, approximate 2018-era figures):
  - Network: $95/Mbps/month (small) vs $13/Mbps/month (large) → ~7.1x advantage
  - Storage: $2.20/GB/month vs $0.40/GB/month → ~5.7x advantage
  - Administration: ~140 servers/admin vs >1000 servers/admin → ~7.1x advantage
  - A large data center can be ~11.5x the size of a football field

### Key Benefits of Cloud/Data Centers
- Higher hardware utilization → better ROI; bulk hardware procurement
- Standardization reduces sysadmin overhead, cooling costs, power waste
- Resources can be **rented** rather than owned
- Enables elastic, massively scaled services and big-data accumulation (requires massively parallel processing)
- Enables rapid emergence of large-scale companies, but requires new programming paradigms and imposes new limits
- Cloud computing enabled by three pillars: **virtualized** (higher utilization, economies of scale, lower CAPEX/OPEX), **standardized** (easier access, flexible pricing, reuse, integration), **automated** (faster cycles, lower support costs, optimized security)

### Virtualization — Foundation of Cloud Computing
- **Server virtualization:** dividing a physical machine's resources into multiple isolated virtual machines (VMs)
- **History:** introduced by IBM in the 1960s (mainframe utilization); declined during client-server era (80s–90s); resurged as servers became cheap/powerful and became core to cloud computing
- **Popek & Goldberg (1974) properties of virtualization:**
  - **Fidelity:** software runs identically under the VMM as on bare hardware
  - **Performance:** most instructions execute directly on hardware without VMM intervention
  - **Safety:** the VMM controls all hardware resources

### Hypervisor (Virtual Machine Monitor)
- Software layer providing VM abstraction, managing multiple OSes and their resource needs
- **Type 1 (bare-metal):** runs directly on hardware (e.g., VMware vSphere, Xen)
- **Type 2 (hosted):** runs atop a host OS (e.g., VMware Workstation, VirtualBox)

### CPU Virtualization Techniques
1. **Full virtualization via binary translation** (e.g., VMware vSphere)
   - All sensitive/privileged instructions are intercepted and replaced via binary translation with calls emulated by the VMM
   - Guest OS unmodified; user-level code runs at native speed; hypervisor caches translations
2. **Paravirtualization / OS-assisted** (e.g., Xen)
   - Requires modifying the guest OS kernel to replace non-virtualizable instructions with **hypercalls** to the hypervisor
   - Hypervisor exposes APIs for memory management, interrupts, timekeeping
   - Lower overhead than full virtualization, but poor compatibility/portability and high maintenance burden (deep kernel modifications)
3. **Hardware-assisted virtualization** (Intel VT-x, AMD-V)
   - New CPU execution mode (root mode "Ring -1") lets privileged/sensitive instructions automatically trap to the hypervisor
   - Removes the need for binary translation or paravirtualization

### Virtualization Summary
- A host OS layer (hypervisor/VMM) provides isolated "guest" OS environments
- Enables running multiple OS types in isolation, increases physical server utilization, and allows VM portability between hosts
- Simplifies administration

### Security of Virtualization
- Often perceived as inherently secure — but this is questioned (treated skeptically in the lecture)
- **Threat categories:** human mistakes, malware-based attacks, system failures
- **Human-mistake risk assessment (example ranking):**
  - **Rank 1 (highest risk, score 20):** inadequate protection, misconfiguration
  - **Rank 2 (score 16):** damage of virtual disk files
  - **Rank 3 (score 12):** VM sprawl, files deletion in virtual file system
  - **Rank 4 (score 9):** VM rollback
  - **Rank 5 (score 6):** dormant VMs
  - **Rank 6 (score 4):** loss of performance
- **Overall risk ranking in server virtualization:**
  - Highest: human mistakes — inadequate protection, misconfiguration
  - Second tier: VM escape, VM hopping, VMware vCenter compromise, abuse of privileges, virtual disk file/disk failure

### Evolution of Cloud Technologies (Timeline)
- 1970s–80s: enterprise-level virtualization → IaaS lineage; component-based computing
- 1990s: x86 virtualization, web technologies, service-oriented computing
- 2000s: hardware support for virtualization, paravirtualization, VPS/VSH → IaaS; SOA → SaaS/PaaS branches

### Cloud Computing Characteristics
- **Virtual:** software, databases, web servers, OSes, storage, and networking delivered as virtual resources
- **On demand:** elastic addition/removal of CPU, memory, bandwidth, storage
- Often leverages: massive scale, free/open-source software, autonomic computing, multi-tenancy, geographic distribution, advanced security technologies
- **Pay-as-you-go** pricing model

### Service Models ("*aaS")
- **IaaS (Infrastructure as a Service):** vendor rents virtualized hardware — networks, virtual machines, virtual file/storage servers; pay for provisioned or used capacity; includes backup services
  - Example: Amazon EC2 — elastic, hourly billing, can scale to large numbers of instances
  - Sample EC2 pricing (2018): t1.micro ($0.02/hr, 0.615GB RAM), m1.xlarge ($0.48/hr, 15GB), cc2.8xlarge ($2.40/hr, 60.5GB) — pricing has trended down over years (e.g., m4 family ~$0.10–$3.20/hr by 2022)
- **PaaS (Platform as a Service):** vendor provides a software platform/environment (e.g., for a programming model or database apps); customer builds custom solutions, vendor runs them elastically, promising better scalability/performance/dev ease
  - Examples: Force.com (Apex), Google App Engine (Python/Google), Microsoft Azure (.NET), Heroku (Ruby/Java/Python/Node on AWS), Oracle Cloud, IBM SmartCloud
- **SaaS (Software as a Service):** vendor runs complete applications remotely; customer "outsources" the function (e.g., Salesforce.com for CRM/sales contact management); vendor also handles patching/bug fixes
  - Other SaaS examples: accounting, billing, email, document handling, shared files (e.g., Google Docs)
- **Layered responsibility model** (Traditional on-prem vs IaaS vs PaaS vs SaaS): moving from on-prem to SaaS shifts management of networking, storage, servers, virtualization, OS, middleware, runtime, data, and applications progressively from client-managed to vendor/cloud-managed

### Beyond the Core *aaS Models
- Cloud mixes many models, including human-in-the-loop services (e.g., outsourced audio-to-text)
- Specialized cloud-adjacent companies:
  - **Akamai:** content delivery network (CDN) specializing in fast delivery of videos/images
  - **DoubleClick:** ad-serving — places targeted ads into web page frames

### Cloud Deployment Models
- **Private Cloud:** owned/leased by a single enterprise; internal functionality not exposed externally; behaves like SaaS from the customer's perspective
- **Public Cloud:** services offered to external users/customers (e.g., Amazon, Google Apps, Windows Azure)
- **Hybrid Cloud:** mix of private and public infrastructure; used to retain control over sensitive data while leveraging public cloud elasticity
- **Community Cloud:** a provider resells/aggregates infrastructure from other providers (public clouds or dedicated infrastructures)

### OpenStack
- Open-source cloud platform providing shared networking and storage resources across **bare metal, virtual machines, and containers**
- Core service categories: compute (Nova, Zun), storage (Swift, Cinder, Manila), networking (Neutron, Octavia, Designate), shared services (Keystone for identity, Glance for images, Barbican for secrets, Placement)
- Orchestration/lifecycle: Heat, Mistral, Senlin, Magnum, Trove, Sahara, Murano
- Operations tooling: Ceilometer (monitoring), Watcher (optimization), billing (Adjutant, CloudKitty), testing (Tempest, Rally)
- Access via Horizon (web UI), OpenStackClient/SDKs, or third-party tools (Kubernetes, Terraform, CloudFoundry)
- **Microstack:** lightweight OpenStack distribution for micro/edge clouds (installed via snap)
- Getting started options: (1) hosted private cloud — full private cloud experience without owning infrastructure; (2) public cloud — pay-as-you-go access to compute/storage/networking within minutes

### Closing Perspective
- In a sense "cloud computing" describes the now-default state of computing: full use of modern off-the-shelf systems makes one a cloud computing user by default, and it's difficult to build a fully "cloud-free" system — partly why such systems are hard to secure
- The lecture closes with a humorous reminder that confident tech predictions (e.g., "a world market for maybe five computers" — Thomas Watson, IBM, 1943) have historically aged poorly

---

## Lecture 4: Docker and Containers

### Why Containers?
- Shipping code to servers is difficult due to dependency conflicts ("works on my machine")
- Two main approaches before containers:
  - **Virtual Machines:** isolate the guest OS from the host, but are hardware-intensive and slow to start
  - **Containers (LXC):** lightweight, low-overhead, but historically had issues with security, scalability, and management

### Linux Container (LXC) Architecture
Containers are made possible by three Linux kernel features combined:
- **Namespaces** (since 2002): process isolation — each container has its own PID tree, network interface, mount points, user IDs (`mnt`, `pid`, `net`, `ipc`, `uts`, `user`)
- **cgroups / control groups** (Google, 2006; merged 2008): resource limiting and accounting — CPU, memory, block I/O, network; no VM needed
- **Copy-on-Write (CoW)** filesystem: image layers are read-only; changes are tracked in a thin writable layer; allows instant startup and image sharing; implementations: AUFS/overlay (file-level), DeviceMapper/RHEL (block-level), BTRFS/ZFS (FS-level)

The **combination of NAMESPACE + CGROUP + CoW** enables container technology.

### What Is Docker?
- Open-source engine that commoditizes LXC
- Provides a standard format for container images and a reproducible build system (Dockerfile)
- Enables creating, sharing, and running images across environments
- Architecture: Docker Client → REST Interface → Docker Engine (libcontainerd, libnetwork, graph, plugins)

### Unique Container Features
- Containers run in **user space**; processes are isolated but run directly on the host kernel (no device emulation)
- Each container has its own process space, network interface, and `/sbin/init`
- Near-native performance: CPU = native, memory = few % overhead, network = small overhead reducible to zero

### Docker on Different Platforms
- **Linux:** native, uses host kernel's cgroups and namespaces directly
- **Windows:** two modes — Windows containers (Windows Kernel, OS version must match) or Linux containers (originally Hyper-V VM; now via WSL 2 running a LinuxKit container); WSL 2 adds Kubernetes support and VPN-friendly networking
- **macOS:** requires a LinuxKit VM via HyperKit virtualization; uses its own `osxfs` file-sharing; supports multiple architectures
- **ARM (Apple Silicon):** defaults to ARM images; uses Rosetta 2 emulator as bridge to x86; force x86 with `--platform=linux/amd64`

### Building Docker Images
Two methods:
1. **run/commit loop:** `docker run` → make changes inside container → `docker commit` → repeat
2. **Dockerfile** (preferred): declarative, reproducible, version-controlled

Key Dockerfile instructions: `FROM`, `RUN`, `COPY`, `WORKDIR`, `EXPOSE`, `CMD`, `ENV`

**Multi-stage builds:** multiple `FROM` statements — one stage for building (full JDK, build tools), another for the slim runtime image; keeps final image small.

### Docker Hub
- Public image registry at `https://hub.docker.com/`; search with `docker search [term]`
- Push images with `docker login` then `docker push <user/image:tag>`
- Automated builds from GitHub Dockerfiles are supported

### Docker Compose
- Tool for defining and running **multi-container** applications via a YAML file
- Single command `docker-compose up` creates and starts all services
- Supports `volumes`, `networks`, `environment`, `depends_on`, `restart` policies

### Security Considerations
- By default, containers run as **root** — a security risk
- Mitigations: **rootless mode**, **user namespace remapping** (subordinate UID/GID), or **Enroot** (NVIDIA, per-user containers)

### GPU in Docker
- Requires NVIDIA drivers installed on the host; GPU-specific libraries go inside the image
- Pass GPUs at runtime: `docker run --gpus all ...`
- Docker Compose: use `deploy.resources.reservations.devices` with `capabilities: [gpu]` and optionally `device_ids`
- Common base images: `nvidia/cuda:*` or pre-installed `nvcr.io/nvidia/pytorch:*`; watch out for version mismatches and large image sizes

### Docker Use Cases
Development environments, integration testing, quick software evaluation, **microservices**, multi-tenancy, and a unified dev→test→prod execution environment (local, VM, cloud).

### Alternatives to Docker
- **Podman:** daemonless architecture; containers run under user privileges (rootless by design)
- **Singularity:** popular in HPC environments

---

## Lecture 5: Kubernetes (K8s) and GitLab CI

### Motivation: The Problem with Standalone Docker
- Running many containers on a single Docker host creates a **single point of failure**
- Managing microservices at scale requires scheduling, self-healing, scaling, and service discovery — leading to **container orchestration**

### What Is Kubernetes (K8s)?
- Portable, extensible, open-source **orchestration platform** for containerized workloads and services
- Follows a **client-server architecture** with master and worker nodes
- Users define rules (desired state); K8s continuously reconciles the actual state to match
- Large, rapidly growing ecosystem; widely supported by cloud providers

### K8s Architecture
- **Master (control plane):** API Server, Controller Manager, Scheduler, etcd (distributed key-value store for cluster state)
- **Worker Nodes:** Kubelet (node agent), cAdvisor (resource monitoring), Kube-Proxy (networking), Container Runtime; run **Pods**
- Nodes communicate via a Plugin Network (Flannel, Weavenet, etc.)

### Core Concepts

| Concept | Description |
|---|---|
| **Cluster** | Collection of hosts aggregating CPU, RAM, disk into a usable pool |
| **Master** | Control plane components; responsible for all cluster decisions |
| **Node** | Single host (physical or virtual) managed by the master, runs pods |
| **Namespace** | Logical cluster/environment; primary method for scoping access |
| **Label** | Key-value pairs for identifying and grouping objects (strict syntax) |
| **Annotation** | Key-value metadata without syntax limitations (structured or unstructured) |
| **Selector** | Filters/selects objects using labels (equality-based or set-based) |

### Workload Objects
- **Pod:** smallest unit in K8s; one or more containers sharing storage, network, and context (namespace, cgroups)
- **ReplicationController:** manages pod replica lifecycle (scheduling, scaling, deletion)
- **ReplicaSet:** next-generation ReplicationController; supports set-based label selectors
- **Deployment:** declarative management of stateless Pods/ReplicaSets; supports rollbacks and granular update control

### Storage
- **Volumes:** mounted into Pod containers; can be ephemeral (`emptyDir`) or persistent/cloud-backed (`awsElasticBlockStore`)
- **Persistent Volumes (PV):** cluster-wide resource; parameters include Capacity, `accessModes` (ROX = ReadOnlyMany, RWO = ReadWriteOnce, RWX = ReadWriteMany), `persistentVolumeReclaimPolicy` (Retain / Recycle / Delete), and StorageClass

### Configuration
- **ConfigMap:** externalized data referenced as env vars, command-line args, or mounted files; separates config from container image
- **Secret:** functionally identical to ConfigMap but stored base64-encoded and encrypted at rest (if configured); used for credentials and keys

### Networking
- **Service (L4):** exposes a stable virtual IP for a Pod group selected via labels; types: ClusterIP (internal), NodePort, LoadBalancer
- **Ingress (L7):** exposes HTTP/HTTPS from outside the cluster to services; provides SSL/TLS termination, name-based virtual hosting, URL rewrites; defined in YAML with paths, backends, and optional TLS secrets
- **Internal networking:** built-in DNS (namespace-scoped; cross-namespace via `pod_name.namespace`)
- **External access:**
  - **Ingress (L7):** shared IP, path-based routing, SSL termination
  - **NodePort:** exposes a port on each node; service reachable at `NodeAddress:NodePort`
  - **LoadBalancer:** cloud provider's external LB; gets own IP; L4 (TCP/UDP)

### Auto-scaling
- **HPA (HorizontalPodAutoscaler):** deploys more Pods in response to increased load
- **VPA (VerticalPodAutoscaler):** allocates more CPU/memory to existing Pods; both scale back down when load decreases
- Support custom resource metrics (e.g., RabbitMQ queue length)

### MiniKube
- Deploys a local single-node K8s cluster for development/practice
- Commands: `minikube start`, `minikube stop`, `minikube delete`

### kubectl (Key Commands)
`kubectl create -f <file.yaml>`, `kubectl get deployment/pods/services`, `kubectl expose deployment --type=LoadBalancer --port=<n>`, `kubectl delete service/deployment <name>`

---

### Continuous Integration (CI)
- Software-development practice: team members integrate their work **frequently** (typically multiple times per day)
- Each integration is verified by an **automated build**: compile code + run automated tests
- Very often integrated with version-control repositories

### GitLab CI
- Fully integrated with the GitLab platform; no separate CI server needed
- Pipelines defined in a `.gitlab-ci.yml` file at the repo root
- Triggered by **push** or a **cron-like scheduler**
- Requires a **Runner** (a Docker container acting as executor); registered with a runner token
- Supports masked project/group **variables** for secrets (e.g., registry passwords)
- Jobs in the same stage can run in parallel; if a job fails, subsequent stages are skipped

**Pipeline structure (`gitlab-ci.yml`):**
- `image`: base Docker image for the pipeline
- `stages`: ordered list of stage names (e.g., check_style → tests → pages → build_master)
- Each **job** specifies: `stage`, `before_script` (setup), `script` (main task), `artifacts` (files to save), `only`/`except` (branch filters), `image` (per-job override)

**Typical pipeline tasks:** code style checks (pep8/docstyle), running unit tests (pytest), saving HTML coverage reports as artifacts, publishing to GitLab Pages, building and pushing Docker images to the GitLab Container Registry

---

## Lecture 6: Basic Concepts of Security and Trust

### Security Fundamentals
- A **computer is secure** if software performs according to specification and the user can trust it
- A **network is secure** if it ensures privacy and trustworthiness of data
- Security depends on technology investments but **even more on human behaviour** — most incidents exploit human errors (humans are the **weakest link**)
- **Web transaction security** requires: infrastructure security (network, server, client workstation), software security, and network communication security

### Threat Categories
- **Common threats:** data corruption/loss (need secure backups), privacy/data disclosure, unauthorized operations
- **Network/Internet threats:** increased risk of external attacks, anonymous attacks, limited legal protection across jurisdictions
- **Web transaction threats:** credibility of orders, non-repudiation (irrefutability), protection of user-entrusted data

### Encryption
- Transforms **plaintext** into **ciphertext** using an **encryption key**; reversed with a **decryption key**
- Security property: knowing plaintext and ciphertext together is **insufficient** to determine the key(s)
- **Keys ≠ passwords** — keys are fixed-size binary values, far longer than typical passwords

### Types of Ciphers

| Property | Symmetric (Bulk) | Public Key (Asymmetric) |
|---|---|---|
| Keys | Single shared key for encrypt + decrypt | Separate keys; private cannot be derived from public |
| Performance | Fast; usable in real-time | Numerically complex (slow) |
| Key size | 64–256 bits | 1024–2048 bits |
| Primary use | Bulk data encryption | Key exchange, digital signatures |

### Cipher Security — Brute-Force Attacks
- Breaking a cipher requires disclosing the secret/private key
- **Brute-force (exhaustive key search):** tests all 2^l key permutations; complexity is exponential in key length
- Maximum time to crack: **t = τ × 2^l** (where l = key length in bits, τ = time to test one key)
- For l = 128 bits: ~2.56 × 10³⁸ permutations → at τ = 1 μs, requires **10²⁵ years** — computationally infeasible

### Cryptanalysis
- Discipline that seeks weaknesses in cipher algorithms to **reduce** the number of key candidates below 2^l
- Methods classified by attacker capability: ciphertext-only, known-plaintext, chosen-plaintext, adaptive chosen-plaintext, chosen-ciphertext, adaptive chosen-ciphertext

### Bulk (Symmetric) Ciphers
- **Stream ciphers:** XOR plaintext bit-by-bit with a pseudo-random bit stream (e.g., RC4, Vernam one-time pad); security depends on the quality of the random number generator
- **Block ciphers:** split input into fixed-size blocks, encrypt each using the same cipher and key; current adopted standard is **AES**

**Block cipher modes of operation:**
- **ECB (Electronic Codebook):** blocks encrypted independently — identical plaintext blocks produce identical ciphertext (weak; reveals patterns, as visible in the Linux Tux image example)
- **CBC (Cipher Block Chaining):** each block XORed with the previous ciphertext block before encryption
- **CFB (Cipher Feedback)** and **OFB (Output Feedback):** convert a block cipher into a stream cipher
- **CTR (Counter Mode):** encrypts an incrementing counter + nonce, then XORs result with plaintext — parallelizable
- **OCB (Offset Codebook Mode):** provides both encryption and authentication (integrity) in a single pass, outputting a Tag/checksum

### Public Key Cryptography
Based on mathematically "hard" (computationally infeasible) problems:
- **RSA:** based on multiplicative inverse and prime factoring; uniquely, the public key can be used for either encryption or decryption
- **Diffie-Hellman / ElGamal:** based on discrete logarithms; primarily used for key exchange
- **DSA (Digital Signature Algorithm):** based on discrete logarithms; used only for signatures, not encryption

### Practical Cipher Applications
- **Bulk encryption (data transmission/storage):** symmetric ciphers; require a pre-shared session key
- **Key exchange:** public key ciphers establish the shared session key over a public channel; in data transmission, public key crypto is used to set up the session key, then symmetric crypto handles the data

### Message Enveloping (Digital Envelope)
A method for sending a confidential message without a pre-shared secret:
1. Sender generates a **random one-time session key**
2. Session key encrypts the plaintext using a bulk cipher
3. Session key is encrypted with the **recipient's public key**
4. Message = encrypted letter + encrypted session key
5. Recipient decrypts the session key with their **private key**, then decrypts the letter

Limitation: **the sender's identity cannot be authenticated** by this method alone.

### Digital Signatures
Originally designed to authenticate electronic mail and other electronic documents.

**Signing process:**
1. Compute a secure **cryptographic digest** (hash) of the document
2. Encrypt the digest with the **author's private key**

**Verification process:**
1. Decrypt the received digest using the **author's public key**
2. Independently compute the digest of the received plaintext document
3. Compare both digests — if equal, the signature is valid

The author's public key is typically extracted from a **certificate** distributed alongside the signature.

**What digital signatures DO provide:**
- **Authentication:** confirms the identity of the signer
- **Integrity:** any modification to the document is detectable
- **Non-repudiation (irrefutability):** the signer cannot deny authorship

**What digital signatures do NOT provide:**
- **Confidentiality** (the document remains plaintext)
- **Anti-spoofing** alone — relies on the certificate infrastructure for that

### Cryptographic Hash (Digest)
- Maps a **variable-length** byte/character string to a **fixed-size** digest: `digest = H("text string")`
- Properties: uniform distribution of outputs; **avalanche effect** (small input change → large, unpredictable digest change)
- Secure hash requirements: computationally infeasible to find a preimage for a given digest; digest reveals no plaintext fragments; digest must be long enough to resist brute-force
- Common algorithms: **MD5**, **SHA-1**, **SHA-2**, **SHA-3**

### Message Authentication Code (MAC)
- Prevents **data forgery during transmission** (provides integrity, not full authentication)
- **MAC:** compute message digest → encrypt digest with symmetric session key (algorithms: SHA1/RC4, MD5/RC2)
- **HMAC (Hash-based MAC):** simplified variant — concatenate message + session key → compute a single digest; no separate encryption step; requires a very strong hash algorithm to prevent session key disclosure

**Digital Signature vs. MAC:**

| Property | Digital Signature | MAC |
|---|---|---|
| Cryptography | Public key (asymmetric) | Symmetric key |
| Authentication | Yes | No |
| Non-repudiation | Yes | No |
| Confidentiality | No | No |
| Performance | Slower | Faster |

---

## Lecture 7: Secure Network Protocols & Public Certificates

### Public Certificates

**The spoofing problem:** how to trust a public key actually belongs to its claimed owner?

**Solution — Certificate Authority (CA):**
- A trusted third party vouches for the identity of the public-key owner by issuing an electronic document (certificate) that:
  - Identifies the certificate owner
  - Includes the owner's public key
  - Specifies the validity period (expiry)
  - Specifies the legal/permitted applications of the certificate
- CA signs the certificate with **its own private key**, vouching for authenticity
- CA includes its own certificate to prevent spoofing of the CA itself
- **CA certificate chain:** Root CA has a **self-signed** certificate (a self-signed certificate alone does not prevent spoofing — trust must come from elsewhere, e.g., a pre-installed trusted root list)

**Certificate fields:**
- Named fields (text, numbers, bitstrings)
- Owner identity + public key
- Period of validity (from–until)
- Purpose (identify a server / identify a user / sign other certificates)
- Unique serial number

**Revocation of certificates:**
- Certificates expire naturally when the validity period ends
- CA can actively revoke a certificate before expiry:
  - **CRL (Certificate Revocation List):** signed by the CA, publicized, held locally by clients and regularly updated
  - **OCSP (Online Certificate Status Protocol, RFC 2560):** verifies certificate validity online in real time

**Certificate types (3 main usages):**
- **CA institution certificate** — certified by a public entity, or self-signed (root)
- **Server certificate** — client software uses it to verify server identity
- **User certificate** — used for self-identification, message enveloping/signing, authentication/authorization

**Certificate development:**
- Certificate request includes name + generated public key
- Name uses a standardized format: **Distinguished Name (DN)**, related to X.500 directory services; DN is a hierarchy of fields, with **Common Name (CN)** as the leaf field
- Private key generated separately and kept in an encrypted key file; public key goes into the certificate
- CA signs the certificate request with its private key

**Policy of trust:**
- Value of a certificate depends on (1) trustworthiness of the issuing CA, and (2) how rigorously the CA verified the owner's identity
- **Certification Practice Statement (CPS):** a CA's public declaration of its identity-verification procedures, confidential-data protection, anti-forgery measures, CRL distribution, and requirements on subordinate CAs — usually published on the web, sometimes linked from within the certificate itself

**Models for building trust:**
| Model | Description |
|---|---|
| **Hierarchical (PEM)** | Central authority IPRA → trust-level authorities (PCA) → issuing CAs |
| **Public (PKIX)** | Certificates include legal usage + CPS; any institution can create a self-signed Root CA; trusted Root CA lists are pre-installed in user software |
| **Distributed (OpenPGP)** | Everyone trusts their own certificates; anyone can add a signature expressing their trust level in someone else's certificate; personal/accumulated "webs of trust"; key-signing parties |

**Standardization of cryptographic data formats:**
- **X.509** (CCITT/ISO/IEC) — v1 in 1988 (part of X.400 mail / X.500 addressing docs, ANS.1/DER encoded), current v3 since 1996
- **PEM (Privacy Enhanced Mail)**, RFC 1421–1424 — hierarchical trust model; PEM encoding = DER, MIME base64-encoded with separators
- **PKCS#1–PKCS#12** (RSA Laboratories) — documents ANS.1/DER encodings for cryptographic formats; packaging of certificates, CRLs, and keys
- **PKIX working group (IETF)** — RFC 2459 / RFC 5280: X.509 certificate and extension fields for Internet use
- Vendor formats: Netscape SPKAC, Microsoft formats

**Public data format map:** Private key / Encrypted private key / DER-PEM-encoded private key combine into a "Set of keys" (SPKAC, PEM) or, together with a Certificate (X.509 signed by CA), into "Encoded private key + certificate" (PEM/PKCS#12); a Certificate with a CRL forms PKCS#7; certificate chains use PEM/PKCS#12.

**RFC 2459/5280 certificate structure** (ANS.1, DER-encoded):
- **Outer fields:** Certificate-TBS (to-be-signed), signing cipher suite (MD2/RSA, MD5/RSA, SHA-1/RSA, SHA-1/DSA), Signature (bitstream)
- **Certificate-TBS fields:** Version (v1=0, v3=2), Serial number, signing cipher suite, Issuer DN, Validity period, Subject (owner) DN, Public key, Extensions
- **DN fields:** Country (C), Organization (O), Organizational Unit (OU), Common Name (CN) — for server certs, CN should be the server's domain name; optional fields like city/postal code (not email); DN must be unique and is compared as a whole entity
- **Public key fields:** cipher suite identifier (RSA, Diffie-Hellman, DSA) + key value
- **Key extensions:** Authority/Subject Key Identifier (multiple keys per owner), Key Usage/Extended Key Usage (permissible usages), Certificate Policies (CPS link/description), Subject Alternative Name (domain, http, or email), Name Constraints (limits on certifiable DN branches), CRL Distribution Points

---

### Secure Communication

**Secure communication underlies all electronic business applications.**

**Threats** (client ↔ network ↔ server, plus a possible false server/client in the middle): eavesdropping, spoofing, forgery, replay attack, vulnerability exploitation

**Aims of communication encryption:**
- **Confidentiality** — protects private data, limits access to authorized users, protects client trust/privacy
- **Data integrity** — encryption alone breaks (rather than detects) tampered ciphertext; **encryption alone is not sufficient** for integrity
- **Sender authentication** — encryption gives only weak authentication, based on a shared secret
- **Replay-attack protection** — requires session keys; encryption alone is insufficient

**Protocol layers used for encryption** (client ↔ server stack):
| Layer | Mechanism |
|---|---|
| Data-link | Scrambling |
| IP | IPsec |
| TCP/UDP | SSL / TLS |
| Application | SSH |

**SSL and TLS:**
- SSL = Secure Socket Layer; TLS = Transport Layer Security
- Originally developed by Netscape Communications Corp.; model implementation by RSA Securities (which held most SSL implementation patents); popular open-source implementations: SSLeay (E. Young) and OpenSSL
- Transport-level protocol underlying application protocols: HTTPS, POPS, IMAPS, etc.

**Components of SSL communication:**
- Connection encrypted with a negotiated **symmetric cipher** (null-encryption can even be negotiated)
- Connection integrity via **MAC or HMAC**
- A randomly generated **session key** is used for encryption and MACs, exchanged via a negotiated public-key algorithm (RSA, Diffie-Hellman)
- **Server is authenticated via its certificate**
- Optional compression; runs over TCP

**ClientHello / ServerHello negotiation:**
- SSL protocol version
- Cipher Suite: key-exchange algorithm (RSA, Diffie-Hellman) + symmetric cipher (Null, RC4 40/128, RC2 40, AES 128/256, 3DES, IDEA, Fortezza) + MAC algorithm (Null, MD5, SHA1)
- Compression
- Session key negotiation
- Server authentication (optionally client authentication too)

**HTTPS:**
- HTTP messages carried over an SSL/TLS link
- Client signals the need for an encrypted connection via the URL scheme: `https://normal_URL_format`
- Default port **443** (not port 80, the HTTP default) — allows a single server to serve both HTTP and HTTPS
- Combined HTTP+HTTPS page content reduces server-side processing
- Popular implementation: Apache with `mod_SSL`

**Secure Apache configuration directives:**
- `SSLEngine on`
- `SSLCertificateFile` / `SSLCertificateKeyFile` — server certificate and private key files; required for server authentication; certificate **CN must match the server's DNS name**, and the **SAN (Subject Alternative Name)** extension should also carry the DNS address; optionally separate RSA/DSA files; virtual-server DNS aliases complicate this
- `SSLPassPhraseDialog` — how to decrypt the server's private key
- `SSLCertificateChainFile` — the server's CA certification chain

**Client (certificate-based) authentication directives:**
- `SSLVerifyClient` — none / optional / optional_no_ca / require
- `SSLVerifyDepth` — max length of the CA certification chain (small is safer; 1 = certificate must be issued by a directly known CA)
- `SSLCACertificatePath` — directory of recognized CAs (linked via `#hash.N` derived from the certificate DN)
- `SSLCARevocationPath` — directory of recognized CAs' CRLs
- The user must supply their own certificate (soft copy or on a USB key) to be authenticated

---

## Lecture 8: Secure Electronic Payments (Security of Banking Transactions)

**Electronic access to bank accounts:**
- Secure HTTPS connection; server certificate from a trusted CA (e.g., VeriSign, Entrust) prevents spoofing; bank must ensure a secure encryption level
- Authentication to the server: simple passwords (vulnerable to client-side malware), single-use passwords, identification tokens/USB keys
- Additional authorization for sensitive operations: PIN via an independent channel (SMS to mobile phone), phone authorization

**Bank transfer:**
- Payer initiates a transfer stating the recipient's account (IBAN)
- Payer's bank messages the recipient's bank to remit funds (secure channel, e.g., **SWIFT**), carrying the data needed for interbank settlement
- Without a direct interbank settlement agreement, a **correspondent bank** is used
- In Poland: **ELIXIR**, run by Elektroniczna Izba Rozrachunkowa
- Transaction hazard: relatively safe since both payer and recipient are authenticated, but danger exists with anonymous recipients, and **transactions are irrevocable** (fraud risk)
- Smartphone payments are an emerging channel

### Payment Cards

**By function:** credit cards, charge/debit cards, pre-paid cards & electronic purse

**By technology/classification:** embossed-print cards, magnetic-stripe cards, smartcards, contactless (RFID) cards, virtual cards (ePayments), mobile

**By transaction channel:** ATM (cash dispenser), point-of-sale (POS), remote payments (CNPT — Card Not Present Transaction)

### Card Transactions

**Remote transactions (Card Not Present — phone/web):**
- Cardholder provides account name, card number, expiry (read from card), and **CVC2/CVV2/CID** (3–4 digit security code)
- Transactions may be revoked (**chargeback**)
- High risk — the issuing bank bears responsibility for fraudulent transactions

**Point of Sale (POS):**
- Offline credit transactions (limited value)
- Online credit transactions with real-time available-credit validation
- Charge cards with online account charging (often charged with a delay)

### Security of POS Transactions

- **Card authentication:** physical plastic properties/watermarks, CVV1 on the magnetic stripe, encrypted communication between POS terminal and smartcard chip
- **Transaction authorization:** based on data recorded on the card, or via online communication with the issuer bank
- **Ensuring irrefutable transactions:** printed embossed text, cardholder signature on the transaction, PIN validated online or offline
- **Risk:** merchants risk fraud; cardholders risk identity theft; **smartcards are the safest** option for both parties
- **EMV** (Europay, Mastercard, VISA) is the common standard for chip ↔ POS/ATM communication

### SET Protocol

- **SET = Secure Electronic Transaction** — joint MasterCard/VISA proposal for secure card payments over the Internet
- Ensures confidentiality, data integrity, and authentication of both payer and merchant
- Involves **four organizations**: cardholder, card issuer (bank), merchant (authorized for SET), and acquirer bank

**Electronic shopping flow:**
- *Client:* browses for goods/suppliers → selects items (shopping cart) → fills in order form → authorizes electronic payment with issuer bank → sends payment-info form to merchant
- *Merchant:* requires payment confirmation from acquirer bank → acknowledges transaction to client → fulfills order → initiates money transfer from issuer to acquirer bank

**Privacy design goal:** the merchant should not gain information that would allow access to the client's bank account (to prevent fraud/identity theft); banks should have only limited information about the transaction (no information about the goods purchased).

### 3D Secure

- Supersedes SET roughly 2005–2010; based on SSL and XML documents
- Branded products: **Verified by VISA** (VISA), **Secure Payment Application / SPA** (MasterCard)
- **3 Domains:** Interoperability Domain (central Visa/MasterCard systems), Acquirer Domain (payment gateways/merchant), Issuer Domain (banks/client accounts)
- **Flow:** Cardholder sends shopping data to merchant → merchant's payment gate (MPI) sends Authentication Request through the Interoperability Domain → reaches the Issuer's Access Control Server (ACS) → cardholder authenticates via an issuer-specified method → response flows back through the chain → acquirer performs authorization and payment processing

**3D Secure cardholder experience:**
- Payment gate opens a widget (dialog or iFrame) granting direct access to the issuer bank
- Bank displays a **Personal Assurance Message (PAM)** to prevent spoofing
- Cardholder logs into their bank account (typically via password) to authorize the payment

### Mobile Phone Card Transactions

- **Schemes:** Wallet (card data stored in-app), one-time card (requires issuer-bank support), **Google Pay**
- **Google Pay:** supports both POS and CNPT transactions; does **not** store card data on the phone, improving security if the phone is stolen
- **Google Pay user experience:**
  - Registration: card data scanned/entered → app obtains a device-specific secure token from the issuer bank → raw card data is never stored on the phone; only the encrypted token is kept
  - Payment: token decrypted via phone authentication (e.g., fingerprint) → secure EMV communication validates the transaction → **NFC** for POS; **SSL** for online shops supporting Google Pay

---

## Lecture 10: IT Service Management (ITIL/ITSM)

### IT Infrastructure

Components: Hardware, Software, Connectivity, Procedures, Documentation, and **People**

### What is ITIL?

- **ITIL (IT Infrastructure Library):** a library of volumes describing a framework of **best practices** for delivering IT services (a best practice = a method/technique consistently shown to outperform alternatives, used as a benchmark)
- Created from best industry practices; defines a common language for IT and business; **platform independent**
- **ITIL 4** released **February 28, 2019**
- Originally developed during the 1980s by the British government's **Central Computer and Telecommunications Agency (CCTA)**, later merged into the Office of Government Commerce

**ITIL benefits:** reduced IT costs, improved IT services via proven best-practice processes, improved customer satisfaction, clear standards and guidance, improved productivity, better use of skills/experience, improved third-party service delivery (via ITIL/BS15000 as a procurement standard)

**ITIL timeline:** 1988 — first ITIL books published (same year the term "Lean" was coined for the Toyota Production System) → 2001 — ITIL service delivery & support (same year the Agile Manifesto was published online) → 2007 — ITIL service lifecycle → 2011 — ITIL business alignment → 2014 — DevOps emerges (addressing the Dev/Ops "wall of confusion") → **Today — ITIL 4: The Service Value System**

**ITIL v3** — a process model built on best industry practices, organized around: Service Delivery, Service Support, Application Management, Security Management

**UPs and DOWNs of ITIL:**
| UPs | DOWNs |
|---|---|
| Process description standard | Not a methodology for streamlining processes |
| Focus on processes, not technologies | Defines "what" but not "how" |
| Integrates processes | Does not include "all" processes |
| Standardization improves quality and profitability | Does not cover organizational issues |
| Customer focus (through service) | Media noise leads to unrealistic expectations |

**What ITIL is NOT:**
- NOT a "universal tool" for solving problems
- NOT a strictly enforced norm — it's a collection of best practices
- Does NOT define specific procedures
- It does strive to improve/increase efficiency, minimize risks, and meets the requirements of **ISO 9001** quality standards

### What is ITSM?

**IT Service Management (ITSM):** a set of specialized organizational capabilities for providing value to customers in the form of IT services — implementing and managing quality IT services that meet business needs, carried out by IT service providers through an appropriate mix of **people, process, partners, and information technology**. **ITIL is the preeminent best-practice framework for ITSM.**

### Service Management — Core Concepts

- **Service:** a way to provide *value* to clients by enabling them to achieve expected results while avoiding unnecessary costs and risks
- **Service Management:** a set of specialized organizational capabilities that provide value to the customer in the form of service
- **Process:** a set of actions aimed at achieving specific goals and providing value to clients/stakeholders; a strategic advantage in market diversification and competitive edge; is measurable, has output = concrete results, provides results to clients/interested parties, and reacts to specific events
- **Roles:**
  - **Service owner / Service manager** — establish responsibilities for the lifecycle of specific services
  - **Process owner / Process manager / Process practitioner** — identify responsibilities in ITSM process management and execution
  - **Process practitioner examples:** Configuration manager, Capacity manager, Service Desk specialist — describing specific responsibilities within certain processes and functions
- **Function:** a team or group of people and tools used to perform one or more processes or activities
- **Role:** a set of duties, actions, and authorities granted to a person or team
- **Service model:** a cycle of **Vision → Processes → Procedures → Tasks**

> **Note (not on the slides, standard ITIL knowledge):** The slides use the word *value* only inside the Service/Service Management/Process definitions above — there's no dedicated "Value" definition slide. For exam purposes, ITIL defines **Value** as the *perceived benefits, usefulness, and importance of something* — it is **subjective** and judged **by the customer**, not the provider. It is **not** the cost of the service, **not** the number of users, and **not** a technical metric like uptime. Value = **Utility** (fit for purpose) + **Warranty** (fit for use).

### Service Lifecycle

5 stages of the service lifecycle = the 5 basic ITILv3 books, driving toward **business value realization** via **continual service improvement**:

| Stage | Key Processes |
|---|---|
| **Service Strategy** | Service Strategy for IT Services, Service Portfolio Management, Business Relationship Management, Financial Management for IT Services, Demand Management |
| **Service Design** | Design Coordination, Service Catalog Management, **Service Level Management**, Availability Management, Capacity Management, IT Service Continuity Management, Information Security Management, Supplier Management |
| **Service Transition** | Transition Planning and Support, **Change Management**, **Service Asset & Configuration Management**, **Release & Deployment Management**, Service Validation, Change Evaluation, **Knowledge Management** |
| **Service Operation** | Event Management, **Incident Management**, Request Fulfillment, **Problem Management**, Access Management — plus Functions: Service Desk, Technical Management, IT Operations Management, Application Management |
| **Continual Service Improvement** | Seven Step Improvement |

Governance Processes flank the cycle on both ends (Service Portfolio Mgmt/Strategy generation on entry; Service reporting/measurement/improvement on exit), while the Operational Processes run through Service Design → Service Transition → Service Operation.

### Key ITIL Processes (Detail)

- **Incident Management** — *Incident:* an unplanned interruption to an IT service, or an unplanned reduction in its quality. *Process aim:* remove the incident ASAP to restore the agreed service level. Steps: incident diagnosis → registration → categorization → prioritization.
- **Problem Management** — *Problem:* the underlying cause of one or more incidents. *Process aim:* find & remove the root cause via a change (**Request For Change**). A **workaround** is a temporary solution; the symptoms of incidents plus their workarounds are called **known errors**. Flow: Error in Infrastructure → Incidents → Problems → Known Error → RFC → Solutions.
- **Service Asset & Configuration Management** — *Process aim:* build and maintain a **Configuration Management Database (CMDB)** holding the resources (**Configuration Items, CIs**) needed for service delivery. The CMDB stores CI descriptions and their mutual relations, at a level of detail appropriate to the need.
- **Change Management** — A **Configuration Item (CI)** is a single element needed for service delivery. A **Request For Change (RFC)** of one or more CIs is the basis for starting the change management process. *Process aim:* ensure changes are implemented in a controlled manner with minimal disruption to the business.
- **Knowledge Management** — *Process aim:* right decision-making, knowledge transfer, qualification management, etc. A **Knowledge Management System** is maintained as part of this process and should be integrated with the CMDB.
- **Release & Deployment Management** — *Process aim:* technical build of a software package, testing, and implementation of a service or change, ensuring the recipient can use the service efficiently. Modeled as an infinite loop: code → build → test → plan → release → deploy → operate → monitor. Stages **Development → Test → Production → Archive** all feed entries into the **CMDB**.
- **Event Management** — *Event:* any registerable status change of a CI needed to perform the service. *Process aim:* monitoring, registration, and categorization of events in the IT environment that provides services.
- **Service Level Management** — *Process aim:* an agreement ensuring the terms of providing a specific service to a specific recipient; conditions are recorded in a **Service Level Agreement (SLA)**. Starting points: standard conditions specified in the **Service Catalog**, and the **Service Level Requirements** of the service recipient.

### Metrics & KPIs

- Guiding principle: *"You can't control what is undefined. You can't measure what is not under control. You can't improve what is not measured."*
- **Key Performance Indicator (KPI):** a measurable value indicating how effectively a company achieves key business goals — tells the organization whether it is **on track** (or not)
- **Metric:** a quantitative measure used to track and assess the status of a specific business process. Metrics are **NOT** KPIs themselves, but they are **required to determine** whether KPIs have been met
- **Worked example:**
  - Business goal (**KPI**): manufacture **20,000 SSDs/year**
  - Current status (**Metric**): **5,000** produced in 10 months
  - Calculation: 5,000 / 20,000 × 100% = **25%**
  - Conclusion: **unlikely that the goal will be achieved**

### Continual Service Improvement (CSI)

**Activities:** monitoring compliance with processes/procedures, monitoring the effectiveness of services/processes, monitoring the performance of services/processes

**Deming cycle (Plan-Do-Check-Act, proposed by William E. Deming):** a diagram illustrating the basic principle of continuous improvement
- **Plan** — plan who, what, when, and how to do it
- **Do** — make the planned changes
- **Check** — check the results
- **Act** — update the plan according to the results

### 4 P's of Service Management

| P | Examples |
|---|---|
| **People** | skills, training, communication |
| **Processes** | actions, activities, changes, goals, improving paths |
| **Products** | tools, monitors, measures, documents |
| **Partners** | vendors, specialists, suppliers |

### Service Delivery Levels (recap, ITIL framing)

- Layered stack: **Application SW** → **OS & Middleware** → **HW & Bld Infrastructure**, mapped to the **SaaS / PaaS / IaaS** pyramid
- Responsibility split across On-premises / IaaS / PaaS / SaaS for: Application, Data, Runtime, Middleware, Operating system, Virtualization, Networking, Storage, Servers — moving from user-managed (dark) toward provider-managed (light) as you move from on-premises to SaaS

### Why ITIL Makes Sense

- Introduces a common language to understand both "pages" (sides) — IT and business
- Enables the service provider to adapt to the needs of the service recipient
- Allows realistic service levels to be agreed, delivering necessary value at an acceptable cost
- Defines specific processes with documented responsibility for each activity
- Processes can be monitored based on Service Level Agreements (SLAs) and improved if necessary (**CSI**)

---

## Lecture 12: Service Level Management, Availability & Continuity Management

### Service Level Management (SLM)

**Process aim:** agree and ensure the terms of providing a specific service to a specific recipient.

Key documents in SLM:
- **SLR (Service Level Requirements):** a document stating the customer's requirements for services they want to use
- **Service Specification:** translation of customer requirements into how the supplier will provide them
- **SLA (Service Level Agreement):** a document setting agreed service levels between a customer and a service provider
- **OLA (Operational Level Agreement):** agreed service levels between an organisation and an *internal* provider (e.g., another department)
- **UC (Underpinning Contract):** agreed service levels between an organisation and an *external* supplier/vendor
- **SQP (Service Quality Plan):** contains key performance indicators of the IT organisation in the field of service measurement

**Relationship diagram:** Business customer ↔ SLR/SLA ↔ IT department ↔ OLA ↔ Internal partner; IT department ↔ UC ↔ External partner

---

### Availability Management

**Process aim:** maintain the levels of services written in SLAs in order to meet current and future (agreed) needs of the enterprise in a cost-effective manner. This applies to *services and configuration elements — not people*.

#### Key Definitions

| Term | Definition | Metric |
|---|---|---|
| **Availability** | Ability of a service/CI to perform the required function at a given time, expressed as a percentage | `(Agreed Service Time − Downtime) / Agreed Service Time × 100%` |
| **Reliability** | How long a service/CI can perform agreed functions without interruption | **MTBF** = `(Available time − Total downtime) / Number of breaks`; **MTBSI** = `Available time / Number of breaks` |
| **Maintainability** | How quickly and efficiently a service/CI can be restored after a failure | **MTRS** = `Total downtime / Number of breaks` |
| **Serviceability** | Ability of a supplier/entity to meet the terms of the contract — includes agreed levels of Availability, Reliability, and Maintainability | — |

**Improving reliability:** increase reliability of individual elements *and/or* increase service resilience to failure of individual elements.

**Incident lifecycle (timeline):**
Detection → Diagnosis → Repair → Restore → Operation
- **Downtime (failure)** = Detection + Diagnosis + Repair (→ MTRS = Maintainability)
- **Uptime (operation)** = Restore → next Incident (→ MTBF = Reliability)
- **MTBSI** spans from one Incident Start to the next (includes both downtime and uptime)

#### Calculation of Availability Levels

**Serial configuration** — all components must be available:
```
A = A_H × A_N × A_S × A_W
```
Example: 0.98 × 0.98 × 0.975 × 0.96 = **0.8989** (≈ 89.89%)

**Parallel (redundant) configuration** — system works if at least one component works:
```
A = 1 − (1 − A_x)^n
```
Example (doubled host at 98%): A_H = 1 − (0.02 × 0.02) = **0.9996**

Applying redundant host to the serial chain: 0.9996 × 0.98 × 0.975 × 0.96 = **0.9196** (≈ 91.96%)

#### Availability Expressed in "Nines"

| Nines | Availability | Downtime/year | Downtime/month | System class |
|---|---|---|---|---|
| One 9 | 90% | 36 d 17 h 20 m | 72 h | 1 — Unmanaged |
| Two 9s | 99% | 3 d 11 h 20 m | 7.2 h | 2 — Managed |
| Three 9s | 99.9% | 8.76 h | 43.2 m | 3 — Well Managed |
| Four 9s | 99.99% | 52.56 m | 4.32 m | 4 — Fault Tolerant |
| Five 9s | 99.999% | 5.26 m | 25.9 s | 5 — High-Availability |
| Six 9s | 99.9999% | 31.5 s | 2.59 s | 6 — Very-High-Availability |
| Seven 9s | 99.99999% | 3 s | 0.25 s | 7 — Ultra-Availability |

#### Cost of Service Unavailability

Example formula for total unavailability cost T_c:
```
T_C = U × S × ((1 − A) / 100)
```
Where U = number of users, S = monthly salary per user, A = availability %.

Example: 1000 employees × 30,000 PLN/month × 0.01 (1% unavailability) = **300,000 PLN/month**.

---

### Capacity Management

- **Capacity:** the ability of a system to operate at a given level of performance
- **Process aims:**
  - Monitor resources to ensure performance conditions described in the SLA
  - Plan for possible resource changes to meet future conditions
  - Minimise infrastructure costs while maintaining quality of services

---

### IT Service Continuity Management (ITSCM)

**Process aim:** plan and prepare resources needed to ensure continuity of service in the event of a disaster, on the terms agreed in the SLA.

- **Disruption:** an unplanned *event* that disrupts the service for a significant amount of time
- **Disaster:** an interruption of critical service *activities* for a significant part of the time

**What ITSCM counteracts:**
- Loss, damage, or denial of access to key infrastructure
- Breakdown of key business services and applications
- Loss of performance of supplier/third-party services
- Loss or misrepresentation of key information
- Sabotage, extortion, commercial espionage, infiltration
- Attacks on critical information systems

#### Failover

**Failover** = ability to automatically and seamlessly switch to a reliable (standby/redundant) system when the primary system fails. The standby system must *always* be ready to take over automatically.

**Disaster Recovery:** processes, policies, and procedures for resuming/maintaining ICT infrastructure critical to the organisation after a natural or man-made disaster.

**Recovery Time Objective (RTO):** defined in the SLA; maximum acceptable time the system can be unavailable (to avoid unacceptable business consequences).

**Recovery Point Objective (RPO):** the point in time to which data will be restored (does not consider quantity/quality of data lost). Both RTO and RPO are included in SLAs.

**Key trade-off:** smaller RTO/RPO (quicker restore) = higher cost (inverse relationship shown by exponential curve).

#### High Availability Systems

**High Availability:** a feature of a system providing an agreed operational performance level, usually uptime, for longer than normal.

**Mechanisms:**
- Redundancy
- Replication (synchronous / asynchronous)
- Cloning and mirroring
- Load balancing
- Failover Zones
- Clustering
- Serverless compute

**Cluster modes:**
- **Active-Active:** all nodes serve requests simultaneously; uniform load across all nodes; load balancing prevents overloading; better throughput and response time; all nodes must have identical configuration
- **Active-Passive (Active-Standby):** at least 2 nodes, 1 active and 1 passive/standby; the passive node takes over automatically if the active one fails; clients connect only to the active server during normal operation

#### Restoring Services to Operation (Recovery Types)

| Type | Description | Recovery Time |
|---|---|---|
| **Cold (Gradual Recovery)** | Servers must be configured and applications installed from scratch | Days–Weeks (> 72 h) |
| **Warm (Intermediate Recovery)** | Configured servers and installed applications, but not yet connected to production infrastructure | Minutes–Hours (max. 72 h) |
| **Hot (Immediate/Fast Recovery)** | Full duplexing and redundancy with automatic failover | (Almost) immediately (max. 24 h) |

---

### Security vs. Safety

- **Safety:** freedom from unacceptable risk of physical injury or human health damage, directly or indirectly as a result of damage to property or the environment. Safety is an attribute of *dependability*.
- **Dependability attributes:** Availability, Reliability, Safety, Confidentiality, Integrity, Maintainability
- **Security:** prevention of illegal/unwanted penetration, intentional/unintentional interference in correct operation, or unauthorised access to confidential information in IT systems.
- **Security = Availability + Confidentiality + Integrity**
- **Security attributes:** Availability, Confidentiality, Integrity (Safety, Reliability, Maintainability are part of *Dependability*, not Security)

#### Confidentiality
- A security function indicating the areas in which data should not be shared or disclosed to unauthorised persons, processes, or other entities.

#### Integrity
- Property of data that excludes their modification in an unauthorised manner; inability to introduce an unauthorised change to the system.

#### Authorization vs. Authentication
- **Authentication:** confirming the declared identity of an entity (*who you are*)
- **Authorization:** process of granting rights to data to an entity (*what you can do*)

---

## Lecture 13: Blockchain and Cryptocurrencies

### A Bit of History

| Year | Event |
|---|---|
| 1998 | Wei Dai describes the idea of cryptocurrency on the *cypher punks* mailing list |
| 2007 | Satoshi Nakamoto conceptualises a new system forming the basis of Blockchain and Bitcoin |
| Aug 2008 | Bitcoin.org established and registered |
| Oct 2008 | Bitcoin Whitepaper published: *"Bitcoin: A Peer-to-Peer Electronic Cash System"* |
| Dec 2009 | First Bitcoin transaction |
| May 2010 | First real-world transaction: Laszlo Hanyecz pays 10k BTC for 2 pizzas (then worth ~$41) |
| Jul 2010 | Mt. Gox exchange opens in Tokyo |
| Feb 2011 | BTC reaches parity with USD |
| 2011 | Silk Road dark marketplace opens; Mt. Gox security breach drops BTC price to 1 US cent fraudulently |
| Jun 2012 | Coinbase BTC wallet launched in San Francisco |
| May 2013 | First BTC ATM in San Diego |
| Oct 2013 | Silk Road closed by FBI |
| Nov 2013 | BTC breaks $1,000 USD barrier |
| Feb 2014 | Massive attacks on exchanges; Mt. Gox collapses; BTC price plummets |
| Dec 2017 | BTC reaches record high of **$18,402.25** USD |
| Dec 2018 | Year-on-year: BTC −82%, BTC Cash −94.4%, Ethereum −88.84%, Litecoin −92.1% |

**Notable exchange hacks:** Mt. Gox (2014, $473M), Bitfinex (2016, $72M), Coincheck (2018, $530M).

---

### Centralized vs. Decentralized vs. Distributed Systems

| Type | Description | Implication |
|---|---|---|
| **Centralized** | One authority controls everything | If it goes offline, peers lose access to all services |
| **Decentralized** | Some nodes have control over services/process information | Partial resilience |
| **Distributed** | No dedicated node to process data | Higher computing power, cost reduction, higher reliability, natural growth |

**Distributed advantages:** higher computing power, cost reduction, higher reliability, natural growth ability.

**Distributed disadvantages:** coordination overhead, communication overhead, dependency on networks, higher program complexity, security issues.

---

### Cryptography Foundations

- **Foundation of cryptocurrencies**; earliest known use: carved ciphertext in Egypt (~1900 BCE)
- Greek *kryptós* ("hidden, secret") + *graphein* ("to write") or *-logia* ("study")
- A mathematical algorithm to secure data
- **Encryption:** human-readable plaintext → encrypted ciphertext
- **Decryption:** encrypted ciphertext → human-readable plaintext
- **Cipher:** the rules to encode the information
- **Key:** allows encryption/decryption of data
- **Cryptography:** uses a cipher as a digital lock and a key to encrypt/decrypt data

---

### Hashing

Hashing algorithms: **MD5*** (deprecated), **SHA-1**, **SHA-2**, **SHA-3**

Properties required:
1. Reasonably fast to compute
2. One-bit change → entirely different hash value (avalanche effect)
3. Must be unique — to prevent hash collisions

*MD5 is deprecated: vulnerable, can be cracked by brute force.*

---

### Blockchain Essentials

**Blockchain ≠ Bitcoin** (Bitcoin is one application built on blockchain technology)

Key properties:
- A **distributed transaction ledger** (register)
- Transactions are grouped into **blocks**, one by one
- System is **peer-to-peer** — no central nodes
- Integrity ensured by **hashing** functions (SHA-2 / SHA-3)
- Authentication ensured by **electronic signature** algorithms
- Transactions gathered in blocks via **broadcasting**
- Each node can participate in adding a block to the ledger
- **Reward-driven** system: achieving consensus via *Proof of Work* (mining) earns a *transaction fee*
- A **publicly disclosed linked ledger** stored in a blockchain

**Blockchain is:**
- A transaction system
- A form of decentralised database
- No single entity has control over transactions
- Unhackable / tamper-proof

#### Ledger
- A public, decentralised, distributed database
- Stores all transactions ever occurred (and future ones)
- Requires an INTERNET connection to view
- Contains: ID, Sender, Receiver, Timestamp
- All transactions are traceable (unlike traditional non-electronic monetary transactions)

#### Exchange
- Essentially a bank-like, *centralised* entity acting as an intermediary

---

### Merkle Tree

- A key structural component of blockchain
- Related to hashing algorithm(s)
- Each transaction has its own hash
- Hashes are combined pairwise → **combination hash** (hash of hashes)
- The **ROOT (Top) hash** is an eventual hash covering all transactions
- Prevents tampering: altering one hash causes a cascade effect (avalanche) that invalidates all parent hashes
- Allows efficient checking of transaction validity (data) without scanning every transaction
- Concept by Ralph Merkle (patented 1979)

---

### Block Structure

A **block** is a container for transactions, each signed by both respective parties.

A **block hash (signature)** locks the block and prevents further changes; it is computed from:
- The *previous block hash*
- Hashes of the transactions contained inside
- The block's creation time (timestamp)
- A random string: the **nonce** (calculated by mining)

**Block header fields:** Version, Previous Block Hash, Merkle Root (hash of Merkle tree), Timestamp, Difficulty Target (PoW algorithm), Nonce.

---

### Full vs. Non-Full Node Blockchain

- **Full node:** stores all transactions in every block; chain formed by all blocks linked in sequence
- A new block is appended (mined) roughly every **10 minutes** (Proof-of-Work)
- Each block uses the *block hash* of the previous block to create its own block hash → blocks become *increasingly harder to corrupt* as more are added

- **Non-full (light) node:** stores only the **Merkle Root** in each block header (not all transactions); allows verifying the entire blockchain without storing every transaction body

---

### Block Chain — In a Nutshell (Mining Process)

1. New transactions are **broadcast** to all nodes
2. Each node collects new transactions into a block
3. Once a block is filled, each node works on finding a valid **nonce** (Proof of Work) → calculates the block hash meeting difficulty criteria (e.g., starts with many zeros)
4. When a node finds the correct nonce, it broadcasts the **signed block** to ALL nodes

**Consensus mechanism:**
- The successful node is **rewarded** (cryptocurrency)
- Nodes accept the block only if **ALL** transactions are VALID
- Nodes express acceptance by discarding their own unfinished block and starting a new one using the accepted block's hash as the previous hash

---

### Why Use Blockchain?

**Key benefits:**
- Not controlled by any corporation or government
- **Secure:** no single point of failure
- **Open:** royalty-free
- Provides a complete audit trail
- Can't be tampered with
- Crowdsources processing power (suitable for scientific research)
- Enables autonomous applications (e.g., AirBnB-like platforms)
- Helps tackle money laundering

**Benefits vs. Unknowns:**

| Benefits | Unknowns |
|---|---|
| Increased transparency | Complex technology |
| Accurate tracking | Regulatory implications |
| Permanent ledger | Implementation challenges |
| Cost reduction | Competing platforms |

---

### Blockchain Applications

1. **Storage for digital records**
2. **Exchanging digital assets** (tokens)
3. **Executing smart contracts:**
   - Ground rules — Terms & conditions recorded in code
   - Distributed network executes contract and monitors compliance
   - Outcomes are automatically validated without a third party

**Industry use cases:** smart property, distributed cloud storage, digital identity, healthcare, energy, machine learning.

---

## Lecture 14 (Part 2): Blockchain and Cryptocurrencies — Cryptocurrencies in Depth

### What Are Cryptocurrencies?

- **Digital assets** that use a medium of exchange (commodities model)
- Facilitate transactions using **cryptography** to ensure security and validity
- **Not backed** by any central authority (e.g., government) that determines value
- Value is determined proportionally to interest in the currency and the work behind it (mining)
- Usually created/issued through a process called **mining** (analogous to physical mining of gold)
- Some (e.g., BTC) have a **finite supply**
- Usually free / open-source to use

**Three main concepts:** Public ledgers · Mining · Transactions

---

### Brief History of Payment Systems

| Era | Form |
|---|---|
| 9000–6000 BC | Shells, livestock, plant products |
| 3000 BC | Mesopotamia — Shekel = 180 grains of barley (unit of weight and currency) |
| 1000 BC | Zhou dynasty — first standardized coinage (knives/spades) |
| 700–500 BC | Aegean coins |
| 7th century AC | China — first banknotes |
| 1661 | Bank of Sweden — first European banknote |
| 1971 | Richard Nixon removed backing of gold from USD |
| Modern | Commodity money → Representative money → FIAT money → Checks → Wire transfers → Debit cards |

---

### Bitcoin (BTC)

- Digital currency — **not backed by a single authority**
- **Decentralized and distrusted** (controlled by a network of users)
- Not issued but **mined** → process of verifying transaction validity (similar to physical gold mining)
- New coins generated as **rewards** for verifying a certain number of transactions
- Creation rate is **automatically halved** every few years (halving)
- Max. number of BTC limited to **21 million** (estimated to be fully mined by ~2140)
- Smallest denomination: **1 Satoshi = 0.000 000 01 BTC**
- ~144 blocks mined per day × 3.125 BTC/block = **~450 BTC per day** (currently)
- ~94.5% of all BTC already issued

**Components:** Public ledger (records all transactions) · Exchange (facilitates sending and receiving) · Wallets (store BTC)

---

### Bitcoin vs. Fiat Currency

| Dimension | FIAT Money | Bitcoin |
|---|---|---|
| Backed by | Government / central authority | Network of users (community) |
| Supply | Not finite (can be issued indefinitely) | Finite (21M cap) |
| Divisibility | Not very divisible | Highly divisible (8 decimal places) |
| Security | Government-backed | Validity confirmed by many users |
| Transaction ease | Easy (real-life presence) | Requires internet; not universally accepted |
| Acceptance | Widely accepted | Growing (?) |
| Cost | Free (cash) | Free to use |

FIAT money was introduced as an alternative to commodity money (gold, silver) and representative money (backed by gold).

---

### PoW vs. PoS (Consensus Comparison)

| Property | Proof of Work (PoW) | Proof of Stake (PoS) |
|---|---|---|
| Block creators called | **Miners** | **Validators** |
| Entry requirement | Buy equipment and energy | Own coins/tokens |
| Energy use | Energy **inefficient** | Energy **efficient** |
| Security model | Robust (expensive upfront) | Security via community control |
| Reward type | Block rewards | Transaction fees |

---

### Process of Mining

Bitcoin mining uses **special software to solve mathematical problems** (verification of transactions):
- Miners rewarded with fractions of BTC for solving math problems
- More miners → more robust and secure system → wider adoption
- BTC network **automatically changes difficulty** to prevent too quick depletion of total BTC supply
- Hardware evolution: **CPU** (too slow) → **GPU** (expensive, energy inefficient) → **ASIC** chips (dedicated, energy efficient but very expensive)
- **FPGA** sits between GPU and ASIC on the flexibility/efficiency spectrum

**Mining Pools:** A collection of miners combining hashpower to mine coins faster. Rewards split according to individual contribution. Major pools: Foundry USA ~30%, AntPool ~22.5%, F2Pool ~14%.

---

### Cryptocurrency Wallets

A **wallet** is equivalent to a bank account — a collection of private keys that facilitates sending/receiving/storing cryptocurrencies.

| Type | Internet | Cost | Security | Notes |
|---|---|---|---|---|
| **Hot** | Yes | Free | Lower — susceptible to hackers and vulnerabilities | Easier setup; accepts more tokens |
| **Cold** | No | 80+ EUR | Higher | More secure; fewer supported currencies; air-gapped devices can still be compromised |

Cold wallet examples: **Trezor** (BTC, BCH, BTG, ETH, ZCash, Dash), **Ledger** (BTC, BCH, BTG, ETH, ZCash, Ripple, Dash, ARK, Stellar)

---

### Exchanges and Value

An **exchange** allows conversion of one currency to another; many act as wallets too. They behave similarly to banks.

**Cryptocurrency value is driven by:**
- Supply and demand (no central authority shapes it)
- More demand → higher market value
- Reputation-based: better public perception → higher value

---

### How to Use Cryptocurrencies

1. Open an exchange account / wallet
2. Get a public address (like an email)
3. Buy crypto (with fiat or another cryptocurrency)
4. Mine for BTC
5. Apply for a debit card (e.g., BitPay, SpectroCoin/Visa)
6. Spend online / offline (physical stores)
7. Trade BTC (like stocks/bonds) — profit from price differences

---

### Illicit Activities

Cryptocurrencies have been misused for: dark web (illegal/stolen data), drugs/weapons dealing, ransom/kidnapping/cyber attacks.

---

### Ups and Downs of Cryptocurrencies

**Challenges:** nascent technology · uncertain regulatory status · large energy consumption (1 BTC transaction ≈ 634.72 kg CO₂, 1,137.98 kWh, equivalent to 1,406,760 VISA transactions, 17,935 L of fresh water) · control/security/privacy concerns · integration concerns · cultural adoption barriers · audit/tax/compliance challenges.

Bitcoin's energy consumption has grown dramatically, reaching an estimated ~175 TWh/year by 2025.

---

### Law and Regulations

**EFTA (Electronic Fund Transfer Act):** passed in US Congress in 1978; covers rights/liabilities of consumers; responsibilities of everyone in electronic fund transfer activities; helps limit losses for lost/stolen funds.

**BTC Global Legal Status:** Unrestricted in **132 of 257** countries/regions. Restricted or illegal in parts of the Middle East, China, and some other nations. Crypto regulations vary widely (Light ↔ Tight): Canada, Switzerland, Lithuania have regulated exchanges; South Korea has banned ICOs; USA/UK/EU operate in grey-area status with upcoming legislation.

---

## Lecture 15 (Part 3): Blockchain — Scaling, ICO/DAO, Consensus Mechanisms and Applications

### BTC Scaling Issue

- Each block holds ~2,000 transactions → ~1 MB in size
- New block every **10 minutes** (regulated by mining difficulty)
- Throughput: **2000 / 10 / 60 ≈ 3.2 TPS**
- For comparison: **VISA processes ~24,000–56,000 TPS**

**Proposed Solutions:**

| Solution | Speed Gain | Est. TPS | Notes |
|---|---|---|---|
| **Doubling block size ("2x")** | 2× | ~6.4 | Blockchain grows exponentially — unsustainable |
| **SegWit** (Segregated Witness) | 2.6× | ~8.3 | Separates signatures ("dead weight", ~60%) into optional extended block; +250% room for transactions |
| **Schnorr signatures** | 2× (5.2× combined with SegWit) | — | Aggregates multiple input signatures into one |
| **SegWit2x** | 5.2× | ~16.6 | Hybrid: double block size + SegWit; same growth problem |
| **Lightning Network (LN)** | Theoretically millions–billions TPS | — | Off-chain payment channels; direct P2P; orders of magnitude beyond VISA |

**Lightning Network:** Keeps unaltered blockchain (same PoW). Uses **payment channels** instead of storing every transaction. Final settlement handled on-chain. Invalid channel transactions cause all channel transactions to fail. All nodes can freely create channels; channels stay open indefinitely until funds are released.

**Replay / Playback Attack (Double-Spending):** An exploit when two forked cryptocurrencies allow transactions to be valid across both chains. The same digital token can be spent more than once because digital tokens can be duplicated or falsified.

**Hard Fork:** Not backward compatible. Old nodes reject new blocks. Nodes running old versions see new transactions as invalid. Controversial and requires everyone to upgrade. Example: **Bitcoin Cash (BCH/BCC)** — created 1st August 2017 as a hard fork from BTC; block size increased to 8 MB.

---

### Consensus Mechanisms

Systems of reaching agreement on the state of the blockchain — protocols for authenticating new entries and governing changes.

| # | Mechanism | Principle | Example Chains |
|---|---|---|---|
| 1 | **Proof of Work (PoW)** | Expensive to add a block (mining) | Bitcoin, Litecoin, Ethereum (pre-Casper) |
| 2 | **Proof of Stake (PoS)** | Lottery; stake coins as deposit | Ethereum (Casper), Peercoin, NxtCoin, BlackCoin |
| 3 | **Leased Proof of Stake (LPoS)** | Like PoS; small holders lease coins to staking nodes | Waves |
| 4 | **Delegated Proof of Stake (DPoS)** | Holders vote to elect nodes; elected nodes join lottery on equal terms | BitShares |
| 5 | **Delegated Byzantine Fault Tolerance (dBFT)** | Byzantine Fault Tolerance; election then validation process | NEO |

#### Proof of Work — Detail

Mining process: collect transactions → validate (reject conflicting) → bundle into blocks → compute cryptographic hashes (SHA-256) → submit block → earn reward.

Key formula: `sha256(sha256(data + nonce)) = difficulty`
- **nonce** — integer the miner chooses freely; the "proof of work"
- **data** — hash over block contents and previous block hash
- **difficulty** — adjusted every ~2016 blocks (~2 weeks) to maintain 1 block per 10 minutes; size range [1, 2²⁵⁶]

**Consensus:** node finding the nonce broadcasts the complete block; other nodes verify (must produce same hash); if >50% of nodes accept → state of consensus reached → block is valid → finding node receives Bitcoin award.

#### Proof of Stake — Detail

All coins created at the beginning — no mining. New block added by a randomly picked node (lottery). Nodes invest a stake (coins) into a deposit to buy lottery tickets. More coins staked → higher chance of winning. Winner collects transaction fees. Very energy efficient.

#### Leased Proof of Stake (LPoS)

Like PoS but small holders lease their balance to staking nodes. Leased funds remain in full control of the holder. Leased coins increase the staking node's lottery chance. Transaction fees split proportionally between staking node and leasing nodes.

#### Delegated Proof of Stake (DPoS)

Coin holders vote to elect a list of nodes (votes weighted by balance). Elected nodes participate in a lottery on equal chances. Holders can vote on network parameter changes. Winning node provides and broadcasts the block; all others verify and add it to their copy.

---

### ICO and DAO

#### IPO vs. ICO

| Dimension | IPO (Initial Public Offering) | ICO (Initial Coin Offering) |
|---|---|---|
| What | Company shares sold to investors | New cryptocurrency/idea sold as tokens |
| Regulation | Regulated | Mostly not regulated |
| Trust | Proven and trusted | Risk of scams |
| Stage | Later-stage companies | Early-stage startups |

Tokens supposedly become functional units of currency when the ICO's funding goal is met.

**ICO due diligence:** (1) read the white paper — does the concept make sense? (2) what problem does it solve? (3) study the team. (4) check crypto forums. (5) check rating companies.

#### Decentralized Autonomous Organization (DAO)

Also known as Decentralized Autonomous Corporation (DAC). A transparent, automated, member-driven organization where rules and decisions are encoded in **smart contracts**, enabling decentralized collaboration and governance without traditional hierarchical management.

**Key features:** Decentralization (no central authority; power distributed among token holders) · Autonomy (smart contracts automate rules and transactions) · Transparency (all actions on blockchain, publicly auditable) · Token-Based Governance (more tokens = more voting power) · Open Participation (anyone can join by acquiring tokens).

**How it works:** Smart contracts deployed on blockchain → tokens issued (grant participation/voting) → members submit proposals → token holders vote → if threshold met, smart contract auto-executes → actions carried out automatically without human intervention.

**Use cases:** Cryptocurrency governance (e.g., MakerDAO) · Collective investment funds · NFT and digital asset acquisition · Decentralized social platforms · Virtual worlds and gaming economies.

**Pros:** Increased transparency/trust · Reduced need for intermediaries · Automated efficient operations · Open global participation.
**Cons:** Security risks (smart contract bugs exploitable) · Legal and regulatory uncertainty · Potential governance manipulation by large token holders.

---

### Smart Contracts

A **computer protocol** intended to digitally facilitate, verify, or enforce the negotiation or performance of a contract.

- A new class of apps; supports agreements between parties
- When agreed conditions are satisfied, **contract is automatically executed**
- No proxies / no middlemen / no lawyers
- Linked smart contracts create **DAOs** — companies that do things automatically

**Complexity spectrum (simple → complex):** Digital value exchange → Smart right/obligation → Basic smart contract → Multiparty smart contract → Distributed autonomous business unit → Distributed autonomous organization → Distributed autonomous government → Distributed autonomous society.

---

### Blockchain Applications

#### Government
- **Dubai** — world's first blockchain-powered state; est. $1.5B savings/year from going paperless
- **Estonia** (partnered with Ericsson) — all public records stored on blockchain
- **South Korea** (Samsung) — blockchain for public safety and transport apps
- **UK** — blockchain to be used for pension payments

#### Cybersecurity
- **Guardtime** — keyless digital signature systems based on blockchain; secures medical records of ~1 million Estonian patients

#### Healthcare
- **GEM (Ericsson)** — disease outbreak data; increases effectiveness of disaster relief
- **Simply Vital** — tracks patient state after leaving hospital; decentralized patient records
- **MedRec (MIT)** — authentication, confidentiality, data sharing of medical records

#### Financial Services
- **Barclays Bank** — tracking financial transactions; combating fraud; verification time cut from 7–10 days to <4 hours
- **BitPesa (Kenya)** — digital foreign exchange and payment platform; reduces cost of sending money to frontier markets

#### Manufacturing and Industrial
- **JIO (Reliance Industries, India)** — blockchain-based supply chain logistics platform; own cryptocurrency (JIO Coin)
- **TransActiv Grid (NY)** — allows users to produce and sell energy; reduces distribution costs
- **STORJ.IO** — distributed and encrypted cloud storage; members share HDD space

#### Retail / Real Estate / Transport
- **OpenBazaar** — decentralized market for services and goods; no market fees
- **Ubitquity.io** — blockchain tracking for complete legal process in real estate
- **Arcade City** — Uber-like, ride-sharing blockchain-based app

---

### Ethereum vs. BTC

| Property | Bitcoin | Ethereum |
|---|---|---|
| Founder | Satoshi Nakamoto | Vitalik Buterin |
| Release | 9 Jan 2008 | 30 July 2015 |
| Blockchain | Proof of Work | Proof of Work (planning PoS) |
| Primary use | Digital currency | Smart contracts + digital currency |
| Cryptocurrency | Bitcoin (Satoshi) | Ether |
| Algorithm | SHA-256 | Ethash |
| Block time | 10 minutes | 12–14 seconds |
| Mining | ASIC miners | GPUs |
| Scalable | Not currently | Yes |

**Ethereum advantages:** faster blocks, supports applications beyond currency, easier individual mining (discourages pools), Turing-complete programming language.

**Ethereum disadvantages:** smaller market/value, less awareness, Ghost Protocol (helps eliminate pool mining), unlimited coin supply.

**Ethereum Classic:** resulted from the DAO Hack (~$50M USD lost in 2016); hack undone by hard fork; members opposed to the fork retained the old chain (Classic).

---

### Ripple (XRP)

Ripple Network is **not a blockchain** — it is a **payment settlement system and currency exchange** designed for the financial services industry. Pre-mined 100 billion tokens; no mining. Used by large institutions (banks) as an intermediary for global asset transfers. Debt-based system similar to conventional banking. Not completely distributed (most validation done by Ripple Labs).

**Advantages:** fast settlement (4–5 seconds); very low fees (0.00001 XRP); versatile (also handles fiat and other cryptocurrencies); used by Santander and Bank of America.

**Disadvantages:** somewhat centralized (default validator list); large pre-mined supply that could impact value; SEC filed lawsuit in December 2020 (alleging XRP should be registered as a security).

---

### LiteCoin (LTC)

Based on BTC Core; uses Lightning Network / SegWit; 4× faster transaction processing.

**Disadvantages:** uses "scrypt" in PoW (sequential memory-hard function requiring asymptotically more memory); FPGA and ASIC mining devices are more complicated and expensive to produce.

---

### Tangle and Alternative Ledger Structures

| Property | Blockchain | Tangle | Hashgraph |
|---|---|---|---|
| Technology | Block chain | Directed acyclic graph | Directed acyclic graph |
| Copyright | Open source | Open source | Patented |
| Consensus | Proof of Work (SHA-256) | PoW: check of Tangle tip | Virtual voting |
| Openness | Public ledger | Public ledger | Private ledger |
| Application | Bitcoin | IOTA | Swirlds |
| Efficiency (TPS) | 3–4 | 500–800 | >250,000 |