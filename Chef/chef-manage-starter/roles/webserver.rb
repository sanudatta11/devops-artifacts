name "webserver"
description "A role for webservers"
run_list "recipe[mychef_client]", "recipe[apache]"
default_attributes({
  "company" => {
    "name" => "Roles Inc",
  },
})
