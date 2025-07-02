const {admin} = require("../config/firebase");

// 사용자 정보 조회
async function getUserProfile(req, res) {
  try {
    console.log('getUserProfile req.body:', req.body);
    console.log('getUserProfile req.body.data:', req.body.data);
    const {uid} = req.body.data;
    const doc = await admin.firestore().collection("users").doc(uid).get();
    if (!doc.exists) throw new Error("User not found");
    res.status(200).json(doc.data());
  } catch (e) {
    res.status(404).json({ error: e.message });
  }
}

// 사용자 정보 수정
async function updateUserProfile(req, res) {
  try {
    console.log('updateUserProfile req.body:', req.body);
    console.log('updateUserProfile req.body.data:', req.body.data);
    const {uid, ...updateData} = req.body.data;
    await admin.firestore().collection("users").doc(uid).update({
      ...updateData,
      updated_at: new Date().toISOString(),
    });
    res.status(200).json({success: true});
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
}

module.exports = {getUserProfile, updateUserProfile};
