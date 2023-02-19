package torque.terraform_plan

import input as tfplan

# --- Validate resource types ---

get_basename(path) = basename {
    arr:= split(path, "/")
    basename:= arr[count(arr)-1]
}

contains(arr, elem){
    arr[_] == elem
}

# This policy enforces a list of allowed resource types that can be created from environments launched from it.
# It takes an array of allowed resource types as an argument (in the data object):
#   allowed_resource_types: the list of allowed resource type names that are allowed for usage.
#
# An example of a data object for this policy looks like this:
# {
#   "allowed_resource_types": [
#       "aws_s3_bucket"
#    ]
# }
#
# This example allows the environments to create only s3 buckets.
deny[reason] {
    not is_array(data.allowed_resource_types)
    reason:= "The data variable 'allowed_resource_types' has to be an array."
}

deny[reason] {
    is_array(data.allowed_resource_types)
    resource:= tfplan.resource_changes[_]
    get_basename(resource.provider_name) == "aws"
    not contains(data.allowed_resource_types, resource.type)
    reason:= concat("",["Invalid resource type: '", resource.type, "'. The allowed AWS resource types are: ", sprintf("%s", [data.allowed_resource_types])])
}
