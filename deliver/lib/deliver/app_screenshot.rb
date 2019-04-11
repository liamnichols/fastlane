require 'fastimage'
require 'spaceship/tunes/device_type'

require_relative 'module'

module Deliver
  # AppScreenshot represents one screenshots for one specific locale and
  # device type.
  class AppScreenshot
    #
    module ScreenSize
      # iPhone 4
      IOS_35 = "iOS-3.5-in"
      # iPhone 5
      IOS_40 = "iOS-4-in"
      # iPhone 6, 7, & 8
      IOS_47 = "iOS-4.7-in"
      # iPhone 6 Plus, 7 Plus, & 8 Plus
      IOS_55 = "iOS-5.5-in"
      # iPhone XS
      IOS_58 = "iOS-5.8-in"
      # iPhone XR
      IOS_61 = "iOS-6.1-in"
      # iPhone XS Max
      IOS_65 = "iOS-6.5-in"

      # iPad
      IOS_IPAD = "iOS-iPad"
      # iPad 10.5
      IOS_IPAD_10_5 = "iOS-iPad-10.5"
      # iPad 11
      IOS_IPAD_11 = "iOS-iPad-11"
      # iPad Pro
      IOS_IPAD_PRO = "iOS-iPad-Pro"

      # Apple Watch
      IOS_APPLE_WATCH = "iOS-Apple-Watch"
      # Apple Watch Series 4
      IOS_APPLE_WATCH_SERIES4 = "iOS-Apple-Watch-Series4"

      # Apple TV
      APPLE_TV = "Apple-TV"

      # Mac
      MAC = "Mac"
    end

    # @return [Deliver::ScreenSize] the screen size (device type)
    #  specified at {Deliver::ScreenSize}
    attr_accessor :screen_size

    attr_accessor :path

    attr_accessor :language

    attr_accessor :is_messages

    attr_accessor :device_type

    # @param path (String) path to the screenshot file
    # @param language (String) Language of this screenshot (e.g. English)
    # @param screen_size (Deliver::AppScreenshot::ScreenSize) the screen size, which
    #  will automatically be calculated when you don't set it.
    def initialize(path, language, screen_size, device_type, is_messages)
      self.path = path
      self.language = language
      self.screen_size = screen_size
      self.device_type = device_type
      self.is_messages = is_messages

      UI.user_error!("The Screenshot '#{path}' does not match the requirements of #{screen_size}") unless self.is_valid?
    end

    # Nice name
    def formatted_name
      # This list does not include iPad Pro 12.9-inch (3rd generation)
      # because it has same resoluation as IOS_IPAD_PRO and will clobber
      matching = {
        ScreenSize::IOS_35 => "iPhone 4",
        ScreenSize::IOS_40 => "iPhone 5",
        ScreenSize::IOS_47 => "iPhone 6", # and 7
        ScreenSize::IOS_55 => "iPhone 6 Plus", # and 7 Plus
        ScreenSize::IOS_58 => "iPhone XS",
        ScreenSize::IOS_61 => "iPhone XR",
        ScreenSize::IOS_65 => "iPhone XS Max",
        ScreenSize::IOS_IPAD => "iPad",
        ScreenSize::IOS_IPAD_10_5 => "iPad 10.5",
        ScreenSize::IOS_IPAD_11 => "iPad 11",
        ScreenSize::IOS_IPAD_PRO => "iPad Pro",
        ScreenSize::MAC => "Mac",
        ScreenSize::IOS_APPLE_WATCH => "Watch",
        ScreenSize::IOS_APPLE_WATCH_SERIES4 => "Watch Series4",
        ScreenSize::APPLE_TV => "Apple TV"
      }

      if is_messages
        "#{matching[self.screen_size]} (iMessage)"
      else
        matching[self.screen_size]
      end
    end

    # Validates the given screenshots (size and format)
    def is_valid?
      return false unless ["png", "PNG", "jpg", "JPG", "jpeg", "JPEG"].include?(self.path.split(".").last)
      return false if is_messages && !Spaceship::Tunes::DeviceType.device_types[device_type].supports_imessage_screenshots
      return !screen_size.nil?
    end

    def self.screen_resolution_map
      device_types = Spaceship::Tunes::DeviceType.device_types
      return {
        ScreenSize::IOS_65 => device_types["iphone65"].screenshot_resolutions,
        ScreenSize::IOS_61 => [[828, 1792], [1792, 828]], # iPhone XR does not exist in Spaceship/App Store Connect
        ScreenSize::IOS_58 => device_types["iphone58"].screenshot_resolutions,
        ScreenSize::IOS_55 => device_types["iphone6Plus"].screenshot_resolutions,
        ScreenSize::IOS_47 => device_types["iphone6"].screenshot_resolutions,
        ScreenSize::IOS_40 => device_types["iphone4"].screenshot_resolutions,
        ScreenSize::IOS_35 => device_types["iphone35"].screenshot_resolutions,
        ScreenSize::IOS_IPAD => device_types["ipad"].screenshot_resolutions,
        ScreenSize::IOS_IPAD_10_5 => device_types["ipad105"].screenshot_resolutions,
        ScreenSize::IOS_IPAD_11 => device_types["ipadPro11"].screenshot_resolutions,
        ScreenSize::IOS_IPAD_PRO => device_types["ipadPro"].screenshot_resolutions,
        ScreenSize::MAC => device_types["desktop"].screenshot_resolutions,
        ScreenSize::IOS_APPLE_WATCH => device_types["watch"].screenshot_resolutions,
        ScreenSize::IOS_APPLE_WATCH_SERIES4 => device_types["watchSeries4"].screenshot_resolutions,
        ScreenSize::APPLE_TV => device_types["appleTV"].screenshot_resolutions
      }
    end

    def self.device_type_for_screen_size(screen_size)
      # This list does not include iPad Pro 12.9-inch (3rd generation)
      # because it has same resoluation as IOS_IPAD_PRO and will clobber
      matching = {
        ScreenSize::IOS_35 => "iphone35",
        ScreenSize::IOS_40 => "iphone4",
        ScreenSize::IOS_47 => "iphone6", # also 7 and 8
        ScreenSize::IOS_55 => "iphone6Plus", # also 7 Plus & 8 Plus
        ScreenSize::IOS_58 => "iphone58",
        ScreenSize::IOS_65 => "iphone65",
        ScreenSize::IOS_IPAD => "ipad",
        ScreenSize::IOS_IPAD_10_5 => "ipad105",
        ScreenSize::IOS_IPAD_11 => "ipadPro11",
        ScreenSize::IOS_IPAD_PRO => "ipadPro",
        ScreenSize::MAC => "desktop",
        ScreenSize::IOS_APPLE_WATCH => "watch",
        ScreenSize::IOS_APPLE_WATCH_SERIES4 => "watchSeries4",
        ScreenSize::APPLE_TV => "appleTV"
      }
      return matching[screen_size]
    end

    def self.screen_size_for_device_type(device_type)
      matching = {
        "iphone35" => ScreenSize::IOS_35,
        "iphone4" => ScreenSize::IOS_40,
        "iphone6" => ScreenSize::IOS_47,
        "iphone6Plus" => ScreenSize::IOS_55,
        "iphone58" => ScreenSize::IOS_58,
        "iphone65" => ScreenSize::IOS_65,
        "ipad" => ScreenSize::IOS_IPAD,
        "ipad105" => ScreenSize::IOS_IPAD_10_5,
        "ipadPro11" => ScreenSize::IOS_IPAD_11,
        "ipadPro" => ScreenSize::IOS_IPAD_PRO,
        "ipadPro129" => ScreenSize::IOS_IPAD_PRO,
        "desktop" => ScreenSize::MAC,
        "desktop" => ScreenSize::IOS_APPLE_WATCH,
        "watchSeries4" => ScreenSize::IOS_APPLE_WATCH_SERIES4,
        "appleTV" => ScreenSize::APPLE_TV
      }
      return matching[device_type]
    end

    def self.calculate_screen_size(path)
      size = FastImage.size(path)

      UI.user_error!("Could not find or parse file at path '#{path}'") if size.nil? || size.count == 0

      self.screen_resolution_map.each do |screen_size, resolutions|
        resolutions.each do |resolution|
          if size[0] == (resolution[0]) && size[1] == (resolution[1])
            return screen_size
          end
        end
      end

      UI.user_error!("Unsupported screen size #{size} for path '#{path}'")
    end
  end

  ScreenSize = AppScreenshot::ScreenSize
end
