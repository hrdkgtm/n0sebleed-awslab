# This file is for tearing down node groups, including those not managed by Terraform

resource "null_resource" "delete_all_node_groups" {
  provisioner "local-exec" {
    command = <<EOF
      # Get all node group names
      nodegroups=$(aws eks list-nodegroups --cluster-name ${var.cluster_name} --region ${var.region} --query 'nodegroups' --output text)
      for ng in $nodegroups; do
        echo "Deleting node group: $ng"
        aws eks delete-nodegroup --cluster-name ${var.cluster_name} --nodegroup-name $ng --region ${var.region}
        # Wait for deletion
        aws eks wait nodegroup-deleted --cluster-name ${var.cluster_name} --nodegroup-name $ng --region ${var.region}
      done
    EOF
  }

  # To trigger this on every apply, use timestamp
  triggers = {
    always_run = timestamp()
  }
}