# Quali Torque built-in OPA policy templates

OPA built-in template collection to create Torque security policies.

## Resources

* Documentation for using policies in Torque: https://docs.qtorque.io/admin-guide/security-policies

* OPA documentation: https://www.openpolicyagent.org/docs/latest/

* OPA Playground: https://play.openpolicyagent.org/

## Policy In Torque

Torque allows adding a security policy based on the OPA policy templates that this repo contains. As described in the documentation above, account admin users can create an instance from a template, specify the external data values, and define the enforcement scope - the whole account or specific spaces.
Once a security policy is created, the enforcement will be active at the selected scope.

## Available Policy Template List

All available built-in policy templates are described below; including the external data accompanying each of them.

### Terraform Based Policy Templates
| Policy Template | Description | External Data |
| --------------- | ----------- | ------------- |
| [Allowed Providers](https://github.com/QualiTorque/opa/blob/main/terraform/allowed_providers/allowed_providers.rego) | Checks the allowed Terraform providers an environment is allowed to deploy on. | `allowed_providers`  Example: *["aws", "azurerm"]* |
| [AWS Allowed Regions](https://github.com/QualiTorque/opa/blob/main/terraform/aws/allowed_regions/allowed_regions.rego) | Checks the AWS allowed regions for deploying environments. | `allowed_regions`  Example: *["eu-west-1", "us-east-2"]* |
| [AWS Allowed Resource Types](https://github.com/QualiTorque/opa/blob/main/terraform/aws/allowed_resource_types/allowed_resource_types.rego) | Checks the AWS resources an environment is allowed to deploy. | `allowed_resource_types`  Example: *["aws_instance"]* |
| [AWS Prohibited Instance Types](https://github.com/QualiTorque/opa/blob/main/terraform/aws/prohibited_instance_types/prohibited_instance_types.rego) | Checks the instance types that environments are **not allowed** to deploy on AWS. | `prohibited_instance_types`  Example: *["t2.2xlarge", "t2.xlarge", "t2.large"]* |
| [AWS Only Private S3 Buckets](https://github.com/QualiTorque/opa/blob/main/terraform/aws/only_private_S3_buckets/only_private_S3_buckets.rego) | Allow AWS S3 Bucket deployment only with private permissions. | |
| [Azure Allowed Location](https://github.com/QualiTorque/opa/blob/main/terraform/azure/allowed_locations/allowed_locations.rego) | Checks the Azure allowed locations for deploying environments. | `allowed_locations`  Example: *["eastus2", "westus2"]* |
| [Azure Allowed Resource Types](https://github.com/QualiTorque/opa/blob/main/terraform/azure/allowed_resource_types/allowed_resource_types.rego) | Checks the Azure resources an environment is allowed to deploy. | `allowed_resource_types`  Example: *["azure_vm", "azure_date_lake_storage"]* |
| [Azure Prohibited VM Sizes](https://github.com/QualiTorque/opa/blob/main/terraform/aws_prohibited_instance_types/aws_prohibited_instance_types.rego) | Checks the VM sizes that environments are **not allowed** to deploy on Azure. | `prohibited_vm_sizes`  Example: *["E2ads_v5", "E8bds_v5"]* |
| [Azure Only Private Blob Storage](https://github.com/QualiTorque/opa/blob/main/terraform/azure/only_private_blob_storage/only_private_blob_storage.rego) | Allow Azure Blob storage deployment only with private permissions. | |

## Policy Template Folder Content

Each template folder includes 3 file types.

- `*.rego`: The OPA policy
- `*_test.rego`: Tests 
- `*_mock.json`: Mocked 'input' data for the tests

## Policy Evaluation

### Policy Input Genenraion

OPA policy evaluation requires a json file as 'input', which means the data should be enforced.

For example, Terraform allows plan json creation by the following commands using Terraform CLI:
```bash
$ terraform init
$ terraform plan --out planfile
$ terraform show -json planfile > plan.json
```

### Adding External Data

Policy data can be overloaded by external json files and refers to their content, using *data.some_key* in the policy rego file.
Most of the templates in this repository use external data to enable dynamic behavior. The supporting structure includes one level of json, while the keys map to an array of strings.

### Perform Policy Evaluation
Policy evaluation can be performed using the `opa eval` command as follows.

```bash
$ opa eval --format pretty --data {PATH_TO_REGO_FILE} --input {PATH_TO_INPUT_JSON_FILE} {PATH_TO_QUERY}
```

- `PATH_TO_REGO_FILE`: Path to the policy rego file
- `PATH_TO_INPUT_JSON_FILE`: Path to the 'input' json file
- `PATH_TO_QUERY`: The query against the policy data and the 'input', should start with `data`. For example, the query `data.torque` - will evaluate all the rules defined in the package called *'torque.terraform_plan'*.

- In order to overload the policy data as part of the evaluation, per every json file add "`--data `" and then the required file path.

## Contributions

We welcome contributions!
We will be happy for fixing bugs or implementing new policy templates.

### Pull Requests

To submit a PR follow the standard process:

* Fork the repository
* Clone locally and create a new branch
* Commit and push
* Submit a pull request

Before submitting the PR for the new policy or bug fix you should confirm it works using `opa eval` as shown above and verifies the mock-based tests work using `opa test` command against the policy files folder.

Tests evaluation example:

```
# opa test {PATH_TO_FOLDER} -v
data.terraform.test_allow_valid: PASS (7.390419ms)
data.terraform.test_deny_invalid: PASS (603.838µs)
data.terraform.test_validate_deny_message: PASS (483.273µs)
--------------------------------------------------------------------------------
PASS: 3/3
```

### Additional Highlights For Adding A New Policy Template
* A new dedicated folder is required that includes the following files:
    * The `*.rego` file with the policy code, includes the package name `torque`  and at least one rule called `deny`, which returns an array of error message strings in case of failure.
    * `*_test.rego` defining the tests to be run and expected results when the PR checks are performed. All test names in this file should start with the `test_` prefix.
    * `*_mock.json` containing test data mocks. You should include data for both valid and invalid evaluations of each rule in the policy.
* Append an `opa test` command execution against the folder, to the end of the [.github/scripts/run_opa_tests.sh](https://github.com/QualiTorque/opa/blob/main/.github/scripts/run_opa_tests.sh) script.
