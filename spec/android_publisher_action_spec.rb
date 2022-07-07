describe Fastlane::Actions::AndroidPublisherAction do
  describe '#run' do
    it 'prints a message' do
      expect(Fastlane::UI).to receive(:message).with("The android_publisher plugin is working!")

      Fastlane::Actions::AndroidPublisherAction.run(nil)
    end
  end
end
