# XXX This facter code is not tested; I couldn't figure out how to get it into
# a reasonable test harness.

module GcloudVersion
  MINIMUM_VERSION = '0.9.60'
end

Facter.add(:gcloud_version) do
  setcode do
    if Facter::Util::Resolution.which('gcloud')
      words = Facter::Util::Resolution.exec('gcloud --version').split
      # Use the first valid semantic version number.
      # NOTE If none is found, we return nil.
      words.select{|word| SemVer.valid?(word)}.first
    end
  end
end

Facter.add(:gcloud_compatible_version) do
  setcode do
    gcloud_version = Facter.value(:gcloud_version)
    if gcloud_version.nil?
      false
    else
      SemVer.new(gcloud_version) >= SemVer.new(GcloudVersion::MINIMUM_VERSION)
    end
  end
end
