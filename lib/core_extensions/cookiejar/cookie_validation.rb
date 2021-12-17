require 'cookiejar/cookie_validation'

# Original source code at
# https://github.com/dwaite/cookiejar/blob/master/lib/cookiejar/cookie_validation.rb
module CookieJar
  module CookieValidation
    # Re-opening the CookieValidation module to rewrite the domains_match method to
    # skip the validation of domains. Open issue at
    # https://github.com/restforce/restforce/issues/120
    def self.domains_match(tested_domain, base_domain)
      return true if tested_domain[-15..].eql?('.salesforce.com')

      # original implementation
      base = effective_host base_domain
      search_domains = compute_search_domains_for_host base
      search_domains.find do |domain|
        domain == tested_domain
      end
    end

    # Implements https://github.com/dwaite/cookiejar/commit/adb79c0a14c2b347c5289e79379a1acfe34bf388
    # which is not part of the cookiejar gem yet and is required to prevent
    # Unknown cookie parameter 'samesite' (CookieJar::InvalidCookieError)
    def self.parse_set_cookie(set_cookie_value)
      args = {}
      params = set_cookie_value.split(/;\s*/)

      first = true
      params.each do |param|
        result = PARAM1.match param
        unless result
          fail InvalidCookieError,
            "Invalid cookie parameter in cookie '#{set_cookie_value}'"
        end
        key = result[1].downcase.to_sym
        keyvalue = result[2]
        if first
          args[:name] = result[1]
          args[:value] = keyvalue
          first = false
        else
          case key
          when :expires
            begin
              args[:expires_at] = Time.parse keyvalue
            rescue ArgumentError
              raise unless $ERROR_INFO.message == 'time out of range'

              args[:expires_at] = Time.at(0x7FFFFFFF)
            end
          when :'max-age'
            args[:max_age] = keyvalue.to_i
          when :domain, :path
            args[key] = keyvalue
          when :secure
            args[:secure] = true
          when :httponly
            args[:http_only] = true
          when :samesite
            args[:samesite] = keyvalue.downcase
          else
            fail InvalidCookieError, "Unknown cookie parameter '#{key}'"
          end
        end
      end
      args[:version] = 0
      args
    end
  end
end
