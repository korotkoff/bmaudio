class Store < ActiveJob::Base
  queue_as :default

  PATTERNS = {
    instrumental: %w(instrumental инструментал),
    cover: %w(cover кавер)
  }

  def perform(path)
    @path = path

    track.duration = duration

    metadata.each do |key, value|
      track.send("#{key}=", value) if track.respond_to?(key)
    end

    check_patterns

    track.save

    store
  end

  private

  def check_patterns
    PATTERNS.each do |key, values|
      values.each do |pattern|
        track.send("#{key}=", true) if track.title.to_s.include?(pattern)
      end
    end
  end

  def store
    store_path = Rails.root.join('public/audio/', track.id.to_s)
    FileUtils.mkdir_p(store_path)
    FileUtils.mv(File.dirname(@path).to_s + '/chunks', store_path.to_s)
    FileUtils.mv(@path, store_path)
  end

  def metadata
    plaintext_metadata = ffmpeg_info.match(/Metadata:(.*)Duration:/m)[1]
    Hash[plaintext_metadata.split(/\n/).map { |s| s.split(':').map(&:strip) }.select { |s| s.size == 2 }]
  end

  def duration
    plaintext_duration = ffmpeg_info.match(/Duration: (\d{2}):(\d{2}):(\d{2}\.\d{2})/)
    (plaintext_duration[1].to_i.hours) + (plaintext_duration[2].to_i.minutes) + plaintext_duration[3].to_f.seconds
  end

  def ffmpeg_info
    @ffmpeg_info ||= begin
      command = "#{FFMPEG.ffmpeg_binary} -i #{@path}"
      Open3.popen3(command) { |_stdin, _stdout, stderr| stderr.read }
    end
  end

  def track
    @track ||= Track.new
  end
end
