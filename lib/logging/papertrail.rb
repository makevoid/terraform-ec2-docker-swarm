require_relative 'env'

API_TOKEN = "xxxxxxxxxxxxxxxxxxxxx"
STACK_NAME = "env-01"

headers = {
  :"X-Papertrail-Token" => API_TOKEN,
}

create_group_url = "https://papertrailapp.com/api/v1/groups.json"

create_group_payload = {
  "group" => {
    "name" => STACK_NAME,
    # "system_wildcard" => "*antani*",
  }
}

options = {
	body: create_group_payload,
  headers: headers,
}

res = HTTParty.post create_group_url, options
p res

#
# query log dest available
#
# logs5.papertrailapp.com:26123
# log-dest-01
#
# logs4.papertrailapp.com:23581
# log-dest-02
#
# logs3.papertrailapp.com:44347
# log-dest-03
