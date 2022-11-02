# Make sure python is installed on system.
#pip3 install pyyaml
import subprocess as sp , os
import yaml
#*************************************************************
def is_eksctl_installed():
    print("****************************************")
    print("\nVerfiying eksctl utility ............")
    is_eksctl=sp.getstatusoutput("eksctl version")
    return is_eksctl

def install_eksctl():
    o1=sp.getstatusoutput("curl --silent --location https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz | tar xz -C /tmp")
    o2=sp.getstatusoutput("sudo mv /tmp/eksctl /usr/local/bin")
    if o1[0]==0 and o2[0]==0:
        print("Installation of eksctl is succeeded")
    else:
        print("Getting some error during eksctl installation")
def is_kubectl_installed():
    print("****************************************")
    print("\nVerfiying kubectl client utility .......")
    is_kubectl=sp.getstatusoutput("kubectl version --client")
    return is_kubectl

def install_kubectl():
    o1=sp.getstatusoutput("curl -LO https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl")
    o2=sp.getstatusoutput("curl -LO https://dl.k8s.io/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl.sha256")
    o3=sp.getstatusoutput("sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl")
    if o1[0]==0 and o2[0]==0 and o3[0]==0:
        print("Installation of kubectl is succeeded")
    else:
        print("Getting some error during kubectl installation")

def is_helm_installed():
    print("****************************************")
    print("\nVerfiying helm utility .......")
    is_helm=sp.getstatusoutput("helm version")
    return is_helm

def install_helm():
    o1=sp.getstatusoutput("curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3")
    o2=sp.getstatusoutput("chmod 700 get_helm.sh")
    o3=sp.getstatusoutput("./get_helm.sh")
    if o1[0]==0 and o2[0]==0 and o3[0]==0:
        print("Installation of helm is succeeded")
    else:
        print("Getting some error during helm installation")

def create_eks_new_vpc(cluster_name,region_name,eks_version,arn_devtron_cluster_IAM_policy,key_name):
    print("\nWill provision eks with new vpc ... ")
    # print(cluster_name, region_name,eks_version)
    filename = "ekstl-devtron-configs-create-new-vpc.yaml"
    stream = open(filename, 'r')
    data = yaml.load(stream,Loader=yaml.SafeLoader)
    data['metadata']['name']=cluster_name
    data['metadata']['region']=region_name
    data['metadata']['version']=eks_version
    data['nodeGroups'][0]['iam']['attachPolicyARNs'][5]=arn_devtron_cluster_IAM_policy
    data['nodeGroups'][1]['iam']['attachPolicyARNs'][5]=arn_devtron_cluster_IAM_policy
    data['nodeGroups'][0]['ssh']['publicKeyName']=key_name
    data['nodeGroups'][1]['ssh']['publicKeyName']=key_name
    with open(filename, 'w') as yaml_file:
        yaml_file.write( yaml.dump(data, default_flow_style=False))
    print("\n Creating the eks cluster with configured values .....\n")
    os.system("eksctl create cluster -f ekstl-devtron-configs-create-new-vpc.yaml")
def create_eks_existing_vpc(cluster_name,region_name,eks_version,arn_devtron_cluster_IAM_policy,key_name):
    print("\nWill provision eks with existing vpc configuration ")
    vpc_id=input("Your vpc id (Ex vpc-xxxxxxx): ")
    filename = "eksctl-devtron-prod-configs.yaml"
    stream = open(filename, 'r')
    data = yaml.load(stream,Loader=yaml.SafeLoader)
    data['metadata']['name']=cluster_name
    data['metadata']['region']=region_name
    data['vpc']['id']=vpc_id
    data['metadata']['version']=eks_version
    data['nodeGroups'][0]['iam']['attachPolicyARNs'][5]=arn_devtron_cluster_IAM_policy
    data['nodeGroups'][1]['iam']['attachPolicyARNs'][5]=arn_devtron_cluster_IAM_policy
    data['nodeGroups'][0]['ssh']['publicKeyName']=key_name
    data['nodeGroups'][1]['ssh']['publicKeyName']=key_name
    total_private=int(input("\nEnter total number of private subnets : "))
    private_subnets={}
    public_subnets={}
    for i in range(total_private):
        subnet_name=input("Subnet name : ")
        subnet_id=input("Subnet id of repective subnet : ")
        private_subnets[subnet_name]=subnet_id
    total_public=int(input("\nEnter total number of public subnets : "))
    for i in range(total_public):
        subnet_name=input("Subnet name : ")
        subnet_id=input("Subnet id of repective subnet: ")
        public_subnets[subnet_name]=subnet_id
    data['vpc']['subnets']['private']={}
    data['vpc']['subnets']['public']={}
    for key ,value in private_subnets.items():
        data['vpc']['subnets']['private'][key]={}
        data['vpc']['subnets']['private'][key]['id']=value
    for key ,value in public_subnets.items():
        data['vpc']['subnets']['public'][key]={}
        data['vpc']['subnets']['public'][key]['id']=value
    with open(filename, 'w') as yaml_file:
        yaml_file.write( yaml.dump(data, default_flow_style=False))
    
    print("\n Creating the eks cluster with configured values .....\n")
    os.system("eksctl create cluster -f eksctl-devtron-prod-configs.yaml")

#*********************************************************************************



is_eksctl=is_eksctl_installed()
if is_eksctl[0]==0:
    print(f"eksctl is already istalled with version {is_eksctl[1]}")
else:
    print("eksctl is not installed will do with latest version  ........")
    install_eksctl()

is_kubectl=is_kubectl_installed()
if is_kubectl[0]==0:
    print("kubectl is already installed")
else:
    print("kubectl client is not installed will do that.........")
    install_kubectl()

is_helm=is_helm_installed()
if is_helm[0]==0:
    print(f"Helm is already installed with version {is_helm[1]}")
else:
    print("Helm is not installed will do .......")
    install_helm()



print("******************************************************************")
cluster_name=input("cluster-name (Ex devtron-cluster): ")
region_name=input("region (Ex ap-south-1): ")
eks_version=input("k8s version (Ex 1.21, 1.22): ")
arn_devtron_cluster_IAM_policy=input("arn for cluster iam policy: ")
key_name=input("Key pair name (Will be attach to nodes): ")
print("\n******************************************************************")
is_create_vpc=input("Do you want to use your existing vpc(yes/no): ")
if is_create_vpc.lower()=='yes' or is_create_vpc.lower()=='y':
    create_eks_existing_vpc(cluster_name,region_name,eks_version,arn_devtron_cluster_IAM_policy,key_name)
elif is_create_vpc.lower()=='no' or is_create_vpc.lower()=='n':
    create_eks_new_vpc(cluster_name,region_name,eks_version,arn_devtron_cluster_IAM_policy,key_name)
else:
    print("\n Value provided are not supported")
    