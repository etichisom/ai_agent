// Copyright 2025
// PieChart CatalogItem for GenUI
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:json_schema_builder/json_schema_builder.dart';
import 'package:genui/genui.dart';


final _pieChartSchema = S.object(
  properties: {
    'labels': A2uiSchemas.stringArrayReference(
      description: 'List of labels for the pie chart.',
    ),
    'values': S.object(
      description: 'List of numeric values for each label.',
      properties: {
        'path': S.string(description: 'Path to numeric array in DataModel.'),
        'literalArray': S.list(items: S.number()),
      },
    ),
    'title': A2uiSchemas.stringReference(description: 'Chart title.'),
  },
  required: ['labels', 'values'],
);

final pieChart = CatalogItem(
  name: 'PieChart',
  dataSchema: _pieChartSchema,
  widgetBuilder: (itemContext) {
    final json = itemContext.data as Map<String, dynamic>;

    // Extract literal arrays if present
    final labels = (json['labels']?['literalArray'] as List?)?.cast<String>() ?? [];
    final values = (json['values']?['literalArray'] as List?)
        ?.map((v) => (v as num).toDouble())
        .toList() ??
        [];
    final title = json['title']?['literalString'] ?? 'Pie Chart';

    final total = values.fold<double>(0, (a, b) => a + b);

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
              child: PieChart(
                PieChartData(
                  sections: List.generate(values.length, (i) {
                    final value = values[i];
                    return PieChartSectionData(
                      value: value,
                      title:
                      "${labels[i]} ${(value / total * 100).toStringAsFixed(1)}%",
                      radius: 60,
                      titleStyle:
                      const TextStyle(fontSize: 11, color: Colors.white),
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
            "PieChart": {
              "labels": {
                "literalArray": ["Apples", "Bananas", "Cherries"]
              },
              "values": {
                "literalArray": [40, 35, 25]
              },
              "title": {"literalString": "Fruit Sales"}
            }
          }
        }
      ]
    ''',
  ],
);
