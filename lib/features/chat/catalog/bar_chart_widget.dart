// BarChart CatalogItem for GenUI
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:json_schema_builder/json_schema_builder.dart';
import 'package:genui/genui.dart';

final _barChartSchema = S.object(
  properties: {
    'labels': A2uiSchemas.stringArrayReference(
      description: 'List of category labels.',
    ),
    'values': S.object(
      description: 'List of numeric values for each category.',
      properties: {
        'path': S.string(description: 'Path to numeric array in DataModel.'),
        'literalArray': S.list(items: S.number()),
      },
    ),
    'title': A2uiSchemas.stringReference(description: 'Chart title.'),
  },
  required: ['labels', 'values'],
);

final barChart = CatalogItem(
  name: 'BarChart',
  dataSchema: _barChartSchema,
  widgetBuilder: (itemContext) {
    final json = itemContext.data as Map<String, dynamic>;

    final labels = (json['labels']?['literalArray'] as List?)?.cast<String>() ?? [];
    final values = (json['values']?['literalArray'] as List?)
        ?.map((v) => (v as num).toDouble())
        .toList() ??
        [];
    final title = json['title']?['literalString'] ?? 'Bar Chart';

    return Card(
      elevation: 2,
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(title, style: Theme.of(itemContext.buildContext).textTheme.titleMedium),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: true)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, _) {
                          final index = value.toInt();
                          if (index < 0 || index >= labels.length) return const SizedBox();
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(labels[index],
                                style: const TextStyle(fontSize: 10)),
                          );
                        },
                      ),
                    ),
                  ),
                  barGroups: List.generate(
                    values.length,
                        (i) => BarChartGroupData(
                      x: i,
                      barRods: [
                        BarChartRodData(
                          toY: values[i],
                          width: 14,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ],
                    ),
                  ),
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
            "BarChart": {
              "labels": {
                "literalArray": ["Q1", "Q2", "Q3", "Q4"]
              },
              "values": {
                "literalArray": [25, 40, 30, 50]
              },
              "title": {"literalString": "Quarterly Sales"}
            }
          }
        }
      ]
    ''',
  ],
);
