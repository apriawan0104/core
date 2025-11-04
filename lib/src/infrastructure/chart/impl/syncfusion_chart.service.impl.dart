import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart' as sf;
import 'package:syncfusion_flutter_charts/sparkcharts.dart' as spark;

import '../../../errors/chart_failure.dart';
import '../../../errors/failures.dart';
import '../../../foundation/domain/entities/chart/entities.dart';
import '../constants/chart.constant.dart';
import '../contract/chart.service.dart';

/// Syncfusion Charts implementation of ChartService
///
/// This implementation wraps Syncfusion Flutter Charts library.
/// It converts generic ChartConfig entities to Syncfusion-specific widgets.
///
/// Following Dependency Independence principle:
/// - External consumers never see Syncfusion types
/// - Can be easily replaced with another chart library
/// - All Syncfusion-specific code is contained in this file
class SyncfusionChartServiceImpl implements ChartService {
  @override
  Either<Failure, Widget> buildCartesianChart(ChartConfig config) {
    try {
      // Validate configuration
      if (config.series.isEmpty) {
        return Left(ChartFailure.emptyData());
      }

      // Check if all series types are cartesian
      for (final series in config.series) {
        if (!_isCartesianType(series.type)) {
          return Left(
            ChartFailure.unsupportedChartType(
              '${series.type} is not a cartesian chart type',
            ),
          );
        }
      }

      final chart = sf.SfCartesianChart(
        title: config.title != null
            ? sf.ChartTitle(text: config.title!)
            : sf.ChartTitle(text: ''),
        primaryXAxis: _buildXAxis(config.primaryXAxis),
        primaryYAxis: _buildYAxis(config.primaryYAxis),
        legend: _buildLegend(config.legendConfig),
        tooltipBehavior: _buildTooltipBehavior(config.tooltipConfig),
        backgroundColor: config.backgroundColor != null
            ? _parseColor(config.backgroundColor!)
            : null,
        enableAxisAnimation: true,
        series: _buildCartesianSeriesList(config.series),
        margin: config.margin != null
            ? EdgeInsets.only(
                top: config.margin!.top,
                bottom: config.margin!.bottom,
                left: config.margin!.left,
                right: config.margin!.right,
              )
            : const EdgeInsets.all(0),
        zoomPanBehavior: config.enableZoomPan
            ? sf.ZoomPanBehavior(
                enablePanning: true,
                enablePinching: true,
                enableDoubleTapZooming: true,
              )
            : null,
        selectionGesture: config.enableSelection
            ? sf.ActivationMode.singleTap
            : sf.ActivationMode.none,
        palette: config.paletteColors?.map(_parseColor).toList(),
      );

      return Right(chart);
    } catch (e) {
      return Left(ChartFailure.renderError(e.toString()));
    }
  }

  @override
  Either<Failure, Widget> buildCircularChart(ChartConfig config) {
    try {
      if (config.series.isEmpty) {
        return Left(ChartFailure.emptyData());
      }

      if (config.series.length > 1) {
        return Left(
          ChartFailure.invalidConfiguration(
            'Circular charts support only one series',
          ),
        );
      }

      final series = config.series.first;

      if (!_isCircularType(series.type)) {
        return Left(
          ChartFailure.unsupportedChartType(
            '${series.type} is not a circular chart type',
          ),
        );
      }

      final chart = sf.SfCircularChart(
        title: config.title != null
            ? sf.ChartTitle(text: config.title!)
            : sf.ChartTitle(text: ''),
        legend: _buildLegend(config.legendConfig),
        tooltipBehavior: _buildTooltipBehavior(config.tooltipConfig),
        backgroundColor: config.backgroundColor != null
            ? _parseColor(config.backgroundColor!)
            : null,
        series: _buildCircularSeriesList([series]),
        margin: config.margin != null
            ? EdgeInsets.only(
                top: config.margin!.top,
                bottom: config.margin!.bottom,
                left: config.margin!.left,
                right: config.margin!.right,
              )
            : const EdgeInsets.all(0),
        palette: config.paletteColors?.map(_parseColor).toList(),
      );

      return Right(chart);
    } catch (e) {
      return Left(ChartFailure.renderError(e.toString()));
    }
  }

  @override
  Either<Failure, Widget> buildPyramidChart(ChartConfig config) {
    try {
      if (config.series.isEmpty) {
        return Left(ChartFailure.emptyData());
      }

      if (config.series.length > 1) {
        return Left(
          ChartFailure.invalidConfiguration(
            'Pyramid charts support only one series',
          ),
        );
      }

      final series = config.series.first;

      final chart = sf.SfPyramidChart(
        title: config.title != null
            ? sf.ChartTitle(text: config.title!)
            : sf.ChartTitle(text: ''),
        legend: _buildLegend(config.legendConfig),
        tooltipBehavior: _buildTooltipBehavior(config.tooltipConfig),
        backgroundColor: config.backgroundColor != null
            ? _parseColor(config.backgroundColor!)
            : null,
        series: _buildPyramidSeries(series),
        margin: config.margin != null
            ? EdgeInsets.only(
                top: config.margin!.top,
                bottom: config.margin!.bottom,
                left: config.margin!.left,
                right: config.margin!.right,
              )
            : const EdgeInsets.all(0),
        palette: config.paletteColors?.map(_parseColor).toList(),
      );

      return Right(chart);
    } catch (e) {
      return Left(ChartFailure.renderError(e.toString()));
    }
  }

  @override
  Either<Failure, Widget> buildFunnelChart(ChartConfig config) {
    try {
      if (config.series.isEmpty) {
        return Left(ChartFailure.emptyData());
      }

      if (config.series.length > 1) {
        return Left(
          ChartFailure.invalidConfiguration(
            'Funnel charts support only one series',
          ),
        );
      }

      final series = config.series.first;

      final chart = sf.SfFunnelChart(
        title: config.title != null
            ? sf.ChartTitle(text: config.title!)
            : sf.ChartTitle(text: ''),
        legend: _buildLegend(config.legendConfig),
        tooltipBehavior: _buildTooltipBehavior(config.tooltipConfig),
        backgroundColor: config.backgroundColor != null
            ? _parseColor(config.backgroundColor!)
            : null,
        series: _buildFunnelSeries(series),
        margin: config.margin != null
            ? EdgeInsets.only(
                top: config.margin!.top,
                bottom: config.margin!.bottom,
                left: config.margin!.left,
                right: config.margin!.right,
              )
            : const EdgeInsets.all(0),
        palette: config.paletteColors?.map(_parseColor).toList(),
      );

      return Right(chart);
    } catch (e) {
      return Left(ChartFailure.renderError(e.toString()));
    }
  }

  @override
  Either<Failure, Widget> buildSparkline({
    required List<double> data,
    required SparklineType type,
    double? width,
    double? height,
    String? color,
    bool showTooltip = true,
  }) {
    try {
      if (data.isEmpty) {
        return Left(ChartFailure.emptyData());
      }

      final Color? sparkColor = color != null ? _parseColor(color) : null;

      final Widget sparkChart = switch (type) {
        SparklineType.line => spark.SfSparkLineChart(
            data: data,
            color: sparkColor,
            trackball: showTooltip
                ? const spark.SparkChartTrackball(
                    activationMode: spark.SparkChartActivationMode.tap,
                  )
                : null,
          ),
        SparklineType.area => spark.SfSparkAreaChart(
            data: data,
            color: sparkColor,
            trackball: showTooltip
                ? const spark.SparkChartTrackball(
                    activationMode: spark.SparkChartActivationMode.tap,
                  )
                : null,
          ),
        SparklineType.bar => spark.SfSparkBarChart(
            data: data,
            color: sparkColor,
            trackball: showTooltip
                ? const spark.SparkChartTrackball(
                    activationMode: spark.SparkChartActivationMode.tap,
                  )
                : null,
          ),
        SparklineType.winLoss => spark.SfSparkWinLossChart(
            data: data,
            tiePointColor: sparkColor,
            trackball: showTooltip
                ? const spark.SparkChartTrackball(
                    activationMode: spark.SparkChartActivationMode.tap,
                  )
                : null,
          ),
      };

      // Wrap with SizedBox for width and/or height
      if (width != null || height != null) {
        return Right(
          SizedBox(
            width: width ?? ChartConstants.defaultSparklineWidth,
            height: height ?? ChartConstants.defaultSparklineHeight,
            child: sparkChart,
          ),
        );
      }

      return Right(sparkChart);
    } catch (e) {
      return Left(ChartFailure.renderError(e.toString()));
    }
  }

  @override
  bool supportsChartType(ChartType type) {
    return _isCartesianType(type) ||
        _isCircularType(type) ||
        type == ChartType.pyramid ||
        type == ChartType.funnel;
  }

  @override
  bool supportsSparklineType(SparklineType type) {
    // Syncfusion supports all sparkline types
    return true;
  }

  // ========== Private Helper Methods ==========

  bool _isCartesianType(ChartType type) {
    return type == ChartType.line ||
        type == ChartType.spline ||
        type == ChartType.area ||
        type == ChartType.splineArea ||
        type == ChartType.column ||
        type == ChartType.bar ||
        type == ChartType.stepLine ||
        type == ChartType.stepArea ||
        type == ChartType.scatter ||
        type == ChartType.bubble ||
        type == ChartType.rangeColumn ||
        type == ChartType.rangeArea ||
        type == ChartType.splineRangeArea ||
        type == ChartType.candle ||
        type == ChartType.hilo ||
        type == ChartType.ohlc ||
        type == ChartType.stackedColumn ||
        type == ChartType.stackedBar ||
        type == ChartType.stackedArea ||
        type == ChartType.stackedLine ||
        type == ChartType.stackedColumn100 ||
        type == ChartType.stackedBar100 ||
        type == ChartType.stackedArea100 ||
        type == ChartType.stackedLine100 ||
        type == ChartType.histogram ||
        type == ChartType.waterfall;
  }

  bool _isCircularType(ChartType type) {
    return type == ChartType.pie ||
        type == ChartType.doughnut ||
        type == ChartType.radialBar;
  }

  sf.ChartAxis _buildXAxis(ChartAxisConfig? config) {
    if (config == null) {
      return sf.CategoryAxis();
    }

    return switch (config.type) {
      AxisType.numeric => sf.NumericAxis(
          title: sf.AxisTitle(text: config.title ?? ''),
          minimum: config.minimum,
          maximum: config.maximum,
          interval: config.interval,
          isVisible: config.isVisible,
          majorGridLines: sf.MajorGridLines(
            width: config.showGridLines ? 1 : 0,
          ),
        ),
      AxisType.category => sf.CategoryAxis(
          title: sf.AxisTitle(text: config.title ?? ''),
          isVisible: config.isVisible,
          majorGridLines: sf.MajorGridLines(
            width: config.showGridLines ? 1 : 0,
          ),
        ),
      AxisType.dateTime => sf.DateTimeAxis(
          title: sf.AxisTitle(text: config.title ?? ''),
          isVisible: config.isVisible,
          majorGridLines: sf.MajorGridLines(
            width: config.showGridLines ? 1 : 0,
          ),
        ),
      AxisType.dateTimeCategory => sf.DateTimeCategoryAxis(
          title: sf.AxisTitle(text: config.title ?? ''),
          isVisible: config.isVisible,
          majorGridLines: sf.MajorGridLines(
            width: config.showGridLines ? 1 : 0,
          ),
        ),
      AxisType.logarithmic => sf.LogarithmicAxis(
          title: sf.AxisTitle(text: config.title ?? ''),
          isVisible: config.isVisible,
          majorGridLines: sf.MajorGridLines(
            width: config.showGridLines ? 1 : 0,
          ),
        ),
    };
  }

  sf.ChartAxis _buildYAxis(ChartAxisConfig? config) {
    if (config == null) {
      return sf.NumericAxis();
    }

    // Y-axis typically numeric or logarithmic
    return switch (config.type) {
      AxisType.numeric ||
      AxisType.category ||
      AxisType.dateTime ||
      AxisType.dateTimeCategory =>
        sf.NumericAxis(
          title: sf.AxisTitle(text: config.title ?? ''),
          minimum: config.minimum,
          maximum: config.maximum,
          interval: config.interval,
          isVisible: config.isVisible,
          majorGridLines: sf.MajorGridLines(
            width: config.showGridLines ? 1 : 0,
          ),
        ),
      AxisType.logarithmic => sf.LogarithmicAxis(
          title: sf.AxisTitle(text: config.title ?? ''),
          isVisible: config.isVisible,
          majorGridLines: sf.MajorGridLines(
            width: config.showGridLines ? 1 : 0,
          ),
        ),
    };
  }

  sf.Legend _buildLegend(ChartLegendConfig? config) {
    if (config == null) {
      return const sf.Legend(isVisible: true);
    }

    return sf.Legend(
      isVisible: config.isVisible,
      position: _mapLegendPosition(config.position),
      toggleSeriesVisibility: config.toggleSeriesVisibility,
      alignment: _mapLegendAlignment(config.alignment),
    );
  }

  sf.LegendPosition _mapLegendPosition(LegendPosition position) {
    return switch (position) {
      LegendPosition.top => sf.LegendPosition.top,
      LegendPosition.bottom => sf.LegendPosition.bottom,
      LegendPosition.left => sf.LegendPosition.left,
      LegendPosition.right => sf.LegendPosition.right,
    };
  }

  sf.ChartAlignment _mapLegendAlignment(LegendAlignment alignment) {
    return switch (alignment) {
      LegendAlignment.start => sf.ChartAlignment.near,
      LegendAlignment.center => sf.ChartAlignment.center,
      LegendAlignment.end => sf.ChartAlignment.far,
    };
  }

  sf.TooltipBehavior? _buildTooltipBehavior(ChartTooltipConfig? config) {
    if (config == null || !config.enable) {
      return null;
    }

    return sf.TooltipBehavior(
      enable: true,
      activationMode: _mapTooltipActivationMode(config.activationMode),
      format: config.format,
    );
  }

  sf.ActivationMode _mapTooltipActivationMode(TooltipActivationMode mode) {
    return switch (mode) {
      TooltipActivationMode.tap => sf.ActivationMode.singleTap,
      TooltipActivationMode.longPress => sf.ActivationMode.longPress,
      TooltipActivationMode.doubleTap => sf.ActivationMode.doubleTap,
      TooltipActivationMode.none => sf.ActivationMode.none,
    };
  }

  List<sf.CartesianSeries> _buildCartesianSeriesList(List<ChartSeries> series) {
    return series.map(_buildCartesianSeries).toList();
  }

  sf.CartesianSeries _buildCartesianSeries(ChartSeries series) {
    final dataSource = series.dataPoints;
    final color = series.color != null ? _parseColor(series.color!) : null;
    final dataLabelSettings = sf.DataLabelSettings(
      isVisible: series.showDataLabels,
    );

    return switch (series.type) {
      ChartType.line => sf.LineSeries<ChartDataPoint, dynamic>(
          name: series.name,
          dataSource: dataSource,
          xValueMapper: (ChartDataPoint point, _) => point.x,
          yValueMapper: (ChartDataPoint point, _) => point.y,
          color: color,
          dataLabelSettings: dataLabelSettings,
          enableTooltip: series.enableTooltip,
          width: series.lineWidth ?? ChartConstants.defaultLineWidth,
          opacity: series.opacity,
        ),
      ChartType.spline => sf.SplineSeries<ChartDataPoint, dynamic>(
          name: series.name,
          dataSource: dataSource,
          xValueMapper: (ChartDataPoint point, _) => point.x,
          yValueMapper: (ChartDataPoint point, _) => point.y,
          color: color,
          dataLabelSettings: dataLabelSettings,
          enableTooltip: series.enableTooltip,
          width: series.lineWidth ?? ChartConstants.defaultLineWidth,
          opacity: series.opacity,
        ),
      ChartType.area => sf.AreaSeries<ChartDataPoint, dynamic>(
          name: series.name,
          dataSource: dataSource,
          xValueMapper: (ChartDataPoint point, _) => point.x,
          yValueMapper: (ChartDataPoint point, _) => point.y,
          color: color,
          dataLabelSettings: dataLabelSettings,
          enableTooltip: series.enableTooltip,
          opacity: series.opacity,
        ),
      ChartType.splineArea => sf.SplineAreaSeries<ChartDataPoint, dynamic>(
          name: series.name,
          dataSource: dataSource,
          xValueMapper: (ChartDataPoint point, _) => point.x,
          yValueMapper: (ChartDataPoint point, _) => point.y,
          color: color,
          dataLabelSettings: dataLabelSettings,
          enableTooltip: series.enableTooltip,
          opacity: series.opacity,
        ),
      ChartType.column => sf.ColumnSeries<ChartDataPoint, dynamic>(
          name: series.name,
          dataSource: dataSource,
          xValueMapper: (ChartDataPoint point, _) => point.x,
          yValueMapper: (ChartDataPoint point, _) => point.y,
          color: color,
          dataLabelSettings: dataLabelSettings,
          enableTooltip: series.enableTooltip,
          opacity: series.opacity,
        ),
      ChartType.bar => sf.BarSeries<ChartDataPoint, dynamic>(
          name: series.name,
          dataSource: dataSource,
          xValueMapper: (ChartDataPoint point, _) => point.x,
          yValueMapper: (ChartDataPoint point, _) => point.y,
          color: color,
          dataLabelSettings: dataLabelSettings,
          enableTooltip: series.enableTooltip,
          opacity: series.opacity,
        ),
      ChartType.scatter => sf.ScatterSeries<ChartDataPoint, dynamic>(
          name: series.name,
          dataSource: dataSource,
          xValueMapper: (ChartDataPoint point, _) => point.x,
          yValueMapper: (ChartDataPoint point, _) => point.y,
          color: color,
          dataLabelSettings: dataLabelSettings,
          enableTooltip: series.enableTooltip,
          opacity: series.opacity,
        ),
      ChartType.bubble => sf.BubbleSeries<ChartDataPoint, dynamic>(
          name: series.name,
          dataSource: dataSource,
          xValueMapper: (ChartDataPoint point, _) => point.x,
          yValueMapper: (ChartDataPoint point, _) => point.y,
          sizeValueMapper: (ChartDataPoint point, _) => point.size ?? 10,
          color: color,
          dataLabelSettings: dataLabelSettings,
          enableTooltip: series.enableTooltip,
          opacity: series.opacity,
        ),
      ChartType.stepLine => sf.StepLineSeries<ChartDataPoint, dynamic>(
          name: series.name,
          dataSource: dataSource,
          xValueMapper: (ChartDataPoint point, _) => point.x,
          yValueMapper: (ChartDataPoint point, _) => point.y,
          color: color,
          dataLabelSettings: dataLabelSettings,
          enableTooltip: series.enableTooltip,
          width: series.lineWidth ?? ChartConstants.defaultLineWidth,
          opacity: series.opacity,
        ),
      ChartType.stepArea => sf.StepAreaSeries<ChartDataPoint, dynamic>(
          name: series.name,
          dataSource: dataSource,
          xValueMapper: (ChartDataPoint point, _) => point.x,
          yValueMapper: (ChartDataPoint point, _) => point.y,
          color: color,
          dataLabelSettings: dataLabelSettings,
          enableTooltip: series.enableTooltip,
          opacity: series.opacity,
        ),
      ChartType.candle => sf.CandleSeries<ChartDataPoint, dynamic>(
          name: series.name,
          dataSource: dataSource,
          xValueMapper: (ChartDataPoint point, _) => point.x,
          lowValueMapper: (ChartDataPoint point, _) => point.low ?? 0,
          highValueMapper: (ChartDataPoint point, _) => point.high ?? 0,
          openValueMapper: (ChartDataPoint point, _) => point.open ?? 0,
          closeValueMapper: (ChartDataPoint point, _) => point.close ?? 0,
          dataLabelSettings: dataLabelSettings,
          enableTooltip: series.enableTooltip,
          opacity: series.opacity,
        ),
      ChartType.stackedColumn =>
        sf.StackedColumnSeries<ChartDataPoint, dynamic>(
          name: series.name,
          dataSource: dataSource,
          xValueMapper: (ChartDataPoint point, _) => point.x,
          yValueMapper: (ChartDataPoint point, _) => point.y,
          color: color,
          dataLabelSettings: dataLabelSettings,
          enableTooltip: series.enableTooltip,
          opacity: series.opacity,
        ),
      ChartType.stackedBar => sf.StackedBarSeries<ChartDataPoint, dynamic>(
          name: series.name,
          dataSource: dataSource,
          xValueMapper: (ChartDataPoint point, _) => point.x,
          yValueMapper: (ChartDataPoint point, _) => point.y,
          color: color,
          dataLabelSettings: dataLabelSettings,
          enableTooltip: series.enableTooltip,
          opacity: series.opacity,
        ),
      ChartType.stackedArea => sf.StackedAreaSeries<ChartDataPoint, dynamic>(
          name: series.name,
          dataSource: dataSource,
          xValueMapper: (ChartDataPoint point, _) => point.x,
          yValueMapper: (ChartDataPoint point, _) => point.y,
          color: color,
          dataLabelSettings: dataLabelSettings,
          enableTooltip: series.enableTooltip,
          opacity: series.opacity,
        ),
      ChartType.stackedLine => sf.StackedLineSeries<ChartDataPoint, dynamic>(
          name: series.name,
          dataSource: dataSource,
          xValueMapper: (ChartDataPoint point, _) => point.x,
          yValueMapper: (ChartDataPoint point, _) => point.y,
          color: color,
          dataLabelSettings: dataLabelSettings,
          enableTooltip: series.enableTooltip,
          width: series.lineWidth ?? ChartConstants.defaultLineWidth,
          opacity: series.opacity,
        ),
      // Add more chart types as needed
      _ => sf.LineSeries<ChartDataPoint, dynamic>(
          name: series.name,
          dataSource: dataSource,
          xValueMapper: (ChartDataPoint point, _) => point.x,
          yValueMapper: (ChartDataPoint point, _) => point.y,
          color: color,
          dataLabelSettings: dataLabelSettings,
          enableTooltip: series.enableTooltip,
          opacity: series.opacity,
        ),
    };
  }

  List<sf.CircularSeries> _buildCircularSeriesList(List<ChartSeries> series) {
    return series.map(_buildCircularSeries).toList();
  }

  sf.CircularSeries _buildCircularSeries(ChartSeries series) {
    final dataSource = series.dataPoints;
    final dataLabelSettings = sf.DataLabelSettings(
      isVisible: series.showDataLabels,
    );

    return switch (series.type) {
      ChartType.pie => sf.PieSeries<ChartDataPoint, dynamic>(
          name: series.name,
          dataSource: dataSource,
          xValueMapper: (ChartDataPoint point, _) => point.x,
          yValueMapper: (ChartDataPoint point, _) => point.y,
          dataLabelSettings: dataLabelSettings,
          enableTooltip: series.enableTooltip,
          opacity: series.opacity,
        ),
      ChartType.doughnut => sf.DoughnutSeries<ChartDataPoint, dynamic>(
          name: series.name,
          dataSource: dataSource,
          xValueMapper: (ChartDataPoint point, _) => point.x,
          yValueMapper: (ChartDataPoint point, _) => point.y,
          dataLabelSettings: dataLabelSettings,
          enableTooltip: series.enableTooltip,
          opacity: series.opacity,
        ),
      ChartType.radialBar => sf.RadialBarSeries<ChartDataPoint, dynamic>(
          name: series.name,
          dataSource: dataSource,
          xValueMapper: (ChartDataPoint point, _) => point.x,
          yValueMapper: (ChartDataPoint point, _) => point.y,
          dataLabelSettings: dataLabelSettings,
          enableTooltip: series.enableTooltip,
          opacity: series.opacity,
        ),
      _ => sf.PieSeries<ChartDataPoint, dynamic>(
          name: series.name,
          dataSource: dataSource,
          xValueMapper: (ChartDataPoint point, _) => point.x,
          yValueMapper: (ChartDataPoint point, _) => point.y,
          dataLabelSettings: dataLabelSettings,
          enableTooltip: series.enableTooltip,
          opacity: series.opacity,
        ),
    };
  }

  sf.PyramidSeries<ChartDataPoint, dynamic> _buildPyramidSeries(
    ChartSeries series,
  ) {
    return sf.PyramidSeries<ChartDataPoint, dynamic>(
      name: series.name,
      dataSource: series.dataPoints,
      xValueMapper: (ChartDataPoint point, _) => point.x,
      yValueMapper: (ChartDataPoint point, _) => point.y,
      dataLabelSettings: sf.DataLabelSettings(
        isVisible: series.showDataLabels,
      ),
      opacity: series.opacity,
    );
  }

  sf.FunnelSeries<ChartDataPoint, dynamic> _buildFunnelSeries(
    ChartSeries series,
  ) {
    return sf.FunnelSeries<ChartDataPoint, dynamic>(
      name: series.name,
      dataSource: series.dataPoints,
      xValueMapper: (ChartDataPoint point, _) => point.x,
      yValueMapper: (ChartDataPoint point, _) => point.y,
      dataLabelSettings: sf.DataLabelSettings(
        isVisible: series.showDataLabels,
      ),
      opacity: series.opacity,
    );
  }

  Color _parseColor(String hexColor) {
    final hex = hexColor.replaceAll('#', '');
    if (hex.length == 6) {
      return Color(int.parse('FF$hex', radix: 16));
    } else if (hex.length == 8) {
      return Color(int.parse(hex, radix: 16));
    }
    return Colors.blue; // Default color
  }
}
