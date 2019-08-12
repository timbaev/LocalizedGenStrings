class Localizedgenstrings < Formula
  desc "Generate localized strings from extension and storyboards"
  homepage "https://github.com/timbaev/LocalizedGenStrings"
  url "https://github.com/timbaev/LocalizedGenStrings.git",
      :tag => "0.0.4", :revision => "a1bdeb573c5bf11b292605b7baf3266908949bca"
  head "https://github.com/timbaev/LocalizedGenStrings.git"

  depends_on :xcode => ["10.3", :build]

  def install
    system "make", "install", "PREFIX=#{prefix}"
  end

  test do
    system "#{bin}/LocalizedGenStrings"
  end
end
