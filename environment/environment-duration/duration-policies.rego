package torque.environment

import future.keywords.if


# This policy enforces a maximal duration on environments launched from it.
# It takes two numbers as arguments (in the data object):
#   1. max_duration_minutes : the total number of minutes the environments are allowed to run (including extentions)
#   2. duration_for_manual_minutes : the duration of the environment which will require a manual approval.
# Usually, duration_for_manual_minutes will be smaller than max_duration_minutes.
#
# An example of a data object for this policy looks like this:
# {
#   "max_duration_minutes": 300
#   "duration_for_manual_minutes": 120
# }
#
# In this example we allow the environment to be up to 5 hours total. Anything more than 5 hours would be automatically denied.
# Duration which is between 2 and 5 hours would need manual approval,
# and below 2 hours would be automatically approved without manual intervention.
#

result := {"decision": "Denied", "reason": "Max duration has to be a number."} if {
    not is_number(data.max_duration_minutes)
}

result := {"decision": "Denied", "reason": "Duration for manual has to be a number."} if {
    not is_number(data.duration_for_manual_minutes)
}

result = { "decision": "Denied", "reason": "sandbox duration exceeds max duration" } if {
    is_number(data.max_duration_minutes)
    is_number(data.duration_for_manual_minutes)
    data.max_duration_minutes < input.duration_minutes
}

result = { "decision": "Manual", "reason": "sandbox duration requires approval" } if {
    is_number(data.max_duration_minutes)
    is_number(data.duration_for_manual_minutes)
	data.max_duration_minutes > input.duration_minutes
	data.duration_for_manual_minutes < input.duration_minutes
}

result = { "decision": "Approved" } if {
    is_number(data.max_duration_minutes)
    is_number(data.duration_for_manual_minutes)
	data.duration_for_manual_minutes > input.duration_minutes
}