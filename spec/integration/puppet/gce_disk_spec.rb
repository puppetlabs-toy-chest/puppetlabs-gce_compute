require 'spec_helper'

describe "gce_disk" do
  it "runs creates and destroys a simple disk" do
    expect(`gcloud compute disks list`).to_not match(/puppet-test/)
    apply_example('up_disk')
    expect(`gcloud compute disks list`).to match(/puppet-test/)
    apply_example('down_disk')
    expect(`gcloud compute disks list`).to_not match(/puppet-test/)
  end

  it "complains about an invalid disk" do
    _, stderr = apply_example('bad_disk')
    expect(stderr).to match(/failed/)
  end

  def apply_example(example)
    _, stdout, stderr = Open3.popen3("puppet apply examples/gce_disk/#{example}.pp")
    return stdout.gets, stderr.gets
  end
end
