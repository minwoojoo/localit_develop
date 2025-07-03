const {db} = require("../config/firebase");

async function createUser(uid, data) {
  if (!uid) throw new Error("uid is required");
  await db.collection("users").doc(uid).set(data);
}

async function createTraveler(uid, data) {
  await db.collection("travelers").doc(uid).set(data);
}

async function createLocal(uid, data) {
  await db.collection("locals").doc(uid).set(data);
}

module.exports = {createUser, createTraveler, createLocal};
