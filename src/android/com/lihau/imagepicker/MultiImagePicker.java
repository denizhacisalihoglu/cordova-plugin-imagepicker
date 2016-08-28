package com.lihau.imagepicker;

import android.app.Activity;
import android.content.Intent;
import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaInterface;
import org.apache.cordova.CordovaInterfaceImpl;
import org.apache.cordova.CordovaPlugin;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.ArrayList;

import me.nereo.multi_image_selector.MultiImageSelectorActivity;

/**
 * Created by lhtan on 31/1/16.
 */
public class MultiImagePicker extends CordovaPlugin {

    private static final int REQUEST_IMAGE = 2;
    private CallbackContext callbackContext;

    /*
    pick
    0 - showCamera boolean
    1 - maxNum int
    2 - selectMulti boolean
    3 - selectedPath string[]
    4 - style {}
     */
    @Override
    public boolean execute(String action, JSONArray args, CallbackContext callbackContext) throws JSONException {
        this.callbackContext = callbackContext;

        if (action.equals("pick")) {
            //Get options
            boolean showCamera = args.getBoolean(0);
            int maxNum = args.getInt(1);
            boolean selectMulti = args.getBoolean(2);
            JSONArray paths = args.getJSONArray(3);
            JSONObject styleOptions = args.optJSONObject(4);
            String themeColor = "#000000";
            String textColor = "#ffffff";
            if (styleOptions != null) {
                themeColor = styleOptions.optString("themeColor", "#000000");
                textColor = styleOptions.optString("textColor", "#ffffff");
            }

            final int length = paths.length();
            ArrayList<String> selectedPaths = new ArrayList<String>();
            for(int i=0;i<length;i++){
                selectedPaths.add(paths.optJSONObject(i).optString("image"));
            }

            Intent intent = new Intent(cordova.getActivity(), MultiImageSelectorActivity.class);
            intent.putExtra(MultiImageSelectorActivity.EXTRA_SHOW_CAMERA, showCamera);

            intent.putExtra(MultiImageSelectorActivity.EXTRA_SELECT_COUNT, maxNum);

            if(!selectMulti){
                intent.putExtra(MultiImageSelectorActivity.EXTRA_SELECT_MODE, MultiImageSelectorActivity.MODE_SINGLE);
            }else{
                intent.putExtra(MultiImageSelectorActivity.EXTRA_SELECT_MODE, MultiImageSelectorActivity.MODE_MULTI);
            }
            // 默认选择
            if(selectedPaths != null && selectedPaths.size()>0){
                intent.putExtra(MultiImageSelectorActivity.EXTRA_DEFAULT_SELECTED_LIST, selectedPaths);
            }
            intent.putExtra(MultiImageSelectorActivity.EXTRA_THEME_COLOR, themeColor);
            intent.putExtra(MultiImageSelectorActivity.EXTRA_TEXT_COLOR, textColor);

            if(this.cordova != null){
                this.cordova.startActivityForResult(this, intent, REQUEST_IMAGE);
            }
            return true;
        }
        return false;
    }

    public void onActivityResult(int requestCode, int resultCode, Intent data) {
        if(requestCode == REQUEST_IMAGE){
            if(resultCode == Activity.RESULT_OK){
                ArrayList<String> selectedPaths = data.getStringArrayListExtra(MultiImageSelectorActivity.EXTRA_RESULT);
                JSONArray res = new JSONArray();
                for (String path : selectedPaths){
                    try {
                        JSONObject obj = new JSONObject();
                        obj.put("image", path);
                        res.put(obj);
                    }catch (Exception e){}
                }
                this.callbackContext.success(res);
            }else{
                this.callbackContext.error("Unknown error");
            }
        }
    }
}
