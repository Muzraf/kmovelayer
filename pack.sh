rm kmovelayer.aseprite-extension
pushd ..
zip -u kmovelayer.aseprite-extension kmovelayer/kmovelayer.lua kmovelayer/package.json kmovelayer/extension-keys.aseprite-keys
mv kmovelayer.aseprite-extension kmovelayer/
popd
