
**🧩 Project Proposal: Zplit**
*An Open-Source Decentralized Payment Splitting App*

### **1️⃣ Overview**

**Zplit** is an open-source mobile application designed to simplify group expense management through a **decentralized architecture**.

Zplit's Core Features are — **expense tracking**, **group management**, and **debt calculation** — while prioritizing **user data privacy**, **offline functionality**, and **peer-to-peer synchronization**.

Unlike legacy expense-sharing apps (like Splitwise and Splitpro) that rely on centralized servers, Zplit employs decentralized communication methods including **WiFi Direct**, **Bluetooth**, **NFC**, and **QR/Deep Link-based sharing**.

This ensures that users can manage and synchronize expenses **without internet** or reliance on cloud-based services.

---

### **Objectives**

*  Create a **privacy-focused, open-source** alternative to Splitwise.
*  Enable **offline-first functionality** through peer-to-peer synchronization.
*  Integrate **on-device OCR** for receipt recognition.
*  Provide users with **intuitive expense visualizations and analytics**.
*  Future plans to add **Web3 stablecoin integration** for decentralized settlements.

---

### **Core Features (Phase 1)**

#### **a. User & Group Management**

* Create and join groups for managing shared expenses (e.g., trips, events, roommates).
* Manage user profiles locally on-device.
* Invite users to groups via:

  *  WiFi Direct / Bluetooth pairing
  *  QR Codes and Deep Links
  *  NFC Taps (for proximity-based sharing)

#### **b. Expense Tracking**

* Add, edit, and delete expenses with:

  * Amount
  * Description
  * Payer and participants
  * Split methods (equal, custom, percentage)
* Filter and sort expenses by:

  * Date
  * Category
  * Amount
  * Member

#### **c. Receipts & OCR**

* Attach images of receipts to expenses.
* Run an **on-device OCR model** to auto-detect:

  * Merchant name
  * Amount
  * Date
* Utilize a **lightweight image recognition model** optimized for on-edge performance.

#### **d. Data Visualization**

* Expense summaries, category breakdowns, and debt balances.
* Visualize data using **fl_chart** graphs and charts (pie, bar, and line formats).

#### **e. Local Storage**

* All data stored locally using **secure Flutter storage** (e.g., Hive or Drift).
* Optional **encrypted backup/export** feature via QR or shareable links.

---

### **Decentralized Data Transfer Methods**

Zplit eliminates the need for central servers through **direct, encrypted device-to-device synchronization channels.**

```
WiFi Direct     | High-speed sync for large data           
Bluetooth       | Short-range sync and quick updates        
NFC             | Tap-to-share group invites or expenses    
QR / Deep Links | Cross-device sharing (link-based)
```

Each synchronization method uses a **lightweight, encrypted protocol** for secure data exchange.

---

### **Technology Stack**

```
Layer                  | Technology
---------------------------------------------------------------
Frontend               | Flutter (Android, iOS, Web)
State Management       | Riverpod
Storage                | Hive / Drift
P2P Communication      | WiFi Direct, Bluetooth, NFC plugins
Visualization          | fl_chart
OCR Model              | ML Kit (TensorFlow Lite)
Deeplinking            | Flutter native
```

---

### **Architecture**

#### **Phase 1: Local-First**

* All user and group data stored locally.
* Sync across users through P2P transfer methods.
* Offline by default; internet only for optional backups.

#### **Phase 2: Decentralized Sync Layer**

* Add background syncing between trusted devices.
* Support multi-hop sharing (data relayed across devices).

#### **Phase 3: Web3 Integration**

* Introduce **stablecoin payments (USDC/DAI)** via non-custodial wallets.
* Allow users to **settle balances using crypto**, securely and transparently.
* Maintain compatibility with offline features.

---

### **Future Enhancements**

* **End-to-End Encrypted Cloud Sync** (optional backups & restoration).
* **Decentralized Identity (DID)** for Web3 logins.
* **Smart Contract-based settlements** for automated crypto payments.
* **Flutter Web App** for cross-platform support.
*  **Local mesh network synchronization** for multi-device sync.

