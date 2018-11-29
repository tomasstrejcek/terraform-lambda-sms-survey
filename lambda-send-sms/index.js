const Twilio = require('twilio')
const aws = require('aws-sdk')
const uuid = require('uuid')
const { marshallItem } = require('@aws/dynamodb-data-marshaller')

async function storeToDynamoDb (payload) {
  const dynamodb = new aws.DynamoDB({ region: process.env.REGION })
  const id = uuid.v4()
  const record = {
    id,
    ...payload,
    created: new Date()
  }

  await dynamodb.putItem({
    Item: marshallItem(require('./schema'), record),
    TableName: process.env.DYNAMO_TABLE
  }).promise()

  return id
}

module.exports.handler = async (event, context) => {
  // if (!body.to) { return } + phone number validation
  try {
    const body = event.body && JSON.parse(event.body)
    const client = new Twilio(process.env.ACCOUNT_SID, process.env.AUTH_TOKEN)

    const userMessage = 'Do you like bread?'
    const result = await client.messages.create({
      body: userMessage, // probably fetched from somewhere?
      to: body.to,
      from: process.env.PHONE_NUMBER
    })

    const message = 'SMS sent'
    console.log(result, message)

    const dbPayload = {
      userNumber: body.to,
      type: 'sent',
      text: userMessage
    }
    const resultId = await storeToDynamoDb(dbPayload)
    console.log(dbPayload, resultId, 'successfully stored to dynamodb')

    return {
      statusCode: 200,
      body: JSON.stringify({
        message,
        input: event,
        result
      })
    }
  } catch (err) {
    const message = 'SMS failed'
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
