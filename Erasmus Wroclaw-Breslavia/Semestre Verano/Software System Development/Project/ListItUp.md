# ListItUp — Full Project Brief
> **For the AI reading this:** You have the full picture of this project below. Two report sections (S3 and S4) are empty templates — your job is to fill them with real content, then help implement the actual application. Read everything carefully before acting.

---

## 0. Meta — How to Use This Document

| What | Detail |
|---|---|
| Project | ListItUp — a social list-curation web platform |
| Team | Group 2, Team 1 — 6 members (PM: Carmelo Romero Pérez) |
| Course | SSD 2026 |
| Status | S1 ✅ done · S2 ✅ done · **S3 ✅ done** · **S4 ⬜ empty** |
| Goal for AI | Complete S4 (Construction & Tests) in the `.docx` report, then implement the MVP |

---

## 1. The Idea

ListItUp is a **social list-curation web platform** where anyone can build and share ranked or ordered lists about anything — top movies, best study tools, favourite restaurants, gear recommendations, etc.

The core insight: people trust human-curated picks over algorithmic feeds. There is no general-purpose, social, dead-simple list platform. Letterboxd does it only for films. Notion is too flexible and unsocial. ListItUp fills that gap.

**Three-sentence pitch:** Users sign up via Google/GitHub OAuth, create beautiful public lists with items (title, description, image, external link), and discover lists from people they follow. Verified creators get analytics. Admins moderate content.

---

## 2. Business Goals

| Goal | Measurable Target |
|---|---|
| Make content creation effortless | ≥ 80% of test users publish a list without help |
| Provide instant value through discovery | New user finds relevant list in < 10–15 seconds |
| Grow an active community | ≥ 15% of pilot users leave at least one interaction (like/save/comment) |
| Deliver a fast, reliable experience | 99.5% uptime · page load TTI < 3 seconds |

---

## 3. Stakeholders

### Internal

| Symbol | Name | Role | Description |
|---|---|---|---|
| I1 | Carmelo A. Romero Pérez | PM / Team Leader | Leads the team, coordinates stakeholders, owns schedule and scope, primary contact for sponsor/IT; also contributes across project tasks as needed. |
| I2 | Álvaro Puebla Ruisánchez | Cross-functional member | Contributes across planning, development, testing, deployment and documentation as required. |
| I3 | David Sosa Domínguez | Cross-functional member | Contributes across planning, development, testing, deployment and documentation as required. |
| I4 | Carmen Gutiérrez Sánchez | Cross-functional member | Contributes across planning, development, testing, deployment and documentation as required. |
| I5 | Diego García Agrelo | Cross-functional member | Contributes across planning, development, testing, deployment and documentation as required. |
| I6 | Miryam Merchán León | Cross-functional member | Contributes across planning, development, testing, deployment and documentation as required. |

### External

| Symbol | Name | Role | Description |
|---|---|---|---|
| E1 | Casual Users | Standard Users | Everyday users who use the app to discover cool recommendations and share their own interests. They can browse, create, edit, and share their own lists. They interact with the community by leaving likes, comments, and saving other people's lists to their personal collections. |
| E2 | Verified Creators | Content Creators/Influencers | High-profile users, influencers, or experts who have a "verified" status on the platform. Alongside standard features, they have access to exclusive tools: a "Creator Dashboard" to view profile and list analytics (like views, saves, and link clicks), a verified badge on their profile, and the ability to pin top lists to their page. |
| E3 | App Administrators | Platform Moderators | A special user role (managed by our team during this phase) with permissions to manage the platform. They can delete inappropriate test lists, remove buggy comments, and keep the database clean during the testing period. |
| E4 | Third-Party API Providers | Technology Partners | Providers of external APIs integrated into the platform: social login (Google, GitHub), image hosting, and link-metadata enrichment. They define technical constraints and service-level agreements. |

---

## 4. Domain Description

### Domain Phenomena

- **User Registration & Roles:** Users sign up to the platform. They can be standard users, "verified" creators (influencers/VIPs), or admins who manage the platform.
- **Creating and Managing Lists:** Users build collections of their favourite things (e.g., top 10 movies, best study tools). A list can be public or private, and the creator can edit or update it over time.
- **Adding Items:** Inside each list, users add specific items. Each item usually has a title, a short description, an image, and an external link to the product or place.
- **Social Interactions and Discovery:** Users browse the app's feed or search by categories to discover new lists. If they find an interesting list, they can leave a "Like", write a comment, or save the list to their personal profile.
- **Follower System and Creator Stats:** Users can follow their favourite creators to see their new lists on their home feed. Verified creators get access to extra data, like how many views or saves their lists are getting.
- **Follow graph:** Users follow curators, creating a directed social graph. Followers receive a personalised feed of newly published or updated lists from those they follow.
- **Alerts and Notifications:** The app sends a notification when someone likes a user's list, leaves a comment, or when a followed creator posts something new. Also, if there is an update to a saved list, notifications are triggered via in-app and/or email channels.
- **Content Moderation:** Users can report lists, items, or comments that violate platform guidelines. Reported content enters a moderation review queue managed by administrators.

### Entities & Key Attributes

| Entity | Key Attributes | Key Relationships |
|---|---|---|
| **User** | userId, username, email, password, biography, profilePicture, role (standard/verified/admin), createdAt | Creates Lists (1:N); Follows Users (M:N self-referential); Writes Comments (1:N); Gives Likes (1:N); Submits Reports (1:N); Receives Notifications (1:N) |
| **List** | listId, title, description, coverPhoto, createdAt, visibility (public/private) | Created by User (N:1); Contains Items (1:N); Belongs to Category (N:1); Receives Comments (1:N); Receives Likes (1:N) |
| **Item** | itemId, title, description, externalUrl, photo, positionIndex | Belongs to List (N:1) |
| **Category** | categoryId, name, icon | Contains Lists (1:N) |
| **Comment** | commentId, text, timestamp | Written by User (N:1); Belongs to List (N:1) |
| **Like** | likeId, timestamp | Given by User (N:1); Belongs to List (N:1) |
| **Notification** | notificationId, message, isRead, timestamp | Received by User (N:1) |
| **Report** | reportId, reason, status (open/reviewed/resolved), timestamp | Submitted by User (N:1) |
| **Follow** | followId, timestamp | Join entity for User ↔ User M:N |

---

## 5. Functional Requirements (S2)

> **Note:** Symbol numbering follows the S2 report (FR1–FR7). The original brief used FR1–FR9; S2 consolidated and re-scoped them. FR1–FR5 are Must; FR6–FR7 are Should.

| Symbol | Type | Description | MoSCoW | Source |
|---|---|---|---|---|
| FR1 | Business Logic | **Create a List:** Authenticated users can create and publish a curated list with a title, description, cover photo, and public/private visibility. | Must | E1, E2 |
| FR2 | Business Logic / Data Management | **Manage Items:** Users can add, edit, reorder, and delete items within a list. Each item supports a title, short description, external URL, and optional photo. | Must | E1, E2 |
| FR3 | Business Logic | **Discovery and Search:** The platform offers a category-based feed of public lists and a keyword search filterable by category and sortable by relevance or recency. | Must | E1, E2 |
| FR4 | Business Logic / Social Interaction | **Social Interactions:** Users can follow others, like lists, post comments, and save lists to a personal collection. | Must | E1, E2 |
| FR5 | Business Logic / Moderation | **Reporting and Moderation:** Users can report lists, items, or comments. Administrators can review reports and delete any content from a dedicated panel. | Must | E1, E3 |
| FR6 | Data Exchange / Notifications | **Notifications:** The system sends in-app notifications for likes, comments, and new posts from followed creators. Key events also trigger email notifications via a third-party provider. | Should | E1, E2, E4 |
| FR7 | User Interface / Analytics | **Creator Analytics:** Verified creators have access to a private dashboard showing per-list statistics: views, saves, likes, and link clicks, updated daily. | Should | E2 |

---

## 6. Non-Functional Requirements (S2)

> **Note:** Symbol numbering follows the S2 report (NF1–NF8), which is more detailed than the original brief.

| Symbol | Type | Description | MoSCoW | Source | Verification Method |
|---|---|---|---|---|---|
| NF1 | Performance / Efficiency | **Page Load Time:** Primary pages must fully render within 3 seconds on a standard broadband connection, measured as Time to Interactive (TTI). | Must | E1, E2 | Run Lighthouse on the three core pages from a cold cache; all TTI values must be below 3 seconds. |
| NF2 | Reliability / Availability | **System Uptime:** The platform must maintain at least 99.5% uptime throughout the pilot period. | Must | E1, E3 | Monitor uptime via UptimeRobot with 1-minute polling; compute the monthly ratio at the end of the pilot and confirm it meets or exceeds 99.5%. |
| NF3 | Security | **HTTPS Encryption:** All client-server communication must be encrypted using TLS 1.2 or higher. No sensitive data may be transmitted over plain HTTP. | Must | E1, E2 | Use browser devtools network tab to confirm all requests use HTTPS. Run an SSL Labs test on the deployed domain and verify a grade of A or higher. |
| NF4 | Legal / Privacy | **GDPR / Legal Compliance:** The platform must comply with GDPR/RODO: users must be able to access, export, rectify, and erase their personal data. A cookie-consent banner must be displayed on first visit before any non-essential cookies are set. | Must | Legal – GDPR, E1 | Manually confirm that account deletion removes all personal user data. Verify that the cookie consent banner appears before any non-essential cookies are set. Confirm users can export their data on request. |
| NF5 | Usability | **Task Completion Rate:** At least 80% of pilot users must be able to complete the core create-and-publish-list task without any staff assistance, measured during moderated usability sessions. | Must | E1, E2 | Run a manual test suite across all target browsers and viewports. Conduct a usability session with at least 5 first-time users and record the task completion rate (target ≥ 80%). |
| NF6 | Compatibility / Responsiveness | **Cross-Browser Responsiveness:** The UI must render correctly and be fully functional across the two most recent stable versions of Chrome, Firefox, and Safari on both desktop and mobile viewports. | Must | E1, E2 | Run the manual test suite on the two latest versions of Chrome, Firefox, and Safari on desktop and mobile. All core user flows must pass with no layout breaks or functional errors. |
| NF7 | Security / Authentication | **OAuth 2.0 Social Login:** The platform must support user authentication exclusively via OAuth 2.0 (Google and GitHub). No platform-specific passwords are stored or managed. | Must | E1, E2, E4 | Attempt to register and log in using a Google and a GitHub account. Confirm the session is established without any platform password. Verify that no plain-text credentials are stored in the database. |
| NF8 | Usability / User Management | **User Profile Management:** Each user must have a publicly visible profile containing a username, biography, and profile picture. Verified creators must additionally display a verification badge on their profile. | Must | E1, E2 | Inspect a registered user profile: verify that username, biography, and profile picture fields are displayed. Log in as a verified creator and confirm that the verification badge appears on the profile page. |

---

## 7. Use Cases (S2)

### Actors

| Actor | Description |
|---|---|
| **E1 Casual User** | A registered standard user who browses, creates, and interacts with content. Primary actor across all four modules. |
| **E2 Verified Creator** | Extends Casual User with exclusive access to the Creator Analytics Dashboard and the ability to pin lists to their profile. Modelled using `<<extend>>` relationships. |
| **E3 App Administrator** | A privileged operator responsible for platform moderation. Interacts exclusively with the Administration module. |
| **E4 Third-Party API Provider** | An external system actor representing services consumed by the platform: OAuth provider, Open Graph metadata service, image host, and transactional email provider. |

### Use Case Map

| Module | Use Cases | Actors |
|---|---|---|
| **List Management** | UC1: Create and Publish List — user creates a curated list with title, description, cover photo and visibility. UC2: Item CRUD Management — user adds, edits, reorders and deletes items within a list. UC3: Set List Visibility — user toggles a list between public and private. UC4: Pin List to Profile `<<extend>>` — Verified Creator pins a list to the top of their profile page. UC5: Enrich Item Link via Open Graph `<<include>>` — system fetches Open Graph metadata from an item URL to populate preview image and title automatically. | UC1–UC3: E1, E2 · UC4: E2 only · UC5: E4 (system) |
| **Social & Discovery** | UC6: Browse Category Feed — user browses public lists organised by category on the home feed. UC7: Search Lists and Items by Keyword — user searches using free-text keywords. UC8: Follow / Unfollow a User — user subscribes or unsubscribes from another user. UC9: Like a List. UC10: Comment on a List — user posts a text comment. UC11: Save List to Personal Collection — user saves a list for later reference. UC12: View Creator Analytics Dashboard `<<extend>>` — Verified Creator views per-list statistics (views, saves, likes, link clicks). | UC6–UC11: E1, E2 · UC12: E2 only |
| **Notifications** | UC13: Receive In-App Notification — user receives a real-time in-app alert for likes, comments or new posts from followed creators. UC14: Receive Email Notification `<<include>>` — system sends an email digest for key events via a third-party email provider. | UC13: E1, E2 · UC14: E4 (system) |
| **Administration** | UC15: Review Content Report Queue — administrator reviews the queue of user-submitted content reports awaiting moderation. UC16: Delete List / Item / Comment — administrator removes flagged or inappropriate content. UC17: Submit Content Report — user reports a list, item or comment that violates platform guidelines. | UC15–UC16: E3 · UC17: E1/E2 (initiates) → E3 (processes) |

---

## 8. Technology Stack

| Layer | Technology | Description | Justification | Key Responsibilities |
|---|---|---|---|---|
| Backend language | **Java** | General-purpose, statically typed, object-oriented language and JVM platform. | All team members have existing experience — no onboarding overhead. Strong static typing reduces runtime errors; JVM ensures cross-platform consistency. | All server-side business logic: resource management, user role handling, API endpoints. |
| Backend framework | **Spring Boot** | Opinionated Java framework enabling rapid development of REST APIs with minimal configuration; includes embedded Tomcat. | Drastically reduces boilerplate vs. plain Spring; built-in support for REST controllers, DI, JPA/Hibernate ORM, Spring Security, and transaction management. | REST API layer, business logic services, authentication/authorisation, database access via Spring Data JPA. |
| Frontend | **HTML + CSS + Vanilla JS (Thymeleaf)** | Standard web technologies: HTML5 for structure, CSS3 for styling/responsiveness, vanilla JS for interactivity. Thymeleaf for server-side rendering. | Fastest path to a working UI within the 7-week MVP; no framework overhead; backend serves Thymeleaf-rendered pages directly, keeping the stack simple. | All user-facing pages: feed, list detail, create/edit, profile, admin panel, analytics dashboard. |
| Database | **MySQL** | Open-source relational DBMS with full SQL, ACID transactions, and FK constraints. | Proven, lightweight, pairs natively with Spring Data JPA/Hibernate; straightforward to manage inside Docker. | Persistent storage of all domain data: users, lists, items, categories, comments, likes, notifications, reports. |
| Reverse proxy | **Nginx** | High-performance HTTP server and reverse proxy; handles static files and TLS termination. | Single entry point for all incoming traffic; improves security; enables static asset serving and future rate limiting/load balancing. | Reverse proxy for Spring Boot API, HTTPS/TLS termination, static asset delivery. |
| Containerisation | **Docker + Docker Compose** | Docker packages apps into portable containers; Compose orchestrates multi-container stacks via a single YAML file. | Guarantees dev/prod environment parity; single-command startup (`docker compose up`); reproducible deployment with no manual configuration. | Containerisation of all services (Spring Boot + MySQL + Nginx), local dev environment, production deployment orchestration. |
| CI/CD | **GitHub Actions** | Integrated CI/CD platform built into GitHub; triggers configurable pipelines on push/PR events. | Native to GitHub — zero additional tooling cost; automates build, test, Docker image build, and deployment promotion on every pull request. | Automated build verification, test execution, Docker image build, deployment to production. |

### Third-Party APIs

| API | Purpose |
|---|---|
| Google & GitHub OAuth 2.0 | Social login — no platform passwords stored |
| Open Graph metadata | Enrich external links on items (auto-populate title + preview image) |
| Cloud object storage (free tier) | Image hosting for profile pictures, list covers, and item photos |
| Transactional email provider (free tier) | Email notifications for key events (FR6) |

---

## 9. Project Schedule

7-week MVP window. Sprints are 2 weeks. Total estimated effort: **384 hours** across 6 members. Actual budget: **€0** (free-tier cloud hosting, open-source tooling, personal laptops).

| ID | Task | Duration | Depends On | Notes | Dates |
|---|---|---|---|---|---|
| T1 | Requirements & concept finalisation | 1 wk | — | Define list types and workflows | 27/3/26 → 6/4/26 |
| T2 | Domain model & database setup (API, DB) | 1 wk | T1 | Entities, relations, policies | 7/4/26 → 15/4/26 |
| T3 | Frontend layout & navigation | 1 wk | T1 | Base pages, component library | 7/4/26 → 15/4/26 |
| T4 | List creation & item management module | 1.5 wk | T2 | Curator editor, draft/publish flow | 16/4/26 → 29/4/26 |
| T5 | Discovery engine (search, feed, trending) | 1.5 wk | T4 | Full-text search, trending, personalised feed | 30/4/26 → 13/5/26 |
| T6 | Social features (follow, like, comment, save) | 1 wk | T4 | Follow graph, interactions, saved collections | 30/4/26 → 8/5/26 |
| T7 | Notifications & moderation tools | 0.5 wk | T5, T6 | In-app + email notifications, admin panel | 14/5/26 → 19/5/26 |
| T8 | UX polish, accessibility & responsiveness | 0.5 wk | T3–T6 | WCAG 2.1 AA pass, mobile review | 14/5/26 → 19/5/26 |
| T9 | Testing, polishing & deployment | 1.5 wk | T7, T8 | QA + Docker deploy | 20/5/26 → 2/6/26 |

**Theoretical cost (if commercial):** ~€7,000–€10,000 for developers + enterprise infrastructure over 7 weeks.

---

## 10. Competitive Landscape

| Competitor | Main Features | Advantages | Disadvantages vs ListItUp |
|---|---|---|---|
| **Are.na** | Collaborative, non-algorithmic content curation. Users create "channels" containing any type of block (text, image, link, file) and connect blocks across channels. | Highly flexible; strong creative-professional community; no recommendation algorithm — editorial control belongs to the user; public API available. | Deliberately niche and minimalist; steep learning curve; limited discovery; free tier has a block limit; UX unfamiliar to general audiences. |
| **Raindrop.io** | Cross-platform bookmark manager with collections, tags, highlights, full-text search, and public sharing. | Polished, feature-rich bookmark management; excellent browser extension; clean UI; good import/export; available across all platforms. | Personal productivity tool rather than a social discovery platform; weak community and follow features; lacks curator ratings; minimal trending discovery. |
| **Product Hunt** | Community-driven platform for discovering new tech products. Daily launches upvoted by users; products accumulate reviews and discussions. | High-quality community of makers and early adopters; authoritative for product discovery; strong SEO; robust discussion systems; strong brand recognition. | Scope limited to technology products; curation features are secondary to the launch feed; strong platform lock-in; not suitable for general-purpose lists; perceived as promotional. |
| **Letterboxd** | Social film diary and review platform. Users log films watched, write reviews, and create thematic lists. Strong social follow graph. | Excellent domain-specific UX; high-quality curator community; elegant list-building tools; strong diary integration; large and growing user base. | Entirely domain-specific (films only); not generalisable; no public API; limited features for professional curators outside film. |
| **Listly** | Web-based list creation and curation tool for content marketers and bloggers. Embeddable lists, collaborative editing, social sharing. | Embeddable widget model; collaborative editing; good SEO for list pages; easy link import. | Outdated and cluttered UI; limited social features; primarily B2B/marketing-focused; weak mobile experience; minimal active general community. |
| **Notion (Public Databases)** | All-in-one productivity workspace supporting public databases, linked resources, gallery views, and filtered list publications. | Extremely flexible; excellent formatting and media embedding; no-code database views; large existing user base; free tier available. | Not purpose-built for social discovery; no native follow or notification model; slow public page load; no recommendation engine; no community engagement features. |

**ListItUp's gap:** general-purpose + social + dead-simple in one product.

---

## 11. Project Context

### Application Context

- **Tired of algorithms:** There is a growing demand for high-quality, human-created information. People are getting tired of automated recommendations and confusing search results; they want trustworthy, hand-picked information organised by actual humans.
- **The creators:** Many internet users and influencers want platforms where they can share specific knowledge and build an audience.
- **Market opportunity:** While there are great list apps for specific hobbies (like Letterboxd for movies), there is no widely used, simple web platform where people can curate and share lists about absolutely anything. ListItUp fills that gap.

### Technological Context

- **No app downloads:** Users expect things to just work in their browsers. The platform must provide a smooth experience on both mobile and desktop without forcing anyone to download a native app.
- **Third-party ecosystem reliance:** The platform depends on external providers for OAuth 2.0 social logins (Google, GitHub), Open Graph metadata for enriching links, cloud object storage for images, and transactional email services. Platform success and uptime are partially tied to the SLAs and constraints of these external technologies.

### Organisational Context

- **Academic deadlines:** The team is a cross-functional academic group of 6 members, strictly bound by the university calendar — a hard deadline and a limited 7-week window to deliver the MVP.
- **Budget and resource limitations:** €0 budget forces prioritisation of open-source components, containerised solutions, and free-tier cloud hosting. Development is done on shared personal developer laptops.
- **Development methodology:** Work is organised in 2-week sprints. Free collaboration tools used: GitHub, Figma, Slack.

### Legal Context

- **Data protection and privacy:** Collection of user emails and account management means GDPR/RODO compliance is mandatory. Users must be able to access, rectify, erase, and port their data.
- **Cookie regulations:** ePrivacy Directive compliance required — any non-session cookies require informed user consent via a banner on first visit.
- **User-generated content liability:** Clear Terms of Service required. Users retain copyright to the lists they create; the platform needs legal protection from responsibility for malicious external links.
- **Accessibility standards:** WCAG 2.1 AA accessibility standards must be met for all public pages.

### Constraints

- **Time:** 7-week hard deadline (academic calendar)
- **Budget:** €0 — free tiers only
- **No native apps:** Web-only; iOS/Android builds are impossible within the time/budget
- **No ML recommendations:** Discovery feed ranks lists based on basic engagement signals (views, likes, saves) only

### Opportunities

- **Massive open-source ecosystem:** Spring Boot, MySQL, and Docker are all free and enterprise-grade
- **Ready-to-use external APIs:** OAuth, Open Graph, and email APIs save weeks of development
- **Free CI/CD:** GitHub Actions at zero cost for automated testing and deployment
- **Team's existing knowledge:** All team members already know Java — no language ramp-up time

---

## 12. S3 — Design (COMPLETED)

### 3.1 Logical Software Architecture

The logical architecture of ListItUp follows a layered, container-based model decomposed into six primary components orchestrated via Docker Compose. All external traffic enters through Nginx, which terminates TLS and routes requests to the Spring Boot application. The database is isolated in its own container. The CI/CD pipeline runs on GitHub Actions and, while not part of the runtime topology, is shown for completeness.

> **Diagram:** See [ComponentDiagramLISTITUP.png](file:///c:/Users/alvaro/Desktop/alvaro/wroclaw/Software%20System%20Development/Project/S3/ComponentDiagramLISTITUP.png) for the UML 2.5 Component Diagram.

---

### 3.2 Business Logic Model

#### 3.2.1 Behavioural Model

**State Diagram — List Lifecycle**

A list begins **unpublished**, waiting for revision, until the system verifies it. Once verification is completed, a list can be **published** or **deleted** depending on the results of the verification. If the list is published, other users can interact with it. If the list receives 1000 likes in less than 2 hours it becomes a **trending** list. When 24 hours have passed, the list becomes published again (with the possibility to receive 1000 likes in less than 2 hours and be trending again). A published list can be **reported** by other users; if so, it is still visible but **under revision**. After that revision the list could be published as normal if the revision is successful, or deleted if it is unsuccessful. When a list is deleted it is cleared out of the system and dies.

> **Diagram:** See the S3 report for the full UML State Diagram.

**Use Case 1 — Create and Publish a List (Sequence & Activity Diagrams)**

This use case covers the full creation flow from the user clicking '+ Create List' to the newly published list appearing in the discovery feed. It is one of the most critical flows as it is directly tied to the core business goal of making content creation effortless (target: ≥ 80% of pilot users able to create and publish without assistance).

> **Diagrams:** See the S3 report for the Sequence Diagram and Activity Diagram for UC1.

**Use Case 2 — Follow a Creator and Receive Notification (Sequence & Activity Diagrams)**

This use case covers the social follow action and the resulting in-app notification, directly tied to the business goal of growing an active community (target: ≥ 15% interaction rate among pilot users). It involves cross-service coordination between UserService and NotificationService.

> **Diagrams:** See the S3 report for the Sequence Diagram and Activity Diagram for UC6/UC8.

#### 3.2.2 Structural Model

**Class Diagram Semantics:**

| Class | Semantics |
|---|---|
| **User** | Central entity representing any registered account. The `role` attribute (`STANDARD`, `VERIFIED`, `ADMIN`) discriminates behaviour: Verified Creators gain analytics access; Admins gain moderation access. Login is exclusively via OAuth 2.0; no platform password is stored. |
| **CuratedList** | A named, ordered collection of Items created by a User. The `isPinned` flag is only meaningful for Verified Creators and allows one list to be pinned on their profile page. The `viewCount` is an atomic counter incremented by the service layer on public page loads. |
| **Item** | A single entry within a CuratedList carrying a title, description, optional photo, external URL, and a `positionIndex` for display ordering. Items cascade-delete with their parent list. |
| **Category** | A read-only lookup table (seeded by the team) used to classify lists and power the discovery feed filters. |
| **Follow** | A join entity representing a directed social edge from follower (User) to following (User). A unique constraint prevents duplicate follows; a check constraint prevents self-follow. |
| **Like / SavedList** | Thin join entities linking a User to a CuratedList, both with a unique `(userId, listId)` constraint to prevent duplicates. |
| **Comment** | A textual contribution by a User on a CuratedList, cascade-deleted when either the author or the list is removed. |
| **Notification** | A system-generated message to a recipient User, optionally referencing a `triggerUser` and a `relatedList`. The `notifType` enum classifies events: `LIKE`, `COMMENT`, `FOLLOW`, `NEW_POST`. |
| **Report** | A user-submitted moderation request. It targets either a CuratedList or a Comment via nullable foreign keys. The `status` enum tracks the review lifecycle: `OPEN → REVIEWED → RESOLVED`. |

**Object Diagram — Execution Snapshot:**

Scenario: User `alice` (VERIFIED) has published two lists. User `bob` (STANDARD) follows alice, has liked her first list, and left a comment. Alice has one unread notification.

> **Diagram:** See the S3 report for the full Object Diagram.

---

### 3.3 Database Model

#### 3.3.1 Conceptual Model (ER Diagram)

This model represents a social list-curation platform where users build and share ranked lists about anything. It includes specialization hierarchies for users and supports complex social interactions, content moderation, and creator analytics.

> **Diagram:** See [SoftwareDBerModel.png](file:///c:/Users/alvaro/Desktop/alvaro/wroclaw/Software%20System%20Development/Project/S3/DBdiagrams/SoftwareDBerModel.png) for the full ER Diagram.

**Entities:**

| Entity | Description |
|---|---|
| **User** | Any person registered in the system. Key attributes: `userId`, `username`, `email`, authentication provider (OAuth: Google or GitHub), and account creation date. No passwords stored — exclusively OAuth 2.0 (NF7). Parent for VerifiedCreator and Admin specializations. |
| **VerifiedCreator** | Specialized User with elevated privileges: verification badge (`hasBadge`), ability to pin lists (`canPinLists`), and analytics dashboard access (`hasAnalyticsAccess`). |
| **Admin** | Specialized User representing platform moderators: permissions to moderate content (`canModerateContent`) and delete any content (`canDeleteAny`). |
| **List** | A curated collection of items. Attributes: `listId`, `creatorId` FK, `title`, `description`, `coverPhoto`, `visibility` (public/private), `createdAt`. Belongs to one Category, contains multiple Items. |
| **Item** | A single entry within a list. Attributes: `itemId`, `listId` FK, `title`, `description`, `externalUrl` (Open Graph enriched), `photo`, `positionIndex`. Always subordinate to a list. |
| **Category** | Topic/classification for lists. Attributes: `categoryId`, `name` (unique), `icon`. Users can propose new categories via CategoryProposal. |
| **Comment** | Text comment by a user on a list. Attributes: `commentId`, `userId` FK, `listId` FK, `text`, `createdAt`. |
| **Like** | User appreciation for a list. `UNIQUE(userId, listId)` prevents duplicates. Serves as engagement metric and ranking signal. |
| **Follow** | Self-referential M:N relationship. `UNIQUE(followerId, followeeId)` prevents duplicates; `CHECK(followerId ≠ followeeId)` prevents self-follows. Powers the social graph and personalized feed. |
| **SavedList** | User's personal collection of bookmarked lists. `UNIQUE(userId, listId)` prevents duplicates. |
| **CategoryProposal** | User suggestions for new categories. `UNIQUE(userId, categoryId)` prevents duplicate proposals. |
| **Report** | Moderation flag on content. Targets exactly one of: list, item, or comment (disjoint targeting). Status lifecycle: `OPEN → REVIEWED → RESOLVED`. Submitter FK uses `SET NULL` to preserve moderation history on user deletion. |
| **Notification** | In-app/email alert. Types: `LIKE`, `COMMENT`, `NEW_POST`, `SAVED_LIST_UPDATE`. Cascade-deleted with user (GDPR). |
| **ListAnalytics** | Weak 1:1 entity storing aggregated metrics (views, saves, link clicks) for VerifiedCreator lists. Updated daily by scheduled task (FR7). |

**Key Relationships:**

| Relationship | Cardinality | Delete Rule | Notes |
|---|---|---|---|
| Creates (User → List) | 1:N | CASCADE | GDPR — user deletion removes all personal lists |
| Contains (List → Item) | 1:N | CASCADE | Orphaned items automatically removed |
| BelongsTo (List → Category) | N:1 | RESTRICT | Lists must be reassigned before category deletion |
| Writes (User → Comment) | 1:N | CASCADE | GDPR compliance |
| HasComment (List → Comment) | 1:N | CASCADE | List deletion removes all comments |
| Gives (User → Like) | 1:N | CASCADE | UNIQUE(userId, listId) |
| Receives (List → Like) | 1:N | CASCADE | Powers like counters and ranking |
| Follow (User ↔ User) | M:N | CASCADE | UNIQUE + CHECK constraints |
| SavedList (User ↔ List) | M:N | CASCADE | Personal collections |
| CategoryProposal (User ↔ Category) | M:N | CASCADE | Crowdsourced category expansion |
| Submits (User → Report) | 1:N | SET NULL | Preserves moderation history |
| Targets (Report → List/Item/Comment) | N:0..1 | SET NULL | Disjoint targeting rule |
| Reviews (Admin → Report) | 1:N | SET NULL | Moderation audit trail |
| Receives (User → Notification) | 1:N | CASCADE | GDPR — ephemeral activity data |
| HasAnalytics (List → ListAnalytics) | 1:0..1 | CASCADE | Only for VerifiedCreator lists |

**Specialization Hierarchy:** User → VerifiedCreator / Admin uses **single-table inheritance** strategy via `role` ENUM, simplifying Spring Boot JPA mapping and reducing join complexity.

**General System Behaviour:** The model supports creation/publication of curated lists (FR1), item management (FR2), category-based discovery and search (FR3), social engagement via follows/likes/comments/saves (FR4), community-driven moderation (FR5), notifications (FR6), creator analytics (FR7), GDPR compliance (NF4), and OAuth 2.0-exclusive authentication (NF7).

#### 3.3.2 Physical Model

> **Diagram:** See [SoftwareDBPhysicalModel.png](file:///c:/Users/alvaro/Desktop/alvaro/wroclaw/Software%20System%20Development/Project/S3/DBdiagrams/SoftwareDBPhysicalModel.png) for the full Physical Model diagram.

**Key Transformation Notes (Conceptual → Physical):**

- **Follow table:** `FK_follower_id : char(36)` and `FK_followee_id : char(36)` must be different — `UNIQUE (follower_id, followee_id)` prevents duplicate follows; `CHECK (follower_id <> followee_id)` prevents self-follows.
- **saved_list table:** `UNIQUE (user_id, list_id)` — a user saves a list only once.
- **category_proposal table:** `UNIQUE (user_id, category_id)` — a user proposes a given category only once.
- **report table:** `CHECK` — exactly one of `(target_list_id, target_item_id, target_comment_id)` is NOT NULL (enforced at app layer or via CHECK constraint).
- **Inheritance:** Single-table strategy — all User roles (STANDARD, VERIFIED, ADMIN) stored in one `user` table with a `role` ENUM column.

---

### 3.4 User Interface Design

These are the different pages designed for this project. Additional pages may be created as the project advances and evolves.

> **Screen mockups:** See the [ScreensUI](file:///c:/Users/alvaro/Desktop/alvaro/wroclaw/Software%20System%20Development/Project/S3/ScreensUI/) directory for all screen designs.

#### Screen 1 — Home Feed (`/feed` or `/`)

| Component | Event | Behaviour |
|---|---|---|
| Category pill (e.g. 'Books') | click | Appends `?category=books` to URL; page reloads with filtered feed. Active pill highlighted. Pills sourced from `/categories` endpoint. |
| Sort tab (Trending / Recent / Following) | click | Appends `?sort=trending|recent|following` to URL; page reloads. 'Following' requires authentication; anonymous users are redirected to `/login`. |
| List card | click anywhere on card | Navigate to `/lists/{listId}`. |
| Heart icon on list card | click | JS fetch `POST /lists/{listId}/like` (toggle). Heart fills/unfills optimistically; reverts on error. Like count updates without page reload. |
| Notification bell (navbar) | click | Dropdown shows last 10 notifications. Unread badge clears. Each notification links to the related list. |
| Search bar (navbar) | submit (Enter / magnifier click) | Navigate to `/search?q={keyword}`. |
| '+ Create List' button (navbar) | click | Navigate to `/lists/new`. If not authenticated, redirect to `/login` with redirect-after-login param. |

#### Screen 2 — List Detail (`/lists/{listId}`)

| Component | Event | Behaviour |
|---|---|---|
| Like button | click | Toggle via fetch `POST /lists/{id}/like`. Button state and count update without reload. |
| Save button | click | Toggle via fetch `POST /lists/{id}/save`. Redirects to `/login` if unauthenticated. |
| Edit button (owner only) | click | Navigate to `/lists/{id}/edit`. |
| External link on item | click | Opens URL in new tab. JS fires a link-click analytics event to `/lists/{id}/items/{itemId}/click` (fire-and-forget). |
| Comment textarea + Post button | click Post | AJAX `POST /lists/{id}/comments` with `{text}`. New comment card appended to DOM. Empty text rejected client-side. |
| Delete comment (author or admin only) | click | Confirm dialog → fetch `DELETE /lists/{id}/comments/{commentId}`. Card removed from DOM on success. |
| Report this list | click | Modal opens with reason textarea. On submit: `POST /reports` with `{targetListId, reason}`. Modal closes with success toast. |

#### Screen 3 — Create / Edit List (`/lists/new` and `/lists/{id}/edit`)

| Component | Event | Behaviour |
|---|---|---|
| Title field | blur / input | Client-side validation: required, max 150 chars. Inline error displayed on violation. |
| Category dropdown | change | Populated via categories loaded on page render (Thymeleaf model). |
| Cover Photo upload | file selected | Preview shown below button. File uploaded via fetch `POST /upload/image`; returned URL stored in hidden form field. |
| Visibility radio | change | Toggles visual indicator. No server call until form submission. |
| Item drag handle | drag-and-drop (HTML5 drag API) | Items reorder in DOM. On drop, `positionIndex` values recalculated and stored in hidden inputs. |
| Item URL field | blur | If URL non-empty, fetch `GET /og?url={url}`. Response auto-fills adjacent title/description fields if currently empty. |
| Delete item button | click | Remove item row from DOM. On edit, item marked for deletion via hidden `delete_ids[]` input. |
| + Add item button | click | Appends a new empty item row. Max 50 items enforced client-side. |
| Publish button | click / form submit | Client validates: title required + ≥1 item with title. On pass: `POST` (create) or `PUT` (edit) to `/lists[/{id}]`. Server validates with Bean Validation. Success → redirect to `/lists/{id}`. Error → form re-rendered with messages (Thymeleaf). |

#### Screen 4 — User Profile (`/users/{username}`)

| Component | Event | Behaviour |
|---|---|---|
| Follow / Unfollow button | click | fetch `POST/DELETE /users/{userId}/follow`. Button label toggles. Follower count updates without reload. |
| Edit Profile button | click | Navigate to `/users/me/edit`. Form with username, bio, avatar upload. |
| Saved tab | click | fetch `GET /users/{username}?tab=saved`. Shows lists the user has saved. |
| Follower / Following count link | click | Modal opens listing followers or following users with Follow/Unfollow buttons. |
| Pinned list card (Verified only) | click | Navigate to `/lists/{listId}`. |

#### Screen 5 — Admin Panel (`/admin`, ADMIN role only)

| Component | Event | Behaviour |
|---|---|---|
| Mark Reviewed button (per report row) | click | fetch `PATCH /admin/reports/{id}` `{status: 'REVIEWED'}`. Row status badge updates inline. |
| Delete Content button (per report row) | click | Confirm dialog → fetch `DELETE /admin/content/{type}/{id}`. Removes list or comment; report auto-resolved. Row updates inline. |
| Role dropdown + Apply button | click Apply | fetch `PATCH /admin/users/{id}/role` `{role: 'VERIFIED'|'STANDARD'|'ADMIN'}`. Confirmation toast shown. |
| Spring Security access control | any request to `/admin/**` | If `user.role != ADMIN`: HTTP 403 returned; Thymeleaf renders 'Forbidden' page. |

#### Screen 6 — Creator Analytics Dashboard (`/analytics`, VERIFIED+ only)

| Component | Event | Behaviour |
|---|---|---|
| Per-list table column header (Views, Likes, etc.) | click | fetch `GET /analytics?sort={column}&order={asc|desc}`. Table re-renders sorted. Sort state stored in URL params. |
| List title link in table | click | Navigate to `/lists/{id}`. |
| Spring Security access control | any request to `/analytics` | If `user.role == STANDARD`: HTTP 403. Redirect to `/feed`. |
| Daily aggregation (scheduled task) | `@Scheduled(cron = '0 0 3 * * *')` | `AnalyticsService` aggregates `view_count`, `like count`, `save count`, `link_click_count` per list at 03:00 UTC daily. Results stored in `analytics_snapshot` table. Dashboard reads from snapshot for fast page load. |

#### Screen 7 — Search Results (`/search?q=&category=&sort=`)

| Component | Event | Behaviour |
|---|---|---|
| Category filter dropdown | change | Updates URL param `?category=`; page reloads with filtered results. |
| Sort dropdown (Relevance / Recency) | change | Updates URL param `?sort=relevance|recency`; page reloads. |
| Pagination controls | click page number | Updates URL param `?page=N`; page reloads. Server returns `Page<CuratedList>` slice via Spring Data Pageable. |

---

## 13. What S4 Needs (Construction & Tests — EMPTY TEMPLATE)

### 4.1. Implementation

#### 4.1.2. Technology Stack
- **Backend:** Java 17+, Spring Boot
- **Frontend:** Thymeleaf, HTML, CSS, Vanilla JS
- **Database:** MySQL
- **Containerization:** Docker, Docker Compose

#### 4.1.3. Artifacts List
**A. Source Code Artifacts**
- `backend/src/main/java/com/listitup/api/ListItUpApplication.java`: Main application entry point.
- `backend/src/main/java/com/listitup/api/config/`: Configuration classes (e.g., MVC, Security).
- `backend/src/main/java/com/listitup/api/controller/`: REST controllers for handling HTTP requests.
- `backend/src/main/java/com/listitup/api/dto/`: Data Transfer Objects for API requests and responses.
- `backend/src/main/java/com/listitup/api/model/`: JPA entities (User, List, Item, Comment, etc.).
- `backend/src/main/java/com/listitup/api/repository/`: Spring Data JPA repositories.
- `backend/src/main/java/com/listitup/api/security/`: Security and OAuth2 configurations.
- `backend/src/main/java/com/listitup/api/service/`: Business logic layer.

**B. Configuration Files**
- `docker-compose.yml`: Orchestrates the Spring Boot backend and MySQL services.
- `backend/Dockerfile`: Instructions to build the Spring Boot application container.
- `backend/pom.xml`: Maven configuration and dependencies.
- `backend/src/main/resources/application.properties`: Spring Boot application settings.
- `.env.example`: Template for environment variables.

**C. Resource Files**
- `backend/src/main/resources/templates/`: Thymeleaf HTML templates (e.g., `home.html`, `list-detail.html`, `profile.html`, `admin.html`).
- `backend/src/main/resources/static/`: Static web assets like CSS stylesheets and Javascript files.
- `backend/src/main/resources/db/`: Database migrations.

**D. Test Artifacts (None for now)**
- (None for now)

#### 4.1.4. Architecture & Relationships
The logical architecture uses Docker Compose to orchestrate multiple containers. The `docker-compose.yml` file defines the interaction between the Spring Boot application (built via `backend/Dockerfile`) and the MySQL database. Nginx (when configured) acts as a reverse proxy routing incoming traffic to the Spring Boot backend. The backend serves Thymeleaf templates as the frontend, using REST APIs and services to interact with the persistent MySQL layer.

#### 4.1.5. Technical Requirements
- **Java Development Kit (JDK):** Version 17 or higher
- **Containerization:** Docker Desktop or Docker Engine + Docker Compose
- **Build Tool:** Maven
- **Database:** MySQL 8+ (provided via Docker Compose)

#### 4.1.6. MVP Feature Coverage
- User authentication via OAuth 2.0 (Google/GitHub).
- Curated list creation, editing, and publishing (FR1).
- Item management with URLs and metadata (FR2).
- Category-based discovery and searching (FR3).
- Social interactions: following users, liking, commenting, and saving lists (FR4).
- Reporting and basic admin moderation panel (FR5).
- Notifications and Creator Analytics dashboards (Pending/FR6, FR7).

### 4.2 Tests

**4.2.1 Requirements Tests**
- Functional: one test per FR (FR1–FR7) — mix of manual test-case scenarios and automated (JUnit/Spring Boot Test)
- Non-functional: one test per NF (NF1–NF8) — Lighthouse for performance, UptimeRobot for reliability, SSL Labs for HTTPS, manual GDPR checklist, usability session for NF5, browser matrix for NF6, OAuth flow for NF7, profile inspection for NF8

**4.2.2 Remaining Tests**
- Unit tests: service layer (e.g., ListService, UserService)
- Integration tests: REST API endpoints with MockMvc
- Any E2E tests if time permits (Selenium or Playwright)

---

## 14. Implementation Checklist (for building the actual app)

Use this as a build order guide:

- [ ] **Repo & Docker setup** — `docker-compose.yml` with Spring Boot + MySQL + Nginx services
- [ ] **DB schema** — Flyway or Liquibase migrations for all tables
- [ ] **Spring Security + OAuth2** — Google & GitHub login (NF7, FR1-auth)
- [ ] **User entity & profile API** — GET/PUT /users/{id} (NF8)
- [ ] **List CRUD API** — POST/GET/PUT/DELETE /lists (FR1)
- [ ] **Item CRUD API** — POST/GET/PUT/DELETE /lists/{id}/items with reorder (FR2)
- [ ] **Category API** — seed categories, GET /categories
- [ ] **Feed & Search API** — GET /feed, GET /search?q=&category= (FR3)
- [ ] **Social APIs** — follow, like, comment, save (FR4)
- [ ] **Report & Admin API** — submit report, review queue, delete content (FR5)
- [ ] **Notification system** — in-app + email (FR6, Should)
- [ ] **Creator analytics** — views/saves/likes aggregation (FR7, Should)
- [ ] **Thymeleaf frontend** — all pages listed in section 12 (S3.4)
- [ ] **Open Graph enrichment** — on item URL submit (UC5)
- [ ] **GDPR endpoints** — data export, account deletion (NF4)
- [ ] **CI/CD** — GitHub Actions pipeline
- [ ] **Nginx config** — reverse proxy + HTTPS (NF3)
- [ ] **Lighthouse audit** — verify NF1
- [ ] **UptimeRobot setup** — verify NF2
- [ ] **SSL Labs test** — verify NF3 grade A or higher
- [ ] **Browser matrix test** — verify NF6
- [ ] **5-user usability session** — verify NF5