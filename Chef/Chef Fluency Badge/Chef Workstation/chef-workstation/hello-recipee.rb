file "/home/ubuntu/hello.txt" do
  content "Hello World! Sam here"
  action :create
end

package "cowsay" do
  action :install
end
