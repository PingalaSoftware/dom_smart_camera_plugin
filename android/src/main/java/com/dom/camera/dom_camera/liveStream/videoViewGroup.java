package com.dom.camera.dom_camera.liveStream;

import android.content.Context;
import android.util.AttributeSet;
import android.widget.FrameLayout;

public class videoViewGroup extends FrameLayout {

  public videoViewGroup(Context context) {
    super(context);
  }

  public videoViewGroup(Context context, AttributeSet attrs) {
    super(context, attrs);
  }

  public videoViewGroup(Context context, AttributeSet attrs, int defStyleAttr) {
    super(context, attrs, defStyleAttr);
  }

  @Override
  protected void onMeasure(int widthMeasureSpec, int heightMeasureSpec) {
    int originalWidth = MeasureSpec.getSize(widthMeasureSpec);
    int originalHeight = MeasureSpec.getSize(heightMeasureSpec);

    int calculatedHeight = originalWidth * 9 / 16; // 16:9 aspect ratio

    int finalWidth, finalHeight;

    if (calculatedHeight <= originalHeight) {
      finalWidth = originalWidth;
      finalHeight = calculatedHeight;
    } else {
      finalWidth = originalHeight * 16 / 9;
      finalHeight = originalHeight;
    }

    super.onMeasure(
      MeasureSpec.makeMeasureSpec(finalWidth, MeasureSpec.EXACTLY),
      MeasureSpec.makeMeasureSpec(finalHeight, MeasureSpec.EXACTLY)
    );
  }
}
