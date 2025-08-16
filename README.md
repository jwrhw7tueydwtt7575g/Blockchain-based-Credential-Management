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
