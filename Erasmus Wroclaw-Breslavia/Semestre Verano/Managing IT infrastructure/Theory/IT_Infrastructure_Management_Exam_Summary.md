# IT Infrastructure Management (W04IST-SI0826G) — Exam Summary

*Course: IT Infrastructure Management — Wojciech Thomas, PhD. Compiled from all lecture slides.*

---

## 1. Introduction & Windows Server Platform

- Course graded as one combined mark for lecture + lab. Lecture attendance optional but offers bonus activities (20% of final grade). Lab attendance mandatory (max 4 absences); grade based on exercises, reports, and in-class activity.
- Course topics: Windows administration, Active Directory, network services administration, Azure (IaaS) administration.
- **Virtualization Type I (server/bare-metal hypervisor):** Hyper-V (Windows Server 2025 / Windows 11), VMware ESX Server, KVM. Runs directly on hardware; guest partitions sit above a hypervisor layer.
- **Virtualization Type II (client/hosted hypervisor):** VirtualBox, VMware Player. Runs as software on top of a host OS; each guest OS runs with its own Virtual Machine Monitor (VMM) layer above the host OS.
- **Containerization:** unlike VMs (which need a full separate OS each), containers share one OS kernel/image, but each container believes it runs independently. Windows Server Containers and Hyper-V Containers share a base OS but isolate at different levels.
- **Hyperthreading:** with Hyper-V enabled, each physical core with Intel Hyperthreading is seen as a separate Logical Processor (LP).
- **Installation methods:** DVD, USB, or Windows Deployment Services (network-based automated install).
- **Minimum requirements (Server 2025):** x86-64 CPU, NX/DEP/SLAT support, 1.4GHz, RAM 2GB (GUI) / 512MB (Core), 32GB disk (more if RAM > 16GB).
- **Cloud service models:** IaaS (infrastructure), PaaS (platform), SaaS (software/service) — public or private cloud.
- **Three installation "flavors":**
  - **Desktop Experience** — full GUI.
  - **Core** — command-line only; same roles as GUI but lower hardware needs (512MB RAM to run, 1024MB to install); managed via `sconfig`, PowerShell, or remote tools.
  - **Nano** — container-only, headless, supports only select roles (e.g., DNS, web server); extremely low footprint (example: 3400 Nano VMs with 128MB RAM each running on a single 8×20-core/1TB RAM host).
- **Server 2025 editions:** Datacenter (unlimited OSEs = Operating System Environments), Standard (2 OSEs), Essentials (25 users/50 devices cap), Storage Server (OEM only), Hyper-V Server (free).
- **Roles vs. Features:** A **Role** is a complex function (e.g., DNS Server, DHCP Server, Domain Controller) — a group of dependent services. A **Feature** is a single capability not normally exposed to clients (e.g., BitLocker encryption). Roles can depend on features; "features on demand" must be installed from mounted media.
- **Server Manager:** single console for managing multiple servers — add roles/features, run PowerShell, view events, configure settings.
- **Key administrative tools:** AD Administrative Center, AD Users and Computers, DNS console, Event Viewer, GPMC, IIS Manager, Performance Monitor, Resource Monitor, Task Scheduler.

---

## 2. Domain Environment & Active Directory Fundamentals

- **Workgroup vs Domain:**
  - *Workgroup* — each computer configured independently; separate accounts per machine.
  - *Domain* — centrally configured; one account works domain-wide.
- **Computer classes:** Workgroup has Clients + Servers; Domain adds the **Domain Controller** (a server running AD DS).
- **AD core component services:** LDAP, Kerberos, DFSR (and more).
- **Kerberos:** provides single sign-on; the domain controller acts as the Key Distribution Center (KDC). Flow: Client → AS_REQ/AS_REP (authentication) → TGS_REQ/TGS_REP (ticket-granting) → AP_REQ/AP_REP (service access).
- **Multi-domain environments:** organized in a **forest**, containing a **domain tree** (parent/child domains, e.g. `nwtrader.msft` → `asia.nwtrader.msft`, `au.nwtrader.msft` → `brisbane.au.nwtrader.msft`); Organizational Units (OUs) live within domains.
- **Basic AD objects:**
  - *Physical:* Domain Controller, Data store, Global Catalog, RODC (Read-Only Domain Controller).
  - *Logical:* Partitions, Schema, Domains, Trees, Forests, Sites, Organizational Units.
- **AD as a directory service:** stores domain config, names/describes resources, enables discovery, management, and security of resources.
- **Advantages of AD:** DNS integration, scalability, centralized management, decentralized management via delegation.
- **Installing a DC (GUI):** (1) install AD DS role, (2) promote server to DC.
- **Installing a DC (Core/PowerShell):**
  ```
  Install-WindowsFeature AD-Domain-Services
  Import-Module ADDSDeployment
  Install-ADDSForest -DomainName contoso.internal -InstallDNS   # first DC in forest
  Install-ADDSDomainController -DomainName contoso.internal -InstallDNS  # additional DC
  ```
- **Install from Removable Media (IFM):** on an existing DC run `ntdsutil` → `activate instance ntds` → `ifm` → `create SYSVOL full C:\IFM`; copy that media to a new server and use it in the configuration wizard (useful for slow links).
- **AD object naming:**
  - *LDAP Distinguished Name (DN):* `OU=Research,DC=contoso,DC=internal` — uniquely identifies any object domain-wide.
  - *LDAP Relative DN (RDN):* `OU=Research` — identifies relative to parent container only.
  - *Canonical Name:* `contoso.internal/Research`.
  - Components: **DC** (domain component), **OU** (organizational unit), **CN** (common name — groups/users/computers). Example: `cn=Sarah,ou=Marketing,ou=Sweden,DC=contoso,DC=internal`.
- **Creating OUs:**
  - PowerShell (recommended): `New-ADOrganizationalUnit -Name Sweden -Path "DC=contoso,DC=internal"`; remove with `Remove-ADOrganizationalUnit`.
  - Legacy CMD: `dsadd ou "OU=Sweden,DC=contoso,DC=internal"`; remove with `dsrm`.
  - Spaces in OU names need quotation marks; never put a space next to a comma.
- **OUs vs Containers:** Containers (e.g., built-in Users, Computers, Built-in) **cannot be nested**, **cannot have permissions assigned**, and **cannot have GPOs linked**. OUs can do all three — this is the key practical difference.
- **User account properties:** Name/Display name; **UPN** (User Principal Name, e.g. `wojtek@contoso.com`) or **SAM account name / pre-Windows 2000 logon** (e.g. `contoso\wojtek`); account options (password never expires, must change password, cannot change password, etc.).
- **Creating users:**
  ```
  New-ADUser Anna -SamAccountName Anna -UserPrincipalName "annas@contoso.com" `
    -Path "OU=Sweden,DC=contoso,DC=internal" -DisplayName "Anna Svensson" `
    -AccountPassword (ConvertTo-SecureString -AsPlainText "P@sswOrd" -Force) -Enabled $true
  ```

---

## 3. User Accounts, Computer Accounts, and Groups

- **Admin tools:** AD Users and Computers, AD Administrative Center, PowerShell (`New-ADUser` — recommended) or legacy `ds...` commands (`dsadd`, `dsmod`, `dsrm`).
- **User Profile:** a network folder storing user-specific settings (desktop wallpaper, Documents folder, etc.).
- **Computer accounts:** each domain computer has its own account — random password, used to securely connect to the DC; password changes automatically and regularly.
- **Adding a computer to the domain:**
  - PowerShell: `Add-Computer -ComputerName cl2 -DomainName "contoso.com" -Restart`
  - CMD: `netdom join cl2 /domain:contoso.com /reboot`
  - A restart is required.
  - **Common problems:** reinstalling a PC creates a *new* computer account/password mismatch; restoring backups can cause password mismatches; excessive time difference between DC and client breaks Kerberos.
- **Computer placement:** servers organized by function; client computers organized by location (e.g., site-based OU structure like BOS/CHI/CPT → Desktops/Laptops).
- **Groups — types:**
  - **Security groups** — can be assigned permissions.
  - **Distribution groups** — email lists only, no SID, cannot be assigned permissions.
- **Group scope (visibility):**
  - **Domain Local** — visible/usable only within its own domain; **can hold objects from the entire forest**; used to assign permissions to resources.
  - **Global** — visible from all forest domains, but **can only contain objects from its own domain**; used to gather users.
  - **Universal** — visible from all forest domains and **can contain objects from the entire forest** (users, global groups, other universal groups); used to combine global groups across domains.
  - Mnemonic strategy often taught: **A-G-DL-P** (Accounts → Global groups → Domain Local groups → Permissions), or with Universal groups in multi-domain forests: A-G-U-DL-P.
- **Default built-in groups:** Enterprise Admins & Schema Admins (first forest domain only); Domain Admins (Users container); Administrators, Server Operators, Account Operators, Backup Operators, Print Operators (Built-in container).
- **Special automatically-managed groups:** Anonymous Logon, Authenticated Users, Everyone, Interactive, Network.
- **Delegation of permissions:** groups usually grant too much power; delegation lets you assign narrower, standard or custom administrative tasks instead.
- **Delegation good practice:** delegate to **groups**, not individual users; **document** all delegations.

---

## 4. File and Folder Permissions

- **NTFS/ReFS only** — permissions are NOT available on FAT/FAT32. Can be applied to files or folders.
- **Key terms:**
  - **SID (Security Identifier):** unique ID for an object.
  - **Security Principal:** any object that has a SID (user, group, computer).
  - **Permission:** the right to perform an action (e.g., read data) — can be **Allow** or **Deny**.
  - **ACL (Access Control List):** list of security principals + their assigned permissions on an object; every securable object has one.
- **Rules of permission evaluation:**
  - **Principle of least privilege** — only explicitly assigned permissions apply.
  - **Implicit deny** — no assigned permission = no access.
  - Permissions from a user account **and** all its groups are **cumulative** (additive).
  - **Explicit deny always wins** over any allow — even if "Everyone::Full Control::Allow" is also set, an explicit Deny blocks that specific permission (e.g., `Everyone::Read::Deny` + `Everyone::Full Control::Allow` → no one, not even admins, can read the file, but they CAN write to it).
- **Basic Permissions:** ready-made bundles of advanced permissions sufficient for ~95-99% of everyday tasks (Full Control, Modify, Read & Execute, List Folder Contents, Read, Write).
- **Advanced Permissions:** granular control, needed when Basic isn't sufficient. Some permissions mean different things for files vs folders (e.g., "List folder / read data"). Use cases: "black hole" folder (can upload, can't view), "drop" folder (can upload, can't modify existing files).
- **Permission Inheritance:**
  - ACL set on a parent folder propagates to subfolders/files.
  - Inherited permissions **cannot be directly changed** at the child level (only at the source).
  - Implemented as a reference back to the source folder's permissions.
  - Inheritance **can be disabled**; when disabled, you choose to either **delete** the inherited entries or **convert them to direct (explicit)** permissions.
  - Tip: never remove permissions for `Administrators` and `SYSTEM`.
  - You can fine-tune inheritance scope: apply to "this folder only," "subfolders and files," "files only," etc.
- **Copy/Move behavior:**
  - **Copy** (anywhere) → object inherits permissions from the **destination** folder.
  - **Move within the same volume** → direct permissions are kept; inherited ones come from the new parent.
  - **Move across volumes** → all permissions inherited fresh from the destination (behaves like a copy).
- **Shared Folders (network access):**
  - UNC format: `\\server_name\folder_name` (DNS or NetBIOS name both work), e.g. `\\dc1.contoso.com\profiles` or `\\dc1\profiles`.
  - Two separate ACLs apply to a *shared* folder: **NTFS** (Security tab) and **Share** (Sharing > Advanced > Permissions).
  - **Locally** accessed path (`C:\profiles`) → only NTFS permissions apply.
  - **Remotely** accessed path (`\\dc1\profiles`) → **both** NTFS and Share permissions apply, and the **most restrictive (lowest common)** combination wins.
  - **Microsoft's recommended best practice:** set Share permission to `Everyone::Full Control::Allow`, and manage all real restriction purely via NTFS. This way only NTFS permissions matter, simplifying administration.
  - **Simple sharing:** folder shared under its own name, default Microsoft-recommended permissions, all subfolders inherit the same.
  - **Advanced sharing:** a folder can be shared under **multiple different names**, each with **different permissions**; you can also limit simultaneous connections.

---

## 5. PowerShell Fundamentals

- **What is PowerShell:** a command-line shell plus a set of admin cmdlets; naming convention is **Verb-Noun** (e.g., `Get-Service`). List allowed verbs with `Get-Verb`.
- **Discovering commands:**
  - `Get-Command *Net*` — wildcard search.
  - `Get-Help Get-NetAdapter [-Examples | -Online]`.
  - `Get-Service -Name w32time | Get-Member` — inspect object properties/methods.
  - `Update-Help` — refresh local help files.
- **Versions:** "PowerShell" (modern, cross-platform) vs legacy "Windows PowerShell"; check with `$PSVersionTable`.
- **Execution policy:** `Get-ExecutionPolicy` / `Set-ExecutionPolicy`; for a single session: `Set-ExecutionPolicy Bypass -Scope Process`.
- **Editors:** Visual Studio Code + PowerShell extension (recommended, modern); PowerShell ISE (legacy, security-updates only now).
- **Pipeline & formatting:**
  ```
  Get-Service | Where-Object Status -eq Running | Select-Object -Property DisplayName,StartupType | Format-Table
  ```
  `Format-Table` and `Format-List` control output presentation.
- **Variable types:** boolean (`$true`/`$false`), integers (byte/integer/long), floating point (float/double), decimal.
- **Functions:**
  - Simple: `function Get-MyPSVersion { $PSversionTable.PSVersion }` — no parentheses needed with zero parameters; last unassigned output value is the return value (or use `return`).
  - With typed parameter: `[string]$ComputerName` inside `param(...)`.
  - `[Parameter(Mandatory)]` — forces the caller to supply a value.
  - `[ValidateNotNullOrEmpty()]` — parameter can't be empty; often paired with a default value (e.g. `= $env:COMPUTERNAME`).
- **If statement:** `else` block is optional.
- **Comparison operators:** `-eq`/`-ieq` (equal, case-insensitive), `-ceq` (case-sensitive equal), `-ne`/`-ine`/`-cne` (not equal), `-gt`, `-ge`, `-lt`, `-le`; `-like` (wildcards `?`/`*`); `-match` (regex); `-is` (type check, e.g. `-is [string]`).
- **Loops:**
  - **for** — classic counter loop.
  - **foreach** — iterates a collection (e.g., `foreach ($id in $ids){...}`).
  - **Foreach-Object** — used in the pipeline (e.g., `Get-NetAdapter | Foreach-Object {$_.name}`).
  - **While** — condition checked before each iteration.
  - **Do...While** — condition checked **after** each iteration (always runs at least once).

---

## 6. Group Policies — Part 1

- **Windows configuration foundation:** the **Registry** acts as the configuration database. Settings split into **Computer settings** vs **User settings**, and **Policies** (enforced) vs **Preferences** (suggested defaults, user can change).
- **Local GPOs:** apply to the machine itself (Computer part only), or to users — separately for Administrators, Non-administrators, or per individual user.
- **Group Policy Object (GPO) structure:**
  - Two top-level components: **User Configuration** and **Computer Configuration**.
  - Each has sections: **Software settings**, **Security settings**, **Administrative Templates**.
- **GPOs in AD:** managed via **GPMC** (Group Policy Management Console); stored in the **'Group Policy Objects' container**; applied to OUs/domains/sites via **GPO links**.
- **Applying GPO settings — order & inheritance:**
  - Linking happens at **Site**, **Domain**, or **Organizational Unit** level (in addition to Local).
  - Default processing order: **Local GPO → Site → Domain → OU** — the **last one applied wins** in case of conflict (closest to the object/most specific wins).
  - **RSoP (Resultant Set of Policy)** — the final, effective combination of all applicable settings after considering inheritance/conflicts.
- **Group Policy Client service:** `gpsvc`. **Client Side Extensions (CSEs)** process specific policy areas: Software installation, Folder redirection, Security settings, Administrative Templates.
- **Refresh timing:**
  - Computer settings: applied at **startup**, and refreshed every **90–120 minutes**.
  - User settings: applied at **logon**, refreshed every **90–120 minutes**.
  - Some settings (e.g., **software installation**) only apply after a **restart/logoff**, not via background refresh.

---

## 7. Group Policies — Part 2 (Templates, Scope, Testing)

- **Administrative Templates file types:**
  - **ADMX** — defines the actual settings (language-neutral).
  - **ADML** — the translated/localized description text.
  - Storage locations: **locally** at `C:\Windows\PolicyDefinitions`; **domain-wide (Central Store)** at `C:\Windows\SYSVOL\domain\Policies\PolicyDefinitions`.
- **Physical structure of a GPO:**
  - **Group Policy Container (GPC)** — stored in **Active Directory**.
  - **Group Policy Template (GPT)** — stored in **SYSVOL**.
- **Inheritance — where GPOs link:** Site, Domain, Organizational Unit.
- **Controlling inheritance:**
  - **Block Inheritance** — set on an OU; prevents GPOs from parent containers from applying (unless enforced — see next).
  - **Enforce (No Override)** — set on a GPO link; this GPO's settings will apply **even through a Block Inheritance** setting downstream.
  - Effective order considers normal inheritance **plus** any blocks and enforcements.
- **Controlling GPO scope:**
  - **Links (Scope)** — where the GPO is attached.
  - **Security Filtering** — restricts *which* groups/accounts the GPO actually applies to (read + apply permissions), even if linked broadly.
  - **Delegation** — used to explicitly exclude (deny) specific groups/accounts from a GPO.
- **Testing GPOs:**
  - **Group Policy Results** — shows what *actually* applied to a real target. Requires access to the target computer, and the user must have logged on there at least once.
  - **Group Policy Modelling** — a *simulation* service; doesn't require the actual user or computer to exist/be reachable. The more parameters you supply, the more accurate the simulated result.

---

## 8. Group Policies — Part 3 (Software Deployment, Folder Redirection, PSOs)

### Software Installation via GPO
- A dedicated **Group Policy Client Side Extension**; deploys to computers or users; requires **no admin rights** from the end user.
- **One of the few areas that does NOT refresh via `gpupdate`** — Computer assignments apply only at **startup**; User assignments apply only at **logon**.
- **Supported format:** only **.msi** (Windows Installer) natively; `.exe` needs script-wrapping (and then needs user permission); modern alternative is **MSIX** (Windows 10 / Server 2019+).
- **Deployment methods:**
  - **Assigned** (Computer *or* User): installs automatically, no choice, **cannot be removed by the user**. Computer→at startup; User→at logon. **Published is NOT available for Computer Configuration** — only Assigned.
  - **Published** (User **only**): appears in Control Panel > Programs for manual install; also auto-installs when opening an associated file type; **user CAN uninstall**.
- **Preparation:** create a network share (e.g. `\\dc1\install\`) with Domain Computers granted Read; **always use the UNC path**, never a local path, in the GPO package definition.
- **Path:** `Computer/User Configuration > Policies > Software Settings > Software installation` → right-click → New > Package → UNC path → choose Assigned/Published.
- **Limitations:** AD does not track license consumption; no built-in install monitoring; admin is responsible for compliance; best suited to small/medium environments.
- **Modern alternatives:** Microsoft Intune (cloud MDM, hybrid/Azure AD), Microsoft Endpoint Configuration Manager / MECM/SCCM (enterprise inventory + compliance), MSIX packaging.

### Folder Redirection
- Default user profile folders (Documents, Desktop, Pictures…) live **locally** — risk of data loss on machine failure, and inaccessible from other machines.
- **Folder Redirection** transparently moves selected folders to a network share; the user experience/path appears unchanged.
- Configured under: `User Configuration > Policies > Windows Settings > Folder Redirection`.
- Two targeting modes:
  - **Basic** — all users redirected to the same root path pattern (e.g. `\\srv01\home\%username%\Documents`).
  - **Advanced** — different paths assigned based on **security group membership**.
- GPMC can auto-create the destination subfolder if it has the necessary permission.
- Practical considerations: the network share **must be reachable at logon** or redirection fails; **Offline Files (CSC)** can cache redirected folders for disconnected/offline use; set NTFS so each user has **Full Control of only their own subfolder**; **do NOT redirect `AppData(Roaming)`** — conflicts with roaming profiles.

### Password Settings Objects (Fine-Grained Password Policy)
- Problem: a GPO can contain password settings, but **only a GPO linked at domain level** actually affects account passwords — meaning by default the **entire domain shares one password policy**, which doesn't fit mixed needs (e.g., service accounts needing long static passwords, contractors needing short lockout windows).
- **PSOs (Password Settings Objects)** — introduced in Windows Server 2008; solve this.
  - Stored as AD objects in `CN=Password Settings Container,CN=System,DC=...`.
  - Applied **directly to users or security groups — never to OUs**.
  - Multiple PSOs can coexist; if more than one applies to the same user, the one with the **lower `msDS-PasswordSettingsPrecedence` value wins**.
- **Create via ADAC:** AD Administrative Center > domain > System > Password Settings Container > New > Password Settings; configure length/complexity/lockout/history/precedence; add target users/groups under "Directly Applies To."
- **Create via PowerShell:**
  ```
  New-ADFineGrainedPasswordPolicy -Name "ServiceAccounts-PSO" -Precedence 10 `
    -MinPasswordLength 20 -ComplexityEnabled $true -LockoutThreshold 5 -LockoutDuration "00:30:00"
  Add-ADFineGrainedPasswordPolicySubject -Identity "ServiceAccounts-PSO" -Subjects "SVC_Accounts"
  Get-ADUserResultantPasswordPolicy -Identity SVC_Accounts
  ```

---

## 9. Active Directory in Large Networks (Replication, Sites, FSMO)

### Replication
- **What replicates:** the AD database (Schema, Configuration, Domain, and Application **partitions**, stored at `C:\Windows\NTDS`) plus the **SYSVOL** volume.
- **Why it matters:** the domain controls access to all resources — no reachable DC means no access; multiple DCs give fault tolerance and **local** authentication for branch offices.
- **PDC Emulator's role in replication delays:** if a password changes on one DC and another DC hasn't yet replicated it, that second DC will **forward the authentication attempt to the PDC Emulator**, which is authoritative for the most recent password changes — so login still succeeds.

### Sites
- **Site** = a group of IP subnets connected by fast, reliable links (typically a LAN); represents the **physical** network, while domains represent the **logical** structure.
- Configured manually in **AD Sites and Services** (`dssite.msc`) — admin assigns IP subnets to sites.
- **Physical architecture components:** Site (subnet group), Domain Controller (hosts data for a site), Site Link (connects sites).

### Intra-Site Replication
- **Topology:** ring with shortcut connections, automatically built/maintained by the **KCC (Knowledge Consistency Checker)** — no admin config needed within a site.
- **Characteristics:** **change-triggered** (near real-time), uses IP/RPC, guarantees full propagation **within a site in under 5 minutes**.

### Inter-Site Replication
- **Topology:** configured manually via AD Sites and Services — admin assigns DCs to sites and configures site link types/schedules.
- **Characteristics:** **schedule-driven, not change-triggered** by default; **default interval is every 180 minutes**.
- **Protocols:** **IP/RPC** (preferred; needs a secure connection — VPN/leased line); **SMTP** (needs certificate infrastructure; only for asynchronous, **non-domain partition** data).
- Diagnostic tool: `repadmin /showrepl`.

### Operations Masters (FSMO Roles)
- AD is fully distributed, but a few operations **cannot** safely run on multiple DCs simultaneously — these run as **FSMO** (**Flexible Single Master Operations**) roles, each on **exactly one** DC.
- **Domain-level roles (one per domain):**
  - **PDC Emulator** — first to learn password changes; time-synchronizes all DCs in the domain.
  - **RID Master** — issues pools of Relative Identifiers (RIDs) used to build unique SIDs for new objects.
  - **Infrastructure Master** — tracks identifiers for objects referenced/moved from other domains.
- **Forest-level roles (one per forest, held on the first domain):**
  - **Domain Naming Master** — adds/removes domains in the forest (console: AD Domains and Trusts).
  - **Schema Master** — processes all changes to the AD schema (console: Active Directory Schema snap-in, `schmmgmt.dll`).
- **Checking role holders:**
  ```
  netdom query fsmo
  Get-ADDomain | Select-Object PDCEmulator, RIDMaster, InfrastructureMaster
  Get-ADForest | Select-Object DomainNamingMaster, SchemaMaster
  ```
- **Transferring a role** (graceful, old DC still online):
  `Move-ADDirectoryServerOperationMasterRole -Identity DC02 -OperationMasterRole PDCEmulator`
- **Seizing a role** (old DC has failed and is unrecoverable): same cmdlet **with `-Force`**.
  - ⚠️ **Critical rule:** after seizing, **never bring the old role holder back online** — it still believes it holds the role and will cause conflicts.

---

## 10. DNS Server

- **Purpose:** translates hostnames to IP addresses; also enables **service discovery** (clients locate DCs, LDAP, Kerberos via DNS **SRV** records). Every domain-joined computer requires working DNS.
- **Client config needs:** primary (and optional secondary) DNS server address; DNS suffix (e.g. `contoso.com`). Set via `Set-DnsClientServerAddress -InterfaceAlias "Ethernet" -ServerAddresses "192.168.1.10","192.168.1.11"`.
- **Zone:** a portion of the DNS namespace managed by one authoritative server; stored as a file (traditional) or in AD (AD-integrated).
- **Zone types:**
  - **Primary** — writable master copy.
  - **Secondary** — read-only copy, updated via zone transfer from the primary.
  - **Stub** — contains only NS and A records pointing to the authoritative server.
  - **AD-Integrated** — stored in Active Directory, replicates automatically with AD.
- **Forward vs Reverse lookup zones:**
  - **Forward** — hostname → IP (e.g., `server01.contoso.com → 10.0.0.5`).
  - **Reverse** — IP → hostname; named by reversed IP prefix (e.g., zone `0.0.10.in-addr.arpa`).
- **Key resource record types:** **A** (hostname→IPv4), **AAAA** (hostname→IPv6), **CNAME** (alias), **NS** (authoritative server for a zone), **MX** (mail server), **SRV** (service location — LDAP/Kerberos), **PTR** (IP→hostname).
- **Recursive vs Iterative queries:**
  - **Recursive** — client asks its resolver for a *final* answer; the resolver does all the work (used between workstation ↔ its configured DNS server).
  - **Iterative** — one DNS server asks another, gets a referral, and tries the next ("I don't know — try that server"); used **between** DNS servers during external resolution.
- **Internet resolution chain:** client → local resolver → **root servers** (13 addresses, `a`–`m.root-servers.net`) → **TLD server** (e.g. `.com`, `.pl`) → **authoritative server** for the domain → answer cached per TTL.
- **Zone delegation:** transferring authority for a sub-zone to a different server (e.g., `contoso.com` delegates `emea.contoso.com` to a London server); implemented with **NS records**; required when creating child domains in a forest.
- **Why AD depends on DNS:** AD components are discovered **entirely** through SRV records — DC lookup via `_ldap._tcp.contoso.com`, Kerberos via `_kerberos._tcp.contoso.com`. Broken/missing SRV records → failed logon, GPO failures, replication failures.
- **The `_msdcs` subdomain:** automatically created alongside the main domain zone when a domain is installed. Contains AD-specific service records: DC locator (SRV/CNAME), Global Catalog locator, PDC Emulator locator. Kept separate to allow independent replication/delegation.
- **AD-integrated zone replication:** stored in the **Application partition** of the AD database; replicates automatically with AD (no manual zone transfer). Replication scope choices: all DNS servers in the forest, all DNS servers in the domain (default for `_msdcs`), or all DCs in the domain. No single point of failure — any DC can answer authoritatively.

---

## 11. Certificate Services (PKI / AD CS)

- **PKI (Public Key Infrastructure):** a system of policies/procedures/technology for issuing, managing, and revoking digital certificates that bind public keys to identities.
- **PKI provides four properties:** **Confidentiality** (only intended recipient decrypts), **Integrity** (data unaltered), **Authenticity** (verifies identity claims), **Non-repudiation** (sender can't deny sending).
- **Certificate basics:** binds a public key to an identity; signed by a **Certification Authority (CA)** — a trusted third party. Key fields: **Subject**, **Issuer**, **Validity period**, **SANs** (Subject Alternative Names), **Key Usage / Extended Key Usage (EKU)**.
- **Why browsers warn on unknown internal CAs:** if the Root CA cert isn't in the browser's trusted root store, the chain can't be verified — fix by distributing the Root CA cert via GPO (`Computer Configuration > Windows Settings > Security Settings > Public Key Policies`).
- **Trust chain:** **Root CA** (self-signed) → **Subordinate/Issuing CA** (signed by root, issues end certs) → **End-entity certificate**. Hierarchies let the Root stay **offline** (reduced compromise risk) and let subordinate CAs be replaced without touching the root.
- **Certificate use cases:** TLS/HTTPS, EFS (Encrypting File System — symmetric file key wrapped by user's cert public key), document signing, smart cards (cert-based logon instead of password), network protocols (IPSec machine auth, 802.1X/EAP-TLS).
- **AD CS (Active Directory Certificate Services)** role services: **Certification Authority** (core issuing/management service), **CA Web Enrollment** (browser-based request UI), **Online Responder (OCSP)** (real-time revocation check, faster than full CRL), **NDES** (issues certs to network devices via SCEP).
- **Stand-alone vs Enterprise CA:**

| | Stand-alone CA | Enterprise CA |
|---|---|---|
| Domain required | No | Yes |
| Certificate templates | No | Yes |
| GPO autoenrollment | No | Yes |
| Publishes CRL/AIA in AD | No | Yes |
| Issuance | Manual approval (default) | Automatic (if template allows) |
| Best used as | Offline root CA | Issuing CA for domain members |

- **Two-tier deployment best practice:** offline Root CA + online Enterprise Issuing CA. To get autoenrollment working for, e.g., 50 web servers: Enterprise CA is required (Stand-alone can't autoenroll); create/duplicate a Web Server template, enable autoenrollment, grant Enroll+Autoenroll to Domain Computers, push via GPO under `Computer Configuration > Windows Settings > Security Settings > Public Key Policies > Certificate Services Client – Auto-Enrollment`.
- **Key install decisions (can't change later):** computer name/domain (becomes part of every issued cert), CA type, key length (4096-bit RSA recommended for roots), hash algorithm (SHA-256 minimum, SHA-1 deprecated), validity period (root: 10–20 yrs, issuing: ~5 yrs).
  `Install-WindowsFeature -Name ADCS-Cert-Authority -IncludeManagementTools` then `Install-AdcsCertificationAuthority -CAType EnterpriseRootCA`.
- **Certificate templates:** AD-stored blueprints, shared by all Enterprise CAs in the domain. Define key usage/EKU, validity/renewal period, subject name format, crypto settings, issuance requirements.
- **Template permissions:** Read (see template — required baseline), Write (modify), **Enroll** (request a cert), **Autoenroll** (zero-touch receipt via GPO), Full Control (all + delegation).
- **Issuance methods:** Autoenrollment (GPO-driven, zero user action), Manual request (`certmgr.msc`/`certlm.msc`), Web enrollment (CA Web Enrollment role), Enrollment Agent (a trusted user requests on behalf of others, e.g., smart cards).
- **CDP vs AIA:**
  - **CDP (CRL Distribution Point):** where clients download the **CRL** to check revocation status.
  - **AIA (Authority Information Access):** where clients download the **issuing CA certificate** to build the chain of trust.
  - Both can be published to AD DS/LDAP (domain members only) or an HTTP web server (reachable by all clients, including non-domain).
  - `Get-CACrlDistributionPoint` / `Get-CAAuthorityInformationAccess`.
- **Revocation vs Expiry:** **revocation** invalidates a cert **before** its natural expiry (compromised key, employee departure, error issuance) — distinct from normal expiry. Process: admin revokes → CA publishes updated CRL → clients check CRL via CDP before trusting any cert. `Revoke-CACertificate -SerialNumber "..." -Reason "KeyCompromise"`.
- **Offline Root CA pitfall:** if taken offline without pre-publishing a long-validity CRL (e.g. 6+ months) reachable over **HTTP** (not just LDAP), all certs it ever signed start failing validation once the old CRL expires.
- **Key archival/recovery:** the CA can store an **encrypted copy of the private key** — but **only for encryption certs (e.g., EFS)**, **never** for signing/authentication keys. Requires a **Key Recovery Agent (KRA)** certificate. Used when keys are lost (profile deleted, OS reinstall, disk failure, device theft). Best practice: KRA on a dedicated secure account, exported cert/key kept offline, tested periodically.

---

## 12. Windows Firewall, IPSec, and OpenSSH

### Windows Firewall
- Host-based firewall, included and enabled by default on every Windows edition (MMC name: "Windows Defender Firewall with Advanced Security," product name now "Windows Firewall").
- **Default behavior:** block all inbound, allow all outbound; **stateful** (no explicit rule needed for the return traffic of an allowed connection).
- **Network profiles (3):**
  - **Domain** — auto-applied when a DC is reachable; **cannot be manually set**.
  - **Private** — internal/home networks; set manually by an admin.
  - **Public** — default for unidentified networks; most restrictive.
  - Check active: `Get-NetConnectionProfile`. Check settings: `Get-NetFirewallProfile -Name Domain`.
- **Rule anatomy:** Action (Allow/Block), Direction (Inbound/Outbound), Protocol (TCP/UDP/ICMP), Port, Program, Profile.
  `New-NetFirewallRule -DisplayName "Allow HTTPS Inbound" -Direction Inbound -Protocol TCP -LocalPort 443 -Action Allow -Profile Domain`
- **Predefined vs custom rules:** Windows ships ~500 predefined rules tied to features/roles (e.g., enabling DHCP Server opens UDP/TCP 67/68; Remote Desktop opens TCP 3389; OpenSSH Server opens TCP 22). Best practice: check for an existing predefined rule before creating a custom one.
- **GPO deployment:** `Computer Configuration > Windows Settings > Security Settings > Windows Firewall with Advanced Security`. **Local rule merge** setting: `AllowMerge` (local admins can add their own rules on top, default) vs `Block` (only GPO rules apply — recommended for servers).
- **Troubleshooting workflow:** (1) check active profile, (2) check rule exists/enabled, (3) enable logging (`Set-NetFirewallProfile -LogAllowed True -LogBlocked True`, log at `%SystemRoot%\System32\LogFiles\Firewall\pfirewall.log`), (4) `Test-NetConnection -ComputerName srv1 -Port 443`, (5) inspect log for DROP entries.

### IPSec
- **IPSec** = a protocol suite that **authenticates** and optionally **encrypts** every IP packet between two hosts. Firewall decides *what* traffic is permitted; IPSec ensures permitted traffic is genuinely authenticated/encrypted. Protects against ARP spoofing, MITM interception, packet injection.
- Configured in the **same** Windows Firewall snap-in/GPO node, via **Connection Security Rules**.
- **Use cases:** DC-to-DC replication, admin-workstation-to-sensitive-server, server isolation zones.
- **Enforcement levels matter:** **Request authentication** — tries IPSec, but falls back to unprotected if the peer can't authenticate (communication still works). **Require authentication** — refuses unprotected traffic entirely; peer **must** also have a matching rule or communication fails. → drives a **phased rollout**: deploy Request first, verify SAs form everywhere, *then* switch to Require.
- **Transport mode vs Tunnel mode:**
  - **Transport** — host-to-host, encrypts payload only, original IP header preserved; used with Connection Security Rules.
  - **Tunnel** — site-to-site VPN, wraps the entire packet in a new outer packet (out of this course's scope).
- **Authentication methods:** **Kerberos V5** (uses existing AD creds, domain-joined machines, needs reachable DC), **Pre-shared key (PSK)** (static shared secret — legacy/testing only, not recommended), **Computer certificate from a CA** (machine proves identity via trusted cert — **recommended for production**, typically with IKEv2).
- **Critical IKEv2 certificate requirement:** the machine cert **must** include the EKU **"IP Security IKE Intermediate" (OID 1.3.6.1.5.5.8.2.2)**. A standard Computer or Web Server template does **not** include this — IKE negotiation will **silently fail with no logged error**. Fix: duplicate the built-in "IPSec (Offline Request)" template, add the EKU, enroll on both machines *before* configuring the rule.
- **Monitoring:**
  - `Get-NetIPsecMainModeSA` — Phase 1 (authentication) success.
  - `Get-NetIPsecQuickModeSA` — Phase 2 (encrypted tunnel active).
  - Security event log IDs: **4650/4651** = SA established, **4653** = SA failed.
- **Most common IPSec failure causes (in order):** (1) cert missing the IKE Intermediate EKU, (2) Root CA cert not trusted on one of the two machines, (3) mismatched authentication methods between the two Connection Security Rules.

### OpenSSH
- Comparison: RDP (Windows-only client, limited scripting) vs PowerShell Remoting (WS-Man, Windows-centric, scriptable) vs **OpenSSH** (cross-platform client, fully scriptable). Built into Windows since Server 2019; **pre-installed by default on Server 2025**.
- **Enable:** GUI — Server Manager > Local Server > Remote SSH Access > Enabled. PowerShell:
  ```
  Get-Service -Name sshd | Set-Service -StartupType Automatic
  Start-Service sshd
  ```
  The predefined firewall rule for TCP 22 is created automatically.
- **Restrict access:** edit `%ProgramData%\ssh\sshd_config`, e.g. `AllowGroups contoso\sshusers contoso\serveroperators`.
- **Key-based authentication:** asymmetric crypto — private key never leaves the client; survives password policy changes, can be revoked independently. `ssh-keygen -t ecdsa` generates a private key (`id_ecdsa`, keep secret) and public key (`id_ecdsa.pub`, copy to server).
- **ssh-agent:** loads the decrypted private key into memory and serves it to `ssh` on demand (`Set-Service -StartupType Automatic`, `Start-Service ssh-agent`, `ssh-add ...`).
- **`authorized_keys` location depends on account type — critical distinction:**
  - **Standard user:** `C:\Users\<username>\.ssh\authorized_keys`.
  - **Administrators group member:** `C:\ProgramData\ssh\administrators_authorized_keys`.
  - This admin file requires a **strict ACL**; if permissions are too broad/open, **sshd silently ignores the file** (set via `icacls.exe` granting only Administrators:F and SYSTEM:F).
- **Default shell:** `cmd.exe` by default after SSH login — must be changed via registry key `HKLM:\SOFTWARE\OpenSSH\DefaultShell` to point at `powershell.exe` (built-in 5.1) or `pwsh.exe` (PowerShell 7, installed separately via `winget`), then `Restart-Service sshd`.

---

## Quick-Reference: Key Numbers & Defaults

| Item | Value |
|---|---|
| GPO refresh interval (computer & user) | every 90–120 minutes |
| Intra-site replication propagation | under 5 minutes (change-triggered) |
| Inter-site replication default interval | every 180 minutes |
| Lab attendance — max absences allowed | 4 |
| Lecture bonus activities | up to 20% of final grade |
| Minimum CPU speed (Server 2025) | 1.4 GHz |
| Minimum RAM — GUI / Core | 2GB / 512MB (1024MB to install Core) |
| Minimum disk | 32GB |
| Root CA recommended key length | 4096-bit RSA |
| Root CA validity | 10–20 years |
| Issuing CA validity | ~5 years |
| Minimum hash algorithm | SHA-256 (SHA-1 deprecated) |
| IKEv2 required EKU OID | 1.3.6.1.5.5.8.2.2 (IP Security IKE Intermediate) |
| OpenSSH default port | TCP 22 |
| RDP default port | TCP 3389 |

---

# Practice Exam Questions

Each question has exactly one correct answer out of three options.

**1. Which group scope can contain user accounts and groups from any domain in the forest, but is itself visible only within its own domain?**
A) Global group
B) Domain Local group
C) Universal group

**2. A folder's NTFS permission is `G_Accounting::Full control::Allow` and its Share permission is `Domain Users::Read::Allow`. What is the effective permission when accessing the folder via `\\dc1\reports`?**
A) Full control, because NTFS permissions always override Share permissions
B) Read, because the most restrictive of the two applicable permissions applies
C) Full control, because Share permissions are ignored when NTFS permissions exist

**3. Which statement about Organizational Units (OUs) versus Containers is correct?**
A) Containers can have Group Policy Objects linked to them, just like OUs
B) OUs can be nested and have permissions/GPOs assigned; containers cannot
C) Containers and OUs are functionally identical, differing only in icon

**4. An administrator wants software to install automatically on 200 computers at next startup, with users unable to uninstall it. Which combination is correct?**
A) Published deployment under Computer Configuration
B) Assigned deployment under Computer Configuration
C) Assigned deployment under User Configuration, applied at logon

**5. Which Group Policy Client Side Extension is notable for NOT being refreshable using `gpupdate`?**
A) Folder Redirection
B) Administrative Templates
C) Software Installation

**6. A Password Settings Object (PSO) can be linked directly to which of the following?**
A) An Organizational Unit only
B) Users or security groups, but never OUs
C) The domain root only

**7. Two PSOs apply to the same user. Which one takes effect?**
A) The one created most recently
B) The one with the higher `msDS-PasswordSettingsPrecedence` value
C) The one with the lower `msDS-PasswordSettingsPrecedence` value

**8. What is the default interval for AD inter-site replication (assuming default settings)?**
A) Every 15 minutes
B) Every 180 minutes
C) Change-triggered, near real-time

**9. Which FSMO role is responsible for time synchronization across all domain controllers in a domain and is the first to learn of password changes?**
A) RID Master
B) PDC Emulator
C) Infrastructure Master

**10. After seizing a failed DC's FSMO role onto another DC, what must the administrator do regarding the original (failed) DC?**
A) Bring it back online as soon as possible to restore redundancy
B) Never bring it back online, since it still believes it holds the role
C) Re-promote it immediately as a Global Catalog server

**11. Which DNS record type allows clients to locate AD services such as LDAP and Kerberos?**
A) CNAME
B) SRV
C) PTR

**12. What is the key difference between a recursive and an iterative DNS query?**
A) A recursive query is used only for reverse lookups; iterative is only for forward lookups
B) In a recursive query the resolver returns a final answer; in an iterative query, each server only refers the client to another server
C) Recursive queries always use UDP, iterative queries always use TCP

**13. Why is the `_msdcs` subdomain created separately from the main domain DNS zone?**
A) To store user mailbox records separately from computer records
B) To allow independent replication and delegation of AD-specific service location records
C) Because Windows requires all DNS zones to have at least two sub-zones

**14. What distinguishes a Stand-alone CA from an Enterprise CA?**
A) A Stand-alone CA supports GPO autoenrollment, while an Enterprise CA does not
B) An Enterprise CA requires AD and supports certificate templates and GPO autoenrollment; a Stand-alone CA does not
C) There is no functional difference; the names refer only to licensing

**15. What is the purpose of the "IP Security IKE Intermediate" Extended Key Usage on a certificate?**
A) It is required for any certificate used with EFS file encryption
B) It is required on machine certificates for IKEv2-based IPSec authentication to succeed
C) It allows a certificate to be used for SSH key-based authentication

**16. A CRL Distribution Point (CDP) is used by clients to:**
A) Download the issuing CA's certificate to build a trust chain
B) Download the Certificate Revocation List to check if a certificate has been revoked
C) Request a brand-new certificate from the CA automatically

**17. On Windows Server 2025, where must the public key be placed for a user who is a member of the local Administrators group to log in via SSH key authentication?**
A) C:\Users\<username>\.ssh\authorized_keys
B) C:\ProgramData\ssh\administrators_authorized_keys
C) C:\Windows\System32\OpenSSH\authorized_keys

**18. In a Windows Firewall Connection Security Rule, what happens if one host requires IPSec authentication ("Require") but the peer host has no matching rule configured at all?**
A) Traffic falls back to unprotected communication automatically
B) Communication fails, since the requiring host refuses unprotected traffic
C) The connection is allowed once, then blocked on subsequent attempts

**19. Which Windows network profile is automatically applied when a domain controller is reachable, and cannot be set manually by an administrator?**
A) Private
B) Public
C) Domain

**20. What happens when permission inheritance is disabled on a folder that previously inherited permissions?**
A) All access to the folder is immediately revoked for everyone
B) The previously inherited permissions can be either deleted or copied and converted into direct permissions
C) Inheritance cannot be disabled once it has been applied

---

## Answer Key

1-C, 2-B, 3-B, 4-B, 5-C, 6-B, 7-C, 8-B, 9-B, 10-B, 11-B, 12-B, 13-B, 14-B, 15-B, 16-B, 17-B, 18-B, 19-C, 20-B
