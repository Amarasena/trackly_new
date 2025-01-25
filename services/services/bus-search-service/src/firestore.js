const admin = require("firebase-admin");
const dotenv = require("dotenv");
dotenv.config({ path: "../.env" });

const firebaseAdminKey = JSON.parse(process.env.FIREBASE_ADMIN_KEY);


admin.initializeApp({
  credential: admin.credential.cert(firebaseAdminKey),
});

const firestore = admin.firestore();
module.exports = firestore;
