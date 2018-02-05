bundle=PSDTXT.app

go build -o bin/psd-parser psd-parser/main.go

# アプリケーションの作成
osacompile -o "${bundle}" <<__APPLESCRIPT__
on main(input)
    try
        do shell script (quoted form of POSIX path of (path to resource "psd-parser")) & space & input
    end try
end main

on open argv
    repeat with aFile in argv
        main(quoted form of POSIX path of aFile)
    end repeat
end open

on run
    main(quoted form of POSIX path of (choose file))
end run
__APPLESCRIPT__

# 拡張子関連付けの追加
while read
do
    /usr/libexec/PlistBuddy -c "${REPLY}" "${bundle}"/Contents/Info.plist
done <<__EOS__
Delete :CFBundleDocumentTypes array
Add :CFBundleDocumentTypes array
Add :CFBundleDocumentTypes:0:CFBundleTypeExtensions array
Add :CFBundleDocumentTypes:0:CFBundleTypeExtensions:0 string psd
Add :CFBundleDocumentTypes:0:CFBundleTypeName string PSD
Add :CFBundleDocumentTypes:0:CFBundleTypeRole string Viewer
__EOS__

mv bin/psd-parser ./${bundle}/Contents/Resources/
