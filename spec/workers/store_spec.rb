require 'rails_helper'

describe Store do
  let(:file) { Rails.root.join('spec', 'fixtures', 'ffmpeg_output') }
  before do
    allow_any_instance_of(Store).to receive(:ffmpeg_info).and_return(File.read(file))
  end

  describe '#medatata' do
    specify do
      expect(subject.send(:metadata).slice('title', 'artist')).to eq(
        'title' => 'Riders On the Storm',
        'artist' => 'The Doors'
      )
    end
  end

  describe '#duration' do
    specify do
      expect(subject.send(:duration)).to eq(427.27)
    end
  end

  describe '#check_patterns' do
    let(:track) { FactoryGirl.create(:track, title: 'Track name (instrumental)') }
    before do
      allow(subject).to receive(:track).and_return(track)
      subject.send(:check_patterns)
    end

    specify do
      expect(subject.send(:track).instrumental).to be true
    end
  end
end
