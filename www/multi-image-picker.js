var exec = require('cordova/exec');

var MultiImagePicker = function() {
};

MultiImagePicker.prototype.getPictures = function(success, fail, arg) {
	if (!arg) {
		arg = {};
	}
    if(arg.showCamera == null)  arg.showCamera = false;

    return exec(success, fail, "MultiImagePicker", "pick",
        [ arg.showCamera,
          arg.maxNum || 9,
          (arg.maxNum || 1) > 1,
          arg.selectedPath || [],
	  	  arg.style || {}]);
};

window.MultiImagePicker = new MultiImagePicker();
