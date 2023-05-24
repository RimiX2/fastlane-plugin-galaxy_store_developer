describe Fastlane::Actions::GalaxyStoreDeveloperUpload do
  describe '#run' do
    it 'prints a message' do
      expect(Fastlane::UI).to receive(:message).with("The galaxy_store_developer plugin is working!")

      Fastlane::Actions::GalaxyStoreDeveloperUpload.run(nil)
    end
  end
end
