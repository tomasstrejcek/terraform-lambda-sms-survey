/* eslint-env node, mocha, describe, before, it */

const assert = require('assert')

const index = require('../index')

describe('on invocation', () => {
  it('should publish text to fb post', async () => {
    process.env.PAGE_ID = ''
    process.env.ACCESS_TOKEN = ''
    const response = await index.handler({
      Records: [{
        Sns: {
          Message: JSON.stringify({
            from: 'me',
            text: 'Ahoj!'
          })
        }
      }]
    })
    console.log(response)
    assert(response.body)
  })
})
