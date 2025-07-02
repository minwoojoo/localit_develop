const {createUser, createTraveler, createLocal} = require("../domain/user");
const {admin} = require("../config/firebase");
const User = require("../entity/user");

// 회원가입
async function registerUser(data) {
  const {uid, email, nickname, type, ...rest} = data;
  await createUser(uid, {
    email, nickname, type,
    created_at: new Date(),
    updated_at: new Date(),
  });
  if (type === "traveler") {
    await createTraveler(uid, {...rest, created_at: new Date(), updated_at: new Date()});
  } else if (type === "local") {
    await createLocal(uid, {...rest, created_at: new Date(), updated_at: new Date()});
  }
  return {success: true};
}

// 회원가입 후 Firestore에 사용자 프로필 자동 생성 (Auth 트리거)
async function onUserCreate(event) {
  const user = event.data;
  const userData = {
    email: user.email,
    nickname: user.displayName || "",
    phone_number: user.phoneNumber || "",
    type: "traveler", // 기본값, 프론트에서 선택 가능
    profileImageUrl: user.photoURL || "",
    languages: [],
    trust_score: 100,
    created_at: new Date().toISOString(),
    updated_at: new Date().toISOString(),
  };
  await admin.firestore().collection("users").doc(user.uid).set(userData);
}

// (선택) 회원가입 API (프론트에서 직접 호출 시)
exports.registerUser = async (req, res) => {
  try {
    console.log('registerUser req.body:', req.body);
    console.log('registerUser req.body.data:', req.body.data);
    const { uid, email, nickname, phone_number, type, profileImageUrl, languages } = req.body.data;
    const userData = {
      email,
      nickname,
      phone_number,
      type,
      profileImageUrl,
      languages,
      trust_score: 100,
      created_at: new Date().toISOString(),
      updated_at: new Date().toISOString(),
    };
    await admin.firestore().collection("users").doc(uid).set(userData);
    res.status(201).json({success: true});
  } catch (e) {
    console.error('registerUser error:', e);
    res.status(500).json({error: e.message});
  }
};

module.exports = {registerUser, onUserCreate};
