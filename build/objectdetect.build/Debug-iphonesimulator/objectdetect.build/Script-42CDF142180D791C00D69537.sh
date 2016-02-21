#!/bin/sh
#!/bin/bash
buildNumber=$(/usr/libexec/PlistBuddy -c "Print CFBundleVersion" objectdetect/objectdetect-Info.plist)
buildNumber=$(($buildNumber + 1))
/usr/libexec/PlistBuddy -c "Set :CFBundleVersion $buildNumber" objectdetect/objectdetect-Info.plist
