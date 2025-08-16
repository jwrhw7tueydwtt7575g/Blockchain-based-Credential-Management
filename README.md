# 🎓 Blockchain Credential Management System (with Aptos + MongoDB + Dashboard)

## 📌 Overview
This project demonstrates how to **issue, store, and verify student credentials** using **Aptos Blockchain**.  

The goal is to ensure **credentials (like degrees, certificates, IDs)** are:
- ✅ Tamper-proof (cannot be changed once stored)
- ✅ Easily verifiable (via blockchain explorer)
- ✅ Securely stored and parsed for dashboards

We integrate:
1. **Aptos Blockchain (Move language)** → To store credentials securely on-chain.  
2. **MongoDB** → To index/store blockchain transaction metadata for quick querying.  
3. **Dashboard (Node.js/Express/React or any frontend)** → To parse and display stored credentials.

---

## 🛠 Why Blockchain?
Traditional credential systems suffer from:
- Fake degree certificates.
- Difficulty in verification across institutions.
- Centralized control (easy to manipulate).

By using **Aptos Blockchain**:
- Credentials are **immutable** once issued.
- Institutions can **issue credentials** on-chain.
- Employers/other schools can **verify authenticity** directly from blockchain.

---

## ⚡ Workflow
1. **Institution issues credential** → Runs Aptos Move command to add credential on-chain.  
2. **Blockchain transaction** → Data stored in Aptos Explorer (visible public record).  
3. **MongoDB storage** → Metadata (credential ID, student ID, IPFS hash, etc.) is pushed into MongoDB for querying.  
4. **Dashboard parsing** → Queries MongoDB and shows credentials with verification links.  

---

## 🚀 Project Structure
project_Block_Chain/
│── sources/
│ └── project.move # Move smart contract (Credential logic)
│── scripts/
│ └── deploy.ps1 # PowerShell helper scripts
│── index.js # Node.js API (connects Aptos + MongoDB)
│── frontend/ # Dashboard UI (React/Express/any)
│── README.md # Project documentation


---

## 🔑 Prerequisites
- [Install Aptos CLI](https://aptos.dev/tools/aptos-cli/install-cli/)  
- [Install Rust](https://www.rust-lang.org/tools/install)  
- [Install MongoDB](https://www.mongodb.com/try/download/community)  
- Node.js (for API + frontend)

---

## 🏗 Setup

### 1️⃣ Configure Aptos
```bash
aptos init --profile student-id
Set devnet as network.

This generates ~/.aptos/config.yaml with your account details.

2️⃣ Publish Smart Contract
aptos move publish --profile student-id


This deploys your project.move to Aptos Blockchain.
You’ll see a link like:

Transaction submitted: https://explorer.aptoslabs.com/txn/0xHASH?network=devnet

3️⃣ Issue Dummy Credential

Example inline command:

aptos move run --function-id 0x<ACCOUNT_ADDRESS>::CredentialSchema::add_schema --args string:"Bachelor of Engineering" string:"2025" string:"ipfs://QmDummySchemaHash" --profile student-id


This adds a schema for credentials (like degree template).

Now issue a student credential:

aptos move run --function-id 0x<ACCOUNT_ADDRESS>::Credential::issue_credential --args address:0x1234567890abcdef string:"ipfs://QmDummyStudentDegree" --profile student-id


✔️ The credential is now on Aptos Blockchain!
Check transaction in explorer:
https://explorer.aptoslabs.com/transactions?network=devnet&type=user

4️⃣ Store in MongoDB

Once transaction is successful, push metadata into MongoDB:

{
  "student_id": "123456",
  "credential": "Bachelor of Engineering",
  "year": "2025",
  "ipfs_hash": "ipfs://QmDummyStudentDegree",
  "txn_hash": "0xABCDEF123456",
  "verified_link": "https://explorer.aptoslabs.com/txn/0xABCDEF123456?network=devnet"
}

5️⃣ Parse & Show on Dashboard

Your dashboard (React/Express or any stack) fetches from MongoDB and shows:

✅ Student ID

✅ Credential Type

✅ IPFS Hash (clickable for full metadata)

✅ Blockchain Verification Link

