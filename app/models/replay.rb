require 'zip/zip'

class Replay < ActiveRecord::Base
  belongs_to :category
  belongs_to :user
  has_many :comments, :order => 'created_at DESC'
  attr_accessible :description, :league, :players, :protoss, :terran, :title, :zerg, :replay_file, :category_id, :status

  LEAGUES = %w{bronze silver gold platinum diamond master grand_master}
  PLAYERS = %w{1v1 2v2 3v3 4v4 FFA}
  STATUSES = %w{new rejected suggested broadcasted}
  EXPIRY_DAYS = 14
  WEEKLY_UPLOAD_LIMIT = 3

  DEFAULT_FILTERS = {
    :page => 1, 
    :statuses => %w{new suggested},
    :query => '', 
    :league => '', 
    :players => '',
    :category_id => '',
    :include_expired => false,
    :rating => ''
  }

  mount_uploader :replay_file, ReplayFileUploader

  validates :replay_file, :presence => true
  validates :title,       :presence => true
  validates :category_id, :presence => true
  validates :user_id,     :presence => true
  validates :expires_at,  :presence => true
  validates :players,     :presence => true, :inclusion => { :in => PLAYERS }
  validates :league,      :presence => true, :inclusion => { :in => LEAGUES }
  validates :status,      :presence => true, :inclusion => { :in => STATUSES }
  validate :disallow_3_races_in_1v1

  def disallow_3_races_in_1v1
    if players == '1v1' && zerg? && terran? && protoss?
      errors.add(:players, "can't have all 3 races in a 1v1 game")
    end
  end

  def expired?
    expires_at < DateTime.now.utc
  end

  def filename
    File.basename(self.replay_file.to_s)
  end

  def update_average_rating
    self.average_rating = self.comments.average(:rating)
    self.save
  end

  def self.all_paged(options = {})
    options = options.reverse_merge(DEFAULT_FILTERS)

    query = "%#{options[:query]}%"
    replays = self.paginate(:page => options[:page], :per_page => 25).order('created_at DESC')
    replays = replays.where('title ilike ? or description ilike ? or replay_file ilike ?', query, query, query) if options[:query].present?
    replays = replays.where('status in (?)', options[:statuses]) if options[:statuses].present?
    replays = replays.where(:league => options[:league]) if options[:league].present?
    replays = replays.where(:players => options[:players]) if options[:players].present?
    replays = replays.where(:category_id => options[:category_id]) if options[:category_id].present?
    if options[:rating].present?
      if options[:rating].to_i == 0
        replays = replays.where('average_rating = ?', options[:rating])
      else
        replays = replays.where('average_rating >= ?', options[:rating])
      end
    end

    unless options[:include_expired]
      replays = replays.where("expires_at > ?", DateTime.now.utc)
    end

    replays
  end

  def self.zip_replay_files(ids)
    replays = self.find(ids)
    buffer = Zip::ZipOutputStream::write_buffer do |zip|
      replays.each do |replay|
        zip.put_next_entry("#{replay.id}-#{replay.filename}")
        zip.write File.read(replay.replay_file.current_path)
      end
    end
    buffer.rewind
    return buffer.sysread
  end

  def self.bulk_change_status(ids, new_status)
    replays = self.find(ids)
    replays.each do |replay|
      replay.status = new_status
      replay.save
    end
  end
end
