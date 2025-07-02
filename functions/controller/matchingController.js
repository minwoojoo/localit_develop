const {createMatching, updateMatchingStatus} = require("../domain/matching");
const {createChatRoom} = require("../domain/chat");
const {db} = require("../config/firebase");

// 매칭 요청
async function requestMatching(req, res) {
  console.log('requestMatching req.body:', req.body);
  console.log('requestMatching req.body.data:', req.body.data);
  const { requester_id, receiver_id, travel_info } = req.body.data;
  const matchingId = await createMatching({
    requester_id,
    receiver_id,
    status: "pending",
    travel_info,
    created_at: new Date(),
    updated_at: new Date(),
  });
  res.status(201).send({matchingId});
}

// 매칭 수락
async function acceptMatching(req, res) {
  const {matchingId} = req.params;
  // 1. status 변경
  await updateMatchingStatus(matchingId, "accepted");
  // 2. 채팅방 생성
  // (여기서는 matching 문서에서 requester/receiver를 읽어와야 함)
  const matchingDoc = await db.collection("matchings").doc(matchingId).get();
  const {requester_id, receiver_id} = matchingDoc.data();
  const chatRoomId = await createChatRoom(requester_id, receiver_id);
  res.status(200).send({chatRoomId});
}

module.exports = {requestMatching, acceptMatching};
