class Split < ActiveJob::Base
  queue_as :default

  after_perform :store

  CHUNK_SIZE = 60

  attr_reader :path

  def perform(path)
    @path = path

    FileUtils.mkdir_p(chunks_dir)

    number_of_chunks.times do |i|
      transcode(from(i), to(i))
    end
  end

  private

  def store
    Store.perform_later(path)
  end

  def file
    @file ||= FFMPEG::Movie.new(path)
  end

  def chunk_name(i)
    chunks_dir.join("#{i}.m4a")
  end

  def chunks_dir
    Pathname.new(File.dirname(path)).join('chunks')
  end

  def duration
    @duration ||= file.duration
  end

  def number_of_chunks
    (duration / CHUNK_SIZE).ceil
  end

  def from(step)
    step * CHUNK_SIZE
  end

  def to(step)
    [from(step) + CHUNK_SIZE, duration].min
  end

  def transcode(from, to, force = false)
    return if !force && File.exist?(chunk_name(from))

    file.transcode(chunk_name(from), "-ss #{from} -to #{to}")
  end
end
