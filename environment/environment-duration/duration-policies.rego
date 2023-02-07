package torque.environment

import future.keywords.if

default status := "approval_required"
default reason := ""

result = { "decision": "Denied", "reason": "sandbox duration exceeds max duration" } if {
    data.max_duration_minutes < input.duration_minutes
}

result = { "decision": "Manual", "reason": "sandbox duration requires approval" } if {
	data.max_duration_minutes > input.duration_minutes
    data.duration_for_manual_minutes < input.duration_minutes
}

result = { "decision": "Approved" } if {
    data.duration_for_manual_minutes > input.duration_minutes
}
