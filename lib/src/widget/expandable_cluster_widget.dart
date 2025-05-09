import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_popup/extension_api.dart';
import 'package:flutter_map_supercluster/src/layer/map_camera_extension.dart';
import 'package:flutter_map_supercluster/src/layer_element_extension.dart';
import 'package:flutter_map_supercluster/src/splay/popup_spec_builder.dart';
import 'package:flutter_map_supercluster/src/widget/cluster_widget.dart';
import 'package:flutter_map_supercluster/src/widget/expanded_cluster.dart';
import 'package:flutter_map_supercluster/src/widget/marker_widget.dart';

import '../layer/supercluster_layer.dart';

class ExpandableClusterWidget extends StatelessWidget {
  final MapCamera mapCamera;
  final ExpandedCluster expandedCluster;
  final ClusterWidgetBuilder builder;
  final Size size;
  final Alignment clusterAlignment;
  final Widget Function(BuildContext, Marker) markerBuilder;
  final void Function(PopupSpec popupSpec) onMarkerTap;
  final VoidCallback onCollapse;
  final Offset clusterPixelPosition;

  ExpandableClusterWidget({
    Key? key,
    required this.mapCamera,
    required this.expandedCluster,
    required this.builder,
    required this.size,
    required this.clusterAlignment,
    required this.markerBuilder,
    required this.onMarkerTap,
    required this.onCollapse,
  })  : clusterPixelPosition =
            mapCamera.getPixelOffset(expandedCluster.layerCluster.latLng),
        super(key: ValueKey('expandable-${expandedCluster.layerCluster.uuid}'));

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: expandedCluster.animation,
      builder: (context, _) {
        final displacedMarkerOffsets = expandedCluster.displacedMarkerOffsets(
          mapCamera,
          clusterPixelPosition,
        );
        final splayDecoration = expandedCluster.splayDecoration(
          displacedMarkerOffsets,
        );

        return Positioned.fill(
          child: Stack(
            children: [
              if (splayDecoration != null)
                Positioned(
                  left: clusterPixelPosition.dx - expandedCluster.splayDistance,
                  top: clusterPixelPosition.dy - expandedCluster.splayDistance,
                  width: expandedCluster.splayDistance * 2,
                  height: expandedCluster.splayDistance * 2,
                  child: splayDecoration,
                ),
              ...displacedMarkerOffsets.map(
                (offset) => MarkerWidget.displaced(
                  displacedMarker: offset.displacedMarker,
                  position: clusterPixelPosition + offset.displacedOffset,
                  markerChild: markerBuilder(
                    context,
                    offset.displacedMarker.marker,
                  ),
                  onTap: () => onMarkerTap(
                    PopupSpecBuilder.forDisplacedMarker(
                      offset.displacedMarker,
                      expandedCluster.minimumVisibleZoom,
                    ),
                  ),
                  mapRotationRad: mapCamera.rotationRad,
                ),
              ),
              ClusterWidget(
                mapCamera: mapCamera,
                cluster: expandedCluster.layerCluster,
                builder: (context, latLng, count, data) =>
                    expandedCluster.buildCluster(context, builder),
                onTap: expandedCluster.isExpanded ? onCollapse : () {},
                size: size,
                alignment: clusterAlignment,
              ),
            ],
          ),
        );
      },
    );
  }
}
