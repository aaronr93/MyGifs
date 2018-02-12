source 'https://github.com/CocoaPods/Specs.git'
workspace 'Master.xcworkspace'

target 'MyGifs' do
	project 'MyGifs/MyGifs.xcodeproj'
	use_frameworks!
	inhibit_all_warnings!
	pod 'Texture'
	
	target 'MyGifsMessages' do
		pod 'Texture'
	end
end

target 'MyGifsKit' do
	project 'MyGifsKit/MyGifsKit.xcodeproj'
	use_frameworks!
	inhibit_all_warnings!
	pod 'Texture'

	target 'MyGifsKitTests' do
	end
end