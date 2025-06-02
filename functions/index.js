/**
 * Import function triggers from their respective submodules:
 *
 * const {onCall} = require("firebase-functions/v2/https");
 * const {onDocumentWritten} = require("firebase-functions/v2/firestore");
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

const { onRequest, onCall } = require("firebase-functions/v2/https");
const { beforeUserCreated } = require("firebase-functions/v2/identity");
const express = require('express');
const app = express();
app.use(express.json());

const { registerUser, onUserCreate } = require('./controller/authController');
const { requestMatching, acceptMatching } = require('./controller/matchingController');
const { postMessage } = require('./controller/chatController');
const { postTravelerIntro } = require('./controller/introController');
const { getUserProfile, updateUserProfile } = require('./controller/userController');
const { admin } = require('./config/firebase');

// Auth 트리거
exports.onUserCreate = beforeUserCreated({
  region: 'asia-northeast3'
}, onUserCreate);

// Callable Functions (v2)
exports.registerUser = onCall({
  cors: true,
  region: 'asia-northeast3'
}, async (request) => {
  return await registerUser(request.data, { json: (data) => data });
});

exports.requestMatching = onCall({
  cors: true,
  region: 'asia-northeast3'
}, async (request) => {
  return await requestMatching(request.data, { json: (data) => data });
});

exports.acceptMatching = onCall({
  cors: true,
  region: 'asia-northeast3'
}, async (request) => {
  return await acceptMatching(request.data, { json: (data) => data });
});

exports.postMessage = onCall({
  cors: true,
  region: 'asia-northeast3'
}, async (request) => {
  return await postMessage(request.data, { json: (data) => data });
});

exports.postTravelerIntro = onCall({
  cors: true,
  region: 'asia-northeast3'
}, async (request) => {
  return await postTravelerIntro(request.data, { json: (data) => data });
});

exports.getUserProfile = onCall({
  cors: true,
  region: 'asia-northeast3'
}, async (request) => {
  return await getUserProfile(request.data, { json: (data) => data });
});

exports.updateUserProfile = onCall({
  cors: true,
  region: 'asia-northeast3'
}, async (request) => {
  return await updateUserProfile(request.data, { json: (data) => data });
});