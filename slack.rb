require 'openssl'

class Slack
  def initialize
    @slack_signing_secret = ENV['SLACK_SIGNING_SECRET']
    check_secret
  end

  def verify(request)
    timestamp = request.env['HTTP_X_SLACK_REQUEST_TIMESTAMP']
    signature_from_slack = request.env['HTTP_X_SLACK_SIGNATURE']

    verify_timestamp(timestamp.to_i) &&
      verify_payload(timestamp, request.body.read, signature_from_slack)
  end

  private

  SLACK_VERSION_NO = 'v0'

  def check_secret
    if @slack_signing_secret.nil?
      warn "Slack signing secret not in env var."
    end
  end

  def verify_timestamp(timestamp)
    # The request timestamp is more than five minutes from local time.
    # It could be a replay attack, so let's ignore it.
    (Time.now.to_i - timestamp) < (60 * 5)
  end

  def verify_payload(timestamp, req_body, signature_from_slack)
    puts "Verifying payload from Slack."
    data = "#{SLACK_VERSION_NO}:#{timestamp}:#{req_body}"
    digest = OpenSSL::Digest.new('sha256')
    my_signature = "#{SLACK_VERSION_NO}=#{OpenSSL::HMAC.hexdigest(digest, @slack_signing_secret, data)}"
    puts "DATA: #{data}"
    puts "MY SIGNATURE: #{my_signature}"
    puts "SLACK SIGNATURE: #{signature_from_slack}"
    my_signature == signature_from_slack
  end
end
