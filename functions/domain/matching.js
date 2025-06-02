const { db } = require('../config/firebase');

async function createMatching(data) {
  const ref = await db.collection('matchings').add(data);
  return ref.id;
}

async function updateMatchingStatus(matchingId, status) {
  await db.collection('matchings').doc(matchingId).update({
    status,
    updated_at: new Date()
  });
}

module.exports = { createMatching, updateMatchingStatus };