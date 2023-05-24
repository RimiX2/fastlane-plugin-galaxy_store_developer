require 'fastlane/action'
require_relative '../helper/galaxy_store_developer_helper'

module Fastlane
  module Actions
    class GalaxyStoreDeveloperUploadAction < Action

      PUB_SCOPE = "publishing"

      def self.run(params)

        # FastlaneCore::PrintTable.print_values(
        #     config: params,
        #     title: "Summary for galaxy_store_developer #{GalaxyStoreDeveloper::VERSION}"
        # )

        accessToken = Helper::GalaxyStoreDeveloperHelper.get_access_token(params[:sa_id], PUB_SCOPE, params[:key_path])
        # is_valid_token = Helper::GalaxyStoreDeveloperHelper.validate_access_token(params[:sa_id], accessToken)
        # if is_valid_token
        #   UI.message "Valid"
        #   else UI.error "Invalid"
        # end
        sessionId = Helper::GalaxyStoreDeveloperHelper.create_upload_session(params[:sa_id], accessToken)

        fileKey = Helper::GalaxyStoreDeveloperHelper.upload_file(params[:sa_id], accessToken, sessionId, params[:file_path])

        newBinaryJSON =
            {
                contentId: "#{params[:app_id]}",
                defaultLanguageCode: "RUS",
                publicationType: "01",
                paid: "N",
                usExportLaws: "true",
                ageLimit: "12",
                newFeature: "#{params[:changelog]}",
                binaryList: [
                    {
                        gms: "Y",
                        filekey: "#{fileKey}"
                    }
                ]
            }.to_json

        Helper::GalaxyStoreDeveloperHelper.modify_app(params[:sa_id], accessToken, newBinaryJSON)

      end

      def self.description
        "Samsung Developer API integration - Uploading app's new version binary"
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
            FastlaneCore::ConfigItem.new(key: :file_path,
                                         env_name: "GALAXY_STORE_DEVELOPER_UPLOAD_FILE_PATH",
                                         description: "Path for the file to upload",
                                         optional: false,
                                         type: String),
            FastlaneCore::ConfigItem.new(key: :app_id,
                                         env_name: "GALAXY_STORE_DEVELOPER_APP_ID",
                                         description: "Content ID of the app",
                                         optional: false,
                                         type: String),
            FastlaneCore::ConfigItem.new(key: :changelog,
                                         description: "Changelog (4000 symbols max)",
                                         optional: true,
                                         default_value: "",
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
