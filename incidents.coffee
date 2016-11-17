# Description:
#   Interact with VictorOps incidents
#
# Dependencies:
#   None
#
# Configuration:
#   HUBOT_VICTOROPS_API_ID = API ID
#   HUBOT_VICTOROPS_API_KEY = API Key
#   HUBOT_VICTOROPS_REST_API_KEY = REST API Key
#
# Commands:
#   !ack [<message>] #[i|incident]<incNum> - acknowledge <incNum>, including optional <message>
#   !resolve [<message>] #[i|incident]<incNum> - resolve <incNum>, including optional <message>
#   !warning <routing_key> <subject> - create a WARNING incident, routed to <routing_key>
#   !critical <routing_key> <subject> - create a CRITICAL incident, routed to <routing_key>

apiauth =
  'X-VO-Api-Id': process.env.HUBOT_VICTOROPS_API_ID
  'X-VO-Api-Key': process.env.HUBOT_VICTOROPS_API_KEY

rest_api_key = process.env.HUBOT_VICTOROPS_REST_API_KEY

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

  robot.hear /^!critical ?(\S+) (.*)/, (msg) ->
    route = msg.match[1]
    message = msg.match[2]

    alert_data = JSON.stringify({
      message_type: "CRITICAL"
      state_message: "Created by #{msg.message.user.name} via Hubot"
      entity_id: "#{message}"
      subject: "#{message}"
    })

    robot
      .http("https://alert.victorops.com/integrations/generic/20131114/alert/#{rest_api_key}/#{route}")
      .post(alert_data) (err, res, body) ->
        if err
          msg.reply "Error occurred sending alert: #{err}"
          return
        if res.statusCode!=200
          msg.reply "Alert failed to send. Status code: #{res.statusCode}"
          return
        msg.reply "Alert has been sent"

  robot.hear /^!warning ?(\S+) (.*)/, (msg) ->
    route = msg.match[1]
    message = msg.match[2]

    alert_data = JSON.stringify({
      message_type: "WARNING"
      state_message: "Created by #{msg.message.user.name} via Hubot"
      entity_id: "#{message}"
      subject: "#{message}"
    })

    robot
      .http("https://alert.victorops.com/integrations/generic/20131114/alert/#{rest_api_key}/#{route}")
      .post(alert_data) (err, res, body) ->
        if err
          msg.reply "Error occurred sending alert: #{err}"
          return
        if res.statusCode!=200
          msg.reply "Alert failed to send. Status code: #{res.statusCode}"
          return
        msg.reply "Alert has been sent"
