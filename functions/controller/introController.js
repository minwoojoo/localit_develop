const {createTravelerIntro} = require("../domain/intro");

// 여행객 소개글 등록
async function postTravelerIntro(req, res) {
  console.log('postTravelerIntro req.body:', req.body);
  console.log('postTravelerIntro req.body.data:', req.body.data);
  const {traveler_id, title, content, location, preferred_meetup, travel_theme} = req.body.data;
  const introId = await createTravelerIntro({
    traveler_id, title, content, location, preferred_meetup, travel_theme,
    created_at: new Date(),
    updated_at: new Date(),
  });
  res.status(201).send({introId});
}

module.exports = {postTravelerIntro};
