require "formula"

class Xplanetfx < Formula
  homepage "http://mein-neues-blog.de/xplanetFX/"
  url "http://repository.mein-neues-blog.de:9000/archive/xplanetfx-2.6.1_all.tar.gz"
  sha1 "e6cec26b6f211477011071ff34a4bd683630a8e5"
  version "2.6"

  bottle do
    cellar :any
    revision 2
    sha1 "508a77eb60b692f086d057cddcd36feed85318e2" => :yosemite
    sha1 "9fe6eab7b46c76a39283ce053fdaf1cca27877cb" => :mavericks
    sha1 "405ffab7e7cd1d734ccf5720266b65b1d4bc9fcb" => :mountain_lion
  end

  option "without-perlmagick", "Build without PerlMagick support - used to check cloud map downloads"
  option "without-gui", "Build to run xplanetFX from the command-line only"
  option "with-gnu-sed", "Build to use GNU sed instead of OS X sed"

  depends_on "xplanet"
  depends_on "imagemagick"
  depends_on "wget"
  depends_on "coreutils"
  depends_on "gnu-sed" => :optional
  depends_on "perlmagick" => :recommended

  if build.with? "gui"
    depends_on "librsvg"
    depends_on "pygtk" => "with-libglade"
  end

  skip_clean "share/xplanetFX"

  def install
    inreplace "bin/xplanetFX", "WORKDIR=/usr/share/xplanetFX", "WORKDIR=#{HOMEBREW_PREFIX}/share/xplanetFX"

    prefix.install "bin", "share"

    path = "#{Formula["coreutils"].opt_libexec}/gnubin"
    path += ":#{Formula["gnu-sed"].opt_libexec}/gnubin" if build.with?("gnu-sed")
    if build.with?("perlmagick")
      perl_version = `/usr/bin/perl -e 'printf "%vd", $^V;'`
      ENV.prepend_create_path "PERL5LIB", "#{HOMEBREW_PREFIX}/lib/perl5/site_perl/#{perl_version}"
    end
    if build.with?("gui")
      ENV.prepend_create_path "PYTHONPATH", "#{HOMEBREW_PREFIX}/lib/python2.7/site-packages/gtk-2.0"
      ENV.prepend_create_path "GDK_PIXBUF_MODULEDIR", "#{HOMEBREW_PREFIX}/lib/gdk-pixbuf-2.0/2.10.0/loaders"
    end
    bin.env_script_all_files(libexec+'bin', :PATH => "#{path}:$PATH", :PYTHONPATH => ENV["PYTHONPATH"], :PERL5LIB => ENV["PERL5LIB"], :GDK_PIXBUF_MODULEDIR => ENV["GDK_PIXBUF_MODULEDIR"])
  end

  def post_install
    if build.with?("gui")
      # Change the version directory below with any future update
      ENV["GDK_PIXBUF_MODULEDIR"]="#{HOMEBREW_PREFIX}/lib/gdk-pixbuf-2.0/2.10.0/loaders"
      system "#{HOMEBREW_PREFIX}/bin/gdk-pixbuf-query-loaders", "--update-cache"
    end
  end
end
