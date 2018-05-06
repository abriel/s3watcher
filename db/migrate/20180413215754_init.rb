class Init < ActiveRecord::Migration[5.1]
  def change
    create_table(:users, options: 'ENGINE=InnoDB DEFAULT CHARSET=utf8') do |t|
      t.string :access_key, null: true
      t.string :secret_key, null: true
      t.string :name
      t.string :email
    end

    create_table(:buckets, options: 'ENGINE=InnoDB DEFAULT CHARSET=utf8') do |t|
      t.references :user, foreign_key: { on_delete: :cascade }
      t.string :name
      t.string :access_key, null: true
      t.string :secret_key, null: true
      t.string :region
      t.datetime :last_scaned
      t.integer :scan_period
    end

    create_table(:s3files, options: 'ENGINE=InnoDB DEFAULT CHARSET=utf8') do |t|
      t.references :bucket, foreign_key: { on_delete: :cascade }
      t.string :etag, index: true
      t.bigint :size
      t.string :key, index: true
      t.datetime :last_modified
      t.datetime :presence, index: true
    end
  end
end
