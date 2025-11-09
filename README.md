## SRE Technical Take-Home Assignment : Terraform-Parse (Terraform + Helm)

This repository provides a python flask-based API that dynamically generates Terraform (.tf) configuration files.
Currently, it supports AWS S3 bucket provisioning with both private and public ACL modes.

### API details

| **Endpoint** | **Method** | **Description** |
|---------------|------------|-----------------|
| `/get-resource` | `GET` | Reads and lists existing Terraform resources from a `.tf` file |
| `/provision` | `POST` | Generates and appends Terraform resource blocks dynamically |
| `/delete-resource` | `DELETE` | Deletes a resource definition from a `.tf` file |


### Example Payload
1. Provision Resource : Generate Terraform for an AWS S3 bucket.

    Request
    ```
    curl -X POST http://localhost:5000/provision \
    -H "Content-Type: application/json" \
    -d '{
        "resource": "aws_s3_bucket",
        "properties": {
        "bucket-name": "static-assets-dummy-3",
        "environment": "staging",
        "region": "ap-southeast-1",
        "acl": "private"
        }
    }'
    ```

    Response
    ```
    {
    "received": {
        "resource": "aws_s3_bucket",
        "properties": {
        "bucket-name": "static-assets-dummy-3",
        "environment": "staging",
        "region": "ap-southeast-1",
        "acl": "private"
        }
    }
    }
    ```
2. Get Resource List: Retrieve existing resource names from a .tf file.

    Request
    ```
    curl -X GET http://localhost:5000/get-resource \
    -H "resource-type: aws_s3_bucket"
    ```
    Response
    ```
    {
    "resource_type": "aws_s3_bucket",
    "total": 2,
    "names": ["static_assets_dummy_1", "static_assets_dummy_2"]
    }
    ```
3. Delete Resource : Delete a specific resource definition from the file.

    Request
    ```
    curl -X DELETE http://localhost:5000/delete-resource \
    -H "resource-type: aws_s3_bucket" \
    -H "resource-name: static_assets_dummy_2"
    ```
    Response
    ```
    {
    "message": "aws_s3_bucket.static_assets_dummy_2 has been removed"
    }
    ```