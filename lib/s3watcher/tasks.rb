namespace :s3watcher do
  desc 'Add an user'
  task :add_user, [:username, :email, :access_key, :secret_key] => :environment do |t, args|
    u = S3watcher::User.find_or_create_by(email: args.email)
    u.name = args.username
    u.access_key = args.access_key
    u.secret_key = args.secret_key
    u.save
  end

  desc 'Add an s3 bucket'
  task :add_bucket, [:email, :bucket_name, :region, :access_key, :secret_key] => :environment do |t, args|
    u = S3watcher::User.where(email: args.email).first
    u.nil? && raise(ArgumentError, "User #{args.email} does not exist")

    b = S3watcher::Bucket.find_or_create_by(name: args.bucket_name)
    b.user && b.user != u && raise(ArgumentError, "Bucket #{args.bucket_name} does not belong to #{args.email}")

    b.user = u
    b.access_key = args.access_key
    b.secret_key = args.secret_key
    b.region = args.region
    b.save
  end

  desc 'List managed buckets'
  task list_buckets: :environment do |t|
    S3watcher::Bucket.all.each do |x|
      puts "#{x.name}: user: #{x.user.name}, region: #{x.region}, " \
           "access_key: #{x.access_key.inspect}, secret_key: #{x.secret_key.inspect}"
    end
  end

  desc 'List users'
  task list_users: :environment do |t|
    S3watcher::User.all.each do |x|
      puts "#{x.name} (#{x.email}), access_key: #{x.access_key.inspect} " \
           "secret_key: #{x.secret_key.inspect}"
    end
  end

  desc 'Scan an bucket'
  task :scan_bucket, [:bucket_name] => :environment do |t, args|
    b = S3watcher::Bucket.where(name: args.bucket_name).first
    b.nil? && raise(ArgumentError, "Bucket #{args.bucket_name} does not exist")

    b.last_scaned && b.scan_period \
    && b.last_scaned + b.scan_period > Time.now && return

    api = Aws::S3::Client.new(
      region: b.region,
      credentials: Aws::Credentials.new(
        b.access_key || b.user.access_key, b.secret_key || b.user.secret_key
      )
    )

    scan_started_at = Time.now
    marker = nil
    loop do
      api.list_objects_v2(
        bucket: b.name,
        continuation_token: marker
      ).tap do |resp|
        marker = resp.is_truncated ? resp.next_continuation_token : nil
      end.contents.each do |x|
        next if x.size == 0

        s3file = b.s3files.find_or_create_by(etag: x.etag, key: x.key)
        s3file.size = x.size
        s3file.last_modified = x.last_modified
        s3file.presence = scan_started_at
        s3file.save
      end

      break if marker.nil?
    end

    b.last_scaned = scan_started_at
    b.save
  end

  desc 'Report about an bucket'
  task :report, [:bucket_name] => :environment do |t, args|
    b = S3watcher::Bucket.where(name: args.bucket_name).first
    b.nil? && raise(ArgumentError, "Bucket #{args.bucket_name} does not exist")

    report = "Last scaned: #{b.last_scaned}\n" \
             "Obtained space: #{b.used_space_h}\n" \
             "Number of files: #{b.n_files}\n" \
             "Number of unique files: #{b.n_files_uniq}\n"

    unless (r = b.duplication).empty?
      report += "Duplications: \n"
      r.values.each_with_index do |x, idx|
        report += "#{idx + 1}: " + x.map(&:key).map(&:inspect).join(', ') + "\n"
      end
    end

    unless (r = b.missing_files).empty?
      report += "Missing files: \n"
      r.each do |x|
        report += "#{x.id}: #{x.key.inspect} (#{JSON.parse(x.etag)})\n"
      end
    end

    puts report
  end

  desc 'Acknowledge missing file'
  task :ack, [:file_id] => :environment do |t, args|
    f = S3watcher::S3file.where(id: args.file_id).first
    f.nil? && raise(ArgumentError, "File with id #{args.file_id} not found")
    print "Are you sure? #{f.key.inspect} (#{JSON.parse(f.etag)}), bucket: #{f.bucket.name} \n(yes): "
    if STDIN.gets.strip == 'yes'
      f.destroy
      puts "Destroyed."
    end
  end
end
