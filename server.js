import express from "express";
import fetch from "node-fetch";
import { MongoClient } from "mongodb";
import path from "path";
import { fileURLToPath } from "url";

const app = express();
const PORT = 5000;

// Fix for __dirname in ES module
const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

// MongoDB connection
const MONGO_URI = "mongodb+srv://vivekchaudhari3718:vivekchaudhari3718@cluster1.9qlun5j.mongodb.net/";
const client = new MongoClient(MONGO_URI);
let collection;

const account = "0xdc85284115cd06f683956a36bee54bf70144eb2d5f9497cbced98bd01c389178";
const baseUrl = "https://fullnode.devnet.aptoslabs.com/v1";

async function connectDB() {
  await client.connect();
  const db = client.db("aptos");
  collection = db.collection("blockchain");
  console.log("✅ Connected to MongoDB");
}

// Fetch Aptos resources
async function fetchResources() {
  try {
    const res = await fetch(`${baseUrl}/accounts/${account}/resources`);
    return await res.json();
  } catch (err) {
    console.error("❌ Error fetching resources:", err);
    return [];
  }
}

// Sync blockchain → Mongo
async function syncBlockchain() {
  const resources = await fetchResources();

  for (let resource of resources) {
    await collection.updateOne(
      { type: resource.type },
      { $set: { type: resource.type, data: resource.data } },
      { upsert: true }
    );
  }

  console.log("🔄 Blockchain data synced to MongoDB");
}

// API route for frontend
app.get("/api/data", async (req, res) => {
  try {
    const docs = await collection.find().toArray();
    res.json(docs);
  } catch (err) {
    res.status(500).json({ error: "Failed to fetch data" });
  }
});

// Serve dashboard.html
app.use(express.static(path.join(__dirname, "public")));

app.get("/", (req, res) => {
  res.sendFile(path.join(__dirname, "public", "dashboard.html"));
});

app.listen(PORT, async () => {
  await connectDB();
  await syncBlockchain(); // initial sync
  setInterval(syncBlockchain, 60000); // sync every 1 min
  console.log(`🚀 Server running at http://localhost:${PORT}`);
});
