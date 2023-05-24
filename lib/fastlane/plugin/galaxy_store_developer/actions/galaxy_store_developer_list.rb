require 'fastlane/action'
require_relative '../helper/galaxy_store_developer_helper'

module Fastlane
  module Actions
    class GalaxyStoreDeveloperListAction < Action

      PUB_SCOPE = "publishing"

      def self.run(params)

        accessToken = Helper::GalaxyStoreDeveloperHelper.get_access_token(params[:sa_id], PUB_SCOPE, params[:key_path])

        responseJSON = Helper::GalaxyStoreDeveloperHelper.get_apps_list(params[:sa_id], accessToken)

        puts JSON.pretty_generate(responseJSON)

        # hah = Hash.new { |h, k| h[k] = "" }

        col_labels = {contentName: "Title", contentId: "ID", contentStatus: "Status", standardPrice: "Price", paid: "Paid", modifyDate: "Date"}
        @columns = col_labels.each_with_object({}) { |(col, label), h|
          h[col] = {label: label,
                    width: [responseJSON.map { |g| g[col.to_s].size }.max, label.size].max }
                    # width: 30}
        }

        puts "+-#{@columns.map { |_, g| '-' * g[:width] }.join('-+-')}-+"
        puts "| #{@columns.map { |_, g| g[:label].ljust(g[:width]) }.join(' | ')} |"
        puts "+-#{@columns.map { |_, g| '-' * g[:width] }.join('-+-')}-+"
        responseJSON.each do |item|
          str = item.keys.map { |k| item[k].ljust(@columns[k.to_sym][:width]) }.join(' | ')
          puts "| #{str} |"
        end
        puts "+-#{@columns.map { |_, g| '-' * g[:width] }.join('-+-')}-+"

      end

      def self.description
        "Samsung Developer API integration - Listing apps"
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
