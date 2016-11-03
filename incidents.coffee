# Description:
#   Interact with VictorOps incidents
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   !ack [<message>] #[i|incident]<incNum> - acknowledge <incNum>, including optional <message>
#   !resolve [<message>] #[i|incident]<incNum> - resolve <incNum>, including optional <message>

apiauth =
  'X-VO-Api-Id': process.env.HUBOT_VICTOROPS_API_ID
  'X-VO-Api-Key': process.env.HUBOT_VICTOROPS_API_KEY

module.exports = (robot) ->
  robot.hear /!ack (.*?)#(i|incident)?([0-9]+)/i, (msg) ->
    ackMsg = msg.match[1]
    ackMsg = "Acked via Hubot" if ackMsg == ""
    data = JSON.stringify {
      userName: msg.envelope.user.id
      incidentNames: [
        msg.match[3]
      ]
      message: ackMsg
    }
    @robot.logger.info "Found ack request from #{data.userName} for incident #{msg.match[3]} with message '#{ackMsg}'"

    robot
      .http("https://api.victorops.com/api-public/v1/incidents/ack")
      .headers(apiauth)
      .header('Content-Type', 'application/json')
      .patch(data) (err, res, body) ->
        msg.reply "#{body}"

  robot.hear /^!resolve (.*?)#(i|incident)?([0-9]+)/i, (msg) ->
    ackMsg = msg.match[1]
    ackMsg = "Resolved via Hubot" if ackMsg == ""
    data = JSON.stringify {
      userName: msg.envelope.user.id
      incidentNames: [
        msg.match[3]
      ]
      message: ackMsg
    }
    @robot.logger.info "Found resolve request from #{data.userName} for incident #{msg.match[3]} with message '#{ackMsg}'"

    robot
      .http("https://api.victorops.com/api-public/v1/incidents/resolve")
      .headers(apiauth)
      .header('Content-Type', 'application/json')
      .patch(data) (err, res, body) ->
        msg.reply "#{body}"
