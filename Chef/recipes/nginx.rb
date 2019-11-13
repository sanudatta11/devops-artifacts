package "nginx"

service "nginx" do
  action [:enable, :start]
end

file "/usr/share/nginx/html/index.html" do
  content "<h1>Hello, world!</h1>"
  action :create
  not_if { ::File.exists?("/usr/share/nginx/html/index.html") }
end