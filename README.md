## What?
S3watcher tool is written to track a files on AWS S3 buckets.
Mostly it is applicable for a buckets where you put files, but not delete. For example archives, backups.
The tool does listing of a bucket and stores a result to a database.
Then it compares the list of files seen recently to the previous scans.
Report includes a list of duplicated and missing files.

## Why?
AWS promises 99.999999999% of durability. In average it means that one billionth file will be lost.
But that depends on how data is spread. One client is lucky and does not lose anything but another client
loses two files. And so on. And that is so if the promise is correct.

## How?
The tool does listing of files on an bucket using ListBucket API call.
[AWS Docs](https://docs.aws.amazon.com/AmazonS3/latest/API/v2-RESTBucketGET.html)

#### IAM Policy
In assuming you are familiar with control access using IAM roles and policies,
just a policy is provided. You know what to do ;)
```
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "s3:ListBucket",
            "Resource": "arn:aws:s3:::*"
        }
    ]
}
```

#### Set up environment
S3watcher requires a relational database, for example MySQL.  
You need to create `config/database.yml` similar to Rails applications.  
Then install dependencies with `bundle install`  
Finally, initialize an database with `bundle exec rake db:setup`

#### Rake commands
Work with the tool is done using rake tasks.

* Add an bucket owner  
`bundle exec rake s3watcher:add_user[username,email,access_key,secret_key]`  
`username` and `email` are mandatory.  
`access_key` and `secret_key` are optional. User may have few buckets and if you have credentials
per user (applicable to all his buckets) you may set it here.

* Add an bucket  
`bundle exec rake s3watcher:add_bucket[email,bucket_name,region,access_key,secret_key]`  
`email`, `bucket_name` and `region` are mandatory.  
`access_key` and `secret_key` are optional, and if not set, the user credentials will be used.

* Scan an bucket  
`bundle exec rake s3watcher:scan_bucket[bucket_name]`  
`bucket_name` is mandatory.  
May take a while. Performance depends on your network channel and database write throughput.

* Get a report  
`bundle exec rake s3watcher:report[bucket_name]`  
`bucket_name` is mandatory.  
Reports about total used space, number of files and unique files, missing files from previous scan.
Example:  
```
Last scaned: 2018-04-16 10:06:58 UTC
Obtained space: 8.901 Gb
Number of files: 3777
Number of unique files: 3775
Duplications: 
1: "2004/2004_11_15 Day 1/2004-introduction.JPG", "2004/2004_11_15 Day 1/DSCN0182.JPG"
2: "2004/2004_11_15 Day 1/2004-friends.JPG", "2004/2004_11_15 Day 1/DSCN0191.JPG"
Missing files:
1435: "2002/2002_10_11/DCIM-015564.JPG"
```

* Acknowledge deleted file  
`bundle exec rake s3watcher:ack[file_id]`  
`file_id` is mandatory.  
Let the tool to forget about a given file. It requires interactive input to confirm. Example:  
```
$ bundle exec rake s3watcher:ack[1435]
Are you sure? "2002/2002_10_11/DCIM-015564.JPG" (7b626394d70b4c3b3b81d20ec8151031), bucket: example_bucket_name 
(yes): yes
```

## Author notes
I assume that make a commercial application from it is useless and there are few reasons:  
1. Almost all trust AWS in storing their files
2. No one wants to share even a list of files with an unknown people.
3. Other security reasons.

So this tool is written to be used personally or within a company.  
It may not cover all your use cases, so pull requests are welcome.

## License
MIT
