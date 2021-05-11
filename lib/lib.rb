module Lib

  def exe(cmd)
    puts "executing: #{cmd}"
    out = %x{#{cmd}}
    puts out
    out
  end

  def accounts
    accs = YAML.load_file ACCOUNTS_CONF_PATH
    accs.fetch :accounts
  end

  def user_accounts
    accs = accounts
    puts "users: #{accs.join ","}"
    accs
  end

  def iam_create_user(username:)
    exe "aws iam create-user --user-name #{username} --profile #{AWS_PROFILE}"
  end

  def iam_create_user_key(username:)
    exe "aws iam create-access-key --user-name #{username} --profile #{AWS_PROFILE}"
  end

  def s3_create_bucket(bucket_name:)
    exe "aws s3api create-bucket --bucket #{bucket_name} --region #{S3_BUCKET_REGION} --create-bucket-configuration LocationConstraint=#{S3_BUCKET_REGION} --profile #{AWS_PROFILE}"
  end

  def create_bucket_policy_file(file_path:, user_arn:, bucket_name:)
    contents = {
      "Version" => "2012-10-17",
      "Id" => "Policy1619170636096",
      "Statement" => [
          {
              "Sid" => "Stmt1619170633479",
              "Effect" => "Allow",
              "Principal" => {
                  "AWS" => user_arn
              },
              "Action" => "s3:*",
              "Resource" => "arn:aws:s3:::#{bucket_name}"
          }, {
              "Sid" => "Stmt1619170633479",
              "Effect" => "Allow",
              "Principal" => {
                  "AWS" => user_arn
              },
              "Action" => "s3:*",
              "Resource" => "arn:aws:s3:::#{bucket_name}/*"
          }
      ]
    }.to_json

    File.open(file_path, "w") do |file|
      file.write contents
    end
  end

  def s3_set_bucket_policy(bucket_name:, user_arn:)
    policy_file = File.expand_path "./bucket_policies/#{bucket_name}.json"
    create_bucket_policy_file file_path: policy_file, user_arn: user_arn, bucket_name: bucket_name
    exe "aws s3api put-bucket-policy --bucket #{bucket_name} --policy file://#{policy_file} --profile #{AWS_PROFILE}"
  end

  def create_users
    s3_users = []
    user_accounts.each do |user|
      resp = iam_create_user username: user
      resp = JSON.parse resp
      resp_user = resp.f "User"
      user_arn  = resp_user.f "Arn"
      s3_users << {
        username:     user,
        bucket_name:  user,
        arn:          user_arn,
      }
    end
    s3_users
  end

  def create_user_keys(s3_users:)
    s3_users.each do |user|
      username = user.f :username
      resp = iam_create_user_key username: username
      resp = JSON.parse resp
      resp_user   = resp.f      "AccessKey"
      key_id      = resp_user.f "AccessKeyId"
      key_secret  = resp_user.f "SecretAccessKey"
      user[:key_id]     = key_id
      user[:key_secret] = key_secret
    end
  end

  def create_s3_buckets(s3_users:)
    s3_users.each do |user|
      bucket    = user.f :bucket_name
      user_arn  = user.f :arn
      s3_create_bucket bucket_name: bucket
      sleep AWS_IAM_USER_PRINCIPAL_TIMEOUT # some time is required to update the user IAM ARN
      s3_set_bucket_policy bucket_name: bucket, user_arn: user_arn
    end
  end

end
