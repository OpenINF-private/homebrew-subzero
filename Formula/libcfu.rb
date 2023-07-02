class Libcfu < Formula
  desc "Library of thread-safe functions and data structures"
  homepage "https://libcfu.sourceforge.io/"
  url "https://github.com/OpenINF/libcfu/archive/v0.04a.tar.gz"
  sha256 "8dbb78a3a383b811eb2bc5bf803235e55ce87288a3e9cefa5600d5732c46cb1f"

  head do
    url "https://github.com/OpenINF/libcfu.git"

    depends_on "automake" => :build
    depends_on "autoconf" => :build
    depends_on "libtool" => :build
  end

  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "libtool" => :build

  def install
    args = %W[
      --includedir=#{include}
    ]

    amargs = %w[
      --add-missing
      --foreign
    ]

    system "./autogen.sh"
    system "automake", *amargs
    system "./configure", *args
    system "make"
    lib.install "src/.libs/libcfu.0.dylib"
    lib.install "src/.libs/libcfu.a"
    include.install Dir["src/*.h"]
    Dir.chdir("doc") do
      system "make", "html"
      doc.install Dir["libcfu.html/*"]
    end
  end

  test do
    (testpath/"test.c").write <<~EOS
      #include <cfuhash.h>
      int main()
      {
        cfuhash_table_t *hash = cfuhash_new_with_initial_size(30);
        cfuhash_set_flag(hash, CFUHASH_FROZEN_UNTIL_GROWS);

        cfuhash_put(hash, "var1", "value1");
        cfuhash_put(hash, "var2", "value2");
        cfuhash_put(hash, "var3", "value3");
        cfuhash_put(hash, "var4", "value4");

        cfuhash_pretty_print(hash, stdout);
        cfuhash_clear(hash);
        cfuhash_destroy(hash);

        return 0;
      }
    EOS
    system ENV.cc, "test.c", "-I#{include}", "-L#{lib}", "-lcfu", "-o", "test"
    system "./test"
  end
end
