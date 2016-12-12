class Modulo < Formula
  desc "Modulo dependency manager"
  homepage "https://github.com/modulo-dm/modulo"
  url "https://github.com/modulo-dm/modulo/archive/v0.0.3.tar.gz"
  sha256 "9573da42daaa17ed563b2f25c2e927d98eb67d1a784f0dfda5baf4e0967bf04b"

  def install
    xcodebuild *%w{-project modulo.xcodeproj -scheme modulo -configuration Release "SYMROOT=build"}
    bin.install "/tmp/modulo"
  end

end
