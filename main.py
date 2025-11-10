from flask import Flask, request, jsonify
from jinja2 import Template # https://jinja.palletsprojects.com/en/stable/api/
import hcl2 # https://pypi.org/project/python-hcl2/

app = Flask(__name__)

@app.get("/get-resource")
def get_handler():
    resource_type = request.headers.get("resource-type")
    region = request.headers.get("aws-region", "ap-southeast-1")
    resources = []
    with open(f"terraform/{region}/main.tf", "r") as f:
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
    generate_tf_template(data)
    return jsonify({"received": data})

@app.delete("/delete-resource")
def destroy_handler():
    resource_type = request.headers.get("resource-type")
    resource_name = request.headers.get("resource-name")
    region = request.headers.get("aws-region", "ap-southeast-1")

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
    with open(f"terraform/{region}/main.tf", "w") as f: 
        f.write("resource blocks updated\n") 

    return jsonify({
        "message": f"{resource_type}.{resource_name} has been removed"
    })

def generate_tf_template(payload: dict):
    resource_type = payload.get("resource")
    props = payload.get("properties", {})

    if resource_type != "aws_s3_bucket":
        raise ValueError(f"Unsupported resource type: {resource_type}")

    bucket_name = props.get("bucket-name")
    environment = props.get("environment", "dev")
    region = props.get("aws-region", "ap-southeast-1")
    enable_policy = props.get("enable-policy", False)
    policy_data = props.get("policy", {})

    resource_name = f"bucket_{bucket_name.replace('-', '_')}"

    statements = []
    if enable_policy and policy_data:
        statements = policy_data.get("statements", [])

    # Load jinja template
    with open("jinja-template/s3.tf.j2") as f:
        template = Template(f.read())

    tf_rendered = template.render(
        aws_region=region,
        bucket_name=bucket_name,
        environment=environment,
        resource_name=resource_name,
        enable_policy=enable_policy,
        policy_statements=statements
    )

    output_tf = f"terraform/{region}/main.tf"
    with open(output_tf, "a") as f:
        f.write(tf_rendered + "\n")

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000, debug=True)