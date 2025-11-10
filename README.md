## SRE Technical Take-Home Assignment : Terraform-Parse (Terraform + Helm)

This repository provides a python flask-based API that dynamically generates Terraform (.tf) configuration files.
Currently, it supports AWS S3 bucket provisioning with both private and public ACL modes. For questions related to this task, please refer the answer in [NOTES.md file](https://github.com/mpdafa/dafa-tripla-terraform-service/blob/main/NOTES.md)

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
    # Without Policy
    curl -X POST http://localhost:5000/provision \
    -H "Content-Type: application/json" \
    -d '{
        "resource": "aws_s3_bucket",
        "properties": {
        "bucket-name": "dummy-without-policy-1",
        "environment": "staging",
        "aws-region": "ap-southeast-1",
        "enable-policy": false
        }
    }'

    # With Policy
    curl -i -X POST http://localhost:5000/provision \
    -H "Content-Type: application/json" \
    -d '{
        "resource": "aws_s3_bucket",
        "properties": {
        "bucket-name": "dummy-with-policy-2",
        "environment": "staging",
        "aws-region": "ap-southeast-1",
        "enable-policy": true,
        "policy": {
            "statements": [
            {
                "sid": "RestrictToSpecificAccount",
                "effect": "Allow",
                "principals": ["arn:aws:iam::123456789012:root"],
                "actions": ["s3:PutObject"],
                "resources": ["arn:aws:s3:::tripla-assets/*"]
            }
            ]
        }
        }
    }'
    ```

    Response
    ```
    {
    "received": {
        "properties": {
        "aws-region": "ap-southeast-1",
        "bucket-name": "dummy-with-policy-1",
        "enable-policy": true,
        "environment": "staging",
        "policy": {
            "statements": [
            {
                "actions": [
                "s3:PutObject"
                ],
                "effect": "Allow",
                "principals": [
                "arn:aws:iam::123456789012:root"
                ],
                "resources": [
                "arn:aws:s3:::tripla-assets/*"
                ],
                "sid": "RestrictToSpecificAccount"
            }
            ]
        }
        },
        "resource": "aws_s3_bucket"
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

### CI/CD Workflow (GitHub Actions)

This repository includes complete GitHub Actions pipeline that automates image build using Docker and deployment to EKS using helm

**Workflow Summary**
- **Build**	: the Docker image from the Dockerfile and tags it with version and commit SHA.
- **Push** : Pushes the built image to Docker Hub
 using a GitHub secret token (DOCKERHUB_TOKEN).
- **Deploy** : Deploys the new image to a Kubernetes cluster using Helm based on defined values.yaml. The chart is located under helm/.
- **Trigger Condition** : The build and push workflow runs automatically on every push or pull request to the main branch. But deployment can only run on main branch.

**GitHub Secrets Configuration**

| Secret Name | Description |
|------------------|-----------------|
| `DOCKERHUB_USERNAME` | Docker Hub account username |
| `DOCKERHUB_TOKEN` | Docker Hub access token for pushing images |
| `KUBE_CONFIG` | Base64-encoded kubeconfig file used by Helm and kubectl |