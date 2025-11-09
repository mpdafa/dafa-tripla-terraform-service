from flask import Flask, request, jsonify
import hcl2 # https://pypi.org/project/python-hcl2/

app = Flask(__name__)

@app.get("/get-resource")
def get_handler():
    resource_type = request.headers.get("resource-type")
    resources = []
    with open(f"terraform/main.tf", "r") as f:
        data = hcl2.load(f)
        for block in data.get("resource", {}):
            for type, defs in block.items():
                if type == resource_type:
                    resources.extend(defs.keys())

    return jsonify({
        "resource_type": resource_type,
        "total": len(resources),
        "names": resources
    })

@app.post("/provision")
def post_handler():
    data = request.get_json() or {}
    if not data:
        return jsonify({"error": "Missing JSON payload"}), 400

    #generate_tf_template(data, f"terraform/{data.get("resource")}.tf")
    generate_tf_template(data, f"terraform/main.tf")
    return jsonify({"received": data})

@app.delete("/delete-resource")
def destroy_handler():
    resource_type = request.headers.get("resource-type")
    resource_name = request.headers.get("resource-name")

    if not (resource_type and resource_name):
        return jsonify({"error": "Missing resource type or resource name!"}), 404
    
    #with open(f"terraform/{resource_type}.tf", "r") as f: 
    with open(f"terraform/main.tf", "r") as f: 
        data = hcl2.load(f)
    
    # Rewrite tf block
    new_blocks = [] 
    for block in data.get("resource", []):
        keep_block = True
        for type, defs in block.items():
            if type == resource_type and resource_name in defs:
                keep_block = False
        if keep_block:
            new_blocks.append(block)

    # Rewrite file
    #with open(f"terraform/{resource_type}.tf", "w") as f:
    with open(f"terraform/main.tf", "w") as f: 
        f.write("resource blocks updated\n") 

    return jsonify({
        "message": f"{resource_type}.{resource_name} has been removed"
    })

def generate_tf_template(payload: dict, output_tf):
    resource_type = payload.get("resource")
    props = payload.get("properties", {})
    acl = props.get("acl", "").lower()
    acl_block = ""

    if resource_type != "aws_s3_bucket":
        raise ValueError(f"Unsupported resource type: {resource_type}")
    if acl not in ["private", "public"]:
        raise ValueError(f"Missing or invalid ACL value: '{props.get('acl')}'. Must be 'private' or 'public'.")

    converted_name = f"static_assets_{props.get('bucket-name').replace('-', '_')}"

    # 🧩 Shared base section
    base_block = f'''## Bucket {converted_name}
resource "aws_s3_bucket" "{converted_name}" {{
  bucket_prefix = "{props.get('bucket-name')}-"
  tags = {{
      Env = "{props.get('environment')}"
  }}
}}

output "bucket_name_{converted_name}" {{
  value = aws_s3_bucket.{converted_name}.bucket
}}

resource "aws_s3_bucket_ownership_controls" "{converted_name}" {{
  bucket = aws_s3_bucket.{converted_name}.id

  rule {{
    object_ownership = "BucketOwnerPreferred"
  }}
}}
'''

    if acl == "public":
        acl_block = f'''
resource "aws_s3_bucket_public_access_block" "{converted_name}" {{
  bucket = aws_s3_bucket.{converted_name}.id
  block_public_acls       = false
  ignore_public_acls      = false
  block_public_policy     = true
  restrict_public_buckets = true
}}

resource "aws_s3_bucket_acl" "{converted_name}" {{
  bucket = aws_s3_bucket.{converted_name}.id
  acl    = "public-read"
  depends_on = [
    aws_s3_bucket_ownership_controls.{converted_name},
    aws_s3_bucket_public_access_block.{converted_name}
  ]
}}
'''
    final_block = base_block + acl_block

    with open(output_tf, "a") as f:
        f.write(final_block + "\n")


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000, debug=True)