berks install
berks upload --no-ssl-verify
knife role from file roles/web.json
knife role list
knife role show web
knife node run_list set node1-ubuntu "role[web]"
knife node show node1-ubuntu --run-list
knife ssh 'role:web' 'sudo chef-client' --ssh-user ubuntu --ssh-identity-file D:\Chef\chef-001.pem --attribute 3.83.154.223
knife status 'role:web' --run-list

knife role delete web --yes

//For Re Boostrap Delete the Chef pem
sudo rm /etc/chef/client.pem