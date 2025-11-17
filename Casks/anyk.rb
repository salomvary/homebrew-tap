cask "anyk" do
  version "3.44.0"
  sha256 :no_check

  url "https://nav.gov.hu/pfile/programFile?path=/nyomtatvanyok/letoltesek/nyomtatvanykitolto_programok/nyomtatvany_apeh/keretprogramok/AbevJava"
  name "ÁNYK"
  desc "Általános Nyomtatványkitöltő (ÁNYK) - keretprogram a Java-alapú  nyomtatványokhoz, az AbevJava továbbfejlesztett változata."
  homepage "https://nav.gov.hu/nyomtatvanyok/letoltesek/nyomtatvanykitolto_programok/nyomtatvany_apeh/keretprogramok/AbevJava"

  livecheck do
    url :homepage
    regex(%r{data-version="(\d+\.\d+\.\d+)"}i)
    strategy :page_match
  end

  depends_on cask: "temurin@8"

  # Cask specific shared variables
  java_home = `/usr/libexec/java_home -v 1.8`.strip
  plist_file = File.join(Dir.home, "Library/LaunchAgents/abevjava.plist")
  # The installer creates an app on the desktop, both the name and path is hardcoded 
  app_on_desktop = File.join(Dir.home, "Desktop/abevjava.app")
  # The macOS app does not contain the actual Java app, it will be installed here 
  install_path = "#{caskroom_path}/abevjava"

  preflight do
    # Unfortunately, the non-interactive installer does not seem to allow
    # specifying the destination directory as a command line argument, only in
    # a pre-existing configuration file.

    # Create config dir
    config_dir = File.join(Dir.home, ".abevjava")
    Dir.mkdir(config_dir) unless Dir.exist?(config_dir)

    # Write install destination to config file
    File.write(File.join(config_dir, "abevjavapath.cfg"), <<~FILE)
      abevjava.path = #{install_path} 
    FILE
  end

  installer script: {
    executable: "#{java_home}/bin/java",
    args: [
      "-jar",
      "#{staged_path}/abevjava_install.jar",
      # Install non-interactively
      "-s",
      # Create .app (on the desktop)
      "-u"
    ]
  }

  # Would be nicer to name the app "ÁNYK" with the accent, but Finder fails
  # to launch the app with "The application can’t be opened" in that case.
  # Interestingly, the app opens fine from Spotlight or using `open` in the
  # Terminal, and also after renaming to "ANYK" and then bak to "ÁNYK". 
  # Thanks Apple!    
  app app_on_desktop, target: "ANYK.app"

  postflight do
    # The `app` stanza above moves the app to /Applications but leaves a symlink on the desktop, which we don't want.
    FileUtils.rm_r(app_on_desktop, force: true)

    # The application needs Java 8 (and not newer) but most systems will not have
    # Java 8 as the default. It is possible to override the path prefix to the Java binary
    # in the JAVA_HOME_ABEV environment variable (which, despite the name is not the Java "home" dir, 
    # but the "bin" one) but setting that permanently and outside of terminal shell sessions is non-trivial in macOS.

    # We could have generated a more sensible launcher script inside the app, but macOS refused to
    # launch that claiming that it is not able to check it for malware and security, likely some
    # Gatekeeper madness.

    # Source https://stackoverflow.com/a/32405815
    File.write(plist_file, <<~FILE)
      <?xml version="1.0" encoding="UTF-8"?>
      <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
      <plist version="1.0">
      <dict>
        <key>Label</key>
        <string>abevjava</string>
        <key>ProgramArguments</key>
        <array>
          <string>launchctl</string>
          <string>setenv</string>
          <string>JAVA_HOME_ABEV</string>
          <string>#{java_home}/bin/</string>
          <string>RUN_OPTS</string>
          <string>-Xdock:icon=#{install_path}/abevjava.ico</string>
        </array>
        <key>RunAtLoad</key>
        <true/>
      </dict>
      </plist>
    FILE

    system("launchctl", "load", plist_file, exception: true)
  end

  uninstall_preflight do
    system("launchctl", "unload", plist_file, exception: true)
  end

  uninstall delete: [
    install_path,
    plist_file,
  ]

  uninstall_postflight do
    # uninstall puts it back as "backup" but we don't need it
    FileUtils.rm_r(app_on_desktop, force: true)
  end

  zap trash: [
    "~/.abevjava"
  ]
end
