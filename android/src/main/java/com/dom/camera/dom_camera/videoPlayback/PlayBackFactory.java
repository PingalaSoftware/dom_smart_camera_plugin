package com.example.camera_sdk.videoPlayback;

import android.content.Context;
import android.view.ViewGroup;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import com.dom.camera.dom_camera.videoPlayback.PlayBackView;
import io.flutter.plugin.common.StandardMessageCodec;
import io.flutter.plugin.platform.PlatformView;
import io.flutter.plugin.platform.PlatformViewFactory;
import java.util.HashMap;
import java.util.Map;

public class PlayBackFactory extends PlatformViewFactory {

  private final ViewGroup view;
  private Map<Integer, PlayBackView> liveViewMap;
  private boolean isMapped = false;

  public PlayBackFactory(ViewGroup view) {
    super(StandardMessageCodec.INSTANCE);
    this.view = view;
    this.liveViewMap = new HashMap<>();
  }

  @NonNull
  public PlayBackView create(
    Context context,
    int viewId,
    @Nullable Object args
  ) {
    if (this.isMapped) {
      disposeView(viewId);
    }

    PlayBackView playBackView = new PlayBackView(context, viewId, view);

    this.liveViewMap.put(viewId, playBackView);
    this.isMapped = true;
    return playBackView;
  }

  public void disposeView(int viewId) {
    this.isMapped = false;

    PlayBackView playBackView = liveViewMap.get(viewId);
    if (playBackView != null) {
      playBackView.dispose();
      liveViewMap.remove(viewId);
    }
  }
}
