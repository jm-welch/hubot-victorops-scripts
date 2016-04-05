# Description:
#   Swap on-call between users
#
# Dependencies:
#   hubot-auth
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

# Add other roles here
authorizedRoles = [
  'admin'
]

module.exports = (robot) ->
  robot.respond /swap ([^ ]+) from ([^ ]+) to ([^ ]+)/i, (msg) ->
    team = msg.match[1]
    data = JSON.stringify({
      fromUser: msg.match[2],
      toUser: msg.match[3]
    })
    @robot.logger.info "Swap request for #{team} received from #{msg.envelope.user.id}: #{data}"
    roleMatch = (r for r in robot.auth.userRoles(msg.envelope.user) when r in authorizedRoles)
    if roleMatch.length > 0
      @robot.logger.info "#{msg.envelope.user.id} matches #{roleMatch} roles. Swap approved."
      robot
        .http("https://api.victorops.com/api-public/v1/team/#{team}/oncall/user")
        .headers(apiauth)
        .header('Content-Type', 'application/json')
        .patch(data) (err, res, body) ->
          msg.reply "#{body}"
    else
      @robot.logger.warn "#{msg.envelope.user.id} not in any required roles. Swap declined."
      msg.reply "Only members of #{JSON.stringify(authorizedRoles)} can use this feature."
