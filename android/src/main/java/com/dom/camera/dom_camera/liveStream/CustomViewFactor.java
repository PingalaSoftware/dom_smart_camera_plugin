package com.dom.camera.dom_camera.liveStream;

import android.content.Context;
import android.view.ViewGroup;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import io.flutter.plugin.common.StandardMessageCodec;
import io.flutter.plugin.platform.PlatformView;
import io.flutter.plugin.platform.PlatformViewFactory;
import java.util.HashMap;
import java.util.Map;

public class CustomViewFactor extends PlatformViewFactory {

  private final ViewGroup view;
  private Map<Integer, CustomLiveView> liveViewMap;
  private boolean isMapped = false;

  public CustomViewFactor(ViewGroup view) {
    super(StandardMessageCodec.INSTANCE);
    this.view = view;
    this.liveViewMap = new HashMap<>();
  }

  @NonNull
  public CustomLiveView create(
    Context context,
    int viewId,
    @Nullable Object args
  ) {
    if (this.isMapped) {
      disposeView(viewId);
    }

    CustomLiveView customLiveView = new CustomLiveView(context, viewId, view);

    this.liveViewMap.put(viewId, customLiveView);
    this.isMapped = true;
    return customLiveView;
  }

  public void disposeView(int viewId) {
    this.isMapped = false;

    CustomLiveView customLiveView = liveViewMap.get(viewId);
    if (customLiveView != null) {
      customLiveView.dispose();
      liveViewMap.remove(viewId);
    }
  }
}
