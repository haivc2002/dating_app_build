import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../common/extension/gradient.dart';
import '../common/textstyles.dart';
import '../theme/theme_color.dart';
import '../theme/theme_notifier.dart';

class ItemParallax extends StatelessWidget {
  final int? index;
  final String? title, subTitle;
  final String? image;
  final double? height, width;
  final bool? itemNew;
  const ItemParallax({
    super.key,
    this.index,
    this.image,
    this.title,
    this.subTitle,
    this.height,
    this.width,
    this.itemNew
  });

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.w),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10.w),
        child: Container(
          height: 130.w,
          color: themeNotifier.systemThemeFade,
          child: Stack(
            alignment: Alignment.topRight,
            children: [
              _itemImage(context),
              _itemInfo(context, themeNotifier),
            ],
          ),
        ),
      ),
    );
  }

  Widget _itemImage(BuildContext context) {
    return Hero(
      tag: '$index',
      child: Flow(
        delegate: ParallaxFlowDelegate(
          scrollable: Scrollable.of(context),
          itemContext: context,
        ),
        children: [
          SizedBox(
            width: width,
            height: height,
            child: CachedNetworkImage(
              imageUrl: image ?? '',
              fit: BoxFit.cover,
              errorWidget: (context, url, error) => const SizedBox(),
              progressIndicatorBuilder: (context, url, progress) => SizedBox(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _itemInfo(BuildContext context, ThemeNotifier themeNotifier) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Spacer(),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: GradientColor.gradientBlackFade
          ),
          child: SizedBox(
            height: 50.w,
            width: double.infinity,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.w),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      title??'',
                      style: TextStyles.defaultStyle
                          .bold
                          .setTextSize(13.sp)
                          .setColor(ThemeColor.whiteColor),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100.w),
                        border: Border.all(color: ThemeColor.whiteColor, width: 1.5),
                        color: ThemeColor.whiteColor.withOpacity(0.7)
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.w),
                        child: Text(
                          subTitle??'',
                          style: TextStyles
                              .defaultStyle
                              .setColor(ThemeColor.pinkColor)
                              .setTextSize(9.sp).bold,
                          maxLines: 1,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        )
      ],
    );
  }
}

class ParallaxFlowDelegate extends FlowDelegate {
  final ScrollableState? scrollable;
  final BuildContext itemContext;

  ParallaxFlowDelegate({
    required this.scrollable,
    required this.itemContext,
  }) : super(repaint: scrollable?.position);

  @override
  BoxConstraints getConstraintsForChild(int i, BoxConstraints constraints) =>
      BoxConstraints.tightFor(width: constraints.maxWidth);

  @override
  void paintChildren(FlowPaintingContext context) {
    if (scrollable == null) return;

    final scrollableBox = scrollable!.context.findRenderObject() as RenderBox;
    final itemBox = itemContext.findRenderObject() as RenderBox;
    final itemOffset = itemBox.localToGlobal(
      itemBox.size.centerLeft(Offset.zero),
      ancestor: scrollableBox,
    );
    final viewportDimension = scrollable!.position.viewportDimension;
    final scrollFraction =
    (itemOffset.dy / viewportDimension).clamp(0, 1);
    final verticalAlignment = Alignment(0, scrollFraction * 6 - 1);
    final imageBox = context.getChildSize(0)!;
    final childRect =
    verticalAlignment.inscribe(imageBox, Offset.zero & context.size);

    context.paintChild(0, transform: Transform.translate(offset: Offset(0, childRect.top)).transform);
  }

  @override
  bool shouldRepaint(covariant FlowDelegate oldDelegate) {
    return true;
  }
}


