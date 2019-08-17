class Localizedgenstrings < Formula
  desc "Generate localized strings from extension and storyboards"
  homepage "https://github.com/timbaev/LocalizedGenStrings"
  url "https://github.com/timbaev/LocalizedGenStrings.git",
      :tag => "0.0.5", :revision => "42016d7dd21d0aca10e56b61a924a0f9788427bd"
  head "https://github.com/timbaev/LocalizedGenStrings.git"

  depends_on :xcode => ["10.3", :build]

  def install
    system "make", "install", "PREFIX=#{prefix}"
  end

  test do
    system "#{bin}/LocalizedGenStrings"
  end
end
