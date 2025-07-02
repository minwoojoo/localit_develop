const {db} = require("../config/firebase");

async function createChatRoom(travelerId, localId) {
  const ref = await db.collection("chat_rooms").add({
    traveler_id: travelerId,
    local_id: localId,
    created_at: new Date(),
  });
  return ref.id;
}

async function sendMessage(chatRoomId, senderId, message) {
  await db.collection("chat_messages").add({
    chat_room_id: chatRoomId,
    sender_id: senderId,
    message,
    created_at: new Date(),
  });
}

module.exports = {createChatRoom, sendMessage};
