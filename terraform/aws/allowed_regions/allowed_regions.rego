package torque.terraform_plan

import input as tfplan

# --- Validate region ---

get_region(provider_name) = region{
    region_var_name:= trim_prefix(input.configuration.provider_config[provider_name].expressions.region.references[0], "var.")
    region:= tfplan.variables[region_var_name].value
}
get_region(provider_name) = region{
    region:= tfplan.configuration.provider_config[provider_name].expressions.region.constant_value
}

get_basename(path) = basename{
    arr:= split(path, "/")
    basename:= arr[count(arr)-1]
}

contains(arr, elem){
    arr[_] == elem
}

deny[reason] {
    provider_name:= get_basename(tfplan.resource_changes[_].provider_name)
    region:= get_region(provider_name)
    not contains(data.allowed_regions, region)
    reason:= concat("",["Invalid region: '", region, "'. The allowed AWS regions are: ", sprintf("%s", [data.allowed_regions])])
}
