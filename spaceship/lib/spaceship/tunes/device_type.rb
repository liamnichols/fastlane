module Spaceship
  module Tunes
    # identifiers of devices that App Store Connect accepts screenshots for
    class DeviceType

      attr_accessor :identifier, :name, :category, :screenshot_resolutions, :supports_imessage_screenshots

      def initialize(data)
        @identifier = data["identifier"]
        @name = data["name"]
        @category = data["category"]
        @screenshot_resolutions = data["screenshot_resolutions"]
        @supports_imessage_screenshots = data["supports_imessage_screenshots"]
      end

      class << self

        def types
          device_types.keys
        end

        def exists?(type)
          !device_types[type].nil?
        end

        def device_types
          @device_types ||= JSON.parse(File.read(File.join(Spaceship::ROOT, "lib", "assets", "deviceTypes.json"))).map { |data| [data["identifier"], DeviceType.new(data)] }.to_h
        end
      end
    end
  end
end
