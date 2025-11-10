### Part 1 (API Service): 
*Describe how you implemented the `Terraform-Parse` service. Include the framework/language you chose, how the API works, and how it translates the payload into Terraform code.*

**Answer :**

I have created the terraform generator and parser service using python flask framework that able to served restful http request, along with a custom library, python-hcl2 that able to parse terrafrom (hcl file) resource blocks. This service will act as a backend for platform as a service that can easily used by developer to on board their resources. The API exposes several endpoints which are :
- **POST /provision** : It accepts json payload/body which consist of needed field for resrouce creation which in this case, AWS S3 bucket. Python function will retrieved the details and rewriting the terrafom file by appending the new S3 bucket resrouce block into the file.
- **GET /get-resource:** It reads terraform file based on the specified resrouce type, by utilzing hcl2 modules to parse the tf resoruce block into a readable dict. It loops through all the block to retrieve the resrouce name and the total resrouce.
- **DELETE /destroy-resrouce** : It removes a specific resrouce block from the TF. The destroy_handler will read the tf file with hcl2 modules to parse the tf files, load it into a dict. To remove the block, It will rewrite the file by skipping the specified resrouce block and definitions in the iteration.

Working Steps:

Initially i am creating the MVP (minimum viable product) to share basic template generator function by concantenate and basic functionality to update the terraform file under the same directory as the service (please refer the code in this [initial commit](https://github.com/mpdafa/dafa-tripla-terraform-service/commit/dfa957422cb4ed8ddcfd1d9a6eb522c8e1841dc5)).

To improve this, i later raised [a followup PR](https://github.com/mpdafa/dafa-tripla-terraform-service/pull/2) where I refactored the function to use Jinja templates. This way, we can reduce complex loop on the code and maintain the TF template file easier.  Additionally, i also replace the S3 bucket acl to iam policy for access control. The reasons behind this change will be explained in the next part.


### Part 2 (Terraform): 
*Describe the issues you found and how you approached improving them. Mention anything you think could still be enhanced.*

**Answer :**

1. Terraform backend state

    For consistent terraform state and better team collaboration, the state need to be stored in centralized s3 bucket instead of locally. It prevents config drift.
2. S3 bucket resource block issues
- Starting from terraform aws >= 4.0, the bucket and bucket acl should be in a separate resrouce block
- A short hard coded s3 bucket name is not a best practice, since it should unique globally. We can use bucket_prefix for this, the aws module will generate the random suffix for the bucket name
- Not a big deal, but it will be better if it has more tags for each bucket (team and app name)
- It might depends on the usecase, but also it will be better to set the bucket ACL to be private, to restrict the access by only the aws account owner (aws_iam_role_policy and aws_iam_role block will be needed)
5. EKS
- It is not a good pracitce to only define desired_capacity number without min_capacity and max_capacity. Without these 2, EKS will provision the cluster with fixed node number without autoscaling.
- To have better high availbilitym we can provision the eks into three subnet, this way the cluster can be spawned to 3 different AZs
6. Provider 
    
    Since i assume there will be use case for s3 bucket creation where we need to provison it in more than 1 region, i have structured the tf folder into different regions, each folder has its own provider and tf state (same bucket).

7. Replace S3 ACL to IAM Policy

    Since this task is open-ended, if it is possible, I decided not to use S3 ACLs—the legacy method of managing S3 bucket permissions—and instead replaced them with IAM policies (slightly deviating from the original requirement). Based on my experience, i believe IAM bucket policies provide a more secure and has better logic to manage the access control. This practice is also mentioned [in this blog post](https://aws.amazon.com/blogs/security/iam-policies-and-bucket-policies-and-acls-oh-my-controlling-access-to-s3-resources/#:~:text=A%20majority%20of%20modern%20use,for%20your%20users%20and%20roles.) 


### Part 3 (Helm): 
*Explain the problems you encountered with the chart, how you addressed them, and how you validated your changes.*

[ToDo]

Add readiness and liveness probe

### Part 4 (System Behavior): 
*Share your thoughts on how this setup might behave under load or in failure scenarios, and what strategies could make it more resilient in the long term.*

**Answer :**

Although this service is for internal developer usage and not for end user, it should be capable for at least handling the traffic up to 1000 rps with response time around 500ms to 1s. We can also consider to reafactor it to fastapi for higher throughput handling (ref : [link](https://strapi.io/blog/fastapi-vs-flask-python-framework-comparison)). In the longer term, it may be even more beneficial to refactor the service into Go, which is well known for being lightweight, resource-efficient, and capable of handling concurrency more effectively than Python, even though it will require additonal learning curve and sprint commitments for SRE team.

In the short term it should be sufficient to increase the minimum replica count, set appropriate CPU requests and limits, and tune the Horizontal Pod Autoscaler (HPA) thresholds. These measures will help the service dynamically adapt to higher load and prevent issues such as pod crashes due to cpu throttling or out-of-memory (OOM).


### Part 5 (Approach & Tools): 
*Outline the approach you took to complete the task, including any resources, tools, or methods that supported your work.*

**Answer :**

1. To implement the service, I immediately decided to use Flask, as I’m more confident building lightweight Python APIs from scratch with it. I referred to the [flask documentation](https://flask.palletsprojects.com/en/stable/) to quickly set up a simple HTTP server and define simple routes for GET and POST.

2. I am able to create my own function to generate tf tempalte and append the resource block into the file. But to really parse the terraform for get (/get-reource) and delete (delete-resource )handler , i decided to use python hcl2 (https://pypi.org/project/python-hcl2/) as a helper to convert the resrouce block into dict variables, and play with it.

3. In the next pull request, I used AI assistance to review my code and gained insights on improving it. For Terraform file generator function, unstead of generating Terraform blocks through simple string concatenation, I refactored the function to use Jinja templates. This change made the loop structures much cleaner and allows the templates to be easily maintained by updating it directly within the .j2 files.

4. I also have used AI assistance to help me create a proper template for README documentation regarding the API and service details.