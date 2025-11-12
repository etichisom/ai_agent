import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:json_schema_builder/json_schema_builder.dart';
import 'package:genui/genui.dart';


final _scatterSchema = S.object(
  properties: {
    'xValues': S.object(properties: {
      'literalArray': S.list(items: S.number()),
    }),
    'yValues': S.object(properties: {
      'literalArray': S.list(items: S.number()),
    }),
    'title': A2uiSchemas.stringReference(),
  },
  required: ['xValues', 'yValues'],
);

final scatterChart = CatalogItem(
  name: 'ScatterChart',
  dataSchema: _scatterSchema,
  widgetBuilder: (ctx) {
    final json = ctx.data as Map<String, dynamic>;
    final xs = (json['xValues']?['literalArray'] as List?)
        ?.map((v) => (v as num).toDouble())
        .toList() ?? [];
    final ys = (json['yValues']?['literalArray'] as List?)
        ?.map((v) => (v as num).toDouble())
        .toList() ?? [];
    final title = json['title']?['literalString'] ?? 'Scatter Chart';

    return Card(
      elevation: 2,
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(title, style: Theme.of(ctx.buildContext).textTheme.titleMedium),
            SizedBox(
              height: 200,
              child: ScatterChart(
                ScatterChartData(
                  scatterSpots: [
                    for (int i = 0; i < xs.length && i < ys.length; i++)
                      ScatterSpot(xs[i], ys[i]),
                  ],
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
            "ScatterChart": {
              "xValues": {"literalArray": [1, 2, 3, 4, 5]},
              "yValues": {"literalArray": [2, 3.5, 3, 4.5, 5]},
              "title": {"literalString": "Temperature vs Depth"}
            }
          }
        }
      ]
    ''',
  ],
);
