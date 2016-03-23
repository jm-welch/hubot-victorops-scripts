# Description:
#   Swap on-call between users
#
# Dependencies:
#   None
#
# Configuration:
#   HUBOT_VICTOROPS_API_ID = API ID
#   HUBOT_VICTOROPS_API_KEY = API Key
#
# Commands:
#   hubot swap <team> from <fromUser> to <toUser> - Replace <fromUser> with <toUser> on <team> until next on-call change

apiauth =
  'X-VO-Api-Id': process.env.HUBOT_VICTOROPS_API_ID
  'X-VO-Api-Key': process.env.HUBOT_VICTOROPS_API_KEY

module.exports = (robot) ->
  robot.respond /swap ([^ ]+) from ([^ ]+) to ([^ ]+)/i, (msg) ->
    team = msg.match[1]
    data = JSON.stringify({
      fromUser: msg.match[2],
      toUser: msg.match[3]
    })
    @robot.logger.info "Swap request received. Team: #{team}. \n #{data}"

    robot
      .http("https://api.victorops.com/api-public/v1/team/#{team}/oncall/user")
      .headers(apiauth)
      .header('Content-Type', 'application/json')
      .patch(data) (err, res, body) ->
        msg.reply "#{body}"
