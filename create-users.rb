require_relative 'lib/env'

def main
  s3_users = create_users
  s3_users = create_user_keys   s3_users: s3_users
  s3_users = create_s3_buckets  s3_users: s3_users

  p s3_users
  puts "-"*80
  puts s3_users.to_yaml
end

main
