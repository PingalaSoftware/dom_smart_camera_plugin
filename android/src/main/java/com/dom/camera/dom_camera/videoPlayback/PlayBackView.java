package com.dom.camera.dom_camera.videoPlayback;

import android.content.Context;
import android.view.View;
import android.view.ViewGroup;
import io.flutter.plugin.platform.PlatformView;

public class PlayBackView implements PlatformView {

  private final ViewGroup view;

  public PlayBackView(Context context, int viewId, ViewGroup view) {
    this.view = view;
  }

  @Override
  public View getView() {
    return view;
  }

  @Override
  public void dispose() {
    if (view != null && view.getParent() instanceof ViewGroup) {
      ViewGroup parentView = (ViewGroup) view.getParent();
      parentView.removeView(view);
    }
  }
}
