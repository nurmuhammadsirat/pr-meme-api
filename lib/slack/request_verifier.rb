require 'logger'
require 'openssl'

module Slack
  class RequestVerifier
    attr_reader :errors

    def initialize(signing_secret, opts = {})
      @logger = opts[:logger] || 
        init_logger(
          log_level: opts[:log_level],
          log_file: opts[:log_file]
        )

      @signing_secret = signing_secret
      @errors = []
    end


    REQUIRED_HEADERS = %w(
      HTTP_X_SLACK_REQUEST_TIMESTAMP
      HTTP_X_SLACK_SIGNATURE
    )

    def perform_verification_for(request)
      request_timestamp, slack_signature = REQUIRED_HEADERS.map do |header| 
        request.env[header]
      end

      @logger.info 'Verifying slack request.'
      verify_not_replay_attack(request_timestamp.to_i)
      verify_payload(request_timestamp, request.body.read, slack_signature)

      @errors.empty?
    end

    private

    SLACK_VERSION_NO = 'v0'

    def init_logger(log_level: Logger::INFO, log_file: STDOUT)
      logger = ::Logger.new(log_file)
      logger.level = log_level
      logger
    end

    def verify_not_replay_attack(request_timestamp)
      @logger.debug "Verifying request is not a replay attack."

      # The request timestamp is more than five minutes from local time.
      # It could be a replay attack, so let's ignore it.
      unless is_within_5_minutes(request_timestamp)
        @errors << 'Possible replay attack: request timestamp is more than 5 minutes.'
      end
    end

    def is_within_5_minutes(request_timestamp)
      (Time.now.to_i - request_timestamp) < (60 * 5)
    end

    def verify_payload(request_timestamp, req_body, slack_signature)
      @logger.debug "Verifying payload from Slack."
      
      data = "#{SLACK_VERSION_NO}:#{request_timestamp}:#{req_body}"
      digest = OpenSSL::Digest.new('sha256')
      
      my_signature = "#{SLACK_VERSION_NO}=#{OpenSSL::HMAC.hexdigest(digest, @signing_secret, data)}"
      @logger.debug "DATA: #{data}"
      @logger.debug "MY SIGNATURE: #{my_signature}"
      @logger.debug "SLACK SIGNATURE: #{slack_signature}"
      
      unless my_signature == slack_signature
        @errors << 'Computed signature does not match signature from Slack.'
      end
    end
  end
end
