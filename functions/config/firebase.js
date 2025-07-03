const admin = require("firebase-admin");
admin.initializeApp();
const db = admin.firestore();

if (process.env.FUNCTIONS_EMULATOR) {
  db.settings({
    host: "localhost:8080",
    ssl: false,
  });
}

module.exports = {admin, db};
