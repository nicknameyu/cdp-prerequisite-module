# Change log for module cdp-prerequisite for Azure

## v0.2.6 AWS policy adjustment
- update cross account reduced policy with the latest version. 
- update reduced policy for DW with the latest version. plus three undocumented permissions:
```
        "acm:RequestCertificate",
        "acm:AddTagsToCertificate",
        "elasticfilesystem:PutFileSystemPolicy",
```
## v0.2.5 AWS policy adjustment
- Liftie policy wasn't sufficient. Adding below policies base on testing. These policies are missing in Liftie policy V9, V10, V12.
```
                "iam:AddRoleToInstanceProfile",
                "iam:AttachRolePolicy",
                "iam:CreateRole",
                "iam:CreateServiceLinkedRole",
                "iam:DeleteRole",
                "iam:DeleteRolePolicy",
                "iam:DetachRolePolicy",
                "iam:GetRole",
                "iam:ListAttachedRolePolicies",
                "iam:ListRolePolicies",
                "iam:ListRoles",
                "iam:PassRole",
                "iam:PutRolePolicy",
                "iam:SimulatePrincipalPolicy"

                "iam:CreateInstanceProfile",
                "iam:DeleteInstanceProfile",
                "iam:ListInstanceProfiles",
                "iam:RemoveRoleFromInstanceProfile",
                "iam:AddRoleToInstanceProfile" 
```

## v0.2.4 AWS modules first version
- AWS modules first version
- a minor fix for Azure module

## v0.2.3 Azure adjustment final
## v0.2.2 Azure adjustment

## v0.2.1 azure adjustment
- add one new module `cdp-custom-role-permissions` to calculate required permissions. 
- adjust other modules accordingly. 

## v0.2.0 Rebuild azure module
- Break one module into 5 modules to adapt with different requirement. 
## v0.1.1 AWS module
- Create CDP prerequiste resources
- Create CMK key and related permissions. 
- Create cross account role, or associate proper permissino to an existing cross account role.
- Create an SSH key

## V0.1.0 Azure module
- Create CDP prerequisite resources
- Create data warehouse managed identity as well as custom role for data warehouse
- Create CMK key vault and key
- Create file share for ML