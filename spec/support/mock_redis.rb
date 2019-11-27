# Mock a Redis implementation so that specs do not depend on an actual Redis
# instance up and running
class MockRedis
  def setex(key, _seconds, value)
    hash[key] = value
    'OK'
  end

  # does not consider the expired seconds
  def get(key)
    hash[key]
  end

  def zadd(key, *args)
    if args.size == 1 && args[0].is_a?(Array)
      sorted_set[key] << args.map(&:last)
      args[0].size
    elsif args.size == 2
      sorted_set[key] << args[1]
      1
    else
      fail 'MockRedis.zadd wrong number of arguments'
    end
  end

  def zrevrange(key, start, stop, _options = {})
    return nil unless sorted_set[key]

    sorted_set[key].to_a.reverse[start..stop]
  end

  private

  def sorted_set
    @sorted_set ||= { key => SortedSet.new }
  end

  def hash
    @hash ||= {}
  end
end
