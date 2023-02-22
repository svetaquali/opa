package torque.environment

import future.keywords.if

does_name_start_with {
	startswith(input.blueprint.name, data.blueprint_name)
}

# This policy enforces a blueprint name validation on environments launched from it.
# It takes a string as an argument (in the data object):
#   1. blueprint_name : the prefix of the blueprint name used for environment launch
# Usually, env_duration_for_manual_approval_minutes will be smaller than max_duration_minutes.
#
# An example of a data object for this policy looks like this:
# {
#   "blueprint_name": "test"
# }
#
# In this example we request a manual approval for any environment with a 
# blueprint whose name starts with a word "test".
result = { "decision": "Manual", "reason": "Blueprint is restricted." } if {
	does_name_start_with
} 

result = { "decision": "Approved" } if {
	not does_name_start_with
} 