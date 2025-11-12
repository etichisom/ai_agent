import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:json_schema_builder/json_schema_builder.dart';
import 'package:genui/genui.dart';


final _lineChartSchema = S.object(
  properties: {
    'labels': A2uiSchemas.stringArrayReference(description: 'X-axis labels'),
    'values': S.object(
      description: 'Numeric values over time',
      properties: {
        'literalArray': S.list(items: S.number()),
      },
    ),
    'title': A2uiSchemas.stringReference(description: 'Chart title'),
  },
  required: ['labels', 'values'],
);

final lineChart = CatalogItem(
  name: 'LineChart',
  dataSchema: _lineChartSchema,
  widgetBuilder: (ctx) {
    final json = ctx.data as Map<String, dynamic>;
    final labels = (json['labels']?['literalArray'] as List?)?.cast<String>() ?? [];
    final values = (json['values']?['literalArray'] as List?)
        ?.map((v) => (v as num).toDouble())
        .toList() ??
        [];
    final title = json['title']?['literalString'] ?? 'Line Chart';

    return Card(
      elevation: 2,
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Text(title, style: Theme.of(ctx.buildContext).textTheme.titleMedium),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, _) {
                          final i = value.toInt();
                          if (i < 0 || i >= labels.length) return const SizedBox();
                          return Text(labels[i], style: const TextStyle(fontSize: 10));
                        },
                      ),
                    ),
                    leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: true),
                    ),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      isCurved: true,
                      barWidth: 3,
                      spots: [
                        for (int i = 0; i < values.length; i++)
                          FlSpot(i.toDouble(), values[i]),
                      ],
                    ),
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
            "LineChart": {
              "labels": {"literalArray": ["Jan", "Feb", "Mar", "Apr", "May"]},
              "values": {"literalArray": [22, 25, 28, 30, 27]},
              "title": {"literalString": "Monthly Ocean Temperature (°C)"}
            }
          }
        }
      ]
    ''',
  ],
);
