const {db} = require("../config/firebase");

// CORS 설정 함수
const setCorsHeaders = (res) => {
  res.set("Access-Control-Allow-Origin", "*");
  res.set("Access-Control-Allow-Methods", "GET, POST, OPTIONS");
  res.set("Access-Control-Allow-Headers", "Content-Type");
};

// 회원가입 API
exports.registerUser = async (req, res) => {
  // CORS preflight 요청 처리
  if (req.method === "OPTIONS") {
    setCorsHeaders(res);
    res.status(204).send("");
    return;
  }

  setCorsHeaders(res);

  try {
    let body = req.body;
    if (!body) {
      body = JSON.parse(req.rawBody.toString());
    }
    const data = body.data || body;

    const {
      uid,
      email,
      nickname,
      phone_number,
      type, // "traveler" 또는 "local"
      profileImageUrl,
      languages,
      // travelers용
      preferred_regions,
      travel_style,
      // locals용
      certified,
      age,
      gender,
      preferred_meetup,
      preferred_location,
      interests,
      hobbies,
      verification_data,
      verification_status,
    } = data;

    // users 컬렉션에 모든 정보 저장 (traveler 필드 포함)
    const userData = {
      email,
      nickname,
      phone_number,
      type,
      profileImageUrl: profileImageUrl || "",
      languages: languages || [],
      trust_score: 80,
      preferred_regions: preferred_regions || [],
      travel_style: travel_style || [],
      created_at: new Date().toISOString(),
      updated_at: new Date().toISOString(),
    };
    await db.collection("users").doc(uid).set(userData);

    // locals 컬렉션에만 추가 정보 저장
    if (type === "local") {
      const localData = {
        certified: certified || false,
        age: age || null,
        gender: gender || "",
        preferred_meetup: preferred_meetup || "",
        preferred_location: preferred_location || "",
        interests: interests || [],
        hobbies: hobbies || "",
        verification_data: verification_data || {},
        verification_status: verification_status || "pending",
        created_at: new Date().toISOString(),
        updated_at: new Date().toISOString(),
      };
      await db.collection("locals").doc(uid).set(localData);
    }

    return res.status(201).json({success: true});
  } catch (e) {
    console.error("registerUser error:", e);
    return res.status(500).json({error: e.message});
  }
};

// 이메일 중복 확인
exports.checkEmailDuplicate = async (req, res) => {
  // CORS preflight 요청 처리
  if (req.method === "OPTIONS") {
    setCorsHeaders(res);
    res.status(204).send("");
    return;
  }

  setCorsHeaders(res);

  try {
    let body = req.body;
    if (!body) {
      body = JSON.parse(req.rawBody.toString());
    }
    const {email} = body.data || body;
    if (!email) {
      return res.status(400).json({error: "이메일이 필요합니다."});
    }
    const snapshot = await db.collection("users").where("email", "==", email).get();
    if (!snapshot.empty) {
      return res.json({exists: true});
    }
    return res.json({exists: false});
  } catch (e) {
    return res.status(500).json({error: e.message});
  }
};
