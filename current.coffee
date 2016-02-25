# Description:
#   Return or @-mention users currently on call for a team
#
# Dependencies:
#   None
#
# Configuration:
#   HUBOT_VICTOROPS_API_ID = API ID
#   HUBOT_VICTOROPS_API_KEY = API Key
#
# Commands:
#   hubot current <team> - List users currently on-call for <team>
#   @!<team> <message> - @-mention <message> to all users currently on-call for <team>

apiauth =
  'X-VO-Api-Id': process.env.HUBOT_VICTOROPS_API_ID
  'X-VO-Api-Key': process.env.HUBOT_VICTOROPS_API_KEY

userFilter = [
  'ghost1'
  'ghost2'
  'ghost3'
]

module.exports = (robot) ->
  robot.respond /current +(.*)$/i, (msg) ->
    team = msg.match[1]

    robot
      .http("https://api.victorops.com/api-public/v1/team/#{team}/oncall/schedule")
      .headers(apiauth)
      .get() (err, res, body) ->
        res = JSON.parse "#{body}"
        if res["schedule"]?
          users = (sched["onCall"] for sched in res["schedule"] when sched["onCall"]? and sched["onCall"] not in userFilter)
          msg.reply "Users on-call for #{team}: #{users.join(', ')}"
        else
          msg.reply "No team '#{team}' found."


  robot.hear /^@! ?(.*) (.*)/, (msg) ->
    team = msg.match[1]
    message = msg.match[2]

    robot
      .http("https://api.victorops.com/api-public/v1/team/#{team}/oncall/schedule")
      .headers(apiauth)
      .get() (err, res, body) ->
        res = JSON.parse "#{body}"
        if res["schedule"]?
          users = (sched["onCall"] for sched in res["schedule"] when sched["onCall"]? and sched["onCall"] not in userFilter)
          mention = ("@#{user}" for user in users).join(' ')
          msg.send "#{mention} #{message}"
        else
          msg.reply "No team '#{team}' found."
