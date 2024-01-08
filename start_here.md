Using Terrafrom create an aws instance (ubuntu) in multiple regions (free-tier) (eu-west-1 and eu-central-1)

- should be on minimum of 2 availablity zones

- should be reuseable

- can be built on multiple environments (dev, prod)

- should have a script that creates ansible, docker container

- your scripts should be modularized

- Create a VPC for the various environments

SOLUTION:
Create a public key with the 'ssh-keygen' and rename the private key to the respective .pem, then dublicate the keys for each region and then in your command line run 

'export TF_VAR_public_key=ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQD3F6tyPEFEzV0LX3X8rtrdMsQz1x2cEikKDEY0aIj41qgxMCP/iteneqXSIFZBp5vizPvaoIR3Um9xK7PGoW8giupGn+EPuxIA4cDM4vzOqOkiMPhz5XK0whEjkVzTo4+S0puvDZuwIsdiW9mxhJc7tgBNL0cYlWSYVkz4G/fslNfRPW5mYAM49f4fhtxPb5ok4Q2Lg9dPKVHO/Bgeu5woMc7RY0p1ej6D4CKFE6lymSDJpW0YHX/wqE9+cfEauh7xZcG0q9t2ta6F6fmX0agvpFyZo8aFbXeUBr7osSCJNgvavWbM/06niWrOvYX2xwWdhXmXSrbX8ZbabVohBK41 email@example.com'

replace the placeholder public key with your actual public key.
during terraform apply, it will pick this ssh public key from your system env to create a key pair on aws. 

TO PROVISION THE INFRASTRUCTURE IN:

Go inito
  

Development Environment 
  ```
        terraform init
  ```

  ```  
  
        terraform plan --var-file central-dev.tfvars

  ```

  ```      
        terraform apply --var-file central-dev.tfvars

  ```  

  ```    
        terraform apply --var-file west-dev.tfvars

```

Production Environment 
  ```
        terraform init
  ```

  ```  
  
        terraform plan --var-file central-dev.tfvars

  ```

  ```      
        terraform apply --var-file central-dev.tfvars

  ```  

  ```    
        terraform apply --var-file west-dev.tfvars

```
