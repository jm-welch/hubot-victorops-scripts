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
#   !current <team> - List users currently on-call for <team>
#   @!<team> <message> - @-mention <message> to all users currently on-call for <team>

apiauth =
  'X-VO-Api-Id': process.env.HUBOT_VICTOROPS_API_ID
  'X-VO-Api-Key': process.env.HUBOT_VICTOROPS_API_KEY

# List users here who should be excluded from all user lists
userFilter = [
  ''
  'ghost1'
  'ghost2'
  'ghost3'
]

module.exports = (robot) ->
  robot.hear /^!current +(.*)$/i, (msg) ->
    team = msg.match[1]

    robot
      .http("https://api.victorops.com/api-public/v1/team/#{team}/oncall/schedule")
      .headers(apiauth)
      .get() (err, res, body) ->
        users = get_current_users team, body
        if users?
          msg.reply "Users on-call for #{team}: #{users.join(', ')}"
        else
          msg.reply "No team '#{team}' found."

  robot.hear /^@! ?(\S*) (.*)/, (msg) ->
    team = msg.match[1]
    message = msg.match[2]

    robot
      .http("https://api.victorops.com/api-public/v1/team/#{team}/oncall/schedule")
      .headers(apiauth)
      .get() (err, res, body) ->
        users = get_current_users team, body
        if users?
          mention = ("@#{user}" for user in users).join(' ')
          msg.send "#{mention} (from #{msg.envelope.user.id}): #{message}"
        else
          msg.reply "No team '#{team}' found."

  get_current_users = (team, apiresult) ->
    robot.logger.info "CURRENT: Finding current on-call members for #{team}"
    res = JSON.parse "#{apiresult}"
    if res["schedule"]?
      users = []
      for sched in res["schedule"]
        shift = sched["shiftName"]
        robot.logger.debug sched
        response = if sched["overrideOnCall"]? then sched["overrideOnCall"] else sched["onCall"]
        # Only push if there's actually someone on-call. This handles FtS rotations
        if response? and response not in userFilter
          users.push response
          robot.logger.info "CURRENT: #{response} is on-call for the #{shift} shift"
      users
    else
      null
