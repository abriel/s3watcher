module S3watcher
  class User < ActiveRecord::Base
    has_many :buckets
  end

  class Bucket < ActiveRecord::Base
    belongs_to :user
    has_many :s3files

    def used_space
      current_etags.sum(:size)
    end

    def used_space_h
      bytes = used_space.to_f
      res = nil
      %w(Kb Mb Gb Tb).each_with_index do |step, idx|
        res = bytes / (1024 ** (idx + 1))
        if res.to_s.split('.').first.length < 3
          return "#{res.round(3)} #{step}"
        end
      end
      return "#{res.round(3)} Tb"
    end

    def n_files
      current_etags.count
    end

    def n_files_uniq
      current_etags.distinct.count
    end

    def duplication
      current_etags.select(:key).group_by(&:etag).select { |k, v| v.size > 1 }
    end

    def current_etags
      s3files.where(presence: last_scaned).select(:etag)
    end

    def missing_files
      s3files.where('presence < ?', last_scaned).select(:etag, :key, :id)
    end
  end

  class S3file < ActiveRecord::Base
    belongs_to :bucket
  end
end
