package torque.terraform_plan

import input as tfplan

# --- Validate allowed providers names (case-insensitive) ---

get_basename(path) = basename{
    arr:= split(path, "/")
    basename:= arr[count(arr)-1]
}

equals(a, b) {
  a == b
}

contains_case_insensitive(arr, elem) {
  lower_elem:= lower(elem)
  equals(lower(arr[_]), lower_elem)
}

# This policy enforces a list of allowed providers on environments launched from it.
# It takes an array of allowed providers as an argument (in the data object):
#   allowed_providers: the list of provider names that are allowed for usage.
#
# An example of a data object for this policy looks like this:
# {
#   "allowed_providers": [
#       "aws"
#    ]
# }
#
# This example allows the deployment only using "aws" as a provider.
deny[reason] {
    not is_array(data.allowed_providers)
    reason:= "The data variable 'allowed_providers' has to be an array."
}

deny[reason] {
  provider_name:= get_basename(tfplan.resource_changes[_].provider_name)
  not contains_case_insensitive(data["allowed_providers"], provider_name)
  reason:= concat("",["Invalid provider: '", provider_name, "'. The allowed providers are: ", sprintf("%s", [data.allowed_providers])])
}
