opsworks-update-ruby
================

OpsWorks ruby cookbook for Amazon Linux to update ruby version.

## Installation instructions

Add this cookbook to your list of Custom Cookbooks

### Sample Chef JSON configuration

```json
{
  "ruby": {
    "update_version": "2.4.2"
  }
}
```

If configuration is not set, default ruby version is set to "2.4.2".