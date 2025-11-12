// Combines PieChart and BarChart into a single catalog.
import 'package:genui/genui.dart';
import 'package:hack_the_future_starter/features/chat/catalog/bar_chart_widget.dart';
import 'package:hack_the_future_starter/features/chat/catalog/pie_chart_widget.dart';


final chartsCatalog = CoreCatalogItems.asCatalog().copyWith([
  pieChart,
  barChart,
]);
