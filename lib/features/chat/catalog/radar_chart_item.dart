import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:json_schema_builder/json_schema_builder.dart';
import 'package:genui/genui.dart';

final _radarSchema = S.object(
  properties: {
    'labels': A2uiSchemas.stringArrayReference(),
    'values': S.object(properties: {
      'literalArray': S.list(items: S.number()),
    }),
    'title': A2uiSchemas.stringReference(),
  },
  required: ['labels', 'values'],
);

final radarChart = CatalogItem(
  name: 'RadarChart',
  dataSchema: _radarSchema,
  widgetBuilder: (ctx) {
    final json = ctx.data as Map<String, dynamic>;
    final labels = (json['labels']?['literalArray'] as List?)?.cast<String>() ?? [];
    final values = (json['values']?['literalArray'] as List?)
        ?.map((v) => (v as num).toDouble())
        .toList() ?? [];
    final title = json['title']?['literalString'] ?? 'Radar Chart';

    return Card(
      elevation: 2,
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(title, style: Theme.of(ctx.buildContext).textTheme.titleMedium),
            SizedBox(
              height: 220,
              child: RadarChart(
                RadarChartData(
                  radarShape: RadarShape.polygon,
                  dataSets: [
                    RadarDataSet(
                      dataEntries: values.map((v) => RadarEntry(value: v)).toList(),
                      fillColor: Colors.blue.withValues(alpha: 0.3),
                      borderColor: Colors.blue,
                      entryRadius: 2,
                    ),
                  ],
                  // ✅ Use these new API properties
                  titleTextStyle: const TextStyle(fontSize: 10),
                  titlePositionPercentageOffset: 0.2,
                  getTitle: (index, angle) {
                    if (index < 0 || index >= labels.length) {
                      return const RadarChartTitle(text: '');
                    }
                    return RadarChartTitle(text: labels[index]);
                  },
                ),
              ),
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
            "RadarChart": {
              "labels": {"literalArray": ["Temp", "Salinity", "pH", "Depth", "Oxygen"]},
              "values": {"literalArray": [7, 5, 9, 6, 8]},
              "title": {"literalString": "Ocean Variable Radar"}
            }
          }
        }
      ]
    ''',
  ],
);
