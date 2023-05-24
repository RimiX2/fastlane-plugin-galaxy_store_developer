require 'fastlane/action'
require_relative '../helper/galaxy_store_developer_helper'

module Fastlane
  module Actions
    class GalaxyStoreDeveloperSubmitAction < Action

      PUB_SCOPE = "publishing"

      def self.run(params)

        accessToken = Helper::GalaxyStoreDeveloperHelper.get_access_token(params[:sa_id], PUB_SCOPE, params[:key_path])

        Helper::GalaxyStoreDeveloperHelper.submit_app(params[:sa_id], accessToken, params[:app_id])

      end

      def self.description
        "Samsung Developer API integration - Submitting app for review"
      end

      def self.authors
        ["Rim Ganiev"]
      end

      def self.return_value
        # If your method provides a return value, you can describe here what it does
      end

      def self.details
        "Fastlane plugin to interacting with Samsung Galaxy Store API"
      end

      def self.available_options
        [
            FastlaneCore::ConfigItem.new(key: :sa_id,
                                         env_name: "GALAXY_STORE_DEVELOPER_SA_ID",
                                         description: "Service Account (SA) ID",
                                         optional: false,
                                         type: String),
            FastlaneCore::ConfigItem.new(key: :key_path,
                                         env_name: "GALAXY_STORE_DEVELOPER_SA_KEY_PATH",
                                         description: "Path for the SA's private key (PEM)",
                                         optional: false,
                                         type: String),
            FastlaneCore::ConfigItem.new(key: :app_id,
                                         env_name: "GALAXY_STORE_DEVELOPER_APP_ID",
                                         description: "Developer's application ID",
                                         optional: false,
                                         type: String)
        ]
      end

      def self.is_supported?(platform)
        [:android].include?(platform)
        true
      end
    end
  end
end
