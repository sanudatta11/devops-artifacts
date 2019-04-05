sudo chmod u+x /tmp/install-chef-server.sh
sudo /tmp/install-chef-server.sh

//For Windows
scp -i ~/.ssh/private_key ubuntu@ec2-54-235-228-159.compute-1.amazonaws.com:/drop/chefadmin.pem ~/learn-chef/.chef/chefadmin.pem

//Copy the Pem file from server to Workstation under .chef folder
//Then run this in Workstation

knife ssl fetch
knife ssl check

//Copy your cookbook my making a cookbook directory under root
//Then upload to server

knife cookbook upload learn_chef_apache2
knife cookbook list

//Run on Workstation
//With Pem File
knife bootstrap ADDRESS --ssh-user USER --sudo --identity-file IDENTITY_FILE --node-name node1-ubuntu --run-list 'recipe[learn_chef_apache2]'
knife bootstrap ec2-3-83-154-223.compute-1.amazonaws.com --ssh-user ubuntu --sudo --identity-file D:\Chef\chef-001.pem --node-name node1-ubuntu --run-list 'recipe[learn_chef_apache2]'

//Check node
knife node list

//Update cookbook
knife cookbook upload learn_chef_apache2

//Update from Workstation the node
knife ssh 'name:node1-ubuntu' 'sudo chef-client' --ssh-user ubuntu --ssh-identity-file D:\Chef\chef-001.pem --attribute ec2-3-83-154-223.compute-1.amazonaws.com