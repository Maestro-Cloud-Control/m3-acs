## Resource datics

### Actions

#### :push
Adding to `datics` attribute group info about published service.\

#### :pull
Searching for services in the same region and project. List of services stored in `node.run_state['datics']` with structure:
```
{
    "service_name" => {
        "service_fqdn" => {
            "data_example"=>"there",
            "source"=>"service_nodename"
        }
    }
}
```

### Properties

#### service
Using as resource name. Is used as an identifier of the service to be published.

#### data
Hash with data to be published.
