const { deadline } = require('../grpc-utils')

/**
 * Sends coins from lnd wallet to address
 *
 * @see http://api.lightning.community/#sendCoins
 * @param {string} addr
 * @param {number} amount
 * @param {Object} opts
 * @param {LndClient} opts.client
 * @returns {Object} response
 */
function sendCoins (addr, amount, { client }) {
  return new Promise((resolve, reject) => {
    client.sendCoins({ addr, amount }, { deadline: deadline() }, (err, res) => {
      if (err) return reject(err)
      return resolve(res)
    })
  })
}

module.exports = sendCoins
