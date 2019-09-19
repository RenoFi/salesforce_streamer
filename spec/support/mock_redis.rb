# frozen_string_literal: true

# Mock a Redis implementation so that specs do not depend on an actual Redis
# instance up and running
class MockRedis
  def zadd(key, *args)
    if args.size == 1 && args[0].is_a?(Array)
      hash[key] << args.map(&:last)
      args[0].size
    elsif args.size == 2
      hash[key] << args[1]
      1
    else
      raise 'MockRedis.zadd wrong number of arguments'
    end
  end

  def zrevrange(key, start, stop, _options = {})
    return nil unless hash[key]

    hash[key].to_a.reverse[start..stop]
  end

  private

  def hash
    @hash ||= Hash.new { |hash, key| hash[key] = SortedSet.new }
  end
end
