require 'deliver/app_screenshot'

# Ensure that screenshots correctly map to the following:
# https://help.apple.com/app-store-connect/#/devd274dd925
describe Deliver::AppScreenshot do
  def screen_size_from(path)
    path.match(/{([0-9]+)x([0-9]+)}/).captures.map(&:to_i)
  end
  before do
    allow(FastImage).to receive(:size) do |path|
      screen_size_from(path)
    end
  end

  describe "valid screen size calculations" do
    def expect_screen_size_from_file(file)
      expect(Deliver::AppScreenshot.calculate_screen_size(file))
    end

    it "should calculate all 6.5 inch iPhone resolutions" do
      expect_screen_size_from_file("iPhoneXSMax-Portrait{1242x2688}.jpg").to eq(Deliver::AppScreenshot::ScreenSize::IOS_65)
      expect_screen_size_from_file("iPhoneXSMax-Landscape{2688x1242}.jpg").to eq(Deliver::AppScreenshot::ScreenSize::IOS_65)
    end

    it "should calculate all 5.8 inch iPhone resolutions" do
      expect_screen_size_from_file("iPhoneXS-Portrait{1125x2436}.jpg").to eq(Deliver::AppScreenshot::ScreenSize::IOS_58)
      expect_screen_size_from_file("iPhoneXS-Landscape{2436x1125}.jpg").to eq(Deliver::AppScreenshot::ScreenSize::IOS_58)
    end

    it "should calculate all 5.5 inch iPhone resolutions" do
      expect_screen_size_from_file("iPhone8Plus-Portrait{1242x2208}.jpg").to eq(Deliver::AppScreenshot::ScreenSize::IOS_55)
      expect_screen_size_from_file("iPhone8Plus-Landscape{2208x1242}.jpg").to eq(Deliver::AppScreenshot::ScreenSize::IOS_55)
    end

    it "should calculate all 4.7 inch iPhone resolutions" do
      expect_screen_size_from_file("iPhone8-Portrait{750x1334}.jpg").to eq(Deliver::AppScreenshot::ScreenSize::IOS_47)
      expect_screen_size_from_file("iPhone8-Landscape{1334x750}.jpg").to eq(Deliver::AppScreenshot::ScreenSize::IOS_47)
    end

    it "should calculate all 4 inch iPhone resolutions" do
      expect_screen_size_from_file("iPhoneSE-Portrait{640x1136}.jpg").to eq(Deliver::AppScreenshot::ScreenSize::IOS_40)
      expect_screen_size_from_file("iPhoneSE-Landscape{1136x640}.jpg").to eq(Deliver::AppScreenshot::ScreenSize::IOS_40)
      expect_screen_size_from_file("iPhoneSE-Portrait-NoStatusBar{640x1096}.jpg").to eq(Deliver::AppScreenshot::ScreenSize::IOS_40)
      expect_screen_size_from_file("iPhoneSE-Landscape-NoStatusBar{1136x600}.jpg").to eq(Deliver::AppScreenshot::ScreenSize::IOS_40)
    end

    it "should calculate all 3.5 inch iPhone resolutions" do
      expect_screen_size_from_file("iPhone4S-Portrait{640x960}.jpg").to eq(Deliver::AppScreenshot::ScreenSize::IOS_35)
      expect_screen_size_from_file("iPhone4S-Landscape{960x640}.jpg").to eq(Deliver::AppScreenshot::ScreenSize::IOS_35)
      expect_screen_size_from_file("iPhone4S-Portrait-NoStatusBar{640x920}.jpg").to eq(Deliver::AppScreenshot::ScreenSize::IOS_35)
      expect_screen_size_from_file("iPhone4S-Landscape-NoStatusBar{960x600}.jpg").to eq(Deliver::AppScreenshot::ScreenSize::IOS_35)
    end

    it "should calculate all 12.9 inch iPad resolutions" do
      expect_screen_size_from_file("iPad-Portrait-12_9Inch{2048x2732}.jpg").to eq(Deliver::AppScreenshot::ScreenSize::IOS_IPAD_PRO)
      expect_screen_size_from_file("iPad-Landscape-12_9Inch{2732x2048}.jpg").to eq(Deliver::AppScreenshot::ScreenSize::IOS_IPAD_PRO)
    end

    it "should calculate all 11 inch iPad resolutions" do
      expect_screen_size_from_file("iPad-Portrait-11Inch{1668x2388}.jpg").to eq(Deliver::AppScreenshot::ScreenSize::IOS_IPAD_11)
      expect_screen_size_from_file("iPad-Landscape-11Inch{2388x1668}.jpg").to eq(Deliver::AppScreenshot::ScreenSize::IOS_IPAD_11)
    end

    it "should calculate all 10.5 inch iPad resolutions" do
      expect_screen_size_from_file("iPad-Portrait-10_5Inch{1668x2224}.jpg").to eq(Deliver::AppScreenshot::ScreenSize::IOS_IPAD_10_5)
      expect_screen_size_from_file("iPad-Landscape-10_5Inch{2224x1668}.jpg").to eq(Deliver::AppScreenshot::ScreenSize::IOS_IPAD_10_5)
    end

    it "should calculate all 9.7 inch iPad resolutions" do
      expect_screen_size_from_file("iPad-Portrait-9_7Inch-Retina{1536x2048}.jpg").to eq(Deliver::AppScreenshot::ScreenSize::IOS_IPAD)
      expect_screen_size_from_file("iPad-Landscape-9_7Inch-Retina{2048x1536}.jpg").to eq(Deliver::AppScreenshot::ScreenSize::IOS_IPAD)
      expect_screen_size_from_file("iPad-Portrait-9_7Inch-Retina-NoStatusBar{1536x2008}.jpg").to eq(Deliver::AppScreenshot::ScreenSize::IOS_IPAD)
      expect_screen_size_from_file("iPad-Landscape-9_7Inch-Retina-NoStatusBar{2048x1496}.jpg").to eq(Deliver::AppScreenshot::ScreenSize::IOS_IPAD)
      expect_screen_size_from_file("iPad-Portrait-9_7Inch-{768x1024}.jpg").to eq(Deliver::AppScreenshot::ScreenSize::IOS_IPAD)
      expect_screen_size_from_file("iPad-Landscape-9_7Inch-{1024x768}.jpg").to eq(Deliver::AppScreenshot::ScreenSize::IOS_IPAD)
      expect_screen_size_from_file("iPad-Portrait-9_7Inch-NoStatusBar{768x1004}.jpg").to eq(Deliver::AppScreenshot::ScreenSize::IOS_IPAD)
      expect_screen_size_from_file("iPad-Landscape-9_7Inch-NoStatusBar{1024x748}.jpg").to eq(Deliver::AppScreenshot::ScreenSize::IOS_IPAD)
    end

    it "should calculate all supported Mac resolutions" do
      expect_screen_size_from_file("Mac{1280x800}.jpg").to eq(Deliver::AppScreenshot::ScreenSize::MAC)
      expect_screen_size_from_file("Mac{1440x900}.jpg").to eq(Deliver::AppScreenshot::ScreenSize::MAC)
      expect_screen_size_from_file("Mac{2560x1600}.jpg").to eq(Deliver::AppScreenshot::ScreenSize::MAC)
      expect_screen_size_from_file("Mac{2880x1800}.jpg").to eq(Deliver::AppScreenshot::ScreenSize::MAC)
    end

    it "should calculate all supported Apple TV resolutions" do
      expect_screen_size_from_file("AppleTV{1920x1080}.jpg").to eq(Deliver::AppScreenshot::ScreenSize::APPLE_TV)
      expect_screen_size_from_file("AppleTV-4K{3840x2160}.jpg").to eq(Deliver::AppScreenshot::ScreenSize::APPLE_TV)
    end

    it "should calculate all supported Apple Watch resolutions" do
      expect_screen_size_from_file("AppleWatch-Series3{312x390}.jpg").to eq(Deliver::AppScreenshot::ScreenSize::IOS_APPLE_WATCH)
      expect_screen_size_from_file("AppleWatch-Series4{368x448}.jpg").to eq(Deliver::AppScreenshot::ScreenSize::IOS_APPLE_WATCH_SERIES4)
    end
  end

  describe "invalid screen size calculations" do
    def expect_invalid_screen_size_from_file(file)
      expect do
        Deliver::AppScreenshot.calculate_screen_size(file)
      end.to raise_error(FastlaneCore::Interface::FastlaneError, "Unsupported screen size #{screen_size_from(file)} for path '#{file}'")
    end

    it "shouldn't calculate portrait Apple TV resolutions" do
      expect_invalid_screen_size_from_file("appleTV/en-GB/AppleTV-Portrait{1080x1920}.jpg")
      expect_invalid_screen_size_from_file("appleTV/en-GB/AppleTV-Portrait{2160x3840}.jpg")
    end

    it "shouldn't calculate modern devices excluding status bars" do
      expect_invalid_screen_size_from_file("iPhoneXSMax-Portrait-NoStatusBar{1242x2556}.jpg")
      expect_invalid_screen_size_from_file("iPhoneXS-Portrait-NoStatusBar{1125x2304}.jpg")
      expect_invalid_screen_size_from_file("iPhone8Plus-Portrait-NoStatusBar{1242x2148}.jpg")
      expect_invalid_screen_size_from_file("iPhone8-Portrait-NoStatusBar{750x1294}.jpg")
      expect_invalid_screen_size_from_file("iPad-Portrait-12_9Inch-NoStatusBar{2048x2692}.jpg")
      expect_invalid_screen_size_from_file("iPad-Portrait-11Inch{1668x2348}.jpg")
      expect_invalid_screen_size_from_file("iPad-Portrait-10_5Inch{1668x2184}.jpg")
    end

    it "shouldn't allow non 16:10 resolutions for Mac" do
      expect_invalid_screen_size_from_file("Mac-Portrait{800x1280}.jpg")
      expect_invalid_screen_size_from_file("Mac-Portrait{900x1440}.jpg")
      expect_invalid_screen_size_from_file("Mac-Portrait{1600x2560}.jpg")
      expect_invalid_screen_size_from_file("Mac-Portrait{1800x2880}.jpg")
    end
  end
end
