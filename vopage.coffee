# Description:
#   Send VictorOps Incident
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   !critical <routing_key> <subject>
#   !warning <routing_key> <subject>

rest_api_key = process.env.HUBOT_VICTOROPS_REST_API_KEY

module.exports = (robot) ->
  robot.hear /^!critical ?(.*) (.*)/, (msg) ->
    route = msg.match[1]
    message = msg.match[2]
    
    alert_data = JSON.stringify({
      message_type: "CRITICAL"
      state_message: "Created by #{msg.message.user.name} via Hubot"
      entity_id: "#{message}"
      subject: "#{message}"
    })
    
    robot
      .http("https://alert.victorops.com/integrations/generic/20131114/alert/#{api_key}/#{route}")
      .post(alert_data) (err, res, body) ->
        if err
          msg.reply "Error occurred sending alert: #{err}"
          return
        if res.statusCode!=200
          msg.reply "Alert failed to send. Status code: #{res.statusCode}"
          return
        msg.reply "Alert has been sent"
        
module.exports = (robot) ->
  robot.hear /^!warning ?(.*) (.*)/, (msg) ->
    route = msg.match[1]
    message = msg.match[2]
    
    alert_data = JSON.stringify({
      message_type: "WARNING"
      state_message: "Created by #{msg.message.user.name} via Hubot"
      entity_id: "#{message}"
      subject: "#{message}"
    })
    
    robot
      .http("https://alert.victorops.com/integrations/generic/20131114/alert/#{api_key}/#{route}")
      .post(alert_data) (err, res, body) ->
        if err
          msg.reply "Error occurred sending alert: #{err}"
          return
        if res.statusCode!=200
          msg.reply "Alert failed to send. Status code: #{res.statusCode}"
          return
        msg.reply "Alert has been sent"
