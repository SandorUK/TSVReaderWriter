Pod::Spec.new do |s|
  s.name         = "TSVReaderWriter"
  s.version      = "0.0.1"
  s.summary      = "A short description of TSVReaderWriter."

  s.description  = <<-DESC
                   A longer description of TSVReaderWriter in Markdown format.

                   * Think: Why did you write this? What is the focus? What does it do?
                   * CocoaPods will be using this to generate tags, and improve search results.
                   * Try to keep it short, snappy and to the point.
                   * Finally, don't worry about the indent, CocoaPods strips it!
                   DESC

  s.homepage     = "http://EXAMPLE/TSVReaderWriter"
  s.license      = {:type => 'MIT', :file => 'LICENSE'}
  s.author             = { "Sandor Kolotenko" => "s" }
  s.social_media_url   = "http://twitter.com/iSandor"

  s.platform     = :ios
  s.platform     = :ios, "5.0"
  s.source       = { :git => "http://EXAMPLE/TSVReaderWriter.git", :tag => "0.0.1" }


  s.source_files  = "Classes", "Classes/**/*.{h,m}"
  s.exclude_files = "Classes/Exclude"

  s.resources = "Resources/*.png"
end
