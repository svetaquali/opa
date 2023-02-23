package torque.terraform_plan

import input as tfplan

# This policy enforces a list of allowed locations that can be used by environments launched from it.
# It takes an array of allowed locations as an argument (in the data object):
#   allowed_locations: the list of allowed locations for usage.
#
# An example of a data object for this policy looks like this:
# {
#   "allowed_locations": [
#       "eastus"
#    ]
# }
#
# This example allows the environments to use only "eastus" location.
deny[reason] {
    not is_array(data.allowed_locations)
    reason:= "The data variable 'allowed_locations' has to be an array."
}

deny[reason] {
    allowed_set:= { x | x:= data.allowed_locations[_] }
    results_set:= { r | r:= tfplan.resource_changes[_].change.after.location }
    diff:= results_set - allowed_set
    
    # print("allowed_set:       ", allowed_set)
    # print("used_locations:    ", results_set)
    # print("diff:              ", diff)

    count(diff) > 0 # if true -> deny! and return this error ("reason") below
    reason:= concat("", ["Invalid location: '", sprintf("%s", [results_set[_]]), "'. The allowed Azure locations are: ", sprintf("%s", [data.allowed_locations])])
}