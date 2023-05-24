require 'fastlane_core/ui/ui'
require "base64"
require "jwt"

module Fastlane
  UI = FastlaneCore::UI unless Fastlane.const_defined?("UI")

  module Helper
    class GalaxyStoreDeveloperHelper

      BASE_URL = 'https://devapi.samsungapps.com'

      private_class_method def self.generate_jwt(scope, key_path, service_account_id)
                             private_key = OpenSSL::PKey.read(File.read(key_path))
                             now_time = Time.now.to_i
                             token = JWT.encode({
                                                    iss: service_account_id,
                                                    iat: now_time,
                                                    exp: now_time + 20 * 60,
                                                    scopes: ["#{scope}"]
                                                },
                                                private_key,
                                                "RS256",
                                                header_fields = {
                                                    alg: "RS256",
                                                    typ: "JWT"
                                                }
                             )
                             return token
                           end

      def self.get_access_token(service_account_id, scope, key_path)
        jwt = generate_jwt(scope, key_path, service_account_id)
        UI.important("Getting access token ...")

        uri = URI(BASE_URL + '/auth/accessToken')
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        req = Net::HTTP::Post.new(uri.path, {'Authorization' => "Bearer #{jwt}"})
        res = http.request(req)

        result_json = JSON.parse(res.body)
        token = result_json['createdItem']['accessToken']
        if token.nil?
          UI.error("Cannot retrieve access token, please check your credentials")
        else
          UI.success 'Access token generated'
          # UI.message token
        end
        return token

      end

      def self.is_token_valid?(service_account_id, access_token)
        UI.message("Validating access token ...")

        uri = URI(BASE_URL + '/auth/checkAccessToken')
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        req = Net::HTTP::Get.new(uri.path)
        req["Authorization"] = "Bearer #{access_token}"
        req["service-account-id"] = service_account_id
        res = http.request(req)

        result_json = JSON.parse(res.body)
        return result_json['ok']
      end

      def self.get_apps_list(service_account_id, access_token)
        UI.message("Listing all apps on the account ...")

        uri = URI(BASE_URL + '/seller/contentList')
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        req = Net::HTTP::Get.new(uri.path)
        req["Authorization"] = "Bearer #{access_token}"
        req["service-account-id"] = service_account_id
        res = http.request(req)
        UI.success 'Listing done' if res.code == '200'
        result_json = JSON.parse(res.body)
        return result_json
      end

      def self.get_app_info(service_account_id, access_token, content_id)
        UI.message("Getting info of the app ...")

        uri = URI(BASE_URL + '/seller/contentInfo')
        params = {:contentId => content_id}
        uri.query = URI.encode_www_form(params)
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        req = Net::HTTP::Get.new(uri)
        req["Authorization"] = "Bearer #{access_token}"
        req["service-account-id"] = service_account_id
        res = http.request(req)

        result_json = JSON.parse(res.body)
        return result_json
      end

      def self.create_upload_session(service_account_id, access_token)
        UI.message("Creating upload session ...")


        uri = URI(BASE_URL + '/seller/createUploadSessionId')
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true

        req = Net::HTTP::Post.new(uri.path)
        req['Authorization'] = "Bearer #{access_token}"
        req['service-account-id'] = "#{service_account_id}"
        res = http.request(req)

        result_json = JSON.parse(res.body)
        session_id = result_json['sessionId']
        UI.error("Failed") if session_id.nil?

        return session_id

      end

      def self.upload_file(service_account_id, access_token, session_id, file_path)
        UI.message("Uploading file ...")

        uri = URI('https://seller.samsungapps.com/galaxyapi/fileUpload')
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        req = Net::HTTP::Post.new(uri.path)
        req['Authorization'] = "Bearer #{access_token}"
        req['service-account-id'] = "#{service_account_id}"
        req.set_content_type("multipart/form-data")
        req.set_form([['file', File.open(file_path)], ['sessionId', session_id]], 'multipart/form-data')
        res = http.request(req)
        result_json = JSON.parse(res.body)

        file_key = result_json['fileKey']
        if file_key.nil?
          UI.error("Upload failed")
          UI.error(result_json['errorCode'])
          UI.error(result_json['errorMsg'])
        else
          UI.success 'File uploaded'
        end

        return file_key

      end

      # register binary
      def self.modify_app(service_account_id, access_token, json_body)
        UI.message("Modifying app ...")

        uri = URI(BASE_URL + '/seller/contentUpdate')
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        req = Net::HTTP::Post.new(uri.path)
        req['Authorization'] = "Bearer #{access_token}"
        req['service-account-id'] = "#{service_account_id}"
        req.set_content_type("application/json")
        req.body = json_body
        res = http.request(req)
        result_json = JSON.parse(res.body)
        if result_json['contentStatus'] == 'REGISTERING'
          UI.success 'App modified'
        else
          UI.error("Modification failed")
          UI.error(result_json['errorCode'])
          UI.error(result_json['errorMsg'])
        end

      end

      # Apps must be in the REGISTERING state before they can be submitted.
      def self.submit_app(service_account_id, access_token, content_id)
        UI.important("Submitting app for review ...")

        uri = URI(BASE_URL + '/seller/contentSubmit')
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        req = Net::HTTP::Post.new(uri.path)
        req['Authorization'] = "Bearer #{access_token}"
        req['service-account-id'] = "#{service_account_id}"
        req.set_content_type("application/json")
        req.body = {contentId: "#{content_id}"}.to_json
        res = http.request(req)
        if res.code == '204'
          UI.success "App submitted"
        else
          UI.error 'App submission failed'
        end

      end


    end
  end
end
