# ImagePicker Plugin for Cordova (iOS and Android)

This is a multi-image picker plugin for Cordova.

## Installation

The plugin conforms to the Cordova plugin specification, it can be installed using the Cordova command line interface.

```
cordova plugin add multi-image-picker
```

## Usage

```javascript
window.MultiImagePicker.getPictures(successCB, failCB, options);
```

- successCB
Callback function when image is selected.

- failCB
Callback function when no image is selected.

- options
See Options

## Options
**showCamera**
Type: Boolean
Default: `false`

**maxNum**
Maximum number of images to be selected, set to `1` to allow single image selection.
Type: Integer
Default: `9`

**selectedPath**
Preselected array of images for the image picker
Type: Array
Default: `[]`

**style**
Modify color for the image picker.
- themeColor `hexColor` default `#000000`
- textColor `hexColor` default `#ffffff`

## For Angular

See [cordova-plugin-imagepicker-angular](https://github.com/tanhauhau/cordova-plugin-imagepicker-angular).

## Library used

### GMImagePicker
Image picker library for iOS. This code uses the MIT license.

[GMImagePicker](https://github.com/guillermomuntaner/GMImagePicker)

### MultiImageSelector
Image picker library for Android. This code uses the MIT license.

[MultiImageSelector](https://github.com/lovetuzitong/MultiImageSelector)

### Fake R
Code(FakeR) was also taken from the phonegap BarCodeScanner plugin. This code uses the MIT license.

[https://github.com/wildabeast/BarcodeScanner](https://github.com/wildabeast/BarcodeScanner)

## License

The MIT License (MIT)

Copyright (c) 2016 Tan Li Hau

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
