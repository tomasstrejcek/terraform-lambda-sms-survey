const superagent = require('superagent')

// if there would be more complex interactions with facebook I would consider using library,
// but for single post this should sufficient
async function publish (text) {
  if (!text) {
    throw new ReferenceError('text is missing')
  }
  const fbUrl = `https://graph.facebook.com/${process.env.PAGE_ID}/feed`
  const params = {
    access_token: process.env.ACCESS_TOKEN, // use extended page access token without expiration
    message: text,
    published: false // needs to be reviewed before making public
  }
  const result = await superagent
    .post(fbUrl)
    .send(params)
  return JSON.parse(result.text)
}

module.exports.handler = async (event, context) => {
  const incoming = JSON.parse(event.Records[0].Sns.Message)
  try {
    const result = await publish('User replied with:' + incoming.text)
    const message = 'Post published'
    console.log(result, incoming, message)
    return {
      statusCode: 200,
      body: JSON.stringify({
        message,
        input: event,
        result
      })
    }
  } catch (err) {
    const message = 'Publishing of post failed'
    console.log(err, message)
    return {
      statusCode: 500,
      body: JSON.stringify({
        message,
        input: event
      })
    }
  }
}
