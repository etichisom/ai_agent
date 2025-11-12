import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:json_schema_builder/json_schema_builder.dart';
import 'package:genui/genui.dart';

final _donutSchema = S.object(
  properties: {
    'labels': A2uiSchemas.stringArrayReference(),
    'values': S.object(properties: {
      'literalArray': S.list(items: S.number()),
    }),
    'title': A2uiSchemas.stringReference(),
  },
  required: ['labels', 'values'],
);

final donutChart = CatalogItem(
  name: 'DonutChart',
  dataSchema: _donutSchema,
  widgetBuilder: (ctx) {
    final json = ctx.data as Map<String, dynamic>;
    final labels = (json['labels']?['literalArray'] as List?)?.cast<String>() ?? [];
    final values = (json['values']?['literalArray'] as List?)
        ?.map((v) => (v as num).toDouble())
        .toList() ?? [];
    final title = json['title']?['literalString'] ?? 'Donut Chart';
    final total = values.fold<double>(0, (a, b) => a + b);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Text(title, style: Theme.of(ctx.buildContext).textTheme.titleMedium),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  centerSpaceRadius: 40,
                  sections: List.generate(values.length, (i) {
                    final v = values[i];
                    return PieChartSectionData(
                      value: v,
                      title: "${labels[i]} ${(v / total * 100).toStringAsFixed(1)}%",
                      radius: 60,
                      titleStyle: const TextStyle(fontSize: 11, color: Colors.white),
                    );
                  }),
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
            "DonutChart": {
              "labels": {"literalArray": ["Phytoplankton", "Zooplankton", "Fish"]},
              "values": {"literalArray": [55, 30, 15]},
              "title": {"literalString": "Marine Biomass Composition"}
            }
          }
        }
      ]
    ''',
  ],
);
