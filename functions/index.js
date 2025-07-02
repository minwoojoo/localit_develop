/**
 * Import function triggers from their respective submodules:
 *
 * const {onCall} = require("firebase-functions/v2/https");
 * const {onDocumentWritten} = require("firebase-functions/v2/firestore");
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

const {onRequest} = require("firebase-functions/v2/https");
const logger = require("firebase-functions/logger");
const authController = require("./controller/authController");
const matchingController = require("./controller/matchingController");
const chatController = require("./controller/chatController");
const introController = require("./controller/introController");
const userController = require("./controller/userController");

// Create and deploy your first functions
// https://firebase.google.com/docs/functions/get-started

// exports.helloWorld = onRequest((request, response) => {
//   logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });

// 예시: registerUser를 onRequest로 export
exports.registerUser = onRequest(authController.registerUser);

// 매칭 요청
exports.requestMatching = onRequest(matchingController.requestMatching);

// 매칭 수락
exports.acceptMatching = onRequest(matchingController.acceptMatching);

// 채팅 메시지 전송
exports.postMessage = onRequest(chatController.postMessage);

// 여행객 소개글 등록
exports.postTravelerIntro = onRequest(introController.postTravelerIntro);

// 사용자 정보 조회
exports.getUserProfile = onRequest(async (req, res) => {
  try {
    const result = await userController.getUserProfile(req.body);
    res.status(200).json(result);
  } catch (e) {
    res.status(404).json({ error: e.message });
  }
});

// 사용자 정보 수정
exports.updateUserProfile = onRequest(async (req, res) => {
  try {
    const result = await userController.updateUserProfile(req.body);
    res.status(200).json(result);
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});
