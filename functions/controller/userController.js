const { admin } = require('../config/firebase');

// 사용자 정보 조회
async function getUserProfile(data) {
  const { uid } = data;
  const doc = await admin.firestore().collection('users').doc(uid).get();
  if (!doc.exists) throw new Error('User not found');
  return doc.data();
}

// 사용자 정보 수정
async function updateUserProfile(data) {
  const { uid, ...updateData } = data;
  await admin.firestore().collection('users').doc(uid).update({
    ...updateData,
    updated_at: new Date().toISOString()
  });
  return { success: true };
}

module.exports = { getUserProfile, updateUserProfile };
