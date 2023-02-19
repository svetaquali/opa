package torque.terraform_plan

import input as tfplan

# --- Validate aws instance types ---

get_basename(path) = basename{
    arr := split(path, "/")
    basename:= arr[count(arr)-1]
}

contains(arr, elem){
    arr[_] == elem
}

# This policy enforces a list of instance types that are forbidden for usage in environments launched from it.
# It takes an array of prohibited instance types as an argument (in the data object):
#   prohibited_instance_types: the list of prohibited instance types that are not allowed for usage.
#
# An example of a data object for this policy looks like this:
# {
#   "prohibited_instance_types": [
#       "t2.xlarge"
#    ]
# }
#
# This example forbids the environments to use "t2.xlarge" instance type.

deny[reason] {
    not is_array(data.prohibited_instance_types)
    reason:= "The data variable 'prohibited_instance_types' has to be an array."
}

deny[reason] {
    is_array(data.prohibited_instance_types)
    resource := tfplan.resource_changes[_]
    get_basename(resource.provider_name) == "aws"
    instance_type:= resource.change.after.instance_type
    contains(data.prohibited_instance_types, instance_type)
    reason:= concat("",["Invalid instance type: '", instance_type, "'. The prohibited instance types for AWS are: ", sprintf("%s", [data.prohibited_instance_types])])
}
