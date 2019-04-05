chef generate cookbook cookbooks/learn_chef_apache2
chef generate template cookbooks/learn_chef_apache2 index.html
sudo chef-client --local-mode --runlist 'recipe[learn_chef_apache2]'