const { sendMessage } = require('../domain/chat');

// 메시지 전송
async function postMessage(req, res) {
  const { chat_room_id, sender_id, message } = req.body;
  await sendMessage(chat_room_id, sender_id, message);
  res.status(201).send({ success: true });
}

module.exports = { postMessage };
