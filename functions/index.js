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

// 회원가입
exports.registerUser = onRequest(authController.registerUser);
exports.checkEmailDuplicate = onRequest(authController.checkEmailDuplicate);

// 채팅 관련 (구현 필요시 아래와 같이 추가)
// exports.sendMessage = onRequest(chatController.sendMessage);

// 여행객 소개글 등록 (구현 필요시 아래와 같이 추가)
// exports.postTravelerIntro = onRequest(introController.postTravelerIntro);

// 매칭 관련 (구현 필요시 아래와 같이 추가)
// exports.requestMatching = onRequest(matchingController.requestMatching);

// 사용자 정보 조회 (구현 필요시 아래와 같이 추가)
// exports.getUserProfile = onRequest(userController.getUserProfile);

// 사용자 정보 수정
exports.updateUserProfile = onRequest(async (req, res) => {
  try {
    const result = await userController.updateUserProfile(req.body);
    res.status(200).json(result);
  } catch (e) {
    res.status(500).json({error: e.message});
  }
});
