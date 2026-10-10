class BrowserDirector < Formula
  desc "Script browser demo videos with smooth zooms and synchronized narration"
  homepage "https://github.com/pyrofolium/browser-director"
  url "https://github.com/pyrofolium/browser-director/archive/refs/tags/v0.1.0.tar.gz"
  sha256 "f7246b0ee50b7d79e1ac6f7dce565f670f04c2524f7cb72809eb0f7aa56df57b"
  license "MIT"

  depends_on "ffmpeg"
  depends_on "node"

  def install
    libexec.install "bin", "src", "skill", "examples", "package.json", "package-lock.json"
    system "npm", "ci", "--prefix", libexec, "--omit=dev", "--ignore-scripts"
    (bin/"browser-director").write_env_script libexec/"bin/browser-director.js",
      PATH: "#{Formula["node"].opt_bin}:#{Formula["ffmpeg"].opt_bin}:$PATH"
  end

  def caveats
    <<~EOS
      Install the matching Chromium browser:
        browser-director setup

      Install the skill for Codex and Claude Code:
        browser-director install-skill

      Check your installation:
        browser-director doctor
    EOS
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/browser-director --version")
    system bin/"browser-director", "init", testpath/"demo"
    system bin/"browser-director", "validate", testpath/"demo/plan.json"
    ENV["CODEX_HOME"] = (testpath/"codex").to_s
    ENV["CLAUDE_CONFIG_DIR"] = (testpath/"claude").to_s
    system bin/"browser-director", "install-skill"
    assert_path_exists testpath/"codex/skills/browser-director/SKILL.md"
    assert_path_exists testpath/"claude/skills/browser-director/SKILL.md"
  end
end
