provider "aws" {
  region = "ap-south-1" # Change to your desired region
}

resource "aws_resourcegroups_group" "example" {
  name        = "abc"
  description = "An example resource group for AWS"

  resource_query {
    query = jsonencode({
      ResourceTypeFilters = ["AWS::AllSupported"]
      TagFilters = [
        {
          Key    = "Environment"
          Values = ["Development"]
        }
      ]
    })
  }
}
