const { createTravelerIntro } = require('../domain/intro');

// 여행객 소개글 등록
async function postTravelerIntro(req, res) {
  const { traveler_id, title, content, location, preferred_meetup, travel_theme } = req.body;
  const introId = await createTravelerIntro({
    traveler_id, title, content, location, preferred_meetup, travel_theme,
    created_at: new Date(),
    updated_at: new Date()
  });
  res.status(201).send({ introId });
}

module.exports = { postTravelerIntro };
