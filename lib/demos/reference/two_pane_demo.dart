// Copyright 2019 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/gallery_localizations.dart';

// BEGIN twoPaneDemo

enum TwoPaneDemoType {
  dualScreen,
  singleScreen,
  tablet,
}

class TwoPaneDemo extends StatefulWidget {
  const TwoPaneDemo({
    Key key,
    @required this.restorationId,
    @required this.type,
  }) : super(key: key);

  final String restorationId;
  final TwoPaneDemoType type;

  @override
  _TwoPaneDemoState createState() => _TwoPaneDemoState();
}

class _TwoPaneDemoState extends State<TwoPaneDemo> with RestorationMixin {
  final RestorableInt _currentIndex = RestorableInt(-1);

  @override
  String get restorationId => widget.restorationId;

  @override
  void restoreState(RestorationBucket oldBucket, bool initialRestore) {
    registerForRestoration(_currentIndex, 'two_pane_selected_item');
  }

  @override
  void dispose() {
    _currentIndex.dispose();
    super.dispose();
  }

  String _title(BuildContext context) {
    switch (widget.type) {
      case TwoPaneDemoType.dualScreen:
        return GalleryLocalizations.of(context).demoTwoPaneDualScreenLabel;
      case TwoPaneDemoType.singleScreen:
        return GalleryLocalizations.of(context).demoTwoPaneSingleScreenLabel;
      case TwoPaneDemoType.tablet:
        return GalleryLocalizations.of(context).demoTwoPaneTabletLabel;
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    var panePriority = TwoPanePriority.both;
    if (widget.type == TwoPaneDemoType.singleScreen) {
      panePriority = _currentIndex.value == -1 ? TwoPanePriority.pane1 : TwoPanePriority.pane2;
    }
    return SimulateScreen(
      type: widget.type,
      child: TwoPane(
        paneProportion: 0.3,
        panePriority: panePriority,
        pane1: ListPane(
          selectedIndex: _currentIndex.value,
          onSelect: (index) {
            setState(() {
              _currentIndex.value = index;
            });
          },
        ),
        pane2: DetailsPane(
          selectedIndex: _currentIndex.value,
          onClose: widget.type == TwoPaneDemoType.singleScreen
              ? () {
                  setState(() {
                    _currentIndex.value = -1;
                  });
                }
              : null,
        ),
      ),
    );
  }
}

class ListPane extends StatelessWidget {
  final ValueChanged<int> onSelect;
  final int selectedIndex;

  const ListPane({
    Key key,
    this.onSelect,
    this.selectedIndex,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('List'),
      ),
      body: Scrollbar(
        child: ListView(
          restorationId: 'list_demo_list_view',
          padding: const EdgeInsets.symmetric(vertical: 8),
          children: [
            for (int index = 1; index < 21; index++)
              ListTile(
                onTap: () {
                  onSelect(index);
                },
                selected: selectedIndex == index,
                leading: ExcludeSemantics(
                  child: CircleAvatar(child: Text('$index')),
                ),
                title: Text(
                  GalleryLocalizations.of(context).demoBottomSheetItem(index),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class DetailsPane extends StatelessWidget {
  final VoidCallback onClose;
  final int selectedIndex;

  const DetailsPane({
    Key key,
    this.selectedIndex,
    this.onClose,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: onClose == null ? null : IconButton(icon: const Icon(Icons.close), onPressed: onClose),
        title: Text('Details'),
      ),
      body: Container(
        color: Color(0xfffafafa),
        child: Center(
          child: Text(selectedIndex == -1
              ? 'Select an item'
              : 'Item $selectedIndex Details'),
        ),
      ),
    );
  }
}

class SimulateScreen extends StatelessWidget {
  const SimulateScreen({
    Key key,
    @required this.type,
    @required this.child,
  }) : super(key: key);

  final TwoPaneDemoType type;
  final TwoPane child;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xff000000),
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(14),
        child: AspectRatio(
          aspectRatio: type == TwoPaneDemoType.dualScreen
              ? 2784.0 / 1800.0
              : type == TwoPaneDemoType.tablet
                  ? 1.33
                  : 9.0 / 16.0,
          child: LayoutBuilder(builder: (context, constraints) {
            final size = Size(constraints.maxWidth, constraints.maxHeight);
            final hingeSize = Size(size.width / 35.0, size.height);
            final hingeBounds = Rect.fromLTWH(
                (size.width - hingeSize.width) / 2,
                0,
                hingeSize.width,
                hingeSize.height);
            return MediaQuery(
              data: MediaQueryData(size: size, displayFeatures: [
                if (type == TwoPaneDemoType.dualScreen)
                  DisplayFeature(
                      bounds: hingeBounds,
                      type: DisplayFeatureType.hinge,
                      state: DisplayFeatureState.postureFlat),
              ]),
              child: child,
            );
          }),
        ),
      ),
    );
  }
}

// END
