require 'spaceship/tunes/tunes'
require 'spaceship/tunes/device_type'

require_relative 'app_screenshot'
require_relative 'module'
require_relative 'loader'

module Deliver
  # upload screenshots to App Store Connect
  class UploadScreenshots
    def upload(options, screenshots)
      return if options[:skip_screenshots]
      return if options[:edit_live]

      app = options[:app]

      v = app.edit_version(platform: options[:platform])
      UI.user_error!("Could not find a version to edit for app '#{app.name}'") unless v

      UI.message("Starting with the upload of screenshots...")
      screenshots_per_language = screenshots.group_by(&:language)

      if options[:overwrite_screenshots]
        UI.message("Removing all previously uploaded screenshots...")
        # First, clear all previously uploaded screenshots
        screenshots_per_language.keys.each do |language|
          # We have to nil check for languages not activated
          next if v.screenshots[language].nil?
          v.screenshots[language].each_with_index do |t, index|
            v.upload_screenshot!(nil, t.sort_order, t.language, t.device_type, t.is_imessage)
          end
        end
      end

      # Now, fill in the new ones
      indized = {} # per language and device type

      enabled_languages = screenshots_per_language.keys
      if enabled_languages.count > 0
        v.create_languages(enabled_languages)
        lng_text = "language"
        lng_text += "s" if enabled_languages.count != 1
        Helper.show_loading_indicator("Activating #{lng_text} #{enabled_languages.join(', ')}...")
        v.save!
        # This refreshes the app version from iTC after enabling a localization
        v = app.edit_version
        Helper.hide_loading_indicator
      end

      screenshots_per_language.each do |language, screenshots_for_language|
        UI.message("Uploading #{screenshots_for_language.length} screenshots for language #{language}")
        screenshots_for_language.each do |screenshot|
          indized[screenshot.language] ||= {}
          indized[screenshot.language][screenshot.formatted_name] ||= 0
          indized[screenshot.language][screenshot.formatted_name] += 1 # we actually start with 1... wtf iTC

          index = indized[screenshot.language][screenshot.formatted_name]

          if index > 10
            UI.error("Too many screenshots found for device '#{screenshot.formatted_name}' in '#{screenshot.language}', skipping this one (#{screenshot.path})")
            next
          end

          UI.message("Uploading '#{screenshot.path}'...")
          v.upload_screenshot!(screenshot.path,
                               index,
                               screenshot.language,
                               screenshot.device_type,
                               screenshot.is_messages)
        end
        # ideally we should only save once, but itunes server can't cope it seems
        # so we save per language. See issue #349
        Helper.show_loading_indicator("Saving changes")
        v.save!
        # Refresh app version to start clean again. See issue #9859
        v = app.edit_version
        Helper.hide_loading_indicator
      end
      UI.success("Successfully uploaded screenshots to App Store Connect")
    end

    def collect_screenshots(options)
      return [] if options[:skip_screenshots]
      return collect_screenshots_for_languages(options[:screenshots_path], options[:ignore_language_directory_validation])
    end

    def collect_screenshots_for_languages(path, ignore_validation, is_messages = false)
      screenshots = []
      extensions = '{png,jpg,jpeg}'
      device_types = "{#{Spaceship::Tunes::DeviceType.types.join(",")}}"

      available_languages = UploadScreenshots.available_languages.each_with_object({}) do |lang, lang_hash|
        lang_hash[lang.downcase] = lang
      end

      Loader.language_folders(path, ignore_validation).each do |lng_folder|
        language = File.basename(lng_folder)

        # Check to see if we need to traverse multiple platforms or just a single platform
        if language == Loader::APPLE_TV_DIR_NAME || language == Loader::IMESSAGE_DIR_NAME
          screenshots.concat(collect_screenshots_for_languages(File.join(path, language), ignore_validation, language == Loader::IMESSAGE_DIR_NAME))
          next
        end

        files = Dir.glob(File.join(lng_folder, "*.#{extensions}"), File::FNM_CASEFOLD)
        files.concat(Dir.glob(File.join(lng_folder, device_types, "*.#{extensions}"), File::FNM_CASEFOLD))
        next if files.count == 0

        framed_screenshots_found = files.any? { |file| file_is_framed?(file) }

        UI.important("Framed screenshots are detected! 🖼 Non-framed screenshot files may be skipped. 🏃") if framed_screenshots_found

        language_dir_name = File.basename(lng_folder)

        if available_languages[language_dir_name.downcase].nil?
          UI.user_error!("#{language_dir_name} is not an available language. Please verify that your language codes are available in iTunesConnect. See https://developer.apple.com/library/content/documentation/LanguagesUtilities/Conceptual/iTunesConnect_Guide/Chapters/AppStoreTerritories.html for more information.")
        end

        language = available_languages[language_dir_name.downcase]

        files.each do |file_path|
          is_framed = file_is_framed?(file_path)
          is_watch = file_path.downcase.include?("watch")

          if framed_screenshots_found && !is_framed && !is_watch
            UI.important("🏃 Skipping screenshot file: #{file_path}")
            next
          end

          dir_name = File.basename(File.dirname(file_path))
          if Spaceship::Tunes::DeviceType.types.include?(dir_name)
            screen_size = AppScreenshot.screen_size_for_device_type(dir_name)
            device_type = dir_name
          else
            screen_size = AppScreenshot.calculate_screen_size(file_path)
            device_type = AppScreenshot.device_type_for_screen_size(screen_size)
          end

          screenshots << AppScreenshot.new(file_path, language, screen_size, device_type, is_messages)
        end
      end

      # Checking if the device type exists in spaceship
      # Ex: iPhone 6.1 inch isn't supported in App Store Connect but need
      # to have it in there for frameit support
      unaccepted_device_shown = false
      screenshots.select! do |screenshot|
        exists = Spaceship::Tunes::DeviceType.exists?(screenshot.device_type)
        unless exists
          UI.important("Unaccepted device screenshots are detected! 🚫 Screenshot file will be skipped. 🏃") unless unaccepted_device_shown
          unaccepted_device_shown = true

          UI.important("🏃 Skipping screenshot file: #{screenshot.path} - Not an accepted App Store Connect device...")
        end
        exists
      end

      return screenshots
    end

    def file_is_framed?(file)
      File.basename(file).downcase.include?("_framed.")
    end

    def self.available_languages
      if Helper.test?
        FastlaneCore::Languages::ALL_LANGUAGES
      else
        Spaceship::Tunes.client.available_languages
      end
    end
  end
end
