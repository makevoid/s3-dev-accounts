### s3-dev-accounts

Simple script to create S3 Dev account with a predefined bucket policy

### Setup

- Make sure you have the `aws` AWS CLI installed and configured (working with a profile loaded, e.g. `default`)

- Copy the accounts configuration default file

```sh
cp accounts.default.yml accounts.yml
```

Edit the configuration file (`accounts.yml`) with your desired account names

Modify `lib/config` to make sure the region and the profile match the region you want the S3 Bucket to be created in and the profile to be used (e.g. `default`)

### Run

    rake

---

Feel free to clone and/or fork the repo.

Cheers,

@makevoid
