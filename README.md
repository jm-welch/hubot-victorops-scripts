# hubot-victorops-scripts
Hubot scripts to extend VictorOps

## Setup
Make sure your invocation of hubot exports the following environment variables (found in the VictorOps interface at **Settings > API**):

    HUBOT_VICTOROPS_API_ID
    HUBOT_VICTOROPS_API_KEY

## Scripts
### current.coffee
List or @-mention currently on-call members for a team.

The `userFilter` is a list of users that should never be returned by either function. Our organization uses "Ghost" users to help construct our schedules, so this was written to keep those users out of the results. Unless similar users exist at your org, no changes should need to be made here.

#### Usage
```
hubot current <team>
@!<team> message
```

### swap.coffee
Swap on-call a'la the **Take On-Call** feature.

**Important:** The **Take On-Call** feature can only be used to take someone else's on-call shift (it cannot be used to "give" on-call). This script allows anyone to move on-call back and forth (both "give" and "take"). Use with trust and caution.

#### Usage
```
hubot swap <team> from <fromUser> to <toUser>
```
