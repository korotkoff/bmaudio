class TrackDecorator < Draper::Decorator
  delegate_all

  CHUNK_SIZE = 60

  def playlist
    (object.duration / CHUNK_SIZE).ceil.times.map do |i|
      "/audio/#{object.id}/chunks/#{chunk_name(i)}"
    end
  end

  private

  def chunk_name(i)
    [i * CHUNK_SIZE, 'm4a'].join('.')
  end

  def self.collection_decorator_class
    PaginatingDecorator
  end
end
