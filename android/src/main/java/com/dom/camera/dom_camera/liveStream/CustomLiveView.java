package com.dom.camera.dom_camera.liveStream;

import android.content.Context;
import android.view.View;
import android.view.ViewGroup;
import androidx.annotation.Nullable;
import io.flutter.plugin.platform.PlatformView;

public class CustomLiveView implements PlatformView {

  private final ViewGroup view;

  public CustomLiveView(Context context, int viewId, ViewGroup view) {
    this.view = view;
  }

  @Nullable
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
