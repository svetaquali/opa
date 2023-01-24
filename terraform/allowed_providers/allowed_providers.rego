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

deny[reason] {
  provider_name:= get_basename(tfplan.resource_changes[_].provider_name)
  not contains_case_insensitive(data["allowed_providers"], provider_name)
  reason:= concat("",["Invalid provider: '", provider_name, "'. The allowed providers are: ", sprintf("%s", [data.allowed_providers])])
}
