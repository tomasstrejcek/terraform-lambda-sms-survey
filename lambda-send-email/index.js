const aws = require('aws-sdk')

module.exports.handler = async (event, context) => {
  const incoming = JSON.decode(event.Records[0].Sns.Message)

  aws.config.update({ region: process.env.REGION })

  // this could be nicely handled from terraform using ses email templates
  const params = {
    Destination: {
      ToAddresses: [
        'destination email address' // no idea what that is :) if sender or responder
      ]
    },
    Message: {
      Body: {
        Text: {
          Charset: 'UTF-8',
          Data: 'Thank you for your survey response! ' + event.Records[0].Sns.Message
        }
      },
      Subject: {
        Charset: 'UTF-8',
        Data: 'Survey - test email'
      }
    },
    Source: process.env.EMAIL_SENDER,
    ReplyToAddresses: [
      process.env.EMAIL_SENDER
    ]
  }

  try {
    const result = await new aws.SES({ apiVersion: '2010-12-01' }).sendEmail(params).promise()
    const message = 'Email sent'
    console.log(incoming, result, params, message)
    return {
      statusCode: 200,
      body: JSON.stringify({
        message,
        input: event,
        result
      })
    }
  } catch (err) {
    const message = 'Email failed (probably not verified email address)'
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
