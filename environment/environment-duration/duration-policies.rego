package torque.environment

import future.keywords.if

get_unit_number(max_duration_ns, index) = date_number {
	diff_data := time.diff(max_duration_ns, 0)
	date_number := diff_data[index]
}

days(max_duration_ns) = days_str {
	years_number := get_unit_number(max_duration_ns, 0)
    months_number := get_unit_number(max_duration_ns, 1)
	days_number := get_unit_number(max_duration_ns, 2)
    days := years_number * 365 + months_number * 30 + days_number
    days != 0
    days_str := concat(" ", [sprintf("%v", [days]), "days"])
}

hours(max_duration_ns) = hours_str {
	hours_number := get_unit_number(max_duration_ns, 3)
    hours_number != 0
    hours_str := concat(" ", [sprintf("%v", [hours_number]), "hours"])
}

minutes(max_duration_ns) = minutes_str {
	minutes_number := get_unit_number(max_duration_ns, 4)
    minutes_number != 0
    minutes_str := concat(" ", [sprintf("%v", [minutes_number]), "minutes"])
}

get_timespan_string(max_duration_ns) = timespan {
    days_str = days(max_duration_ns)
	hours_str = hours(max_duration_ns)
    minutes_str = minutes(max_duration_ns)
	timespan := concat(" ", [days_str, hours_str, minutes_str])
}

get_timespan_string(max_duration_ns) = timespan {
    days_str = days(max_duration_ns)
	hours_str = hours(max_duration_ns)
    not minutes(max_duration_ns)
	timespan := concat(" ", [days_str, hours_str])
}

get_timespan_string(max_duration_ns) = timespan {
    days_str = days(max_duration_ns)
	minutes_str = minutes(max_duration_ns)
	not hours(max_duration_ns)
	timespan := concat(" ", [days_str, minutes_str])
}

get_timespan_string(max_duration_ns) = timespan {
    hours_str = hours(max_duration_ns)
	minutes_str = minutes(max_duration_ns)
	not days(max_duration_ns)
	timespan := concat(" ", [hours_str, minutes_str])
}

get_timespan_string(max_duration_ns) = timespan {
	days_str = days(max_duration_ns)
    not hours(max_duration_ns)
    not minutes(max_duration_ns)
	timespan := concat(" ", [days_str])
}

get_timespan_string(max_duration_ns) = timespan {
	hours_str = hours(max_duration_ns)
    not days(max_duration_ns)
    not minutes(max_duration_ns)
	timespan := concat(" ", [hours_str])
}

get_timespan_string(max_duration_ns) = timespan {
	minutes_str = minutes(max_duration_ns)
    not days(max_duration_ns)
    not hours(max_duration_ns)
	timespan := concat(" ", [minutes_str])
}

# testing
# This policy enforces a maximal duration on environments launched from it.
# It takes two numbers as arguments (in the data object):
#   1. env_max_duration_minutes : the total number of minutes the environments are allowed to run (including extentions)
#   2. env_duration_for_manual_approval_minutes : the duration of the environment which will require a manual approval.
# Usually, env_duration_for_manual_approval_minutes will be smaller than max_duration_minutes.
#
# An example of a data object for this policy looks like this:
# {
#   "env_max_duration_minutes": 300,
#   "env_duration_for_manual_approval_minutes": 120
# }
#
# In this example we allow the environment to be up to 5 hours total. Anything more than 5 hours would be automatically denied.
# Duration which is between 2 and 5 hours would need manual approval,
# and below 2 hours would be automatically approved without manual intervention.
result := { "decision": "Denied", "reason": "environment must have duration" } if {
    not input.duration_minutes
}

result := {"decision": "Denied", "reason": "Max duration and duration for manual have to be numbers."} if {
	data.env_max_duration_minutes
	not is_number(data.env_max_duration_minutes)
	data.env_duration_for_manual_approval_minutes
	not is_number(data.env_duration_for_manual_approval_minutes)
}

result = {"decision": "Denied", "reason": concat("", ["environment duration exceeds max duration in ", timespan, ""])} if {
    is_number(data.env_max_duration_minutes)
	data.env_max_duration_minutes < input.duration_minutes
	difference := input.duration_minutes - data.env_max_duration_minutes
	timespan := get_timespan_string(difference * 60000000000)
}

result = {"decision": "Manual", "reason": "environment duration requires approval"} if {
	is_number(data.env_max_duration_minutes)
	is_number(data.env_duration_for_manual_approval_minutes)
	data.env_max_duration_minutes > input.duration_minutes
	data.env_duration_for_manual_approval_minutes < input.duration_minutes
}

result = {"decision": "Approved"} if {
    is_number(data.env_max_duration_minutes)
	is_number(data.env_duration_for_manual_approval_minutes)
    data.env_duration_for_manual_approval_minutes < data.env_max_duration_minutes
	data.env_duration_for_manual_approval_minutes > input.duration_minutes
}
