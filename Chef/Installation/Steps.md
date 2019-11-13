# Workstation Setup
```
sudo apt-get update
sudo apt-get -y install curl
curl https://omnitruck.chef.io/install.sh | sudo bash -s -- -P chef-workstation -c stable -v 0.2.41
sudo apt-get install nano --yes
```

## Server Setup
```
echo $(curl -s http://169.254.169.254/latest/meta-data/public-hostname) | xargs sudo hostname
wget -P /downloads https://packages.chef.io/files/stable/chef-server/13.0.17/ubuntu/18.04/chef-server-core_13.0.17-1_amd64.deb
dpkg -i /downloads/chef-server-core_13.0.17-1_amd64.deb
chef-server-ctl user-create chefadmin Chef Admin admin@4thcoffee.com password --filename /drop/chefadmin.pem
chef-server-ctl org-create 4thcoffee "Fourth Coffee, Inc." --association_user chefadmin --filename 4thcoffee-validator.pem
```

### Using Chef Manage
```
chef-server-ctl install chef-manage
chef-server-ctl reconfigure
chef-manage-ctl reconfigure
```

Downlad Starter Kit

### Upload Cookbook
```
knife cookbook upload <COOKBOOK_NAME>
```

### Correct SSL Error for Private IP

Chef's documentation used to have steps to correct this issue, but since the time I initially answered this question they have removed those steps from their tutorial. The following steps worked for me with Chef 12, Ubuntu 16 on an ec2 instance.

1. ssh onto your chef server
2. open your hostname file with the following command sudo vim /etc/hostname
3. remove the line containing you internal ip and replace it with your public ip and save the file.
4. reboot the server with sudo reboot
5. run sudo chef-server-ctl reconfigure (this signs a new certificate, among other things)
6. Go back to your workstation and use knife ssl fetch followed by knife ssl check and you should be good to go.

## Bootstrap Node
```
knife bootstrap 18.219.36.38 --ssh-user ubuntu --sudo -i ~/Documents/ssh-key-isengard.pem --node-name node1-ubuntu --run-list 'recipe[learn_chef_apache2]'
knife bootstrap 18.222.106.235 --ssh-user ubuntu --sudo -i ~/Documents/ssh-key-isengard.pem --node-name node2-ubuntu --run-list 'recipe[learn_chef_apache2]'
knife bootstrap 18.189.141.140 --ssh-user ubuntu --sudo -i ~/Documents/ssh-key-isengard.pem --node-name node3-ubuntu --run-list 'recipe[learn_chef_apache2]'
```

### Update Node Using Chef Client
```
knife ssh 'name:node1-ubuntu' 'sudo chef-client' --ssh-user ubuntu -i ~/Documents/ssh-key-isengard.pem --attribute 18.219.36.38
```

## Finalizing Node Settings

Adding auto chef-client cron job for periodic updates from Chef Server.

### Adding Chef Client as a Dependent Cookbook to Original Cookbook
```
cd ~/learn-chef
```

Contents of Berksfile ~/<cookbook>/Berksfile

```
source 'https://supermarket.chef.io'
cookbook 'chef-client'
```

Now we need to upload the cookbook using Berks as knife cookbook upload uploads only a single cookbook to Chef Server
Inside ~/<cookbook>
Run

```
berks upload
```

### Adding a Role to Node Run-list

https://learn.chef.io/modules/manage-a-node-chef-server/ubuntu/bring-your-own-system/run-chef-client-periodically#/

Now that the chef-client cookbook is on your Chef server, you need to update your node's run-list to use it. You also need to specify how often to run chef-client. In this part, you'll use a role to define both.

How often chef-client is run is controlled by two node attributes (source code):

```node['chef_client']['interval']``` – interval specifies the number of seconds between chef-client runs. The default value is 1,800 (30 minutes).
```node['chef_client']['splay']``` – splay specifies a maximum random number of seconds that is added to the interval. Splay helps balance the load on the Chef server by ensuring that many chef-client runs are not occurring at the same interval. The default value is 300 (5 minutes).
By default, chef-client will run every 30—35 minutes on your node. In practice, the values you choose depend on your requirements. For learning purposes, you'll specify an interval of 5 minutes (300 seconds) and a splay of 1 minute (60 seconds), causing your node to check in every 5—6 minutes.

To update your node's run-list, you could use the knife node run_list set command. However, that does not set the appropriate node attributes.

To accomplish both tasks, you'll use a role. Roles enable you to focus on the function your node performs collectively rather than each of its individual components (its run-list, node attributes, and so on). For example, you might have a web server role, a database role, or a load balancer role. Here, you'll create a role named web to define your node's function as a web server.

Roles are stored as objects on the Chef server. To create a role, you can use the knife role create command. Another common way is to create a file (in JSON format) that describes your role and then run the knife role from file command to upload that file to the Chef server. The advantage of creating a file is that you can store that file in a version control system such as Git.

First, ensure you have a directory named ~/learn-chef/roles.

Add web.json

```
{
   "name": "web",
   "description": "Web server role.",
   "json_class": "Chef::Role",
   "default_attributes": {
     "chef_client": {
       "interval": 300,
       "splay": 60
     }
   },
   "override_attributes": {
   },
   "chef_type": "role",
   "run_list": ["recipe[chef-client::default]",
                "recipe[chef-client::delete_validation]",
                "recipe[learn_chef_apache2::default]"
   ],
   "env_run_lists": {
   }
}
```

Next, run the following ```knife role from file``` command to upload your role to the Chef server.

```knife role from file roles/web.json```

For verification

```knife role list```
```knife role show web```

### Adding Role to Node

The final step is to set your node's run-list. Run the following ```knife node run_list``` set command to do that.

```knife node run_list set node1-ubuntu "role[web]"```


As a verification step, you can run the ```knife node show``` command to view your node's run-list.

```knife node show node1-ubuntu --run-list```

### Running Chef Client for Propogate

Run the following by changing the ip address of each node

```knife ssh 'role:web' 'sudo chef-client' --ssh-user ubuntu -i ~/Documents/ssh-key-isengard.pem --attribute 18.189.141.140```

### Final Checking

```knife status 'role:web' --run-list```