const aws = require('aws-sdk')
const { marshallItem } = require('@aws/dynamodb-data-marshaller')
const qs = require('querystring')
const uuid = require('uuid')

async function storeToDynamoDb (payload) {
  const dynamodb = new aws.DynamoDB()
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
  aws.config.update({ region: process.env.REGION })
  const body = qs.parse(event.body) // We are interested in From, Body

  const payload = {
    Message: JSON.stringify({ from: body.From, text: body.Body }),
    TopicArn: process.env.SNS_TOPIC
  }

  let result
  try {
    // could be split into multiple separate function but given how little code it is
    const dbPayload = {
      userNumber: body.From,
      type: 'received',
      text: body.Body
    }
    const resultId = await storeToDynamoDb(dbPayload)
    console.log(dbPayload, resultId, 'successfully stored to dynamodb')

    result = await new aws.SNS({ apiVersion: '2010-03-31' }).publish(payload).promise()
    const message = 'Topic succesfully published'
    console.log(result, message)
    return {
      statusCode: 200,
      body: JSON.stringify({
        message,
        input: event,
        result
      })
    }
  } catch (err) {
    // we could also throw directly but its better to handle it ourselves
    const message = 'Topic publishing failed'
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
