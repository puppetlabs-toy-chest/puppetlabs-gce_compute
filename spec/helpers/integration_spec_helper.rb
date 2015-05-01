require 'json'

class IntegrationSpecHelper
  def self.describe_out(resource, args)
    out, _ = describe_resource(resource, args)
    # NOTE This will throw a TypeError if `describe_resource` had no content in stdout
    return JSON.parse(out)
  end

  def self.describe_err(resource, args)
    _, err = describe_resource(resource, args)
    return err
  end

  def self.describe_resource(resource, args)
    _, stdout, stderr = Open3.popen3("gcloud compute #{resource} describe #{args} --format json")
    return stdout.gets(nil), stderr.gets(nil)
  end

  def self.apply_example(example)
    _, stdout, stderr = Open3.popen3("puppet apply examples/#{example}.pp")
    return stdout.gets(nil), stderr.gets(nil)
  end
end
