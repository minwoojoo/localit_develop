const {db} = require("../config/firebase");

async function createTravelerIntro(data) {
  const ref = await db.collection("traveler_intros").add(data);
  return ref.id;
}

module.exports = {createTravelerIntro};
