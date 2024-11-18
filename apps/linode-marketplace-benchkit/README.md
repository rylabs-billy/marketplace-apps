# Linode Benchkit Deployment One-Click APP

Our benchmark Marketplace application provides a list tools designed to benchmark and analyze the performance of frontend applications under various loads and conditions. With these tools, developers and QA teams can conduct comprehensive stress, load, and endurance testing to ensure high-performance standards and resilience across web applications.

## Software Included

| Software  | Version   | Description   |
| :---      | :----     | :---          |
| Jmeter    | Latest    | A versatile, feature-rich tool designed for load testing and measuring web application performance, including support for complex test configurations. |
| K6    | Latest    |  A modern load-testing tool optimized for scripting complex test scenarios and measuring system performance under simulated user loads |
| Apache Benchmark    | 2.3    | A tool for benchmarking your Apache Hypertext Transfer Protocol (HTTP) server. It is designed to give you an impression of how your current Apache installation performs. This especially shows you how many requests per second your Apache installation is capable of serving. |
| Siege    | 4.0.7    | Siege is an open source regression test and benchmark utility. It can stress test a single URL with a user defined number of simulated users, or it can read many URLs into memory and stress them simultaneously. |
| Docker Community Edition    | Latest    | Container Management tool. |

**Supported Distributions:**

- Ubuntu 22.04 LTS

## Linode Helpers Included

| Name  | Action  |
| :---  | :---    |
| Hostname   | The Hostname module uses `dnsdomainname -A` to detect the Linode's FQDN and write to the `/etc/hosts` file. This defaults to the Linode's automatically assigned rDNS. To use a custom FQDN see [Configure your Linode for Reverse DNS](https://www.linode.com/docs/guides/configure-your-linode-for-reverse-dns/).  |
| Update Packages   | The Update Packages module performs apt update and upgrade actions as root.  |
| UFW   | The UFW module will utilize a list generated by `linode_helpers/ufw/ufwgen.yml` in the `group_vars/linode/vars` and enables the service.  |
| Fail2Ban   | The Fail2Ban module installs, activates and enables the Fail2Ban service.  |

## Use our API

Customers can choose to the deploy the Benchmark app through the Linode Marketplace or directly using API. Before using the commands below, you will need to create an [API token](https://www.linode.com/docs/products/tools/linode-api/get-started/#create-an-api-token) or configure [linode-cli](https://www.linode.com/products/cli/) on an environment.

Make sure that the following values are updated at the top of the code block before running the commands:
- TOKEN
- ROOT_PASS

SHELL:
```
export TOKEN="YOUR API TOKEN"
export ROOT_PASS="aComplexP@ssword"

curl -H "Content-Type: application/json" \
-H "Authorization: Bearer $TOKEN" \
-X POST -d '{
    "backups_enabled": true,
    "image": "linode/ubuntu22.04",
    "private_ip": true,
    "region": "us-southeast",
    "stackscript_data": {
        "user_name": "admin",
        "disable_root": "No"
    },
    "stackscript_id": 00000000000,
    "type": "g6-dedicated-4",
    "label": "label123",
    "root_pass": "${ROOT_PASS}",
    "authorized_users": [
        "myUser"
    ]
}' https://api.linode.com/v4/linode/instances
```

CLI:
```
export ROOT_PASS="aComplexP@ssword"

linode-cli linodes create \
  --backups_enabled true \
  --image 'linode/ubuntu22.04' \
  --private_ip true \
  --region us-southeast \
  --stackscript_data '{"user_name": "admin","disable_root":"No"}' \
  --stackscript_id 00000000000 \
  --type g6-dedicated-4 \
  --label label123 \
  --root_pass "${ROOT_PASS}" \
  --authorized_users myUser
```

## Resources

- [Create Linode via API](https://www.linode.com/docs/api/linode-instances/#linode-create)
- [Stackscript referece](https://www.linode.com/docs/guides/writing-scripts-for-use-with-linode-stackscripts-a-tutorial/#user-defined-fields-udfs)
