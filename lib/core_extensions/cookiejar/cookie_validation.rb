# frozen_string_literal: true

# Original source code at
# https://github.com/dwaite/cookiejar/blob/master/lib/cookiejar/cookie_validation.rb
# Re-opening the CookieValidation module to rewrite the domains_match method to
# skip the validation of domains. Open issue at
# https://github.com/restforce/restforce/issues/120
module CoreExtensions
  module CookieJar
    module CookieValidation
      def self.extended(base)
        base.class_eval do

          def self.domains_match(tested_domain, base_domain)
            return true if tested_domain[-15..-1].eql?('.salesforce.com')

            # original implementation
            base = effective_host base_domain
            search_domains = compute_search_domains_for_host base
            search_domains.find do |domain|
              domain == tested_domain
            end
          end

        end
      end
    end
  end
end

CookieJar::CookieValidation.extend(CoreExtensions::CookieJar::CookieValidation)
