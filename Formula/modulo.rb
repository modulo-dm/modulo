class Modulo < Formula
  desc "Modulo dependency manager"
  homepage "https://github.com/modulo-dm/modulo"
  url "https://github.com/modulo-dm/modulo/archive/v0.0.4.tar.gz"
  sha256 "e81f39d363550196c4ccf0b6b29e32a85376d56796989ec125c19aa5f4f51415"

  def install
    xcodebuild *%w{-project modulo.xcodeproj -scheme modulo -configuration Release "SYMROOT=build"}
    bin.install "/tmp/modulo"
    rm "tmp/modulo"
    man1.install "Documentation/modulo.1"
    man1.install "Documentation/modulo-layout.1"
    man1.install "Documentation/modulo-init.1"
    man1.install "Documentation/modulo-add.1"
    man1.install "Documentation/modulo-update.1"
  end

end
