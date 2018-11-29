/* eslint-env node, mocha, describe, before, it */

const assert = require('assert')

const index = require('../index')

describe('sms receive lambda', () => {
  it('should encode event and publish sns topic', async () => {
    process.env.REGION = 'test'
    const response = await index.handler({
      'resource': '/sms-receive',
      'path': '/sms-receive',
      'httpMethod': 'POST',
      'headers': {
        'Accept': '*/*',
        'Cache-Control': 'max-age=259200',
        'CloudFront-Forwarded-Proto': 'https',
        'CloudFront-Is-Desktop-Viewer': 'true',
        'CloudFront-Is-Mobile-Viewer': 'false',
        'CloudFront-Is-SmartTV-Viewer': 'false',
        'CloudFront-Is-Tablet-Viewer': 'false',
        'CloudFront-Viewer-Country': 'US',
        'Content-Type': 'application/x-www-form-urlencoded; charset=utf-8',
        'Host': 'spvm3lo98b.execute-api.ap-southeast-1.amazonaws.com',
        'User-Agent': 'TwilioProxy/1.1',
        'Via': '1.1 6d27d721f415e98f0e191dfd2a249564.cloudfront.net (CloudFront)',
        'X-Amz-Cf-Id': 'XlOxxUHGMazCz7JC5cW9cXhwk5OkfAWI3HBYR9w0v4H7uLVfDWymCw==',
        'X-Amzn-Trace-Id': 'Root=1-5be9a18a-523d202c92ad094eb96b91f8',
        'X-Forwarded-For': '18.234.53.237, 52.46.14.42',
        'X-Forwarded-Port': '443',
        'X-Forwarded-Proto': 'https',
        'X-Twilio-Signature': 'UFKBjYHEewsT0bXxYPMUWyAZi7Q='
      },
      'multiValueHeaders': {
        'Accept': [
          '*/*'
        ],
        'Cache-Control': [
          'max-age=259200'
        ],
        'CloudFront-Forwarded-Proto': [
          'https'
        ],
        'CloudFront-Is-Desktop-Viewer': [
          'true'
        ],
        'CloudFront-Is-Mobile-Viewer': [
          'false'
        ],
        'CloudFront-Is-SmartTV-Viewer': [
          'false'
        ],
        'CloudFront-Is-Tablet-Viewer': [
          'false'
        ],
        'CloudFront-Viewer-Country': [
          'US'
        ],
        'Content-Type': [
          'application/x-www-form-urlencoded; charset=utf-8'
        ],
        'Host': [
          'spvm3lo98b.execute-api.ap-southeast-1.amazonaws.com'
        ],
        'User-Agent': [
          'TwilioProxy/1.1'
        ],
        'Via': [
          '1.1 6d27d721f415e98f0e191dfd2a249564.cloudfront.net (CloudFront)'
        ],
        'X-Amz-Cf-Id': [
          'XlOxxUHGMazCz7JC5cW9cXhwk5OkfAWI3HBYR9w0v4H7uLVfDWymCw=='
        ],
        'X-Amzn-Trace-Id': [
          'Root=1-5be9a18a-523d202c92ad094eb96b91f8'
        ],
        'X-Forwarded-For': [
          '18.234.53.237, 52.46.14.42'
        ],
        'X-Forwarded-Port': [
          '443'
        ],
        'X-Forwarded-Proto': [
          'https'
        ],
        'X-Twilio-Signature': [
          'UFKBjYHEewsT0bXxYPMUWyAZi7Q='
        ]
      },
      'queryStringParameters': null,
      'multiValueQueryStringParameters': null,
      'pathParameters': null,
      'stageVariables': null,
      'requestContext': {
        'resourceId': 'wu4oro',
        'resourcePath': '/sms-receive',
        'httpMethod': 'POST',
        'extendedRequestId': 'QQYtnEF5SQ0Ffug=',
        'requestTime': '12/Nov/2018:15:51:38 +0000',
        'path': '/development/sms-receive',
        'accountId': '142920961168',
        'protocol': 'HTTP/1.1',
        'stage': 'development',
        'domainPrefix': 'spvm3lo98b',
        'requestTimeEpoch': 1542037898339,
        'requestId': 'd71c7440-e692-11e8-af85-bbd55eb79726',
        'identity': {
          'cognitoIdentityPoolId': null,
          'accountId': null,
          'cognitoIdentityId': null,
          'caller': null,
          'sourceIp': '18.234.53.237',
          'accessKey': null,
          'cognitoAuthenticationType': null,
          'cognitoAuthenticationProvider': null,
          'userArn': null,
          'userAgent': 'TwilioProxy/1.1',
          'user': null
        },
        'domainName': 'spvm3lo98b.execute-api.ap-southeast-1.amazonaws.com',
        'apiId': 'spvm3lo98b'
      },
      'body': 'ApiVersion=2010-04-01&SmsSid=SMa37d34e8efc089b760707e36fe9220ea&SmsStatus=received&SmsMessageSid=SMa37d34e8efc089b760707e36fe9220ea&NumSegments=1&From=%2B420723138687&ToState=CA&MessageSid=SMa37d34e8efc089b760707e36fe9220ea&AccountSid=ACc9b48b7e186cdf17aa947327fc888d74&FromCountry=CZ&ToCity=SAN%20JOSE&ToZip=95112&FromCity=&To=%2B14089165811&FromZip=&Body=Yo%21&ToCountry=US&FromState=&NumMedia=0',
      'isBase64Encoded': false

    }, {})
    console.log(response)
    assert(response.body)
  })
})
