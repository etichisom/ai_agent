import 'package:flutter/material.dart';
import 'package:json_schema_builder/json_schema_builder.dart';
import 'package:genui/genui.dart';

final _heatMapSchema = S.object(
  properties: {
    'matrix': S.object(
      description:
      '2D matrix of numeric values representing intensities or magnitudes.',
      properties: {
        'literalArray': S.list(
          items: S.list(items: S.number()),
          description: 'List of lists (rows of numeric values)',
        ),
      },
    ),
    'xLabels': A2uiSchemas.stringArrayReference(
      description: 'Labels for X-axis (columns)',
    ),
    'yLabels': A2uiSchemas.stringArrayReference(
      description: 'Labels for Y-axis (rows)',
    ),
    'title': A2uiSchemas.stringReference(description: 'Chart title.'),
  },
  required: ['matrix', 'xLabels', 'yLabels'],
);

final heatMap = CatalogItem(
  name: 'HeatMap',
  dataSchema: _heatMapSchema,
  widgetBuilder: (ctx) {
    final json = ctx.data as Map<String, dynamic>;
    final title = json['title']?['literalString'] ?? 'Heat Map';
    final xLabels = (json['xLabels']?['literalArray'] as List?)?.cast<String>() ?? [];
    final yLabels = (json['yLabels']?['literalArray'] as List?)?.cast<String>() ?? [];
    final matrix =
        (json['matrix']?['literalArray'] as List?)?.cast<List<dynamic>>() ?? [];

    if (matrix.isEmpty) {
      return const Center(child: Text('No data available'));
    }

    // Compute value range for color scaling
    final flat = matrix.expand((row) => row.cast<num>()).toList();
    final minVal = flat.reduce((a, b) => a < b ? a : b).toDouble();
    final maxVal = flat.reduce((a, b) => a > b ? a : b).toDouble();

    Color getColor(double v) {
      final t = (v - minVal) / (maxVal - minVal + 0.0001);
      // Gradient from blue → green → yellow → red
      return HSVColor.lerp(
        const HSVColor.fromAHSV(1, 240, 1, 1), // blue
        const HSVColor.fromAHSV(1, 0, 1, 1),   // red
        t,
      )!
          .toColor();
    }

    return Card(
      elevation: 3,
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(ctx.buildContext).textTheme.titleMedium),
            const SizedBox(height: 8),
            // Heatmap grid
            Table(
              defaultColumnWidth: const IntrinsicColumnWidth(),
              children: [
                // Header row (x-axis labels)
                TableRow(
                  children: [
                    const SizedBox(width: 40),
                    for (final x in xLabels)
                      Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Text(
                          x,
                          style: const TextStyle(
                              fontSize: 11, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      ),
                  ],
                ),
                // Rows
                for (int i = 0; i < matrix.length; i++)
                  TableRow(
                    children: [
                      // Y-axis label
                      Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Text(
                          i < yLabels.length ? yLabels[i] : '',
                          style: const TextStyle(
                              fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ),
                      // Cells
                      for (final cell in matrix[i])
                        Container(
                          height: 28,
                          width: 28,
                          color: getColor((cell as num).toDouble()),
                          alignment: Alignment.center,
                          child: Text(
                            '${cell.toString()}',
                            style: const TextStyle(
                                fontSize: 10,
                                color: Colors.white,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Min: ${minVal.toStringAsFixed(1)}  Max: ${maxVal.toStringAsFixed(1)}',
              style: Theme.of(ctx.buildContext).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  },
  exampleData: [
        () => '''
      [
        {
          "id": "root",
          "component": {
            "HeatMap": {
              "title": {"literalString": "Sea Surface Temperature (°C)"},
              "xLabels": {"literalArray": ["A", "B", "C", "D", "E"]},
              "yLabels": {"literalArray": ["1", "2", "3", "4"]},
              "matrix": {
                "literalArray": [
                  [24, 26, 28, 29, 30],
                  [22, 25, 27, 28, 29],
                  [20, 23, 25, 26, 27],
                  [18, 21, 23, 24, 25]
                ]
              }
            }
          }
        }
      ]
    ''',
  ],
);
