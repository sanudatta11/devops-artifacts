current_dir = File.dirname(__FILE__)
log_level :info
log_location STDOUT
node_name "chefadmin"
client_key "#{current_dir}/chefadmin.pem"
chef_server_url "https://ec2-3-88-173-172.compute-1.amazonaws.com/organizations/4thcoffee"
cookbook_path ["#{current_dir}/../cookbooks"]
